/* The below schedule class is to generate a unique 10 digit PIN for all HCP accounts. */
global class AGN_OnlineConsent_ScheduleGenerationPIN implements Schedulable {
   global void execute(SchedulableContext sc) {
      Id profRecordTypeId = [Select Id from RecordType where SobjectType='Account' and DeveloperName='Professional_vod'].Id; 
       
      String queryParameter = Label.OnlineConsent_BatchQueryStr + ' \''+profRecordTypeId+'\''; 
       
      System.debug('Query::: '+queryParameter); 
       
      Integer scope = Integer.valueOf(Label.OnlineConsent_BatchScope); 
      Database.executebatch(new AGN_Batch_Update_Account_UniqueRef(queryParameter), scope);
   }
}