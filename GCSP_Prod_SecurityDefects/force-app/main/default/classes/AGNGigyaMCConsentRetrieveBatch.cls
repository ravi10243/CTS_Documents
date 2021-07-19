/**
* --------------
* Allergan GDPR
* March 2018
* --------------
* This class retrieves new consent updates from Gigya.
*/

public class AGNGigyaMCConsentRetrieveBatch implements Database.Batchable<Object>, Database.AllowsCallouts, Database.Stateful {
    
    private static AGN_GIGYA_REST_API__c gigyaSettings = AGN_GIGYA_REST_API__c.getInstance('Gigya_Credentials');
    private List<AGNGigyaValidationException> validationExceptions = new List<AGNGigyaValidationException>();
    private Integer totalCount = 0;
    private Datetime syncStartDatetime;
    private static final String TURKEY_COUNTRY_CODE = 'TR';
    public Set<String> ENABLED_COUNTRIES_CODES = AGN_GDPRCountriesUtil.getConsentCountryCodes();
    
    public List<Object> start(Database.BatchableContext batchableContext){
        ENABLED_COUNTRIES_CODES.add(TURKEY_COUNTRY_CODE);
        this.syncStartDatetime = System.now();
        
        Datetime lastSync = gigyaSettings.AGN_Last_Consent_Sync_DateTime__c;
        String lastSyncString = lastSync == null ? '' : String.valueOf(lastSync.getTime());
        try {
            return AGNGigyaConsentFactory.getLastUpdatedConsents(lastSyncString);
        } catch(AGNGigyaValidationException e) {
            validationExceptions.add(e);
        }
        return new List<Object>();
    }
    private List<Success_Error_History_AGN__c> accountsNotFounds = new List<Success_Error_History_AGN__c>();
    
    public void execute(Database.BatchableContext batchableContext, List<Object> gigyaObjects) {
        totalCount += gigyaObjects.size();
        accountsNotFounds = new List<Success_Error_History_AGN__c>();
        List<Multichannel_Consent_vod__c> newMultichannelConsents = new List<Multichannel_Consent_vod__c>();
        for (Object gigyaObject : gigyaObjects) {
            try {
                Map<String, Object> gigyaRecord = (Map<String, Object>) gigyaObject;
                String gigyaUID = String.valueOf(gigyaRecord.get('UID'));
                String gigyaLastUpdatedTimestamp  = String.valueOf(gigyaRecord.get('lastUpdatedTimestamp'));
                Map<String, Object> gigyaRecordData = (Map<String, Object>) gigyaRecord.get('data');
                String gigyaExtenalId = null;
                String gigyaMdmId = null;
                String gigyaSfdcId = null;
                Id accountId = null;
                if (gigyaRecordData != null) {
                    gigyaExtenalId = String.valueOf(gigyaRecordData.get('External_ID_vod__c'));
                    gigyaSfdcId = String.valueOf(gigyaRecordData.get('SFDCId'));
                    gigyaMdmId = String.valueOf(gigyaRecordData.get('MDM_ID_AGN__c'));
                    try {
                        accountId = [SELECT Id FROM Account WHERE Id = :gigyaSfdcId LIMIT 1].Id;
                    } catch (Exception e){
                    }
                }
                List<AGNGigyaConsent> gigyaConsents = AGNGigyaConsentFactory.getSubscriptionsPreferences(gigyaRecord);
                for (AGNGigyaConsent gigyaConsent : gigyaConsents) {
                    if (ENABLED_COUNTRIES_CODES.contains(gigyaConsent.country.toUpperCase())) {
                        Multichannel_Consent_vod__c veevaConsent =
                            AGNGigyaMCConsentUtil.getConsentFromVeeva(gigyaSfdcId, gigyaConsent.channel,
                                                                      gigyaExtenalId, gigyaMdmId, gigyaConsent.consentId,
                                                                      gigyaConsent.country, gigyaConsent.language);
                        String newConsentTypeId = null;
                        String newRecordTypeId = null;
                        String newContentTypeId = null;
                        String newConsentLineId = null;
                        String newConsentStatus = gigyaConsent.isSubscribed ? 'Opt_In_vod' : 'Opt_Out_vod';
                        
                        if (veevaConsent != null) {
                            Boolean veevaSubscribed = veevaConsent.Opt_Type_vod__c == 'Opt_In_vod';
                            if (veevaSubscribed != gigyaConsent.isSubscribed) {
                                newConsentTypeId = veevaConsent.Consent_Type_vod__c;
                                newRecordTypeId = veevaConsent.RecordTypeId;
                                newContentTypeId = veevaConsent.Content_Type_vod__c;
                                newConsentLineId = veevaConsent.Consent_Line_vod__c;
                            }
                            // it creates a new mcconsent only if a consent type is found and
                            // and the consent is opted in
                        } else {
                            if (gigyaConsent.isSubscribed) {
                                if (AGNGigyaConsentFactory.EMAIL_BASED_CONSENTS.contains(gigyaConsent.consentId)) {
                                    Consent_Line_vod__c clTemp = AGNGigyaMCConsentUtil.getConsentLineFromConsentTypeContentType(gigyaConsent.consentId,
                                                                                                                                gigyaConsent.country, gigyaConsent.language);
                                    if (clTemp != null) {
                                        newConsentTypeId = clTemp.Consent_Type_vod__c;
                                        newRecordTypeId = [SELECT Id
                                                           FROM RecordType
                                                           WHERE SobjectType='Multichannel_Consent_vod__c'
                                                           AND DeveloperName = :AGNGigyaMCConsentUtil.getApprovedEmailRecordType()].Id;
                                        newContentTypeId = clTemp.Content_Type_vod__c;
                                        newConsentLineId = clTemp.Id;
                                    }
                                } else {
                                    Consent_Type_vod__c ctTemp = AGNGigyaMCConsentUtil.getConsentType(gigyaConsent.consentId, gigyaConsent.country, gigyaConsent.language);
                                    if (ctTemp != null) {
                                        newConsentTypeId = ctTemp.id;
                                        newRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType='Multichannel_Consent_vod__c' AND DeveloperName = :gigyaConsent.consentId].Id;
                                    }
                                }
                            }
                            if (accountId != null) {
                                String detailMessage = 'MCConsent not found. ';
                                detailMessage += 'Account: ' + accountId + ' ';
                                detailMessage += '- Channel: ' + gigyaConsent.channel;
                                detailMessage += '- ExternalId: ' + gigyaExtenalId;
                                detailMessage += '- ConsentId: ' + gigyaConsent.consentId + '.' + gigyaConsent.country + '.' + gigyaConsent.language;
                                
                                Success_Error_History_AGN__c errorTemp = new Success_Error_History_AGN__c(
                                    Allergan_Error_Table__c = 'Error',
                                    Error_Id_AGN__c = null,
                                    Record_Details_AGN__c = detailMessage,
                                    Success_Code_from_Gigya_AGN__c = null
                                );
                                System.debug(detailMessage);
                                accountsNotFounds.add(errorTemp);
                            }
                        }
             
                        if (newConsentTypeId != null && gigyaSfdcId != null && newRecordTypeId != null) {
                            System.debug(veevaConsent);
                            System.debug(gigyaConsent);
                            System.debug('found!');
                            //Cognizant- CC - Line Number - 125,128,131,134,137,145,148,151,154,159,165
                            Multichannel_Consent_vod__c newVeevaConsent = new Multichannel_Consent_vod__c();
                            if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isAccessible() && Schema.sObjectType.Multichannel_Consent_vod__c.fields.Account_vod__c.isCreateable() ){
                                newVeevaConsent.Account_vod__c = gigyaSfdcId;
                            } 
                            if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Opt_Type_vod__c.isCreateable()){
                                newVeevaConsent.Opt_Type_vod__c = newConsentStatus;//Cognizant- CC - Line Number - 
                            }
                            if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.RecordTypeId.isCreateable()){
                                newVeevaConsent.RecordTypeId = newRecordTypeId;
                            }
                            if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Last_Device_vod__c.isCreateable()){
                                newVeevaConsent.Last_Device_vod__c = 'Data_Load_vod';
                            }
                            if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Signature_ID_vod__c.isCreateable()){
                                newVeevaConsent.Signature_ID_vod__c = 'gigya';
                            }
                            
