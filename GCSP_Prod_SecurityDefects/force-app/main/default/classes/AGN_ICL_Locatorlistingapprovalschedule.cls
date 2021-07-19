/*
Modified by :ICL Project Team
Description: New schedulable class has been created to call batch class AGN_ICL_Locatorlistingapprovalbatch
Release :ICL Wave-3
*/
global with Sharing class  AGN_ICL_Locatorlistingapprovalschedule implements Schedulable{
  global void execute(SchedulableContext sc) {
    AGN_ICL_Locatorlistingapprovalbatch  b = new AGN_ICL_Locatorlistingapprovalbatch ();
    database.executebatch(b,1);
  }
}