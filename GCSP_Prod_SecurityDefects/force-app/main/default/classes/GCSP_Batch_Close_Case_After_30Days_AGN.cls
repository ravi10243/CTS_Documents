/*-------------------------------------------------------------------------------------------------------
* @author         Namrata Kundu
* @createdBy      
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        
* @testClass     
* @Class Name    GCSP_Batch_Close_Case_After_30Days_AGN
* --------------------------------------------------------------------------------------------------------
* @description -  Case should be automatically closed after 30 days, which are in registration step 1 
                  and deactivate guest user.

*/

public class GCSP_Batch_Close_Case_After_30Days_AGN implements Database.Batchable<SObject>, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
         Integer caseCloseCount= Integer.valueOf(AGN_GCSP_Settings__c.getValues('AN')?.get('days_to_close_case__c'));
         return Database.getQueryLocator([SELECT Email_AGN__c,Id,Case_AGN__c FROM Allergan_Customer_Registration_AGN__c WHERE Online_Registration_Step_AGN__c <= '4'AND Online_Registration_Status_AGN__c !='Completed' AND Country_Code_AGN__c IN ('AU','AN','NZ') AND GCSP_Case_Age_Count_Agn__c = :caseCloseCount]);
    }
    
    public void execute(Database.BatchableContext context, List<Allergan_Customer_Registration_AGN__c> scope){  
        system.debug('## Inside GCSP_Batch_Close_Case_After_30Days_AGN.execute()'+scope);
        List<String> userNameList = new List<String>();
        List<ID> caseList = new List<ID>();
        String userName;
        for(Allergan_Customer_Registration_AGN__c registrationObj: scope){
            userName = registrationObj.Email_AGN__c +'.agn';
            userNameList.add(userName);
            caseList.add(registrationObj.Case_AGN__c);
        }
        
       List<Case> caseListToUpdate =[SELECT ID,CreatedById,CreatedBy.Profile.Name,status FROM Case WHERE CreatedBy.Profile.Name NOT IN('AGN GCSP Lightning Profile','GCSP Portal Profile')and ID IN :caseList]; 
       Map<id,Case> caseMap = new Map<id,Case>(); 
        System.debug('List of cases'+caseListToUpdate);
        for(Case caseObj: caseListToUpdate){
            caseObj.Status ='Closed';
            caseMap.put(caseObj.Id,caseObj);
            System.debug('Mail sent'+caseMap);
        }
        if(caseMap.size()>0){
			update caseMap.values();
           System.debug('caseMap updated successfully');  
		}
    }
    public void finish(Database.BatchableContext context) {
    }

}