global class AGN_ICL_PL_ConsentBatchSchedule implements Schedulable{
  global void execute(SchedulableContext sc) {
    AGN_ICL_PractitionerListing_ConsentBatch b = new AGN_ICL_PractitionerListing_ConsentBatch();
    database.executebatch(b,1);
  }
}