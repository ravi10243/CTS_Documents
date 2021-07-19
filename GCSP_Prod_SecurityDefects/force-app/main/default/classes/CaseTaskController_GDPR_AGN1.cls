public class CaseTaskController_GDPR_AGN1 
{
    @InvocableMethod
    public static void ListOfTasks(List<Case> caselist)
    {
        List<Task> TaskList = new List<Task>();
        //List<Case> caselist=new List<Case>();
        //caselist=[SELECT id from Case where Status =: 'In-Progress'];
        Set<id> caseid=new Set<id>();
        for(Case c:caselist)
        {
            caseid.add(c.id);
        }
        TaskList = [SELECT id,whatId,Status FROM Task WHERE whatId in :caseid];
        Map<id,List<Task>> caseTaskMap = new Map<id,List<Task>>();
        for(id c_id : caseid)
        {
            List<Task> tempTaskList = new  List<Task>();
            for(Task tsk : TaskList){
                if(c_id == tsk.whatId)
                {
                    tempTaskList.add(tsk);
                }
            }
            caseTaskMap.put(c_id, tempTaskList);
        }
        Set <id> finalCaseId = new Set<id>();
        for(id cs_id : caseTaskMap.keySet()){
            List<Task> caseTaskList = new  List<Task>();
            caseTaskList = caseTaskMap.get(cs_id);
            integer count = 0;
            for(Task tsk : caseTaskList){
                if(tsk.Status == 'Completed')
                    count ++;
            }            
            if(caseTaskList.size() == count){
                //System.debug('caseTaskList.size() -> '+caseTaskList.size());
                //System.debug('count -> '+count);
                finalCaseId.add(cs_id);
                
            }
        }
        List<Case> finalCaseList = [SELECT id,Status from Case where id in: finalCaseId];
        for(Case c : finalCaseList){
            c.Status = 'Task Completed';
        }
        update finalCaseList;
        System.debug('finalCaseList.size() -> '+finalCaseList.size());
    }
}