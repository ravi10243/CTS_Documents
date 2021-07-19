/*****************************************************************************************************************************************************************
Apex  Class- AGN_GDPR_NOTIFICATION_INTEGRATION_GIGYA
Description- This class is used to send notification updates to gigya via REST integration. Whenever any of the two fields on account .i.e. GDPR_Notification_Status_AGN__c
or GDPR_Notification_Received_AGN__c is updated, history is  tracked in AccountHistory. This batch process picks all such records updated after last sync and send
them to gigya
Developer Name- Mansi Mittal
Development Date- 3 May 2018
********************************************************************************************************************************************************************/

global class AGN_GDPR_NOTIFICATION_INTEGRATION_GIGYA implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    private Set<String> ENABLED_COUNTRIES_CODES = new Set<String>();
    private Set<String> ENABLED_BR_COUNTRIES_CODES = new Set<String>();
    private static final String TURKEY_COUNTRY_CODE = 'TR';
    private static final String BRAZIL_COUNTRY_CODE = 'BR';
    global Integer successCount=0, errorCount=0;Integer totalCount=0;
    global Map<AGNGigyaValidationException, AccountHistory> errorRecordMap=new Map<AGNGigyaValidationException, AccountHistory>();
    private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        ENABLED_COUNTRIES_CODES = AGN_GDPRCountriesUtil.getCountryCodes();
        //ENABLED_BR_COUNTRIES_CODES = AGN_GDPRCountriesUtil.getCountryCodes();
        if (ENABLED_COUNTRIES_CODES.size() == 0) {
            throw new AGN_customException(0, 'ENABLED_COUNTRIES_CODES is empty!');
        }
        //adding turkey code, we will include only records in cyprus
        ENABLED_COUNTRIES_CODES.add(TURKEY_COUNTRY_CODE);
        ENABLED_BR_COUNTRIES_CODES.add(BRAZIL_COUNTRY_CODE);
        String query;DateTime lastBatchRunTime; Set<id> accHistIdSet= new Set<Id>();
        List<Success_Error_History_AGN__c> histList= new List<Success_Error_History_AGN__c>();
        List<string> acclst = new List<string>();
        //Added specfic to Brazil
        for(Account acc: [select id, country_vod__c,Country_vod__r.Name from Account where Account.Country_vod__r.Name in :ENABLED_BR_COUNTRIES_CODES Limit 1]){
            acclst.add(acc.country_vod__r.Name);
        }
        
        try{
            lastBatchRunTime= [SELECT Start_Date_AGN__c, Name, Run_Status__c,Run_Name_AGN__c FROM Interface_Run_Details_AGN__c where
                               Interface_Run_Details_AGN__c.Run_Name_AGN__c='AGN_GDPR_NOTIFICATION_INTEGRATION_GIGYA'
                               order by Start_Date_AGN__c desc LIMIT 1].Start_Date_AGN__c;
            
            System.debug('@@lastBatchRunTime@@'+lastBatchRunTime);
            
            for(Success_Error_History_AGN__c histInstance:[SELECT Record_Details_AGN__c ,Allergan_Error_Table__c,Allergan_Interface_Run_Details_AGN__c FROM Success_Error_History_AGN__c
                                                           Where Allergan_Interface_Run_Details_AGN__r.Name='AGN_GDPR_NOTIFICATION_INTEGRATION_GIGYA' and Allergan_Error_Table__c='Error'
                                                           and Allergan_Interface_Run_Details_AGN__r.Run_Status__c='Failed'])
            {
                Id accHistId= (Id) histInstance.Record_Details_AGN__c;
                accHistIdSet.add(accHistId);
                histInstance.Allergan_Error_Table__c='Success';
                histList.add(histInstance);
            }
            Update histList;
        }
        catch(Exception ex){
            lastBatchRunTime=null;
        }
        
        if(lastBatchRunTime!=null) {
            system.debug('Country code'+acclst);
            if(acclst.contains('BR')){
                 query='Select NewValue, OldValue, CreatedDate, AccountId, Field, Account.Id, '+
                'Account.Email_Template_Name_AGN__c, Account.External_ID_vod__c, Account.Salutation, Account.FirstName, '+
                'Account.Middle_vod__c, Account.LastName, Account.PersonEmail, Account.GDPR_Notification_Status_AGN__c, '+
                'Account.GDPR_Notification_Received_AGN__c, Account.External_ID2_AGN__c, Account.Country_vod__r.Name, ' +
                'Account.Country_Name_AGN__c, Account.Email_Internal_AGN__c, Account.Status_AGN__c, ' +
                'Account.Email_Sent_Date_AGN__c,Account.LGPD_Notification_Status_AGN__c,Account.Email_Sent_Received_Date_AGN__c, ' +
                'Account.Specialty_Allergan_1_AGN__r.Name, Account.Sub_Specialty_Allergan_AGN__r.Name, ' +
                'Account.Additional_Status_AGN__c, Account.Specialty_1_AGN__r.Name, Account.Specialty_2_AGN__r.Name ' +
                'From AccountHistory '+
                'Where ((( Field=\'GDPR_Notification_Received_AGN__c\' or Field= \'LGPD_Notification_Status_AGN__c\' ) ' +
                'and Account.Privacy_Law_Status_AGN__c != true ' +
                'and Account.Country_vod__r.Name in :ENABLED_COUNTRIES_CODES and createdDate>:lastBatchRunTime) or (id in :accHistIdSet)) ' +'AND Account.Country_vod__r.Name NOT IN (\'RU\')';
            }else{            
              
            query='Select NewValue, OldValue, CreatedDate, AccountId, Field, Account.Id, '+
                'Account.Email_Template_Name_AGN__c, Account.External_ID_vod__c, Account.Salutation, Account.FirstName, '+
                'Account.Middle_vod__c, Account.LastName, Account.PersonEmail, Account.GDPR_Notification_Status_AGN__c, '+
                'Account.GDPR_Notification_Received_AGN__c, Account.External_ID2_AGN__c, Account.Country_vod__r.Name, ' +
                'Account.Country_Name_AGN__c, Account.Email_Internal_AGN__c, Account.Status_AGN__c, ' +
                'Account.Email_Sent_Date_AGN__c,Account.LGPD_Notification_Status_AGN__c,Account.Email_Sent_Received_Date_AGN__c, ' +
                'Account.Specialty_Allergan_1_AGN__r.Name, Account.Sub_Specialty_Allergan_AGN__r.Name, ' +
                'Account.Additional_Status_AGN__c, Account.Specialty_1_AGN__r.Name, Account.Specialty_2_AGN__r.Name ' +
                'From AccountHistory '+
                'Where (((Field=\'GDPR_Notification_Status_AGN__c\' or Field=\'GDPR_Notification_Received_AGN__c\' ) ' +
                'and Account.Privacy_Law_Status_AGN__c != true ' +
                'and Account.Country_vod__r.Name in :ENABLED_COUNTRIES_CODES and createdDate>:lastBatchRunTime) or (id in :accHistIdSet)) ' +'AND Account.Country_vod__r.Name NOT IN (\'RU\')';
        }
    }
        else {
            if(acclst.contains('BR')){
                query='Select NewValue, OldValue, CreatedDate, AccountId, Field, Account.Id, ' +
                'Account.Email_Template_Name_AGN__c, Account.External_ID_vod__c, Account.Salutation, Account.FirstName, '+
                'Account.Middle_vod__c, Account.LastName, Account.PersonEmail, Account.GDPR_Notification_Status_AGN__c, '+
                'Account.GDPR_Notification_Received_AGN__c, Account.External_ID2_AGN__c, Account.Country_vod__r.Name, ' +
                'Account.Country_Name_AGN__c, Account.Email_Internal_AGN__c, Account.Status_AGN__c, ' +
                'Account.Email_Sent_Date_AGN__c,Account.LGPD_Notification_Status_AGN__c,Account.Email_Sent_Received_Date_AGN__c, ' +
                'Account.Specialty_Allergan_1_AGN__r.Name, Account.Sub_Specialty_Allergan_AGN__r.Name, ' +
                'Account.Additional_Status_AGN__c, Account.Specialty_1_AGN__r.Name, Account.Specialty_2_AGN__r.Name ' +
                'From AccountHistory '+
                'Where ( Field=\'GDPR_Notification_Received_AGN__c\' or Field=\'LGPD_Notification_Status_AGN__c\') ' +
                'and Account.Privacy_Law_Status_AGN__c != true ' +
                'and Account.Country_vod__r.Name in :ENABLED_COUNTRIES_CODES ' +'AND Account.Country_vod__r.Name NOT IN (\'RU\')';
            }else{
            query='Select NewValue, OldValue, CreatedDate, AccountId, Field, Account.Id, ' +
                'Account.Email_Template_Name_AGN__c, Account.External_ID_vod__c, Account.Salutation, Account.FirstName, '+
                'Account.Middle_vod__c, Account.LastName, Account.PersonEmail, Account.GDPR_Notification_Status_AGN__c, '+
                'Account.GDPR_Notification_Received_AGN__c, Account.External_ID2_AGN__c, Account.Country_vod__r.Name, ' +
                'Account.Country_Name_AGN__c, Account.Email_Internal_AGN__c, Account.Status_AGN__c, ' +
                'Account.Email_Sent_Date_AGN__c,Account.LGPD_Notification_Status_AGN__c,Account.Email_Sent_Received_Date_AGN__c, ' +
                'Account.Specialty_Allergan_1_AGN__r.Name, Account.Sub_Specialty_Allergan_AGN__r.Name, ' +
                'Account.Additional_Status_AGN__c, Account.Specialty_1_AGN__r.Name, Account.Specialty_2_AGN__r.Name ' +
                'From AccountHistory '+
                'Where (Field=\'GDPR_Notification_Status_AGN__c\' or Field=\'GDPR_Notification_Received_AGN__c\') ' +
                'and Account.Privacy_Law_Status_AGN__c != true ' +
                'and Account.Country_vod__r.Name in :ENABLED_COUNTRIES_CODES ' +'AND Account.Country_vod__r.Name NOT IN (\'RU\')';
        }
        }
        system.debug('check** :   '+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<AccountHistory> scope) {
        totalCount+=scope.size();
        AGNGigyaNotification notfctnInstance;
        for(AccountHistory aHist : scope) {
            // excluding Turkey cities not in Cyprus
            if (aHist.Account.Country_vod__r.Name != TURKEY_COUNTRY_CODE || (aHist.Account.Country_vod__r.Name == TURKEY_COUNTRY_CODE && AGN_GDPRCountriesUtil.accountHasCyprusAddressCity(aHist.Account.Id))) {
                notfctnInstance=new AGNGigyaNotification();
                notfctnInstance.setSalutation(aHist.Account.Salutation);
                notfctnInstance.setFirstName(aHist.Account.FirstName);
                notfctnInstance.setLastName(aHist.Account.LastName);
                notfctnInstance.setMiddleName(aHist.Account.Middle_vod__c);
                notfctnInstance.setEmail(aHist.Account.PersonEmail);
                notfctnInstance.setExternalId(aHist.Account.External_ID_vod__c);
                notfctnInstance.setSfdcId(aHist.Account.id);
                //Added specific to Brazil
                if(aHist.Account.Country_vod__r.Name !='BR'){
                    notfctnInstance.setEmailTemplateName(aHist.Account.Email_Template_Name_AGN__c);
                }
                
              
                 if(aHist.Field=='GDPR_Notification_Received_AGN__c') {
                    Boolean newGDPRReceieved=(Boolean) aHist.NewValue;
                    notfctnInstance.setNotificationReceived(newGDPRReceieved);
                } else {
                    notfctnInstance.setNotificationReceived(aHist.Account.GDPR_Notification_Received_AGN__c);
                }
                if(aHist.Field=='GDPR_Notification_Status_AGN__c') {
                    String newGDPRStatus=String.valueOf(aHist.NewValue);
                    notfctnInstance.setNotificationStatus(newGDPRStatus);
                } else {
                    notfctnInstance.setNotificationStatus(aHist.Account.GDPR_Notification_Status_AGN__c);
                }
                  if(aHist.Field=='LGPD_Notification_Status_AGN__c') {
                    String newGDPRStatus=String.valueOf(aHist.NewValue);
                    notfctnInstance.setNotificationStatusBR(newGDPRStatus);
                } else {
                    notfctnInstance.setNotificationStatusBR(aHist.Account.LGPD_Notification_Status_AGN__c);
                }
                if (aHist.Account.Email_Sent_Date_AGN__c != null) {
                    notfctnInstance.setEmailSentDate(String.valueOfGmt(aHist.Account.Email_Sent_Date_AGN__c));
                }
                notfctnInstance.setExternalId2(aHist.Account.External_ID2_AGN__c);
                notfctnInstance.setCountryCode(aHist.Account.Country_vod__r.Name);
                notfctnInstance.setCountryName(aHist.Account.Country_Name_AGN__c);
                notfctnInstance.setSecondaryEmail(aHist.Account.Email_Internal_AGN__c);
                notfctnInstance.setStatus(aHist.Account.Status_AGN__c);
                notfctnInstance.setAdditionalStatus(aHist.Account.Additional_Status_AGN__c);
                if (!String.isBlank(aHist.Account.External_ID_vod__c) && aHist.Account.External_ID_vod__c.startsWith('W')) {
                    notfctnInstance.setSpecialty1(aHist.Account.Specialty_1_AGN__r.Name);
                    notfctnInstance.setSpecialty2(aHist.Account.Specialty_2_AGN__r.Name);
                } else {
                    notfctnInstance.setSpecialty1(aHist.Account.Specialty_Allergan_1_AGN__r.Name);
                    notfctnInstance.setSpecialty2(aHist.Account.Sub_Specialty_Allergan_AGN__r.Name);
                }
                notfctnInstance.setVeevaCreatedDate(aHist.createdDate);
                notfctnInstance.setemailSentRecDate(aHist.Account.Email_Sent_Received_Date_AGN__c);
                
                System.debug('@@@notfctnInstance@@'+notfctnInstance);
                System.debug('@@@NotificationReceived@@'+notfctnInstance.getNotificationReceived());
                try {
                    Boolean success = AGNGigyaRESTNotification.setNotification(notfctnInstance);
                    if(success)
                        successCount++;
                    System.debug('Success Count'+successCount);
                } catch(AGNGigyaValidationException ex) {
                    errorCount++;
                    errorRecordMap.put(ex,aHist);
                    ex.errorDetail= aHist.id;
                    validationExceptions.add(ex);
                    System.debug('errorCount '+errorCount);
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        System.debug('Reached Finish** ');
        if(!validationExceptions.isEmpty()){
            AGNInterfacePublishEvent.logBatchApex(bc, validationExceptions, totalCount);
        }else{
            AGNInterfacePublishEvent.logBatchApex(bc, totalCount);
        }
        System.debug('totalCount'+totalCount);
        if (validationExceptions.size() > 0) {
            System.debug('>>> EXCEPTION <<<');
            System.debug(validationExceptions[0]);
            throw validationExceptions[0];
        }
        
    }
}