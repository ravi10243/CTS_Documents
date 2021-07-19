public without sharing class AGN_CustomerRegistrationUtils {
    
    public static User uInfo{get{return [SELECT Id,Name,Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];}} 
    public static final String USERNAME_SUFFIX =  (String)OAM_User_Settings__c.getValues(uInfo.Country_Code__c)?.get('Username_Suffix__c');//'agncustomerd17';
    
    public static final String USER_PROFILE = (String)OAM_User_Settings__c.getValues(uInfo.Country_Code__c)?.get('User_Profile__c');    
    public static final String OWNER_ID = (String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c)?.get('CR_Record_Owner__c');
    //public static final Boolean EnableHCP = (Boolean)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Enable_HCP_AGN__c');
    
    public static string createNewCustomerRegistration(Allergan_Customer_Registration_AGN__c customer, Allergan_Customer_Address_AGN__c customerAddress, list<Customer_Type_Configuration_AGN__c> configList){
        
        //create account and user
        //Account customerAccount = createCustomerAccount(customer);
        if(string.isEmpty(customerAddress.Company_Name_AGN__c)){
            customerAddress.Company_Name_AGN__c = customer.First_Name_AGN__c +' '+customer.Last_Name_AGN__c;
        }
        Contact customerContact = createCustomerContact(customer, customerAddress);
        
        //create case
        Case caseNewCr = new Case();
        caseNewCr.Service_AGN__c = 'Customer Registration';
        caseNewCr.Type = 'New' + ' - ' + customer.Customer_Category_AGN__c;
        caseNewCr.Reason = 'New Customer Registration';
        //Fix for PMO 3091 and INC #INC0465845 Santanu Start        
        caseNewCr.Business_Unit_AGN__c = customer.Customer_Category_AGN__c == 'Dentista (Pessoa Física)' ? customer.Business_Unit_AGN__c : '';
        //End customer.Business_Unit_AGN__c
        caseNewCr.Priority = 'Medium';
        caseNewCr.Origin = 'Web';
        caseNewCr.Status = 'New';
        caseNewCr.Subject = customerAddress.Company_Name_AGN__c + ' - ' + caseNewCr.Type;
        caseNewCr.ContactId = customerContact.Id;
        caseNewCr.AccountId = customerContact.AccountId;
        caseNewCr.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'AGN_Support_Request_Customer_Registration' LIMIT 1][0].Id;
        caseNewCr.SuppliedName = customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c;
        caseNewCr.SuppliedEmail = customer.Email_AGN__c;
        caseNewCr.SuppliedPhone = customer.Phone_AGN__c;
        caseNewCr.Case_Sub_Status_AGN__c='Online Registration - In Progress';
        
        List<Case> tempCRcaseList = new List<Case>();
        tempCRcaseList.add(caseNewCr);              
        String objCRcase = 'Case';
        SObjectType objCRcaseType = ((SObject)(Type.forName('Schema.'+objCRcase).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCRcaseList,objCRcaseType,'INSERT');
        insert caseNewCr;        
        
        //create customer registration        
        customer.Online_Registration_Step_AGN__c='2';
        customer.Online_Registration_AGN__c = true;
        customer.Allergan_Direct_Access_Requested_AGN__c =true;        
        customer.Case_AGN__c = caseNewCr.Id;
        //customer.Account_AGN__c = customerAccount.Id;
        customer.Trigger_Validation_of_Children__c = false;
        customer.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id;
        mapCustomerType(configList, customerAddress, customer);        
        customer.OwnerId = OWNER_ID;
        customer.Processed_By_SAP_AGN__c = 'In Progress';
        
        List<Allergan_Customer_Registration_AGN__c> tempCRregList = new List<Allergan_Customer_Registration_AGN__c>();
        tempCRregList.add(customer);              
        String objCRreg = 'Allergan_Customer_Registration_AGN__c';
        SObjectType objCRregType = ((SObject)(Type.forName('Schema.'+objCRreg).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCRregList,objCRregType,'INSERT');
        system.debug('@@@@@customer>>>>'+customer);
        insert customer;
        system.debug('@@@@@customer>>>>'+customer.Id);
        
        
        //create sold to address
        customerAddress.Company_Name_AGN__c= String.isBlank(customerAddress.Company_Name_AGN__c)?(customer.Salutation_AGN__c+' '+customer.First_Name_AGN__c+' '+customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;           
        customerAddress.Parent_AGN__c = customer.Id;
        customerAddress.Account_AGN__c = customerContact.AccountId;
        customerAddress.Sold_To_AGN__c = true;
        customerAddress.Email_AGN__c = customer.Email_AGN__c;
        customerAddress.Mapping_2_AGN__c = customer.Mapping_1_AGN__c;  // invoice email
        customerAddress.Phone_AGN__c = customer.Phone_AGN__c;
        customerAddress.Phone_2_AGN__c = customer.Mobile_AGN__c;
        customerAddress.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id;          
        
        List<Allergan_Customer_Address_AGN__c> tempCRaddList = new List<Allergan_Customer_Address_AGN__c>();
        tempCRaddList.add(customerAddress);              
        String objCRadd = 'Allergan_Customer_Address_AGN__c';
        SObjectType objCRaddType = ((SObject)(Type.forName('Schema.'+objCRadd).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCRaddList,objCRaddType,'INSERT');
        insert customerAddress;
        
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
        crContact.Allergan_Direct_Access_Requested_AGN__c=true;
        //enable person account---> need to do it from GCSP custom setting
        if((Boolean)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Enable_HCP_AGN__c') != null){
            crContact.Enable_HCP_AGN__c = (Boolean)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Enable_HCP_AGN__c');
        }else{
            crContact.Enable_HCP_AGN__c = false;
        }
        
        List<Allergan_Customer_Contact_AGN__c> tempCRContactList = new List<Allergan_Customer_Contact_AGN__c>();
        tempCRContactList.add(crContact);              
        String objCRContact = 'Allergan_Customer_Contact_AGN__c';
        SObjectType objCRContactType = ((SObject)(Type.forName('Schema.'+objCRContact).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCRContactList,objCRContactType,'INSERT');
        insert crContact;
        
        //Create Okta User
        //ID jobID = System.enqueueJob(new AGN_CustomerRegistrationQueueableUtils(customer,customerAccount));
        ID jobID = System.enqueueJob(new AGN_CustomerRegistrationQueueableUtils(customer,customerContact));
        
        return caseNewCr.Id;
    }
    
    public static string getValueFromJson ( String strJson, String field ){
        JSONParser parser = JSON.createParser(strJson);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                if(parser.getText() == field){
                    // Get the value.
                    parser.nextToken();
                    return parser.getText();
                }
            }
        }
        return null;
    }
    
    public static string makeRequest(string url, string body)  {
        
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();   
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        
        try {
            Http http = new Http();
            response = http.send(req);
            return response.getBody();
        } catch(System.Exception e) {
            System.debug('ERROR: ' + e);
        }
        return '{"success":false}';
    }
    
    public static Set<AGN_CR_CountryRegionMapping__mdt> getCountries(){
        Set<AGN_CR_CountryRegionMapping__mdt> countrySet  = new Set<AGN_CR_CountryRegionMapping__mdt>();
        List<AGN_CR_CountryRegionMapping__mdt> countrylist = [SELECT Country_Code__c,
                                                              Country_Name__c 
                                                              FROM AGN_CR_CountryRegionMapping__mdt
                                                              ORDER BY Country_Code__c];
        string tempCountry='';
        for (AGN_CR_CountryRegionMapping__mdt c : countrylist){
            if(tempCountry.indexOf(String.valueof(c.Country_Code__c))<=0){
                countrySet.add(c);
                tempCountry=tempCountry+','+c.Country_Code__C;
            }
        } 
        return countrySet;
    }
    
    public static Country_vod__c getCountryDetailsByCountryCode(string countryCode){
        Country_vod__c countryDetails = [SELECT Id,
                                         Country_Name_vod__c,
                                         Alpha_2_Code_vod__c,
                                         AGN_Country_Name__c
                                         FROM Country_vod__c
                                         WHERE Alpha_2_Code_vod__c=:countryCode
                                         LIMIT 1];
        return countryDetails;
    }
    
    public static List<AGN_CR_CountryRegionMapping__mdt> getRegions(string countryCode){
        List<AGN_CR_CountryRegionMapping__mdt> regionList = [SELECT RegionCode__c,
                                                             RegionName__c 
                                                             FROM AGN_CR_CountryRegionMapping__mdt
                                                             WHERE Country_Code__c=:countryCode
                                                             ORDER BY RegionName__c];
        
        return regionList;
    }
    
    public static String getRegionNamebyCode(string regionCode, string countryCode ){
        AGN_CR_CountryRegionMapping__mdt regionValue = [SELECT RegionName__c 
                                                        FROM AGN_CR_CountryRegionMapping__mdt
                                                        WHERE (RegionCode__c=:regionCode AND Country_Code__c=:countryCode)
                                                        LIMIT 1];         
        
        return regionValue.RegionName__c;
    }
    
    public static boolean checkForDuplicateCustomer(string email){
        
        string newUserName = email + '.' + USERNAME_SUFFIX;
        
        for (User u : [select Id from User where UserName =: newUserName and IsActive = true]){
            return true;
        }
        return false;
    }
    
    public static Id setEntitlement(string caseRecordType, string requestCategory, string countryCode){
        system.debug('=== caseRecordType: '+caseRecordType +'requestCategory:'+requestCategory+'countryCode: '+countryCode);
        Id entitlementId = [SELECT Entitlement_AGN__c FROM Case_Configuration_AGN__c WHERE
                            Case_Record_Type__c = :caseRecordType AND Static_Category_AGN__c = :requestCategory AND Country_Code_AGN__c = :countryCode 
                            LIMIT 1].Entitlement_AGN__c;
        system.debug('Case Record Type ==> ' + caseRecordType + ', Request Category ==> ' + requestCategory + ', Country Code ==> ' + countryCode);
        return entitlementId;
    } 
    
    
    public static String generateChangeList(Allergan_Customer_Address_AGN__c newAddress, Address_vod__c oldAddress){
        String changeList = '';        
        
        if(newAddress.Company_Name_AGN__c != oldAddress.Account_vod__r.Name && String.isNotEmpty(newAddress.Company_Name_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Company Name</b> from "' + oldAddress.Account_vod__r.Name + '" to "' + newAddress.Company_Name_AGN__c + '"<br>';
        if(newAddress.Department_Name_AGN__c != oldAddress.Department_Name_AGN__c && String.isNotEmpty(newAddress.Department_Name_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Department</b> from "' + oldAddress.Department_Name_AGN__c + '" to "' + newAddress.Department_Name_AGN__c + '"<br>';
        if(newAddress.Address_Line_1_AGN__c != oldAddress.Name && String.isNotEmpty(newAddress.Address_Line_1_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Address Line 1</b> from "' + oldAddress.Name + '" to "' + newAddress.Address_Line_1_AGN__c + '"<br>';
        if(newAddress.Address_Line_2_AGN__c != oldAddress.Address_line_2_vod__c && String.isNotEmpty(newAddress.Address_Line_2_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Address Line 2</b> from "' + oldAddress.Address_line_2_vod__c + '" to "' + newAddress.Address_Line_2_AGN__c + '"<br>';
        if(newAddress.Address_Line_3_AGN__c != oldAddress.Address_Line_3_AGN__c && String.isNotEmpty(newAddress.Address_Line_3_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Address Line 3</b> from "' + oldAddress.Address_Line_3_AGN__c + '" to "' + newAddress.Address_Line_3_AGN__c + '"<br>';
        if(newAddress.City_AGN__c != oldAddress.City_vod__c && String.isNotEmpty(newAddress.City_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>City</b> from "' + oldAddress.City_vod__c + '" to "' + newAddress.City_AGN__c + '"<br>';
        if(String.isEmpty(oldAddress.State_vod__c)) oldAddress.State_vod__c = '';
        if(newAddress.State_AGN__c != oldAddress.State_vod__c && !newAddress.State_AGN__c.contains(oldAddress.State_vod__c) && String.isNotEmpty(newAddress.State_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>State</b> from "' + oldAddress.State_vod__c + '" to "' + newAddress.State_AGN__c + '"<br>';
        if(newAddress.Zip_AGN__c != oldAddress.Zip_vod__c && String.isNotEmpty(newAddress.Zip_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Postal Code</b> from "' + oldAddress.Zip_vod__c + '" to "' + newAddress.Zip_AGN__c + '"<br>';
        if(newAddress.Phone_AGN__c != oldAddress.Phone_vod__c && String.isNotEmpty(newAddress.Phone_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Phone</b> from "' + oldAddress.Phone_vod__c + '" to "' + newAddress.Phone_AGN__c + '"<br>';
        if(newAddress.Email_AGN__c != oldAddress.Email_AGN__c && String.isNotEmpty(newAddress.Email_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Email</b> from "' + oldAddress.Email_AGN__c + '" to "' + newAddress.Email_AGN__c + '"<br>';
        
        if(changeList != '')
            changeList = 'Update ' + oldAddress.Account_vod__r.Name.toUppercase() + ' (' + newAddress.SAP_ID_AGN__c + ') with the following changes:' + '<br><br>' + changeList + '<br>';
        
        return changeList;
    }
    
    //private methods
    
    private static void mapCustomerType(list<Customer_Type_Configuration_AGN__c> config, Allergan_Customer_Address_AGN__c customerAddress, Allergan_Customer_Registration_AGN__c customer){
        for(Customer_Type_Configuration_AGN__c c : config){
            if(c.Category_AGN__c== customer.Customer_Category_AGN__c && c.Sub_Category__c==customer.Customer_Sub_Category_AGN__c){
                customerAddress.Account_Type_AGN__c = c.Account_Record_Type_AGN__c;
                //customerAddress.Type_AGN__c = c.Category_AGN__c;
                //customerAddress.Sub_Type_AGN__c = c.Sub_Category__c;
                customer.Account_Sub_Type_AGN__c = c.Category_AGN__c;
                customerAddress.Sub_Type_AGN__c = c.Category_AGN__c;
                customer.Customer_Group_AGN__c = c.Customer_Group_AGN__c;
            }
        }
    }
    public static String generateNewChangeList(Allergan_Customer_Address_AGN__c newAddress, Customer_Detail_AGN__c oldAddress){
        String changeList = '';        
        
        if(newAddress.Company_Name_AGN__c != oldAddress.Name && String.isNotEmpty(newAddress.Company_Name_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Company Name</b> from "' + oldAddress.Name + '" to "' + newAddress.Company_Name_AGN__c + '"<br>';
        if(newAddress.Department_Name_AGN__c != oldAddress.Department_Name_AGN__c && String.isNotEmpty(newAddress.Department_Name_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Department</b> from "' + oldAddress.Department_Name_AGN__c + '" to "' + newAddress.Department_Name_AGN__c + '"<br>';
        if(newAddress.Address_Line_1_AGN__c != oldAddress.Address_Line_1_AGN__c && String.isNotEmpty(newAddress.Address_Line_1_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Address Line 1</b> from "' + oldAddress.Address_Line_1_AGN__c + '" to "' + newAddress.Address_Line_1_AGN__c + '"<br>';
        if(newAddress.Address_Line_2_AGN__c != oldAddress.Address_Line_2_AGN__c && String.isNotEmpty(newAddress.Address_Line_2_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Address Line 2</b> from "' + oldAddress.Address_Line_2_AGN__c + '" to "' + newAddress.Address_Line_2_AGN__c + '"<br>';
        if(newAddress.Address_Line_3_AGN__c != oldAddress.Address_Line_3_AGN__c && String.isNotEmpty(newAddress.Address_Line_3_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Address Line 3</b> from "' + oldAddress.Address_Line_3_AGN__c + '" to "' + newAddress.Address_Line_3_AGN__c + '"<br>';
        if(newAddress.City_AGN__c != oldAddress.City_AGN__c && String.isNotEmpty(newAddress.City_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>City</b> from "' + oldAddress.City_AGN__c + '" to "' + newAddress.City_AGN__c + '"<br>';
        if(String.isEmpty(oldAddress.State_AGN__c)) oldAddress.State_AGN__c = '';
        if(newAddress.State_AGN__c != oldAddress.State_AGN__c && !newAddress.State_AGN__c.contains(oldAddress.State_AGN__c) && String.isNotEmpty(newAddress.State_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>State</b> from "' + oldAddress.State_AGN__c + '" to "' + newAddress.State_AGN__c + '"<br>';
        if(newAddress.Zip_AGN__c != oldAddress.Zip_AGN__c && String.isNotEmpty(newAddress.Zip_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Postal Code</b> from "' + oldAddress.Zip_AGN__c + '" to "' + newAddress.Zip_AGN__c + '"<br>';
        if(newAddress.Phone_AGN__c != oldAddress.Phone_AGN__c && String.isNotEmpty(newAddress.Phone_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Phone</b> from "' + oldAddress.Phone_AGN__c + '" to "' + newAddress.Phone_AGN__c + '"<br>';
        if(newAddress.Email_AGN__c != oldAddress.Email_AGN__c && String.isNotEmpty(newAddress.Email_AGN__c))
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Email</b> from "' + oldAddress.Email_AGN__c + '" to "' + newAddress.Email_AGN__c + '"<br>';
        if(newAddress.SAP_Blocking_Status_AGN__c != oldAddress.SAP_Blocking_Status_AGN__c && String.isNotEmpty(newAddress.SAP_Blocking_Status_AGN__c))
           changeList += '&emsp<b>\u25AA</b>&ensp Set <b>SAP Blocking Status</b> from "' + oldAddress.SAP_Blocking_Status_AGN__c + '" to "' + newAddress.SAP_Blocking_Status_AGN__c + '"<br>';
        if(newAddress.Request_for_Deactivation_AGN__c) 
            changeList += '&emsp<b>\u25AA</b>&ensp Set <b>Request For Deactivation </b> is "' + newAddress.Request_for_Deactivation_AGN__c + '"<br>';
        
        if(changeList != '')
            changeList = 'Update ' + oldAddress.Name.toUppercase() + ' (' + newAddress.SAP_ID_AGN__c + ') with the following changes:' + '<br><br>' + changeList + '<br>';
        
        return changeList;
    }

    /**********************Core+ChnageListStart*****************/

    public static String generateAddressChangeList(Allergan_Customer_Address_AGN__c newAddress, Allergan_Customer_Address_AGN__c oldAddress){
            
        string changeList= '';
        
        List<CR_Changlist_Setting_AGN__mdt> changeListSettings =New List<CR_Changlist_Setting_AGN__mdt>([SELECT Field_Details__c,Object_API_Name__c FROM CR_Changlist_Setting_AGN__mdt]);
        
        for(CR_Changlist_Setting_AGN__mdt cListSetting : changeListSettings){
            
            //Change in Address Details 
            if(cListSetting.Object_API_Name__c=='Allergan_Customer_Address_AGN__c' && newAddress!= Null && oldAddress!=NULL){
                String changeList1 = '<br>Address <b>'+oldAddress.Company_Name_AGN__c +'</b> has been amended with below changes : <br>';
                string changelIstVal = '';
                List<String> craFieldInfoList = cListSetting.Field_Details__c.split(',');        
                for(String craFieldInfo : craFieldInfoList) {
                    String[] craField = craFieldInfo.split('=');
                    if((( String.valueOf(newAddress.get(craField[1].trim()))) != String.valueOf(oldAddress.get(craField[1].trim()))) && !(string.isEmpty(String.valueOf(newAddress.get(craField[1].trim())))   && string.isEmpty(String.valueOf(oldAddress.get(craField[1].trim())))))
                        changelIstVal += '&emsp<b>\u25AA</b>&ensp Set <b>"'+craField[0].trim()+'"</b> from "' + oldAddress.get(craField[1]) + '" to "' + newAddress.get(craField[1].trim().trim()) + '"<br>';
                }
                changeList += String.isEmpty(changelIstVal) ? changelIstVal : changeList1+changelIstVal;
            }
        }
        system.debug('changeList' + changeList);    
        return changeList;
    }   
    /**********************Core+ChnageListEnd*****************/    
    
    private static Contact createCustomerContact(Allergan_Customer_Registration_AGN__c customer, Allergan_Customer_Address_AGN__c customerAddress){
        
        Account customerAccount = new Account();
        customerAccount.Name = customerAddress.Company_Name_AGN__c;
        customerAccount.OwnerId = AGN_OAMConstant.OWNER_ID;
        customerAccount.Phone = customerAddress.Phone_AGN__c;
        customerAccount.Customer_Sub_Category_AGN__c = customer.Customer_Sub_Category_AGN__c;            
        insert customerAccount;
        
        Contact customerContact = new Contact();        
        try { 
            customerContact.AccountId = customerAccount.ID;
            customerContact.Salutation = customer.Salutation_AGN__c;
            customerContact.FirstName = customer.First_Name_AGN__c;
            customerContact.Middle_Name_AGN__c = customer.Middle_Name_AGN__c;
            customerContact.LastName = customer.Last_Name_AGN__c;
            customerContact.Email = customer.Email_AGN__c;
            customerContact.Phone = customer.Phone_AGN__c;
            customerContact.Country_Code__c = customer.Country_Code_AGN__c;
            customerContact.Customer_Registration_AGN__c = 'In Progress';
            customerContact.Customer_Managed_AGN__c = true;
            customerContact.Country_vod__c = customer.Country_AGN__c;
            customerContact.SAP_Country_Code_AGN__c = customer.SAP_Country_Code_AGN__c;
            customerContact.Is_Primary_Contact_AGN__c = true;
            
            List<Contact> tempCRContactList = new List<Contact>();
            tempCRContactList.add(customerContact);              
            String objCRContact = 'Contact';
            SObjectType objCRContactType = ((SObject)(Type.forName('Schema.'+objCRContact).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCRContactList,objCRContactType,'INSERT');
            insert customerContact;
            
            customerContact = [select Id, AccountId, Account.Customer_Sub_Category_AGN__c, Name, FirstName, Country_vod__c, Customer_Managed_AGN__c, Salutation, Email,
                               LastName, Middle_Name_AGN__c, Is_Primary_Contact_AGN__c, Phone, Country_Code__c, SAP_Country_Code_AGN__c, Customer_Registration_AGN__c
                               from Contact where Id =: customerContact.Id limit 1];
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }       
        createCustomerUser(Json.serialize(customerContact));
        return customerContact;
    }
    
    @future
    public static void createPersonAccounts(string contactList, string craMap, string craBAMap, string cr, string CRToAccFieldMap, string CRFieldToB){
        
        Map<string, string> CroToAccountFieldMap = (Map<string, string>)JSON.deserialize(CRToAccFieldMap, Map<string, string>.class);
        Set<string> CroFieldsToBooleanify = (Set<string>)JSON.deserialize(CRFieldToB, Set<string>.class);
        boolean managedByCustomer = AGN_OAM_ProcessUtils.managedByCustomer;
        
        Allergan_Customer_Registration_AGN__c crRecord = (Allergan_Customer_Registration_AGN__c)JSON.deserialize(cr, Allergan_Customer_Registration_AGN__c.class);
        
        Map<Id, Contact> conMap = (Map<Id, Contact>)JSON.deserialize(contactList, Map<Id, Contact>.class);
        
        Id paRecordId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id;
        map<Id, Account> contactPersonMap = new map<Id, Account>();         
       
        map<Id, AccountContactRelation> acrRecMap = new map<Id,AccountContactRelation>();
        
         //Check exitsted ACR Records.
        map<Id, AccountContactRelation> acrRecMap1 = new map<Id,AccountContactRelation>([SELECT Id,ContactId,AccountId FROM AccountContactRelation WHERE ContactId = : conMap.KeySet() AND AccountID =: crRecord.Account_AGN__c]);       
                
        //check all existed PA's 
        for(AccountContactRelation acr : [SELECT Id,ContactId,AccountId FROM AccountContactRelation WHERE ContactId = : conMap.KeySet() AND Account.PersonContactId != null]){           
            acrRecMap.put(acr.ContactId,acr);           
        }
        for(Contact c : conMap.Values()){     //conList          
            Account personAccount = new Account();
            if(crRecord.Email_AGN__c.equalsIgnoreCase(c.Email)){ // check primary Contact? 
                personAccount.OwnerId = crRecord.OwnerId;               
                for (string croField : CroToAccountFieldMap.keySet()){  //SG: commented out to allow null values to be updated on Account                                              
                    // Otherwise, transfer the value.
                    string accField = CroToAccountFieldMap.get(croField);
                    if (CroFieldsToBooleanify.contains(croField)){
                        object val = crRecord.get(croField);                        
                        if (val != null){
                            string value = (string)(val);                            
                            personAccount.put(accField, value.toUpperCase() == 'YES');
                        }
                    }else{
                        personAccount.put(accField, crRecord.get(croField));
                    }
                }                
               // if (crRecord.Online_Registration_AGN__c == true) personAccount.Customer_Managed_AGN__c = true; //set flag for online account management
                //Added for OAM EMEA    
                //if(personAccount.Customer_Managed_AGN__c==false && managedByCustomer==true) personAccount.Customer_Managed_AGN__c = true;
                
                //if PA Availble but ACR realtion is Not Available for associated contact
                if(acrRecMap1.isEmpty()) personAccount.id = crRecord.Account_AGN__c; 
            }
            else{             
                personAccount.RecordTypeId = paRecordId;
                personAccount.Salutation = c.Salutation;
                personAccount.FirstName = c.FirstName;
                personAccount.Middle_vod__c = c.Middle_Name_AGN__c;
                personAccount.LastName = c.LastName;
                personAccount.PersonEmail = c.Email;
                personAccount.Phone = c.Phone;
                personAccount.Status_AGN__c = 'Active';
                personAccount.Country_Code__c = crRecord.Country_Code_AGN__c;
                personAccount.Country_vod__c = crRecord.Country_AGN__c;
                personAccount.SAP_Country_Code_AGN__c = crRecord.SAP_Country_Code_AGN__c;               
                
               // if(crRecord.Online_Registration_AGN__c ==true || managedByCustomer ==true) personAccount.Customer_Managed_AGN__c = true; 
            }
            
            if(acrRecMap.get(c.Id) != null){   // check if PA exists              
                personAccount.Id = acrRecMap.get(c.Id).AccountId;
            } 
            //personAccount.Primary_Parent_vod__c = c.AccountId;            
            contactPersonMap.put(c.Id, personAccount); 
        }
        upsert contactPersonMap.values();
        
        system.debug('@@@@@Person Accounts Created Successfully@@@@@@');
        
        list<AccountContactRelation> acrList = new list<AccountContactRelation>();
        //set<Id> personAccSet = new set<Id>();
        map<Id, AccountContactRelation> personAccMap = new map<Id, AccountContactRelation>();
        
        for(Id cId : contactPersonMap.keyset()){
            AccountContactRelation acr = new AccountContactRelation();
            acr.ContactId = cId;
            acr.AccountId = contactPersonMap.get(cId).Id;
            if(acrRecMap.get(cId) != null){
                acr.id = acrRecMap.get(cId).Id;
            }
            acrList.add(acr); 
            
        }
        upsert acrList;

        for(AccountContactRelation a: acrList){
            //personAccSet.add(a.AccountId); 
            personAccMap.put(a.AccountId, a);
        }
        
        // Create ContactPerson Affiliation
        createPersonContactAffiliations(personAccMap, craMap, craBAMap, conMap.values()[0].AccountId);      
        
    }
    
    private static void createPersonContactAffiliations(map<Id, AccountContactRelation> contactPersonAcc, string craMap, string craBAMap, string SoldToId){
      
        map<string, RecordType> CraRecordTypes = AGN_OAM_ProcessUtils.fetchRecordTypes('Allergan_Customer_Address_AGN__c');
        boolean managedByCustomer = AGN_OAM_ProcessUtils.managedByCustomer;        
       
        list<Contact> replaceContactList = new list<Contact>();
        
        map<Id, AccountContactRelation> acRelationmap = new map<Id, AccountContactRelation>();
        //Check the Primary Bussiness Accounts associated Contacts
        for(AccountContactRelation acr : [SELECT ID, ContactId,contact.AccountId,AccountId FROM AccountContactRelation where AccountId IN:contactPersonAcc.keyset()]){
            acRelationmap.put(acr.AccountId, acr);
        }
            
        list<Child_Account_vod__c> chilAccountList = new list<Child_Account_vod__c>();
        map<Id, Child_Account_vod__c> chilAccountListToDelete = new Map<Id, Child_Account_vod__c>(); 
        
        map<Id, Id> craBAMapVal = (map<Id, Id>)JSON.deserialize(craBAMap, map<Id, Id>.class); 
        
        map<Id, Allergan_Customer_Address_AGN__c> craMapVal = (map<Id, Allergan_Customer_Address_AGN__c>)JSON.deserialize(craMap, map<Id, Allergan_Customer_Address_AGN__c>.class);
        list<Allergan_Customer_Address_AGN__c> craAddList = new list<Allergan_Customer_Address_AGN__c>();      
      
        //-- Start --if we add mulitple contacts with out soldTo's then we can create SoldTo Record 
        boolean isPaSold = true;       
        for(Allergan_Customer_Address_AGN__c add : craMapVal.values()){
            if(add.Sold_To_AGN__c) isPaSold =false;         
        }
        if(isPaSold){
           Account SoldToAccount = [SELECT Id, SAP_Sold_To_AGN__c, SAP_Ship_To_AGN__c, SAP_Bill_To_AGN__c, External_ID2_AGN__c FROM Account WHERE ID =:SoldToId ];
           Allergan_Customer_Address_AGN__c craAdd = new Allergan_Customer_Address_AGN__c();
            craAdd.Sold_To_AGN__c = SoldToAccount.SAP_Sold_To_AGN__c;
            craAdd.Ship_To_AGN__c = SoldToAccount.SAP_Ship_To_AGN__c;
            craAdd.Bill_To_AGN__c = SoldToAccount.SAP_Bill_To_AGN__c;            
            craAdd.Account_AGN__c = SoldToAccount.ID;
            craAdd.SAP_ID_AGN__c = SoldToAccount.External_ID2_AGN__c;
            craAdd.Parent_AGN__c = craMapVal.values()[0].Parent_AGN__c;
            craAdd.RecordTypeId = CraRecordTypes.get('Amend').Id;
            
            List<Allergan_Customer_Address_AGN__c> tempCRaddList = new List<Allergan_Customer_Address_AGN__c>();
            tempCRaddList.add(craAdd);              
            String objCRadd = 'Allergan_Customer_Address_AGN__c';
            SObjectType objCRaddType = ((SObject)(Type.forName('Schema.'+objCRadd).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCRaddList,objCRaddType,'INSERT');
            insert craAdd; 
            
            craAddList.add(craAdd);            
            craMapVal.put(craAdd.Id, craAdd);
            craBAMapVal.put(craAdd.Id, SoldToAccount.ID);            
        } 
        //-- End
        map<Id, Child_Account_vod__c> exitsingAffilMap = new map<Id, Child_Account_vod__c>(); 
        map<Id, Id> PaBaMap = new map<Id, Id>(); 
        map<String, Child_Account_vod__c> newchildAccountMap = new map<String, Child_Account_vod__c>();
        if (!contactPersonAcc.isEmpty()){
            for (Child_Account_vod__c c : [select Id, Parent_Account_vod__c, Child_Account_vod__c from Child_Account_vod__c where Parent_Account_vod__c =:craBAMapVal.values() and Child_Account_vod__c IN :contactPersonAcc.keyset()]){
                 exitsingAffilMap.put(c.Parent_Account_vod__c, c);                
                 PaBaMap.put(c.Child_Account_vod__c, c.Parent_Account_vod__c);
            }
        }  
                
        for(Allergan_Customer_Address_AGN__c cra : craMapVal.values()){ 
            for( Id PersonAccId : contactPersonAcc.keyset()){ 
                if (cra.RecordTypeId == CraRecordTypes.get('Affiliate').Id){
                    // Create the affiliation
                    Child_Account_vod__c paAffil = new Child_Account_vod__c();
                    paAffil.Child_Account_vod__c = PersonAccId;
                    paAffil.Parent_Account_vod__c = cra.Account_AGN__c;
                    paAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;
                    paAffil.Sold_To_AGN__c = cra.Sold_To_AGN__c;
                    paAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                    paAffil.Copy_Address_vod__c = true;
                    //paAffil.Customer_Managed_AGN__C= cra.Parent_AGN__r.Online_Registration_AGN__c ;// SB:added for onboarding existing customer to OAM
                    
                    //Added for OAM EMEA    
                   // if(paAffil.Customer_Managed_AGN__c==false && managedByCustomer==true) paAffil.Customer_Managed_AGN__c = true;
                    
                    system.debug(LoggingLevel.ERROR, paAffil);
                    chilAccountList.add(paAffil);

                }       
                if (cra.RecordTypeId == CraRecordTypes.get('Replace').Id && PersonAccId != null){
                    //if (exitsingAffilMap.containsKey(cra.Account_AGN__c)) chilAccountListToDelete.put(exitsingAffilMap.get(cra.Account_AGN__c).Id, exitsingAffilMap.get(cra.Account_AGN__c));                  
                   if(PaBaMap.get(PersonAccId) == cra.Account_AGN__c) chilAccountListToDelete.put(exitsingAffilMap.get(PaBaMap.get(PersonAccId)).Id, exitsingAffilMap.get(PaBaMap.get(PersonAccId)));
                    Child_Account_vod__c paAffil = new Child_Account_vod__c();
                    paAffil.Child_Account_vod__c = PersonAccId;
                    paAffil.Parent_Account_vod__c = cra.Replacer_AGN__c;
                    paAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;
                    paAffil.Sold_To_AGN__c = cra.Sold_To_AGN__c;
                    paAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                    paAffil.Country_Code__c = cra.Country_Code_AGN__c; 
                    paAffil.Copy_Address_vod__c = true;                    
                    //Added for OAM EMEA    
                  //  if(paAffil.Customer_Managed_AGN__c== false && managedByCustomer==true) paAffil.Customer_Managed_AGN__c = true; 
                    // If we replace PA to PrimaryBussinessAccount Affilation, Associated Contact also replaced to Replacer Bussiness Account.                   
                    if(contactPersonAcc.get(PersonAccId) != null && cra.Sold_To_AGN__c == true && !acRelationmap.isEmpty() && cra.Account_AGN__c == acRelationmap.get(PersonAccId).contact.AccountId){ 
                        paAffil.Network_Primary_vod__c = true;
                        Contact con = new Contact();
                        con.AccountId = cra.Replacer_AGN__c;
                        con.id= contactPersonAcc.get(PersonAccId).ContactId;            
                        replaceContactList.add(con);                        
                    }
                    
                     chilAccountList.add(paAffil);
                   
                }
                if (cra.RecordTypeId == CraRecordTypes.get('New').Id || cra.RecordTypeId == CraRecordTypes.get('Amend').Id){                   
                   // if (PersonAccId !=null && !exitsingAffilMap.containsKey(craBAMapVal.get(cra.Id))){ // //check if PA affiliation exists                     
                    if (PersonAccId !=null && PaBaMap.get(PersonAccId) != craBAMapVal.get(cra.Id)){
                        
                        Child_Account_vod__c paAffil = new Child_Account_vod__c();
                        paAffil.Child_Account_vod__c = PersonAccId;
                        paAffil.Parent_Account_vod__c = craBAMapVal.get(cra.Id);
                        paAffil.Ship_To_AGN__c = cra.Ship_To_AGN__c;
                        paAffil.Sold_To_AGN__c = cra.Sold_To_AGN__c;
                        paAffil.Bill_To_AGN__c = cra.Bill_To_AGN__c;
                        paAffil.Copy_Address_vod__c = true;
                        paAffil.Country_Code__c = cra.Country_Code_AGN__c; // Added for EMEAS OAM release                
                        //Added for OAM EMEA    
                      //  if(paAffil.Customer_Managed_AGN__c==false && managedByCustomer==true) paAffil.Customer_Managed_AGN__c = true;
                        String parentChildIdMap = paAffil.Parent_Account_vod__c +'-'+PersonAccId;
                        if (cra.Sold_To_AGN__c) paAffil.Network_Primary_vod__c = true;   
                        if(!newchildAccountMap.containskey(parentChildIdMap)){
                            newchildAccountMap.put(parentChildIdMap, paAffil);
                        }
                        //chilAccountList.add(paAffil);
                    }
                }            
                
            }
            
        }
        
        String objAcc = 'Child_Account_vod__c';
        SObjectType AccObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
        AGN_FLSCheck.check(newchildAccountMap.values(),AccObjType,'INSERT');
         database.insert(newchildAccountMap.values(), false);
        //insert chilAccountList;
        
        
        system.debug('@@@@@Person Accounts Affiliation Created Successfully@@@@@@');
        if (!chilAccountListToDelete.isEmpty())  delete chilAccountListToDelete.values();
        if(!replaceContactList.isEmpty()) update replaceContactList;         
        if(!craAddList.isEmpty()) delete craAddList;//after affiliation delete manually created soldTo addresss list.
        
    }
    @future
    public static void createCustomerUser(string customerContact){
        
        //get account record from json
        system.debug('customerAccount=='+customerContact);
        //Account customer = (Account)JSON.deserialize(customerAccount, Account.class);
        Contact customer = (contact)JSON.deserialize(customerContact, contact.class);
        OAM_User_Settings__c allDetails =  OAM_User_Settings__c.getInstance(customer.Country_Code__c);
        
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
        
        customerUser.Email = customer.Email.toLowercase();
        customerUser.Phone = customer.Phone;
        customerUser.FirstName = customer.FirstName;
        customerUser.LastName = customer.LastName;
        customerUser.Alias = Alias;   
        customerUser.LanguageLocaleKey = allDetails.User_Language__c;
        customerUser.EmailEncodingKey = 'UTF-8';        
        customerUser.LocalesIdKey = allDetails.User_Locale__c;
        customerUser.TimezonesIdKey =allDetails.User_Timezone__c;
        customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: allDetails.User_Profile__c limit 1].Id;
        customerUser.UserName = customer.Email + '.' + USERNAME_SUFFIX;
        customerUser.ContactId = customer.id; 
        customerUser.Country_Code__c = customer.Country_Code__c;
        customerUser.Division= customer.Account.Customer_Sub_Category_AGN__c;
        
        List<User> tempCRUserList = new List<User>();
        tempCRUserList.add(customerUser);              
        String objCRUser = 'User';
        SObjectType objCRUserType = ((SObject)(Type.forName('Schema.'+objCRUser).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCRUserList,objCRUserType,'INSERT');
        insert customerUser;       
    }
    
    public static String createOktaUserSendLink(Allergan_Customer_Registration_AGN__c customer, Contact customerContact) { //Account customerAccount
        
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
                    //Account acc = [Select Okta_Id_AGN__c From Account Where Id =: customerAccount.Id];
                    Contact con = [Select Okta_Id_AGN__c From Contact Where Id =: customerContact.Id];
                    con.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Contact/Customer
                    update con;
                }
                //SendExpiryLinkChangePassword(customer, customerAccount);
                SendExpiryLinkChangePassword(customer, customerContact);
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
                    //Account acc = [Select Okta_Id_AGN__c From Account Where Id =: customerAccount.Id];
                    Contact con = [Select Okta_Id_AGN__c From Contact Where Id =: customerContact.Id];
                    con.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    update con;
                }
                //SendExpiryLinkChangePassword(customer, customerAccount);
                SendExpiryLinkChangePassword(customer, customerContact);
            } else {
                returnMessage = 'DEPROVISIONED';
            }
        }
        
        return returnMessage;
    }
    
    public static void SendExpiryLinkChangePassword(Allergan_Customer_Registration_AGN__c customer, Contact customerContact) {//Account customerAccount
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
        /* Account acc = [Select Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccount.Id];
acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
update acc;*/
        Contact con = [Select Community_Okta_Password_Reset_Token_AGN__c From Contact Where Id =: customerContact.Id];
        con.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        update con;
        
        String userName = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? customer.Email_AGN__c + '.' + AGN_OAMConstant.USERNAME_SUFFIX : customer.Email_AGN__c;
        //SendMail(customer.First_Name_AGN__c, userName, customer.Email_AGN__c, encryptedData);
        SendWelcomeMail(customer, encryptedData);  
    }
    
    public static void SendWelcomeMail(Allergan_Customer_Registration_AGN__c customer, String encryptedData){
        Decimal expirationInDays = 0;
        String accepteddate;
        String expiryLink;
        //AGN_OAMConstant.TOKENVALIDTILL/24; 
        
        expirationInDays = AGN_OAMConstant.TOKENVALIDTILL/24;
        accepteddate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd');
        
        if(String.isEmpty(AGN_OAMConstant.COMMUNITY_SUFFIX) || AGN_OAMConstant.COMMUNITY_SUFFIX.equals('/')){
            expiryLink = AGN_OAMConstant.COMMUNITY_BASE_URL + '/AGN_OAMPortalAccountActivation?token=' + encryptedData;//AGN_CustomerPortalOktaForceChgPWD
        }
        else{
            expiryLink = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_OAMPortalAccountActivation?token=' + encryptedData;
        }
        
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.First_Name_AGN__c,
                '{!Recipient.LastName}' => customer.Last_Name_AGN__c,
                '{!Recipient.Email}' => customer.Email_AGN__c,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => accepteddate,
                '{!ExpiryLink}' => expiryLink
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
    
    @Testvisible
    private static void updateOktaUserIdInAccount(Id customerAccountId, String oktaUserId, String passwordResetToken) {
        
        Account acc = [Select Okta_Id_AGN__c, Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: customerAccountId];
        if (!String.isEmpty(oktaUserId)) {
            acc.Okta_Id_AGN__c = oktaUserId;
        }
        if (!String.isEmpty(passwordResetToken)) {
            acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        }
        update acc;
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
        
        //updateOktaUserIdInAccount(customer.Account.Id, '', passwordResetToken);
        updateOktaUserIdInAccount(customer.Contact.Id, '', passwordResetToken);
        
        SendMailForgotRecoveryQA(customer, encryptedData, hasOktaRecoveryQuestion);  
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
    
    public static AddressDetail getAddressDetail(string cep) {
        
        AddressDetail address = new AddressDetail();
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.postmon.com.br/v1/cep/' + cep);
        req.setMethod('GET');         
        
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
    public static void setCustomerSpecialty (Allergan_Customer_Registration_AGN__c customer,List<Customer_Type_Configuration_AGN__c> customerTypeConfigList){
        
        for(Customer_Type_Configuration_AGN__c c: customerTypeConfigList)
        {
            if(c.Category_AGN__c==customer.Customer_Category_AGN__c 
               && c.Country_Code_AGN__c==customer.SAP_Country_Code_AGN__c 
               && c.Sub_Category__c==customer.Customer_Sub_Category_AGN__c)
            {
                if(c.Specialty_Allergan_AGN__c!=null)
                    customer.Specialty_Allergan_1_AGN__c  =c.Specialty_Allergan_AGN__c;
            }
        }
        
    }
    
    //public string cep {get;set;}
    //public AddressDetail address {get;set;}    
    
    public class AddressDetail{
        
        /* public string street {get;set;}
public string city {get;set;}
public string state {get;set;}
public string complement{get;set;}
public string bairro {get;set;}
public string zip {get;set;} */
        
        public string street;
        public string city; 
        public string state;
        public string complement;
        public string bairro; 
        public string zip; 
        
        public AddressDetail(){
            
        }
    }   
}