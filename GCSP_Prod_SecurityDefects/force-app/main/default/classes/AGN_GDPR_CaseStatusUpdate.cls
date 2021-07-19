public class AGN_GDPR_CaseStatusUpdate
{
    @InvocableMethod
    public Static void caseStatus(List<Task> Tsks)
    {
        
        Set<id> Caseid=new Set<id>();
        for(Task t : Tsks){
            Caseid.add(t.WhatId);
        }
        List<Task> TaskList=[select id,Status,WhatId from Task where WhatId in: Caseid];
        boolean iscompleted=false;
        Set<id> finalcaseID=new Set<id>();
        for(Task t: TaskList)
        {
            if(t.Status=='Completed')
            {
                
                iscompleted=true;
                finalcaseID.add(t.Whatid);
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