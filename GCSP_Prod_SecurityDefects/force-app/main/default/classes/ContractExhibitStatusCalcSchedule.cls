global class ContractExhibitStatusCalcSchedule implements Schedulable{
  global void execute(SchedulableContext sc) {
    ContractExhibitStatusCalc b = new ContractExhibitStatusCalc();
    database.executebatch(b,1);
  }
}