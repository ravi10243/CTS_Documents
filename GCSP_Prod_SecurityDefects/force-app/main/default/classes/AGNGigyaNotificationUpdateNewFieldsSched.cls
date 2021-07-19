public class AGNGigyaNotificationUpdateNewFieldsSched  implements Schedulable {
	public void execute(SchedulableContext sc) {
			// Salesforce has a limit of 5 running batch jobs
			// If there are already 5 jobs running, then don't run this job
			// Any records that need to be processed will be processed the next time the job executes
	//		if(this.getNumberOfRunningBatchJobs() >= 5) return;

			if(this.isStillRunning()) return;

			Database.executeBatch(new AGNGigyaNotificationUpdateNewFieldsBatch(), 100);
	}

	private Integer getNumberOfRunningBatchJobs() {
			return [SELECT COUNT() FROM AsyncApexJob WHERE JobType='BatchApex' AND Status IN ('Processing', 'Preparing', 'Queued')];
	}

	private Boolean isStillRunning() {
		return [SELECT COUNT()
		FROM AsyncApexJob
		where apexclass.name='AGNGigyaNotificationUpdateNewFieldsBatch' and status not in ('Completed', 'Failed', 'Aborted')] > 0;
	}


}