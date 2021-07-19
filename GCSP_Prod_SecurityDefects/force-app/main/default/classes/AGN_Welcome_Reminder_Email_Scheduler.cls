global class AGN_Welcome_Reminder_Email_Scheduler implements Schedulable {
    
    // Execute at regular intervals
    global void execute(SchedulableContext ctx){
        
        //For testing purpose
       //  String soql = 'select id,Email_AGN__c,Country_AGN__r.Name from Allergan_Customer_Registration_AGN__c where ((CreatedDate = LAST_N_DAYS:2 AND CreatedDate < LAST_N_DAYS:1) OR (CreatedDate = LAST_N_DAYS:1)) AND (Online_Registration_AGN__c = true) AND (Online_Registration_Step_AGN__c = \'2\')';
                
       
        String soql = 'select id,Email_AGN__c,Country_AGN__r.Name from Allergan_Customer_Registration_AGN__c where ((CreatedDate = LAST_N_DAYS:10 AND CreatedDate < LAST_N_DAYS:9) OR (CreatedDate = LAST_N_DAYS:20 AND CreatedDate < LAST_N_DAYS:19)) AND (Online_Registration_AGN__c = true) AND (Online_Registration_Step_AGN__c = \'2\')';
        
        AGN_Welcome_Reminder_Email_Batch batch = new AGN_Welcome_Reminder_Email_Batch(soql);
        Database.executebatch(batch,10);
    }
}