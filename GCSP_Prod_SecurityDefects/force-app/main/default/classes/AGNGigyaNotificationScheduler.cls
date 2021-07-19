public class AGNGigyaNotificationScheduler implements Schedulable {

    public static void scheduleHourly(Integer startingMinuteInHour, String jobName) {
        System.schedule(jobName, '0 ' + startingMinuteInHour + ' * * * ?', new AGNGigyaNotificationScheduler());
    }

    public void execute(SchedulableContext sc) {
        // Salesforce has a limit of 5 running batch jobs
        // If there are already 5 jobs running, then don't run this job
        // Any records that need to be processed will be processed the next time the job executes
        if(this.getNumberOfRunningBatchJobs() >= 5) return;

        Database.executebatch(new AGNGigyaNotificationBatch());
    }

    private Integer getNumberOfRunningBatchJobs() {
        return [SELECT COUNT() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status IN ('Processing', 'Preparing', 'Queued')];
    }

}