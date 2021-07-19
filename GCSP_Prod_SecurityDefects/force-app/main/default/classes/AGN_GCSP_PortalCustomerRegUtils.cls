/**
 * @description       : Save the data from Server for Registration process Step2, step3 and step4
 * @author            : GCSP Core Plus Dev Team
 * @group             : 
 * @last modified on  : 15-04-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   01-05-2021   GCSP Core Plus Dev Team   Initial Version
**/
public without sharing class AGN_GCSP_PortalCustomerRegUtils { 
    
    public static boolean checkForDuplicateCustomer(String email, String country) {
        //String USERNAME_SUFFIX =  (String)OAM_User_Settings__c.getValues(country).get('Username_Suffix__c');
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        String USERNAME_SUFFIX = !String.isEmpty(commonOktaConfig.UsernameSuffix_AGN__c) ? commonOktaConfig.UsernameSuffix_AGN__c : '';
        string newUserName = email + USERNAME_SUFFIX;
        
        for (User u: [select Id from User where UserName =: newUserName and isActive = true limit 1]) {
            return true;
        }
        return false;
    }
    
    public class  AddressWrapper{
        @AuraEnabled public String streetName;
        @AuraEnabled public String addressLine3;
        @AuraEnabled public String cityName;
        @AuraEnabled public String stateName;
        public AddressWrapper(){
            streetName ='';
            addressLine3='';
            cityName='';
            stateName='';
        }
    }  
    
    public static AddressWrapper fetchAddress(String countryCode,String zipCode){
        return null;
    }   
    
    @AuraEnabled(cacheable=true)
    public static List<Object> fetchCountryList(String countryCode, String source){ 
        system.debug('countryCode>>>>>>>>>>>>>>>>>>>>>>>>'+countryCode);
        system.debug('source>>>>>>>>>>>>>>>>>>>>>>>>'+source);
        List<Country_vod__c> options = new List<Country_vod__c>();
        List<Object> optionsObject = new List<Object>();
        Set<String> uniqueCountry = new Set<String>();
        String sapCountryCode = '';
        if(string.isNotEmpty(countryCode) && countryCode.equalsIgnoreCase('AU') || countryCode.equalsIgnoreCase('NZ')){
            sapCountryCode = 'AN';
        }else if(string.isNotEmpty(countryCode)){
            sapCountryCode = countryCode;
        }
        List<Customer_Type_Configuration_AGN__c> customerTypeConfigListValues = customerTypeConfig(sapCountryCode, source);
        List<Customer_Type_Configuration_AGN__c> customerTypeConfigList = new List<Customer_Type_Configuration_AGN__c>();
        for(Customer_Type_Configuration_AGN__c confg : customerTypeConfigListValues){
            
             if((countryCode.equalsIgnoreCase('AU') || countryCode.equalsIgnoreCase('AN')) && confg.Customer_Country_AGN__r.Name == 'AN' ){
                customerTypeConfigList.add(confg);
            }
            if(countryCode.equalsIgnoreCase('NZ') && confg.Customer_Country_AGN__r.Name == 'NZ'){
                	 customerTypeConfigList.add(confg);
            }
            if(!countryCode.equalsIgnoreCase('NZ') && !countryCode.equalsIgnoreCase('AU') && !countryCode.equalsIgnoreCase('AN')){
                customerTypeConfigList.add(confg);
            }
        }
        system.debug('customerTypeConfigList>>>>>>>>>>>>>>>>>>>>>>>>'+customerTypeConfigList);  
        //system.debug('user country code : '+AGN_OAMConstant.USERCOUNTRYCODE);
        if(customerTypeConfigList !=null && !customerTypeConfigList.isEmpty()){
            if(countryCode.equalsIgnoreCase('IE') || countryCode.equalsIgnoreCase('GB') || countryCode.equalsIgnoreCase('AU') || countryCode.equalsIgnoreCase('AN') || countryCode.equalsIgnoreCase('NZ')){
                for(Customer_Type_Configuration_AGN__c custConfig : customerTypeConfigList)
                {
                    system.debug('Customer_Country_AGN__r.Name : '+custConfig.Customer_Country_AGN__r.Name);
                    uniqueCountry.add(custConfig.Customer_Country_AGN__r.Name);            
                }
            }           
            else{
                for(Customer_Type_Configuration_AGN__c custConfig : customerTypeConfigList)
                {
                    system.debug('custConfig.Country_Code_AGN__c : '+custConfig.Country_Code_AGN__c);
                    uniqueCountry.add(custConfig.Country_Code_AGN__c);            
                }
            }
            System.debug('uniqueCountry : '+uniqueCountry);
            System.debug('uniqueCountry : '+uniqueCountry.size());
            
            options = [SELECT Id,
                       Alpha_2_Code_vod__c,
                       AGN_Country_Name__c
                       FROM Country_vod__c
                       WHERE Alpha_2_Code_vod__c IN:uniqueCountry];
            
            optionsObject.add(options);
            optionsObject.add(customerTypeConfigList);
            if(countryCode.equalsIgnoreCase('CA')){
                List<AGN_CR_CountryRegionMapping__mdt> provinces = provinceList(countryCode);
                optionsObject.add(provinces);
            }
        }
        system.debug('optionsObject>>>>>>>>>>>>>>>>>>'+optionsObject);
        return optionsObject;
    }
    
    public static List<Customer_Type_Configuration_AGN__c> customerTypeConfig(String countryCode,String source) {        
        
        String SobjectApiName = 'Customer_Type_Configuration_AGN__c';
        String query;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        Boolean isOnlineRegister = (string.isNotEmpty(source) && source.equalsIgnoreCase('oam')) ? true : false;
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        string configFields = 'Customer_Country_AGN__r.Name';
        // Checkmarx GCSP Core+ and HCO Harmonization: Adding below line to avoid SOQL/SOSL Injection
        countryCode = String.escapeSingleQuotes(countryCode);
        query = 'select '+configFields+', ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE ( Country_Code_AGN__c ='+'\''+ countryCode+ '\''+' OR Customer_Country_AGN__r.Alpha_2_Code_vod__c ='+'\''+ countryCode+ '\''+' )'; 
        query+= isOnlineRegister ? ' AND Applicable_For_Online_Registration_AGN__c ='+isOnlineRegister : '';
        
        List<Customer_Type_Configuration_AGN__c> configList = Database.query(query);  
        system.debug('configList>>>'+configList);
        return configList.isEmpty() ? new list<Customer_Type_Configuration_AGN__c>() : configList; 
        
    }
    
    public static List<AGN_CR_CountryRegionMapping__mdt> provinceList(String countryCode) {
        
        return [SELECT
                Country_Name__c,
                Country_Code__c,
                MasterLabel,
                RegionCode__c,
                RegionName__c,
                Region_Label_AGN__c 
                FROM AGN_CR_CountryRegionMapping__mdt WHERE Country_Code__c =:AGN_OAMConstant.USERCOUNTRYCODE];
    }
    
    
    
    public static Allergan_Customer_Registration_AGN__c getCustomerRegDetails() {
        User uInfo = [SELECT Id, ContactId from User where Id =: UserInfo.getUserId() limit 1];
        system.debug('uInfo.ContactId>>>>>>>>>>>>>>>'+uInfo.ContactId);
        Allergan_Customer_Contact_AGN__c customerContact = [SELECT Id,Parent_AGN__c,Contact_AGN__c,Contact_Person_Type_AGN__c 
                                                            FROM Allergan_Customer_Contact_AGN__c 
                                                            WHERE Contact_AGN__c =: uInfo.ContactId 
                                                            AND Contact_AGN__r.Customer_Registration_AGN__c != 'Complete' LIMIT 1];
        String RegId = String.escapeSingleQuotes(customerContact.Parent_AGN__c);     
        String SobjectApiName = 'Allergan_Customer_Registration_AGN__c';
        String query;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if((commaSepratedFields == null || commaSepratedFields == '') && !fieldName.equalsIgnoreCase('Province_AGN__c') ){                               
                commaSepratedFields = fieldName; 
            }else{                        
                if(fieldName.equalsIgnoreCase('Province_AGN__c')){ 
                    fieldName = 'toLabel(Province_AGN__c )';                         
                } 
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        query = 'select Country_AGN__r.AGN_Country_Name__c,' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE ID ='+'\''+ RegId+ '\'';
        
        list<Allergan_Customer_Registration_AGN__c> custRegList = Database.query(query);  
        
        return custRegList.isEmpty() ? new Allergan_Customer_Registration_AGN__c() : custRegList[0];              
        
    } 
    public static Allergan_Customer_Registration_AGN__c getCustomerRegDetailsCS(string caseId) {
        String caseRecId = String.escapeSingleQuotes(caseId);     
        String SobjectApiName = 'Allergan_Customer_Registration_AGN__c';
        String query;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if((commaSepratedFields == null || commaSepratedFields == '') && !fieldName.equalsIgnoreCase('Province_AGN__c') ){                               
                commaSepratedFields = fieldName; 
            }else{                        
                if(fieldName.equalsIgnoreCase('Province_AGN__c')){ 
                    fieldName = 'toLabel(Province_AGN__c )';                         
                } 
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        query = 'select Country_AGN__r.AGN_Country_Name__c,' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Case_AGN__c ='+'\''+ caseRecId+ '\'';
        System.debug('query>>>>'+query);
        list<Allergan_Customer_Registration_AGN__c> custRegList = Database.query(query);  
        System.debug('custRegList[0]>>>'+custRegList[0].Product_Interest_AGN__c);
        System.debug('custRegList>>>>'+custRegList);
         system.debug('customerreglist--------'  +  custRegList[0] + 'lsist---> ' + custRegList );
        return custRegList.isEmpty() ? new Allergan_Customer_Registration_AGN__c() : custRegList[0];   
       
        
    } 
    
    public static List<Allergan_Customer_Address_AGN__c> getCustomerAddressDetails(String custRegId) {
        
        //Allergan_Customer_Registration_AGN__c custReg = getCustomerRegDetails();
        String RegId = String.escapeSingleQuotes(custRegId); 
        String SobjectApiName = 'Allergan_Customer_Address_AGN__c';
        String query;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){                   
            if((commaSepratedFields == null || commaSepratedFields == '') && !fieldName.equalsIgnoreCase('Province_AGN__c')){
                commaSepratedFields = fieldName;
            }else{
                 if(fieldName.equalsIgnoreCase('Province_AGN__c')){ 
                    fieldName = 'toLabel(Province_AGN__c )';                         
                } 
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
            
        }
        query = 'select '+ commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Parent_AGN__c ='+'\''+ RegId + '\'' + ' ORDER BY createdDate DESC';
        List<Allergan_Customer_Address_AGN__c> custAdd = Database.query(query); 
        return custAdd.isEmpty() ? new list<Allergan_Customer_Address_AGN__c>() : custAdd ;
    }
    
    public static Case getCaseDetails(String caseId) {
        
        //Allergan_Customer_Registration_AGN__c custReg = getCustomerRegDetails();
        String caseRecId = String.escapeSingleQuotes(caseId); 
        String SobjectApiName = 'Case';
        String query;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){                   
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
            
        }
        query = 'select '+ commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Id ='+'\''+ caseRecId + '\'' + ' ORDER BY createdDate DESC';
        
        list<Case> caseCr = Database.query(query); 
        
        
        return caseCr.isEmpty() ? new Case() : caseCr[0] ;
    }
    
    public static Allergan_Customer_Contact_AGN__c getcustomerContactDetails(String crRecordId) {
        String regId = String.escapeSingleQuotes(crRecordId); 
        String SobjectApiName = 'Allergan_Customer_Contact_AGN__c';
        String query;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){                   
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
            
        }
        query = 'select '+ commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Parent_AGN__c ='+'\''+ regId + '\'' + ' ORDER BY createdDate DESC';
        
        list<Allergan_Customer_Contact_AGN__c> acrContactList = Database.query(query); 
        
        
        return acrContactList.isEmpty() ? new Allergan_Customer_Contact_AGN__c() : acrContactList[0] ;
    }
    
    
    
    public static Id upsertRegistrationDetails(Allergan_Customer_Address_AGN__c soldToAddr,
                                               List < Allergan_Customer_Address_AGN__c > billToAddrList,
                                               List < Allergan_Customer_Address_AGN__c > shipToAddrList,
                                               List < Allergan_Customer_Address_AGN__c > newBillToAddrList,
                                               List < Allergan_Customer_Address_AGN__c > newShipToAddrList,
                                               Allergan_Customer_Registration_AGN__c customer,
                                               String actionType,
                                               String currentStep
                                              )
    {
        system.debug('soldToAddr-->' + soldToAddr);
        system.debug('billToAddrList-->' + billToAddrList +'++' + billToAddrList.size());
        system.debug('shipToAddrList-->'+ shipToAddrList +'++'+ shipToAddrList.size());
        system.debug('newBillToAddrList-->'+ newBillToAddrList +'++'+ newBillToAddrList.size());
        system.debug('newShipToAddrList-->'+ newShipToAddrList +'++' + newShipToAddrList.size());
        system.debug('actionType-->' + actionType);
        Allergan_Customer_Address_AGN__c soldToAddrOld = [SELECT Id,Country_AGN__c FROM Allergan_Customer_Address_AGN__c WHERE Id =:soldToAddr.Id];
        if(String.isEmpty(soldToAddr.Country_AGN__c)){
            soldToAddr.Country_AGN__c = soldToAddrOld.Country_AGN__c;
        }
        
        //Allergan_Customer_Registration_AGN__c customer = getCustomerRegDetails();
        
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
            if(soldToAddr.Are_You_The_Prescribing_Doctor_AGN__c && soldToAddr.Country_Code_AGN__c != 'CA') {
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
                if(soldToId != customerAddress.Id) {
                    customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                    customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                    if (String.isBlank(customerAddress.Parent_AGN__c)) {
                        customerAddress.Parent_AGN__c = customer.Id;
                    }
                    customerAddress.RecordTypeId = addressRecordTypeId;
                    customerAddress.Country_AGN__c = String.isNotEmpty(customerAddress.Country_AGN__c)? customerAddress.Country_AGN__c : soldToAddr.Country_AGN__c;
                    //customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                    customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                    
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                        customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c : customerAddress.Company_Name_AGN__c;
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
                if(soldToId != customerAddress.Id) {
                    customerAddress.Sold_To_AGN__c = false;
                    customerAddress.Bill_To_AGN__c = false;
                    customerAddress.Ship_To_AGN__c  = true;  
                    customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                    customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                    if (String.isBlank(customerAddress.Parent_AGN__c)) {
                        customerAddress.Parent_AGN__c = customer.Id;
                    }
                    customerAddress.RecordTypeId = addressRecordTypeId;
                    customerAddress.Country_AGN__c = String.isNotEmpty(customerAddress.Country_AGN__c)? customerAddress.Country_AGN__c : soldToAddr.Country_AGN__c;
                    //customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                    customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                    
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                        //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                         customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c : customerAddress.Company_Name_AGN__c;
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
                customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                if (String.isBlank(customerAddress.Parent_AGN__c)) {
                    customerAddress.Parent_AGN__c = customer.Id;
                }
                customerAddress.RecordTypeId = addressRecordTypeId;
                customerAddress.Country_AGN__c = String.isNotEmpty(customerAddress.Country_AGN__c)? customerAddress.Country_AGN__c : soldToAddr.Country_AGN__c;

                //customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                
                //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c : customerAddress.Company_Name_AGN__c;
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
                customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                if (customerAddress.Parent_AGN__c == null || String.isEmpty(customerAddress.Parent_AGN__c)) {
                    customerAddress.Parent_AGN__c = customer.Id;
                }
                customerAddress.RecordTypeId = addressRecordTypeId;
                customerAddress.Country_AGN__c = String.isNotEmpty(customerAddress.Country_AGN__c)? customerAddress.Country_AGN__c : soldToAddr.Country_AGN__c;
                //customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                
                // customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                     customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c : customerAddress.Company_Name_AGN__c;
                }
                
                //add account owner details
                customerAddress.Doctors_First_Name_AGN__c = soldToAddr.Doctors_First_Name_AGN__c;
                customerAddress.Doctors_Middle_Name_AGN__c = soldToAddr.Doctors_Middle_Name_AGN__c;
                customerAddress.Doctors_Last_Name_AGN__c = soldToAddr.Doctors_Last_Name_AGN__c;
                customerAddress.Doctors_Email_AGN__c = soldToAddr.Doctors_Email_AGN__c;
                customerAddress.Doctors_Phone_AGN__c = soldToAddr.Doctors_Phone_AGN__c;
                customerAddress.KB23_Article_AGN__c = soldToAddr.KB23_Article_AGN__c;
                addList.add(customerAddress);
            }
            system.debug('ListcustomerAddress-->' + addList.size());
            system.debug('newShipToAddrList-->' + addList);
            if (!addList.isEmpty()) {
                //Database.UpsertResult[] rs = Database.upsert(addList, true);
                system.debug('addList@@@@@-->'+addList);
                String obj = 'Allergan_Customer_Address_AGN__c';
                SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
                AGN_FLSCheck.check(addList,objType,'UPSERT');
                upsert addList;
                if(String.isNotBlank(actionType) && actionType == 'next'){
                    if (customer.Online_Registration_Step_AGN__c == '2' && currentStep == '2') {
                        customer.Online_Registration_Step_AGN__c = '3';
                        update customer;
                    }else if (customer.Online_Registration_Step_AGN__c == '3' && currentStep == '3') {
                        customer.Online_Registration_Step_AGN__c = '4';
                        update customer;
                    }else if (customer.Online_Registration_Step_AGN__c == '4' && currentStep == '4') {
                        customer.Online_Registration_Step_AGN__c = '5';
                        update customer;
                        //finishCustomerRegistration_finalStep(soldToAddr,billToAddrList,shipToAddrList,newBillToAddrList,newShipToAddrList,caseNewCr,customer.Country_Code_AGN__c);
                    }
                }else{
                    update customer;
                }
                
            }
        } catch (DmlException dx) {
            system.debug('exception>>>>>>>>>>>>>'+dx.getMessage());
            throw new DmlException(dx.getMessage());
        }
        return caseNewCr.Id;
    }
    
    
    
    public static Id upsertAddressDetails(Allergan_Customer_Address_AGN__c soldToAddr,
                                          List < Allergan_Customer_Address_AGN__c > billToAddrList,
                                          List < Allergan_Customer_Address_AGN__c > shipToAddrList,
                                          List < Allergan_Customer_Address_AGN__c > newBillToAddrList,
                                          List < Allergan_Customer_Address_AGN__c > newShipToAddrList
                                         )
    {
        system.debug('soldToAddr-->' + billToAddrList.size());
        system.debug('billToAddrList-->' + shipToAddrList.size());
        system.debug('shipToAddrList-->' + shipToAddrList.size());
        system.debug('newBillToAddrList-->' + shipToAddrList.size());
        system.debug('newShipToAddrList-->' + shipToAddrList.size());
        
        Allergan_Customer_Registration_AGN__c customer = getCustomerRegDetails();
        
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
            if(soldToAddr.Are_You_The_Prescribing_Doctor_AGN__c && soldToAddr.Country_Code_AGN__c != 'CA') {
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
                if(soldToId != customerAddress.Id) {
                    customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                    customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                    if (String.isBlank(customerAddress.Parent_AGN__c)) {
                        customerAddress.Parent_AGN__c = customer.Id;
                    }
                    customerAddress.RecordTypeId = addressRecordTypeId;
                    customerAddress.Country_AGN__c = String.isNotEmpty(customerAddress.Country_AGN__c)? customerAddress.Country_AGN__c : soldToAddr.Country_AGN__c;//soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                    customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                    
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                        //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                        customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c : customerAddress.Company_Name_AGN__c;
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
                if(soldToId != customerAddress.Id) {
                    customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                    customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                    if (String.isBlank(customerAddress.Parent_AGN__c)) {
                        customerAddress.Parent_AGN__c = customer.Id;
                    }
                    customerAddress.RecordTypeId = addressRecordTypeId;
                    customerAddress.Country_AGN__c = String.isNotEmpty(customerAddress.Country_AGN__c)? customerAddress.Country_AGN__c : soldToAddr.Country_AGN__c;//soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                    customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                    
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                        //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                        customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c : customerAddress.Company_Name_AGN__c;
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
                customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                if (String.isBlank(customerAddress.Parent_AGN__c)) {
                    customerAddress.Parent_AGN__c = customer.Id;
                }
                customerAddress.RecordTypeId = addressRecordTypeId;
                customerAddress.Country_AGN__c = String.isNotEmpty(customerAddress.Country_AGN__c)? customerAddress.Country_AGN__c : soldToAddr.Country_AGN__c;//soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                
                //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c : customerAddress.Company_Name_AGN__c;
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
                customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                if (customerAddress.Parent_AGN__c == null || String.isEmpty(customerAddress.Parent_AGN__c)) {
                    customerAddress.Parent_AGN__c = customer.Id;
                }
                customerAddress.RecordTypeId = addressRecordTypeId;
                customerAddress.Country_AGN__c = String.isNotEmpty(customerAddress.Country_AGN__c)? customerAddress.Country_AGN__c : soldToAddr.Country_AGN__c;//soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                
                // customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c : customerAddress.Company_Name_AGN__c;
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
                system.debug('addList@@@@@-->'+addList);
                String obj = 'Allergan_Customer_Address_AGN__c';
                SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
                AGN_FLSCheck.check(addList,objType,'UPSERT');
                upsert addList;
                if (customer.Online_Registration_Step_AGN__c == '2') {
                    customer.Online_Registration_Step_AGN__c = '3';
                    update customer;
                }else if (customer.Online_Registration_Step_AGN__c == '3') {
                    customer.Online_Registration_Step_AGN__c = '4';
                    update customer;
                }else if (customer.Online_Registration_Step_AGN__c == '4') {
                    customer.Online_Registration_Step_AGN__c = '5';
                    update customer;
                    //finishCustomerRegistration_finalStep(soldToAddr,billToAddrList,shipToAddrList,newBillToAddrList,newShipToAddrList,caseNewCr,customer.Country_Code_AGN__c);
                }
                
            }
        } catch (DmlException dx) {
            system.debug('exception>>>>>>>>>>>>>'+dx.getMessage());
            throw new DmlException(dx.getMessage());
        }
        return caseNewCr.Id;
    }
    
    
    public static String upsertAllAddressDetails(Allergan_Customer_Address_AGN__c soldToAddr,
                                                 List < Allergan_Customer_Address_AGN__c > billToAddrList,
                                                 List < Allergan_Customer_Address_AGN__c > shipToAddrList,
                                                 List < Allergan_Customer_Address_AGN__c > newBillToAddrList,
                                                 List < Allergan_Customer_Address_AGN__c > newShipToAddrList,
                                                 Allergan_Customer_Registration_AGN__c customer,
                                                 String currentStep,
                                                 String actionType,
                                                 String source)
    {
        
        try {
            //Allergan_Customer_Registration_AGN__c customer = getCustomerRegDetails();
            
            system.debug('customer-->' + customer);
            system.debug('soldToAddr-->' + soldToAddr);
            
            Id addressRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c'
                                      AND DeveloperName = 'New'
                                      LIMIT 1
                                     ][0].Id;
            
            Case caseNewCr = [SELECT Id, Type, CaseNumber, RecordType.Name, Case_Sub_Status_AGN__c, EntitlementId, OwnerId FROM Case WHERE Id =: customer.Case_AGN__c];
            
            Country_vod__c country = new Country_vod__c();
            string countrycode;
            if(!string.isEmpty(customer.SAP_Country_Code_AGN__c)){
                countrycode = customer.SAP_Country_Code_AGN__c;
            }else{
                countrycode = customer.Country_Code_AGN__c;
            }
            
            countrycode = countrycode.equalsIgnoreCase('AU') ? 'AN' : countrycode;
            if(String.isNotEmpty(countrycode)){
                list<Country_vod__c> countryList = [SELECT Id, AGN_Country_Name__c, Alpha_2_Code_vod__c FROM Country_vod__c WHERE Alpha_2_Code_vod__c =:countrycode ];
                country = countryList.isEmpty() ? new Country_vod__c(): countryList[0];
            }
            
            Id soldToId = soldToAddr.Id;
            
            List < Allergan_Customer_Address_AGN__c > addList = new List < Allergan_Customer_Address_AGN__c > ();
            //Country_AGN__c = customer.Country_AGN__r.AGN_Country_Name__c, Country_Lookup_AGN__c = customer.Country_AGN__c
            //billto
            soldToAddr.Customer_Group_AGN__c = customer.Customer_Group_AGN__c;
            soldToAddr.Country_AGN__c = String.isEmpty(soldToAddr.Country_AGN__c) ? country.AGN_Country_Name__c: soldToAddr.Country_AGN__c;
            
            // if account owner is same as created user
            if(soldToAddr.Are_You_The_Prescribing_Doctor_AGN__c && soldToAddr.Country_Code_AGN__c != 'CA') {
                soldToAddr.Doctors_First_Name_AGN__c = customer.First_Name_AGN__c;
                soldToAddr.Doctors_Middle_Name_AGN__c = customer.Middle_Name_AGN__c;
                soldToAddr.Doctors_Last_Name_AGN__c = customer.Last_Name_AGN__c;
                soldToAddr.Doctors_Email_AGN__c = customer.Email_AGN__c;
                soldToAddr.Doctors_Phone_AGN__c = customer.Phone_AGN__c;
            }
            
            if(!soldToAddr.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
               // soldToAddr.SAP_Name_1_AGN__c = soldToAddr.Company_Name_AGN__c;
                soldToAddr.SAP_Name_1_AGN__c = String.isNotEmpty(soldToAddr.SAP_Name_1_AGN__c) ? soldToAddr.SAP_Name_1_AGN__c : soldToAddr.Company_Name_AGN__c;
            }
            
            addList.add(soldToAddr);
            
            //billto
            system.debug('billToAddrList-->' + billToAddrList.size());
            for (Allergan_Customer_Address_AGN__c customerAddress: billToAddrList) {
                
                if(soldToId != customerAddress.Id) {
                    
                    customerAddress.Account_Type_AGN__c = soldToAddr.Account_Type_AGN__c;
                    customerAddress.Sub_Type_AGN__c = soldToAddr.Sub_Type_AGN__c;                                                                      
                    
                    customerAddress.Country_AGN__c = String.isEmpty(customerAddress.Country_AGN__c) ? country.AGN_Country_Name__c: customerAddress.Country_AGN__c;
                    customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                    customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                    if (String.isBlank(customerAddress.Parent_AGN__c)) {
                        customerAddress.Parent_AGN__c = customer.Id;
                    }
                    customerAddress.RecordTypeId = addressRecordTypeId;
                    //customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                    customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                    
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                        customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c: customerAddress.Company_Name_AGN__c;
                        //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
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
                if(soldToId != customerAddress.Id) {
                    
                    customerAddress.Account_Type_AGN__c = soldToAddr.Account_Type_AGN__c;
                    customerAddress.Sub_Type_AGN__c = soldToAddr.Sub_Type_AGN__c; 
                    
                    customerAddress.Country_AGN__c = String.isEmpty(customerAddress.Country_AGN__c) ? country.AGN_Country_Name__c: customerAddress.Country_AGN__c;
                    customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                    customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                    if (String.isBlank(customerAddress.Parent_AGN__c)) {
                        customerAddress.Parent_AGN__c = customer.Id;
                    }
                    customerAddress.RecordTypeId = addressRecordTypeId;
                    //customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                    customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                    
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                    if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                        customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c: customerAddress.Company_Name_AGN__c;
                        //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
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
                
                customerAddress.Account_Type_AGN__c = soldToAddr.Account_Type_AGN__c;
                customerAddress.Sub_Type_AGN__c = soldToAddr.Sub_Type_AGN__c; 
                
                customerAddress.Country_AGN__c = String.isEmpty(customerAddress.Country_AGN__c) ? country.AGN_Country_Name__c: customerAddress.Country_AGN__c;
                customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                if (String.isBlank(customerAddress.Parent_AGN__c)) {
                    customerAddress.Parent_AGN__c = customer.Id;
                }
                customerAddress.RecordTypeId = addressRecordTypeId;
                // customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                
                //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                    customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c: customerAddress.Company_Name_AGN__c;
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
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
                
                customerAddress.Account_Type_AGN__c = soldToAddr.Account_Type_AGN__c;
                customerAddress.Sub_Type_AGN__c = soldToAddr.Sub_Type_AGN__c; 
                
                customerAddress.Country_AGN__c = String.isEmpty(customerAddress.Country_AGN__c) ? country.AGN_Country_Name__c: customerAddress.Country_AGN__c;
                customerAddress.Company_Name_AGN__c = String.isNotEmpty(customerAddress.Company_Name_AGN__c) ? customerAddress.Company_Name_AGN__c : customerAddress.SAP_Name_1_AGN__c;
                customerAddress.Company_Name_AGN__c = String.isBlank(customerAddress.Company_Name_AGN__c) ? (customer.Salutation_AGN__c + ' ' + customer.First_Name_AGN__c + ' ' + customer.Last_Name_AGN__c) : customerAddress.Company_Name_AGN__c;
                if (customerAddress.Parent_AGN__c == null || String.isEmpty(customerAddress.Parent_AGN__c)) {
                    customerAddress.Parent_AGN__c = customer.Id;
                }
                customerAddress.RecordTypeId = addressRecordTypeId;
                //customerAddress.Country_AGN__c = soldToAddr.Country_AGN__c;//customer.Country_AGN__r.AGN_Country_Name__c;
                customerAddress.Country_Lookup_AGN__c = customer.Country_AGN__c;
                
                // customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
                if(!customer.Country_Code_AGN__c.equalsIgnoreCase('AN')) {
                    customerAddress.SAP_Name_1_AGN__c = String.isNotEmpty(customerAddress.SAP_Name_1_AGN__c) ? customerAddress.SAP_Name_1_AGN__c: customerAddress.Company_Name_AGN__c;
                    //customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
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
            List<Allergan_Customer_Address_AGN__c> updateList =  new List<Allergan_Customer_Address_AGN__c>();
            if (!addList.isEmpty()) {
                for(Allergan_Customer_Address_AGN__c addObj: addList){ 
                    if(source.equalsIgnoreCase('oam')){
                        
                        if(customer.Country_Code_AGN__c == 'IT') {
                            addObj.Tax_Classification_AGN__c = (addObj.Country_AGN__c == 'Italy' ) ? '9' : '0';                           
                        }else {
                            addObj.Tax_Classification_AGN__c = String.isEmpty(customer.Tax_Exempted_AGN__c) ? '9' : customer.Tax_Exempted_AGN__c;
                        }
                        
                    }
                    else if(customer.Country_Code_AGN__c  == 'AU' || customer.Country_Code_AGN__c == 'NZ'|| customer.Country_Code_AGN__c == 'AN') {               
                        customer.Tax_Exempted_AGN__c =  String.isEmpty(customer.Tax_Exempted_AGN__c) ? '9' : customer.Tax_Exempted_AGN__c ;
                        customer.Tax_Classification_AGN__c =  String.isEmpty(customer.Tax_Classification_AGN__c) ? '9' : customer.Tax_Classification_AGN__c;
                        addObj.Tax_Classification_AGN__c = String.isEmpty(addObj.Tax_Classification_AGN__c) ? '9' : customer.Tax_Classification_AGN__c ;
                    }
                    else{
                        
                        addObj.Tax_Classification_AGN__c = customer.Tax_Classification_AGN__c;
                        customer.Tax_Exempted_AGN__c =  String.isEmpty(customer.Tax_Exempted_AGN__c) ? ((customer.Tax_Classification_AGN__c == '0' || customer.Tax_Classification_AGN__c == '9') ?  customer.Tax_Classification_AGN__c : '') : customer.Tax_Exempted_AGN__c;
                        
                    }
                    updateList.add(addObj);
                } 
                //Database.UpsertResult[] rs = Database.upsert(addList, true);
                system.debug('updateList@@@@@-->'+updateList);
                String obj = 'Allergan_Customer_Address_AGN__c';
                SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
                AGN_FLSCheck.check(updateList,objType,'UPSERT');
                upsert updateList;
                //upsert addList;
                
                if(!actionType.equalsIgnoreCase('save')){                
                    if(source.equalsIgnoreCase('oam')){
                        customer.Online_Registration_Step_AGN__c = '5';
                        
                        //Create the Contact Address Affiliations for Online Registration
                        createContactAddAffiliations(customer, updateList);
                        
                    }else{
                        customer.Online_Registration_Step_AGN__c = '0';
                    }
                }
                update customer;
                
                caseNewCr.Case_Sub_Status_AGN__c = 'Online Registration Completed';
                
                String entitleCountrycode = countrycode.equalsIgnoreCase('AU') ? 'AN' : countrycode;
                entitleCountrycode = entitleCountrycode.equalsIgnoreCase('IE') ? 'GB' : entitleCountrycode;
                
                caseNewCr.EntitlementId = setEntitlement(caseNewCr.RecordType.Name, caseNewCr.Type, entitleCountrycode);
                
                update caseNewCr;
                // Trigger the assignment rule by calling the case next button functionality
                if(source.equalsIgnoreCase('oam') && !actionType.equalsIgnoreCase('save')){
                    AGN_Case_Next.gotoNextStep(caseNewCr.id);
                }
                return caseNewCr.Id;  
                
            }
        } catch (Exception e) {
            system.debug('exception>>>>>>>>>>>>>'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    
    public static void createContactAddAffiliations(Allergan_Customer_Registration_AGN__c customer, list<Allergan_Customer_Address_AGN__c> addList){
        
        string acrContactId = [SELECT Id FROM Allergan_Customer_Contact_AGN__c WHERE Parent_AGN__c =:customer.Id]?.Id;
        
        Map<Id, Id> addConMap = new Map<Id, Id>();
        Map<Id, Id> acrConMap = new Map<Id, Id>();
        for(Allergan_Address_Contact_Mapping_agn__c con : [SELECT Id, Allergan_Customer_Address_agn__c, 
                                                           Allergan_Customer_Contact_agn__c,
                                                           Allergan_Customer_Registration_agn__c 
                                                           FROM Allergan_Address_Contact_Mapping_agn__c 
                                                           WHERE Allergan_Customer_Registration_agn__c =: customer.Id LIMIT 1]){
                                                               
                                                               addConMap.put(con.Allergan_Customer_Address_agn__c, con.Id);
                                                               acrConMap.put(con.Allergan_Customer_Contact_agn__c, con.Id);
                                                               
                                                               
                                                           }
        
        List<Allergan_Address_Contact_Mapping_agn__c> addConMapList = new List<Allergan_Address_Contact_Mapping_agn__c>();                                                 
        for(Allergan_Customer_Address_AGN__c address : addList){
            Allergan_Address_Contact_Mapping_agn__c addConRec = new Allergan_Address_Contact_Mapping_agn__c();
            if(addConMap.containsKey(address.Id) && acrConMap.containsKey(acrContactId) && addConMap.get(address.Id) == acrConMap.get(acrContactId)){
                addConRec.Id = addConMap.get(address.Id);
                
            }else{
                addConRec.Allergan_Customer_Address_agn__c = address.Id;
                addConRec.Allergan_Customer_Contact_agn__c = acrContactId;
                addConRec.Allergan_Customer_Registration_agn__c = customer.Id;
            }            
            
            addConMapList.add(addConRec);
            
        }
        
        if(!addConMapList.isEmpty()){
            String obj = 'Allergan_Address_Contact_Mapping_agn__c';
            SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
            AGN_FLSCheck.check(addConMapList,objType,'UPSERT');
            upsert addConMapList;
        }
        
    }
    
    public static String finishCustomerRegistration_finalStep(Allergan_Customer_Address_AGN__c soldToAddr,
                                                              List < Allergan_Customer_Address_AGN__c > billToAddrList,
                                                              List < Allergan_Customer_Address_AGN__c > shipToAddrList,
                                                              List < Allergan_Customer_Address_AGN__c > newBillToAddrList,
                                                              List < Allergan_Customer_Address_AGN__c > newShipToAddrList,
                                                              Case crCase,
                                                              String countrycode
                                                             ){
                                                                 
                                                                 list<Allergan_Customer_Address_AGN__c> addressList = new list<Allergan_Customer_Address_AGN__c>();
                                                                 Allergan_Customer_Registration_AGN__c customer = getCustomerRegDetailsCS(crCase.Id);                                                       
                                                                 Allergan_Customer_Address_AGN__c SoldToAddress = FetchObjectDetails(customer.Id);
                                                                 system.debug('SoldToAddress----->'  + SoldToAddress );
                                                                 String countryName = SoldToAddress.Country_Lookup_AGN__r.AGN_Country_Name__c;
                                                                 for(Allergan_Customer_Address_AGN__c add : billToAddrList) {
                                                                     add.Account_Type_AGN__c = SoldToAddress.Account_Type_AGN__c;
                                                                     add.Sub_Type_AGN__c = SoldToAddress.Sub_Type_AGN__c;
                                                                     add.Country_AGN__c = String.isEmpty(add.Country_AGN__c) ? countryName : add.Country_AGN__c;
                                                                     addressList.add(add);
                                                                 }
                                                                 for(Allergan_Customer_Address_AGN__c add : shipToAddrList) {
                                                                     add.Account_Type_AGN__c = SoldToAddress.Account_Type_AGN__c;
                                                                     add.Sub_Type_AGN__c = SoldToAddress.Sub_Type_AGN__c;
                                                                     add.Country_AGN__c = String.isEmpty(add.Country_AGN__c) ? countryName : add.Country_AGN__c;
                                                                     addressList.add(add);
                                                                 }
                                                                 for(Allergan_Customer_Address_AGN__c add : newBillToAddrList) {
                                                                     add.Account_Type_AGN__c = SoldToAddress.Account_Type_AGN__c;
                                                                     add.Sub_Type_AGN__c = SoldToAddress.Sub_Type_AGN__c;
                                                                     add.Country_AGN__c = String.isEmpty(add.Country_AGN__c) ? countryName : add.Country_AGN__c;
                                                                     addressList.add(add);
                                                                 }
                                                                 for(Allergan_Customer_Address_AGN__c add : newShipToAddrList) {
                                                                     add.Account_Type_AGN__c = SoldToAddress.Account_Type_AGN__c;
                                                                     add.Sub_Type_AGN__c = SoldToAddress.Sub_Type_AGN__c;
                                                                     add.Country_AGN__c = String.isEmpty(add.Country_AGN__c) ? countryName : add.Country_AGN__c;
                                                                     addressList.add(add);
                                                                 }
                                                                 soldToAddr.Id = SoldToAddress.Id; 
                                                                 
                                                                 soldToAddr.Country_AGN__c = String.isEmpty(soldToAddr.Country_AGN__c) ? countryName : soldToAddr.Country_AGN__c;
                                                                 addressList.add(soldToAddr);                                                                  
                                                                 
                                                                 
                                                                 if (customer.Online_Registration_Step_AGN__c == '4') {
                                                                     customer.Online_Registration_Step_AGN__c = '5';
                                                                 } 
                                                                 
                                                                 update customer;
                                                                 
                                                                 String objaddress = 'Allergan_Customer_Address_AGN__c';
                                                                 SObjectType objaddressType = ((SObject)(Type.forName('Schema.'+objaddress).newInstance())).getSObjectType();
                                                                 AGN_FLSCheck.check(addressList,objaddressType,'UPSERT');

                                                                 upsert addressList;
                                                                 
                                                                 crCase.Case_Sub_Status_AGN__c = 'Online Registration Completed';
                                                                 //crCase.Case_Step_Number_AGN__c = 2;
                                                                 
                                                                 //system.debug('======customerAddress========>' + crCase.RecordType.Name + '==' + crCase.Type + '==' + customer.Country_Code_AGN__c);
                                                                 system.debug('@@@@crCase@@@@@@@@@@'  + '  ' + crCase.RecordType.Name + '  ' + crCase.Type + ' ' + countrycode ); 
                                                                 crCase.EntitlementId = setEntitlement(crCase.RecordType.Name, crCase.Type, countrycode);//Country_Code_AGN__c
                                                                 // recordsToUpdate.add(crCase);
                                                                 
                                                                 update crCase;
                                                                 
                                                                 // Trigger the assignment rule by calling the case next button functionality
                                                                 AGN_Case_Next.gotoNextStep(crCase.id);
                                                                 //return [Select Id, CaseNumber From Case WHERE Id =: crCase.Id];
                                                                 //.CaseNumber;
                                                                 return crCase.id;
                                                             }
    
    public static Allergan_Customer_Address_AGN__c FetchObjectDetails(String regId){    
        
        //Sobject objCust = getCustomerRegDetailsCS(crCase.Id); 
        
        String parentId = String.escapeSingleQuotes(regId);
        
        String SobjectApiName = 'Allergan_Customer_Address_AGN__c';
        String query;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        query = 'select Country_Lookup_AGN__r.AGN_Country_Name__c, ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Parent_AGN__c ='+'\''+ parentId+ '\'' + 'AND Sold_To_AGN__c = True Limit 1';
        
        Allergan_Customer_Address_AGN__c objAdd = Database.query(query); 
        system.debug('Databasequery------>' + objAdd);
        
        return objAdd;
    }    
    
    public static Id setEntitlement(string caseRecordType, string requestCategory, string countryCode) {
        system.debug('===' + caseRecordType + requestCategory + countryCode);
        Id entitlementId = [SELECT Entitlement_AGN__c FROM Case_Configuration_AGN__c WHERE
                            Case_Record_Type__c =: caseRecordType AND Static_Category_AGN__c =: requestCategory AND Country_Code_AGN__c =: countryCode
                            LIMIT 1
                           ].Entitlement_AGN__c;
            system.debug('Entitlement_AGN__c@@@@@@@@@@' + entitlementId);
            system.debug('Case Record Type ==> ' + caseRecordType + ', Request Category ==> ' + requestCategory + ', Country Code ==> ' + countryCode);
        
        return entitlementId;
    }
    
    public static void deleteAddress(Allergan_Customer_Address_AGN__c customerAddress) {
        
        try {
            delete customerAddress;
        } catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteFile(Id fileId) {
        
        system.debug('== file to delete fileId =='+fileId);
        Attachment att = [
            SELECT Id 
            FROM Attachment
            WHERE Id =: fileId
        ];
        delete att;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        
        system.debug('== appendToFile fileId =='+fileId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
    }
    
    public static Id saveTheFile(String attachmentId, Id parentId, String fileName, String base64Data, String contentType, String description) {
        system.debug('@@attachmentId@@ '+attachmentId);
        system.debug('== parentId =='+parentId);
        system.debug('== fileName =='+fileName);
        system.debug('== description =='+description);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        system.debug('== base64Data =='+base64Data);
        List<Attachment> attachmentList = new List<Attachment>();
        Allergan_Customer_Registration_AGN__c acr = new Allergan_Customer_Registration_AGN__c();
        acr = [SELECT Id FROM Allergan_Customer_Registration_AGN__c WHERE Id=:parentId LIMIT 1];
        
        system.debug('== Id =='+acr.Id);
        Attachment attachmentFile = new Attachment(); 
        
        if ((!String.isEmpty(attachmentId)) && attachmentId.trim() != 'undefined'){
            attachmentFile.Id = attachmentId;
        } 
        else{
            //attachmentFile.Id =  String.isEmpty(attachmentId)? null : attachmentId;
            attachmentFile.ParentId = acr.Id;
            
        }
        
        attachmentFile.Body = EncodingUtil.base64Decode(base64Data);
        attachmentFile.Name = fileName;
        attachmentFile.ContentType = contentType;
        attachmentFile.Description = description.trim();
        
        system.debug('•attachmentFile•'+attachmentFile);
        
        List<Attachment> tempattachmentList = new List<Attachment>();
        tempattachmentList.add(attachmentFile);              
        String objAttachment = 'Attachment';
        SObjectType objattachmentType = ((SObject)(Type.forName('Schema.'+objAttachment).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempattachmentList,objattachmentType,'UPSERT');

        upsert attachmentFile;
        
        return attachmentFile.Id;
    }
    
    public static Id saveChunk(String fileId,String attachmentId, Id parentId, String fileName, String base64Data, String contentType, String description) {
        
        
        if (fileId == '') {
            fileId = saveTheFile(attachmentId, parentId, fileName,base64Data, contentType,description);
            system.debug('== fileId In If=='+fileId);
            
        } else {
            system.debug('== fileId In Else =='+fileId);
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static String upsertCustomerDetails(Allergan_Customer_Registration_AGN__c customer, 
                                               Allergan_Customer_Address_AGN__c customerAddress, 
                                               String Specialty,
                                               String actionType,
                                               String currentStep,
                                               String source) 
    {
        Allergan_Customer_Registration_AGN__c customerOld = AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetailsCS(customer.Case_AGN__c);
        Set<String> AddressfieldSet = new Set<String>();  
        Set<String> cRfieldSet = new Set<String>();
        system.debug('customerOld -->' + customerOld); 
        system.debug('customer -->' + customer); 
        system.debug('customerAddress -->' + customerAddress);        
        //String selectyedCustgrp = customerOld.Country_Code_AGN__c =='IT'? NULL : customerOld.Customer_Group_AGN__c;            
         String customerCountryCode = String.isBlank(customerOld.SAP_Country_Code_AGN__c) ? customerOld.Country_Code_AGN__c :customerOld.SAP_Country_Code_AGN__c;  //Added for NZ and AU. To be checked for IE.        
        AddressfieldSet = getFieldMetadata('Allergan_Customer_Address_AGN__c',customerCountryCode,3,customerOld.Customer_Group_AGN__c,source);
        cRfieldSet = getFieldMetadata('Allergan_Customer_Registration_AGN__c',customerCountryCode,3,customerOld.Customer_Group_AGN__c,source);
        
        List<Specialty_Allergan_AGN__c> sp;
        
        system.debug('Specialty-->' + Specialty);
        
        if(!String.isBlank(Specialty)) {
            sp = [SELECT ID FROM Specialty_Allergan_AGN__c WHERE (Translated_Value_AGN__c =:Specialty OR English_Value_AGN__c =:Specialty ) AND Country_code_AGN__c =:customerOld.Country_Code_AGN__c limit 1];
        }
        
        Case caseNewCr = [SELECT Id, Type, RecordType.Name, Case_Sub_Status_AGN__c,
                          EntitlementId, OwnerId FROM Case WHERE Id =: customerOld.Case_AGN__c];
        try {
            if(String.isNotBlank(actionType) && actionType == 'next'){
                if (customerOld.Online_Registration_Step_AGN__c == '3' && currentStep == '3') {
                    customerOld.Online_Registration_Step_AGN__c = '4';
                }
            }
            
            for(String tempStr: cRfieldSet)
            {
                if(customer.get(tempStr) != null)
                {
                    customerOld.put(tempStr,customer.get(tempStr));
                }
            }
          /*  customerOld.VAT_AGN__c = customer.VAT_AGN__c;
            customerOld.Registration_License_Number_AGN__c = customer.Registration_License_Number_AGN__c;
            customerOld.Physician_Registration_Reference_AGN__c = customer.Physician_Registration_Reference_AGN__c;            
            customerOld.Employee_AGN__c = customer.Employee_AGN__c;
            customerOld.Owner_AGN__c = customer.Owner_AGN__c;
            customerOld.Contractor_AGN__c = customer.Contractor_AGN__c;
            customerOld.Professional_Service_Provider_AGN__c = customer.Professional_Service_Provider_AGN__c;            
            customerOld.AAF_signed_AGN__c = customer.AAF_signed_AGN__c;
            customerOld.Confirmation_AAF_Is_On_Date_AGN__c = customer.Confirmation_AAF_Is_On_Date_AGN__c;
            customerOld.Consignment_Authorized_AGN__c = customer.Consignment_Authorized_AGN__c; */
            if(!String.isBlank(Specialty) && !sp.isEmpty()){
                customerOld.Specialty_Allergan_1_AGN__c = sp[0].Id;
            }
            
            if(source.equalsIgnoreCase('oam')){             
                customerOld.Tax_Exempted_AGN__c = String.isEmpty(customer.Tax_Exempted_AGN__c) ? '9' : customer.Tax_Exempted_AGN__c;
            }
            else if(customerOld.Country_Code_AGN__c == 'AU' || customerOld.Country_Code_AGN__c == 'NZ'|| customerOld.Country_Code_AGN__c == 'AN') {   
                customerOld.Tax_Classification_AGN__c = String.isEmpty(customer.Tax_Classification_AGN__c) ? '9' : customer.Tax_Classification_AGN__c;
                customerOld.Tax_Exempted_AGN__c =  customerOld.Tax_Classification_AGN__c ;            
            }
            else{               
                customerOld.Tax_Exempted_AGN__c =  String.isEmpty(customer.Tax_Exempted_AGN__c) ? ((customer.Tax_Classification_AGN__c == '0' || customer.Tax_Classification_AGN__c == '9') ?  customer.Tax_Classification_AGN__c : '') : customer.Tax_Exempted_AGN__c;
                customerOld.Tax_Classification_AGN__c = customer.Tax_Classification_AGN__c;
            }
            
            
            List<Allergan_Customer_Registration_AGN__c> tempcustomeroldList = new List<Allergan_Customer_Registration_AGN__c>();
            tempcustomeroldList.add(customerOld);              
            String objCustomerOld = 'Allergan_Customer_Registration_AGN__c';
            SObjectType objCustomerOldType = ((SObject)(Type.forName('Schema.'+objCustomerOld).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempcustomeroldList,objCustomerOldType,'UPDATE');

            update customerOld;
            system.debug('@@@customerOld>>>>'+customerOld);
            
            list<Allergan_Customer_Address_AGN__c> customerAddressOldList = AGN_GCSP_CustomerRegStep2Controller.getCustomerAddressDetails(customerOld.Id); //get all Addresss list
            
            system.debug('customerAddressOld -->' + customerAddressOldList);
            system.debug('customerAddressNew -->' + customerAddress);
            
            list<Allergan_Customer_Address_AGN__c> addList = new list<Allergan_Customer_Address_AGN__c>();
            
            if(!customerAddressOldList.isEmpty() && customerAddressOldList.size()>0) {
                for(Allergan_Customer_Address_AGN__c cra : customerAddressOldList ) {
                    if(cra.Sold_To_AGN__c) {
                        for(String tempStr: AddressfieldSet)
                        {
                           if(customerAddress.get(tempStr) != null)
                            {
                                cra.put(tempStr,customerAddress.get(tempStr));
                            }
                        }
                      cra.State_License_Number_AGN__c = String.isEmpty(cra.State_License_Number_AGN__c) ? String.isEmpty(customer.Registration_License_Number_AGN__c) ? '' : customer.Registration_License_Number_AGN__c : cra.State_License_Number_AGN__c;
                    }
                    
                    if(source.equalsIgnoreCase('oam')){
                        if(customerOld.Country_Code_AGN__c == 'IT') {
                            cra.Tax_Classification_AGN__c = (cra.Country_AGN__c == 'Italy' ) ? '9' : '0';                           
                        }else {
                            cra.Tax_Classification_AGN__c = String.isEmpty(customerOld.Tax_Exempted_AGN__c) ? '9' : customerOld.Tax_Exempted_AGN__c;
                        }
                    }else{                      
                        cra.Tax_Classification_AGN__c = customerOld.Tax_Classification_AGN__c;                      
                    }
                    
                    addList.add(cra);
                }
            }
            
            //if(!addList.isEmpty()){
            String obj = 'Allergan_Customer_Address_AGN__c';
            SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
            AGN_FLSCheck.check(addList,objType,'UPDATE');
            update addList;
            //}
            
            system.debug('@@@addList>>>'+addList);
            
        } catch (DmlException dx) {
            
            throw new DmlException(dx.getMessage());
        }
        //return [Select CaseNumber From Case WHERE Id =: caseNewCr.Id].CaseNumber;
        return caseNewCr.Id;
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
        
        /*if(hasOktaRecoveryQuestion){
expiryLink = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_OAMPortalAccountActivation?token=' + encryptedData + '&r=true&language='+customer.LanguageLocaleKey;
}
else{
expiryLink = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + '/AGN_OAMPortalAccountActivation?token=' + encryptedData + '&language='+customer.LanguageLocaleKey;
}*/
        
        String COMMUNITY_BASE_URL = commonOktaConfig.Community_Base_URL_AGN__c;
        String COMMUNITY_SUFFIX = commonOktaConfig.Community_Suffix_AGN__c;
        if(String.isEmpty(COMMUNITY_SUFFIX) || COMMUNITY_SUFFIX.equals('/')) {
            expiryLink = COMMUNITY_BASE_URL;
        }
        else{
            expiryLink = COMMUNITY_BASE_URL + COMMUNITY_SUFFIX;
        }
        
        expiryLink += commonOktaConfig.Account_Activation_Page_Name_AGN__c + '?token=' + encryptedData + '&language=' + customer.LanguageLocaleKey;
        
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customer.FirstName,
                '{!Recipient.LastName}' => customer.LastName,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!ExpiryLink}' => expiryLink
                };
                    
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', customer.Email, null, null, null, mapSubjectParams, null, mapBodyParams));
        String senderEmailAddress = (String)AGN_GCSP_Settings__c.getValues(customer.Country_Code__c).get('Sender_Email_AGN__c');
        if(listEmailMessageWrapper.size() > 0) {
            
            if(customer.Country_Code__c.equalsIgnoreCase('AU') || customer.Country_Code__c.equalsIgnoreCase('NZ')) {
                emailTemplateName = String.Format('Self Registration: Reset Security Q&A Email-{0}_{1}',new String[] {customer.Country_Code__c, customer.LocaleSidKey});
            }else{
                emailTemplateName = String.Format('Self Registration: Reset Security Q&A Email-{0}',new String[] {customer.LanguageLocaleKey});
            }
            
            //second parameter is email template name (e.g: Self Registration: Reset Security Q&A Email-AU_en_AU)
            AGN_GCSP_Utilities.sendEmail(listEmailMessageWrapper, emailTemplateName, senderEmailAddress);
        }
    }
    
    @AuraEnabled
    public static DocumentDetails getDependentAttachments(Id parentRecId,String stepNo, string source, string fieldName, string objectname, string creteriaValue){
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        System.debug('parentRecId in getAllAttachments : '+parentRecId);
        set<string> documentDescSet= new set<string>();
        list<Attachment>listOfSavedAttachments = new list<Attachment>();
        list<AttachmentWrapper> newAttachments = new list<AttachmentWrapper>();
        DocumentDetails attWithDetails = new DocumentDetails();
        
        Allergan_Customer_Address_AGN__c addressdetails=AGN_GCSP_CustomerRegStep2Controller.getCustomerAddressDetailsTemp(parentRecId);
        
        Allergan_Customer_Registration_AGN__c parentRecordDetails = AGN_GCSP_CustomerRegStep2Controller.getCustomerRegistrationDetailsTemp(parentRecId);  
        
        string documentListAdditional;
        String documentListWithoutAdditional='';
        string documentList='';
        List<string> documentNames = new List<string> ();
        string countryCode = parentRecordDetails.SAP_Country_Code_AGN__c;
        if(String.isEmpty(countryCode)){
            countryCode = parentRecordDetails.Country_Code_AGN__c;
        }
         
        
        Map<String,Set<String>> fieldDocMap = new Map<String,Set<String>>();
        List<AGN_GCSP_Document__mdt> docMetaData = new List<AGN_GCSP_Document__mdt>();
        system.debug('source::::'+source);
        docMetaData = getDependentDocumentList(countryCode,parentRecordDetails.Customer_Group_AGN__c, stepNo, fieldName, objectname, source, creteriaValue);
        Set<string> documentReturnSet = new Set<string> ();
        system.debug('docMetaData>>>>'+docMetaData);
        for(AGN_GCSP_Document__mdt attObj : docMetaData){
            
            String key = attObj.AGN_Country__c+'_'+attObj.AGN_Field_API_Name__c+'_'+attObj.Step_No_AGN__c;            
            Set<string> documentNameSet = new Set<string> ();
            String [] str = attObj.AGN_OAMDocument_List__c.split(';');
            system.debug('str>>>>'+str);
            for (integer i = 0; i < str.size(); i++){              
                documentNames.add(str[i]);
                documentNameSet.add(str[i]);
                documentReturnSet.add(str[i]);
            }
            if(!fieldDocMap.containskey(key))
            {
                fieldDocMap.put(attObj.AGN_Field_API_Name__c,documentNameSet);
            }
        }
        
        for (String str : documentReturnSet){
            newAttachments.add(new AttachmentWrapper(str, new Attachment(Description = str)));
            //documentDescSet.add(documentReturnSet[i]);
        }
        System.debug('newAttachments>>>>'+newAttachments);
        listOfSavedAttachments = [SELECT  Id,
                                  Name,
                                  Description,
                                  Body,
                                  BodyLength,
                                  ContentType,
                                  OwnerId,
                                  ParentId 
                                  FROM Attachment                                                         
                                  WHERE ParentId =:parentRecId ] ;
        
        if(listOfSavedAttachments!=null){
            for (AttachmentWrapper aw:newAttachments ){
                for(Attachment att :listOfSavedAttachments){
                    
                    if(att.Description.Trim()==aw.file.Description.Trim())
                    {    
                        aw.file.Id=att.Id;
                        aw.file.Name=att.Name;
                    }
                }
                if (aw.file.Description.containsIgnoreCase('(Required)')){
                    aw.label = aw.file.Description.removeEndIgnoreCase('(Required)');
                    aw.isRequired= true;
                    if(string.isEmpty(aw.file.Id)){
                        attWithDetails.missingAttachment= true;
                    }
                }
                
                /* for downLoad link  */
                if (aw.file.Description.containsIgnoreCase('(Download)')){
                    if(aw.file.Description.containsIgnoreCase('(Required)')){
                        aw.label = aw.file.Description.removeEndIgnoreCase('(Required)(Download)');
                    }else{
                        aw.label = aw.file.Description.removeEndIgnoreCase('(Download)');
                    }    
                    
                    String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(parentRecordDetails.Country_Code_AGN__c)?.get('Community_Base_URL_AGN__c');           
                    String comSuffix = (String)AGN_GCSP_Settings__c.getValues(parentRecordDetails.Country_Code_AGN__c)?.get('Community_Suffix_AGN__c');
                    String communityBaseURL = ''; //commonOktaConfig.Community_Base_URL_AGN__c + commonOktaConfig.Community_Suffix_AGN__c;
                    
                    if(String.isEmpty(comSuffix) || comSuffix.equalsIgnoreCase('/'))
                    {
                        communityBaseURL = comBaseURL;
                    }else{
                        communityBaseURL = comBaseURL+comSuffix;
                    }                       
                       
                    Id docId = getDocument(aw.label); 
                    if(docId != null){
                        aw.documentId = docId;
                    }
                    aw.downloadLink = communityBaseURL+'/servlet/servlet.FileDownload?file='+docId;   /* Ex: https://gcspeudev-allergancommunityeu.cs84.force.com/customerIT/servlet/servlet.FileDownload?file=   */
                    aw.isDownload= true;
                    if(string.isEmpty(aw.file.Id)){
                        attWithDetails.missingAttachment= true;
                    }
                }
            }
        }
        system.debug('fieldDocMap>>>>'+fieldDocMap);
        system.debug('==newAttachments=='+ newAttachments);
        attWithDetails.AttachmentWrapperList= newAttachments;
        // attWithDetails.missingAttachment
        system.debug('==attWithDetails=='+ attWithDetails);        
        return attWithDetails;
    }
    
    public class DocumentDetails{
        @AuraEnabled
        public List<AttachmentWrapper> attachmentWrapperList {get;set;}
        @AuraEnabled
        public List<String> webSiteList{get;set;}
        @AuraEnabled
        public Boolean missingAttachment {get;set;}
        
        public DocumentDetails(){
            this.attachmentWrapperList = new list<AttachmentWrapper>();
            this.webSiteList= new list<String>();
            this.missingAttachment = false;
        }
    }
    
    public class AttachmentWrapper{
        @AuraEnabled
        public string label {get;set;}
        @AuraEnabled
        public boolean isRequired {get;set;}
        @AuraEnabled
        public Attachment file {get;set;}
        @AuraEnabled
        public string inputFileHtmlId {get;set;}
        
        /* for Download button  */
        @AuraEnabled
        public string downloadLink {get;set;}        
        @AuraEnabled
        public boolean isDownload {get;set;}
        @AuraEnabled
        public string documentId {get;set;}
        
        public AttachmentWrapper(string newLabel, Attachment newAttachment){
            this.label = newLabel;
            this.isRequired = false;
            this.file = newAttachment;
            this.file.Description = newLabel.trim();
            this.inputFileHtmlId = newLabel.deleteWhitespace();
        }
        
    }
    
    @AuraEnabled
    public static  List<AGN_GCSP_Document__mdt> getDependentDocumentList (String countryCode,String customerGrp,String CurrStep,String fieldName,string objectname, String source, String creteriaValue){
        
        List<AGN_GCSP_Document__mdt>  docRetrunList = new List<AGN_GCSP_Document__mdt>();
        List<AGN_GCSP_Document__mdt> docList = new List<AGN_GCSP_Document__mdt>();
        system.debug('source222::::'+source);
        String regSource = String.isEmpty(source) ? '' : '\'%'+String.escapeSingleQuotes(source)+'%\''; 
        String regSourceLine =  String.isEmpty(source) ? '' : ' AND Registration_Source_AGN__c LIKE ' + regSource ;
        
        countryCode = String.isEmpty(countryCode) ? '' : '\'' + String.escapeSingleQuotes(countryCode) + '\''; 
        CurrStep = String.isEmpty(CurrStep) ? '' : '\'' + String.escapeSingleQuotes(CurrStep) + '\''; 
        fieldName = String.isEmpty(fieldName) ? '' : '\'' + String.escapeSingleQuotes(fieldName) + '\''; 
        objectname = String.isEmpty(objectname) ? '' : '\'' + String.escapeSingleQuotes(objectname) + '\''; 
        
        String queryStr = 
            'SELECT AGN_Country__c,'+
            ' Registration_Source_AGN__c,'+
            ' Dependent_Field_Show_Criteria_AGN__c,'+
            ' AGN_Field_API_Name__c,AGN_OAM_Customer_Group__c,'+
            ' AGN_OAMDocument_List__c,AGN_SObject_API_Name__c,'+
            ' Step_No_AGN__c'+
            ' FROM AGN_GCSP_Document__mdt'+
            ' WHERE AGN_Country__c = ' + countryCode + // = \'' + country + '\'' +creteriaValue
            ' AND Step_No_AGN__c = ' + CurrStep +
            ' AND AGN_Field_API_Name__c  = ' + fieldName +
            ' AND AGN_SObject_API_Name__c  = ' + objectname + ' ' + regSourceLine; 
           // ' AND Dependent_Field_Show_Criteria_AGN__c  = \'' + creteriaValue + '\'' +
            
        System.debug('queryStr es: '+queryStr);  
        docList =  Database.query(queryStr);       
        System.debug('docList>>>'+docList);
        if(!docList.isEmpty())
        {
            if (String.IsNotEmpty(customerGrp)) {

                for(AGN_GCSP_Document__mdt doc:docList)
                {
                    string docCreteria = doc.Dependent_Field_Show_Criteria_AGN__c;
                    if(docCreteria.containsIgnoreCase(creteriaValue)){
                        List < String > lstCustGrp = String.isNotEmpty(doc.AGN_OAM_Customer_Group__c) ? doc.AGN_OAM_Customer_Group__c.split(',') : new list<String>();
                        if(lstCustGrp.contains(customerGrp) || lstCustGrp.isEmpty() ) 
                        {
                            docRetrunList.add(doc);                      
                        }
                    }
                }
                  return docRetrunList;
            }
            return docList;
            
        }
        return docList;    
    }
    
    /* get documents for downLoad link  */
    public static string getDocument(string docName){
        system.debug('@@@@DocName::::'+docName);
        if(docName != ''){            
            list<Document> docId =  [SELECT Id FROM Document WHERE Name =:docName];
            if(docId.size()>0){
                return docId[0].Id; 
            }else{return null;}
            
        }else{
            return null;  
        }
        
    }
    
    // for es state wise additional attachment purpose
    public static Allergan_Customer_Address_AGN__c getCustomerAddressDetailsTemp (Id crId ){
        Allergan_Customer_Address_AGN__c caRecord = new Allergan_Customer_Address_AGN__c();   
        List<Allergan_Customer_Address_AGN__c> addresses = new List<Allergan_Customer_Address_AGN__c>([SELECT ID,Country_Code_AGN__c,State_AGN__c 
                                                                                                       FROM Allergan_Customer_Address_AGN__c 
                                                                                                       WHERE Parent_AGN__c =:crId LIMIT 1]);
        if(addresses.size() > 0){
            caRecord= addresses.get(0);
        }
        
        return caRecord;
    }
    
    public static PicklistOption[] getPicklistOptions(String ObjectName ,string fieldName) {
        List<PicklistOption> options = new List<PicklistOption>();
        sObject objObject = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values = fieldMap.get(fieldName).getDescribe().getPickListValues();
        PicklistOption option;
        option = new PicklistOption('' ,'Select');
        options.add(option);
        for (Schema.PicklistEntry a: values) {
            option = new PicklistOption(a.getValue() , a.getLabel());
            options.add(option);
        }
        system.debug('allOpts ---->' + options);
        return options;
    }
    
    public class PicklistOption{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        public PicklistOption(String value , String label){
            this.value = value;
            this.label = label;            
        }
    }
    
    public static Set<String> getFieldMetadata(String objectName,String countryCode,Integer stepNo,String customerGrp,String cusRegSource){
        
        countryCode = countryCode.equalsIgnoreCase('AN')? 'AU' : countryCode;
        AGN_Community_Layout_Setting__mdt[] configList = null;
        AGN_Community_Layout_Setting__mdt[] matchingRows = null;
        Set<String> fieldList = new Set<String>();
        
        // Checkmarx GCSP Core+ and HCO Harmonization: Adding below line to avoid SOQL/SOSL Injection - start
        // String regSource = '\'%'+cusRegSource+'%\''; 
        // String customerGroup = '\'%'+customerGrp+'%\''; 
        String regSource = '\'%'+String.escapeSingleQuotes(cusRegSource)+'%\''; 
        String customerGroup = '\'%'+String.escapeSingleQuotes(customerGrp)+'%\''; 
        countryCode = String.escapeSingleQuotes(countryCode);
        objectName = String.escapeSingleQuotes(objectName);
        // Checkmarx GCSP Core+ and HCO Harmonization: Adding below line to avoid SOQL/SOSL Injection - end
        String queryStr = 'SELECT SObject_Name_AGN__c,' +
            ' Field_Name_AGN__c,' +
            ' Step_No_AGN__c,' +    
            ' Country_AGN__c,' +  
            ' Customer_Groups_AGN__c,' +
            ' Section_Header_Sort_Order_AGN__c,' +
            ' Sort_Order_AGN__c,' +
            ' Display__c,' +
            ' Registration_Source_AGN__c ' +
            ' FROM AGN_Community_Layout_Setting__mdt ' +
            ' WHERE Country_AGN__c = \'' + countryCode + '\'' +
            ' AND Step_No_AGN__c = \'' + stepNo + '\''+
            ' AND Registration_Source_AGN__c LIKE ' + regSource +
            ' AND SObject_Name_AGN__c = \'' + objectName + '\'' +
            ' AND Display__c = true ORDER BY Section_Header_Sort_Order_AGN__c, Sort_Order_AGN__c';
         //' AND Customer_Groups_AGN__c LIKE ' + customerGroup + 
        System.debug('queryStr es: '+queryStr);        
        configList = Database.query(queryStr);
        System.debug('configList: '+configList); 
        System.debug('Size: '+configList.size()); 
         
        for(AGN_Community_Layout_Setting__mdt tempObj:configList){            
            if(String.isEmpty(tempObj.Customer_Groups_AGN__c) || tempObj.Customer_Groups_AGN__c.contains(customerGrp) ) {
                fieldList.add(tempObj.Field_Name_AGN__c);
            }
        }
        System.debug('fieldList: '+fieldList); 
        return fieldList;
    }
    
    public static List<Allergan_Consent_Footer_Info__c> getFooterConsents(String countryCode) {
        
        List<Allergan_Consent_Footer_Info__c> footerLst = [Select Id, Name, Language__c, Footer_RichText_c__c from Allergan_Consent_Footer_Info__c where Language__c= :countryCode Order by Display_Order__c asc];
        return footerLst;
    }
    
    public static List<sObject> getSpecialityDetails(String countryCode){  
        
        
        List<sObject> PicklistValues = [SELECT Id,
                                        Translated_Value_AGN__c,
                                        English_Value_AGN__c 
                                        FROM Specialty_Allergan_AGN__c
                                        WHERE Country_code_AGN__c=:countryCode
                                        AND Active_AGN__c= true];        
        return PicklistValues;   
        
    }
    
}