public class BOTaskAcceptAction_GDPR_AGN_Controller {
     
         
    @AuraEnabled
    public static String acceptTask(Id taskId)
    {
        System.debug('Task ID+'+taskId);
       List<Business_Owner_Task_GDPR_AGN__c> boObj = [select id, Status_GDPR_AGN__c  from Business_Owner_Task_GDPR_AGN__c where id =: taskId limit 1];
        if(boObj[0].Status_GDPR_AGN__c=='In Progress'){
            return 'InProgress';
        }else if(boObj[0].Status_GDPR_AGN__c=='Not Started'){
            Business_Owner_Task_GDPR_AGN__c b = new Business_Owner_Task_GDPR_AGN__c();
            b.Id = taskId;
            b.Status_GDPR_AGN__c='In Progress';
            update b;
            return 'NotStarted';
        } else if(boObj[0].Status_GDPR_AGN__c=='Rejected'){
            return 'Rejected';
            
        }else{
            return 'other';
        } 

    }
}