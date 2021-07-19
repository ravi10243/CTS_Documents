global class AGN_OnlineConsent_EmailSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
      AGN_OnlineConsent_EmailNotificationBatch batch = new AGN_OnlineConsent_EmailNotificationBatch(); 
      database.executebatch(batch);
   }
}