/*-------------------------------------------------------------------------------------------------------
* @author         sachin Jain   
* @createdBy      
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        
* @testClass     
* @Class Name    AGN_VeevaMergeJob
* --------------------------------------------------------------------------------------------------------
* @description -  Batch job to create merge records for Allergan Customer Address records where matching HCOs 
have been identified by the MDM users
*/


public class AGN_VeevaMergeJob implements Database.Batchable<sObject>,Database.Stateful{
     public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator('SELECT Account_AGN__c,Parent_AGN__r.Process_AGN__c,Account_AGN__r.Country_Code__c,Id,Initial_Account_AGN__c FROM Allergan_Customer_Address_AGN__c where Parent_AGN__r.Processed_Date_AGN__c= LAST_N_DAYS:7 AND Account_AGN__c != null AND Initial_Account_AGN__c!= null AND Parent_AGN__r.Process_AGN__c = true'); 
    }
    
    public void execute(Database.BatchableContext bc, List<Allergan_Customer_Address_AGN__c> customerAddress){
        // process each batch of records
        List<MERGE_PARENT_AGN__C> mergeRecordList = new List<MERGE_PARENT_AGN__C>();
        // added for checking whether winner and loser accounts are deleted
        List<Id> loserAccountList = new List<Id>();
     //   List<Id> winnerAccountList = new List<Id>();
        for(Allergan_Customer_Address_AGN__c allCusAdd : customerAddress){
            Id loserId = allCusAdd.Initial_Account_AGN__c;
            Id winnerId = allCusAdd.Account_AGN__c;
            loserAccountList.add(loserId);
            loserAccountList.add(winnerId);
        }
        Map< Id, Account > accMapLoser = new Map< Id, Account >();
            accMapLoser.putAll([select id from Account where id in :loserAccountList]);
      //  Map< Id, Account > accMapWinner = new Map< Id, Account >();
      //      accMapWinner.putAll([select id from Account where id in :winnerAccountList]);
   
        for(Allergan_Customer_Address_AGN__c allerganCustomerAddress : customerAddress){
            
            if(allerganCustomerAddress.Initial_Account_AGN__c == System.Label.AGN_Dupe_Checker_Id_Placeholder) {
                continue;
            }
             
            if(allerganCustomerAddress.Account_AGN__c != allerganCustomerAddress.Initial_Account_AGN__c){
                   MERGE_PARENT_AGN__C mergeRecord = new MERGE_PARENT_AGN__C();
				   if (Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Winner_Id_AGN__c.isCreateable() && 
				   Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Winner_Id_AGN__c.isUpdateable()) {
					mergeRecord.Winner_Id_AGN__c = allerganCustomerAddress.Account_AGN__c;
					}
					if (Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Loser_Id_AGN__c.isCreateable() && 
				   Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Loser_Id_AGN__c.isUpdateable()) {
					mergeRecord.Loser_Id_AGN__c = allerganCustomerAddress.Initial_Account_AGN__c;
					}
                   if (Schema.sObjectType.MERGE_PARENT_AGN__C.fields.External_ID_AGN__c.isCreateable() && 
				   Schema.sObjectType.MERGE_PARENT_AGN__C.fields.External_ID_AGN__c.isUpdateable()) {
					mergeRecord.External_ID_AGN__c = allerganCustomerAddress.Account_AGN__c + '__' + allerganCustomerAddress.Initial_Account_AGN__c;
					}
                   if (Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Merge_Country_AGN__c.isCreateable() && 
				   Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Merge_Country_AGN__c.isUpdateable()) {
					mergeRecord.Merge_Country_AGN__c = allerganCustomerAddress.Account_AGN__r.Country_Code__c;
					}
                   if (Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Merge_Status_AGN__c.isCreateable() && 
				   Schema.sObjectType.MERGE_PARENT_AGN__C.fields.Merge_Status_AGN__c.isUpdateable()) {
					mergeRecord.Merge_Status_AGN__c = 'INPROGRESS';
					}
                if((accMapLoser.containsKey(allerganCustomerAddress.Initial_Account_AGN__c)) && (accMapLoser.containsKey(allerganCustomerAddress.Account_AGN__c))){
                   mergeRecordList.add(mergeRecord);
                    recordsProcessed = recordsProcessed + 1;
                }
            }     
        }
        upsert mergeRecordList External_ID_AGN__c;
        
    }
    
    public void finish(Database.BatchableContext bc){
         // calling AGN_CustRegistrationMergeJob batch class
        AGN_CustRegistrationMergeJob mergeObj	= new AGN_CustRegistrationMergeJob();
        Database.executeBatch(mergeObj,200);
         AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email, ExtendedStatus
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[] {job.CreatedBy.Email};
         mail.setToAddresses(toAddresses);
         mail.setSubject('BatchJob Allergan Customer Address Veeva Merge Status: ' + job.Status);
     mail.setPlainTextBody('The batch Apex job processed ' + job.TotalJobItems +
    ' batches with '+ job.NumberOfErrors + ' failures. ExtendedStatus: ' + job.ExtendedStatus);
  
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }
}