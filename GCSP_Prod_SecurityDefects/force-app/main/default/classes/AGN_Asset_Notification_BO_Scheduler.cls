/* 
@Class name : AGN_Asset_Notification_BO_Scheduler
@Createdate : 27.02.2020
@Author : GDPR Case management Project Team
@Description: Apex class to schedule batch class AGN_Batch_Asset_Notification_To_BO_CCPA(Requirement ID: 47 March Release)
*/

global class AGN_Asset_Notification_BO_Scheduler implements Schedulable{

     global void execute(SchedulableContext sc)
    {      
        // We now call the batch class to be scheduled
        AGN_Batch_Asset_Notification_To_BO_CCPA b = new AGN_Batch_Asset_Notification_To_BO_CCPA();
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
}