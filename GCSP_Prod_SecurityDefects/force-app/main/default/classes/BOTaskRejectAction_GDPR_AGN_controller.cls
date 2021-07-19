public class BOTaskRejectAction_GDPR_AGN_controller {
        @AuraEnabled
    public static String checkTask(Id taskId)
    {
        system.debug('task id for Update:  ' +taskId);
        List<Business_Owner_Task_GDPR_AGN__c> cs = new List<Business_Owner_Task_GDPR_AGN__c >();
       
        cs=[SELECT Id,Rejection_Reason_AGN__c,Status_GDPR_AGN__c,Rejection_Reason_Code_AGN__c from Business_Owner_Task_GDPR_AGN__c where Id= :taskId];

        System.debug('Task '+cs[0].Status_GDPR_AGN__c);
        
        if(cs[0].Status_GDPR_AGN__c=='Not Started' || cs[0].Status_GDPR_AGN__c=='In Progress')
        {
            
            if(String.isNotBlank(cs[0].Rejection_Reason_AGN__c) && String.isNotBlank(cs[0].Rejection_Reason_Code_AGN__c) )

            {
                Business_Owner_Task_GDPR_AGN__c c = new Business_Owner_Task_GDPR_AGN__c();
                c.Id = taskId;
                c.Reject_Task_AGN__c=true;
                c.Status_GDPR_AGN__c='Rejected';
                update c;
                System.debug('Good to go!!!');
                return 'Valid Field';
            }
            else
            {
                return 'Invalid Field'; 
            }
        }
      else
        {
            if(cs[0].Reject_Task_AGN__c==true)
            {
                return 'Task Rejected';
            }
            else
            {
                 return 'Invalid Status';
            }
           
        }
       
        
    }

}