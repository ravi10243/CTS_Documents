/**
 * @description       : Save the data to  Server for step 1 Registration.
 * @author            : GCSP Core Plus Dev Team
 * @group             : 
 * @last modified on  : 04-15-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   05-01-2021   GCSP Core Plus Dev Team   Initial Version
**/
public without sharing class AGN_GCSP_CustomerRegUtils {
    
    public static boolean checkForDuplicateCustomer(String email, String country) {
        //String USERNAME_SUFFIX =  (String)OAM_User_Settings__c.getValues(country).get('Username_Suffix__c');
        //string newUserName = email + USERNAME_SUFFIX;
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();   
        String newUserName = email + commonOktaConfig.UsernameSuffix_AGN__c;
        for (User u: [select Id from User where UserName =: newUserName and isActive = true limit 1]) {
            return true;
        }
        return false;
    }
    
    public static Map < String, List < AGN_Community_Layout_Setting__mdt > > getLayoutCountrySetting(String country, String stepNo, String customerType, String customerSubType, List < Customer_Type_Configuration_AGN__c > custTypeConfig, String source) {
        String customerGroup = '';
        AGN_Community_Layout_Setting__mdt[] configList = null;
        AGN_Community_Layout_Setting__mdt[] matchingRows = null;
       // Checkmarx GCSP Core+ and HCO Harmonization: Adding below line to avoid SOQL/SOSL Injection - start
       // String regSource = '\'%'+source+'%\''; 
       String regSource = '\'%'+String.escapeSingleQuotes(source)+'%\''; 
       country = String.escapeSingleQuotes(country);
       stepNo = String.escapeSingleQuotes(stepNo);
       // Checkmarx GCSP Core+ and HCO Harmonization: Adding below line to avoid SOQL/SOSL Injection - end
       // if((country.equalsIgnoreCase('AU')||(country.equalsIgnoreCase('NZ'))||(country.equalsIgnoreCase('AN'))) && stepNo == '3') {
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
            ' Picklist_Options_AGN__c, ' +
            ' Help_Text_AGN__c, ' +
            ' Object_Field_Type_AGN__c, ' + 
            ' Is_Controlling_Field_AGN__c, ' +
            ' Controlling_Field_AGN__c, ' +
            ' AGN_Document_Required__c,'+
            ' Controlling_Field_SObject_Name_AGN__c, ' +
            ' Default_Display_On_Load_AGN__c, ' +
            ' Dependent_Field_Show_Criteria_AGN__c,' +
            ' Registration_Source_AGN__c,' +
            ' Customer_Type_AGN__c, ' +
            ' Customer_Sub_Category_AGN__c ' +
            ' FROM AGN_Community_Layout_Setting__mdt ' +
            ' WHERE Country_AGN__c = \'' + country + '\'' +
            ' AND Step_No_AGN__c = \'' + stepNo + '\''+
            ' AND OnUpdatePage_AGN__c = false' +   
            ' AND Registration_Source_AGN__c LIKE ' + regSource + 
            ' AND Display__c = true ORDER BY Section_Header_Sort_Order_AGN__c, Sort_Order_AGN__c';
        
        /* System.debug('queryStr3 es: '+queryStr3);
            if (customerType != null && customerSubType != null){
                configList = Database.query(queryStr3);
                
                matchingRows = findMatchingRowsbyTypeSubType(configList, customerType, customerSubType);
                return groupByField('Section_Header_AGN__c', matchingRows);
            }*/
      // }
      
        System.debug('queryStr es: '+queryStr);
        if (customerType == null && customerSubType == null && (custTypeConfig == null || custTypeConfig.isEmpty())) {
            configList = Database.query(queryStr);
            system.debug('configList>>>>>>>>>>>'+configList);
            return groupByField('Section_Header_AGN__c', configList);
        } else if (customerType != null && customerSubType != null && (custTypeConfig == null || custTypeConfig.isEmpty())) {
            
            //custTypeConfig.isEmpty()=> need to fetch Customer_Group_AGN__c from server
            String countryCode;
            if(country.equalsIgnoreCase('AU')) { //country.equalsIgnoreCase('NZ') ||
                countryCode = 'AN';
            }
            else{
                countryCode = country;
            }
            
            Customer_Type_Configuration_AGN__c[] confList = [SELECT
                                                             Customer_Group_AGN__c
                                                             FROM Customer_Type_Configuration_AGN__c
                                                             where Category_AGN__c =: customerType
                                                             and Sub_Category__c =: customerSubType
                                                             and Customer_Country_AGN__r.Alpha_2_Code_vod__c =: countryCode
                                                             limit 1];
            
            
            if (confList != null && !confList.isEmpty()) {
                customerGroup = confList[0].Customer_Group_AGN__c;
                configList = Database.query(queryStr);
                //matchingRows = findMatchingRows(configList, customerGroup);
                matchingRows = findMatchingRowsbyTypeSubType(configList, customerType, customerSubType, customerGroup);
                system.debug('matchingRows>>>>>>>>>>>'+matchingRows);
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
                
                //matchingRows = findMatchingRows(configList, customerGroup);
                matchingRows = findMatchingRowsbyTypeSubType(configList, customerType, customerSubType, customerGroup);
                return groupByField('Section_Header_AGN__c', matchingRows);
            }
        }
        
        return groupByField('Section_Header_AGN__c', configList);
    }
    
     public static Map < String, List < AGN_Community_Layout_Setting__mdt > > getLayoutCountrySettingUpdateReg(String country, String stepNo, String customerType, String customerSubType, List < Customer_Type_Configuration_AGN__c > custTypeConfig, String source) {
        String customerGroup = '';
        AGN_Community_Layout_Setting__mdt[] configList = null;
        AGN_Community_Layout_Setting__mdt[] matchingRows = null;
        
       // Checkmarx GCSP Core+ and HCO Harmonization: Adding below line to avoid SOQL/SOSL Injection - start
       // String regSource = '\'%'+source+'%\''; 
       String regSource = '\'%'+String.escapeSingleQuotes(source)+'%\''; 
       country = String.escapeSingleQuotes(country);
       stepNo = String.escapeSingleQuotes(stepNo);
       // Checkmarx GCSP Core+ and HCO Harmonization: Adding below line to avoid SOQL/SOSL Injection - end
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
            ' Picklist_Options_AGN__c, ' +
            ' Help_Text_AGN__c, ' +
            ' Object_Field_Type_AGN__c, ' + 
            ' Is_Controlling_Field_AGN__c, ' +
            ' Controlling_Field_AGN__c, ' +
            ' AGN_Document_Required__c,'+
            ' Controlling_Field_SObject_Name_AGN__c, ' +
            ' Default_Display_On_Load_AGN__c, ' +
            ' Dependent_Field_Show_Criteria_AGN__c,' +
            ' Registration_Source_AGN__c, ' +
            ' Customer_Type_AGN__c, ' +
            ' Customer_Sub_Category_AGN__c ' +
            ' FROM AGN_Community_Layout_Setting__mdt ' +
            ' WHERE Country_AGN__c = \'' + country + '\'' +
            ' AND Step_No_AGN__c = \'' + stepNo + '\''+
            ' AND OnNewRegPage_AGN__c = false' + 
            ' AND Registration_Source_AGN__c LIKE ' + regSource + 
            ' AND Display__c = true ORDER BY Section_Header_Sort_Order_AGN__c, Sort_Order_AGN__c';
        
        System.debug('queryStr es: '+queryStr);
        if (customerType == null && customerSubType == null && (custTypeConfig == null || custTypeConfig.isEmpty())) {
            configList = Database.query(queryStr);
            system.debug('configList>>>>>>>>>>>'+configList);
            return groupByField('Section_Header_AGN__c', configList);
        } else if (customerType != null && customerSubType != null && (custTypeConfig == null || custTypeConfig.isEmpty())) {
            
            //custTypeConfig.isEmpty()=> need to fetch Customer_Group_AGN__c from server
            String countryCode;
            if(country.equalsIgnoreCase('AU')) { //country.equalsIgnoreCase('NZ') ||
                countryCode = 'AN';
            }
            else{
                countryCode = country;
            }
            
            Customer_Type_Configuration_AGN__c[] confList = [SELECT
                                                             Customer_Group_AGN__c
                                                             FROM Customer_Type_Configuration_AGN__c
                                                             where Category_AGN__c =: customerType
                                                             and Sub_Category__c =: customerSubType
                                                             and Customer_Country_AGN__r.Alpha_2_Code_vod__c =: countryCode
                                                             limit 1];
            
            
            if (confList != null && !confList.isEmpty()) {
                customerGroup = confList[0].Customer_Group_AGN__c;
                configList = Database.query(queryStr);
                //matchingRows = findMatchingRows(configList, customerGroup);
                matchingRows = findMatchingRowsbyTypeSubType(configList, customerType, customerSubType, customerGroup);
                system.debug('matchingRows>>>>>>>>>>>'+matchingRows);
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
                
                //matchingRows = findMatchingRows(configList, customerGroup);
                matchingRows = findMatchingRowsbyTypeSubType(configList, customerType, customerSubType, customerGroup);
                return groupByField('Section_Header_AGN__c', matchingRows);
            }
        }
        
        return groupByField('Section_Header_AGN__c', configList);
    }
    
    @TestVisible
    private static List < AGN_Community_Layout_Setting__mdt > findMatchingRows(AGN_Community_Layout_Setting__mdt[] configList, String customerGroup) {
        List < AGN_Community_Layout_Setting__mdt > matchedConfig = new List < AGN_Community_Layout_Setting__mdt > ();
        for (AGN_Community_Layout_Setting__mdt layout: configList) {
            List < String > lstCustGrp = String.isNotEmpty(layout.Customer_Groups_AGN__c) ? layout.Customer_Groups_AGN__c.split(',') : new list<String>();
            if(!lstCustGrp.isEmpty())
            {
                for (String grp: lstCustGrp) {
                    String cg = grp.trim();
                    if (cg.equalsIgnoreCase(customerGroup)) {
                        matchedConfig.add(layout);
                        
                        break;
                    }
                }
            }
            else{
                 matchedConfig.add(layout);
            }          
           
        }
        system.debug('matchedConfig::::'+matchedConfig); 
        
        return matchedConfig;
    }
    @TestVisible
    private static List < AGN_Community_Layout_Setting__mdt > findMatchingRowsbyTypeSubType(AGN_Community_Layout_Setting__mdt[] configList, String customerType, String customerSubType, String customerGroup) {
        List < AGN_Community_Layout_Setting__mdt > matchedConfig = new List < AGN_Community_Layout_Setting__mdt > ();
        
        for (AGN_Community_Layout_Setting__mdt layout: configList) {
            List < String > lstcustomerType = String.isNotEmpty(layout.Customer_Type_AGN__c) ? layout.Customer_Type_AGN__c.split(',') : new list<String>();
            List < String > lstcustomerSubType = String.isNotEmpty(layout.Customer_Sub_Category_AGN__c) ? layout.Customer_Sub_Category_AGN__c.split(',') : new list<String>();
			List < String > lstCustGrp = String.isNotEmpty(layout.Customer_Groups_AGN__c) ? layout.Customer_Groups_AGN__c.split(',') : new list<String>();
            system.debug('lstcustomerType::::'+lstcustomerType);
            system.debug('lstcustomerSubType::::'+lstcustomerSubType);
            if(!lstcustomerType.isEmpty() && !lstcustomerSubType.isEmpty())
            {
                for (String type: lstcustomerType) {
                    if (type.equalsIgnoreCase(customerType)) {
                        for (String subtype: lstcustomerSubType) {
                            if (subtype.equalsIgnoreCase(customerSubType)) {
                                matchedConfig.add(layout);
                                System.debug('layout::::'+layout);
                                break;
                            }
                        }
                        break;
                    }
                }
            }else if(!lstCustGrp.isEmpty()){
				for (String grp: lstCustGrp) {
					String cg = grp.trim();
					if (cg.equalsIgnoreCase(customerGroup)) {
						matchedConfig.add(layout);
							
						break;
					}
				}
								     
			}else{
				matchedConfig.add(layout);
			} 			
            
        }
        
        return matchedConfig;
    }
    
    @TestVisible
    private static Map < String, List < AGN_Community_Layout_Setting__mdt > > groupByField(String field, List < AGN_Community_Layout_Setting__mdt > records) {
        system.debug('confList records>>>>>>>>>>>'+records);
        Map < String, List < AGN_Community_Layout_Setting__mdt > > grouped = new Map < String, List < AGN_Community_Layout_Setting__mdt > > ();
        if (records != null && records.size() > 0) {
            for (AGN_Community_Layout_Setting__mdt record: records) {
                system.debug('record id>>>>>>>>>>>>>>'+record.id);
                system.debug('key>>>>>>>>>>>>>>>>>>>>'+(String) record.get(field));
                String key = (String) record.get(field);
                if (!grouped.containsKey(key)) {
                    grouped.put(key, new List < AGN_Community_Layout_Setting__mdt > ());
                }
                grouped.get(key).add(record);
            }
        }
        system.debug('Layout Configs>>>>>>>>>>>>>>>>>>>>'+grouped);
        return grouped;
    }
    
    public static Account createAccount(Allergan_Customer_Address_AGN__c customerAddress, Allergan_Customer_Registration_AGN__c customer, String countryCode) {
        
        Account customerAccount = new Account();
        
        try {
            if(countryCode.equalsIgnoreCase('BR')){
                customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;   
            }else{
                customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
            }
            
            customerAccount.Name = customerAddress.Company_Name_AGN__c;
            customerAccount.OwnerId = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('CR_Record_Owner__c');
            customerAccount.Phone = customerAddress.Phone_AGN__c;
            customerAccount.Country_Code__c = customer.Country_Code_AGN__c;
            customerAccount.SAP_Country_Code_AGN__c = customer.SAP_Country_Code_AGN__c;
            if(customer != null) customerAccount.Customer_Sub_Category_AGN__c = customer.Customer_Sub_Category_AGN__c;            
            
            
            //------CheckMarx--Added on 25/07/2020----------      
            List<Account> tempAcList = new List<Account>();
            tempAcList.add(customerAccount);
            
            String objAcc = 'Account';
            SObjectType AccObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempAcList,AccObjType,'INSERT');
            insert customerAccount;
            
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
        return customerAccount;
    }
    
    public static Contact createContact(Allergan_Customer_Registration_AGN__c customer, Account acc, String countryCode) {
        
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
            customerContact.OwnerId = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('CR_Record_Owner__c');
            customerContact.Customer_Registration_AGN__c = 'In Progress';
            customerContact.Customer_Managed_AGN__c = true;
            customerContact.Country_vod__c = customer.Country_AGN__c;
            customerContact.SAP_Country_Code_AGN__c = customer.SAP_Country_Code_AGN__c;
            customerContact.Is_Primary_Contact_AGN__c = true;
            //customerContact.Portal_Access_AGN__c = 'OAM';
            //------CheckMarx--Added on 25/07/2020----------      
            List<Contact> tempCrCsList = new List<Contact>();
            tempCrCsList.add(customerContact);              
            String objCRCase = 'Contact';
            SObjectType CsObjType = ((SObject)(Type.forName('Schema.'+objCRCase).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCrCsList,CsObjType,'INSERT');
            insert customerContact;
            //---------------------------------------------
            
            system.debug('@@@@@ customerContact @@@@@'+customerContact);
            
            customerContact = [select Id, AccountId,Name, FirstName,Country_vod__c, Customer_Managed_AGN__c,Middle_Name_AGN__c,
                               LastName,Email, Phone, Country_Code__c,SAP_Country_Code_AGN__c,Customer_Registration_AGN__c,
                               Account.Customer_Sub_Category_AGN__c from Contact where Id =: customerContact.Id limit 1];
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
        
        return customerContact;
    }
    
    public static Id createCommunityUser(Id customerContactId, String countryCode, string selectedUserLocale) {  
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        string alias = '';
        Contact customer = [select Id, Name,Country_Code__c, Account.Customer_Sub_Category_AGN__c, FirstName, LastName, Email, Phone
                            from Contact
                            where Id =: customerContactId limit 1];
        string SapCountryCode = '';
        if(countryCode.equalsIgnoreCase('IE')) {
            countryCode = 'GB';
            SapCountryCode = 'IE';
        }else if(countryCode.equalsIgnoreCase('AU') || countryCode.equalsIgnoreCase('AN') || countryCode.equalsIgnoreCase('NZ')){
            SapCountryCode = countryCode.equalsIgnoreCase('NZ') ? 'NZ' : 'AU';
            countryCode = 'AN';
            
        }else{
            SapCountryCode = countryCode;
        }
        OAM_User_Settings__c allDetails = new OAM_User_Settings__c();
        if(!string.isEmpty(SapCountryCode)) {
            allDetails = OAM_User_Settings__c.getInstance(SapCountryCode);
        }
        
        User customerUser = new User();
        system.debug('@@@@selectedUserLocale>>>> '+selectedUserLocale);
        system.debug('@@@@countryCode>>>> '+countryCode);
        if(countryCode.equalsIgnoreCase('CA')) {
            if(!String.isEmpty(selectedUserLocale)) {
                if(selectedUserLocale.containsIgnoreCase('en')) {
                    customerUser.LanguageLocaleKey = 'en_US';
                    customerUser.LocalesIdKey = 'en_CA';
                }else if(selectedUserLocale.containsIgnoreCase('fr')) {
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
            String profileName = allDetails.User_Profile__c; 
            customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: profileName limit 1]?.Id;
            
            String USERNAME_SUFFIX =  commonOktaConfig.UsernameSuffix_AGN__c; //(String)OAM_User_Settings__c.getValues(countryCode).get('Username_Suffix__c');
            String suffix = !String.isEmpty(USERNAME_SUFFIX) ? USERNAME_SUFFIX : '';
            String sfdcUserName = customer.Email.toLowercase() + suffix;
            //String USERNAME_SUFFIX =  sfdcUserName;
            customerUser.UserName = sfdcUserName;
            customerUser.ContactId = customer.Id;
            customerUser.Country_Code__c = countryCode;
            customerUser.Division = customer.Account.Customer_Sub_Category_AGN__c;
            //customerUser.FederationIdentifier = customer.Email.toLowercase(); //SSO Mapping has been shifted to createOktaUserSendLink() method
            customerUser.MA_User_Country_Code_AGN__c=SapCountryCode; // added for gb step2 subtype mismatch
            //------CheckMarx--Added on 25/07/2020----------      
            List<User> tempuserList = new List<User>();
            tempuserList.add(customerUser);
            String objCRUser = 'User';
            SObjectType CRUserObjType = ((SObject)(Type.forName('Schema.'+objCRUser).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempuserList,CRUserObjType,'INSERT');
            insert customerUser;
            
            system.debug('@@@@@ customerUser @@@@'+customerUser);            
            
            
        } catch (DmlException dx) {
            system.debug('Exception in create community user ::: '+dx.getMessage());
            throw new DmlException(dx.getMessage());
        }
        return customerUser.Id;
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
    
    public static Id createNewCustomerRegistration(Allergan_Customer_Registration_AGN__c customer,
                                                   Allergan_Customer_Address_AGN__c customerAddress,
                                                   List < Customer_Type_Configuration_AGN__c > configList,
                                                   Contact customerContact,
                                                   String selectedUserLocale) {
                                                       List < Customer_Type_Configuration_AGN__c > custTypeconfigList = new List < Customer_Type_Configuration_AGN__c >();
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
                                                           caseNewCr.AccountId = customerContact.AccountId;
                                                           caseNewCr.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case'
                                                                                     AND DeveloperName = 'AGN_Support_Request_Customer_Registration'
                                                                                     LIMIT 1
                                                                                    ][0].Id;
                                                           caseNewCr.SuppliedName = customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c;
                                                           caseNewCr.SuppliedEmail = customer.Email_AGN__c;
                                                           caseNewCr.SuppliedPhone = customer.Phone_AGN__c;
                                                           caseNewCr.Case_Sub_Status_AGN__c = 'Online Registration - In Progress';
                                                           caseNewCr.Country_Code_AGN__c = customer.Country_Code_AGN__c;
                                                           caseNewCr.Business_Unit_AGN__c = customer.Business_Unit_AGN__c;
                                                           caseNewCr.Id = customer.Case_AGN__c;
                                                           
                                                           //------CheckMarx--Added on 25/07/2020----------      
                                                          
                                                           List<Case> tempCrCsList = new List<Case>();
                                                           tempCrCsList.add(caseNewCr);              
                                                           String objCRCase = 'Case';
                                                           SObjectType CsObjType = ((SObject)(Type.forName('Schema.'+objCRCase).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCrCsList,CsObjType,'UPSERT');
                                                           upsert caseNewCr;
                                                           //---------------------------------------------
                                                           
                                                           system.debug('@@@@@ UserInfo @@@@'+UserInfo.getName()+'::::'+UserInfo.getUserId());
                                                           
                                                           //String OwnerId = UserInfo.getUserType()== 'Guest' ? UserInfo.getUserId() : [SELECT CreatedById FROM Case Where Id =:caseNewCr.Id].CreatedById;
                                                           caseNewCr.OwnerId = UserInfo.getUserId();
                                                           //update caseNewCr;
                                                           //------CheckMarx--Added on 25/07/2020----------      
                                                          /* List<Case> tempCsList = new List<Case>();
                                                           tempCsList.add(caseNewCr);              
                                                           String objCase = 'Case';
                                                           SObjectType objType = ((SObject)(Type.forName('Schema.'+objCase).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCsList,objType,'UPDATE');
                                                           update caseNewCr; */
                                                           //---------------------------------------------
                                                           
                                                           
                                                           
                                                           system.debug('@@@@@ caseNewCr @@@@'+caseNewCr.Id+':::::'+caseNewCr.OwnerId+':::'+caseNewCr.Owner.Name);
                                                           
                                                           //create customer registration
                                                           customer.Portal_Access_AGN__c = 'OAM';
                                                           customer.Online_Registration_Step_AGN__c = '2';
                                                           customer.Online_Registration_AGN__c = true;
                                                           String lang;
                                                           if(customer.Country_Code_AGN__c.equalsIgnoreCase('CA')) {
                                                               if(!String.isEmpty(selectedUserLocale)) {
                                                                   if(selectedUserLocale.containsIgnoreCase('en')) {
                                                                       lang = 'en_US';
                                                                   }else if(selectedUserLocale.containsIgnoreCase('fr')) {
                                                                       lang = 'fr';
                                                                   }
                                                                   else{
                                                                       //lang = AGN_OAMConstant.USER_LANGUAGE;
                                                                       lang = selectedUserLocale;
                                                                   }
                                                               }
                                                               else{
                                                                   //lang = AGN_OAMConstant.USER_LANGUAGE;
                                                                   lang = selectedUserLocale;
                                                               }
                                                           }
                                                           else if(customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('AU') || customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('NZ')) {
                                                               //lang = (String)OAM_User_Settings__c.getValues(customer.SAP_Country_Code_AGN__c).get('User_Language__c');
                                                               lang = selectedUserLocale;
                                                           }
                                                           else{
                                                               //lang = AGN_OAMConstant.USER_LANGUAGE;
                                                               lang = selectedUserLocale;
                                                           }
                                                           
                                                           customer.Language_AGN__c = (String.isEmpty(customer.Language_AGN__c)) ? lang : customer.Language_AGN__c;
                                                           
                                                           customer.Case_AGN__c = caseNewCr.Id;
                                                           customer.Trigger_Validation_of_Children__c = false;
                                                           customer.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c'
                                                                                    AND DeveloperName = 'New'
                                                                                    LIMIT 1
                                                                                   ][0].Id;
                                                           mapCustomerType(configList, customerAddress, customer);
                                                           String OWNER_ID = (String)AGN_GCSP_Settings__c.getValues(customer.SAP_Country_Code_AGN__c).get('CR_Record_Owner__c');
                                                           customer.OwnerId = OWNER_ID;
                                                           customer.Processed_By_SAP_AGN__c = 'In Progress';            
                                                           customer.Allergan_Direct_Access_Requested_AGN__c = true; //Allergan Direct enablement
                                                           
                                                           //------CheckMarx--Added on 25/07/2020----------      
                                                           List<Allergan_Customer_Registration_AGN__c> tempCRList = new List<Allergan_Customer_Registration_AGN__c>();
                                                           tempCRList.add(customer);              
                                                           String objCustomer = 'Allergan_Customer_Registration_AGN__c';
                                                           SObjectType objCRType = ((SObject)(Type.forName('Schema.'+objCustomer).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCRList,objCRType,'UPSERT');
                                                           upsert customer;
                                                           //---------------------------------------------
                                                           
                                                           system.debug('@@@@@ customer @@@@'+customer);
                                                           
                                                           //create sold to address                                                           
                                                           customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                                                           
                                                           customerAddress.Parent_AGN__c = customer.Id;
                                                           customerAddress.Sold_To_AGN__c = true;
                                                           //customerAddress.Ship_To_AGN__c = true;
                                                           //customerAddress.Bill_To_AGN__c = true;
                                                           //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c; //This has been taken by Process Builder
                                                           customerAddress.Account_AGN__c = customerContact.AccountId;
                                                           
                                                           if(customer.Country_Code_AGN__c.equalsIgnoreCase('AN') || customer.Country_Code_AGN__c.equalsIgnoreCase('AU') ||
                                                             customer.Country_Code_AGN__c.equalsIgnoreCase('NZ')) {
                                                               customerAddress.Phone_AGN__c = customer.Phone_AGN__c;
                                                               customerAddress.Email_AGN__c = customer.Email_AGN__c;
                                                           }else{
                                                               customerAddress.Email_AGN__c = customer.Email_AGN__c;
                                                               customerAddress.Mapping_2_AGN__c = String.isNotEmpty(customerAddress.Mapping_2_AGN__c) ? customerAddress.Mapping_2_AGN__c : customer.Mapping_1_AGN__c;                                                // invoice email
                                                               customerAddress.Phone_AGN__c = customer.Phone_AGN__c;
                                                               customerAddress.Phone_2_AGN__c = String.isNotEmpty(customerAddress.Phone_2_AGN__c) ? customerAddress.Phone_2_AGN__c : customer.Mobile_AGN__c;
                                                               customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                                                           }
                                                           
                                                           customerAddress.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c'
                                                                                           AND DeveloperName = 'New'
                                                                                           LIMIT 1
                                                                                          ][0].Id;
                                                           string countryCodeVal = customer.SAP_Country_Code_AGN__c;
                                                           if(String.isEmpty(countryCodeVal)){
                                                               countryCodeVal = customer.Country_Code_AGN__c;
                                                           }
                                                           
                                                           countryCodeVal = countryCodeVal.equalsIgnoreCase('AU') ? 'AN' : countryCodeVal;                                                           
                                                           //customerAddress.Country_AGN__c = [SELECT AGN_Country_Name__c FROM Country_vod__c WHERE Alpha_2_Code_vod__c =:countryCodeVal LIMIT 1][0].AGN_Country_Name__c;
                                                           customerAddress.Country_AGN__c = String.isNotEmpty(customerAddress.Country_AGN__c)?customerAddress.Country_AGN__c: [SELECT AGN_Country_Name__c FROM Country_vod__c WHERE Alpha_2_Code_vod__c =:countryCodeVal LIMIT 1]?.AGN_Country_Name__c;
                                                           //------CheckMarx--Added on 25/07/2020----------      
                                                           List<Allergan_Customer_Address_AGN__c> tempCRAList = new List<Allergan_Customer_Address_AGN__c>();
                                                           tempCRAList.add(customerAddress);              
                                                           String objCustomerAdd = 'Allergan_Customer_Address_AGN__c';
                                                           SObjectType objCRAType = ((SObject)(Type.forName('Schema.'+objCustomerAdd).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCRAList,objCRAType,'INSERT');
                                                           upsert customerAddress;
                                                           //---------------------------------------------
                                                           
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
                                                           crContact.Allergan_Direct_Access_Requested_AGN__c = true;
                                                           if((Boolean)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_HCP_AGN__c') != null) {
                                                               crContact.Enable_HCP_AGN__c = (Boolean)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_HCP_AGN__c');
                                                           }else{
                                                               crContact.Enable_HCP_AGN__c = false;
                                                           }
                                                           
                                                            
                                                           //------CheckMarx--Added on 25/07/2020----------      
                                                           List<Allergan_Customer_Contact_AGN__c> tempCRContactList = new List<Allergan_Customer_Contact_AGN__c>();
                                                           tempCRContactList.add(crContact);              
                                                           String objCRContact = 'Allergan_Customer_Contact_AGN__c';
                                                           SObjectType objCRContactType = ((SObject)(Type.forName('Schema.'+objCRContact).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCRContactList,objCRContactType,'UPSERT');
                                                           upsert crContact;
                                                           //---------------------------------------------
                                                           
                                                           system.debug('@@@@@ crContact @@@@'+crContact);
                                                           // Change Added for PMO -2151 : Contact Affiliation with SoldTo, ShipTo,BillTo address....
                                                           String addConId;
                                                           for(Allergan_Address_Contact_Mapping_agn__c con : [SELECT Id, Allergan_Customer_Address_agn__c, 
                                                                                                                     Allergan_Customer_Contact_agn__c,
                                                                                                                     Allergan_Customer_Registration_agn__c 
                                                                                                                     FROM Allergan_Address_Contact_Mapping_agn__c WHERE Allergan_Customer_Address_agn__c =: customerAddress.Id
                                                                                                                     AND Allergan_Customer_Contact_agn__c =: crContact.Id
                                                                                                                     AND Allergan_Customer_Registration_agn__c =: customer.Id LIMIT 1]){
                                                                                                                     
                                                                                            if(string.isNotEmpty(con.Id)){
                                                                                                addConId = con.Id;
                                                                                            }
                                                           
                                                           
                                                           }
                                                           // Change Added for PMO -2151 : Contact Affiliation with SoldTo, ShipTo,BillTo address....
                                                           Allergan_Address_Contact_Mapping_agn__c contactMappingObj = new Allergan_Address_Contact_Mapping_agn__c();
                                                           contactMappingObj.Allergan_Customer_Address_agn__c = customerAddress.Id;
                                                           contactMappingObj.Allergan_Customer_Contact_agn__c = crContact.Id;
                                                           contactMappingObj.Allergan_Customer_Registration_agn__c = customer.Id;
                                                           if(string.isNotEmpty(addConId)){
                                                               contactMappingObj.Id = addConId;
                                                           }
                                                           
                                                           List<Allergan_Address_Contact_Mapping_agn__c> contactMappingObjList = new List<Allergan_Address_Contact_Mapping_agn__c>();
                                                           contactMappingObjList.add(contactMappingObj);              
                                                           String objcontactMapping = 'Allergan_Address_Contact_Mapping_agn__c';
                                                           SObjectType objcontactMappingType = ((SObject)(Type.forName('Schema.'+objcontactMapping).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(contactMappingObjList,objcontactMappingType,'UPSERT');
                                                           upsert contactMappingObj;
                                                           
                                                           system.debug('@@@@@ contactMappingObj @@@@'+contactMappingObj);
                                                            // Change Ended for PMO -2151 : Contact Affiliation with SoldTo, ShipTo,BillTo address....
                                                           
                                                       } catch (DmlException dx) {
                                                           
                                                           // An exception was caught. We need to revert to our Savepoint
                                                           // This will rollback all successful changes. So, if Case saved successfully
                                                           // and then Address failed, the Case will be rolled back as well
                                                           Database.rollback(sp);
                                                           
                                                           throw new DmlException(dx.getMessage());
                                                       }
                                                       return caseNewCr.Id;
                                                   }
    public static Id createNewCustomerRegistrationCS(Allergan_Customer_Registration_AGN__c customer,
                                                   Allergan_Customer_Address_AGN__c customerAddress,
                                                   List < Customer_Type_Configuration_AGN__c > configList,
                                                   Contact customerContact,
                                                   Case caseCr,
                                                   Allergan_Customer_Contact_AGN__c acrContact,
                                                   String selectedUserLocale) {
                                                       
                                                       Savepoint sp = Database.setSavepoint();
                                                       Case caseNewCr = new Case();
                                                       try {
                                                           //create case
                                                           caseNewCr.Service_AGN__c = 'Customer Registration';
                                                           caseNewCr.Type = 'New';
                                                           caseNewCr.Reason = 'New Customer Registration';
                                                           caseNewCr.Priority = 'Medium';
                                                           caseNewCr.Origin = 'Email';
                                                           caseNewCr.Status = 'New';
                                                           //caseNewCr.Subject = customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c + ' - ' + caseNewCr.Type;
                                                           //caseNewCr.ContactId = customerContact.Id;
                                                           caseNewCr.AccountId = customerAddress.Account_AGN__c;
                                                           caseNewCr.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case'
                                                                                     AND DeveloperName = 'AGN_Support_Request_Customer_Registration'
                                                                                     LIMIT 1
                                                                                    ][0].Id;
                                                           caseNewCr.SuppliedName = customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c;
                                                           caseNewCr.SuppliedEmail = customer.Email_AGN__c;
                                                           caseNewCr.SuppliedPhone = customer.Phone_AGN__c;
                                                           caseNewCr.Case_Sub_Status_AGN__c = 'Online Registration - In Progress';
                                                           caseNewCr.Country_Code_AGN__c = customer.Country_Code_AGN__c;
                                                           caseNewCr.Business_Unit_AGN__c = customer.Business_Unit_AGN__c;
                                                           caseNewCr.Id = (String.isEmpty(customer.Case_AGN__c))? null : customer.Case_AGN__c;
                                                           
                                                           //------CheckMarx--Added on 25/07/2020----------      
                                                           
                                                           List<Case> tempCrCsList = new List<Case>();
                                                           tempCrCsList.add(caseNewCr);              
                                                           String objCRCase = 'Case';
                                                           SObjectType CsObjType = ((SObject)(Type.forName('Schema.'+objCRCase).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCrCsList,CsObjType,'UPSERT');
                                                           upsert caseNewCr;
                                                           //---------------------------------------------
                                                           
                                                           system.debug('@@@@@ UserInfo @@@@'+UserInfo.getName()+'::::'+UserInfo.getUserId());
                                                           
                                                           //String OwnerId = UserInfo.getUserType()== 'Guest' ? UserInfo.getUserId() : [SELECT CreatedById FROM Case Where Id =:caseNewCr.Id].CreatedById;
                                                           caseNewCr.OwnerId = UserInfo.getUserId();
                                                           //update caseNewCr;
                                                           //------CheckMarx--Added on 25/07/2020----------      
                                                          /* List<Case> tempCsList = new List<Case>();
                                                           tempCsList.add(caseNewCr);              
                                                           String objCase = 'Case';
                                                           SObjectType objType = ((SObject)(Type.forName('Schema.'+objCase).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCsList,objType,'UPDATE');
                                                           update caseNewCr; */
                                                           //---------------------------------------------
                                                            
                                                           
                                                           
                                                           system.debug('@@@@@ caseNewCr @@@@'+caseNewCr.Id+':::::'+caseNewCr.OwnerId+':::'+caseNewCr.Owner.Name);
                                                           
                                                           //create customer registration
                                                           customer.Portal_Access_AGN__c = 'OAM';
                                                           customer.Online_Registration_Step_AGN__c = '2';
                                                           customer.Online_Registration_AGN__c = customer.Allergan_Direct_Access_Requested_AGN__c;
                                                           String lang;
                                                           if(customer.Country_Code_AGN__c.equalsIgnoreCase('CA')) {
                                                               if(!String.isEmpty(selectedUserLocale)) {
                                                                   if(selectedUserLocale.containsIgnoreCase('en')) {
                                                                       lang = 'en_US';
                                                                   }else if(selectedUserLocale.containsIgnoreCase('fr')) {
                                                                       lang = 'fr';
                                                                   }
                                                                   else{
                                                                       //lang = AGN_OAMConstant.USER_LANGUAGE;
                                                                       lang = selectedUserLocale;
                                                                   }
                                                               }
                                                               else{
                                                                   //lang = AGN_OAMConstant.USER_LANGUAGE;
                                                                   lang = selectedUserLocale;
                                                               }
                                                           }
                                                           else if(customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('AU') || customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('NZ')) {
                                                               lang = (String)OAM_User_Settings__c.getValues(customer.SAP_Country_Code_AGN__c).get('User_Language__c');
                                                               //lang = selectedUserLocale;
                                                           }
                                                           //added as part of UAT Fix: GCSP Core + LWC Model change, Market wants to remove language field from registration page and language code needs to populated by default
                                                           else if(customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('DE') || customer.Country_Code_AGN__c.equalsIgnoreCase('DE')) {
                                                                customer.Language_AGN__c = 'de';
                                                           }
                                                           else{
                                                               //lang = AGN_OAMConstant.USER_LANGUAGE;
                                                               lang = selectedUserLocale;
                                                           }
                                                           
                                                            customer.Language_AGN__c = (String.isEmpty(customer.Language_AGN__c)) ? lang : customer.Language_AGN__c;
                                     
                                                           
                                                           customer.Case_AGN__c = caseNewCr.Id;
                                                           customer.Trigger_Validation_of_Children__c = false;
                                                           customer.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c'
                                                                                    AND DeveloperName = 'New'
                                                                                    LIMIT 1
                                                                                   ][0].Id;
                                                           mapCustomerType(configList, customerAddress, customer);
                                                           string countryCode = customer.SAP_Country_Code_AGN__c;
                                                           if(String.isNotEmpty(countryCode)){
                                                               if(countryCode.equalsIgnoreCase('IE')){
                                                                   countryCode = 'GB';
                                                               }else if(countryCode.equalsIgnoreCase('AU')){
                                                                    countryCode = 'AN';
                                                               }    
                                                           }else{
                                                               countryCode = customer.Country_Code_AGN__c;
                                                           }
                                                           String OWNER_ID = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('CR_Record_Owner__c');
                                                           customer.OwnerId = OWNER_ID;
                                                           customer.Processed_By_SAP_AGN__c = 'In Progress';                                                            
                                                           
                                                           //------CheckMarx--Added on 25/07/2020----------      
                                                           List<Allergan_Customer_Registration_AGN__c> tempCRList = new List<Allergan_Customer_Registration_AGN__c>();
                                                           tempCRList.add(customer);              
                                                           String objCustomer = 'Allergan_Customer_Registration_AGN__c';
                                                           SObjectType objCRType = ((SObject)(Type.forName('Schema.'+objCustomer).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCRList,objCRType,'UPSERT');
                                                           upsert customer;
                                                           //---------------------------------------------
                                                           
                                                           system.debug('@@@@@ customer @@@@'+customer);
                                                           
                                                           //create sold to address
                                                           //customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                                                           string customerAdd= customerAddress.Id;
                                                           if(String.isEmpty(customerAdd)){
                                                               customerAddress.Parent_AGN__c = customer.Id;
                                                           }                                                           
                                                           customerAddress.Sold_To_AGN__c = true;
                                                           //customerAddress.Ship_To_AGN__c = true;
                                                           //customerAddress.Bill_To_AGN__c = true;
                                                           //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c; //This has been taken by Process Builder
                                                           //customerAddress.Account_AGN__c = customerContact.AccountId;
                                                           
                                                            
                                                           if(customer.Country_Code_AGN__c.equalsIgnoreCase('AN')|| customer.Country_Code_AGN__c.equalsIgnoreCase('AU') ||
                                                             customer.Country_Code_AGN__c.equalsIgnoreCase('NZ')) {
                                                               customerAddress.Phone_AGN__c = customer.Phone_AGN__c;
                                                               customerAddress.Email_AGN__c = customer.Email_AGN__c;
                                                           }else{                                                              
                                                               customerAddress.Email_AGN__c = customer.Email_AGN__c;
                                                               customerAddress.Mapping_2_AGN__c = String.isNotEmpty(customerAddress.Mapping_2_AGN__c) ? customerAddress.Mapping_2_AGN__c : customer.Mapping_1_AGN__c;                                                // invoice email
                                                               customerAddress.Phone_AGN__c = customer.Phone_AGN__c;
                                                               customerAddress.Phone_2_AGN__c = String.isNotEmpty(customerAddress.Phone_2_AGN__c) ? customerAddress.Phone_2_AGN__c : customer.Mobile_AGN__c;
                                                               customerAddress.SAP_Name_1_AGN__c = String.isEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                                                           }
                                                           customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                                                           customerAddress.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c'
                                                                                           AND DeveloperName = 'New'
                                                                                           LIMIT 1
                                                                                          ][0].Id;
                                                           
                                                           string countryCodeVal = customer.SAP_Country_Code_AGN__c;
                                                           if(String.isEmpty(countryCodeVal)){
                                                               countryCodeVal = customer.Country_Code_AGN__c;
                                                           }
                                                            countryCodeVal = countryCodeVal.equalsIgnoreCase('AU') ? 'AN' : countryCodeVal;                                                           
                                                           //customerAddress.Country_AGN__c = [SELECT AGN_Country_Name__c FROM Country_vod__c WHERE Alpha_2_Code_vod__c =:countryCodeVal LIMIT 1]?.AGN_Country_Name__c;
                                                           customerAddress.Country_AGN__c = String.isNotEmpty(customerAddress.Country_AGN__c)?customerAddress.Country_AGN__c: [SELECT AGN_Country_Name__c FROM Country_vod__c WHERE Alpha_2_Code_vod__c =:countryCodeVal LIMIT 1]?.AGN_Country_Name__c;
                                                           //------CheckMarx--Added on 25/07/2020----------      
                                                           List<Allergan_Customer_Address_AGN__c> tempCRAList = new List<Allergan_Customer_Address_AGN__c>();
                                                           tempCRAList.add(customerAddress);              
                                                           String objCustomerAdd = 'Allergan_Customer_Address_AGN__c';
                                                           SObjectType objCRAType = ((SObject)(Type.forName('Schema.'+objCustomerAdd).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCRAList,objCRAType,'UPSERT');
                                                           upsert customerAddress;
                                                           //---------------------------------------------
                                                           
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
                                                           crContact.Contact_Person_Type_AGN__c = customer.Contact_Person_Type_AGN__c;
                                                           crContact.Enable_Portal_User_AGN__c = customer.Allergan_Direct_Access_Requested_AGN__c;//true
                                                           crContact.Allergan_Direct_Access_Requested_AGN__c = customer.Allergan_Direct_Access_Requested_AGN__c;
                                                           if((Boolean)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_HCP_AGN__c') != null) {
                                                               crContact.Enable_HCP_AGN__c = (Boolean)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Enable_HCP_AGN__c');
                                                           }else{
                                                               crContact.Enable_HCP_AGN__c = false;
                                                           }
                                                           crContact.Id = acrContact.Id;
                                                            
                                                            List<Allergan_Customer_Contact_AGN__c> tempCRList1 = new List<Allergan_Customer_Contact_AGN__c>();
                                                            tempCRList1.add(crContact);
                                                            String objcr = 'Allergan_Customer_Contact_AGN__c';
                                                            SObjectType objTypecr = ((SObject)(Type.forName('Schema.'+objcr).newInstance())).getSObjectType();
                                                            AGN_FLSCheck.check(tempCRList1,objTypecr,'UPSERT');
                                                            upsert crContact;
                                                           
                                                           String addConId;
                                                           for(Allergan_Address_Contact_Mapping_agn__c con : [SELECT Id, Allergan_Customer_Address_agn__c, 
                                                                                                                     Allergan_Customer_Contact_agn__c,
                                                                                                                     Allergan_Customer_Registration_agn__c 
                                                                                                                     FROM Allergan_Address_Contact_Mapping_agn__c WHERE Allergan_Customer_Address_agn__c =: customerAddress.Id
                                                                                                                     AND Allergan_Customer_Contact_agn__c =: crContact.Id
                                                                                                                     AND Allergan_Customer_Registration_agn__c =: customer.Id LIMIT 1]){
                                                                                                                     
                                                                                            if(string.isNotEmpty(con.Id)){
                                                                                                addConId = con.Id;
                                                                                            }
                                                           
                                                           
                                                           }
                                                           // Change Added for PMO -2151 : Contact Affiliation with SoldTo, ShipTo,BillTo address....
                                                           Allergan_Address_Contact_Mapping_agn__c contactMappingObj = new Allergan_Address_Contact_Mapping_agn__c();
                                                           contactMappingObj.Allergan_Customer_Address_agn__c = customerAddress.Id;
                                                           contactMappingObj.Allergan_Customer_Contact_agn__c = crContact.Id;
                                                           contactMappingObj.Allergan_Customer_Registration_agn__c = customer.Id;
                                                           if(string.isNotEmpty(addConId)){
                                                               contactMappingObj.Id = addConId;
                                                           }
                                                           
                                                           
                                                           //------CheckMarx--Added on 25/07/2020----------      
                                                           List<Allergan_Address_Contact_Mapping_agn__c> tempCRContactList = new List<Allergan_Address_Contact_Mapping_agn__c>();
                                                           tempCRContactList.add(contactMappingObj);              
                                                           String objCRContact = 'Allergan_Address_Contact_Mapping_agn__c';
                                                           SObjectType objCRContactType = ((SObject)(Type.forName('Schema.'+objCRContact).newInstance())).getSObjectType();
                                                           AGN_FLSCheck.check(tempCRContactList,objCRContactType,'UPSERT');
                                                           upsert contactMappingObj;
                                                           //---------------------------------------------
                                                           
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
                //for Brazil Speciality Field
                if(c.Specialty_Allergan_AGN__c!=null)
                    customer.Specialty_Allergan_1_AGN__c  =c.Specialty_Allergan_AGN__c;
                
                break;
            }
        }
    }
    
    public static String createOktaUserSendLink(Allergan_Customer_Registration_AGN__c customer, Contact customerContact, String userLocale, String country) {
        String OKTASFCOMMUNITYGROUPID = (String)AGN_GCSP_Settings__c.getValues(country).get('Okta_SF_Community_Group_Id_AGN__c');
        String OKTABASEURL = (String)AGN_GCSP_Settings__c.getValues(country).get('Okta_Base_URL_AGN__c');
        String OKTAAPIKEY = (String)AGN_GCSP_Settings__c.getValues(country).get('Okta_API_Key_AGN__c');
        String returnMessage = 'FAILURE';
        String countryCode = customer.SAP_Country_Code_AGN__c;
        if(String.isEmpty(countryCode)) {
            countryCode = customer.Country_Code_AGN__c;
        }
        //Okta Username = Email of Community User
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        String userName = customer.Email_AGN__c;
        //AGN_OktaUtils oUtil = new AGN_OktaUtils(country , userName);
        
        AGN_OktaUtils oUtil = new AGN_OktaUtils(OKTABASEURL, OKTAAPIKEY, null);
        
        //checking if user is present in OKTA
        String okatMessage = oUtil.isPresentInOkta(userName);
        Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
        
        String messagetype = (String) m.get('messagetype');
        system.debug('messagetype>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+messagetype + OKTASFCOMMUNITYGROUPID);
        //messagetype = ERROR -> User not found, need to create the user
        if (messagetype.equalsIgnoreCase('ERROR')) {
            
            system.debug('Not a duplicate user>>>>>>'+customer);
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
                +'{"question": "' + /*AGN_OAMConstant.DEFAULT_OKTA_RECOVERY_QUETION*/ 'Name of this company?' + '","answer": "' + /*AGN_OAMConstant.DEFAULT_OKTA_RECOVERY_ANSWER*/ 'ALLERGAN' + '"' +
                +'}' +
                +'},' +
                +'"groupIds": [' + OKTASFCOMMUNITYGROUPID + ']}';
            system.debug('Creating okta user>>>>>>'+reqBody);
            String userCreateMsg = oUtil.CreateUser(reqBody);
            Map < String, Object > userCreateMsgMap = (Map < String, Object > ) JSON.deserializeUntyped(userCreateMsg);
            
            if (String.valueOf(userCreateMsgMap.get('messagetype')).equalsIgnoreCase('SUCCESS')) {
                returnMessage = 'SUCCESS';
                String userOktaId = String.valueOf(userCreateMsgMap.get('Id'));
                if (!String.isEmpty(userOktaId)) {
                    Contact cont = [Select Okta_Id_AGN__c From Contact Where Id =: customerContact.Id];
                    cont.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Contact
                    update cont;
                    
                    //Update oktaId in User's FederationIdentifier
                    updateOktaIdCommunityUser(customer.Email_AGN__c, userOktaId, country);
                }
                SendExpiryLinkChangePassword(customer, customerContact, userLocale,country);
            }
        }
        //User found
        else {
            String userOktatatus = (String) m.get('Status');
            String userOktaId = (String) m.get('Id');
            //Not inactive (DEPROVISIONED)
            if (!userOktatatus.equalsignorecase('DEPROVISIONED')) {
                oUtil.AddUserToGroup(OKTASFCOMMUNITYGROUPID, userOktaId);
                returnMessage = 'SUCCESS';
                if (!String.isEmpty(userOktaId)) {
                    Contact cont = [Select Okta_Id_AGN__c From Contact Where Id =: customerContact.Id];
                    cont.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Contact
                    update cont;
                    
                    //Update oktaId in User's FederationIdentifier
                    updateOktaIdCommunityUser(customer.Email_AGN__c, userOktaId,country);
                }
                SendExpiryLinkChangePassword(customer, customerContact, userLocale,country);
            } else {
                returnMessage = 'DEPROVISIONED';
            }
        }
        
        return returnMessage;
    }
    
    @future
    public static void updateOktaIdCommunityUser(String communityUserEmail, String okatId, String country) {
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        String suffix = !String.isEmpty(commonOktaConfig.UsernameSuffix_AGN__c) ? commonOktaConfig.UsernameSuffix_AGN__c : '';
        String sfdcUserName = communityUserEmail.toLowercase() + suffix;
        //String USERNAME_SUFFIX =  (String)OAM_User_Settings__c.getValues(country).get('Username_Suffix__c');
        //String communityUserName  = communityUserEmail + '.' + USERNAME_SUFFIX;
        system.debug('@@@communityUserName>>>'+sfdcUserName);
        User u = [Select IsActive, IsPortalEnabled,FederationIdentifier From User Where UserName =: sfdcUserName];
        u.FederationIdentifier = okatId;
        update u;
    }
    
    public static void forgotRecoveryQA(User customer, Boolean hasOktaRecoveryQuestion, String country) {
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        String dataToEncrypt;
        String encryptedData;
        
        String privateKey = commonOktaConfig.Encrypt_Decrypt_Private_Key_AGN__c;
        
        AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
        
        Decimal TOKENVALIDTILL = (Decimal)AGN_GCSP_Settings__c.getValues(country).get('Activation_Token_Valid_Till_AGN__c');
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(TOKENVALIDTILL));
        
        String passwordResetToken = cUtil.getRandomKey();
        String USERNAME_SUFFIX = !String.isEmpty(commonOktaConfig.UsernameSuffix_AGN__c) ? commonOktaConfig.UsernameSuffix_AGN__c : '';
        dataToEncrypt = '{' +
            +'"portalusername": "' + customer.Email + USERNAME_SUFFIX + '",' +
            +'"portaluseremail": "' + customer.Email + '",' +
            +'"countrycode": "' + country + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        Contact cont = [Select Community_Okta_Password_Reset_Token_AGN__c From Contact Where Id =: customer.contactID];
        cont.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        update cont;
        
        sendMailForgotRecoveryQA(customer, encryptedData, hasOktaRecoveryQuestion, commonOktaConfig);
    }
    
    public static void sendMailForgotRecoveryQA(User customer, String encryptedData, Boolean hasOktaRecoveryQuestion, AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig) {
        String expiryLink;
        String emailTemplateName;
        Decimal TOKENVALIDTILL = (Decimal)AGN_GCSP_Settings__c.getValues(customer.Country_Code__c).get('Activation_Token_Valid_Till_AGN__c');
        Decimal expirationInDays = TOKENVALIDTILL/24;
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        
        String countryCode = customer.Country_Code__c;
        IF(countryCode.equalsIgnoreCase('IE')) {
          countryCode ='GB'; 
        }          
        /*if(hasOktaRecoveryQuestion){
expiryLink = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_OAMPortalAccountActivation?token=' + encryptedData + '&r=true&language='+customer.LanguageLocaleKey;
}
else{
expiryLink = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_OAMPortalAccountActivation?token=' + encryptedData + '&language='+customer.LanguageLocaleKey;
}*/
        
        String COMMUNITY_BASE_URL = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Community_Base_URL_AGN__c');
            //commonOktaConfig.Community_Base_URL_AGN__c;
        String COMMUNITY_SUFFIX = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Community_Suffix_AGN__c');
            //commonOktaConfig.Community_Suffix_AGN__c;
        if(String.isEmpty(COMMUNITY_SUFFIX) || COMMUNITY_SUFFIX.equals('/')) {
            expiryLink = COMMUNITY_BASE_URL;
        }
        else{
            expiryLink = COMMUNITY_BASE_URL + COMMUNITY_SUFFIX;
        }
        
        expiryLink += commonOktaConfig.Account_Activation_Page_Name_AGN__c + '?token=' + encryptedData + '&language=' + customer.LocalesIdKey;
        
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.FirstName,
                '{!Recipient.LastName}' => customer.LastName,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!ExpiryLink}' => expiryLink
                };
                    
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email, null, null, null, mapSubjectParams, null, mapBodyParams));
        String senderEmailAddress = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Sender_Email_AGN__c');
        if(listEmailMessageWrapper.size() > 0) {
            system.debug('customer.Country_Code__c.::::'+customer.Country_Code__c);
            if(customer.Country_Code__c.equalsIgnoreCase('AU') || customer.Country_Code__c.equalsIgnoreCase('NZ') || customer.Country_Code__c.equalsIgnoreCase('AN')) {
                emailTemplateName = String.Format('Self Registration: Reset Security Q&A Email-{0}_{1}',new String[] {customer.MA_User_Country_Code_AGN__c, customer.LocaleSidKey});
            }else{
                emailTemplateName = String.Format('Self Registration: Reset Security Q&A Email-{0}',new String[] {customer.LanguageLocaleKey});
            }
             system.debug('emailTemplateName::::'+emailTemplateName);
            //second parameter is email template name (e.g: Self Registration: Reset Security Q&A Email-AU_en_AU)
            AGN_GCSP_Utilities.sendEmail(listEmailMessageWrapper, emailTemplateName, senderEmailAddress);
        }
    }
    public static void SendExpiryLinkChangePassword(Allergan_Customer_Registration_AGN__c customer, contact customerContact, String userLocale, String country) {
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        //String PRIVATEKEYVAL = (String)AGN_GCSP_Settings__c.getValues(country).get('Encrypt_Decrypt_Private_Key_AGN__c');
        String PRIVATEKEYVAL = commonOktaConfig.Encrypt_Decrypt_Private_Key_AGN__c;
        String dataToEncrypt;
        String encryptedData;
        String privateKey = PRIVATEKEYVAL; //config
        
        AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
        Decimal TOKENVALIDTILL = (Decimal)AGN_GCSP_Settings__c.getValues(country).get('Activation_Token_Valid_Till_AGN__c');
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(TOKENVALIDTILL));
        
        String passwordResetToken = cUtil.getRandomKey();
        
        String USERNAME_SUFFIX = !String.isEmpty(commonOktaConfig.UsernameSuffix_AGN__c) ? commonOktaConfig.UsernameSuffix_AGN__c : '';
        
        dataToEncrypt = '{' +
            +'"portalusername": "' + customer.Email_AGN__c + USERNAME_SUFFIX + '",' +
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
        update cont;
        
        SendWelcomeMail(customer, encryptedData,userLocale,country);
    }
    
    public static void SendWelcomeMail(Allergan_Customer_Registration_AGN__c customer, String encryptedData, String userLocale, String country){
        Decimal expirationInDays = 0;
        String accepteddate;
        String expiryLink;
        //AGN_OAMConstant.TOKENVALIDTILL/24;
        Decimal TOKENVALIDTILL = (Decimal)AGN_GCSP_Settings__c.getValues(country).get('Activation_Token_Valid_Till_AGN__c');
        if(customer.Country_Code_AGN__c.equalsIgnoreCase('FR') || customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
            expirationInDays = TOKENVALIDTILL;
            accepteddate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('dd MMM YYYY');
        }
        else{
            expirationInDays = TOKENVALIDTILL/24;
            accepteddate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd');
        }
        
        String lang;
        String langSidKey = '';
        System.debug('SendWelcomeMail -- customer.Country_Code_AGN__c ->' +customer.Country_Code_AGN__c);
        System.debug('SendWelcomeMail -- userLocale ->' +userLocale);
        
        if(customer.Country_Code_AGN__c.equalsIgnoreCase('CA')) {
            if(!String.isEmpty(userLocale)) {
                if(userLocale.containsIgnoreCase('en')) {
                    lang = 'en_US';
                }else if(userLocale.containsIgnoreCase('fr')) {
                    lang = 'fr';
                    langSidKey = 'fr_CA';
                }
                else{
                    //lang = AGN_OAMConstant.USER_LANGUAGE;
                    lang = userLocale;
                }
            }
            else{
                //lang = AGN_OAMConstant.USER_LANGUAGE;
                lang = userLocale;
            }
        }
        else if(customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('AU') || customer.SAP_Country_Code_AGN__c.equalsIgnoreCase('NZ')) {
            //lang = (String)OAM_User_Settings__c.getValues(customer.SAP_Country_Code_AGN__c).get('User_Language__c');
            lang = userLocale;
        }
        else{
            //lang = AGN_OAMConstant.USER_LANGUAGE;
            lang = userLocale;
        }
        
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        
         String COMMUNITY_BASE_URL = (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Community_Base_URL_AGN__c');
            //commonOktaConfig.Community_Base_URL_AGN__c;
        String COMMUNITY_SUFFIX = (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code_AGN__c).get('Community_Suffix_AGN__c');
            //commonOktaConfig.Community_Suffix_AGN__c;
        if(String.isEmpty(COMMUNITY_SUFFIX) || COMMUNITY_SUFFIX.equals('/')) {
            expiryLink = COMMUNITY_BASE_URL;
        }
        else{
            expiryLink = COMMUNITY_BASE_URL + COMMUNITY_SUFFIX;
        }
        
        //String COMMUNITY_BASE_URL = commonOktaConfig.Community_Base_URL_AGN__c;
        //String COMMUNITY_SUFFIX = !String.isEmpty(commonOktaConfig.Community_Suffix_AGN__c) ? commonOktaConfig.Community_Suffix_AGN__c : '';
        string languageSidkeyValue = String.isEmpty(langSidKey) ? lang :langSidKey;
        expiryLink += commonOktaConfig.Account_Activation_Page_Name_AGN__c+'?token=' + encryptedData + '&language='+languageSidkeyValue;
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.First_Name_AGN__c,
                '{!Recipient.LastName}' => customer.Last_Name_AGN__c,
                '{!Recipient.Email}' => customer.Email_AGN__c,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => accepteddate,
                '{!ExpiryLink}' => expiryLink
                };
                    
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email_AGN__c, null, null, null, mapSubjectParams, null, mapBodyParams));
        String SENDEREMAILADDRESSVAL = (String)AGN_GCSP_Settings__c.getValues(country).get('Sender_Email_AGN__c');
        String senderEmailAddress = SENDEREMAILADDRESSVAL;
        if(listEmailMessageWrapper.size() > 0) {
            //second parameter of sendEmail() is email template name (e.g: Self Registration: Welcome Email-DE)
            //System.debug('####Language Code #### '+ AGN_OAMConstant.USER_LANGUAGE.toUpperCase());
            String countryCode = customer.SAP_Country_Code_AGN__c;//Country_Code_AGN__c
            if(countryCode.equalsIgnoreCase('IE')) {
                countryCode = 'GB';
            }
            if(string.isEmpty(countryCode)) countryCode = customer.Country_Code_AGN__c;
            
            String userLocaleSid = (String)OAM_User_Settings__c.getValues(countryCode).get('User_Locale__c'); // Country_Code_AGN__c
            String welcomeEmailTemplateName;
            if(countryCode.equalsIgnoreCase('AU') || countryCode.equalsIgnoreCase('NZ')) {
                welcomeEmailTemplateName = String.Format('Self Registration: Welcome Email-{0}_{1}',new String[] {countryCode, userLocaleSid});
            }
            else{
                welcomeEmailTemplateName =  String.Format('Self Registration: Welcome Email-{0}',new String[] {lang.toUpperCase()});
            }
            System.debug('####email template name #### '+ welcomeEmailTemplateName);
            AGN_GCSP_Utilities.sendEmail(listEmailMessageWrapper, welcomeEmailTemplateName, senderEmailAddress);
        }
    }
    
    public static String getCustomerGroup(String countryCode, String customerType , String customerSubType) {
        
        String customerGroup = '';
        
        countryCode = countryCode.equalsIgnoreCase('AU') ? 'AN' : countryCode;
        
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
    
    public static Country_vod__c getCountry() {
        User uInfo = [SELECT Id, Country_Code__c,ContactId from User where Id =: UserInfo.getUserId() limit 1];
        string countryCode = '';
        if(uInfo.Country_Code__c == 'AU') {
            countryCode = 'AN';
        }else{
            countryCode = uInfo.Country_Code__c;
        }
        Country_vod__c country = [SELECT ID,Name,AGN_Country_Name__c,Alpha_2_Code_vod__c FROM Country_vod__c WHERE Alpha_2_Code_vod__c =: countryCode limit 1];
        system.debug('country-->'+country.AGN_Country_Name__c);
        return country;
    }
    
    /* description : Call out for get the Address Based on Zipcode for Brazil */    
    public static AddressDetail getAddressDetail(string cep) {
        
            AddressDetail address = new AddressDetail();
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.postmon.com.br/v1/cep/' + cep);
            req.setMethod('GET');         
            req.setTimeout(120000); 
            Http http = new Http();
            HTTPResponse res = http.send(req);
            System.debug(res.getBody());
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
    
        public class AddressDetail{        
            @AuraEnabled public string street{get;set;}
            @AuraEnabled public string city{get;set;}
            @AuraEnabled public string state{get;set;}
            @AuraEnabled public string complement{get;set;}
            @AuraEnabled public string bairro{get;set;} 
            @AuraEnabled public string zip{get;set;} 
           
            public AddressDetail(){
                
            }
        }
    
        
}