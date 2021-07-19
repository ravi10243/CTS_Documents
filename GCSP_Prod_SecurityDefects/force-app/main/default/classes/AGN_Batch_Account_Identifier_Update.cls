/**
***** @author- Akash
***** @date- 26/June/2019
***** @Release- 19R2 PMO2205
***** @Description- Apex Batch class created in order to update the account identifier field of Account object in batches. The Account Identifier field will update
                    with data for specific countries and with specific values. The countries which is mentioned in the custom setting.
                    AGN_DCR_Account_Identifier_Values__c is the custom setting which is used.
                    The query contains the record from last time query fired.
**/ 
global class AGN_Batch_Account_Identifier_Update implements Database.Batchable <sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        Datetime currTime = Datetime.now();
        AGN_DCR_Account_Identifier_Values__c accIdentifierSettings = AGN_DCR_Account_Identifier_Values__c.getOrgDefaults();
        Datetime prevTime = accIdentifierSettings.Account_Identifier_Update_Time_AGN__c;
        List<String> CountryCodeList = new List<String>();
        if(Schema.sObjectType.AGN_DCR_Account_Identifier_Values__c.fields.DCR_Account_Identifier_Address_Line_AGN__c.isAccessible()){ //swar cc
            CountryCodeList = accIdentifierSettings.DCR_Account_Identifier_Address_Line_AGN__c.split(',');
        }
        if(Schema.sObjectType.AGN_DCR_Account_Identifier_Values__c.fields.DCR_Account_Identifier_City_AGN__c.isAccessible()){ //swar cc
            CountryCodeList.addAll(accIdentifierSettings.DCR_Account_Identifier_City_AGN__c.split(','));
        }
        if(Schema.sObjectType.AGN_DCR_Account_Identifier_Values__c.fields.DCR_Account_Identifier_City_AGN__c.isAccessible()){ //swar cc
            CountryCodeList.addAll(accIdentifierSettings.DCR_Account_Identifier_City_AGN__c.split(','));
        }
        if(Schema.sObjectType.AGN_DCR_Account_Identifier_Values__c.fields.DCR_Account_Identifier_IQVIA_ID_AGN__c.isAccessible()){ //swar cc
            CountryCodeList.addAll(accIdentifierSettings.DCR_Account_Identifier_IQVIA_ID_AGN__c.split(','));
        }
        if(Schema.sObjectType.AGN_DCR_Account_Identifier_Values__c.fields.DCR_Account_Identifier_Postal_Code_AGN__c.isAccessible()){ //swar cc
            CountryCodeList.addAll(accIdentifierSettings.DCR_Account_Identifier_Postal_Code_AGN__c.split(','));
        }
        if(Schema.sObjectType.AGN_DCR_Account_Identifier_Values__c.fields.DCR_Account_Identifier_SAP_ID_AGN__c.isAccessible()){ //swar cc
            CountryCodeList.addAll(accIdentifierSettings.DCR_Account_Identifier_SAP_ID_AGN__c.split(','));
        }
        if(Schema.sObjectType.AGN_DCR_Account_Identifier_Values__c.fields.DCR_Account_Identifier_Status_AGN__c.isAccessible()){ //swar cc
            CountryCodeList.addAll(accIdentifierSettings.DCR_Account_Identifier_Status_AGN__c.split(','));
        }
        Set<String> CountryCodeSet = new Set<String>(CountryCodeList);
        String accQuery = 'SELECT id,country_vod__c,country_vod__r.name,External_ID2_AGN__c,External_ID_vod__c,Status_AGN__c,'+
            'Address_Line_1_AGN__c,BillingCity,BillingPostalCode,Account_Identifier_vod__c,LastModifiedDate'+
            ' FROM Account WHERE LastModifiedDate >=: prevTime AND LastModifiedDate <: currTime '+
            'AND country_vod__c != '+null+' AND country_vod__r.name IN: CountryCodeSet';
        
        if(Schema.sObjectType.AGN_DCR_Account_Identifier_Values__c.fields.Acnt_Identifier_Previous_Update_Time_AGN__c.isUpdateable()){ //swar cc
            accIdentifierSettings.Acnt_Identifier_Previous_Update_Time_AGN__c = prevTime;
        }
        if(Schema.sObjectType.AGN_DCR_Account_Identifier_Values__c.fields.Account_Identifier_Update_Time_AGN__c.isUpdateable()){ //swar cc
        accIdentifierSettings.Account_Identifier_Update_Time_AGN__c = currTime;
        }
         if(schema.SObjectType.AGN_DCR_Account_Identifier_Values__c.isUpdateable()){ //swar cc
            update accIdentifierSettings;
        }
        return Database.getQueryLocator(accQuery);
    }
    global void execute(Database.BatchableContext bc,List<account> accList){
        AGN_Account_Identifier_Update_Helper.getAccount(accList);
        System.debug('~~~~ Execute completed');
    }
    global void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =: BC.getJobId()];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> toAddress = new List<String>();
        toAddress.add('dl-internationapplicationsupport@allergan.com');
        email.setToAddresses(toAddress);
        email.setSubject('Successfully Batch Completed');
        email.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '
                               + a.NumberOfErrors + ' failures. AsyncApexJob id is '+ a.Id);
        System.debug('~~~~ Finish block '+' The batch Apex job processed ' + a.TotalJobItems +' batches with '
                     + a.NumberOfErrors + ' failures. AsyncApexJob id is '+ a.Id );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}