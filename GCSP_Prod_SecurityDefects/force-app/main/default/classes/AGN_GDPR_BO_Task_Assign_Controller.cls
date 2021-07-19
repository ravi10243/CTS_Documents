public class AGN_GDPR_BO_Task_Assign_Controller {
    
    public Id taskOwnerID {get;set;}
    
    public List<Business_Owner_Task_GDPR_AGN__c> getBoTaskList()
    {
        List<Business_Owner_Task_GDPR_AGN__c> botaskAssigned;
        botaskAssigned = [SELECT id,BO_Priority_GDPR_AGN__c,Due_Date_AGN__c,Days_to_Close_GDPR_AGN__c,CreatedDate,Assigned_To_GDPR_AGN__c,Task_Subject_GDPR_AGN__c, Assigned_To_GDPR_AGN__r.name,Assigned_To_GDPR_AGN__r.email,Assigned_To_GDPR_AGN__r.id,Case_Type_GDPR_AGN__c,Name,OwnerId,Related_to_GDPR_AGN__r.CaseNumber,Status_GDPR_AGN__c,Asset_GDPR_AGN__c,Asset_GDPR_AGN__r.Name FROM Business_Owner_Task_GDPR_AGN__c WHERE Status_GDPR_AGN__c NOT IN ('Completed','Rejected') and Assigned_To_GDPR_AGN__c =: taskOwnerID order by CreatedDate DESC];
        return botaskAssigned;
       
    }

}