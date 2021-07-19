global class AGN_EmailNotificationProcessSch implements Schedulable{
global void execute(SchedulableContext sc) {
                 AGN_EmailNotificationProcessBatch batchforemail = new AGN_EmailNotificationProcessBatch();
                 Database.executeBatch(batchforemail,200);

      }
}