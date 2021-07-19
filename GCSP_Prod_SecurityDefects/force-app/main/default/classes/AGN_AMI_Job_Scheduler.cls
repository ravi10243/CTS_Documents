global class AGN_AMI_Job_Scheduler implements Schedulable 
{
    global void execute(SchedulableContext sc) 
    {
        AGN_AMI_Attendee_Status_Updates updateBatch = new AGN_AMI_Attendee_Status_Updates(); 
        database.executebatch(updateBatch);
        
        AGN_AMI_MeetingShareNotifications notificationBatch = new AGN_AMI_MeetingShareNotifications();
        database.executebatch(notificationBatch);
        
        AGN_AMI_EJ_Curr_Updates ejBatch = new AGN_AMI_EJ_Curr_Updates();
        database.executebatch(ejBatch);
        
        AGN_AMI_Password_Reminder_Batch passwordBatch = new AGN_AMI_Password_Reminder_Batch(); 
		database.executebatch(passwordBatch);
    }
}