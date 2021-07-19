global class AGN_CaseToOneTrackHandlerScheduleJob implements Schedulable{
    global void execute(SchedulableContext sc){
        String query = 'Select id from Case where OTI_Batch_Status_CoolS_AGN__c=\'Scheduled\'';     
        system.debug('#####query#####'+query);
        AGN_CaseToOneTrackHandlerBatch sched= new AGN_CaseToOneTrackHandlerBatch(query);
        Integer interval=Integer.valueof(Label.AGN_OTI_Batch_Run_Interval);               
        Id batchId = Database.executeBatch(sched,1);                   
        DateTime now  = DateTime.now();
        DateTime nextRunTime = now.addHours(interval);
        String cronString = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' +
            nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' +
            nextRunTime.month() + ' ? ' + nextRunTime.year();
        AGN_CaseToOneTrackHandlerScheduleJob objJob = new AGN_CaseToOneTrackHandlerScheduleJob();
        system.schedule('OneTrack Batch Job' + now.format(), cronString, objJob);           
        if(sc!=null){
            Id jobId = SC.getTriggerId();
            System.abortJob(jobId);
        }
    }
}