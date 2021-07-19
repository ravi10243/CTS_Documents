@isTest
public class AGN_CaseToOneTrackHandlerScheduleJobTest {

    public static testmethod void testSchedule()
    {
        Integer interval=Integer.valueof(Label.AGN_OTI_Batch_Run_Interval);   
        Test.StartTest();
        AGN_CaseToOneTrackHandlerScheduleJob testScheduleJob = new AGN_CaseToOneTrackHandlerScheduleJob();
    DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addHours(interval);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + 
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + 
            nextRunTime.month() + ' ? ' + nextRunTime.year(); 
        //system.schedule('ScheduleJob Test', cronString, testScheduleJob);
        
        String jobId = system.schedule('ScheduleJob Test', cronString, testScheduleJob);
      // Get the information from the CronTrigger API object 
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
       // Verify the expressions are the same System.assertEquals(CRON_EXP, ct.CronExpression); 
      // Verify the job has not run 
      System.assertEquals(0, ct.TimesTriggered); 
      // Verify the next time the job will run 
      System.assertEquals(String.valueOf(nextRunTime), String.valueOf(ct.NextFireTime)); 
        Test.stopTest();
    }
}