global class AGN_EmailNotificationProcessSchedule_BR implements Schedulable{
global void execute(SchedulableContext sc) {
                 AGN_EmailNotificationProcessBatch_BR batchforemail = new AGN_EmailNotificationProcessBatch_BR();
                 Database.executeBatch(batchforemail,200);

      }
}