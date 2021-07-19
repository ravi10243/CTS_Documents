public class AGNNotificationIntegrationBatchSchedule implements Schedulable{
    public void execute(SchedulableContext SC) {
        AGN_GDPR_NOTIFICATION_INTEGRATION_GIGYA notify= new AGN_GDPR_NOTIFICATION_INTEGRATION_GIGYA();
        database.executeBatch(notify,50);  
    }
}