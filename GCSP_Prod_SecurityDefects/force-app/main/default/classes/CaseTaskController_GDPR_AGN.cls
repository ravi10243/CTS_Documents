public class CaseTaskController_GDPR_AGN 
{   
    public List<Task> ListOfTasks()
    {
        List<Case> caselist=new List<Case>();
        List<Task> TaskList = new List<Task>();
        caselist=[SELECT id from Case where Status!='Task Completed'];
        
        Set<id> caseid=new Set<id>();
        for(Case c:caselist)
        {
            caseid.add(c.id);
        }
        TaskList = [SELECT id FROM Task WHERE WhatId in :caseid];
        Map<id,List<Task>> caseTaskMap = new Map<id,List<Task>>();
        for(id c_id : caseid)
        {
            List<Task> tempTaskList = new  List<Task>();
            for(Task tsk : TaskList)
            {
                if(c_id == tsk.WhatId)
                {
                    tempTaskList.add(tsk);
                }
                caseTaskMap.put(c_id, tempTaskList);
            }
        }
        System.debug(caseTaskMap.size());
        System.debug(caseTaskMap);
        return(TaskList);
    }
}