global with Sharing class  AGN_ICL_Case_Reopen_Schedule implements Schedulable{
  global void execute(SchedulableContext sc) {
    AGN_ICL_LocatorlistingCaseapprovalbatch  b = new AGN_ICL_LocatorlistingCaseapprovalbatch ();
    database.executebatch(b,1);
  }
}