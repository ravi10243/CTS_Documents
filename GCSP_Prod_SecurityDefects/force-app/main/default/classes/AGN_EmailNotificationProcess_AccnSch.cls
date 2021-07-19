global class AGN_EmailNotificationProcess_AccnSch implements Schedulable{
global void execute(SchedulableContext sc) {
                 AGN_EmailNotificationProcessBatch_Accnt batchforemail = new AGN_EmailNotificationProcessBatch_Accnt();
                 Database.executeBatch(batchforemail,200);

      }
}