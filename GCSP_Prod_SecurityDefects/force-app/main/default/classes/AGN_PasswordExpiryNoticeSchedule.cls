global class AGN_PasswordExpiryNoticeSchedule implements Schedulable{
  global void execute(SchedulableContext sc) {
    AGN_PasswordExpiryNotice b = new AGN_PasswordExpiryNotice();
    database.executebatch(b,10);
  }
}