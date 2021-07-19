global class AGN_Welcome_Reminder_Email_Batch implements Database.Batchable<sObject> {
    
    private String query;
    
    global AGN_Welcome_Reminder_Email_Batch (String soql){
        query = soql;
    }
    
    // The batch job starts
    global Database.Querylocator start(Database.BatchableContext bc){
        //String query = 'SELECT Id, Name FROM Account';
        System.debug('>>>> start ' + query);
        return Database.getQuerylocator(query);
    } 
    
    // The batch job executes and operates on one batch of records
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        
        
        System.debug('>>>> execute ' + scope.size());
        
        AGN_Country_Code_List__c countryList = AGN_Country_Code_List__c.getValues('Send_Welcome_Reminder_Email_Country');
        String myCCVal = countryList.Country_Code_List__c;
        List<String> userName = new  List<String>();
        List<User> allUsers = new List<User>();
        
        List<Allergan_Customer_Registration_AGN__c> result = (List<Allergan_Customer_Registration_AGN__c>) scope ;
        System.debug('Result Acc'+result);
        System.debug('Result Acc Size'+result.size());
        
        
        for(Allergan_Customer_Registration_AGN__c checkCountry : result)
        {
            if(myCCVal.contains(checkCountry.Country_AGN__r.Name))
                
            {
                System.debug('Test'+checkCountry.Email_AGN__c);
                userName.add(checkCountry.Email_AGN__c+'.agn'); // Setting userName by appending '.agn'                
                System.debug('UserName:'+userName);
                
            }
            
        }
        
        System.debug('UserList Size'+userName.size());
        
        if(userName != null)
        {
            allUsers = [Select id from user where username IN :userName];  
            System.debug('User Names:'+allUsers);
            for(User usr : allUsers)
            {
                System.resetPasswordWithEmailTemplate(usr.Id, true,'AGN_Customer_Welcome_Reminder_Email') ;
                
            } 
            
        }
    }
    
    // The batch job finishes
    global void finish(Database.BatchableContext bc){
        
        System.debug('>>>> finish ');
    }
}