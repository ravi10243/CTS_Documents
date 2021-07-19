public without sharing class AGN_OAMCustomerRegUtils {
    
    public static boolean checkForDuplicateCustomer(String email) {
        
        string newUserName = email + '.' + AGN_OAMConstant.USERNAME_SUFFIX;
        
        for (User u: [select Id from User where UserName =: newUserName and isActive = true limit 1]) {
            return true;
        }
        return false;
    }
    @TestVisible
    private static void mapCustomerType(list < Customer_Type_Configuration_AGN__c > config, Allergan_Customer_Address_AGN__c customerAddress, Allergan_Customer_Registration_AGN__c customer) {
        for (Customer_Type_Configuration_AGN__c c: config) {
            if (c.Category_AGN__c == customer.Customer_Category_AGN__c && c.Sub_Category__c == customer.Customer_Sub_Category_AGN__c) {
                customerAddress.Account_Type_AGN__c = c.Account_Record_Type_AGN__c;
                //customerAddress.Type_AGN__c = c.Category_AGN__c;
                //customerAddress.Sub_Type_AGN__c = c.Sub_Category__c;
                customer.Account_Sub_Type_AGN__c = c.Category_AGN__c;
                customerAddress.Sub_Type_AGN__c = c.Category_AGN__c;
                customer.Customer_Group_AGN__c = c.Customer_Group_AGN__c;
                
                break;
            }
        }
    }
    
    public static Account createAccount(Allergan_Customer_Registration_AGN__c customer) {
        
        Account customerAccount = new Account();
        
        try {
            customerAccount.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
                                            AND DeveloperName = 'Professional_vod'
                                            LIMIT 1
                                           ][0].Id;
            customerAccount.Salutation = customer.Salutation_AGN__c;
            customerAccount.FirstName = customer.First_Name_AGN__c;
            customerAccount.LastName = customer.Last_Name_AGN__c;
            customerAccount.PersonEmail = customer.Email_AGN__c;
            customerAccount.Phone = customer.Phone_AGN__c;
            customerAccount.OwnerId = AGN_OAMConstant.OWNER_ID;
            customerAccount.Customer_Registration_AGN__c = 'In Progress';
            customerAccount.Customer_Managed_AGN__c = true;
            customerAccount.Country_Code__c = customer.Country_Code_AGN__c;
            customerAccount.Country_vod__c = customer.Country_AGN__c;
            
            system.debug('@@@@@ customer.Country_Code_AGN__c @@@@@'+ customer.Country_Code_AGN__c);
            system.debug('@@@@@ customer.Country_AGN__c @@@@@'+customer.Country_AGN__c);
            
            customerAccount.Customer_Category_AGN__c = customer.Customer_Category_AGN__c;
            customerAccount.Customer_Sub_Category_AGN__c = customer.Customer_Sub_Category_AGN__c;
            //------CheckMarx--Added on 25/07/2020----------      
            List<Account> tempAcList = new List<Account>();
            tempAcList.add(customerAccount);
            /*SObjectAccessDecision decisionOnCrUsr = Security.stripInaccessible(AccessType.CREATABLE,tempAcList);
            if(decisionOnCrUsr.getRemovedFields().get('Account')!=null){
                throw new AGN_CommonException('Error: Insufficient Create Access On Account [Class Name: AGN_OAMCustomerRegUtils and Method Name: createAccount]');
            }
            else{
                insert customerAccount;
            }*/
            String objAcc = 'Account';
            SObjectType AccObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempAcList,AccObjType,'INSERT');
            insert customerAccount;
            //-------------------------
            
            system.debug('@@@@@ customerAccount @@@@@'+customerAccount);
            
            customerAccount = [select Id, Name, PersonContactId, 
                               FirstName, Country_Code__c, LastName, 
                               PersonEmail, Phone, Customer_Category_AGN__c, 
                               Customer_Sub_Category_AGN__c,
                               Okta_Id_AGN__c,
                               Community_Okta_Password_Reset_Token_AGN__c 
                               from Account where Id =: customerAccount.Id limit 1];
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
        return customerAccount;
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
    
    //User object is "setup" object, the "Mixed_DML_operation" error will be occured if we’re trying to perform DML operation 
    //on both setup and non-setup objects (e.g Account) in the same transation.
    //To fix this kind of error, we need to perform DML operations on more than one transation or need to use @future method (this method has some limitation).
    public static Id createCommunityUser(Id customerAccountId) {
        
        string alias = '';
        Account customer = [select Id, Name, PersonContactId, FirstName, Country_Code__c, LastName, PersonEmail, Phone, Customer_Category_AGN__c, Customer_Sub_Category_AGN__c from Account where Id =: customerAccountId limit 1];
        OAM_User_Settings__c allDetails = OAM_User_Settings__c.getInstance(customer.Country_Code__c);
        User customerUser = new User();
        
        
        try {
            /*if (customer.FirstName.length() > 0) {
                alias += customer.FirstName.substring(0, 1);
            }
            if (customer.LastName.length() > 0) {
                //alias += customer.LastName.substring(0,Math.min(customer.LastName.length(), 7));
                alias += customer.LastName.substring(0, Math.min(customer.LastName.length(), 4));
            }
            
            // Alias uniqueness handling
            
            integer existingUserCount = [SELECT COUNT() FROM User WHERE SMB_Alias_External_Id__c LIKE: alias + '%'];
            if (existingUserCount > 0) {
                alias += existingUserCount;
            }*/
            
            alias = generateRandomString(8);        
            
            customerUser.Email = customer.PersonEmail.toLowercase();
            customerUser.Phone = customer.Phone;
            customerUser.FirstName = customer.FirstName;
            customerUser.LastName = customer.LastName;
            customerUser.Alias = alias;
            customerUser.LanguageLocaleKey = allDetails.User_Language__c;
            customerUser.EmailEncodingKey = 'UTF-8';
            customerUser.LocalesIdKey = allDetails.User_Locale__c;
            customerUser.TimezonesIdKey = allDetails.User_Timezone__c;
            customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: allDetails.User_Profile__c limit 1].Id;
            customerUser.UserName = customer.PersonEmail.toLowercase() + '.' + AGN_OAMConstant.USERNAME_SUFFIX;
            customerUser.ContactId = customer.PersonContactId;
            customerUser.Country_Code__c = customer.Country_Code__c;
            customerUser.Division = customer.Customer_Sub_Category_AGN__c;
            customerUser.FederationIdentifier = customer.PersonEmail.toLowercase(); //SSO Mapping
              //------CheckMarx--Added on 25/07/2020----------      
            List<User> tempuserList = new List<User>();
            tempuserList.add(customerUser);
            /*SObjectAccessDecision decisionOnCrUsr = Security.stripInaccessible(AccessType.CREATABLE,tempuserList);
            if(decisionOnCrUsr.getRemovedFields().get('User')!=null){
                throw new AGN_CommonException('Error: Insufficient Create Access On User [Class Name: AGN_OAMCustomerRegUtils and Method Name: createCommunityUser]');
            }
            else{
                 insert customerUser;
            }*/
            String objCRUser = 'User';
            SObjectType CRUserObjType = ((SObject)(Type.forName('Schema.'+objCRUser).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempuserList,CRUserObjType,'INSERT');
            insert customerUser;
            //-------------------------
            
            
            system.debug('@@@@@ customerUser @@@@'+customerUser);
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
        return customerUser.Id;
    }
    
    public static Id createCommunityUser(Id customerAccountId , String selectedUserLocale) {
        system.debug('customerAccountId>>>>>>>>>>>>>>>>>>>>>'+customerAccountId);
        string alias = '';
        Account customer = [select Id, Name, PersonContactId, FirstName, Country_Code__c, LastName, PersonEmail, Phone, Customer_Category_AGN__c, Customer_Sub_Category_AGN__c from Account where Id =: customerAccountId limit 1];
        OAM_User_Settings__c allDetails = OAM_User_Settings__c.getInstance(customer.Country_Code__c);
        User customerUser = new User();
        if(customer.Country_Code__c == 'CA'){
            if(String.isNotBlank(selectedUserLocale)){
                if(selectedUserLocale.containsIgnoreCase('en')){
                    customerUser.LanguageLocaleKey = 'en_US';
                    customerUser.LocalesIdKey = 'en_CA';
                }else if(selectedUserLocale.containsIgnoreCase('fr')){
                    customerUser.LanguageLocaleKey = 'fr';
                    customerUser.LocalesIdKey = 'fr_CA'; 
                }
            }else{
                customerUser.LanguageLocaleKey = allDetails.User_Language__c;
                customerUser.LocalesIdKey = allDetails.User_Locale__c; 
            }
        }else{
            customerUser.LanguageLocaleKey = allDetails.User_Language__c;
            customerUser.LocalesIdKey = allDetails.User_Locale__c; 
        }
        
        
        try {
            /*if (customer.FirstName.length() > 0) {
                alias += customer.FirstName.substring(0, 1);
            }
            if (customer.LastName.length() > 0) {
                //alias += customer.LastName.substring(0,Math.min(customer.LastName.length(), 7));
                alias += customer.LastName.substring(0, Math.min(customer.LastName.length(), 4));
            }
            
            // Alias uniqueness handling
            
            integer existingUserCount = [SELECT COUNT() FROM User WHERE SMB_Alias_External_Id__c LIKE: alias + '%'];
            if (existingUserCount > 0) {
                alias += existingUserCount;
            }*/
            
            alias = generateRandomString(8);
            
            customerUser.Email = customer.PersonEmail.toLowercase();
            customerUser.Phone = customer.Phone;
            customerUser.FirstName = customer.FirstName;
            customerUser.LastName = customer.LastName;
            customerUser.Alias = alias;
            customerUser.EmailEncodingKey = 'UTF-8';
            customerUser.TimezonesIdKey = allDetails.User_Timezone__c;
            customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: allDetails.User_Profile__c limit 1].Id;
            customerUser.UserName = customer.PersonEmail.toLowercase() + '.' + AGN_OAMConstant.USERNAME_SUFFIX;
            customerUser.ContactId = customer.PersonContactId;
            customerUser.Country_Code__c = customer.Country_Code__c;
            customerUser.Division = customer.Customer_Sub_Category_AGN__c;
            customerUser.FederationIdentifier = customer.PersonEmail.toLowercase(); //SSO Mapping
             //------CheckMarx--Added on 25/07/2020----------      
            List<User> tempuserList = new List<User>();
            tempuserList.add(customerUser);
            /*SObjectAccessDecision decisionOnCrUsr = Security.stripInaccessible(AccessType.CREATABLE,tempuserList);
            if(decisionOnCrUsr.getRemovedFields().get('User')!=null){
                throw new AGN_CommonException('Error: Insufficient Create Access On User [Class Name: AGN_OAMCustomerRegUtils and Method Name: createCommunityUser]');
            }
            else{
                 insert customerUser;
            }*/
            String objCRUser = 'User';
            SObjectType CRUserObjType = ((SObject)(Type.forName('Schema.'+objCRUser).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempuserList,CRUserObjType,'INSERT');
            insert customerUser;
            //-------------------------
           
            
            system.debug('@@@@@ customerUser @@@@'+customerUser);
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
        return customerUser.Id;
    }
    
    public static Id createNewCustomerRegistration
        (Allergan_Customer_Registration_AGN__c customer,
         Allergan_Customer_Address_AGN__c customerAddress,
         List < Customer_Type_Configuration_AGN__c > configList,
         Account customerAccount) {
             
             Savepoint sp = Database.setSavepoint();
             Case caseNewCr = new Case();
             try {
                 
                 //create case
                 caseNewCr.Service_AGN__c = 'Customer Registration';
                 caseNewCr.Type = 'New';
                 caseNewCr.Reason = 'New Customer Registration';
                 caseNewCr.Priority = 'Medium';
                 caseNewCr.Origin = 'Web';
                 caseNewCr.Status = 'New';
                 caseNewCr.Subject = customerAddress.Company_Name_AGN__c + ' - ' + caseNewCr.Type;
                 caseNewCr.ContactId = customerAccount.PersonContactId;
                 caseNewCr.AccountId = customerAccount.Id;
                 caseNewCr.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case'
                                           AND DeveloperName = 'AGN_Support_Request_Customer_Registration'
                                           LIMIT 1
                                          ][0].Id;
                 caseNewCr.SuppliedName = customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c;
                 caseNewCr.SuppliedEmail = customer.Email_AGN__c;
                 caseNewCr.SuppliedPhone = customer.Phone_AGN__c;
                 caseNewCr.Case_Sub_Status_AGN__c = 'Online Registration - In Progress';
                 //------CheckMarx--Added on 25/07/2020----------      
                 List<Case> tempCrCsList = new List<Case>();
                 tempCrCsList.add(caseNewCr);
                /* SObjectAccessDecision decisionOnCRCs = Security.stripInaccessible(AccessType.CREATABLE,tempCrCsList);
                 if(decisionOnCRCs.getRemovedFields().get('Case')!=null){
                     throw new AGN_CommonException('Error: Insufficient Create Access On Case [Class Name: AGN_OAMCustomerRegUtils and Method Name: createNewCustomerRegistration]');
                 }
                 else{
                    insert caseNewCr;
                 }*/
                 String objCRCase = 'Case';
                 SObjectType CsObjType = ((SObject)(Type.forName('Schema.'+objCRCase).newInstance())).getSObjectType();
                 AGN_FLSCheck.check(tempCrCsList,CsObjType,'INSERT');
                 insert caseNewCr;
                 //---------------------------------------------
                 
                 
                 system.debug('@@@@@ caseNewCr @@@@'+caseNewCr);
                 
                 //create customer registration
                 customer.Online_Registration_Step_AGN__c = '2';
                 customer.Online_Registration_AGN__c = true;
                 customer.Language_AGN__c = AGN_OAMConstant.USER_LANGUAGE;
                 customer.Case_AGN__c = caseNewCr.Id;
                 customer.Account_AGN__c = customerAccount.Id;
                 customer.Trigger_Validation_of_Children__c = false;
                 customer.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c'
                                          AND DeveloperName = 'New'
                                          LIMIT 1
                                         ][0].Id;
                 mapCustomerType(configList, customerAddress, customer);
                 customer.OwnerId = AGN_OAMConstant.OWNER_ID;
                 customer.Processed_By_SAP_AGN__c = 'In Progress';
                 customer.Allergan_Direct_Access_Requested_AGN__c = true; //Allergan Direct enablement
                 //------CheckMarx--Added on 25/07/2020----------
                 List<Allergan_Customer_Registration_AGN__c> tempCrRegList = new List<Allergan_Customer_Registration_AGN__c>(); 
                 tempCrRegList.add(customer);
                 /*SObjectAccessDecision decisionOnCRReg = Security.stripInaccessible(AccessType.CREATABLE,tempCrRegList);
                 if(decisionOnCRReg.getRemovedFields().get('Allergan_Customer_Registration_AGN__c')!=null){
                     throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Registration_AGN__c [Class Name: AGN_OAMCustomerRegUtils and Method Name: createNewCustomerRegistration]');
                 }
                 else{
                    insert customer;
                 }*/
                 String objCReg1 = 'Allergan_Customer_Registration_AGN__c';
                 SObjectType CrRegObjType = ((SObject)(Type.forName('Schema.'+objCReg1).newInstance())).getSObjectType();
                 AGN_FLSCheck.check(tempCrRegList,CrRegObjType,'INSERT');
                 insert customer;
                 //--------------------
                
                 
                 system.debug('@@@@@ customer @@@@'+customer);
                 
                 //create sold to address
                 customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                 customerAddress.Parent_AGN__c = customer.Id;
                 customerAddress.Sold_To_AGN__c = true;
                 customerAddress.Ship_To_AGN__c = true;
                 customerAddress.Bill_To_AGN__c = true;
                 customerAddress.Email_AGN__c = customer.Email_AGN__c;
                 customerAddress.Mapping_2_AGN__c = customer.Mapping_1_AGN__c; // invoice email
                 customerAddress.Phone_AGN__c = customer.Phone_AGN__c;
                 customerAddress.Phone_2_AGN__c = customer.Mobile_AGN__c;
                 customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                 customerAddress.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c'
                                                 AND DeveloperName = 'New'
                                                 LIMIT 1
                                                ][0].Id;
                 //------CheckMarx--Added on 25/07/2020----------
                 List<Allergan_Customer_Address_AGN__c> tempCrAddrList = new List<Allergan_Customer_Address_AGN__c>(); 
                 tempCrAddrList.add(customerAddress);
                 /*SObjectAccessDecision decisionOnAddr = Security.stripInaccessible(AccessType.CREATABLE,tempCrAddrList);
                 if(decisionOnAddr.getRemovedFields().get('Allergan_Customer_Address_AGN__c')!=null){
                     throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Address_AGN__c [Class Name: AGN_OAMCustomerRegUtils and Method Name: createNewCustomerRegistration]');
                 }
                 else{
                     insert customerAddress;
                 }*/
                 String objCrAddr = 'Allergan_Customer_Address_AGN__c';
                 SObjectType ACRAddrObjType = ((SObject)(Type.forName('Schema.'+objCrAddr).newInstance())).getSObjectType();
                 AGN_FLSCheck.check(tempCrAddrList,ACRAddrObjType,'INSERT');
                 insert customerAddress;
                 //--------------------
                 
                 
                 system.debug('@@@@@ customerAddress @@@@'+customerAddress);
                 
             } catch (DmlException dx) {
                 
                 // An exception was caught. We need to revert to our Savepoint
                 // This will rollback all successful changes. So, if Case saved successfully
                 // and then Address failed, the Case will be rolled back as well
                 Database.rollback(sp);
                 
                 throw new DmlException(dx.getMessage());
             }
             return caseNewCr.Id;
         }
    
    public static Id createNewCustomerRegistration
        (Allergan_Customer_Registration_AGN__c customer,
         Allergan_Customer_Address_AGN__c customerAddress,
         List < Customer_Type_Configuration_AGN__c > configList,
         Account customerAccount,
         String selectedUserLocale) {
             
             Savepoint sp = Database.setSavepoint();
             Case caseNewCr = new Case();
             try {
                 
                 //create case
                 caseNewCr.Service_AGN__c = 'Customer Registration';
                 caseNewCr.Type = 'New';
                 caseNewCr.Reason = 'New Customer Registration';
                 caseNewCr.Priority = 'Medium';
                 caseNewCr.Origin = 'Web';
                 caseNewCr.Status = 'New';
                 caseNewCr.Subject = customerAddress.Company_Name_AGN__c + ' - ' + caseNewCr.Type;
                 caseNewCr.ContactId = customerAccount.PersonContactId;
                 caseNewCr.AccountId = customerAccount.Id;
                 caseNewCr.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case'
                                           AND DeveloperName = 'AGN_Support_Request_Customer_Registration'
                                           LIMIT 1
                                          ][0].Id;
                 caseNewCr.SuppliedName = customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c;
                 caseNewCr.SuppliedEmail = customer.Email_AGN__c;
                 caseNewCr.SuppliedPhone = customer.Phone_AGN__c;
                 caseNewCr.Case_Sub_Status_AGN__c = 'Online Registration - In Progress';
                 //------CheckMarx--Added on 25/07/2020----------      
                 List<Case> tempCrCsList = new List<Case>();
                 tempCrCsList.add(caseNewCr);
                 /*SObjectAccessDecision decisionOnCRCs = Security.stripInaccessible(AccessType.CREATABLE,tempCrCsList);
                 if(decisionOnCRCs.getRemovedFields().get('Case')!=null){
                     throw new AGN_CommonException('Error: Insufficient Create Access On Case [Class Name: AGN_OAMCustomerRegUtils and Method Name: createNewCustomerRegistration]');
                 }
                 else{
                    insert caseNewCr;
                 }*/
                 String objCRCase = 'Case';
                 SObjectType CsObjType = ((SObject)(Type.forName('Schema.'+objCRCase).newInstance())).getSObjectType();
                 AGN_FLSCheck.check(tempCrCsList,CsObjType,'INSERT');
                 insert caseNewCr;
                 //---------------------------------------------
                 
                 system.debug('@@@@@ caseNewCr @@@@'+caseNewCr);
                 String lang;
                 //create customer registration
                 customer.Online_Registration_Step_AGN__c = '2';
                 customer.Online_Registration_AGN__c = true;
                 if(customerAccount.Country_Code__c.equalsIgnoreCase('CA')){
                     if(!String.isEmpty(selectedUserLocale)){
                         if(selectedUserLocale.containsIgnoreCase('en')){
                             lang = 'en_US';
                         }else if(selectedUserLocale.containsIgnoreCase('fr')){
                             lang = 'fr';
                         }
                         else{
                             lang = AGN_OAMConstant.USER_LANGUAGE;
                         }
                     }
                     else{
                         lang = AGN_OAMConstant.USER_LANGUAGE;
                     }
                 }
                 else{
                     lang = AGN_OAMConstant.USER_LANGUAGE;
                 }
                 customer.Language_AGN__c = lang;
                 customer.Case_AGN__c = caseNewCr.Id;
                 customer.Account_AGN__c = customerAccount.Id;
                 customer.Trigger_Validation_of_Children__c = false;
                 customer.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c'
                                          AND DeveloperName = 'New'
                                          LIMIT 1
                                         ][0].Id;
                 mapCustomerType(configList, customerAddress, customer);
                 customer.OwnerId = AGN_OAMConstant.OWNER_ID;
                 customer.Processed_By_SAP_AGN__c = 'In Progress';
                 customer.Allergan_Direct_Access_Requested_AGN__c = true; //Allergan Direct enablement
                 //------CheckMarx--Added on 25/07/2020----------
                 List<Allergan_Customer_Registration_AGN__c> tempCrRegList = new List<Allergan_Customer_Registration_AGN__c>(); 
                 tempCrRegList.add(customer);
                 /*SObjectAccessDecision decisionOnCRReg = Security.stripInaccessible(AccessType.CREATABLE,tempCrRegList);
                 if(decisionOnCRReg.getRemovedFields().get('Allergan_Customer_Registration_AGN__c')!=null){
                     throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Registration_AGN__c [Class Name: AGN_OAMCustomerRegUtils and Method Name: createNewCustomerRegistration]');
                 }
                 else{
                    insert customer;
                 }*/
                 String objCReg1 = 'Allergan_Customer_Registration_AGN__c';
                 SObjectType CrRegObjType = ((SObject)(Type.forName('Schema.'+objCReg1).newInstance())).getSObjectType();
                 AGN_FLSCheck.check(tempCrRegList,CrRegObjType,'INSERT');
                 insert customer;
                 //--------------------
                
                 
                 system.debug('@@@@@ customer @@@@'+customer);
                 
                 //create sold to address
                 customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                 customerAddress.Parent_AGN__c = customer.Id;
                 customerAddress.Sold_To_AGN__c = true;
                 customerAddress.Ship_To_AGN__c = true;
                 customerAddress.Bill_To_AGN__c = true;
                 customerAddress.Email_AGN__c = customer.Email_AGN__c;
                 customerAddress.Mapping_2_AGN__c = customer.Mapping_1_AGN__c; // invoice email
                 customerAddress.Phone_AGN__c = customer.Phone_AGN__c;
                 customerAddress.Phone_2_AGN__c = customer.Mobile_AGN__c;
                 customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                 customerAddress.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c'
                                                 AND DeveloperName = 'New'
                                                 LIMIT 1
                                                ][0].Id;
                 //------CheckMarx--Added on 25/07/2020----------
                 List<Allergan_Customer_Address_AGN__c> tempCrAddrList = new List<Allergan_Customer_Address_AGN__c>(); 
                 tempCrAddrList.add(customerAddress);
                 /*SObjectAccessDecision decisionOnAddr = Security.stripInaccessible(AccessType.CREATABLE,tempCrAddrList);
                 if(decisionOnAddr.getRemovedFields().get('Allergan_Customer_Address_AGN__c')!=null){
                     throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Address_AGN__c [Class Name: AGN_OAMCustomerRegUtils and Method Name: createNewCustomerRegistration]');
                 }
                 else{
                     insert customerAddress;
                 }*/
                 String objCrAddr = 'Allergan_Customer_Address_AGN__c';
                 SObjectType ACRAddrObjType = ((SObject)(Type.forName('Schema.'+objCrAddr).newInstance())).getSObjectType();
                 AGN_FLSCheck.check(tempCrAddrList,ACRAddrObjType,'INSERT');
                 insert customerAddress;
                 //--------------------
                 
                 
                 system.debug('@@@@@ customerAddress @@@@'+customerAddress);
                 
             } catch (DmlException dx) {
                 
                 // An exception was caught. We need to revert to our Savepoint
                 // This will rollback all successful changes. So, if Case saved successfully
                 // and then Address failed, the Case will be rolled back as well
                 Database.rollback(sp);
                 
                 throw new DmlException(dx.getMessage());
             }
             return caseNewCr.Id;
         }
    @future
    public static void inactivateUser(Id communityUserId) {
        
        User u = [Select IsActive, IsPortalEnabled From User Where Id =: communityUserId];
        u.IsActive = false;
        u.IsPortalEnabled = false;
        //------CheckMarx--Updated on 25/07/2020----------   
        /*if(Schema.sObjectType.User.fields.IsActive.isUpdateable() && Schema.sObjectType.User.fields.IsPortalEnabled.isUpdateable()){
            update u;
        }
        else{
            throw new AGN_CommonException('Error: Insufficient Edit Access On User [Class Name: AGN_OAMCustomerRegUtils and Method Name: inactivateUser]');
        }*/
        List<User> tempuserList = new List<User>();
        tempuserList.add(u);
        String objCRUser = 'User';
        SObjectType CRUserObjType = ((SObject)(Type.forName('Schema.'+objCRUser).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempuserList,CRUserObjType,'UPDATE');
        update u;
        //----------------------------------------------
       
    }
    
    //Check if user exists in Okta else need to create the user and provide access to the Okta group specified and send welcome mail
    //If user is present in Okta (users that do not have a status of DEPROVISIONED), need to check if use has access to Okta apps via groups specified. 
    //If does not have access to that group, need to provide access to that Okta group and send welcome mail
    public static String createOktaUserSendLink(Allergan_Customer_Registration_AGN__c customer, Account customerAccount) {
        
        String returnMessage = 'FAILURE';
        
        String userName = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? customer.Email_AGN__c + '.' + AGN_OAMConstant.USERNAME_SUFFIX : customer.Email_AGN__c;
        
        AGN_OktaUtils oUtil = new AGN_OktaUtils();
        
        //checking if user is present in OKTA
        String okatMessage = oUtil.isPresentInOkta(userName);
        Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
        
        String messagetype = (String) m.get('messagetype');
        
        //messagetype = ERROR -> User not found, need to create the user
        if (messagetype.equalsIgnoreCase('ERROR')) {
            //string oktaPassword = oUtil.generateRandomString(10);    
            string reqBody = '{"profile":' +
                +'{"firstName": "' + customer.First_Name_AGN__c + '",' +
                +'"lastName": "' + customer.Last_Name_AGN__c + '",' +
                +'"email": "' + customer.Email_AGN__c.toLowercase() + '",' +
                +'"login": "' + userName.toLowercase() + '",' +
                +'"countryCode": "' + customer.Country_Code_AGN__c + '",' +
                +'"mobilePhone": "' + customer.Phone_AGN__c + '",' +
                +'"title": "' + customer.Salutation_AGN__c + '",' +
                +'"ad_has_consented_gdpr": "true"' +
                +'},' +
                +'"credentials":{' +
                //+'"password" : '+
                //+'{"value": "'+ oktaPassword +'"'+
                //+'},'+
                +'"recovery_question":' +
                +'{"question": "' + AGN_OAMConstant.DEFAULT_OKTA_RECOVERY_QUETION + '","answer": "' + AGN_OAMConstant.DEFAULT_OKTA_RECOVERY_ANSWER + '"' +
                +'}' +
                +'},' +
                +'"groupIds": [' + AGN_OAMConstant.OKTASFCOMMUNITYGROUPID + ']}';
            
            String userCreateMsg = oUtil.CreateUser(reqBody);
            Map < String, Object > userCreateMsgMap = (Map < String, Object > ) JSON.deserializeUntyped(userCreateMsg);
            
            if (String.valueOf(userCreateMsgMap.get('messagetype')).equalsIgnoreCase('SUCCESS')) {
                returnMessage = 'SUCCESS';
                String userOktaId = String.valueOf(userCreateMsgMap.get('Id'));
                if (!String.isEmpty(userOktaId)) {
                    Account acc = [Select Okta_Id_AGN__c From Account Where Id =: customerAccount.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    //----------Checkmarx Fix ---Added on 03-08-2020---------
                    List<Account> crAccList1 = new List<Account>();
                    crAccList1.add(acc);
                    String objCrAcc1 = 'Account';
                    SObjectType objCrAccType1 = ((SObject)(Type.forName('Schema.'+objCrAcc1).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(crAccList1,objCrAccType1,'UPDATE');
                    update acc;
                    //------------------------------------------------
                   
                }
                SendExpiryLinkChangePassword(customer, customerAccount);
            }
        }
        //User found
        else {
            String userOktatatus = (String) m.get('Status');
            String userOktaId = (String) m.get('Id');
            //Not inactive (DEPROVISIONED)
            if (!userOktatatus.equalsignorecase('DEPROVISIONED')) {
                oUtil.AddUserToGroup(AGN_OAMConstant.OKTASFCOMMUNITYGROUPID, userOktaId);
                returnMessage = 'SUCCESS';
                if (!String.isEmpty(userOktaId)) {
                    Account acc = [Select Okta_Id_AGN__c From Account Where Id =: customerAccount.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    //----------Checkmarx Fix ---Added on 03-08-2020---------
                    List<Account> crAccList = new List<Account>();
                    crAccList.add(acc);
                    String objCrAcc = 'Account';
                    SObjectType objCrAccType = ((SObject)(Type.forName('Schema.'+objCrAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(crAccList,objCrAccType,'UPDATE');
                    update acc;
                    //------------------------------------------------
                    
                }
                SendExpiryLinkChangePassword(customer, customerAccount);
            } else {
                returnMessage = 'DEPROVISIONED';
            }
        }
        
        return returnMessage;
    }
    
    public static String createOktaUserSendLink(Allergan_Customer_Registration_AGN__c customer, Account customerAccount, String userLocale) {
        
        String returnMessage = 'FAILURE';
        
        String userName = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? customer.Email_AGN__c + '.' + AGN_OAMConstant.USERNAME_SUFFIX : customer.Email_AGN__c;
        
        AGN_OktaUtils oUtil = new AGN_OktaUtils();
        
        //checking if user is present in OKTA
        String okatMessage = oUtil.isPresentInOkta(userName);
        Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
        
        String messagetype = (String) m.get('messagetype');
        
        //messagetype = ERROR -> User not found, need to create the user
        if (messagetype.equalsIgnoreCase('ERROR')) {
            //string oktaPassword = oUtil.generateRandomString(10);    
            string reqBody = '{"profile":' +
                +'{"firstName": "' + customer.First_Name_AGN__c + '",' +
                +'"lastName": "' + customer.Last_Name_AGN__c + '",' +
                +'"email": "' + customer.Email_AGN__c.toLowercase() + '",' +
                +'"login": "' + userName.toLowercase() + '",' +
                +'"countryCode": "' + customer.Country_Code_AGN__c + '",' +
                +'"mobilePhone": "' + customer.Phone_AGN__c + '",' +
                +'"title": "' + customer.Salutation_AGN__c + '",' +
                +'"ad_has_consented_gdpr": "true"' +
                +'},' +
                +'"credentials":{' +
                //+'"password" : '+
                //+'{"value": "'+ oktaPassword +'"'+
                //+'},'+
                +'"recovery_question":' +
                +'{"question": "' + AGN_OAMConstant.DEFAULT_OKTA_RECOVERY_QUETION + '","answer": "' + AGN_OAMConstant.DEFAULT_OKTA_RECOVERY_ANSWER + '"' +
                +'}' +
                +'},' +
                +'"groupIds": [' + AGN_OAMConstant.OKTASFCOMMUNITYGROUPID + ']}';
            
            String userCreateMsg = oUtil.CreateUser(reqBody);
            Map < String, Object > userCreateMsgMap = (Map < String, Object > ) JSON.deserializeUntyped(userCreateMsg);
            
            if (String.valueOf(userCreateMsgMap.get('messagetype')).equalsIgnoreCase('SUCCESS')) {
                returnMessage = 'SUCCESS';
                String userOktaId = String.valueOf(userCreateMsgMap.get('Id'));
                if (!String.isEmpty(userOktaId)) {
                    Account acc = [Select Okta_Id_AGN__c From Account Where Id =: customerAccount.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    //------CheckMarx--Updated on 25/07/2020----------   
                    /*if(Schema.sObjectType.Account.fields.Okta_Id_AGN__c.isUpdateable()){
                        update acc;
                    }
                    else{
                        throw new AGN_CommonException('Error: Insufficient Edit Access On Account [Class Name: AGN_OAMCustomerRegUtils and Method Name: createOktaUserSendLink]');
                    }  */
                    List<Account> accList = new List<Account>();
                    accList.add(acc);
                    String objAcc = 'Account';
                    SObjectType AccObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(accList,AccObjType,'UPDATE');
                    update acc;
                    //----------------------------------------------
                }
                SendExpiryLinkChangePassword(customer, customerAccount, userLocale);
            }
        }
        //User found
        else {
            String userOktatatus = (String) m.get('Status');
            String userOktaId = (String) m.get('Id');
            //Not inactive (DEPROVISIONED)
            if (!userOktatatus.equalsignorecase('DEPROVISIONED')) {
                oUtil.AddUserToGroup(AGN_OAMConstant.OKTASFCOMMUNITYGROUPID, userOktaId);
                returnMessage = 'SUCCESS';
                if (!String.isEmpty(userOktaId)) {
                    Account acc = [Select Okta_Id_AGN__c From Account Where Id =: customerAccount.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    //------CheckMarx--Updated on 25/07/2020----------   
                    /*if(Schema.sObjectType.Account.fields.Okta_Id_AGN__c.isUpdateable()){
                        update acc;
                    }
                    else{
                        throw new AGN_CommonException('Error: Insufficient Edit Access On Account [Class Name: AGN_OAMCustomerRegUtils and Method Name: createOktaUserSendLink]');
                    }*/ 
                    List<Account> accList1 = new List<Account>();
                    accList1.add(acc);
                    String objAcc1 = 'Account';
                    SObjectType Acc1ObjType = ((SObject)(Type.forName('Schema.'+objAcc1).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(accList1,Acc1ObjType,'UPDATE');
                    update acc;
                    //----------------------------------------------
                }
                SendExpiryLinkChangePassword(customer, customerAccount, userLocale);
            } else {
                returnMessage = 'DEPROVISIONED';
            }
        }
        
        return returnMessage;
    }
    @Testvisible
    private static void updateOktaUserIdInAccount(Account customerAccount, String oktaUserId, String passwordResetToken) {
        
        Account acc = [Select Okta_Id_AGN__c, Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccount.Id];
        if (!String.isEmpty(oktaUserId)) {
            acc.Okta_Id_AGN__c = oktaUserId;
        }
        if (!String.isEmpty(passwordResetToken)) {
            acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        }
        //------CheckMarx--Added on 24/07/2020----------      
        List<Account> tempAcList = new List<Account>();
        tempAcList.add(acc);
       /* SObjectAccessDecision decisionOnAc = Security.stripInaccessible(AccessType.UPDATABLE,tempAcList);
        if(decisionOnAc.getRemovedFields().get('Account')!=null){
            throw new AGN_CommonException('Error: Insufficient Edit Access On Account [Class Name: AGN_OAMCustomerRegUtils and Method Name: updateOktaUserIdInAccount]');
        }
        else{
            update acc;
        }*/
        String objAcc1 = 'Account';
        SObjectType Acc1ObjType = ((SObject)(Type.forName('Schema.'+objAcc1).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempAcList,Acc1ObjType,'UPDATE');
        update acc;
        //--------------------
    }
    @Testvisible
    private static void updateOktaUserIdInAccount(Id customerAccountId, String oktaUserId, String passwordResetToken) {
        
        Account acc = [Select Okta_Id_AGN__c, Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccountId];
        if (!String.isEmpty(oktaUserId)) {
            acc.Okta_Id_AGN__c = oktaUserId;
        }
        if (!String.isEmpty(passwordResetToken)) {
            acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        }
        //------CheckMarx--Added on 24/07/2020----------      
        List<Account> tempAcList = new List<Account>();
        tempAcList.add(acc);
        /*SObjectAccessDecision decisionOnAc = Security.stripInaccessible(AccessType.UPDATABLE,tempAcList);
        if(decisionOnAc.getRemovedFields().get('Account')!=null){
            throw new AGN_CommonException('Error: Insufficient Edit Access On Account [Class Name: AGN_OAMCustomerRegUtils and Method Name: updateOktaUserIdInAccount]');
        }
        else{
            update acc;
        }*/
        String objAcc1 = 'Account';
        SObjectType Acc1ObjType = ((SObject)(Type.forName('Schema.'+objAcc1).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempAcList,Acc1ObjType,'UPDATE');
        update acc;
        //--------------------
        
    }
    
    public static void SendExpiryLinkChangePassword(Allergan_Customer_Registration_AGN__c customer, Account customerAccount) {
        String dataToEncrypt;
        String encryptedData;
        String privateKey = AGN_OAMConstant.PRIVATEKEY; //config
        
        AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
        
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(AGN_OAMConstant.TOKENVALIDTILL));
        
        String passwordResetToken = cUtil.getRandomKey();
        
        dataToEncrypt = '{' +
            +'"portalusername": "' + customer.Email_AGN__c + '.' + AGN_OAMConstant.USERNAME_SUFFIX + '",' +
            +'"portaluseremail": "' + customer.Email_AGN__c + '",' +
            +'"countrycode": "' + AGN_OAMConstant.USERCOUNTRYCODE + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        //updateOktaUserIdInAccount(customerAccount, '', passwordResetToken);
        
        //Update generated password reset token with the Account/Customer
        Account acc = [Select Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccount.Id];
        acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        //------CheckMarx--Updated on 25/07/2020----------   
       /* if(Schema.sObjectType.Account.fields.Community_Okta_Password_Reset_Token_AGN__c.isUpdateable()){
            update acc;
        }
        else{
            throw new AGN_CommonException('Error: Insufficient Edit Access On Account [Class Name: AGN_OAMCustomerRegUtils and Method Name: SendExpiryLinkChangePassword]');
        } */ 
        List<Account> tempAcList = new List<Account>();
        tempAcList.add(acc);
        String objAcc1 = 'Account';
        SObjectType Acc1ObjType = ((SObject)(Type.forName('Schema.'+objAcc1).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempAcList,Acc1ObjType,'UPDATE');
        update acc;
        //----------------------------------------------
       
        
        String userName = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? customer.Email_AGN__c + '.' + AGN_OAMConstant.USERNAME_SUFFIX : customer.Email_AGN__c;
        //SendMail(customer.First_Name_AGN__c, userName, customer.Email_AGN__c, encryptedData);
        SendWelcomeMail(customer, encryptedData);  
    }
    public static void SendExpiryLinkChangePassword(Allergan_Customer_Registration_AGN__c customer, Account customerAccount, String userLocale) {
        String dataToEncrypt;
        String encryptedData;
        String privateKey = AGN_OAMConstant.PRIVATEKEY; //config
        
        AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
        
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(AGN_OAMConstant.TOKENVALIDTILL));
        
        String passwordResetToken = cUtil.getRandomKey();
        
        dataToEncrypt = '{' +
            +'"portalusername": "' + customer.Email_AGN__c + '.' + AGN_OAMConstant.USERNAME_SUFFIX + '",' +
            +'"portaluseremail": "' + customer.Email_AGN__c + '",' +
            +'"countrycode": "' + AGN_OAMConstant.USERCOUNTRYCODE + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        //updateOktaUserIdInAccount(customerAccount, '', passwordResetToken);
        
        //Update generated password reset token with the Account/Customer
        Account acc = [Select Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccount.Id];
        acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        //------CheckMarx--Updated on 25/07/2020----------   
        /*if(Schema.sObjectType.Account.fields.Community_Okta_Password_Reset_Token_AGN__c.isUpdateable()){
             update acc;
        }
        else{
            throw new AGN_CommonException('Error: Insufficient Edit Access On Account [Class Name: AGN_OAMCustomerRegUtils and Method Name: SendExpiryLinkChangePassword]');
        } */ 
        List<Account> tempAcList = new List<Account>();
        tempAcList.add(acc);
        String objAcc1 = 'Account';
        SObjectType Acc1ObjType = ((SObject)(Type.forName('Schema.'+objAcc1).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempAcList,Acc1ObjType,'UPDATE');
        update acc;
        //----------------------------------------------
      
        
        String userName = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? customer.Email_AGN__c + '.' + AGN_OAMConstant.USERNAME_SUFFIX : customer.Email_AGN__c;
        //SendMail(customer.First_Name_AGN__c, userName, customer.Email_AGN__c, encryptedData);
        SendWelcomeMail(customer, encryptedData, userLocale);  
    }
    public static void SendWelcomeMail(Allergan_Customer_Registration_AGN__c customer, String encryptedData){
        Decimal expirationInDays = 0;
        String accepteddate;
        //AGN_OAMConstant.TOKENVALIDTILL/24; 
        
        if(customer.Country_Code_AGN__c.equalsIgnoreCase('FR')){
            expirationInDays = AGN_OAMConstant.TOKENVALIDTILL;
            accepteddate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('dd MMM YYYY');
        }
        else{
            expirationInDays = AGN_OAMConstant.TOKENVALIDTILL/24;
            accepteddate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd');
        }
        
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.First_Name_AGN__c,
                '{!Recipient.LastName}' => customer.Last_Name_AGN__c,
                '{!Recipient.Email}' => customer.Email_AGN__c,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => accepteddate,
                '{!ExpiryLink}' => AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_CustomerPortalOktaForceChgPWD?token=' + encryptedData
                };
                    
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email_AGN__c, null, null, null, mapSubjectParams, null, mapBodyParams));
        
        String senderEmailAddress = AGN_OAMConstant.SENDEREMAILADDRESS;
        if(listEmailMessageWrapper.size() > 0){
            //second parameter of sendEmail() is email template name (e.g: Self Registration: Welcome Email-DE)
            System.debug('####Language Code #### '+ AGN_OAMConstant.USER_LANGUAGE.toUpperCase());
            System.debug('####email template name #### '+ 'Self Registration: Welcome Email-'+ AGN_OAMConstant.USER_LANGUAGE.toUpperCase());
            sendEmail(listEmailMessageWrapper, 'Self Registration: Welcome Email-'+ AGN_OAMConstant.USER_LANGUAGE.toUpperCase(), senderEmailAddress);
        }
    }
    public static void SendWelcomeMail(Allergan_Customer_Registration_AGN__c customer, String encryptedData, String userLocale){
        
        Decimal expirationInDays = AGN_OAMConstant.TOKENVALIDTILL/24; 
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        
        String lang;
        System.debug('SendWelcomeMail -- customer.Country_Code_AGN__c ->' +customer.Country_Code_AGN__c);
        System.debug('SendWelcomeMail -- userLocale ->' +userLocale);
        if(customer.Country_Code_AGN__c.equalsIgnoreCase('CA')){
            if(!String.isEmpty(userLocale)){
                if(userLocale.containsIgnoreCase('en')){
                    lang = 'en_US';
                }else if(userLocale.containsIgnoreCase('fr')){
                    lang = 'fr';
                }
                else{
                    lang = AGN_OAMConstant.USER_LANGUAGE;
                }
            }
            else{
                lang = AGN_OAMConstant.USER_LANGUAGE;
            }
        }
        else{
            lang = AGN_OAMConstant.USER_LANGUAGE;
        }
        
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.First_Name_AGN__c,
                '{!Recipient.LastName}' => customer.Last_Name_AGN__c,
                '{!Recipient.Email}' => customer.Email_AGN__c,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd'),
                '{!ExpiryLink}' => AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_CustomerPortalOktaForceChgPWD?token=' + encryptedData + '&language='+lang
                };
                    
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email_AGN__c, null, null, null, mapSubjectParams, null, mapBodyParams));   
        
        String senderEmailAddress = AGN_OAMConstant.SENDEREMAILADDRESS;
        if(listEmailMessageWrapper.size() > 0){
            //second parameter of sendEmail() is email template name (e.g: Self Registration: Welcome Email-DE)
            
            //System.debug('####senderEmailAddress #### '+ senderEmailAddress);
            //System.debug('####email template name #### '+ 'Self Registration: Welcome Email-'+ lang.toUpperCase());
            sendEmail(listEmailMessageWrapper, 'Self Registration: Welcome Email-'+ lang.toUpperCase(), senderEmailAddress);
        }
    }
    public static void forgotRecoveryQA(User customer) {
        String dataToEncrypt;
        String encryptedData;
        
        String privateKey = AGN_OAMConstant.PRIVATEKEY; //config
        
        AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
        
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(AGN_OAMConstant.TOKENVALIDTILL));
        
        String passwordResetToken = cUtil.getRandomKey();
        
        dataToEncrypt = '{' +
            +'"portalusername": "' + customer.Email + '.' + AGN_OAMConstant.USERNAME_SUFFIX + '",' +
            +'"portaluseremail": "' + customer.Email + '",' +
            +'"countrycode": "' + AGN_OAMConstant.USERCOUNTRYCODE + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        updateOktaUserIdInAccount(customer.Account.Id, '', passwordResetToken);
        
        SendMailForgotRecoveryQA(customer, encryptedData);  
    }
    
    public static void forgotRecoveryQA(User customer, Boolean hasOktaRecoveryQuestion) {
        String dataToEncrypt;
        String encryptedData;
        
        String privateKey = AGN_OAMConstant.PRIVATEKEY; //config
        
        AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
        
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(AGN_OAMConstant.TOKENVALIDTILL));
        
        String passwordResetToken = cUtil.getRandomKey();
        
        dataToEncrypt = '{' +
            +'"portalusername": "' + customer.Email + '.' + AGN_OAMConstant.USERNAME_SUFFIX + '",' +
            +'"portaluseremail": "' + customer.Email + '",' +
            +'"countrycode": "' + AGN_OAMConstant.USERCOUNTRYCODE + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        updateOktaUserIdInAccount(customer.Account.Id, '', passwordResetToken);
        
        SendMailForgotRecoveryQA(customer, encryptedData, hasOktaRecoveryQuestion);  
    }
    
    public static void SendMailForgotRecoveryQA(User customer, String encryptedData) {
        
        Decimal expirationInDays = AGN_OAMConstant.TOKENVALIDTILL/24; 
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.FirstName,
                '{!Recipient.LastName}' => customer.LastName,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!ExpiryLink}' => AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_CustomerPortalOktaForceChgPWD?token=' + encryptedData + '&r=true&language='+customer.LanguageLocaleKey
                };
                    
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email, null, null, null, mapSubjectParams, null, mapBodyParams));
        String senderEmailAddress = AGN_OAMConstant.SENDEREMAILADDRESS;
        if(listEmailMessageWrapper.size() > 0){
            //second parameter is email template name (e.g: Self Registration: Reset Security Q&A Email-DE)
            sendEmail(listEmailMessageWrapper, 'Self Registration: Reset Security Q&A Email-'+ AGN_OAMConstant.USER_LANGUAGE.toUpperCase(), senderEmailAddress);
        }
    }
    
    public static void SendMailForgotRecoveryQA(User customer, String encryptedData, Boolean hasOktaRecoveryQuestion) {
        
        Decimal expirationInDays = AGN_OAMConstant.TOKENVALIDTILL/24; 
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        String expiryLink;
        
        if(hasOktaRecoveryQuestion){
           expiryLink = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_CustomerPortalOktaForceChgPWD?token=' + encryptedData + '&r=true&language='+customer.LanguageLocaleKey;
        }
        else{
            expiryLink = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_CustomerPortalOktaForceChgPWD?token=' + encryptedData + '&language='+customer.LanguageLocaleKey;
        }
        
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.FirstName,
                '{!Recipient.LastName}' => customer.LastName,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!ExpiryLink}' => expiryLink
                };
                    
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email, null, null, null, mapSubjectParams, null, mapBodyParams));
        String senderEmailAddress = AGN_OAMConstant.SENDEREMAILADDRESS;
        if(listEmailMessageWrapper.size() > 0){
            //second parameter is email template name (e.g: Self Registration: Reset Security Q&A Email-DE)
            sendEmail(listEmailMessageWrapper, 'Self Registration: Reset Security Q&A Email-'+ AGN_OAMConstant.USER_LANGUAGE.toUpperCase(), senderEmailAddress);
        }
    }
    public static Id upsertAddressDetails(Allergan_Customer_Address_AGN__c soldToAddr,
                                          List < Allergan_Customer_Address_AGN__c > billToAddrList,
                                          List < Allergan_Customer_Address_AGN__c > shipToAddrList,
                                          List < Allergan_Customer_Address_AGN__c > newBillToAddrList,
                                          List < Allergan_Customer_Address_AGN__c > newShipToAddrList
                                         ) 
    {
        system.debug('billToAddrList-->' + billToAddrList.size());
        system.debug('shipToAddrList-->' + shipToAddrList.size());
        
        Allergan_Customer_Registration_AGN__c customer = AGN_OAMCustomerRegStep2Controller.getCustomerRegDetails();
        
        system.debug('customer-->' + customer);
        
        Id addressRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c'
                                  AND DeveloperName = 'New'
                                  LIMIT 1
                                 ][0].Id;
        
        Case caseNewCr = [SELECT Id, Type, RecordType.Name, Case_Sub_Status_AGN__c, EntitlementId, OwnerId FROM Case WHERE Id =: customer.Case_AGN__c];
        try {
            
            Id soldToId = soldToAddr.Id;
            
            List < Allergan_Customer_Address_AGN__c > addList = new List < Allergan_Customer_Address_AGN__c > ();
            //Country_AGN__c = customer.Country_AGN__r.AGN_Country_Name__c, Country_Lookup_AGN__c = customer.Country_AGN__c
            //billto
            soldToAddr.Customer_Group_AGN__c = customer.Customer_Group_AGN__c;
            addList.add(soldToAddr);
            
            //billto
            system.debug('billToAddrList-->' + billToAddrList.size());
            for (Allergan_Customer_Address_AGN__c customerAddress: billToAddrList) {
                if(soldToId != customerAddress.Id){
                    customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                    if (String.isBlank(customerAddress.Parent_AGN__c)) {
                        customerAddress.Parent_AGN__c = customer.Id;
                    }
                    customerAddress.RecordTypeId = addressRecordTypeId;
                    if(customer.Country_Code_AGN__c != 'IT'){
                        customerAddress.Country_AGN__c = customer.Country_AGN__r.AGN_Country_Name__c;  
                    }                    
                    customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                    customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    addList.add(customerAddress);
                }
            }
            
            //shipto
            system.debug('shipToAddrList-->' + shipToAddrList.size());
            for (Allergan_Customer_Address_AGN__c customerAddress: shipToAddrList) {
                if(soldToId != customerAddress.Id){
                    customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                    if (String.isBlank(customerAddress.Parent_AGN__c)) {
                        customerAddress.Parent_AGN__c = customer.Id;
                    }
                    customerAddress.RecordTypeId = addressRecordTypeId;
                    if(customer.Country_Code_AGN__c != 'IT'){
                        customerAddress.Country_AGN__c = customer.Country_AGN__r.AGN_Country_Name__c;
                    }                  
                    customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                    customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    addList.add(customerAddress);
                }
            }
            
            //new billto
            system.debug('newBillToAddrList-->' + newBillToAddrList.size());
            for (Allergan_Customer_Address_AGN__c customerAddress: newBillToAddrList) {
                customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                if (String.isBlank(customerAddress.Parent_AGN__c)) {
                    customerAddress.Parent_AGN__c = customer.Id;
                }
                customerAddress.RecordTypeId = addressRecordTypeId;
                if(customer.Country_Code_AGN__c != 'IT'){
                    customerAddress.Country_AGN__c = customer.Country_AGN__r.AGN_Country_Name__c;
                }    
                customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                addList.add(customerAddress);
            }
            
            //new shipto
            system.debug('newShipToAddrList-->' + newShipToAddrList.size());
            for (Allergan_Customer_Address_AGN__c customerAddress: newShipToAddrList) {
                customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                if (customerAddress.Parent_AGN__c == null || String.isEmpty(customerAddress.Parent_AGN__c)) {
                    customerAddress.Parent_AGN__c = customer.Id;
                }
                customerAddress.RecordTypeId = addressRecordTypeId;
                if(customer.Country_Code_AGN__c != 'IT'){
                    customerAddress.Country_AGN__c = customer.Country_AGN__r.AGN_Country_Name__c;
                }
                customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                addList.add(customerAddress);
            }
            system.debug('ListcustomerAddress-->' + addList.size());
            system.debug('newShipToAddrList-->' + addList);
            if (!addList.isEmpty()) {
                
                //Database.UpsertResult[] rs = Database.upsert(addList, true);           
                //system.debug('rs@@@@@-->'+rs.size());
                //----------Checkmarx Fix ---Added on 03-08-2020---------
                String objCrAddr = 'Allergan_Customer_Address_AGN__c';
                SObjectType objCrAddrType = ((SObject)(Type.forName('Schema.'+objCrAddr).newInstance())).getSObjectType();
                AGN_FLSCheck.check(addList,objCrAddrType,'UPSERT');
                upsert addList;
                //------------------------------------------
               
                if (customer.Online_Registration_Step_AGN__c == '2') {
                    customer.Online_Registration_Step_AGN__c = '3';
                    //----------Checkmarx Fix ---Added on 03-08-2020---------
                    List<Allergan_Customer_Registration_AGN__c> crRegList = new List<Allergan_Customer_Registration_AGN__c>();
                    crRegList.add(customer);
                    String objCrReg = 'Allergan_Customer_Registration_AGN__c';
                    SObjectType objCrRegType = ((SObject)(Type.forName('Schema.'+objCrReg).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(crRegList,objCrRegType,'UPDATE');
                    update customer;
                    //------------------------------------------------
                }
            }
        } catch (DmlException dx) {
            
            throw new DmlException(dx.getMessage());
        }
        return caseNewCr.Id;
    }
    
    public static Boolean updateAddressDetails(List <Allergan_Customer_Address_AGN__c> records) 
    {       
        try {
            
            //List <Allergan_Customer_Address_AGN__c> addList = new List <Allergan_Customer_Address_AGN__c> (); 
            system.debug('records -->' + records);         
            if (!records.isEmpty()) {
                
                //----------Checkmarx Fix ---Added on 03-08-2020---------
                String objCrAddr = 'Allergan_Customer_Address_AGN__c';
                SObjectType objCrAddrType = ((SObject)(Type.forName('Schema.'+objCrAddr).newInstance())).getSObjectType();
                AGN_FLSCheck.check(records,objCrAddrType,'UPDATE');
                update records;
                //------------------------------------------
            }
        } catch (DmlException dx) {
            
            throw new DmlException(dx.getMessage());
        }
        return true;
    }
    public static Id upsertCustomerDetails(Allergan_Customer_Registration_AGN__c customer, Allergan_Customer_Address_AGN__c customerAddress, String Specialty) {
        Allergan_Customer_Registration_AGN__c customerOld = AGN_OAMCustomerRegStep2Controller.getCustomerRegDetails();
        
        system.debug('customerOld -->' + customerOld);
        
        List<Specialty_Allergan_AGN__c> sp;
        
        system.debug('Specialty-->' + Specialty);
        
        if(!String.isBlank(Specialty)){
            sp = [SELECT ID FROM Specialty_Allergan_AGN__c WHERE Translated_Value_AGN__c =:Specialty AND Country_code_AGN__c =:customerOld.Country_Code_AGN__c limit 1];
        }
        
        Case caseNewCr = [SELECT Id, Type, RecordType.Name, Case_Sub_Status_AGN__c, 
                          EntitlementId, OwnerId FROM Case WHERE Id =: customerOld.Case_AGN__c];
        try {
            
            if (customerOld.Online_Registration_Step_AGN__c == '3') {
                
                customerOld.Online_Registration_Step_AGN__c = '4';
            }
            customerOld.VAT_AGN__c = customer.VAT_AGN__c;
            customerOld.Registration_License_Number_AGN__c = customer.Registration_License_Number_AGN__c;
            customerOld.Physician_Registration_Reference_AGN__c = customer.Physician_Registration_Reference_AGN__c;            
            if(!String.isBlank(Specialty) && !sp.isEmpty()){
                customerOld.Specialty_Allergan_1_AGN__c = sp[0].Id;
            }else{
                customerOld.Specialty_Allergan_1_AGN__c = null;                
            }
            
            //if(customer.Tax_Exempted_AGN__c == null){                
            if(String.isEmpty(customer.Tax_Exempted_AGN__c)){
                customerOld.Tax_Exempted_AGN__c = '9';
            }else{
                customerOld.Tax_Exempted_AGN__c = customer.Tax_Exempted_AGN__c;  
            }
            //----------Checkmarx Fix ---Added on 03-08-2020---------
            List<Allergan_Customer_Registration_AGN__c> crRegList = new List<Allergan_Customer_Registration_AGN__c>();
            crRegList.add(customerOld);
            String objCrReg = 'Allergan_Customer_Registration_AGN__c';
            SObjectType objCrRegType = ((SObject)(Type.forName('Schema.'+objCrReg).newInstance())).getSObjectType();
            AGN_FLSCheck.check(crRegList,objCrRegType,'UPDATE');
            update customerOld;
            //------------------------------------------------
            
           
            
            
            list<Allergan_Customer_Address_AGN__c> customerAddressOldList = [SELECT Id, Name, VAT_Number_AGN__c,Tax_Classification_AGN__c,Ship_To_AGN__c,Country_AGN__c,Additional_Comments_AGN__c, 
                                                                             Mapping_1_AGN__c,Mapping_2_AGN__c,Contract_Number_AGN__c,State_License_Number_AGN__c,Distribution_ID_AGN__c,Website_Link_AGN__c,
                                                                             Sold_To_AGN__c,Bill_To_AGN__c,Tax_Number_AGN__c FROM Allergan_Customer_Address_AGN__c 
                                                                             WHERE Parent_AGN__c =: customerOld.Id ];
            
            system.debug('customerAddressOld -->' + customerAddressOldList);
            system.debug('customerAddressNew -->' + customerAddress);
            
            list<Allergan_Customer_Address_AGN__c> addList = new list<Allergan_Customer_Address_AGN__c>(); 
            
            if(!customerAddressOldList.isEmpty() && customerAddressOldList.size()>0){           
                for(Allergan_Customer_Address_AGN__c cra : customerAddressOldList ){
                    if(cra.Sold_To_AGN__c){
                        if( customerAddress.VAT_Number_AGN__c != null ){
                            cra.VAT_Number_AGN__c = customerAddress.VAT_Number_AGN__c;
                        }
                        if( customerAddress.Additional_Comments_AGN__c != null ){
                            cra.Additional_Comments_AGN__c = customerAddress.Additional_Comments_AGN__c;
                        }
                        if( customerAddress.Tax_Number_AGN__c != null ){
                            cra.Tax_Number_AGN__c = customerAddress.Tax_Number_AGN__c;
                        }
                        if(customerAddress.Mapping_1_AGN__c != null){
                            cra.Mapping_1_AGN__c = customerAddress.Mapping_1_AGN__c;
                        }
                        if(customerAddress.Mapping_2_AGN__c != null){
                            cra.Mapping_2_AGN__c = customerAddress.Mapping_2_AGN__c;
                        }
                        if(customerAddress.Contract_Number_AGN__c != null){
                            cra.Contract_Number_AGN__c = customerAddress.Contract_Number_AGN__c;
                        }
                        if(customer.Registration_License_Number_AGN__c != null){
                            cra.State_License_Number_AGN__c = customer.Registration_License_Number_AGN__c;
                        }
                        if(customerAddress.Distribution_ID_AGN__c !=null ){
                            cra.Distribution_ID_AGN__c = customerAddress.Distribution_ID_AGN__c;    
                        }
                        if(customerAddress.Website_Link_AGN__c != null){
                            cra.Website_Link_AGN__c = customerAddress.Website_Link_AGN__c;
                        }
                       
                        if(customerOld.Country_Code_AGN__c == 'IT'){
                            if(cra.Country_AGN__c == 'Italy' ){
                                cra.Tax_Classification_AGN__c = '9';
                            }else{
                                cra.Tax_Classification_AGN__c = '0';
                            }
                        }else if(!String.isEmpty(customerOld.Tax_Exempted_AGN__c)){
                            cra.Tax_Classification_AGN__c = customerOld.Tax_Exempted_AGN__c;
                        }
                        else{
                            cra.Tax_Classification_AGN__c = '9';
                        }
                        
                    }else if(cra.Bill_To_AGN__c){                        
                        if(customerOld.Country_Code_AGN__c == 'IT'){
                            if(cra.Country_AGN__c == 'Italy' ){
                                cra.Tax_Classification_AGN__c = '9';
                            }else{
                                cra.Tax_Classification_AGN__c = '0';
                            }
                        }else if(!String.isEmpty(customerOld.Tax_Exempted_AGN__c)){
                            cra.Tax_Classification_AGN__c = customerOld.Tax_Exempted_AGN__c;
                        }
                        else{
                            cra.Tax_Classification_AGN__c = '9';
                        }
                        
                    }else if(cra.Ship_To_AGN__c){                       
                        if(customerOld.Country_Code_AGN__c == 'IT'){
                            if(cra.Country_AGN__c == 'Italy' ){
                                cra.Tax_Classification_AGN__c = '9';
                            }else{
                                cra.Tax_Classification_AGN__c = '0';
                            }
                        }else if(!String.isEmpty(customerOld.Tax_Exempted_AGN__c)){
                            cra.Tax_Classification_AGN__c = customerOld.Tax_Exempted_AGN__c;
                        }
                        else{
                            cra.Tax_Classification_AGN__c = '9';
                        }
                    }
                    
                    addList.add(cra);
                }
            }
            //----------Checkmarx Fix ---Added on 03-08-2020---------
            String objCrAddr = 'Allergan_Customer_Address_AGN__c';
            SObjectType objCrAddrType = ((SObject)(Type.forName('Schema.'+objCrAddr).newInstance())).getSObjectType();
            AGN_FLSCheck.check(addList,objCrAddrType,'UPDATE');
            update addList; 
            //------------------------------------------
            
        } catch (DmlException dx) {
            
            throw new DmlException(dx.getMessage());
        }
        return caseNewCr.Id;
    }
    
    /* Finish registration  start*/
    
    public static ID finishCustomerRegistration_finalStep(Allergan_Customer_Registration_AGN__c customerReg, 
                                                          Allergan_Customer_Address_AGN__c customerAddress, 
                                                          String formofPayment, String PaymentTerm) 
    {
        
        list < SObject > recordsToUpdate = new list < SObject > ();
        
        Allergan_Customer_Registration_AGN__c customer = AGN_OAMCustomerRegStep2Controller.getCustomerRegDetails();
        customer.Consent_For_Communication_AGN__c = customerReg.Consent_For_Communication_AGN__c;
        Case crCase = [SELECT Id, Type, RecordType.Name, 
                       Case_Sub_Status_AGN__c, 
                       EntitlementId, 
                       OwnerId FROM Case 
                       WHERE Id =: customer.Case_AGN__c];
        try {
            //system.debug('customer--->'+ customer.Case_AGN__c);
            system.debug('formofPayment -->'+formofPayment);
            system.debug('PaymentTerm -->'+PaymentTerm);
            system.debug('customer.SAP_Country_Code_AGN__c -->'+customer.SAP_Country_Code_AGN__c);
            
            Payment_Term_AGN__c pt;
            Form_of_Payment_AGN__c fop;
            if(customer.Country_Code_AGN__c == 'CA'){
                fop = [SELECT ID,Name, Form_Of_Payment_Label_AGN__c FROM Form_of_Payment_AGN__c 
                       WHERE (Form_Of_Payment_Label_AGN__c =: formofPayment OR Name =: formofPayment)
                       AND Country_code_AGN__c =: customer.Country_Code_AGN__c];
                
                
                system.debug('PaymentTerm--->'+PaymentTerm);
                pt = [SELECT ID, Name,Payment_Term_Label_AGN__c FROM Payment_Term_AGN__c WHERE Form_Of_Payment__c =: fop.Id AND (Name =: PaymentTerm OR Payment_Term_Label_AGN__c =:PaymentTerm)]; 
                
            }else{
                
                pt = [SELECT ID, Name,Payment_Term_Label_AGN__c FROM Payment_Term_AGN__c 
                      WHERE Form_Of_Payment__c =: formofPayment AND SAP_Payment_Term_Code_AGN__c =: PaymentTerm];
            }
            
            system.debug('pt--->'+pt);            
            
            if (customer.Online_Registration_Step_AGN__c == '4') {
                customer.Online_Registration_Step_AGN__c = '5';
            }
            
            system.debug('customer--->' + customer.Online_Registration_Step_AGN__c);
            if(customer.Country_Code_AGN__c == 'CA'){
                customer.Form_of_Payment_AGN__c = fop.Id;
            }
            else{
                customer.Form_of_Payment_AGN__c = formofPayment;
            }
            customer.Payment_Term_AGN__c = pt.ID;
            //----------Checkmarx Fix ---Added on 03-08-2020---------
            List<Allergan_Customer_Registration_AGN__c> crRegList = new List<Allergan_Customer_Registration_AGN__c>();
            crRegList.add(customer);
            String objCrReg = 'Allergan_Customer_Registration_AGN__c';
            SObjectType objCrRegType = ((SObject)(Type.forName('Schema.'+objCrReg).newInstance())).getSObjectType();
            AGN_FLSCheck.check(crRegList,objCrRegType,'UPDATE');
            update customer;
            //------------------------------------------------

            
            
            Allergan_Customer_Address_AGN__c SoldToAddress = [SELECT Id, Country_Lookup_AGN__c,
                                                              Account_Type_AGN__c,
                                                              House_Number_AGN__c,
                                                              Street_Name_AGN__c,
                                                              Address_Line_1_AGN__c,
                                                              Additional_Comments_AGN__c,
                                                              City_AGN__c,
                                                              Company_Name_AGN__c,
                                                              Department_Name_AGN__c,
                                                              Country_AGN__c,
                                                              Country_Code_AGN__c,
                                                              Email_AGN__c,
                                                              Phone_AGN__c,
                                                              Parent_AGN__c,
                                                              Parent_AGN__r.First_Name_AGN__c,
                                                              Parent_AGN__r.Last_Name_AGN__c,
                                                              Zip_AGN__c,
                                                              Ship_To_AGN__c,
                                                              Sold_To_AGN__c,
                                                              Bill_To_AGN__c,
                                                              State_AGN__c,
                                                              RecordTypeId,
                                                              Sort_Code_AGN__c,
                                                              SWIFT_BIC_AGN__c,
                                                              Bank_Name_AGN__c,
                                                              Bank_Account_Number_AGN__c,
                                                              IBAN_AGN__c,
                                                              IBAN_Text_AGN__c,
                                                              Sub_Type_AGN__c FROM Allergan_Customer_Address_AGN__c 
                                                              WHERE Parent_AGN__c =: customer.Id AND Sold_To_AGN__c = True LIMIT 1];
            
            
            
            //update SoldToAddress;
            system.debug('SoldToAddress--->' + SoldToAddress);
            
            
            SoldToAddress.Bank_Name_AGN__c = customerAddress.Bank_Name_AGN__c;
            SoldToAddress.Bank_Account_Number_AGN__c = customerAddress.Bank_Account_Number_AGN__c;
            SoldToAddress.Sort_Code_AGN__c = customerAddress.Sort_Code_AGN__c;
            SoldToAddress.IBAN_AGN__c = customerAddress.IBAN_Text_AGN__c;
            SoldToAddress.IBAN_Text_AGN__c = customerAddress.IBAN_Text_AGN__c;
            SoldToAddress.SWIFT_BIC_AGN__c = customerAddress.SWIFT_BIC_AGN__c;
            SoldToAddress.Business_Name_Reference1_AGN__c = customerAddress.Business_Name_Reference1_AGN__c;
            SoldToAddress.Business_Name_Reference2_AGN__c = customerAddress.Business_Name_Reference2_AGN__c;
            SoldToAddress.Contact_Name_Reference1_AGN__c = customerAddress.Contact_Name_Reference1_AGN__c;
            SoldToAddress.Contact_Name_Reference2_AGN__c = customerAddress.Contact_Name_Reference2_AGN__c;
            SoldToAddress.Phone_Reference1_AGN__c = customerAddress.Phone_Reference1_AGN__c;
            SoldToAddress.Phone_Reference2_AGN__c = customerAddress.Phone_Reference2_AGN__c;
            SoldToAddress.Fax_Reference1_AGN__c = customerAddress.Fax_Reference1_AGN__c;
            SoldToAddress.Fax_Reference2_AGN__c = customerAddress.Fax_Reference2_AGN__c;
            
            SoldToAddress.NIF_CIF_number_AGN__c = customerAddress.NIF_CIF_number_AGN__c; // added abdul
            
            
            List < Allergan_Customer_Address_AGN__c > custAddList = [SELECT Id, Country_Lookup_AGN__c,
                                                                     Account_Type_AGN__c,
                                                                     House_Number_AGN__c,
                                                                     Street_Name_AGN__c,
                                                                     Address_Line_1_AGN__c,
                                                                     Additional_Comments_AGN__c,
                                                                     City_AGN__c,
                                                                     Company_Name_AGN__c,
                                                                     Department_Name_AGN__c,
                                                                     Country_AGN__c,
                                                                     Country_Code_AGN__c,
                                                                     Email_AGN__c,
                                                                     Phone_AGN__c,
                                                                     Parent_AGN__c,
                                                                     Parent_AGN__r.First_Name_AGN__c,
                                                                     Parent_AGN__r.Last_Name_AGN__c,
                                                                     Zip_AGN__c,
                                                                     Ship_To_AGN__c,
                                                                     Sold_To_AGN__c,
                                                                     Bill_To_AGN__c,
                                                                     State_AGN__c,
                                                                     RecordTypeId,
                                                                     Sort_Code_AGN__c,
                                                                     SWIFT_BIC_AGN__c,
                                                                     Bank_Name_AGN__c,
                                                                     Bank_Account_Number_AGN__c,
                                                                     IBAN_Text_AGN__c,  
                                                                     IBAN_AGN__c,
                                                                     Sub_Type_AGN__c FROM Allergan_Customer_Address_AGN__c 
                                                                     WHERE Parent_AGN__c =: customer.id ORDER BY createdDate DESC];
            
            system.debug('----->' + custAddList);
            system.debug('----->' + custAddList.size());
            
            
            if (AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_Bill_To__c') != Null ?
                (boolean) AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_Bill_To__c') : false) {
                    
                    for (Allergan_Customer_Address_AGN__c add: custAddList) {
                        if (add.Sold_To_AGN__c) {
                            system.debug('Sold_To_AGN__c----->' + add);
                            recordsToUpdate.add(SoldToAddress);
                        } else if (add.Bill_To_AGN__c) {
                            system.debug('Bill_To_AGN__c----->' + add);
                            
                            if (!isSameAddress(add, SoldToAddress)) {
                                add.Bank_Name_AGN__c = SoldToAddress.Bank_Name_AGN__c;
                                add.Bank_Account_Number_AGN__c = SoldToAddress.Bank_Account_Number_AGN__c;
                                add.Sort_Code_AGN__c = SoldToAddress.Sort_Code_AGN__c;
                                add.IBAN_AGN__c = SoldToAddress.IBAN_Text_AGN__c;
                                add.IBAN_Text_AGN__c = SoldToAddress.IBAN_Text_AGN__c;
                                add.SWIFT_BIC_AGN__c = SoldToAddress.SWIFT_BIC_AGN__c;
                                add.Business_Name_Reference1_AGN__c = SoldToAddress.Business_Name_Reference1_AGN__c;
                                add.Business_Name_Reference2_AGN__c = SoldToAddress.Business_Name_Reference2_AGN__c;
                                add.Contact_Name_Reference1_AGN__c = SoldToAddress.Contact_Name_Reference1_AGN__c;
                                add.Contact_Name_Reference2_AGN__c = SoldToAddress.Contact_Name_Reference2_AGN__c;
                                add.Phone_Reference1_AGN__c = SoldToAddress.Phone_Reference1_AGN__c;
                                add.Phone_Reference2_AGN__c = SoldToAddress.Phone_Reference2_AGN__c;
                                add.Fax_Reference1_AGN__c = SoldToAddress.Fax_Reference1_AGN__c;
                                add.Fax_Reference2_AGN__c = SoldToAddress.Fax_Reference2_AGN__c;
                                
                                recordsToUpdate.add(add);
                                
                            } else {
                                SoldToAddress.Bill_To_AGN__c = true;
                                recordsToUpdate.add(SoldToAddress);
                            }
                            
                        } else if (add.Ship_To_AGN__c) {
                            system.debug('Ship_To_AGN__c----->' + add);
                            if (isSameAddress(add, SoldToAddress)) {
                                SoldToAddress.Ship_To_AGN__c = true;
                                recordsToUpdate.add(add);
                            }
                        }
                    }
                    
                }
            
            crCase.Case_Sub_Status_AGN__c = 'Online Registration Completed';
            //crCase.Case_Step_Number_AGN__c = 2;
            
            system.debug('======customerAddress========>' + crCase.RecordType.Name + '==' + crCase.Type + '==' + customer.Country_Code_AGN__c);
            crCase.EntitlementId = setEntitlement(crCase.RecordType.Name, crCase.Type, customer.Country_Code_AGN__c);
            // recordsToUpdate.add(crCase);
            //----------Checkmarx Fix ---Added on 03-08-2020---------
            List<Case> crCaseList = new List<Case>();
            crCaseList.add(crCase);
            String objCrCase = 'Case';
            SObjectType objCrCaseType = ((SObject)(Type.forName('Schema.'+objCrCase).newInstance())).getSObjectType();
            AGN_FLSCheck.check(crCaseList,objCrCaseType,'UPDATE');
            update crCase;
            //------------------------------------------------
            String objCrAddr = 'Allergan_Customer_Address_AGN__c';
            SObjectType objCrAddrType = ((SObject)(Type.forName('Schema.'+objCrAddr).newInstance())).getSObjectType();
            AGN_FLSCheck.check(recordsToUpdate,objCrAddrType,'UPDATE');
            update recordsToUpdate;
            // Trigger the assignment rule by calling the case next button functionality
            AGN_Case_Next.gotoNextStep(crCase.id);            
        } catch (DmlException dx) {
            
            throw new DmlException(dx.getMessage());
        }
        return crCase.id;
    }
    
    public static boolean isSameAddress(Allergan_Customer_Address_AGN__c add1, Allergan_Customer_Address_AGN__c add2) {
        system.debug('======add1=========>' + add1);
        system.debug('======add2=========>' + add2);
        
        add1.Company_Name_AGN__c = (add1.Company_Name_AGN__c == null ? '' : add1.Company_Name_AGN__c);
        add1.Address_Line_1_AGN__c = (add1.Address_Line_1_AGN__c == null ? '' : add1.Address_Line_1_AGN__c);
        add1.Address_Line_2_AGN__c = (add1.Address_Line_2_AGN__c == null ? '' : add1.Address_Line_2_AGN__c);
        add1.Address_Line_3_AGN__c = (add1.Address_Line_3_AGN__c == null ? '' : add1.Address_Line_3_AGN__c);
        add1.State_AGN__c = (add1.State_AGN__c == null ? '' : add1.State_AGN__c);
        add1.City_AGN__c = (add1.City_AGN__c == null ? '' : add1.City_AGN__c);
        add1.Country_AGN__c = (add1.Country_AGN__c == null ? '' : add1.Country_AGN__c);
        add1.Zip_AGN__c = (add1.Zip_AGN__c == null ? '' : add1.Zip_AGN__c);
        add1.Email_AGN__c = (add1.Email_AGN__c == null ? '' : add1.Email_AGN__c);
        add1.Phone_AGN__c = (add1.Phone_AGN__c == null ? '' : add1.Phone_AGN__c);
        add1.Phone_2_AGN__c = (add1.Phone_2_AGN__c == null ? '' : add1.Phone_2_AGN__c);
        add1.Department_Name_AGN__c = (add1.Department_Name_AGN__c == null ? '' : add1.Department_Name_AGN__c);
        add1.House_Number_AGN__c = (add1.House_Number_AGN__c == null ? '' : add1.House_Number_AGN__c);
        
        
        add2.Company_Name_AGN__c = (add2.Company_Name_AGN__c == null ? '' : add2.Company_Name_AGN__c);
        add2.Address_Line_1_AGN__c = (add2.Address_Line_1_AGN__c == null ? '' : add2.Address_Line_1_AGN__c);
        add2.Address_Line_2_AGN__c = (add2.Address_Line_2_AGN__c == null ? '' : add2.Address_Line_2_AGN__c);
        add2.Address_Line_3_AGN__c = (add2.Address_Line_3_AGN__c == null ? '' : add2.Address_Line_3_AGN__c);
        add2.State_AGN__c = (add2.State_AGN__c == null ? '' : add2.State_AGN__c);
        add2.City_AGN__c = (add2.City_AGN__c == null ? '' : add2.City_AGN__c);
        add2.Country_AGN__c = (add2.Country_AGN__c == null ? '' : add2.Country_AGN__c);
        add2.Zip_AGN__c = (add2.Zip_AGN__c == null ? '' : add2.Zip_AGN__c);
        add2.Email_AGN__c = (add2.Email_AGN__c == null ? '' : add2.Email_AGN__c);
        add2.Phone_AGN__c = (add2.Phone_AGN__c == null ? '' : add2.Phone_AGN__c);
        add2.Phone_2_AGN__c = (add2.Phone_2_AGN__c == null ? '' : add2.Phone_2_AGN__c);
        add2.Department_Name_AGN__c = (add2.Department_Name_AGN__c == null ? '' : add2.Department_Name_AGN__c);
        add2.House_Number_AGN__c = (add2.House_Number_AGN__c == null ? '' : add2.House_Number_AGN__c);
        
        
        if (add1.Company_Name_AGN__c.deleteWhitespace() == add2.Company_Name_AGN__c.deleteWhitespace() &&
            add1.Address_Line_1_AGN__c.deleteWhitespace() == add2.Address_Line_1_AGN__c.deleteWhitespace() &&
            add1.State_AGN__c.deleteWhitespace() == add2.State_AGN__c.deleteWhitespace() &&
            add1.City_AGN__c.deleteWhitespace() == add2.City_AGN__c.deleteWhitespace() &&
            add1.Country_AGN__c.deleteWhitespace() == add2.Country_AGN__c.deleteWhitespace() &&
            add1.Zip_AGN__c.deleteWhitespace() == add2.Zip_AGN__c.deleteWhitespace() &&
            add1.Email_AGN__c.deleteWhitespace() == add2.Email_AGN__c.deleteWhitespace() &&
            add1.Phone_AGN__c.deleteWhitespace() == add2.Phone_AGN__c.deleteWhitespace() &&
            add1.Phone_2_AGN__c.deleteWhitespace() == add2.Phone_2_AGN__c.deleteWhitespace() &&
            add1.Address_Line_2_AGN__c.deleteWhitespace() == add2.Address_Line_2_AGN__c.deleteWhitespace() &&
            add1.Address_Line_3_AGN__c.deleteWhitespace() == add2.Address_Line_3_AGN__c.deleteWhitespace() &&
            add1.Department_Name_AGN__c.deleteWhitespace() == add2.Department_Name_AGN__c.deleteWhitespace() &&
            String.valueof(add1.House_Number_AGN__c).deleteWhitespace() == String.valueof(add2.House_Number_AGN__c).deleteWhitespace())
            return true;
        else return false;
    }
    
    public static Id setEntitlement(string caseRecordType, string requestCategory, string countryCode) {
        system.debug('===' + caseRecordType + requestCategory + countryCode);
        Id entitlementId = [SELECT Entitlement_AGN__c FROM Case_Configuration_AGN__c WHERE
                            Case_Record_Type__c =: caseRecordType AND Static_Category_AGN__c =: requestCategory AND Country_Code_AGN__c =: countryCode
                            LIMIT 1
                           ].Entitlement_AGN__c;
        system.debug('Case Record Type ==> ' + caseRecordType + ', Request Category ==> ' + requestCategory + ', Country Code ==> ' + countryCode);
        
        return entitlementId;
        
    }
    
    public static Map<String , List<AGN_CommunityDependentLayout__mdt>> getDependantFieldSettings(String country){
        Map<String , List<AGN_CommunityDependentLayout__mdt>> dependantFieldMap = new Map<String , List<AGN_CommunityDependentLayout__mdt>>();
        List<AGN_CommunityDependentLayout__mdt> fieldSettings = new List<AGN_CommunityDependentLayout__mdt>();
        String queryStr = 'SELECT SObject_Name_AGN__c,' +
            ' Field_Name_AGN__c,' +
            ' Sort_Order_AGN__c,' +
            ' Field_Label_AGN__c,' +
            ' Field_Custom_Label_AGN__c,' + 
            ' Required_AGN__c,' +
            ' Section_Header_AGN__c,' +
            ' Section_Header_Label_AGN__c,' +
            ' Section_Header_Custom_Label_AGN__c,' +
            ' Customer_Groups_AGN__c,' +
            ' Field_Regex_AGN__c, ' +
            ' Help_Text_AGN__c ,' +
            ' FieldValue_AGN__c ,'+ 
            ' Is_Format_Valid_AGN__c ,'+
            ' FieldValue_Missing_AGN__c ,'+
            ' Controlling_Field__c '+
            ' FROM AGN_CommunityDependentLayout__mdt ' +
            ' WHERE Country_AGN__c = \'' + String.escapeSingleQuotes(country) + '\'';
        fieldSettings = Database.query(queryStr);
        for(AGN_CommunityDependentLayout__mdt setting : fieldSettings){
            if(setting.Controlling_Field__c != null){
                if(dependantFieldMap.containsKey(setting.Controlling_Field__c)){
                    dependantFieldMap.get(setting.Controlling_Field__c).add(setting);
                }else{
                    List<AGN_CommunityDependentLayout__mdt> settings = new List<AGN_CommunityDependentLayout__mdt>();
                    settings.add(setting);
                    dependantFieldMap.put(setting.Controlling_Field__c , settings);
                }
            }
        }
        system.debug('dependantFieldMap>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+dependantFieldMap);
        return dependantFieldMap;
    }
    
    /* Finish registration  End  */
    
    public static Map < String, List < AGN_Community_Layout_Setting__mdt >> getLayoutCountrySetting(String country, String stepNo, String customerType, String customerSubType, List < Customer_Type_Configuration_AGN__c > custTypeConfig) {
        
        String customerGroup = '';
        AGN_Community_Layout_Setting__mdt[] configList = null;
        AGN_Community_Layout_Setting__mdt[] matchingRows = null;
        
        String queryStr = 'SELECT SObject_Name_AGN__c,' +
            ' Field_Name_AGN__c,' +
            ' Sort_Order_AGN__c,' +
            ' Field_Label_AGN__c,' +
            ' Field_Custom_Label_AGN__c,' +
            ' Required_AGN__c,' +
            ' Section_Header_AGN__c,' +
            ' Section_Header_Label_AGN__c,' +
            ' Section_Header_Custom_Label_AGN__c,' +
            ' Customer_Groups_AGN__c,' +
            ' Field_Regex_AGN__c, ' +
            ' Help_Text_AGN__c ' +
            ' FROM AGN_Community_Layout_Setting__mdt ' +
            ' WHERE Country_AGN__c = \'' + String.escapeSingleQuotes(country)  + '\'' +
            ' AND Step_No_AGN__c = \'' + String.escapeSingleQuotes(stepNo) + '\'' +
            ' AND Display__c = true ORDER BY Section_Header_Sort_Order_AGN__c, Sort_Order_AGN__c';
        
        System.debug('queryStr es: '+queryStr);
        if (customerType == null && customerSubType == null && (custTypeConfig == null || custTypeConfig.isEmpty())) {            
            configList = Database.query(queryStr);
            return groupByField('Section_Header_AGN__c', configList);
        } else if (customerType != null && customerSubType != null && (custTypeConfig == null || custTypeConfig.isEmpty())) {
            
            //custTypeConfig.isEmpty()=> need to fetch Customer_Group_AGN__c from server
            String countryCode;
            if(country.equalsIgnoreCase('IE')){
                countryCode = 'GB';
            }
            else{
                countryCode = country;
            }
            Customer_Type_Configuration_AGN__c[] confList = [SELECT
                                                             Customer_Group_AGN__c
                                                             FROM Customer_Type_Configuration_AGN__c
                                                             where Category_AGN__c =: customerType
                                                             and Sub_Category__c =: customerSubType
                                                             and Country_Code_AGN__c =: countryCode
                                                             limit 1
                                                            ];
            
            
            if (confList != null && !confList.isEmpty()) {
                customerGroup = confList[0].Customer_Group_AGN__c;
                configList = Database.query(queryStr);
                
                matchingRows = findMatchingRows(configList, customerGroup);
                return groupByField('Section_Header_AGN__c', matchingRows);
            }
        } else if (customerType != null && customerSubType != null && !custTypeConfig.isEmpty()) {
            
            //custTypeConfig not empty=> need to find Customer_Group_AGN__c from parameter
            
            for (Customer_Type_Configuration_AGN__c cConf: custTypeConfig) {
                if (cConf.Category_AGN__c.equalsIgnoreCase(customerType) && cConf.Sub_Category__c.equalsIgnoreCase(customerSubType)) {
                    customerGroup = cConf.Customer_Group_AGN__c;
                    break;
                }
            }
            if (customerGroup != '') {
                configList = Database.query(queryStr);
                
                matchingRows = findMatchingRows(configList, customerGroup);
                return groupByField('Section_Header_AGN__c', matchingRows);
            }
        }
        
        return groupByField('Section_Header_AGN__c', configList);         
    }
    @TestVisible
    private static List < AGN_Community_Layout_Setting__mdt > findMatchingRows(AGN_Community_Layout_Setting__mdt[] configList, String customerGroup) {
        
        List < AGN_Community_Layout_Setting__mdt > matchedConfig = new List < AGN_Community_Layout_Setting__mdt > ();
        
        for (AGN_Community_Layout_Setting__mdt layout: configList) {
            List < String > lstCustGrp = layout.Customer_Groups_AGN__c.split(',');
            for (String grp: lstCustGrp) {
                if (grp.equalsIgnoreCase(customerGroup)) {
                    matchedConfig.add(layout);
                    break;
                }
            }
        }
        
        return matchedConfig;
    }
    @TestVisible
    private static Map < String, List < AGN_Community_Layout_Setting__mdt >> groupByField(String field, List < AGN_Community_Layout_Setting__mdt > records) {   
        Map < String, List < AGN_Community_Layout_Setting__mdt >> grouped = new Map < String, List < AGN_Community_Layout_Setting__mdt >> ();
        if (records != null && records.size() > 0) {
            for (AGN_Community_Layout_Setting__mdt record: records) {
                String key = (String) record.get(field);
                if (!grouped.containsKey(key))
                    grouped.put(key, new List < AGN_Community_Layout_Setting__mdt > ());
                grouped.get(key).add(record);
            }
        }        
        return grouped;
    }
    
    public static void deleteAddress(Allergan_Customer_Address_AGN__c customerAddress) {
        
        try {
            delete customerAddress;
        }
        catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
    }
    
    public static Boolean isRegistrationCompleted() {
        
        User currentUser = [Select Contact.Customer_Registration_AGN__c, Account.Customer_Registration_AGN__c from User where Id =: UserInfo.getUserId() limit 1];
        if(currentUser.Account.Customer_Registration_AGN__c == 'Complete' || currentUser.Contact.Customer_Registration_AGN__c == 'Complete'){
            return true;
        }
        else{
            return false;
        }
    }
    
    public static Boolean isRegistrationCompleted(String userId) {
        
        User currentUser = [Select Contact.Customer_Registration_AGN__c, Account.Customer_Registration_AGN__c from User where Id =: userId limit 1];
        
        if(currentUser.Account.Customer_Registration_AGN__c == 'Complete' || currentUser.Contact.Customer_Registration_AGN__c == 'Complete'){
            return true;
        }
        else{
            return false;
        }    
    }
    
    public static List<Allergan_Consent_Footer_Info__c> getFooterConsents(String countryCode) {
        
        List<Allergan_Consent_Footer_Info__c> footerLst = [Select Id, Name, Language__c, Footer_RichText_c__c from Allergan_Consent_Footer_Info__c where Language__c= :countryCode Order by Display_Order__c asc];
        return footerLst;
    }
    
    public static void sendEmail(List<AGN_EmailMessageWrapper> listEmailMessageWrapper, String emailTemplateName, String fromEmailAddress) {
        Messaging.reserveSingleEmailCapacity(2);
        List<Messaging.SendEmailResult> listEmailResult = null;
        List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :emailTemplateName];  
        
        //getting attachment lists
        List<Attachment> attachmentLst = [select Name, Body, BodyLength from Attachment where ParentId = :emailTemplate.Id];
        
        for (AGN_EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: fromEmailAddress];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            else{
                mail.setSenderDisplayName('Allergan Customer Portal'); 
            } 
            //if(emailMessageWrapper.FromAddress != null && emailMessageWrapper.FromAddress.length() > 0)
            //    mail.setReplyTo(emailMessageWrapper.FromAddress);
            if(emailMessageWrapper.ToAddress != null && emailMessageWrapper.ToAddress.length() > 0)
                mail.setToAddresses(new String[] { emailMessageWrapper.ToAddress });
            else
                mail.setTargetObjectId(emailMessageWrapper.ToAddressId);
            if(emailMessageWrapper.BccAddress != null && emailMessageWrapper.BccAddress.length() > 0)
                mail.setBccAddresses(new String[] {emailMessageWrapper.BccAddress });
            String subject = null;
            if(emailMessageWrapper.Subject != null && emailMessageWrapper.Subject.length() > 0) {
                mail.setSubject(emailMessageWrapper.Subject);
                subject = emailMessageWrapper.Subject;
            }
            else{
                subject = emailTemplate.Subject;
            }
            for(String key: emailMessageWrapper.ParameterSubjectMap.keySet()){
                subject = subject.replace(key, (emailMessageWrapper.ParameterSubjectMap.get(key) == null ? '' : emailMessageWrapper.ParameterSubjectMap.get(key)));
            }
            
            mail.setSubject(subject);
            String htmlBody = emailTemplate.HtmlValue;
            String plainBody = emailTemplate.Body;
            for (String key : emailMessageWrapper.ParameterBodyMap.keySet()) {
                htmlBody = htmlBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
                plainBody = plainBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
            }
            
            mail.setHtmlBody(htmlBody);
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(plainBody);
            
            
            //Set email file attachments
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for (Attachment a : attachmentLst)
            {
                // Add to attachment file list
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(a.Name);
                efa.setBody(a.Body);
                fileAttachments.add(efa);
            }
            mail.setFileAttachments(fileAttachments);
            
            listSingleEmailMessages.add(mail);
        }
        if(!Test.isRunningTest()){
            listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
        } 
    }
}