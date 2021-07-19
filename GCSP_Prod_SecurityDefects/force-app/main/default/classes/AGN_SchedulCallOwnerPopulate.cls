global class AGN_SchedulCallOwnerPopulate implements Schedulable{

/* Cognizant: Release10 : 24/02/2017 - This class will schedule  AGN_CallOwnerPopulate 6 times a day  */

    global void execute(SchedulableContext sc) {
        DateTime now  = DateTime.now();
        DateTime scheduledTime = now.addMinutes(1);
        
        for(Integer i=1;i<=6;i++){
            String runTime=''+scheduledTime.second()+' '+scheduledTime.minute()+' '+scheduledTime.hour()+' '+scheduledTime.day()+' '+scheduledTime.month()+' ? '+scheduledTime.year(); 
            String jobName = 'AGN Call Owner Populate-'+i; 
            System.schedule(jobName , runTime , new AGN_CallOwnerPopulate());
            scheduledTime = scheduledTime.addMinutes(2);                       
        }
        
    }
}