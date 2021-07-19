public class AGN_GDPR_Case_TaskCompleteStatusUpdate {
    
    @InvocableMethod
    public Static void caseStatus(List<Business_Owner_Task_GDPR_AGN__c> Tsks1)
    {
        
        Set<id> Caseid=new Set<id>();
        for(Business_Owner_Task_GDPR_AGN__c t : Tsks1){
            Caseid.add(t.Related_to_GDPR_AGN__c);
        }
        List<Business_Owner_Task_GDPR_AGN__c> TaskList=[select id,Status_GDPR_AGN__c,Related_to_GDPR_AGN__c from Business_Owner_Task_GDPR_AGN__c where Related_to_GDPR_AGN__c in: Caseid];
        boolean iscompleted=false;
        Set<id> finalcaseID=new Set<id>();
        for(Business_Owner_Task_GDPR_AGN__c t: TaskList)
        {
            if(t.Status_GDPR_AGN__c=='Completed' || t.Status_GDPR_AGN__c=='Rejected' )
            {
                
                iscompleted=true;
                finalcaseID.add(t.Related_to_GDPR_AGN__c);
            }
            else
            {
                iscompleted=false;
                break;
            }
        }
        if(iscompleted)
        {
            List<Case> finalCaseList=[select id,Status from Case where id in:finalcaseID];
            for(Case c : finalCaseList)
            {
                c.Status='Task Completed';
            }
            
        if(finalCaseList.size()>0)
        {
            update finalCaseList;
        }
        }
    }

}