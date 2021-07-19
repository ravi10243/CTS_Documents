global class Schedule_Batch_To_Validate_with_DP_AGN implements Schedulable{
 global void execute(SchedulableContext sc) {
      Batch_To_Validate_with_DP_AGN batch = new Batch_To_Validate_with_DP_AGN();
      database.executebatch(batch);
   }
}