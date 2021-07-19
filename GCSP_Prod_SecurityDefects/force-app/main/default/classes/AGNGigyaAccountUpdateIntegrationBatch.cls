/**
* --------------
* Allergan GDPR
* November 2018
* --------------
* This Batch class retrieves accounts modified after the last sync
* and push in Gigya the updated fields
* == run it with batch size = 9
*/
public class AGNGigyaAccountUpdateIntegrationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    private static AGN_GIGYA_REST_API__c gigyaSettings = AGN_GIGYA_REST_API__c.getInstance('Gigya_Credentials');
    private static final String TURKEY_COUNTRY_CODE = 'TR';
    //private static final String BRAZIL_COUNTRY_CODE = 'BR';
    private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
    private Integer totalCount = 0;
    private Datetime datetimestamp = null;
    private Datetime syncStartDatetime;
    
    public AGNGigyaAccountUpdateIntegrationBatch() {
   }
    
    public AGNGigyaAccountUpdateIntegrationBatch(String datetimestampString) {
        datetimestamp = DateTime.newInstance(Long.valueOf(datetimestampString));
    }
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        this.syncStartDatetime = System.now();
        
        Datetime lastSync = null;
        if (datetimestamp != null) {
            lastSync = datetimestamp;
        } else {
            lastSync = gigyaSettings.AGN_Last_Account_Update_Sync_datetime__c;
        }
        Set<String> ENABLED_COUNTRIES_CODES = AGN_GDPRCountriesUtil.getConsentCountryCodes();
        //adding turkey code, we will include only records in cyprus 
        ENABLED_COUNTRIES_CODES.add(TURKEY_COUNTRY_CODE);
        
        
        String accountProfessionalRT = Label.AGN_Account_Professional_RecordType;
        String query = 'SELECT Id, FirstName, LastName, PersonEmail, Country_Name_AGN__c, Status_AGN__c, '+
            'Additional_Status_AGN__c, Email_Internal_AGN__c, External_ID_vod__c, External_ID2_AGN__c, Middle_vod__c, ' +
            'MDM_ID_AGN__c, Country_vod__r.Name, Specialty_Allergan_1_AGN__r.Name, Sub_Specialty_Allergan_AGN__r.Name, ' +
            'Email_Sent_Date_AGN__c,Distribution_ID_AGN__c,Physician_Registration_Reference_AGN__c, ' +
            'Specialty_1_AGN__r.Name, Specialty_2_AGN__r.Name, Salutation, Privacy_Law_Status_AGN__c ' +
            'FROM Account '+
            'WHERE Country_vod__r.Name IN :ENABLED_COUNTRIES_CODES '+
            'AND Country_vod__r.Name NOT IN (\'RU\')' +
            'AND RecordType.DeveloperName = :accountProfessionalRT ';
        if (lastSync != null) {
            query += 'AND lastModifiedDate >= :lastSync ';
        }
        query += 'ORDER BY lastModifiedDate ASC ';
        
        try {
            
            return Database.getQueryLocator(query);
        } catch(AGNGigyaValidationException e) {
            validationExceptions.add(e);
        }
        return null;
    }
    
    /**
* ---=== D006 ===---
* na = number of accounts per batch, or batch size
* nn = max number of notifications
* nc = max number of Gigya EPM accounts = 3
*
* max callouts = na * (nn + nc) + 2
* then: na = (100-3)/(nn + 2)
* ------------------
*   (commented) AGNGigyaRESTAccount.getEmailsFromEmails
*   AGNGigyaRESTAccount.getUsersByAccountsMap
*   AGNGigyaRESTNotification.getAllNotificationsByAccountIdsMap
*   for each account:
*       for each notification:
*               AGNGigyaRESTNotification.setNotification
*       if no consent:
*           (3) getToken + AGNGigyaRESTAccount.registerAccount + AGNGigyaRESTAccount.setAccountInfo
*       for each consent:
*           (max 3) AGNGigyaRESTAccount.setAccountInfo
*/
    public void execute(Database.BatchableContext batchableContext, List<Account> accounts) {
        totalCount = totalCount + accounts.size();
        system.debug('Query is'+totalCount);
        System.debug('execute started');
        // initializing maps
        Set<String> veevaAccountEmails = new Set<String>();
        List<String> veevaAccountIds = new List<String>();
        for (Account account : accounts) {
            veevaAccountIds.add(account.Id);
            if (!String.isBlank(account.PersonEmail)) {
                veevaAccountEmails.add(account.PersonEmail);
            }
        }
        
        //Set<String> gigyaEmails = AGNGigyaRESTAccount.getEmailsFromEmails(veevaAccountEmails);
        Map<String, List<AGNGigyaAccount>> gigyaAccountsMap = AGNGigyaRESTAccount.getUsersByAccountsMap(veevaAccountIds);
        Map<String, List<AGNGigyaNotification>> gigyaNotificationsMap = AGNGigyaRESTNotification.getAllNotificationsByAccountIdsMap(veevaAccountIds);
        
        // executing algorithm
         for (Account account : accounts){
            System.debug('working on account|'+account);
            
            // notification process - start
            System.debug('- notification process started');
            List<AGNGigyaNotification> gigyaNotifications = gigyaNotificationsMap.get(account.Id);
            if (gigyaNotifications == null) {
                gigyaNotifications = new List<AGNGigyaNotification>();
            }
            for (AGNGigyaNotification gigyaNotification : gigyaNotifications) {
                System.debug('-- working on gigyaNotification|' + gigyaNotification);
                List<String> dataFieldsToEmpty = new List<String>();
                AGNgigyaNotification newGigyaNotification = AGNGigyaMCConsentUtil.getNewGigyaNotification(gigyaNotification, account, dataFieldsToEmpty);
                try {
                    if (newGigyaNotification.isUpdated() || dataFieldsToEmpty.size() > 0) {
                        System.debug('D003 - notification process - notification updated|' + newGigyaNotification);
                        AGNGigyaRESTNotification.setNotification(newGigyaNotification, dataFieldsToEmpty);
                    }
                } catch(AGNGigyaValidationException e) {
                    e.errorDetail = e.errorDetail + '|account: ' + account + '|gigyaUID: ' + String.valueOf(gigyaNotification.getUserId());
                    validationExceptions.add(e);
                }
            }
            // notification process - end
            //system.debug('a---gigyaAccountsMap' +gigyaAccountsMap);
            // consent process - start
            //system.debug('a----account.Id--->' +account.Id);
            List<AGNGigyaAccount> gigyaAccounts = gigyaAccountsMap.get(account.Id);
            system.debug('a---gigyaAccounts' +gigyaAccounts);
            if (gigyaAccounts == null) {
                gigyaAccounts = new List<AGNGigyaAccount>();
            }
            System.debug('- gigyaAccounts.size()|'+gigyaAccounts.size());
            System.debug('- account.Privacy_Law_Status_AGN__c|'+account.Privacy_Law_Status_AGN__c);
            if ((gigyaAccounts.size() == 0 && !account.Privacy_Law_Status_AGN__c)) {
                System.debug('-- gigya account is empty and privacy law status is false, then create a new account');
                AGNGigyaAccount newGigyaAccount = new AGNGigyaAccount();
                newGigyaAccount.setId(account.Id);
                //if (!String.isBlank(account.PersonEmail) && !gigyaEmails.contains(account.PersonEmail)) {
               
                if (!String.isBlank(account.PersonEmail)) {
                    newGigyaAccount.setEmail(account.PersonEmail);
                    newGigyaAccount.setUsername(account.PersonEmail);
                } else {
                    newGigyaAccount.setUsername(account.Id);
                }                 
                    
                
                newGigyaAccount.setFirstName(account.FirstName);
                newGigyaAccount.setLastName(account.LastName);                
                newGigyaAccount.setCountryName(account.Country_Name_AGN__c);
                newGigyaAccount.setStatus(account.Status_AGN__c);
                newGigyaAccount.setAdditionalStatus(account.Additional_Status_AGN__c);
                newGigyaAccount.setSecondaryEmail(account.Email_Internal_AGN__c);
                newGigyaAccount.setExternalId(account.External_ID_vod__c);
                newGigyaAccount.setExternalId2(account.External_ID2_AGN__c);
                newGigyaAccount.setMdmId(account.MDM_ID_AGN__c);
                newGigyaAccount.setCountryCode(account.Country_vod__r.Name);
                system.debug('a-----newGigyaAccount1' +newGigyaAccount);
                //Added specific for Brazil
                system.debug('Current Country is'+account.Country_vod__r.Name);
                if(account.Country_vod__r.Name == 'BR' ){
                    newGigyaAccount.setDistributionID(account.Distribution_ID_AGN__c);
                    newGigyaAccount.setphysicianRefNumber(account.Physician_Registration_Reference_AGN__c);
                    //newGigyaAccount.setBrCountryCode(account.Country_vod__r.Name);
                }            
                system.debug('a-----newGigyaAccount2' +newGigyaAccount);
                if (!String.isBlank(account.External_ID_vod__c) && account.External_ID_vod__c.startsWith('W')) {
                    newGigyaAccount.setSpecialty1(account.Specialty_1_AGN__r.Name);
                    newGigyaAccount.setSpecialty2(account.Specialty_2_AGN__r.Name);
                } else {
                    newGigyaAccount.setSpecialty1(account.Specialty_Allergan_1_AGN__r.Name);
                    newGigyaAccount.setSpecialty2(account.Sub_Specialty_Allergan_AGN__r.Name);
                }
                newGigyaAccount.setSalutation(account.Salutation);
                system.debug('a-----newGigyaAccount' +newGigyaAccount);
                try { 
                    //System.debug('D006/D007 - consent process - new account created|' + newGigyaAccount);
                    AGNGigyaRESTAccount.registerAccount(newGigyaAccount);
                    System.debug('D006/D007 - consent process - new account created|' + newGigyaAccount);
                } catch(AGNGigyaValidationException e) {
                    e.errorDetail = e.errorDetail + '|account: ' + account + '|new Gigya account not created|' + newGigyaAccount;
                    validationExceptions.add(e);
                }
            }
            for (AGNGigyaAccount gigyaAccount : gigyaAccounts) {
                System.debug('-- working on gigyaAccount|' + gigyaAccount);
                List<String> profileFieldsToEmpty = new List<String>();
                List<String> dataFieldsToEmpty = new List<String>();
                AGNGigyaAccount newGigyaAccount = AGNGigyaMCConsentUtil.getNewGigyaAccount(gigyaAccount, account, profileFieldsToEmpty, dataFieldsToEmpty);
                system.debug('a---newGigyaAccount.isUpdated()--->' +newGigyaAccount.isUpdated() + 'a---profileFieldsToEmpty.size()--->' +profileFieldsToEmpty.size() +'a--dataFieldsToEmpty.size()--->' +dataFieldsToEmpty.size());
                try {
                    if (newGigyaAccount.isUpdated() || profileFieldsToEmpty.size() > 0 || dataFieldsToEmpty.size() > 0) {
                        System.debug('D003/D005-2 - consent process - account updated|' + newGigyaAccount);
                        System.debug('D003/D005-2 - dataFieldsToEmpty|' + dataFieldsToEmpty);
                        AGNGigyaRESTAccount.setAccountInfo(newGigyaAccount, profileFieldsToEmpty, dataFieldsToEmpty);
                    }
                } catch(AGNGigyaValidationException e) {
                    e.errorDetail = e.errorDetail + '|account: ' + account + '|gigyaUID: ' + String.valueOf(gigyaAccount.getUserId());
                    validationExceptions.add(e);
                }
            } // consent process - end
        }
    }
    public void finish(Database.BatchableContext batchableContext){
        if (datetimestamp != null) {
            System.debug('this.syncStartDatetime|' + this.syncStartDatetime);
        } else {
            //Cognizant- CC - Line Number - 202
            if(Schema.sObjectType.AGN_GIGYA_REST_API__c.fields.AGN_Last_Account_Update_Sync_datetime__c.isAccessible() && Schema.sObjectType.AGN_GIGYA_REST_API__c.fields.AGN_Last_Account_Update_Sync_datetime__c.isUpdateable()){
                gigyaSettings.AGN_Last_Account_Update_Sync_datetime__c = this.syncStartDatetime;                
            }
            
            update gigyaSettings;
        }
        if(!validationExceptions.isEmpty()) {
            AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, totalCount);
            System.debug('>>> EXCEPTION <<<');
            System.debug(validationExceptions[0]);
        } else {
            AGNInterfacePublishEvent.logBatchApex(batchableContext, totalCount);
        }
    }
    
}