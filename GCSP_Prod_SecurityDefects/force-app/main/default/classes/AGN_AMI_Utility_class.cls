global without sharing class AGN_AMI_Utility_class{ 
    /* Updated with Cluster Country Logic 7/7/2020 - Start */   
    public static User uInfo{get{return [SELECT Id,Name,Country_Code__c,Cluster_User_AGN__c,MA_User_Country_Code_AGN__c from User where Id =: UserInfo.getUserId() limit 1];}}  
    
    public static final String USERNAME_SUFFIX =  (String)AMI_User_Settings_AGN__c.getValues((uInfo.Cluster_User_AGN__c)?uInfo.MA_User_Country_Code_AGN__c:uInfo.Country_code__c).get('Username_Suffix__c');    
    public static final String RECORD_OWNER = (String)AMI_User_Settings_AGN__c.getValues((uInfo.Cluster_User_AGN__c)?uInfo.MA_User_Country_Code_AGN__c:uInfo.Country_code__c).get('CR_Record_Owner__c');    
   // system.debug('RECORD_OWNER>>>'+RECORD_OWNER);
         
    /* Updated with Cluster Country Logic 7/7/2020 - End */ 
    public static final String OWNER_ID = [SELECT ID FROM User where Username =: RECORD_OWNER LIMIT 1].Id;  
    //public static List<Account> accountList;  
    public static string noAddressLabel = System.Label.AGN_AMI_NoRelated_Address;   
        
       
    webservice static String enableAMIUser(string accountId, Allergan_Customer_Registration_AGN__c acr, string contactId) {     
        /* Updated with DQ Change Logic */  
        system.debug('RECORD_OWNER>>>'+RECORD_OWNER);
        system.debug('==accountId=='+accountId);    
        String result;  
        List<Account> accounts = new List<Account>([SELECT PersonEmail,     
                                                    Phone,  
                                                    FirstName,  
                                                    LastName,   
                                                    PersonContactId,    
                                                    Language_vod__c,    
                                                    AMI_Registration_Email_AGN__c,  
                                                    Country_Code__c,    
                                                    Country_vod__r.Name,    
                                                    AGN_AMI_Enabled__c, 
                                                    Specialty_1_AGN__r.Name,    
                                                    Customer_Sub_Category_AGN__c,   
                                                    Specialty_Allergan_1_AGN__r.Name,   
                                                    Sub_Specialty_Allergan_AGN__r.Name  
                                                    FROM Account    
                                                    WHERE Id =:accountId LIMIT 1]);     
        List<Contact> contacts = new List<Contact>([SELECT Email,   
                                                    Phone,  
                                                    FirstName,  
                                                    LastName,   
                                                    Id, 
                                                    Language_AGN__c,    
                                                    Country_Code_AGN__c,    
                                                    Country_AGN__r.Name,    
                                                    Is_AMI_Contact_AGN__c   
                                                    FROM Contact    
                                                    WHERE Id =: contactId LIMIT 1]);    
            
        List<User> listAMIUser = [Select Id,Contact.AccountId,FirstName,LastName from User  
                                  where Email =: acr.Email_AGN__c   
                                  and Contact.Is_AMI_Contact_AGN__c = true  
                                  and ContactId =: contactId    
                                  and IsActive = true   
                                  Limit 1]; 
        List<User> listOtherUser = [Select Id,Contact.AccountId from User   
                                    where Email =: acr.Email_AGN__c 
                                    and Contact.Is_AMI_Contact_AGN__c = false   
                                    and ContactId =: contactId  
                                    and IsActive = true 
                                    and Profile.UserLicense.Name like '%Customer Community%'    
                                    Limit 1];   
            
        //System.debug(accounts[0].Specialty_Allergan_1_AGN__r.Name + accounts[0].Sub_Specialty_Allergan_AGN__r.Name ); 
        List<AMI_SPecality_AGN__c> ASList_MDM = [select id from AMI_SPecality_AGN__c    
                                                 where Allergan_Speciality_Name_AGN__c =: accounts[0].Specialty_1_AGN__r.Name   
                                                 and Country_AGN__r.Name =: accounts[0].Country_vod__r.Name     
                                                 Limit 1];  
        List<AMI_SPecality_AGN__c> ASList_CM = [select id from AMI_SPecality_AGN__c 
                                                where Allergan_Speciality_Name_AGN__c =: accounts[0].Specialty_Allergan_1_AGN__r.Name   
                                                and Country_AGN__r.Name =: accounts[0].Country_vod__r.Name  
                                                Limit 1];   
        /*List<AMI_Sub_Specialty_AGN__c> ASSList = [select id from AMI_Sub_Specialty_AGN__c     
where name_AGN__c =: accounts[0].Sub_Specialty_Allergan_AGN__r.Name     
and Country_AGN__r.Name =: accounts[0].Country_Code__c  
Limit 1];*/ 
        AMI_User_Settings_AGN__c specSource = AMI_User_Settings_AGN__c.getInstance(accounts[0].Country_vod__r.Name);    
        if(ASList_MDM.size()>0 && !specSource.Country_Managed_Specialty_AGN__c) 
        {   
            accounts[0].AMI_Specialty_AGN__c = ASList_MDM[0].Id;    
            contacts[0].AMI_Specialty_AGN__c = ASList_MDM[0].Id;    
        }   
        else if(ASList_CM.size()>0 && specSource.Country_Managed_Specialty_AGN__c)  
        {   
            accounts[0].AMI_Specialty_AGN__c = ASList_CM[0].Id; 
            contacts[0].AMI_Specialty_AGN__c = ASList_CM[0].Id; 
        }   
            
        accounts[0].AGN_AMI_Enabled__c= True;   
        contacts[0].Is_AMI_Contact_AGN__c = true;   
        accounts[0].AMI_Registration_Email_AGN__c = acr.Email_AGN__c;   
        system.debug('==accounts =='+accounts );    
        if(listAMIUser.size() > 0)  
        {   
            //system.debug('Entered AMI If');   
            result = 'A user already exists in the AMI Portal with the name : ' + listAMIUser[0].FirstName + ' ' + listAMIUser[0].LastName  
                + '. Please provide additional information (if required) to the associated account';    
            //system.debug(result); 
        }   
        else if(listOtherUser.size() > 0)   
        {   
            accounts[0] = new Account();    
            accounts[0].Id = listOtherUser[0].Contact.AccountId;    
            if(ASList_MDM.size()>0 && !specSource.Country_Managed_Specialty_AGN__c) 
            {   
                accounts[0].AMI_Specialty_AGN__c = ASList_MDM[0].Id;    
                contacts[0].AMI_Specialty_AGN__c = ASList_MDM[0].Id;    
            }   
            else if(ASList_CM.size()>0 && specSource.Country_Managed_Specialty_AGN__c)  
            {   
                accounts[0].AMI_Specialty_AGN__c = ASList_CM[0].Id; 
                contacts[0].AMI_Specialty_AGN__c = ASList_CM[0].Id; 
            }   
            contacts[0].Is_AMI_Contact_AGN__c = true;   
            accounts[0].AGN_AMI_Enabled__c= True;   
            accounts[0].AMI_Registration_Email_AGN__c = acr.Email_AGN__c;   
            AGN_AMI_Utility_class.assignPermissionSet(listOtherUser[0].Id);     
        }   
        else if(!accounts.isEmpty())    
        {   
            result = 'User creation has been processed and the user is enabled for AMI Portal.';    
            AGN_AMI_Utility_class.createCustomerUser(Json.serialize(accounts[0]), JSON.serialize(acr), Json.serialize(contacts[0]));    
        }   
        else    
        {   
            result = 'Sorry, there occured some while attempting to create the user.';  
        }   
        update accounts;    
        update contacts;    
        return result;  
    }   
        
    @future 
    public static void assignPermissionSet(Id userId){  
        Id pSetId = [select id, name,profileid from permissionset where Name ='AGN_AMI_Portal_Access'].id;  
        List<permissionSetAssignment> psaList = [select id,AssigneeId from PermissionSetAssignment where AssigneeId= :userId and PermissionSetId =: pSetId limit 1];    
        PermissionSetAssignment permSetAssign = new PermissionSetAssignment();  
        permSetAssign.AssigneeId = userId;  
        permSetAssign.PermissionSetId = pSetId; 
        if(psaList.isEmpty() && pSetId != null) 
            insert permSetAssign;   
    }   
        
    webservice static String checkDuplicate(String firstName, String lastName, String userEmail) {  
        List<Account> accList = [Select Id, FirstName, LastName, PersonEmail from Account   
                                 where FirstName =: firstName   
                                 and LastName =: lastName   
                                 and PersonEmail =: userEmail Limit 1]; 
        return !accList.isEmpty() ? 'true' : 'false';   
    }   
    webservice static String saveProcessedRecord(Id caseId, Id ACRId, String userEmail) {   
        String success = 'false';   
        Case caseRecord = new Case();   
        caseRecord.Status = 'Closed';   
        caseRecord.Id = caseId; 
        Allergan_Customer_Registration_AGN__c ACRRecord = new Allergan_Customer_Registration_AGN__c();  
        ACRRecord.Id = ACRId;   
        ACRRecord.Process_AGN__c = true;    
        List<User> listAMIUser = [Select Id,Contact.AccountId from User     
                                  where Email =: userEmail  
                                  and Contact.Account.AGN_AMI_Enabled__c = true 
                                  and IsActive = true   
                                  Limit 1]; 
        List<Allergan_Customer_Registration_AGN__c> listACR = [select Account_AGN__r.AGN_AMI_Enabled__c     
                                                               from Allergan_Customer_Registration_AGN__c   
                                                               where id =: ACRId Limit 1];  
            
        if(listAMIUser.size() > 0)  
        {   
            ACRRecord.Account_AGN__c = listAMIUser[0].Contact.AccountId;    
            success = 'User already existing in the AMI system';    
        }   
            
        Savepoint sp = Database.setSavepoint(); 
        try 
        {   
            //system.debug(caseRecord); 
            if(! listACR.isEmpty() && listACR[0].Account_AGN__c != null && listACR[0].Account_AGN__r.AGN_AMI_Enabled__c)    
            {   
                success = 'Account mapped is already enabled in AMI Portal.';   
            }   
            else if (!isRelatedAddressNotEmpty(ACRId))  
            {   
                success = noAddressLabel;   
            }   
            else    
            {   
                update caseRecord;  
                update ACRRecord;   
                success = success + 'create_true';  
                List <Allergan_Customer_Registration_AGN__c> lstCustid = [SELECT Account_AGN__r.Id, Contact_AGN__r.Id, Email_AGN__c, Language_AGN__c    
                                                                          from  Allergan_Customer_Registration_AGN__c   
                                                                          where Id =: ACRId 
                                                                          LIMIT 1]; 
                system.debug(lstCustid);    
                enableAMIUser(lstCustid[0].Account_AGN__r.Id, lstCustid[0], lstCustid[0].Contact_AGN__r.Id);    
                // Added to insert HCP Profile with proper Level and default Category   
                insertHCPProfile(lstCustid[0].Account_AGN__r.Id, lstCustid[0].Contact_AGN__r.Id);   
            }   
            system.debug(ACRRecord);    
        }   
        catch(Exception e)  
        {   
            success = 'Some errors occured. Contact your adminstrator'; 
            System.debug(e);    
            Database.rollback(sp);  
            AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_Utility_class','saveProcessedRecord');   
        }   
        return success; 
    }   
    webservice static String rejectRecord(Id caseId, Id ACRId) {    
        String success = 'false';   
        Case caseRecord = new Case();   
        caseRecord.Status = 'Closed';   
        caseRecord.Id = caseId; 
        Allergan_Customer_Registration_AGN__c ACRRecord = new Allergan_Customer_Registration_AGN__c();  
        ACRRecord.Id = ACRId;   
        ACRRecord.Rejected_AMI_AGN__c = true;   
        Savepoint sp = Database.setSavepoint(); 
        try 
        {   
            update caseRecord;  
            update ACRRecord;   
            success = success + 'create_true';  
        }   
        catch(Exception e)  
        {   
            success = 'Some errors occured. Contact your adminstrator/support team';    
            System.debug(e);    
            Database.rollback(sp);  
            AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_Utility_class','saveProcessedRecord');   
        }   
        return success; 
    }   
      public static String generateRandomString(Integer len) {  
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';  
        String randStr = '';    
        while (randStr.length() < len) {    
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());    
            randStr += chars.substring(idx, idx+1); 
        }   
        return randStr;     
    }   
    // Updated as part of DQ Harmonization to create user from contact instead of Account   
    @future     
    public static void createCustomerUser(string customerAccount, String customerRegistration, String customerContact){ 
        //G.B - 07.07.2020 - extend try/catch error handling    
        try{    
            //get account record from json  
            system.debug('customerAccount=='+customerAccount);  
            // Removes as part of DQ Harmonization  
            Account customer = (Account)JSON.deserialize(customerAccount, Account.class);   
            Contact contact = (Contact)JSON.deserialize(customerContact, Contact.class);    
            Allergan_Customer_Registration_AGN__c registration = (Allergan_Customer_Registration_AGN__c)JSON.deserialize(customerRegistration, Allergan_Customer_Registration_AGN__c.class);    
            AMI_User_Settings_AGN__c allDetails =  AMI_User_Settings_AGN__c.getInstance(contact.Country_AGN__r.Name);   
                
            User customerUser = new User(); 
            //try   
            //{ 
            string alias = generateRandomString(8); 
            
            customerUser.Email = contact.Email; // Updated to consider registration email from - customer.PersonEmail;  
            customerUser.Phone = contact.Phone; 
            customerUser.FirstName = contact.FirstName; 
            customerUser.LastName = contact.LastName;   
            customerUser.Alias = Alias;     
            customerUser.LanguageLocaleKey = contact.Language_AGN__c;   
            customerUser.EmailEncodingKey = 'UTF-8';            
            customerUser.LocalesIdKey = allDetails.User_Locale__c;  
            customerUser.TimezonesIdKey =allDetails.User_Timezone__c;   
            customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: allDetails.User_Profile__c limit 1].Id;  
            customerUser.UserName = contact.Email // Updated to consider registration email from - customer.PersonEmail;    
                + '.' + USERNAME_SUFFIX;    
            customerUser.ContactId = contact.Id;    
            customerUser.Country_Code__c = contact.Country_Code_AGN__c; 
            if(contact.Country_Code_AGN__c != contact.Country_AGN__r.Name){ 
                customerUser.Cluster_User_AGN__c = true;    
                customerUser.MA_User_Country_Code_AGN__c = contact.Country_AGN__r.Name; 
            }   
            //customerUser.Division=contact.Customer_Sub_Category_AGN__c;   
                
            system.debug('======customerUser====='+customerUser);   
                
            insert customerUser;  
            
         
            
            
            if(customerUser.MA_User_Country_Code_AGN__c!=null){
                if(AMI_User_Settings_AGN__c.getValues(customerUser.MA_User_Country_Code_AGN__c).Anatomy_App_Permission_Required__c==true)
                {
                    boolean containDomain = false;
                    list<String> test =new   list<String>();
                    String str = AMI_User_Settings_AGN__c.getValues(customerUser.MA_User_Country_Code_AGN__c).Domain_Anatomy_App__c;
                    if(str != null){
                        test = str.split(';'); 
                    }
                    
                    if(test.size()>0){
                        for(String a :test){
                            system.debug('a>>>'+a);
                            if(customerUser.email.toLowercase().contains(a)==true){
                                containDomain =true;
                            }   
                        }  
                    }
                    if(containDomain==false){
                        assignAnatomyPermissionSet(customerUser.Id); 
                    }
                } 
            }
            else
            {
                if(AMI_User_Settings_AGN__c.getValues(customerUser.Country_Code__c).Anatomy_App_Permission_Required__c==true)
                {
                    boolean containDomain = false;
                    list<String> test =new   list<String>();
                    String str = AMI_User_Settings_AGN__c.getValues(customerUser.Country_Code__c).Domain_Anatomy_App__c;
                    if(str != null){
                        test = str.split(';'); 
                    }
                    system.debug('str>>>'+str);
                    if(test.size()>0){
                        for(String a :test){
                            system.debug('a>>>'+a);
                            if(customerUser.email.toLowercase().contains(a)==true){
                                containDomain =true;
                            }   
                        }  
                    }
                    
                    if(containDomain==false){
                        assignAnatomyPermissionSet(customerUser.Id); 
                    }
                }
            }
        }          
        catch(Exception e)  
        {   
            String errorCode = 'createCustomerUser';    
            String className ='AGN_AMI_Utility_class';  
            String status ='open';  
            AGN_AMI_UserErrorLog userErrorLog = new AGN_AMI_UserErrorLog(e,errorCode,className,status); 
            System.enqueueJob(userErrorLog);    
        }   
    }  
    
     public static void assignAnatomyPermissionSet (id assigneeId){
        PermissionSet perid =[SELECT Id FROM PermissionSet WHERE Name = 'AGN_AMI_Anatomy_iPad_App' limit 1] ;
        PermissionSetAssignment per = new PermissionSetAssignment();
        per.AssigneeId =  assigneeId;
        per.PermissionSetId = perid.id;
        insert per;
    }
    
    //To create HCP Profile with proper/default values once the Account is created as the Registration is processed 
    public static void insertHCPProfile(Id AccID, Id ConId) 
    {   
        AMI_HCP_Profile_AGN__c AHP; 
        List<Product_Group_vod__c> productList = [SELECT Product_vod__c     
                                                  FROM Product_Group_vod__c     
                                                  WHERE Product_Catalog_vod__r.Name LIKE '%AMI Education Journey%'  
                                                  and Product_vod__r.Name LIKE '%Facial%'   
                                                  and Product_vod__r.Product_Type_vod__c = 'Detail'];   
        List<Id> productIdList = new List<Id>();    
        for(Product_Group_vod__c pgc : productList) 
            productIdList.add(pgc.Product_vod__c);  
        List<Product_Metrics_vod__c> metrics = [SELECT AMI_Education_Journey_AGN__c     
                                                FROM Product_Metrics_vod__c     
                                                WHERE Account_vod__c =: AccId   
                                                and Products_vod__c in: productIdList   
                                                ORDER BY AMI_Education_Journey_AGN__c ASC NULLS LAST    
                                                LIMIT 1];           
        List<AMI_HCP_Profile_AGN__c> listAHP= [Select Id from AMI_HCP_Profile_AGN__c where Account_AGN__c =: AccID Limit 1];    
            
        if(listAHP.size()>0)    
            AHP = listAHP[0];   
        else    
            AHP = new AMI_HCP_Profile_AGN__c(Account_AGN__c = AccID, Contact_AGN__c = ConId);   
            
        if(metrics.size()>0){   
            AHP.AMI_Education_AGN__c = metrics[0].AMI_Education_Journey_AGN__c; 
            AHP.HCP_Category_AGN__c = 'Knowledge seeker';   
        }else{  
                
            AHP.HCP_Category_AGN__c =  'Knowledge seeker';  
            AHP.AMI_Education_AGN__c =  '1';    
        }   
        upsert AHP; 
    }   
        
    //To updated or create AMI_HCP_Profile if the account is enabled in AMI Portal and its related Product Metrics is updated   
    public static void updateHCPProfile(Map<String,String> eduJourneyMap)   
    {   
        List<String> accIds = new List<String>(eduJourneyMap.keySet()); 
        List<AMI_HCP_Profile_AGN__c> oldProfiles = [Select Id, Account_AGN__c,AMI_Education_AGN__c  
                                                    from AMI_HCP_Profile_AGN__c     
                                                    where Account_AGN__c in :accIds];   
        List<Account> accList = [Select id from Account where id in :accIds and AGN_AMI_Enabled__c = true]; 
        List<Id> accEnabledList = new List<Id>();   
        for(Account acc : accList)  
        {   
            accEnabledList.add(acc.Id); 
        }   
            
        List<AMI_HCP_Profile_AGN__c> newProfiles = new List<AMI_HCP_Profile_AGN__c>();  
            
        for(String accId : accIds)  
        {   
            if(! accEnabledList.contains(accId))    
                continue;   
                
            boolean flag = false;   
            for(AMI_HCP_Profile_AGN__c ahp : oldProfiles)   
            {   
                if(ahp.Account_AGN__c == accId) 
                {   
                    flag = true;    
                    ahp.AMI_Education_AGN__c = eduJourneyMap.get(accId);    
                    newProfiles.add(ahp);   
                }   
            }   
            if(! flag)  
            {   
                AMI_HCP_Profile_AGN__c ahp = new AMI_HCP_Profile_AGN__c(Account_AGN__c = accId,     
                                                                        AMI_Education_AGN__c = eduJourneyMap.get(accId),    
                                                                        HCP_Category_AGN__c = 'Knowledge seeker');  
                newProfiles.add(ahp);   
            }   
                
            if(! newProfiles.isEmpty()) 
            {   
                try 
                {   
                    upsert newProfiles; 
                }   
                catch(Exception e)  
                {   
                    System.debug(e.getMessage());   
                    AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_Utility_class','updateHCPProfile');  
                }   
            }   
        }   
    }   
        
    //below is the wrapper class for getting loggedin user  
    public class  AGN_AMI_UserDetails { 
        public String userLanguage; 
        public String userCountryName;
        //CR 3839- Incident Fix- for sending actual country code to starta for cluster country.22/02/2021
        public String userCountryForStrata;
        public user user;   
        public User userRecord; 
        public Account accountRecord;   
        public Contact contactRecord;   
        public String maskedUserCountryName;    
        public AGN_AMI_UserDetails()    
        {   
            this.user = [Select     
                         //Fields from Account record   
                         contact.Account.isPersonAccount, contact.Account.Id,   
                         contact.Account.AMI_Specialty_AGN__c, contact.Account.Type_AGN__c,     
                         contact.Account.Country_vod__c,    
                         //Fields from Contact record   
                         Contact.Id, Contact.FirstName, Contact.LastName, Contact.Email,    
                         Contact.Salutation, contact.AccountId, 
                         //Fields from User record  
                         contactId, Cluster_User_AGN__c, MA_User_Country_Code_AGN__c, FirstName, LastName,  
                         Country_code__c, LanguageLocaleKey, Email, Profile.Id, UserType, Is_AMI_Demo_User_AGN__c,  
                         // Fields Added for POC    
                         Is_AMI_Country_Demo_User_AGN__c,Allergan_Internal_Account_Id__c    
                         from user  
                         where id =: Userinfo.getUserid()   
                         limit 1];      
            // DQ - HCP Harmonization changes start 
            system.debug('this.user.ContactId-->'+this.user.ContactId); 
            //system.debug('IsDirect-->'+IsDirect); 
            system.debug('Account.AGN_AMI_Enabled__c-->'+Account.AGN_AMI_Enabled__c);   
            /* Added logic to check Account.AGN_AMI_SC_Enabled__c and Contact.Is_AMI_SC_Contact_AGN__c is true  for Specialty Care -START*/ 
            if(! user.contact.Account.isPersonAccount && user.UserType == 'CspLitePortal')  
            {   
                // Use this query to fetch all account and contact related information.     
                // Query on contact and account should not be made in any other pages.  
                AccountContactRelation acr = [Select AccountId, ContactId,  
                                              //Fields from Account record  
                                              Account.Id, Account.AMI_Specialty_AGN__c,     
                                              Account.Type_AGN__c, Account.Country_vod__c,  
                                              //Fields from Contact record  
                                              Contact.Id, Contact.FirstName, Contact.LastName, Contact.Salutation, Contact.Email    
                                              from AccountContactRelation   
                                              where ContactId =: this.user.ContactId    
                                              and IsDirect = false  
                                              and (Account.AGN_AMI_Enabled__c = true    
                                                   or   Account.AGN_AMI_SC_Enabled__c = true)   
                                              and (Contact.Is_AMI_Contact_AGN__c = true 
                                                   or Contact.Is_AMI_SC_Contact_AGN__c = true)      
                                              Limit 1]; 
                this.userRecord = user; 
                this.accountRecord = acr.Account;   
                this.contactRecord = acr.Contact;   
            }   
                
            // PMO#2733 - Sales Rep Login Start 
            /* Added logic to check Account.AGN_AMI_SC_Enabled__c and Contact.Is_AMI_SC_Contact_AGN__c is true  for Specialty Care - END */ 
            else if(user.UserType != 'CspLitePortal' && user.UserType != 'Guest')   
            {   
                String countryCode = (user.Cluster_User_AGN__c)?user.MA_User_Country_Code_AGN__c:user.Country_Code__c;  
                    
                // Added logic for Allergan Internal usr access CR#3598- Start  
                  String accountId; 
                  if(String.isBlank(this.user.Allergan_Internal_Account_Id__c)) 
                  { 
                     accountId= AMI_User_Settings_AGN__c.getInstance(countryCode).Demo_Account_AGN__c;  
                  } else {  
                     accountId= this.user.Allergan_Internal_Account_Id__c;  
                  } 
                //String accountId = AMI_User_Settings_AGN__c.getInstance(countryCode).Demo_Account_AGN__c; 
                // Added logic for Allergan Internal usr access CR#3598- End    
                    
                AccountContactRelation acr = [Select AccountId, ContactId,  
                                              //Fields from Account record  
                                              Account.Id, Account.AMI_Specialty_AGN__c,     
                                              Account.Type_AGN__c, Account.Country_vod__c,  
                                              //Fields from Contact record  
                                              Contact.Id, Contact.FirstName, Contact.LastName, Contact.Salutation, Contact.Email    
                                              from AccountContactRelation   
                                               where AccountId =: accountId // CR#3598      
                                              //where AccountId =: this.user.Allergan_Internal_Account_Id__c    
                                              and IsDirect = false  
                                              and (Account.AGN_AMI_Enabled__c = true    
                                                   or   Account.AGN_AMI_SC_Enabled__c = true)   
                                              Limit 1]; 
                this.userRecord = user; 
                this.accountRecord = acr.Account;   
                this.contactRecord = acr.Contact;   
            }   
            // Sales Rep Login End  
            // DQ - HCP Harmonization backward compatibility start  
            else    
            {   
                this.accountRecord = user.Contact.Account;  
                this.contactRecord = user.Contact;  
            }   
            // DQ - HCP Harmonization backward compatibility start  
            // DQ - HCP Harmonization changes end   
                
            this.userLanguage = this.user.LanguageLocaleKey;    
            if(! this.user.Cluster_User_AGN__c) 
            {   
                this.userCountryName = this.user.Country_code__c; 
                // CR 3839-Incident Fix for sending actual country code to starta for cluster country. 
                this.userCountryForStrata= this.user.Country_code__c;   
                
            }   
            else    
            {   
                this.userCountryName = this.user.MA_User_Country_Code_AGN__c;
                // CR-3839, Incident Fix for sending actual country code to starta for cluster country.22/02/2021
                this.userCountryForStrata= this.user.MA_User_Country_Code_AGN__c;    
            }   
            /*AMI MENA changes- Start*/     
            if(user.UserType == 'Guest'){   
                String externalCountry = ApexPages.currentPage().getParameters().get('country');    
                List<AGN_AMI_MENA_Mapping__mdt> menaSettings1 = new List<AGN_AMI_MENA_Mapping__mdt>([Select AGN_AMI_Child_Country_Code__c,AGN_AMI_Parent_Country_Code__c from   
                                                                                                     AGN_AMI_MENA_Mapping__mdt Where MasterLabel =:externalCountry ]) ; 
                if(menaSettings1.size() > 0){   
                    userCountryName=menaSettings1[0].AGN_AMI_Parent_Country_Code__c;    
                }else{  
                    userCountryName=externalCountry;    
                }   
            }   
            List<AGN_AMI_MENA_Mapping__mdt> menaSettings2 = new List<AGN_AMI_MENA_Mapping__mdt>([Select AGN_AMI_Child_Country_Code__c,AGN_AMI_Parent_Country_Code__c from   
                                                                                                 AGN_AMI_MENA_Mapping__mdt Where MasterLabel =:userCountryName ]) ; 
                
            if(menaSettings2.size() > 0){   
                for(AGN_AMI_MENA_Mapping__mdt m:menaSettings2){ 
                    maskedUserCountryName=userCountryName;  
                    userCountryName=m.AGN_AMI_Parent_Country_Code__c;   
                        
                }   
            }else{  
                maskedUserCountryName=userCountryName;  
            }   
            /*AMI MENA changes- End */  
        }   
    }   
    public static void sendNotification(EmailTemplate template, String Body, List<String> emailIdList, string subject, Id objectId) 
    {   
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();    
        Id contactId = [Select ContactId from User where id =: UserInfo.getUserId() Limit 1].Id;    
        system.debug(Body); 
        system.debug('emailsent@@@@'+ emailIdList); 
        email.setToAddresses(emailIdList);  
        email.setTemplateId(template.Id);   
        email.setSaveAsActivity(false); 
        email.setSubject(subject);  
        //email.setTargetObjectId(contactId);   
        if(Body != null)    
        {   
            system.debug('emailsent@@@@Body'+ emailIdList); 
            email.setHtmlBody(Body);    
                
        }   
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();    
        emailList.add(email);   
        List<Messaging.SendEmailResult> emailingResult = Messaging.sendEmail(emailList, true);  
        system.debug('emailsent@@@@emailingResult'+ emailingResult);    
        System.debug(emailingResult);   
    }   
    public static Map<String,List<Schema.PicklistEntry>> getDependentPicklistValues( Schema.sObjectField dependToken )  
    {   
        Schema.DescribeFieldResult depend = dependToken.getDescribe();  
        Schema.sObjectField controlToken = depend.getController();  
        if ( controlToken == null ) return null;    
        Schema.DescribeFieldResult control = controlToken.getDescribe();    
        List<Schema.PicklistEntry> controlEntries = 
            (   control.getType() == Schema.DisplayType.Boolean 
             ?   null   
             :   control.getPicklistValues()    
            );  
            
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';  
        Map<String,List<Schema.PicklistEntry>> dependentPicklistValues = new Map<String,List<Schema.PicklistEntry>>();  
        for ( Schema.PicklistEntry entry : depend.getPicklistValues() ) if ( entry.isActive() ) 
        {   
            List<String> base64chars =  
                String.valueOf  
                (   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( entry ) )).get( 'validFor' ) 
                ).split( '' );  
            for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )    
            {   
                Object controlValue =   
                    (   controlEntries == null  
                     ?   (Object) (index == 1)  
                     :   (Object) (controlEntries[ index ].isActive() ? controlEntries[ index ].getLabel() : null)  
                    );  
                Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );  
                if  (   controlValue == null    
                     || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0   
                    ) continue; 
                if ( !dependentPicklistValues.containsKey( controlValue.toString() ) )  
                {   
                    dependentPicklistValues.put( controlValue.toString(), new List<Schema.PicklistEntry>() );   
                }   
                dependentPicklistValues.get( controlValue.toString() ).add( entry );    
            }   
        }   
        return dependentPicklistValues; 
    }   
    //Added for fetching the address details by passing the zinc code   
    public static AddressDetail getAddressDetail(string cep) {  
            
        String brazilCEPEndpoint = System.Label.AGN_AMI_Brazil_Endpoint;    
        AddressDetail address = new AddressDetail();    
            
        HttpRequest req = new HttpRequest();    
        req.setEndpoint( brazilCEPEndpoint + cep);  
        req.setMethod('GET');           
            
        Http http = new Http(); 
        HTTPResponse res = http.send(req);  
        System.debug('Body@@@@' + res.getBody());   
        if(res.getStatusCode()==200)    
        {   
            JSONParser parser = JSON.createParser(res.getBody());   
            while (parser.nextToken() != null) {    
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'complemento')){ 
                    parser.nextToken(); 
                    //address.complement = parser.getText();    
                    address.complement ='';             
                }   
                else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'estado')){ 
                    parser.nextToken(); 
                    address.state = parser.getText();               
                }   
                else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'cidade')){ 
                    parser.nextToken(); 
                    address.city = parser.getText();                
                }   
                else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'logradouro') || parser.getText() == 'endere\u00e7o'){  
                    parser.nextToken(); 
                    address.street = parser.getText();              
                }   
                else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'bairro')){ 
                    parser.nextToken(); 
                    address.bairro = parser.getText();              
                }   
                else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'cep')){    
                    parser.nextToken(); 
                    address.zip = parser.getText();             
                }   
                    
            }   
        }   
        return address ;    
            
    }   
        
    //wrapper for the Address detail    
    public class AddressDetail{ 
        public string street;   
        public string city;     
        public string state;    
        public string complement;   
        public string bairro;   
        public string zip;  
            
        public AddressDetail(){ 
                
        }   
    }   
    //Email for workshop rejection  
    @InvocableMethod    
    public static void WorkshopRejection(List <AMI_Workshop_Attendee_AGN__c> attendees) 
    {   
        String userCountryName='';  
        //AGN_AMI_UserDetails userdetails = new AGN_AMI_UserDetails();      
        AMI_Workshop_Attendee_AGN__c attendee = new AMI_Workshop_Attendee_AGN__c(); 
        system.debug('attendees@@@@@' + attendees); 
        attendee=attendees[0];  
        string wid=attendee.AMI_Workshop_AGN__c;    
        AMI_Workshop_AGN__c wrkshop= [select Country_Code_AGN__c,Date_AGN__c from AMI_Workshop_AGN__c where Id =: wid limit 1  ];   
        userCountryName=wrkshop.Country_Code_AGN__c;    
        AMI_Web_Visibility_Settings_AGN__c awv = AMI_Web_Visibility_Settings_AGN__c.getValues(userCountryName); 
        AMI_User_Settings_AGN__c aus = AMI_User_Settings_AGN__c.getValues(userCountryName); 
        String FormattedTime = wrkshop.Date_AGN__c.format('HH:mm',aus.User_Timezone__c);    
        if(awv.Workshop_Rejection_Notification_AGN__c)  
        {   
            EmailTemplate template; 
                
            template = [SELECT DeveloperName, Id, body, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = 'AGN_AMI_Workshop_Rejection_Notification' limit 1];     
            String htmlBody = template.HtmlValue;   
            AMI_Workshop_Attendee_AGN__c attendeeDetail = [Select Workshop_Details_AGN__c, Account_Details_AGN__c   
                                                           from AMI_Workshop_Attendee_AGN__c where id =: attendee.Id Limit 1];  
            system.debug(htmlBody); 
            Map<String, String> mapBodyParams = new Map<String, String>     
            {   
                '{!AMI_Workshop_Attendee_AGN__c.Workshop_Details_AGN__c}' => attendeeDetail.Workshop_Details_AGN__c,    
                    '{!AMI_Workshop_Attendee_AGN__c.Account_Details_AGN__c}' => attendeeDetail.Account_Details_AGN__c,  
                    'AMI_Workshop_Attendee_AGN__c.FormattedTime' => FormattedTime   
                    };  
                        for (String key : mapBodyParams.keySet()) { 
                            htmlBody = htmlBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));   
                            //plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));   
                        }   
            //template.Body = body; 
            system.debug(template); 
            system.debug(htmlBody); 
            List<String> emailIdList = new List<String>();  
            if(awv.Workshop_Email_List_AGN__c.contains(';'))    
            {   
                emailIdList = awv.Workshop_Email_List_AGN__c.split(';');    
                system.debug('emailIdList@@@' + emailIdList);   
                AGN_AMI_Utility_class.sendNotification(template, htmlBody, emailIdList, template.Subject, attendee.Id); 
            }   
            else if(! String.isBlank(awv.Workshop_Email_List_AGN__c))   
            {   
                emailIdList.add(awv.Workshop_Email_List_AGN__c);    
                AGN_AMI_Utility_class.sendNotification(template, htmlBody, emailIdList, template.Subject, attendee.Id); 
            }           
        }   
    }   
   /*   
    * @Author Hijith NS 
    * @description : Added as part of ACR process Fix   
                     Method check for related address on mapped Business Account    
    * @param : acrId - Allergan Customer Registration Id    
    * @return: Boolean  
    * @date : 07/17/2020    
    */  
        
     public static Boolean isRelatedAddressNotEmpty(Id acrId){  
            
        List <Allergan_Customer_Address_AGN__c> acaList = new List <Allergan_Customer_Address_AGN__c>();    
        List<Address_vod__c> temObjList = new List<Address_vod__c>();           
        Boolean hasAddress = true;  
        try{    
            acaList = [SELECT Account_AGN__c,Parent_AGN__c  
                       FROM Allergan_Customer_Address_AGN__c    
                       WHERE Parent_AGN__c =:acrId AND Account_AGN__c !=NULL ]; 
            if(acaList.size()>0){   
                temObjList = [SELECT Id     
                              FROM Address_vod__c   
                              WHERE Account_vod__c =: acaList[0].Account_AGN__c AND Account_vod__c!=NULL LIMIT 1];  
                hasAddress = temObjList.isEmpty()?false:true;               
            }   
        }catch(exception ex){   
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Utility_class','isRelatedAddressNotEmpty'); 
        }   
        return hasAddress;  
    }   
}