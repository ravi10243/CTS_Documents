global class Schedule_AGN_GCSP_Case_Closure_Batch implements Schedulable{
    global void execute(SchedulableContext sc) {
      GCSP_Batch_Close_Case_After_30Days_AGN batch = new GCSP_Batch_Close_Case_After_30Days_AGN();
      database.executebatch(batch);
      GCSP_Batch_Update_User_On_Case_Close_AGN batch1 = new GCSP_Batch_Update_User_On_Case_Close_AGN();
      database.executebatch(batch1); 
      
   }

}