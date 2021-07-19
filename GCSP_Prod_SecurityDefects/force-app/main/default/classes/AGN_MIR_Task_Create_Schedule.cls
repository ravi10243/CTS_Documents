global class AGN_MIR_Task_Create_Schedule implements Schedulable{
  global void execute(SchedulableContext sc) {
    AGN_MIR_Task_Create b = new AGN_MIR_Task_Create();
    database.executebatch(b,10);
  }
}