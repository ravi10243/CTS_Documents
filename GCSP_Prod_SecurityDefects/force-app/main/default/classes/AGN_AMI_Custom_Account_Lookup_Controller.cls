public without sharing class AGN_AMI_Custom_Account_Lookup_Controller {
    
    public Account account {get;set;} // new account to create
    public List<Account> results{get;set;} // search results
    //public string searchStringName{get;set;}// search keyword
    public boolean searchIsPersonAccount{get;set;} // search keyword
    public string searchStringFirstName{get;set;}
    public string searchStringLastName{get;set;}
    public string searchStringSpecialty{get;set;} 
    //public string searchStringSubSpecialty{get;set;}
    //public string searchStringDOB{get;set;}
    public string searchStringMob{get;set;}
    //public string searchStringPRN{get;set;}
    public string searchStringEmail{get;set;}
    public string accId{get;set;}
    public integer resultSize{get;set;}
    public string searchStringHospital{get;set;}
    
    
    public AGN_AMI_Custom_Account_Lookup_Controller() {
        account = new Account();
        // get the current search string
        searchIsPersonAccount = true;
        resultSize=0;
        //runSearch();  
    }
    
    // performs the keyword search
    public PageReference search() {
        runSearch();
        return null;
    }
    
    // prepare the query and issue the search command
    private void runSearch() {
        // TODO prepare query string for complex serarches & prevent injections
        results = performSearch(searchIsPersonAccount);
        resultSize=results.size();
        if(resultSize==0)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, system.Label.AGN_AMI_User_Not_Found)); 
    }
    
    // run the search and return the records found. 
    private List<Account> performSearch(boolean searchIsPersonAccount) {
        
        String soql = 'SELECT Id, Name,FirstName,LastName,PersonEmail,Specialty_1_AGN__r.Name,Sub_Specialty_Allergan_AGN__r.Name,PersonBirthdate,Physician_Registration_Reference_AGN__c,Primary_Parent_vod__r.Name, PersonMobilePhone,Type_AGN__c,Distribution_ID_AGN__c,Status_AGN__c,Country_Code__c,Other_Name_AGN__c, (SELECT Name, Address_line_2_vod__c, City_vod__c, State_vod__c,Country_vod__c, Zip_vod__c FROM Address_vod__r) FROM Account WHERE Id<>null and Primary_Parent_vod__c <> null and AGN_AMI_Enabled__c = false and IsPersonAccount ='+searchIsPersonAccount;
        if(//String.IsBlank(searchStringName) &&
            String.IsBlank(searchStringEmail) &&
            //String.IsBlank(searchStringPRN) &&
            String.IsBlank(searchStringFirstName) &&
            String.IsBlank(searchStringLastName) &&
            String.IsBlank(searchStringHospital) &&
            String.IsBlank(searchStringSpecialty))
        {
            return new List<Account>();
        }
        /*if (searchStringName != '' && searchStringName != null)
		searchStringName = String.escapeSingleQuotes(searchStringName);*/
        if(searchStringEmail!='' && searchStringEmail!=null)
            searchStringEmail=String.escapeSingleQuotes(searchStringEmail);
        /*if(searchStringPRN!='' && searchStringPRN!=null)
		searchStringPRN=String.escapeSingleQuotes(searchStringPRN);*/
        if(searchStringFirstName!='' && searchStringFirstName!=null)
            searchStringFirstName=String.escapeSingleQuotes(searchStringFirstName);
        if(searchStringLastName!='' && searchStringLastName!=null)
            searchStringLastName=String.escapeSingleQuotes(searchStringLastName);
        if(searchStringSpecialty!='' && searchStringSpecialty!=null)
            searchStringSpecialty=String.escapeSingleQuotes(searchStringSpecialty);
        if(searchStringHospital!='' && searchStringHospital!=null)
            searchStringHospital=String.escapeSingleQuotes(searchStringHospital);
        
        //if(searchStringSubSpecialty!='' && searchStringSubSpecialty!=null)
        //  searchStringSubSpecialty=String.escapeSingleQuotes(searchStringSubSpecialty);
        
        
        if(searchStringMob!='' && searchStringMob!=null)
            searchStringMob=String.escapeSingleQuotes(searchStringMob);
        /*if(searchStringName != '' && searchStringName != null && searchStringCountry=='' && searchStringDistribution =='')
        soql = soql +  ' AND (Name LIKE \'%' + searchStringName +'%\')';
        if(searchStringCountry != '' && searchStringCountry != null && searchStringName=='' && )
        soql = soql +  ' AND Country_Code__c='+'\''+searchStringCountry+'\'';
        
        if(searchStringName != '' && searchStringName != null && searchStringCountry!='' && searchStringCountry!=null && searchStringDistribution!='' && searchStringDistribution!=null)
        soql = soql +  ' AND (Name LIKE \'%' + searchStringName +'%\')'+' AND Country_Code__c='+'\''+searchStringCountry+'\''+' AND Distribution_ID_AGN__c='+'\''+searchStringDistribution+'\'';
        soql = soql + ' LIMIT 1000';*/
                
                /*if(!string.isBlank(searchStringName)){
        soql=soql+' AND Name LIKE \'%' + searchStringName +'%\''; 
        } */
        if(!string.isBlank(searchStringEmail)){
            soql=soql+' AND PersonEmail=\''+searchStringEmail+'\''; 
        }
        /* if(!string.isBlank(searchStringPRN)){
        soql=soql+' AND Physician_Registration_Reference_AGN__c=\''+searchStringPRN+'\''; 
        }*/
        
        if(!string.isBlank(searchStringFirstName)){
            soql=soql+' AND Firstname=\''+searchStringFirstName+'\''; 
        }
        if(!string.isBlank(searchStringLastName)){
            soql=soql+' AND Lastname=\''+searchStringLastName+'\''; 
        }
        if(!string.isBlank(searchStringSpecialty)){
            soql=soql+' AND Specialty_1_AGN__r.Name=\''+searchStringSpecialty+'\''; 
        }
        if(!string.isBlank(searchStringHospital)){
            soql=soql+' AND Primary_Parent_vod__r.Name=\''+searchStringHospital+'\''; 
        }
        //if(!string.isBlank(searchStringSubSpecialty)){
        //  soql=soql+' AND Sub_Specialty_Allergan_AGN__r.Name=\''+searchStringSubSpecialty+'\''; 
        //}
        /*if(!string.isBlank(searchStringDOB)){
        Date dt=Date.parse(searchStringDOB);
        soql=soql+' AND PersonBirthdate='+dt; 
        soql=soql.remove('00:00:00');
        }*/
        if(!string.isBlank(searchStringMob)){
            soql=soql+' AND PersonMobilePhone=\''+searchStringMob+'\''; 
        }
        
        if(!String.isBlank(soql) && soql.endsWith('AND'))
            soql = soql.substring(0,soql.length()-3);
        soql = soql + ' LIMIT 1000';
        
        System.debug(soql);
        return database.query(soql); 
    }
    public void createContact()
    {
        if(!string.IsBlank(accId))
        {
            List<Account> accounts = new List<Account>([SELECT PersonEmail, 
                                                        Phone, 
                                                        FirstName, 
                                                        LastName, 
                                                        PersonContactId,
                                                        Primary_Parent_vod__c,
                                                        Language_vod__c,
                                                        Country_Code__c, 
                                                        country_vod__r.name,
                                                        Customer_Sub_Category_AGN__c  
                                                        FROM Account 
                                                        WHERE Id =:accId LIMIT 1]);
            Contact contact = new Contact (FirstName = accounts[0].FirstName, 
                                           LastName = accounts[0].LastName, 
                                           Email = accounts[0].PersonEmail, 
                                           is_AMI_Contact_AGN__c = true, 
                                           AccountId = accounts[0].Primary_Parent_vod__c, 
                                           Country_code_AGN__c = accounts[0].country_vod__r.name, 
                                           Country_AGN__c = accounts[0].country_vod__c);
            insert Contact;
            AccountContactRelation acr = new AccountContactRelation(ContactId = contact.Id,
                                                                    AccountId = accId);
            insert acr;
            Account acc = new Account(Id = accounts[0].id, AGN_AMI_Enabled__c = true);
            update acc;
            if(contact.Id!=null)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, System.Label.AGN_AMI_User_Created));
                enable(contact.Id, accId);
            }
            else
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, System.Label.AGN_AMI_User_Not_Created)); 
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, System.Label.AGN_AMI_User_Enable)); 
        }
    }
    @future
    public static void Enable(Id contactId, Id accId)
    {  
        system.debug('Enable'+accId);
        if(!string.IsBlank(accId))
        {
            List<Account> accounts = new List<Account>([SELECT PersonEmail, 
                                                        Phone, 
                                                        FirstName, 
                                                        LastName, 
                                                        PersonContactId,
                                                        Language_vod__c,
                                                        Country_Code__c, 
                                                        country_vod__r.name,
                                                        Customer_Sub_Category_AGN__c  
                                                        FROM Account 
                                                        WHERE Id =:accId LIMIT 1]);
            //get account record from json
            Account customer = (Account)JSON.deserialize(Json.serialize(accounts[0]), Account.class);
            String USERNAME_SUFFIX =  (String)AMI_User_Settings_AGN__c.getValues(customer.country_vod__r.name).get('Username_Suffix__c');//'agncustomerd17';
            AMI_User_Settings_AGN__c allDetails =  AMI_User_Settings_AGN__c.getInstance(customer.country_vod__r.name);
            system.debug('---'+allDetails);
            User customerUser = new User();
            
            string alias = '';
            if (customer.FirstName.length() > 0){
                alias += customer.FirstName.substring(0, 1);
            }
            if(customer.LastName.length()>0){
                //alias += customer.LastName.substring(0,Math.min(customer.LastName.length(), 7));
                alias += customer.LastName.substring(0,Math.min(customer.LastName.length(), 4));
            }
            
            // Alias uniqueness handling
            
            integer existingUserCount = [SELECT COUNT() FROM User WHERE SMB_Alias_External_Id__c LIKE :alias + '%'];
            if(existingUserCount > 0){
                alias += existingUserCount;
            }
            
            customerUser.Email = customer.PersonEmail;
            customerUser.Phone = customer.Phone;
            customerUser.FirstName = customer.FirstName;
            customerUser.LastName = customer.LastName;
            customerUser.Alias = Alias;   
            customerUser.LanguageLocaleKey = allDetails.User_Language__c;
            customerUser.EmailEncodingKey = 'UTF-8';        
            customerUser.LocalesIdKey = allDetails.User_Locale__c;
            customerUser.TimezonesIdKey =allDetails.User_Timezone__c;
            customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: allDetails.User_Profile__c limit 1].Id;
            customerUser.UserName = customer.PersonEmail + '.' + USERNAME_SUFFIX;
            customerUser.ContactId = contactId; 
            customerUser.Country_Code__c = customer.country_vod__r.name;
            customerUser.Division=customer.Customer_Sub_Category_AGN__c;
            
            system.debug('======customerUser====='+customerUser);
            
            Database.SaveResult sr = Database.insert(customerUser, false);
            // Iterate through each returned result
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    system.debug('--nosuccess'+err.getMessage());
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, err.getMessage()));
                }
            }
            
        }
        
    }
    
}