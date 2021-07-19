/****************************************************************************************************************
@ Class:          AGN_CustRegistrationMergeJob 
@ Version:        1
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        Batch job to create merge records for Allergan Customer Contact records where matching HCPs 
have been identified by the MDM users
-----------------------------------------------------------------------------------------------------------------
@ Change history: 10.02.2021 / Ayush Basak / Created the class.
19.03.2021/ Sachin Jain / Line 44-52 and 83
****************************************************************************************************************/

public class AGN_CustRegistrationMergeJob implements Database.Batchable<sObject>,Database.Stateful{
    final static String IN_PROGRESS = 'INPROGRESS';
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String timeFilter = 'LAST_N_DAYS:180';
        String query = 'SELECT Mapped_Account_AGN__c, Country_Code_AGN__c, Id, Contact_AGN__c ' 
            + 'FROM Allergan_Customer_Contact_AGN__c ' 
            + 'WHERE CreatedDate= ' + timeFilter
            + ' AND Mapped_Account_AGN__c!= null ' 
            + 'AND Parent_AGN__r.Process_AGN__c = true';
        return Database.getQueryLocator(query); 
    }
    
    public void execute(Database.BatchableContext bc, List<Allergan_Customer_Contact_AGN__c> customerContacts){
        
        Map<String,String> contactAccountMap = new Map<String,String>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Allergan_Customer_Contact_AGN__c contact : customerContacts) {
            contactIds.add(contact.Contact_AGN__c);
            
        }
        
        List<AccountContactRelation> acrList = [SELECT AccountId, ContactId 
                                                FROM AccountContactRelation 
                                                WHERE ContactId IN: contactIds 
                                                AND isActive = true 
                                                AND Account.isPersonAccount = true];                    
        for(AccountContactRelation acr : acrList) { 
            contactAccountMap.put(acr.ContactId, acr.AccountId);
        }     
        // added for checking whether winner and loser accounts are deleted
        List<Id> winnerAccountList = new List<Id>(); 
        for(Allergan_Customer_Contact_AGN__c contactObj : customerContacts){
            winnerAccountList.add(contactObj.Mapped_Account_AGN__c); //
            Id loserAccountId = contactAccountMap.get(contactObj.Contact_AGN__c);
            winnerAccountList.add(loserAccountId);
        }
        Map< Id, Account > accMap = new Map< Id, Account >(); //
        
        accMap.putAll([select id from Account where id in :winnerAccountList]);
        
        List<Merge_Parent_AGN__c> mergeRecordList = new List<Merge_Parent_AGN__c>();
        
        for(Allergan_Customer_Contact_AGN__c contacts : customerContacts){
            Merge_Parent_AGN__c mergeRecord = new Merge_Parent_AGN__c();
            Id newAccountId = contactAccountMap.get(contacts.Contact_AGN__c);
            if(newAccountId == contacts.Mapped_Account_AGN__c) {
                continue;
            }
            if (Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Loser_Id_AGN__c.isCreateable() && 
                Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Loser_Id_AGN__c.isUpdateable()) {
                    mergeRecord.Loser_Id_AGN__c = newAccountId;
                }
            if (Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Winner_Id_AGN__c.isCreateable() && 
                Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Winner_Id_AGN__c.isUpdateable()) {
                    mergeRecord.Winner_Id_AGN__c = contacts.Mapped_Account_AGN__c;
                }
            if (Schema.sObjectType.MERGE_PARENT_AGN__C.fields.External_ID_AGN__c.isCreateable() && 
                Schema.sObjectType.MERGE_PARENT_AGN__C.fields.External_ID_AGN__c.isUpdateable()) {
                    mergeRecord.External_ID_AGN__c = contacts.Mapped_Account_AGN__c
                        + '__' + newAccountId ;
                }
            if (Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Merge_Country_AGN__c.isCreateable() && 
                Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Merge_Country_AGN__c.isUpdateable()) {
                    mergeRecord.Merge_Country_AGN__c = contacts.Country_Code_AGN__c;
                }
            if (Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Merge_Status_AGN__c.isCreateable() && 
                Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Merge_Status_AGN__c.isUpdateable()) {
                    mergeRecord.Merge_Status_AGN__c = IN_PROGRESS;
                }
            if((accMap.containsKey(newAccountId)) && (accMap.containsKey(contacts.Mapped_Account_AGN__c))){
                mergeRecordList.add(mergeRecord);  
            }
        }
        
        upsert mergeRecordList External_ID_AGN__c;
    }
    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email, ExtendedStatus
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {job.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
        mail.setSubject('BatchJobXYZ Status: ' + job.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + job.TotalJobItems +
                              ' batches with '+ job.NumberOfErrors + ' failures. ExtendedStatus: ' + job.ExtendedStatus);
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}