global class AGN_UpdateTaskStatus_Schedule implements Schedulable{
  global void execute(SchedulableContext sc) {
    AGN_UpdateTaskStatus b = new AGN_UpdateTaskStatus();
    database.executebatch(b,100);
  }
}