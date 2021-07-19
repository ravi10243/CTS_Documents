public class AGN_GDPR_Scheduler_CaseDelete implements Schedulable{
    public void execute(SchedulableContext SC){
        AGN_GDPR_Batch_CaseDelete obj = new AGN_GDPR_Batch_CaseDelete();
    Database.executeBatch(obj);
    }
}