                            Datetime lastUpdatedTimestamp = Datetime.now();
                            if (gigyaLastUpdatedTimestamp != null && gigyaLastUpdatedTimestamp.length() > 0) {
                                lastUpdatedTimestamp = DateTime.newInstance(Long.valueOf(gigyaLastUpdatedTimestamp));
                            }
                            if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Capture_Datetime_vod__c.isCreateable()){
                                newVeevaConsent.Capture_Datetime_vod__c = lastUpdatedTimestamp;
                            }
                            if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.FromGigya_AGN__c.isCreateable()){
                                newVeevaConsent.FromGigya_AGN__c = true;
                            } 
                            if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Consent_Type_vod__c.isCreateable()){
                                newVeevaConsent.Consent_Type_vod__c = newConsentTypeId;
                            } 
                            if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Channel_Value_vod__c.isCreateable()){
                                newVeevaConsent.Channel_Value_vod__c = gigyaConsent.channel;
                            } 
                            
                            if (!String.isEmpty(newContentTypeId)) {
                                if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Content_Type_vod__c.isCreateable()){
                                    newVeevaConsent.Content_Type_vod__c = newContentTypeId;
                                }
                                
                            }
                            if (!String.isEmpty(newConsentLineId)) {
                                if(Schema.sObjectType.Multichannel_Consent_vod__c.fields.Consent_Line_vod__c.isCreateable()){
                                    newVeevaConsent.Consent_Line_vod__c = newConsentLineId;
                                }
                                
                            }
                            newMultichannelConsents.add(newVeevaConsent);
                        }
                    }
                }
            } catch(AGNGigyaValidationException e) {
                e.errorDetail = e.errorDetail + '|gigyaObject:' + String.valueOf(gigyaObject);
                validationExceptions.add(e);
                System.debug(e);
            }
        }
        if(Schema.sObjectType.Multichannel_Consent_vod__c.isCreateable()){
            insert newMultichannelConsents;
        }
        
    }
    
    public void finish(Database.BatchableContext batchableContext){
        // //Cognizant- CC - Line Number - 172
        if(Schema.sObjectType.AGN_GIGYA_REST_API__c.fields.AGN_Last_Consent_Sync_DateTime__c.isAccessible() && Schema.SobjectType.AGN_GIGYA_REST_API__c.fields.AGN_Last_Consent_Sync_DateTime__c.isupdateable()){
             gigyaSettings.AGN_Last_Consent_Sync_DateTime__c = this.syncStartDatetime;
        }       
        update gigyaSettings;
        if (!accountsNotFounds.isEmpty()) {
            String currentClassName = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
            AGNInterfaceLogger.log(currentClassName, null, accountsNotFounds);
        }
        if(!validationExceptions.isEmpty()){
            AGNInterfacePublishEvent.logBatchApex(batchableContext, validationExceptions, totalCount);
        } else {
            AGNInterfacePublishEvent.logBatchApex(batchableContext, totalCount);
        }
    }
}