public class AGN_GDPR_Scheduler_CaseAtchmntDel implements Schedulable{
    public void execute(SchedulableContext SC){
        AGN_GDPR_Batch_CaseAtchmntDel obj=new AGN_GDPR_Batch_CaseAtchmntDel();
        Database.executeBatch(obj);
    }   
}