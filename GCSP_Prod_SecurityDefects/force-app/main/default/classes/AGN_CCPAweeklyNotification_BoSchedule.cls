global class AGN_CCPAweeklyNotification_BoSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
      AGN_CCPAAssetWeeklyNotificationtoBOBatch batch = new AGN_CCPAAssetWeeklyNotificationtoBOBatch(); 
      database.executebatch(batch);
   }
}