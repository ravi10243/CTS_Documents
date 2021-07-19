public class AGN_GDPR_TaskAttachmentDelScheduler implements Schedulable{
    public void execute(SchedulableContext SC){
        AGN_GDPR_TaskAttachmentDelBatch obj = new AGN_GDPR_TaskAttachmentDelBatch ();
    Database.executeBatch(obj);
    }
}