public without sharing class AGN_OAMPortalCustomerRegUtils{
    
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
            ' ReadOnly_AGN__c,' +
            ' Field_Regex_AGN__c, ' +
            ' Help_Text_AGN__c ' +
            ' FROM AGN_Community_Layout_Setting__mdt ' +
            ' WHERE Country_AGN__c = \'' + String.escapeSingleQuotes(country) + '\'' +
            ' AND Step_No_AGN__c = \'' + String.escapeSingleQuotes(stepNo) + '\'' +
            ' AND Display__c = true ORDER BY Section_Header_Sort_Order_AGN__c, Sort_Order_AGN__c';
        
        System.debug('queryStr es: '+queryStr);
        if (customerType == null && customerSubType == null && (custTypeConfig == null || custTypeConfig.isEmpty())) {            
            configList = Database.query(queryStr);
            return groupByField('Section_Header_AGN__c', configList);
        } else if (customerType != null && customerSubType != null && (custTypeConfig == null || custTypeConfig.isEmpty())) {
            
            //custTypeConfig.isEmpty()=> need to fetch Customer_Group_AGN__c from server
            String countryCode;
            if(country.equalsIgnoreCase('AU')){ //country.equalsIgnoreCase('NZ') ||
                countryCode = 'AN';
            }
            else{
                countryCode = country;
            }
            
            // system.debug('country>>>>>>>>>>>'+countryCode);
            //  system.debug('customerType>>>>>>>>>>>'+customerType);
            //  system.debug('customerSubType>>>>>>>>>>>'+customerSubType);
            Customer_Type_Configuration_AGN__c[] confList = [SELECT
                                                             Customer_Group_AGN__c
                                                             FROM Customer_Type_Configuration_AGN__c
                                                             where Category_AGN__c =: customerType
                                                             and Sub_Category__c =: customerSubType
                                                             and Customer_Country_AGN__r.Alpha_2_Code_vod__c =: countryCode
                                                             limit 1
                                                            ];
            //system.debug('confList>>>>>>>>>>>'+confList);
            
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
            ' WHERE Country_AGN__c = \'' + String.escapeSingleQuotes(country) + '\'' +
            ' ORDER BY Sort_Order_AGN__c';
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
    
    /* For Step 3 */
    public static Map < String, List < AGN_Portal_Community_Layout_Setting__mdt >> getPortalLayoutCountrySetting(String country, String stepNo, String customerType, String customerSubType) {
        
        AGN_Portal_Community_Layout_Setting__mdt[] configList = null;
        AGN_Portal_Community_Layout_Setting__mdt[] matchingRows = null;
        
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
            ' Help_Text_AGN__c, ' +
            ' Customer_Type_AGN__c, ' +
            ' Customer_Sub_Category__c ' +
            ' FROM AGN_Portal_Community_Layout_Setting__mdt ' +
            ' WHERE Country_AGN__c = \'' + String.escapeSingleQuotes(country) + '\'' +
            ' AND Step_No_AGN__c = \'' + String.escapeSingleQuotes(stepNo) + '\'' +
            ' AND Display_AGN__c = true ORDER BY Section_Header_Sort_Order_AGN__c, Sort_Order_AGN__c';
        
        System.debug('queryStr es: '+queryStr);
        
        if (customerType == null && customerSubType == null) {            
            configList = Database.query(queryStr);
            
            return groupByPortalField('Section_Header_AGN__c', configList);
            
        } else if (customerType != null && customerSubType != null) {       
            configList = Database.query(queryStr);
            matchingRows = findPortalMatchingRows(configList, customerType, customerSubType);
            
            return groupByPortalField('Section_Header_AGN__c', matchingRows);         
        } 
        return groupByPortalField('Section_Header_AGN__c', configList);    
    }
    @TestVisible
    private static List < AGN_Portal_Community_Layout_Setting__mdt > findPortalMatchingRows(AGN_Portal_Community_Layout_Setting__mdt[] configList, String customerType, String customerSubType) {
        
        List < AGN_Portal_Community_Layout_Setting__mdt > matchedConfig = new List < AGN_Portal_Community_Layout_Setting__mdt > ();
        
        system.debug('configList>>>>>>>>>>>>>>'+configList);
        
        for (AGN_Portal_Community_Layout_Setting__mdt layout: configList) {
            List < String > lstCustType = layout.Customer_Type_AGN__c.split(',');
            List < String > lstCustSubType = layout.Customer_Sub_Category__c.split(',');            
            for (String grp: lstCustType) { 
                for(String stype : lstCustSubType){
                    if (grp.equalsIgnoreCase(customerType) && stype.equalsIgnoreCase(customerSubType)) {
                        system.debug('grp>>>>>>>>>>>>>>'+grp+'>>>>>>'+customerType+'>>>>>stype>>>>>'+stype+'>>>>>'+customerSubType);
                        matchedConfig.add(layout);
                        break;
                    }
                }
            }
        }
        system.debug('matchedConfig>>>>>>>>>>>>>>'+matchedConfig);
        return matchedConfig;
    }
    @TestVisible
    private static Map < String, List < AGN_Portal_Community_Layout_Setting__mdt >> groupByPortalField(String field, List < AGN_Portal_Community_Layout_Setting__mdt > records) {   
        Map < String, List < AGN_Portal_Community_Layout_Setting__mdt >> grouped = new Map < String, List < AGN_Portal_Community_Layout_Setting__mdt >> ();
        if (records != null && records.size() > 0) {
            for (AGN_Portal_Community_Layout_Setting__mdt record: records) {
                String key = (String) record.get(field);
                if (!grouped.containsKey(key))
                    grouped.put(key, new List < AGN_Portal_Community_Layout_Setting__mdt > ());
                grouped.get(key).add(record);
            }
        } 
        system.debug('grouped>>>>>>>>>>>>>>'+grouped);
        return grouped;
    }
    
    /* for Step 3 End */
    
    public static List<Allergan_Consent_Footer_Info__c> getFooterConsents(String countryCode) {
        
        List<Allergan_Consent_Footer_Info__c> footerLst = [Select Id, Name, Language__c, Footer_RichText_c__c from Allergan_Consent_Footer_Info__c where Language__c= :countryCode Order by Display_Order__c asc];
        return footerLst;
    }
    
    public static Account createAccount(Allergan_Customer_Address_AGN__c customerAddress, Allergan_Customer_Registration_AGN__c customer) {
        
        Account customerAccount = new Account();
        
        try {
            customerAccount.Name = customerAddress.Company_Name_AGN__c;
            customerAccount.OwnerId = AGN_OAMConstant.OWNER_ID;
            customerAccount.Phone = customerAddress.Phone_AGN__c;
            if(customer != null) customerAccount.Customer_Sub_Category_AGN__c = customer.Customer_Sub_Category_AGN__c; 
             //------CheckMarx--Added on 24/07/2020----------      
            List<Account> tempAcList = new List<Account>();
            tempAcList.add(customerAccount);
            /*SObjectAccessDecision decisionOnAc = Security.stripInaccessible(AccessType.CREATABLE,tempAcList);           
            if(decisionOnAc.getRemovedFields().get('Account')!=null){
                throw new AGN_CommonException('Error: Insufficient Create Access On Account [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: createAccount]');
            }
            else{
               insert customerAccount;
            }*/
            String objAcc = 'Account';
            SObjectType AccObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempAcList,AccObjType,'INSERT');
            insert customerAccount;
            //-------------------------
            
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
        return customerAccount;
    }
    
    public static Contact createContact(Allergan_Customer_Registration_AGN__c customer, Account acc) {
        
        Contact customerContact = new Contact();        
        try { 
            customerContact.AccountId = acc.ID;
            customerContact.Salutation = customer.Salutation_AGN__c;
            customerContact.FirstName = customer.First_Name_AGN__c;
            customerContact.Middle_Name_AGN__c = customer.Middle_Name_AGN__c;
            customerContact.LastName = customer.Last_Name_AGN__c;
            customerContact.Email = customer.Email_AGN__c;
            customerContact.Phone = customer.Phone_AGN__c;
            customerContact.Country_Code__c = customer.Country_Code_AGN__c;
            customerContact.OwnerId = AGN_OAMConstant.OWNER_ID; 
            customerContact.Customer_Registration_AGN__c = 'In Progress';
            customerContact.Customer_Managed_AGN__c = true;
            customerContact.Country_vod__c = customer.Country_AGN__c;
            customerContact.SAP_Country_Code_AGN__c = customer.SAP_Country_Code_AGN__c;
            customerContact.Is_Primary_Contact_AGN__c = true;
            //------CheckMarx--Added on 24/07/2020----------      
            List<Contact> tempCtList = new List<Contact>();
            tempCtList.add(customerContact);
           /* SObjectAccessDecision decisionOnCt = Security.stripInaccessible(AccessType.CREATABLE,tempCtList);
            if(decisionOnCt.getRemovedFields().get('Contact')!=null){
                System.debug('No Permission on Fields'+ decisionOnCt.getRemovedFields().get('Contact'));
                Id profileId=userinfo.getProfileId();
                String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
                system.debug('ProfileName'+profileName);
                throw new AGN_CommonException('Error: Insufficient Create Access On Contact [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: createContact]');
            }
            else{
               insert customerContact;
            }*/
            String objCnt = 'Contact';
            SObjectType CntObjType = ((SObject)(Type.forName('Schema.'+objCnt).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCtList,CntObjType,'INSERT');
            insert customerContact;
            
            //-------------------------
           
            system.debug('@@@@@ customerContact @@@@@'+customerContact);
            
            customerContact = [select Id, AccountId,Name, FirstName,Country_vod__c, Customer_Managed_AGN__c,Middle_Name_AGN__c,
                               LastName,Email, Phone, Country_Code__c,SAP_Country_Code_AGN__c,Customer_Registration_AGN__c,
                               Account.Customer_Sub_Category_AGN__c from Contact where Id =: customerContact.Id limit 1];
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }      
        
        return customerContact;
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
    
    public static Id createCommunityUser(Id customerContactId , String countryCode, string selectedUserLocale) {
        string alias = '';
        Contact customer = [select Id, Name,Country_Code__c, Account.Customer_Sub_Category_AGN__c, FirstName, LastName, Email, Phone from Contact where Id =: customerContactId limit 1];
        string SapCountryCode = ''; 
        if(countryCode.equalsIgnoreCase('IE')){
            countryCode = 'GB';
            SapCountryCode = 'IE';
        }else{
            SapCountryCode = countryCode;
        }
        OAM_User_Settings__c allDetails = new OAM_User_Settings__c();
        if(!string.isEmpty(countryCode)){
            allDetails = OAM_User_Settings__c.getInstance(countryCode);
        }       
        
        User customerUser = new User();        
        
        if(countryCode.equalsIgnoreCase('CA')){
            if(!String.isEmpty(selectedUserLocale)){
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
            
            alias = generateRandomString(8);        
            
            customerUser.Email = customer.Email.toLowercase();
            customerUser.Phone = customer.Phone;
            customerUser.FirstName = customer.FirstName;
            customerUser.LastName = customer.LastName;
            customerUser.Alias = alias;
            //customerUser.LanguageLocaleKey = allDetails.User_Language__c;
            customerUser.EmailEncodingKey = 'UTF-8';
            //customerUser.LocalesIdKey = allDetails.User_Locale__c;
            customerUser.TimezonesIdKey = allDetails.User_Timezone__c;
            customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: allDetails.User_Profile__c limit 1].Id;
            customerUser.UserName = customer.Email.toLowercase() + '.' + AGN_OAMConstant.USERNAME_SUFFIX;
            customerUser.ContactId = customer.Id;
            customerUser.Country_Code__c = countryCode;
            customerUser.Division = customer.Account.Customer_Sub_Category_AGN__c;
            //customerUser.FederationIdentifier = customer.Email.toLowercase(); //SSO Mapping has been shifted to createOktaUserSendLink() method
            customerUser.MA_User_Country_Code_AGN__c=SapCountryCode; // added for gb step2 subtype mismatch
            
            //------CheckMarx--Added on 24/07/2020----------      
            List<User> tempuserList = new List<User>();
            tempuserList.add(customerUser);
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
    
    public static Boolean isRegistrationCompleted() {
        
        User currentUser = [Select Contact.Customer_Registration_AGN__c from User where Id =: UserInfo.getUserId() limit 1];
        
        return currentUser.Contact.Customer_Registration_AGN__c == 'Complete' ? true : false;    
    }
    
    public static Id createNewCustomerRegistration(Allergan_Customer_Registration_AGN__c customer,
                                                   Allergan_Customer_Address_AGN__c customerAddress,
                                                   List < Customer_Type_Configuration_AGN__c > configList,
                                                   Contact customerContact,
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
                                                           //caseNewCr.Subject = customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c + ' - ' + caseNewCr.Type;
                                                           caseNewCr.ContactId = customerContact.Id;
                                                           //caseNewCr.AccountId = customerContact.AccointId;
                                                           caseNewCr.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case'
                                                                                     AND DeveloperName = 'AGN_Support_Request_Customer_Registration'
                                                                                     LIMIT 1
                                                                                    ][0].Id;
                                                           caseNewCr.SuppliedName = customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c;
                                                           caseNewCr.SuppliedEmail = customer.Email_AGN__c;
                                                           caseNewCr.SuppliedPhone = customer.Phone_AGN__c;
                                                           caseNewCr.Case_Sub_Status_AGN__c = 'Online Registration - In Progress';
                                                           caseNewCr.Country_Code_AGN__c = customer.Country_Code_AGN__c;
                                                           //------CheckMarx--Added on 24/07/2020----------      
                                                           List<Case> tempCrCsList = new List<Case>();
                                                           tempCrCsList.add(caseNewCr);
                                                           /*SObjectAccessDecision decisionOnCRCs = Security.stripInaccessible(AccessType.CREATABLE,tempCrCsList);
                                                           if(decisionOnCRCs.getRemovedFields().get('Case')!=null){
                                                               System.debug('No Permission on Fields'+decisionOnCRCs.getRemovedFields());
                                                               throw new AGN_CommonException('Error: Insufficient Create Access On Case [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: createNewCustomerRegistration]');
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
                                                           String lang;
                                                           if(customer.Country_Code_AGN__c.equalsIgnoreCase('CA')){
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
                                                           else if(customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('AU') || customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('NZ')){
                                                               lang = (String)OAM_User_Settings__c.getValues(customer.SAP_Country_Code_AGN__c).get('User_Language__c');
                                                           }
                                                           else{
                                                               lang = AGN_OAMConstant.USER_LANGUAGE;
                                                           } 
                                                           
                                                           customer.Language_AGN__c = lang;
                                                           
                                                           customer.Case_AGN__c = caseNewCr.Id;                                                           
                                                           customer.Trigger_Validation_of_Children__c = false;
                                                           customer.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c'
                                                                                    AND DeveloperName = 'New'
                                                                                    LIMIT 1
                                                                                   ][0].Id;
                                                           mapCustomerType(configList, customerAddress, customer);
                                                           customer.OwnerId = AGN_OAMConstant.OWNER_ID;
                                                           customer.Processed_By_SAP_AGN__c = 'In Progress';
                                                           //customer.Allergan_Direct_Access_Requested_AGN__c = true; //Allergan Direct enablement
                                                           
                                                           //------CheckMarx--Added on 23/07/2020----------      
                                                           List<Allergan_Customer_Registration_AGN__c> tempCrList = new List<Allergan_Customer_Registration_AGN__c>();
                                                           tempCrList.add(customer);
                                                           /*SObjectAccessDecision decisionOnCrR = Security.stripInaccessible(AccessType.CREATABLE,tempCrList);
                                                           if(decisionOnCrR.getRemovedFields().get('Allergan_Customer_Registration_AGN__c')!=null){
                                                               System.debug('No Permission on Fields'+decisionOnCrR.getRemovedFields());
                                                               throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Registration_AGN__c [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: createNewCustomerRegistration]');
                                                           }
                                                           else{
                                                                insert customer;
                                                           }*/
                                                           String objCReg1 = 'Allergan_Customer_Registration_AGN__c';
                                                           SObjectType CrRegObjType = ((SObject)(Type.forName('Schema.'+objCReg1).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCrList,CrRegObjType,'INSERT');
                                                           insert customer;
                                                           //--------------------
                                                          
                                                           
                                                           system.debug('@@@@@ customer @@@@'+customer);
                                                           
                                                           //create sold to address
                                                           customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                                                           customerAddress.Parent_AGN__c = customer.Id;
                                                           customerAddress.Sold_To_AGN__c = true;
                                                           customerAddress.Ship_To_AGN__c = true;
                                                           customerAddress.Bill_To_AGN__c = true;                
                                                           //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c; //This has been taken by Process Builder
                                                           customerAddress.Account_AGN__c = customerContact.AccountId;
                                                           
                                                           if(customer.Country_Code_AGN__c.equalsIgnoreCase('AN')){
                                                               customerAddress.Phone_AGN__c = customerAddress.Phone1_AGN__c;
                                                               customerAddress.Email_AGN__c = customerAddress.Email1_AGN__c; 
                                                           }else{
                                                               customerAddress.Email_AGN__c = customer.Email_AGN__c;
                                                               customerAddress.Mapping_2_AGN__c = customer.Mapping_1_AGN__c; // invoice email
                                                               customerAddress.Phone_AGN__c = customer.Phone_AGN__c;
                                                               customerAddress.Phone_2_AGN__c = customer.Mobile_AGN__c;
                                                               customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                                                           }
                                                           
                                                           customerAddress.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c'
                                                                                           AND DeveloperName = 'New'
                                                                                           LIMIT 1
                                                                                          ][0].Id;
                                                           //------CheckMarx--Added on 24/07/2020----------
                                                         List<Allergan_Customer_Address_AGN__c> tempCrAddrList = new List<Allergan_Customer_Address_AGN__c>(); 
                                                           tempCrAddrList.add(customerAddress);
                                                          /* SObjectAccessDecision decisionOnAddr = Security.stripInaccessible(AccessType.CREATABLE,tempCrAddrList);
                                                           if(decisionOnAddr.getRemovedFields().get('Allergan_Customer_Address_AGN__c')!=null){
                                                               System.debug('No Permission on Fields'+decisionOnAddr.getRemovedFields());
                                                               throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Address_AGN__c [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: createNewCustomerRegistration]');
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
                                                           
                                                           Allergan_Customer_Contact_AGN__c crContact = new Allergan_Customer_Contact_AGN__c();
                                                           crContact.Parent_AGN__c = customer.Id; 
                                                           crContact.Contact_AGN__c = customerContact.Id;
                                                           crContact.First_Name_AGN__c = customer.First_Name_AGN__c;
                                                           crContact.Last_Name_AGN__c  = customer.Last_Name_AGN__c;
                                                           crContact.Email_AGN__c =  customer.Email_AGN__c;
                                                           crContact.Salutation_AGN__c = customer.Salutation_AGN__c;
                                                           crContact.Middle_Name_AGN__c = customer.Middle_Name_AGN__c;
                                                           crContact.Phone_AGN__c = customer.Phone_AGN__c;
                                                           crContact.Primary_Contact_AGN__c = true;
                                                           crContact.Enable_Portal_User_AGN__c = true;                                                           
                                                           if((Boolean)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_HCP_AGN__c') != null){
                                                               crContact.Enable_HCP_AGN__c = (Boolean)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_HCP_AGN__c');
                                                           }else{
                                                               crContact.Enable_HCP_AGN__c = false;
                                                           }
                                                           //------CheckMarx--Added on 23/07/2020----------      
                                                           List<Allergan_Customer_Contact_AGN__c> tempCrCntList = new List<Allergan_Customer_Contact_AGN__c>();
                                                           tempCrCntList.add(crContact);
                                                         /*  SObjectAccessDecision decisionOnCrCnt = Security.stripInaccessible(AccessType.CREATABLE,tempCrCntList);
                                                           if(decisionOnCrCnt.getRemovedFields().get('Allergan_Customer_Contact_AGN__c')!=null){
                                                               throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Contact_AGN__c [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: createNewCustomerRegistration] No Permission on Fields'+ decisionOnCrCnt.getRemovedFields());
                                                           }
                                                           else{
                                                               insert crContact;   
                                                           }*/
                                                           String objCrCnt = 'Allergan_Customer_Contact_AGN__c';
                                                           SObjectType ACRCntObjType = ((SObject)(Type.forName('Schema.'+objCrCnt).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCrCntList,ACRCntObjType,'INSERT');
                                                           insert crContact;
                                                           //--------------------
                                                           
                                                           
                                                           system.debug('@@@@@ crContact @@@@'+crContact); 
                                                           
                                                       } catch (DmlException dx) {
                                                           
                                                           // An exception was caught. We need to revert to our Savepoint
                                                           // This will rollback all successful changes. So, if Case saved successfully
                                                           // and then Address failed, the Case will be rolled back as well
                                                           Database.rollback(sp);
                                                           
                                                           throw new DmlException(dx.getMessage());
                                                       }
                                                       return caseNewCr.Id;
                                                   }
    
    /*
    * @description : Check if user exists in Okta else need to create the user and provide access to the Okta group specified and send welcome mail
    *                If user is present in Okta (users that do not have a status of DEPROVISIONED), need to check if use has access to Okta apps via groups specified. 
    *                If does not have access to that group, need to provide access to that Okta group and send welcome mail
    * @param customer
    * @param customerContact
    * @param userLocale
    * @return returns string success/failure message
    * @modifiedby GCSP Development Team
    * @modifieddate 04-September-2019
    */
    
    public static String createOktaUserSendLink(Allergan_Customer_Registration_AGN__c customer, Contact customerContact, String userLocale) {
        
        String returnMessage = 'FAILURE';
        String countryCode = customer.SAP_Country_Code_AGN__c;
        if(String.isEmpty(countryCode)){
            countryCode = customer.Country_Code_AGN__c;
        }
        //Okta Username = Email of Community User
        String userName = customer.Email_AGN__c;
        
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
                +'"countryCode": "' + countryCode + '",' +
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
                    Contact cont = [Select Okta_Id_AGN__c From Contact Where Id =: customerContact.Id];
                    cont.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Contact
                    //------CheckMarx--Updated on 25/07/2020----------                   
                    //if(Schema.sObjectType.Contact.fields.Okta_Id_AGN__c.isUpdateable()){
                        update cont;
                    //}
                   // else{
                     //   throw new AGN_CommonException('Error: Insufficient Edit Access On Contact [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: createOktaUserSendLink]');
                   // } 
                    //----------------------------------------------
                    
                    //Update oktaId in User's FederationIdentifier
                    updateOktaIdCommunityUser(customer.Email_AGN__c, userOktaId);
                }
                SendExpiryLinkChangePassword(customer, customerContact, userLocale);
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
                    Contact cont = [Select Okta_Id_AGN__c From Contact Where Id =: customerContact.Id];
                    cont.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Contact
                    //------CheckMarx--Updated on 25/07/2020----------   
                    //if(Schema.sObjectType.Contact.fields.Okta_Id_AGN__c.isUpdateable()){
                        update cont;
                   // }
                    //else{
                   //     throw new AGN_CommonException('Error: Insufficient Edit Access On Contact [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: createOktaUserSendLink]');
                   // }  
                    //----------------------------------------------
                   
                    
                    //Update oktaId in User's FederationIdentifier
                    updateOktaIdCommunityUser(customer.Email_AGN__c, userOktaId);
                }
                SendExpiryLinkChangePassword(customer, customerContact, userLocale);
            } else {
                returnMessage = 'DEPROVISIONED';
            }
        }
        
        return returnMessage;
    }
    
    /*
    * @description send email with reset password link
    * @params customer, customerContact, userLocale
    * @return nil 
    * @modifiedby GCSP Development Team
    * @modifieddate 04-September-2019
    */
    
    public static void SendExpiryLinkChangePassword(Allergan_Customer_Registration_AGN__c customer, contact customerContact, String userLocale) {
        String dataToEncrypt;
        String encryptedData;
        String privateKey = AGN_OAMConstant.PRIVATEKEY; //config
        
        AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
        
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(AGN_OAMConstant.TOKENVALIDTILL));
        
        String passwordResetToken = cUtil.getRandomKey();
        
        dataToEncrypt = '{' +
            +'"portalusername": "' + customer.Email_AGN__c + '.' + AGN_OAMConstant.USERNAME_SUFFIX + '",' +
            +'"portaluseremail": "' + customer.Email_AGN__c + '",' +
            +'"customercontactid": "' + customerContact.Id + '",' +
            +'"countrycode": "' + customer.Country_Code_AGN__c + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        //Update generated password reset token with in Contact
        Contact cont = [Select Community_Okta_Password_Reset_Token_AGN__c From Contact Where Id =: customerContact.Id];
        cont.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        //------CheckMarx--Updated on 25/07/2020----------   
       // if(Schema.sObjectType.Contact.fields.Community_Okta_Password_Reset_Token_AGN__c.isUpdateable()){
           update cont;
       // }
       // else{
       //    throw new AGN_CommonException('Error: Insufficient Edit Access On Contact [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: SendExpiryLinkChangePassword]');
        //}  
        //----------------------------------------------
       
        
        SendWelcomeMail(customer, encryptedData,userLocale);  
    }
    
    public static void SendWelcomeMail(Allergan_Customer_Registration_AGN__c customer, String encryptedData, String userLocale){
        Decimal expirationInDays = 0;
        String accepteddate;
        //AGN_OAMConstant.TOKENVALIDTILL/24; 
        
        if(customer.Country_Code_AGN__c.equalsIgnoreCase('FR') || customer.Country_Code_AGN__c.equalsIgnoreCase('AN')){
            expirationInDays = AGN_OAMConstant.TOKENVALIDTILL;
            accepteddate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('dd MMM YYYY');
        }       
        else{
            expirationInDays = AGN_OAMConstant.TOKENVALIDTILL/24;
            accepteddate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd');
        } 
        
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
        else if(customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('AU') || customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('NZ')){
            lang = (String)OAM_User_Settings__c.getValues(customer.SAP_Country_Code_AGN__c).get('User_Language__c');
        }
        else{
            lang = AGN_OAMConstant.USER_LANGUAGE;
        }
        
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.First_Name_AGN__c,
                '{!Recipient.LastName}' => customer.Last_Name_AGN__c,
                '{!Recipient.Email}' => customer.Email_AGN__c,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => accepteddate,
                '{!ExpiryLink}' => AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_OAMPortalAccountActivation?token=' + encryptedData + '&language='+lang
                };
                    
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email_AGN__c, null, null, null, mapSubjectParams, null, mapBodyParams));
        
        String senderEmailAddress = AGN_OAMConstant.SENDEREMAILADDRESS;
        if(listEmailMessageWrapper.size() > 0){
            //second parameter of sendEmail() is email template name (e.g: Self Registration: Welcome Email-DE)
            //System.debug('####Language Code #### '+ AGN_OAMConstant.USER_LANGUAGE.toUpperCase());
            String countryCode = customer.SAP_Country_Code_AGN__c;//Country_Code_AGN__c
            if(countryCode.equalsIgnoreCase('IE')){
                countryCode = 'GB';
            }
            if(string.isEmpty(countryCode)) countryCode = customer.Country_Code_AGN__c;
            
            String userLocaleSid = (String)OAM_User_Settings__c.getValues(countryCode).get('User_Locale__c'); // Country_Code_AGN__c
            String welcomeEmailTemplateName;
            if(countryCode.equalsIgnoreCase('AU') || countryCode.equalsIgnoreCase('NZ')){
                welcomeEmailTemplateName = String.Format('Self Registration: Welcome Email-{0}_{1}',new String[]{countryCode, userLocaleSid});
            }
            else{
                welcomeEmailTemplateName =  String.Format('Self Registration: Welcome Email-{0}',new String[]{lang.toUpperCase()});
            }
            System.debug('####email template name #### '+ welcomeEmailTemplateName);
            sendEmail(listEmailMessageWrapper, welcomeEmailTemplateName, senderEmailAddress);
        }
    }
    
    @future
    public static void updateOktaIdCommunityUser(String communityUserEmail, String okatId) {
        String communityUserName  = communityUserEmail + '.' + AGN_OAMConstant.USERNAME_SUFFIX;
        system.debug('@@@communityUserName>>>'+communityUserName);
        User u = [Select IsActive, IsPortalEnabled From User Where UserName =: communityUserName];
        u.FederationIdentifier = okatId;
        
        //------CheckMarx Phase2--Added on08/09/2020---------- 
        List<User> userList = new List<User>();
        userList.add(u);
        String objUser = 'User';
        SObjectType userObjType = ((SObject)(Type.forName('Schema.'+objUser).newInstance())).getSObjectType();
        AGN_FLSCheck.check(userList,userObjType,'UPDATE');
        update u;
        //----------------------------------------------------
    }
    
    /*@Testvisible
    private static void updateOktaUserIdInAccount(Id customerAccount, String oktaUserId, String passwordResetToken) {
    
    Account acc = [Select Okta_Id_AGN__c, Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccount];
    if (!String.isEmpty(oktaUserId)) {
    acc.Okta_Id_AGN__c = oktaUserId;
    }
    if (!String.isEmpty(passwordResetToken)) {
    acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
    }
    update acc;
    }*/
    
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
        
        //updateOktaUserIdInAccount(customer.Contact.Id, '', passwordResetToken);
        //system.debug('@@@customer>>'+customer.contactID+':::::::'+customer.Contact.Id);
        Contact cont = [Select Community_Okta_Password_Reset_Token_AGN__c From Contact Where Id =: customer.contactID];
        cont.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        //------CheckMarx--Updated on 25/07/2020----------   
        //if(Schema.sObjectType.Contact.fields.Community_Okta_Password_Reset_Token_AGN__c.isUpdateable()){
            update cont;
       // }
       // else{
        //   throw new AGN_CommonException('Error: Insufficient Edit Access On Contact [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: forgotRecoveryQA]');
       // }  
        //----------------------------------------------
        SendMailForgotRecoveryQA(customer, encryptedData, hasOktaRecoveryQuestion);  
    }
    /*
public static void SendMailForgotRecoveryQA(User customer, String encryptedData) {

Decimal expirationInDays = AGN_OAMConstant.TOKENVALIDTILL/24; 
List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
Map<String, String> mapSubjectParams = new Map<String, String>();
Map<String, String> mapBodyParams = new Map<String, String> {
'{!Recipient.FirstName}' => customer.FirstName,
'{!Recipient.LastName}' => customer.LastName,
'{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
'{!ExpiryLink}' => AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_OAMPortalAccountActivation?token=' + encryptedData + '&r=true&language='+customer.LanguageLocaleKey
};

listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email, null, null, null, mapSubjectParams, null, mapBodyParams));
String senderEmailAddress = AGN_OAMConstant.SENDEREMAILADDRESS;
if(listEmailMessageWrapper.size() > 0){
String welcomeEmailTemplateName = String.Format('Self Registration: Reset Security Q&A Email-{0}_{1}',new String[]{customer.Country_Code__c, customer.LocaleSidKey});
//second parameter is email template name (e.g: Self Registration: Reset Security Q&A Email-AU_en_AU)
sendEmail(listEmailMessageWrapper, welcomeEmailTemplateName, senderEmailAddress);
}
}
*/
    public static void SendMailForgotRecoveryQA(User customer, String encryptedData, Boolean hasOktaRecoveryQuestion) {
        
        String emailTemplateName;
        Decimal expirationInDays = AGN_OAMConstant.TOKENVALIDTILL/24; 
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        String expiryLink;
        
        if(hasOktaRecoveryQuestion){
            expiryLink = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_OAMPortalAccountActivation?token=' + encryptedData + '&r=true&language='+customer.LanguageLocaleKey;
        }
        else{
            expiryLink = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_OAMPortalAccountActivation?token=' + encryptedData + '&language='+customer.LanguageLocaleKey;
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
            
            if(customer.Country_Code__c.equalsIgnoreCase('AU') || customer.Country_Code__c.equalsIgnoreCase('NZ')){                
                emailTemplateName = String.Format('Self Registration: Reset Security Q&A Email-{0}_{1}',new String[]{customer.Country_Code__c, customer.LocaleSidKey});
            }else{
                emailTemplateName = String.Format('Self Registration: Reset Security Q&A Email-{0}',new String[]{customer.LanguageLocaleKey});
            }
            
            //second parameter is email template name (e.g: Self Registration: Reset Security Q&A Email-AU_en_AU)
            sendEmail(listEmailMessageWrapper, emailTemplateName, senderEmailAddress);
        }
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
    
    public static Id upsertAddressDetails(Allergan_Customer_Address_AGN__c soldToAddr,
                                          List < Allergan_Customer_Address_AGN__c > billToAddrList,
                                          List < Allergan_Customer_Address_AGN__c > shipToAddrList,
                                          List < Allergan_Customer_Address_AGN__c > newBillToAddrList,
                                          List < Allergan_Customer_Address_AGN__c > newShipToAddrList
                                         ) 
    {
        system.debug('billToAddrList-->' + billToAddrList.size());
        system.debug('shipToAddrList-->' + shipToAddrList.size());
        
        Allergan_Customer_Registration_AGN__c customer = AGN_OAMPortalCustomerRegStep2Controller.getCustomerRegDetails();
        
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
            
            // if account owner is same as created user 
            if(soldToAddr.Are_You_The_Prescribing_Doctor_AGN__c){
                soldToAddr.Doctors_First_Name_AGN__c = customer.First_Name_AGN__c;
                soldToAddr.Doctors_Middle_Name_AGN__c = customer.Middle_Name_AGN__c;
                soldToAddr.Doctors_Last_Name_AGN__c = customer.Last_Name_AGN__c;
                soldToAddr.Doctors_Email_AGN__c = customer.Email_AGN__c;
                soldToAddr.Doctors_Phone_AGN__c = customer.Phone_AGN__c;
            }
            
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
                    customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                    customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                    
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')){
                        customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c; 
                    }                   
                    
                    //add account owner details
                    customerAddress.Doctors_First_Name_AGN__c = soldToAddr.Doctors_First_Name_AGN__c;
                    customerAddress.Doctors_Middle_Name_AGN__c = soldToAddr.Doctors_Middle_Name_AGN__c;
                    customerAddress.Doctors_Last_Name_AGN__c = soldToAddr.Doctors_Last_Name_AGN__c;
                    customerAddress.Doctors_Email_AGN__c = soldToAddr.Doctors_Email_AGN__c;
                    customerAddress.Doctors_Phone_AGN__c = soldToAddr.Doctors_Phone_AGN__c;
                    
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
                    customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;                                      
                    customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                    
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')){
                        customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c; 
                    } 
                    
                    //add account owner details
                    customerAddress.Doctors_First_Name_AGN__c = soldToAddr.Doctors_First_Name_AGN__c;
                    customerAddress.Doctors_Middle_Name_AGN__c = soldToAddr.Doctors_Middle_Name_AGN__c;
                    customerAddress.Doctors_Last_Name_AGN__c = soldToAddr.Doctors_Last_Name_AGN__c;
                    customerAddress.Doctors_Email_AGN__c = soldToAddr.Doctors_Email_AGN__c;
                    customerAddress.Doctors_Phone_AGN__c = soldToAddr.Doctors_Phone_AGN__c;
                    
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
                customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;                   
                customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                
                //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')){
                    customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c; 
                } 
                
                //add account owner details
                customerAddress.Doctors_First_Name_AGN__c = soldToAddr.Doctors_First_Name_AGN__c;
                customerAddress.Doctors_Middle_Name_AGN__c = soldToAddr.Doctors_Middle_Name_AGN__c;
                customerAddress.Doctors_Last_Name_AGN__c = soldToAddr.Doctors_Last_Name_AGN__c;
                customerAddress.Doctors_Email_AGN__c = soldToAddr.Doctors_Email_AGN__c;
                customerAddress.Doctors_Phone_AGN__c = soldToAddr.Doctors_Phone_AGN__c;
                
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
                customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                
                // customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;                
                if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')){
                    customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c; 
                } 
                
                //add account owner details
                customerAddress.Doctors_First_Name_AGN__c = soldToAddr.Doctors_First_Name_AGN__c;
                customerAddress.Doctors_Middle_Name_AGN__c = soldToAddr.Doctors_Middle_Name_AGN__c;
                customerAddress.Doctors_Last_Name_AGN__c = soldToAddr.Doctors_Last_Name_AGN__c;
                customerAddress.Doctors_Email_AGN__c = soldToAddr.Doctors_Email_AGN__c;
                customerAddress.Doctors_Phone_AGN__c = soldToAddr.Doctors_Phone_AGN__c;
                addList.add(customerAddress);
            }
            system.debug('ListcustomerAddress-->' + addList.size());
            system.debug('newShipToAddrList-->' + addList);
            if (!addList.isEmpty()) {                
                //Database.UpsertResult[] rs = Database.upsert(addList, true);           
                //system.debug('rs@@@@@-->'+rs.size());
                //------CheckMarx--Added on 24/07/2020----------   
                /*SObjectAccessDecision decisionOnAddr = Security.stripInaccessible(AccessType.UPSERTABLE,addList);
                if(decisionOnAddr.getRemovedFields().get('Allergan_Customer_Address_AGN__c')!=null){
                    System.debug('fields>>'+decisionOnAddr.getRemovedFields().get('Allergan_Customer_Address_AGN__c'));
                    throw new AGN_CommonException('Error: Insufficient Edit/Create Access On Allergan_Customer_Address_AGN__c [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: upsertAddressDetails] No Permission on fields '+ decisionOnAddr.getRemovedFields().get('Allergan_Customer_Address_AGN__c'));
                }
                else{
                    upsert addList;
                }*/
                
                String obj = 'Allergan_Customer_Address_AGN__c';
                SObjectType ACRAddrObjType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
                AGN_FLSCheck.check(addList,ACRAddrObjType,'UPSERT');
                upsert addList;
                //--------------------
                
                if (customer.Online_Registration_Step_AGN__c == '2') {
                    customer.Online_Registration_Step_AGN__c = '3';
                    //------CheckMarx--Added on 25/07/2020----------  
                    List<Allergan_Customer_Registration_AGN__c> tempCrList = new List<Allergan_Customer_Registration_AGN__c>();
                    tempCrList.add(customer);
                    /*SObjectAccessDecision decisionOnCrReg = Security.stripInaccessible(AccessType.UPDATABLE,tempCrList);
                    if(decisionOnCrReg.getRemovedFields().get('Allergan_Customer_Registration_AGN__c')!=null){
                         System.debug('fields>>'+decisionOnCrReg.getRemovedFields().get('Allergan_Customer_Registration_AGN__c'));
                        throw new AGN_CommonException('Error: Insufficient Edit Access On Allergan_Customer_Registration_AGN__c [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: upsertAddressDetails] No Permission on fields '+ decisionOnCrReg.getRemovedFields().get('Allergan_Customer_Registration_AGN__c'));
                    }
                    else{
                       update customer;
                    }*/
                    String obj2 = 'Allergan_Customer_Registration_AGN__c';
                    SObjectType ACRCRObjType = ((SObject)(Type.forName('Schema.'+obj2).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(tempCrList,ACRCRObjType,'UPDATE');
                    update customer;
                    //--------------------
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
    public static void deleteAddress(Allergan_Customer_Address_AGN__c customerAddress) {
        
        try {            
            delete customerAddress;            
        } catch (DmlException dx) {            
            throw new DmlException(dx.getMessage());
        }
    }
    public static Id upsertCustomerDetails(Allergan_Customer_Registration_AGN__c customer, Allergan_Customer_Address_AGN__c customerAddress, String Specialty) {
        Allergan_Customer_Registration_AGN__c customerOld = AGN_OAMPortalCustomerRegStep2Controller.getCustomerRegDetails();
        
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
            customerOld.Employee_AGN__c = customer.Employee_AGN__c;
            customerOld.Owner_AGN__c = customer.Owner_AGN__c;
            customerOld.Contractor_AGN__c = customer.Contractor_AGN__c;
            customerOld.Professional_Service_Provider_AGN__c = customer.Professional_Service_Provider_AGN__c;            
            
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
            
              //------CheckMarx--Added on 25/07/2020----------
            List<Allergan_Customer_Registration_AGN__c> tempOldCrRegList = new List<Allergan_Customer_Registration_AGN__c>();
            tempOldCrRegList.add(customerOld);   
           /* SObjectAccessDecision decisionOnCrOldReg = Security.stripInaccessible(AccessType.UPDATABLE,tempOldCrRegList);
            if(decisionOnCrOldReg.getRemovedFields().get('Allergan_Customer_Registration_AGN__c')!=null){
                System.debug('No Permission on Fields '+decisionOnCrOldReg.getRemovedFields().get('Allergan_Customer_Registration_AGN__c'));
                throw new AGN_CommonException('Error: Insufficient Edit Access On Allergan_Customer_Registration_AGN__c [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: upsertCustomerDetails]');
            }
            else{
              update customerOld;
            }*/
            String objACR = 'Allergan_Customer_Registration_AGN__c';
            SObjectType ACRCRObjType = ((SObject)(Type.forName('Schema.'+objACR).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempOldCrRegList,ACRCRObjType,'UPDATE');
            update customerOld;
            //---------------------------------------------  
           
            system.debug('@@@customerOld>>>>'+customerOld);
            
            list<Allergan_Customer_Address_AGN__c> customerAddressOldList = AGN_OAMPortalCustomerRegStep2Controller.getCustomerAddressDetails(customerOld.Id); //get all Addresss list
            
            system.debug('customerAddressOld -->' + customerAddressOldList);
            system.debug('customerAddressNew -->' + customerAddress);
            
            list<Allergan_Customer_Address_AGN__c> addList = new list<Allergan_Customer_Address_AGN__c>(); 
            
            if(!customerAddressOldList.isEmpty() && customerAddressOldList.size()>0){           
                for(Allergan_Customer_Address_AGN__c cra : customerAddressOldList ){
                    if(cra.Sold_To_AGN__c){                       
                        if( customerAddress.VAT_Number_AGN__c != null ){
                            cra.VAT_Number_AGN__c = customerAddress.VAT_Number_AGN__c;
                        }
                        if(customerAddress.CUU_Code_AGN__c !=null )
                        {
                            cra.CUU_Code_AGN__c = customerAddress.CUU_Code_AGN__c;
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
                        if(customerAddress.Service_code_AGN__c != null){
                            cra.Service_code_AGN__c = customerAddress.Service_code_AGN__c;
                        }
                        if( customerAddress.DEA_Number_AGN__c != null ){
                            cra.DEA_Number_AGN__c = customerAddress.DEA_Number_AGN__c ;
                        }                        
                        if( customerAddress.State_License_Number_AGN__c != null && customerOld.Country_Code_AGN__c == 'AN'){
                            cra.State_License_Number_AGN__c = customerAddress.State_License_Number_AGN__c;
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
             //------CheckMarx--Added on 25/07/2020----------
           /* SObjectAccessDecision decisionOnSAddR = Security.stripInaccessible(AccessType.UPDATABLE,addList);
            if(decisionOnSAddR.getRemovedFields().get('Allergan_Customer_Address_AGN__c')!=null){
                System.debug('No Permission on Fields '+decisionOnSAddR.getRemovedFields().get('Allergan_Customer_Address_AGN__c'));
                throw new AGN_CommonException('Error: Insufficient Edit Access On Allergan_Customer_Address_AGN__c [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: upsertCustomerDetails]');
            }
            else{
              update addList; 
            }*/
            String objAdr = 'Allergan_Customer_Address_AGN__c';
            SObjectType ACRAddrObjType = ((SObject)(Type.forName('Schema.'+objAdr).newInstance())).getSObjectType();
            AGN_FLSCheck.check(addList,ACRAddrObjType,'UPDATE');
            update addList; 
            //---------------------------------------------  
          
            
            system.debug('@@@addList>>>'+addList);
            
        } catch (DmlException dx) {
            
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
        //if(Schema.sObjectType.User.fields.IsActive.isUpdateable() && Schema.sObjectType.User.fields.IsPortalEnabled.isUpdateable() ){
            update u;
        //}
        //else{
        //    throw new AGN_CommonException('Error: Insufficient Edit Access On User [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: inactivateUser]');
       // }
        //---------------------------------------------
    }
    public static ID finishCustomerRegistration_finalStep(Allergan_Customer_Registration_AGN__c customerReg, 
                                                          Allergan_Customer_Address_AGN__c customerAddress, 
                                                          String formofPayment, String PaymentTerm) 
    {
        
        list < SObject > recordsToUpdate = new list < SObject > ();
        
        Allergan_Customer_Registration_AGN__c customer = AGN_OAMPortalCustomerRegStep2Controller.getCustomerRegDetails();
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
            if (customer.Online_Registration_Step_AGN__c == '4') {
                customer.Online_Registration_Step_AGN__c = '5';
            } 
            
            system.debug('customer--->' + customer.Online_Registration_Step_AGN__c);          
            //customer.Form_of_Payment_AGN__c = formofPayment;           
            // customer.Payment_Term_AGN__c = PaymentTerm;    
            
            if(customer.Country_Code_AGN__c.equalsIgnoreCase('CA')){
                customer.Form_of_Payment_AGN__c = [SELECT ID FROM Form_of_Payment_AGN__c WHERE (Form_Of_Payment_Label_AGN__c =: formofPayment OR Name =: formofPayment) AND Country_code_AGN__c =: customer.Country_Code_AGN__c LIMIT 1].Id;              
                
                system.debug('PaymentTerm--->'+PaymentTerm);
                customer.Payment_Term_AGN__c = [SELECT ID FROM Payment_Term_AGN__c WHERE Form_Of_Payment__c =: customer.Form_of_Payment_AGN__c AND (Name =: PaymentTerm OR Payment_Term_Label_AGN__c =:PaymentTerm) LIMIT 1].Id; 
                
            }
            else if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')){
                customer.Form_of_Payment_AGN__c = formofPayment;
                customer.Payment_Term_AGN__c = [SELECT ID FROM Payment_Term_AGN__c WHERE Form_Of_Payment__c =: formofPayment AND SAP_Payment_Term_Code_AGN__c =: PaymentTerm LIMIT 1].Id;
            }
            
            //------CheckMarx--Added on 25/07/2020----------
            List<Allergan_Customer_Registration_AGN__c> tempCrRegList = new List<Allergan_Customer_Registration_AGN__c>();
            tempCrRegList.add(customer);   
            /*SObjectAccessDecision decisionOnCrReg = Security.stripInaccessible(AccessType.UPDATABLE,tempCrRegList);
            if(decisionOnCrReg.getRemovedFields().get('Allergan_Customer_Registration_AGN__c')!=null){
                throw new AGN_CommonException('Error: Insufficient Edit Access On Allergan_Customer_Registration_AGN__c [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: finishCustomerRegistration_finalStep]');
            }
            else{
             update customer;
            }*/
            String objCrReg = 'Allergan_Customer_Registration_AGN__c';
            SObjectType ACRRegObjType = ((SObject)(Type.forName('Schema.'+objCrReg).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCrRegList,ACRRegObjType,'UPDATE');
            update customer;
            //---------------------------------------------  
           
            
            List < Allergan_Customer_Address_AGN__c > addList = AGN_OAMPortalCustomerRegStep2Controller.getCustomerAddressDetails(customer.Id);
            
            Allergan_Customer_Address_AGN__c SoldToAddress = AGN_OAMPortalCustomerRegStep2Controller.FetchObjectDetails();               
            
            //update SoldToAddress;
            system.debug('SoldToAddress--->' + SoldToAddress);            
            
            system.debug('customerAddress--->' + customerAddress);            
            
            SoldToAddress.Bank_Name_AGN__c = customerAddress.Bank_Name_AGN__c;
            SoldToAddress.Bank_Account_Number_AGN__c = customerAddress.Bank_Account_Number_AGN__c;
            SoldToAddress.Sort_Code_AGN__c = customerAddress.Sort_Code_AGN__c;
            SoldToAddress.IBAN_AGN__c = customerAddress.IBAN_Text_AGN__c;
            SoldToAddress.IBAN_Text_AGN__c = customerAddress.IBAN_Text_AGN__c;
            SoldToAddress.SWIFT_BIC_AGN__c = customerAddress.SWIFT_BIC_AGN__c;
            SoldToAddress.Business_Name_Reference1_AGN__c = customerAddress.Business_Name_Reference1_AGN__c;
            SoldToAddress.Business_Name_Reference2_AGN__c = customerAddress.Business_Name_Reference2_AGN__c;
            SoldToAddress.Business_Name_Reference3_AGN__c = customerAddress.Business_Name_Reference3_AGN__c;
            SoldToAddress.Contact_Name_Reference1_AGN__c = customerAddress.Contact_Name_Reference1_AGN__c;
            SoldToAddress.Contact_Name_Reference2_AGN__c = customerAddress.Contact_Name_Reference2_AGN__c;
            SoldToAddress.Contact_Name_Reference3_AGN__c = customerAddress.Contact_Name_Reference3_AGN__c; 
            SoldToAddress.Phone_Reference1_AGN__c = customerAddress.Phone_Reference1_AGN__c;
            SoldToAddress.Phone_Reference2_AGN__c = customerAddress.Phone_Reference2_AGN__c;
            SoldToAddress.Phone_Reference3_AGN__c = customerAddress.Phone_Reference3_AGN__c;
            SoldToAddress.Fax_Reference1_AGN__c = customerAddress.Fax_Reference1_AGN__c;
            SoldToAddress.Fax_Reference2_AGN__c = customerAddress.Fax_Reference2_AGN__c;
            SoldToAddress.Email_Reference1_AGN__c = customerAddress.Email_Reference1_AGN__c;
            SoldToAddress.Email_Reference2_AGN__c = customerAddress.Email_Reference2_AGN__c;
            SoldToAddress.Email_Reference3_AGN__c = customerAddress.Email_Reference3_AGN__c;
            SoldToAddress.NIF_CIF_number_AGN__c = customerAddress.NIF_CIF_number_AGN__c; // added abdul
            if(customer.Country_Code_AGN__c.equalsIgnoreCase('AN')){
                SoldToAddress.Form_Of_Payment_AGN__c = formofPayment;
                SoldToAddress.Payment_Term_AGN__c = PaymentTerm;
            }else{
                SoldToAddress.Form_Of_Payment_AGN__c = customer.Form_of_Payment_AGN__c;
                SoldToAddress.Payment_Term_AGN__c = customer.Payment_Term_AGN__c;
            }
            
            Boolean isTrue = false;
            if(!SoldToAddress.Are_You_The_Prescribing_Doctor_AGN__c){
                SoldToAddress.Are_You_The_Prescribing_Doctor_AGN__c = true; 
                isTrue = true;
            }
            //------CheckMarx--Added on 25/07/2020----------
            List<Allergan_Customer_Address_AGN__c> tempSAddRList = new List<Allergan_Customer_Address_AGN__c>();
            tempSAddRList.add(SoldToAddress);   
            /*SObjectAccessDecision decisionOnSAddR = Security.stripInaccessible(AccessType.UPDATABLE,tempSAddRList);
            if(decisionOnSAddR.getRemovedFields().get('Allergan_Customer_Address_AGN__c')!=null){
                throw new AGN_CommonException('Error: Insufficient Edit Access On Allergan_Customer_Address_AGN__c [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: finishCustomerRegistration_finalStep]');
            }
            else{
             update SoldToAddress;
            }
            */
            String objSoldto = 'Allergan_Customer_Address_AGN__c';
            SObjectType ACRSoldTObjType = ((SObject)(Type.forName('Schema.'+objSoldto).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempSAddRList,ACRSoldTObjType,'UPDATE');
            update SoldToAddress;
            //---------------------------------------------  
            
           
            
            // Email triggred to prescribing doctor if created user is not prescribing doctor (Wf rule : AGN - Send Customer Registration Request Completion Acknowledgement Email MP AU/NZ)
            if(isTrue){
                SoldToAddress.Are_You_The_Prescribing_Doctor_AGN__c = false;                
            }
            string CountryCode = '';
            if(String.isEmpty(customer.SAP_Country_Code_AGN__c) || customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('IE') || customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('AU')){
                CountryCode = customer.Country_Code_AGN__c;
            }else{
                countrycode = customer.SAP_Country_Code_AGN__c;
            }
            
            if (AGN_GCSP_Settings__c.getValues(countrycode).get('Enable_Bill_To__c') != Null ?
                (boolean) AGN_GCSP_Settings__c.getValues(countrycode).get('Enable_Bill_To__c') : false) { //Country_Code_AGN__c
                    
                    for (Allergan_Customer_Address_AGN__c add: addList) {
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
                                add.Business_Name_Reference3_AGN__c = SoldToAddress.Business_Name_Reference3_AGN__c;
                                add.Contact_Name_Reference1_AGN__c = SoldToAddress.Contact_Name_Reference1_AGN__c;
                                add.Contact_Name_Reference2_AGN__c = SoldToAddress.Contact_Name_Reference2_AGN__c;
                                add.Contact_Name_Reference3_AGN__c = SoldToAddress.Contact_Name_Reference3_AGN__c;                                
                                add.Phone_Reference1_AGN__c = SoldToAddress.Phone_Reference1_AGN__c;
                                add.Phone_Reference2_AGN__c = SoldToAddress.Phone_Reference2_AGN__c;
                                add.Phone_Reference3_AGN__c = SoldToAddress.Phone_Reference3_AGN__c;
                                add.Fax_Reference1_AGN__c = SoldToAddress.Fax_Reference1_AGN__c;
                                add.Fax_Reference2_AGN__c = SoldToAddress.Fax_Reference2_AGN__c;
                                add.Email_Reference1_AGN__c = SoldToAddress.Email_Reference1_AGN__c;
                                add.Email_Reference2_AGN__c = SoldToAddress.Email_Reference2_AGN__c;
                                add.Email_Reference3_AGN__c = SoldToAddress.Email_Reference3_AGN__c;
                                add.Form_Of_Payment_AGN__c = SoldToAddress.Form_Of_Payment_AGN__c;
                                add.Payment_Term_AGN__c = SoldToAddress.Payment_Term_AGN__c;
                                add.Account_Type_AGN__c = SoldToAddress.Account_Type_AGN__c;
                                add.Sub_Type_AGN__c = SoldToAddress.Sub_Type_AGN__c;
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
                            }else{
                                add.Account_Type_AGN__c = SoldToAddress.Account_Type_AGN__c;
                                add.Sub_Type_AGN__c = SoldToAddress.Sub_Type_AGN__c;
                                recordsToUpdate.add(add);
                            }
                        }
                    }
                    
                } 
            
            crCase.Case_Sub_Status_AGN__c = 'Online Registration Completed';
            //crCase.Case_Step_Number_AGN__c = 2;
            
            system.debug('======customerAddress========>' + crCase.RecordType.Name + '==' + crCase.Type + '==' + customer.Country_Code_AGN__c);
            
            crCase.EntitlementId = setEntitlement(crCase.RecordType.Name, crCase.Type, countrycode);//Country_Code_AGN__c
            // recordsToUpdate.add(crCase);
            //------CheckMarx--Added on 24/07/2020----------      
            List<Case> tempCrCaseList = new List<Case>();
            tempCrCaseList.add(crCase);
            /*SObjectAccessDecision decisionOncrCase = Security.stripInaccessible(AccessType.UPDATABLE,tempCrCaseList);
            if(decisionOncrCase.getRemovedFields().get('Case')!=null){
                throw new AGN_CommonException('Error: Insufficient Edit Access On Case [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: finishCustomerRegistration_finalStep]');
            }
            else{
               update crCase;
            }*/
            String objcrCase = 'Case';
            SObjectType ACRCaseType = ((SObject)(Type.forName('Schema.'+objcrCase).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCrCaseList,ACRCaseType,'UPDATE');
            update crCase;
            //---------------------------------------------
            //------CheckMarx--Added on 24/07/2020----------   
            /*SObjectAccessDecision decisionOnCrAddr = Security.stripInaccessible(AccessType.UPDATABLE,recordsToUpdate);
            if(decisionOnCrAddr.getRemovedFields().get('Allergan_Customer_Address_AGN__c')!=null){
                throw new AGN_CommonException('Error: Insufficient Edit Access On Allergan_Customer_Address_AGN__c [Class Name: AGN_OAMPortalCustomerRegUtils and Method Name: finishCustomerRegistration_finalStep]');
            }
            else{
            
            }*/
            String objRecd = 'Allergan_Customer_Address_AGN__c';
            SObjectType ACRecType = ((SObject)(Type.forName('Schema.'+objRecd).newInstance())).getSObjectType();
            AGN_FLSCheck.check(recordsToUpdate,ACRecType,'UPDATE');
            update recordsToUpdate;
            //---------------------------------------------  
            
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
    
    
    public static String getCustomerGroup(String countryCode, String customerType , String customerSubType) {
        
        String customerGroup = '';
        
        if(String.isNotBlank(countryCode)){
            List<Customer_Type_Configuration_AGN__c> configs = new List<Customer_Type_Configuration_AGN__c>([SELECT Id,Customer_Group_AGN__c 
                                                                                                             FROM Customer_Type_Configuration_AGN__c 
                                                                                                             WHERE Customer_Country_AGN__r.Alpha_2_Code_vod__c=:countryCode 
                                                                                                             AND (Category_AGN__c =: customerType OR Category_Label_AGN__c =: customerType ) 
                                                                                                             AND (Sub_Category__c =: customerSubType OR Sub_Category_Label_AGN__c =:customerSubType )]);
            if(configs.size() > 0 && String.isNotBlank(configs.get(0).Customer_Group_AGN__c)){
                customerGroup = configs.get(0).Customer_Group_AGN__c;
            }
        }
        return customerGroup;
    } 
    
}