public class AGN_AMI_Utility_Bulkify_Class {
    
    public static User uInfo{get{return [SELECT Id,Name,Country_Code__c,Cluster_User_AGN__c,MA_User_Country_Code_AGN__c from User where Id =: UserInfo.getUserId() limit 1];}} 
    public static final String USERNAME_SUFFIX =  (String)AMI_User_Settings_AGN__c.getValues((uInfo.Cluster_User_AGN__c)?uInfo.MA_User_Country_Code_AGN__c:uInfo.Country_Code__c).get('Username_Suffix__c');
    
    public static void enableAMIUser(List<Id> accountIds){
        
        List<Account> accounts = new List<Account>([SELECT Id,
                                                    PersonEmail, 
                                                    Phone, 
                                                    FirstName, 
                                                    LastName, 
                                                    PersonContactId,
                                                    Language_vod__c,
                                                    Country_Code__c,
                                                    Country_vod__r.Name,
                                                    AGN_AMI_Enabled__c,
                                                    Specialty_1_AGN__r.Name,
                                                    Customer_Sub_Category_AGN__c,
                                                    Specialty_Allergan_1_AGN__r.Name,
                                                    Sub_Specialty_Allergan_AGN__r.Name
                                                    FROM Account 
                                                    WHERE Id in:accountIds
                                                    and PersonEmail != null]);
        
        //Set<String> emailIds=new Set<String>();
        Set<String> specialty1AgnName=new Set<String>();
        Set<String> countryVodName=new Set<String>();
        List<AMI_SPecality_AGN__c> ASList = [select id,Allergan_Speciality_Name_AGN__c,Country_AGN__r.Name from AMI_SPecality_AGN__c];
        Map<Id,String> AMIsPecalityMapName =new Map<Id,String>();
        Map<Id,String> AMIsPecalityMapCountry =new Map<Id,String>();
        if(!(accounts.isEmpty())){
            for (Account a:accounts){
                //emailIds.add(a.PersonEmail);
                specialty1AgnName.add(a.Specialty_1_AGN__r.Name);
                countryVodName.add(a.Country_vod__r.Name);
            }
        }
        
        for(AMI_SPecality_AGN__c a:ASList){
            AMIsPecalityMapName.put(a.id,a.Allergan_Speciality_Name_AGN__c);
            AMIsPecalityMapCountry.put(a.id,a.Country_AGN__r.Name);
        }
        
        for(Account a:accounts){
            for(String s:AMIsPecalityMapName.values()){
                if(a.Specialty_1_AGN__r.Name.equals(s)){
                    if(AMIsPecalityMapCountry.containsKey(a.id)){
                        a.AMI_Specialty_AGN__c=a.Id;
                    }
                }
            }
        }
        List<Account> updateAccounts = new List<Account>();
        if(!(accounts.isEmpty())){
            for(Account a:accounts){
                a.AGN_AMI_Enabled__c= True;
                updateAccounts.add(a);
            }                    
        }
        
        if(!(updateAccounts.isEmpty())){
            //Call Batch apex to update the Accounts
            //Id accountBatchJobId = Database.executeBatch(new AGN_AMI_Utility_Batch_UpdateAccounts(updateAccounts), 250);
            Id accountBatchJobId = Database.executeBatch(new AGN_AMI_Utility_Batch_Generic(updateAccounts,'Update'), 250);
        }
        
        //Create Users
        
        List<User> createUsers=new List<User>();
        Id customerUserProfileId=[SELECT Id FROM Profile WHERE Name ='AMI Customer Community' limit 1].Id;
        
        if(!(accounts.isEmpty())){
            for(Account a: accounts) {
                AMI_User_Settings_AGN__c allDetails =  AMI_User_Settings_AGN__c.getInstance(a.Country_vod__r.Name);
                User customerUser = new User();
                string Alias = '';
                
                if (a.FirstName.length() > 0){  
                    Alias += a.FirstName.substring(0, 1);
                }  
                if(a.LastName.length()>0){            
                    Alias += a.LastName.substring(0,Math.min(a.LastName.length(), 4));
                }
                
                customerUser.Email = a.PersonEmail +'.' + USERNAME_SUFFIX;
                customerUser.Phone = a.Phone;  
                customerUser.FirstName = a.FirstName;
                customerUser.LastName = a.LastName;
                customerUser.Alias = Alias;  
                customerUser.LanguageLocaleKey = a.Language_vod__c;
                customerUser.EmailEncodingKey = 'UTF-8';        
                customerUser.LocalesIdKey = allDetails.User_Locale__c;
                customerUser.TimezonesIdKey =allDetails.User_Timezone__c;
                //customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: allDetails.User_Profile__c limit 1].Id;
                customerUser.ProfileId=customerUserProfileId;
                customerUser.UserName = a.PersonEmail + '.' + USERNAME_SUFFIX;
                customerUser.ContactId = a.PersonContactId; 
                customerUser.Country_Code__c = a.Country_Code__c;
                if(a.Country_Code__c != a.Country_vod__r.Name)
                {
                    customerUser.Cluster_User_AGN__c = true;
                    customerUser.MA_User_Country_Code_AGN__c = a.Country_vod__r.Name;
                }
                customerUser.Division=a.Customer_Sub_Category_AGN__c;      
                createUsers.add(customerUser);       
                
            }
        }
        
        // Alias uniqueness handling
        
        List<User> allUsersList=[SELECT Id,FirstName,LastName,Email,Alias,SMB_Alias_External_Id__c FROM User];
        Map<String,String> allUserMap=new Map<String,String>();
        Map<String,User> destinationUserMap= new Map<String,User>();
        for(User u:allUsersList){
            allUserMap.put(u.Alias,u.Alias);
        }
        
        for(User s:createUsers){
            
            while(allUserMap.ContainsKey(s.Alias)){
                if(s.Alias.right(1).isNumeric()){
                    if((s.Alias.right(1)=='9') && (s.Alias.right(2).isNumeric())){
                        String lastAliasChar=s.Alias.right(2);
                        Integer count=1;
                        count+=integer.valueof(lastAliasChar);
                        s.Alias=s.Alias.remove(lastAliasChar);
                        s.Alias+=count;
                    }
                    else{
                        String lastAliasChar=s.Alias.right(1);
                        Integer count=1;
                        count+=integer.valueof(lastAliasChar);
                        s.Alias=s.Alias.remove(lastAliasChar);
                        s.Alias+=count; 
                    }
                }
                else{
                    Integer count=1;
                    s.Alias+=count;
                }
            }
            while(destinationUserMap.containsKey(s.Alias)){
                if(s.Alias.right(1).isNumeric()){
                    if((s.Alias.right(1)=='9') && (s.Alias.right(2).isNumeric())){
                         String lastAliasChar=s.Alias.right(2);
                         Integer count=1;
                         count+=integer.valueof(lastAliasChar);
                         s.Alias=s.Alias.remove(lastAliasChar);
                         s.Alias+=count;
                    }
                    else{
                         String lastAliasChar=s.Alias.right(1);
                         Integer count=1;
                         count+=integer.valueof(lastAliasChar);
                         s.Alias=s.Alias.remove(lastAliasChar);
                         s.Alias+=count;
                    }
                }
                else{
                    Integer count=1;
                    s.Alias+=count; 
                }
            }
            destinationUserMap.put(s.Alias,s);
            
        }
        List<User> destinationUserList=new List<User>();
        for(User s:destinationUserMap.values()){
            destinationUserList.add(s);
        }
        
        //Call Batch apex to Create the Users
        if(!(destinationUserList.isEmpty())){
            //Id userBatchJobId = Database.executeBatch(new AGN_AMI_Utility_Batch_CreateUsers(createUsers), 250);
            Id userBatchJobId = Database.executeBatch(new AGN_AMI_Utility_Batch_Generic(destinationUserList,'Insert'), 250);
        }
        //Reset Password
        if(!(destinationUserList.isEmpty())){
        	Id passwordBatchJobId = Database.executeBatch(new AGN_AMI_Utility_Batch_Generic(destinationUserList,'Reset'), 140);
        }
    }
    public static void insertHCPProfile(List<Id> accountIds){
        
        Set<Id> IdsGet=new Set<Id>();
        Set<Id> IdsSet=new Set<Id>();       
        for(Id a:accountIds){
            IdsGet.add(a);
        }
        
        List<AMI_HCP_Profile_AGN__c> AHP=new List<AMI_HCP_Profile_AGN__c>();
        List<AMI_HCP_Profile_AGN__c> AHPUpdate=new List<AMI_HCP_Profile_AGN__c>() ;
        List<Product_Group_vod__c> productList = [SELECT Product_vod__c 
                                                  FROM Product_Group_vod__c 
                                                  WHERE Product_Catalog_vod__r.Name LIKE '%AMI Education Journey%' 
                                                  and Product_vod__r.Name LIKE '%Facial%'
                                                  and Product_vod__r.Product_Type_vod__c = 'Detail'];
        List<Id> productIdList = new List<Id>();
        for(Product_Group_vod__c pgc : productList){
            productIdList.add(pgc.Product_vod__c);
        }
        List<Product_Metrics_vod__c> metrics = [SELECT AMI_Education_Journey_AGN__c 
                                                FROM Product_Metrics_vod__c 
                                                WHERE Account_vod__c in: accountIds 
                                                and Products_vod__c in: productIdList
                                                ORDER BY AMI_Education_Journey_AGN__c ASC NULLS LAST 
                                               ]; 
        List<AMI_HCP_Profile_AGN__c> foundListAHP= [Select Id from AMI_HCP_Profile_AGN__c where Account_AGN__c in: accountIds];
        if(!(foundListAHP.isEmpty())){
            for(Id i:accountIds){            
                for(AMI_HCP_Profile_AGN__c b:foundListAHP){
                    IdsSet.add(b.Account_AGN__c);
                    if(b.Account_AGN__c==i){
                        AHP.add(b);
                    }                
                }
            }
        }
        for(Id i:IdsGet){
            if(!(IdsSet.contains(i))){
                AMI_HCP_Profile_AGN__c AHPtemp=new AMI_HCP_Profile_AGN__c(Account_AGN__c = i);
                AHP.add(AHPtemp);
            }
        }
        for(Product_Metrics_vod__c p:metrics){
            for(AMI_HCP_Profile_AGN__c a:AHP){
                if(p.Account_vod__c==a.Account_AGN__c){
                    a.AMI_Education_AGN__c=p.AMI_Education_Journey_AGN__c;
                    a.HCP_Category_AGN__c='Knowledge seeker';    
                    AHPUpdate.add(a);
                }
                else{
                    AHPUpdate.add(a); 
                }
            }
        }

        //Call Batch apex to Upsert HCP Profile
        
        Id HCPBatchJobId = Database.executeBatch(new AGN_AMI_Utility_Batch_Generic(AHPUpdate,'Upsert'), 250);
    }    
}