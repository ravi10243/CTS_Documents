global class AGN_batchSparkConsentEmailSchedule implements Schedulable 
{
   global void execute(SchedulableContext sc) {
      AGN_batchSparkConsentEmail batch = new AGN_batchSparkConsentEmail (); 
      database.executebatch(batch);
   }
}