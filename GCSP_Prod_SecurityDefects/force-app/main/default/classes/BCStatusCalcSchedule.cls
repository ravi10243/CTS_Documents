global class BCStatusCalcSchedule implements Schedulable{
  global void execute(SchedulableContext sc) {
    BCInvoice  b = new BCInvoice ();
    database.executebatch(b,1);
  }
}