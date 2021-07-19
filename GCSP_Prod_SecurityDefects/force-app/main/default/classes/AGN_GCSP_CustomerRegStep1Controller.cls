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
public without sharing class AGN_GCSP_CustomerRegStep1Controller {
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
    
    @AuraEnabled(cacheable=true)
    public static Map < String, List < AGN_Community_Layout_Setting__mdt >> getLayout(String country, String stepNo, String source) {
        try{
            return AGN_GCSP_CustomerRegUtils.getLayoutCountrySetting(country, stepNo, null, null, null, source);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map < String, List < AGN_Community_Layout_Setting__mdt >> getLayout(String country, String stepNo, String customerType, String customerSubType, List < Customer_Type_Configuration_AGN__c > custTypeConfig, String source) {
        try{
            return AGN_GCSP_CustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, custTypeConfig, source);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 

    @AuraEnabled
    public static String getCustomerGroup(String countryCode, String customerType , String customerSubType) { 
        try{
            return AGN_GCSP_CustomerRegUtils.getCustomerGroup(countryCode, customerType, customerSubType);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled
    public static Account createAccount(Allergan_Customer_Address_AGN__c customerAddress, Allergan_Customer_Registration_AGN__c customer , String country){
        try{
            return AGN_GCSP_CustomerRegUtils.createAccount(customerAddress, customer , country);
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Contact createContact(Allergan_Customer_Registration_AGN__c customer, Account acc,String country){
        
        system.debug('@@@@acc>>>>>>'+acc);
        try{
            return AGN_GCSP_CustomerRegUtils.createContact(customer, acc, country);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id createCommunityUser(Id customerContactId , String countryCode , String userLocale ){
        try{      
            
            return AGN_GCSP_CustomerRegUtils.createCommunityUser(customerContactId , countryCode, userLocale);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Id createNewCustomerRegistration(Allergan_Customer_Registration_AGN__c customer, 
                                                   Allergan_Customer_Address_AGN__c customerAddress, 
                                                   List<Customer_Type_Configuration_AGN__c> configList,
                                                   Contact customerContact , String userLocale) {
        
        try{
            return AGN_GCSP_CustomerRegUtils.createNewCustomerRegistration(customer, customerAddress, configList, customerContact, userLocale);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    @AuraEnabled
    public static Id createNewCustomerRegistrationCS(Allergan_Customer_Registration_AGN__c customer, 
                                                   Allergan_Customer_Address_AGN__c customerAddress, 
                                                   List<Customer_Type_Configuration_AGN__c> configList,
                                                   Contact customerContact, 
                                                   Case caseCr,
                                                   Allergan_Customer_Contact_AGN__c acrContact,
                                                   String userLocale) {
                                                      
        
        try{
            return AGN_GCSP_CustomerRegUtils.createNewCustomerRegistrationCS(customer, customerAddress, configList, customerContact, caseCr, acrContact, userLocale);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled
    public static String createOktaUserSendLink(Allergan_Customer_Registration_AGN__c customer, Contact customerContact, String userLocale , String country)
    {
        
        try{
            return AGN_GCSP_CustomerRegUtils.createOktaUserSendLink(customer, customerContact, userLocale, country);
        }
        catch (Exception e) {
           system.debug('Exception : '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
            //return null;
        }
    }
    
    @AuraEnabled
    public static boolean isDuplicateUser(String email , String country){
        try{
           return AGN_GCSP_CustomerRegUtils.checkForDuplicateCustomer(email , country); 
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /*
    * @description Returns customer registration data 
    * @param NIL
    * @return returns Allergan Customer Registration
    * @createdby GCSP Developer Team
    * @modifieddate 05-Sept-2019
    */
    
    @AuraEnabled(cacheable=true)
    public static List<Object> getAllConfigurations(String countryCode , String step , String customerType, String customerSubType, String source) {
        try{
            List<Object> configObject = new List<Object>();
            List<Country_vod__c> options = new List<Country_vod__c>();
            
            Set<String> uniqueCountry = new Set<String>();
            String sapCountryCode = '';
            if(string.isNotEmpty(countryCode) && countryCode.equalsIgnoreCase('AU') || countryCode.equalsIgnoreCase('NZ')){
                sapCountryCode = 'AN';
            }else if(string.isNotEmpty(countryCode)){
                sapCountryCode = countryCode;
            }
            List<Customer_Type_Configuration_AGN__c> customerTypeConfigList = customerTypeConfig(sapCountryCode, source);        
            //system.debug('user country code : '+AGN_OAMConstant.USERCOUNTRYCODE);
            if(customerTypeConfigList !=null && !customerTypeConfigList.isEmpty()){
                if(countryCode.equalsIgnoreCase('GB') || countryCode.equalsIgnoreCase('IE') || countryCode.equalsIgnoreCase('AN') || countryCode.equalsIgnoreCase('AU') || countryCode.equalsIgnoreCase('NZ')){
                    for(Customer_Type_Configuration_AGN__c custConfig : customerTypeConfigList)
                    {
                        //system.debug('Customer_Country_AGN__r.Name : '+custConfig.Customer_Country_AGN__r.Name);
                        uniqueCountry.add(custConfig.Customer_Country_AGN__r.Name);            
                    }
                }           
                else{
                    for(Customer_Type_Configuration_AGN__c custConfig : customerTypeConfigList)
                    {
                        //system.debug('custConfig.Country_Code_AGN__c : '+custConfig.Country_Code_AGN__c);
                        uniqueCountry.add(custConfig.Country_Code_AGN__c);            
                    }
                }
                System.debug('uniqueCountry : '+uniqueCountry.size());
                
                options = [SELECT Id,
                           Alpha_2_Code_vod__c,
                           AGN_Country_Name__c
                           FROM Country_vod__c
                           WHERE Alpha_2_Code_vod__c IN:uniqueCountry];
                
                configObject.add(options);
                configObject.add(customerTypeConfigList);
                if(countryCode.equalsIgnoreCase('CA')){
                    List<AGN_CR_CountryRegionMapping__mdt> provinces = provinceList(countryCode);
                    configObject.add(provinces);
                }
                Map < String, List < AGN_Community_Layout_Setting__mdt >> layoutSettings = AGN_GCSP_CustomerRegUtils.getLayoutCountrySetting(countryCode,step,customerType,customerSubType,customerTypeConfigList, source);
                configObject.add(layoutSettings);
            }
            system.debug('Configuration Object>>>>>>>>>>>>>>>>>>'+configObject);
            return configObject;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static List<Customer_Type_Configuration_AGN__c> customerTypeConfig(String countryCode, String source) {
        
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
        countryCode = string.escapeSingleQuotes(countryCode);
        string configFields = 'Customer_Country_AGN__r.Name';
        // Checkmarx GCSP Core+ and HCO Harmonization: Adding below line to avoid SOQL/SOSL Injection
        countryCode = String.escapeSingleQuotes(countryCode);
        query = 'select '+configFields+', ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE IsActive_AGN__c = true AND Category_Label_AGN__c !=NULL AND Sub_Category_Label_AGN__c !=NULL AND ( Country_Code_AGN__c ='+'\''+ countryCode+ '\''+' OR Customer_Country_AGN__r.Alpha_2_Code_vod__c ='+'\''+ countryCode+ '\''+' )'; 
            query+= isOnlineRegister ? ' AND Applicable_For_Online_Registration_AGN__c ='+isOnlineRegister : '';
         System.debug('query>>>'+ query);
        List<Customer_Type_Configuration_AGN__c> configList = Database.query(query);  
        
        return configList.isEmpty() ? new list<Customer_Type_Configuration_AGN__c>() : configList;
        
       /* return [SELECT 
                Account_Record_Type_AGN__c,
                Category_AGN__c,
                Country_Code_AGN__c,
                Customer_Group_AGN__c ,
                Sub_Category__c,
                Specialty_Allergan_AGN__c,
                Sub_Specialty_Allergan_AGN__c,
                Category_Label_AGN__c,
                Sub_Category_Label_AGN__c,
                Province_AGN__c,
                Customer_Country_AGN__r.Name,
                Product_Interest_AGN__c 
                FROM Customer_Type_Configuration_AGN__c 
                WHERE Country_Code_AGN__c=:countryCode 
                AND Applicable_For_Online_Registration_AGN__c = True]; */
    }
    
  

    private static List<AGN_CR_CountryRegionMapping__mdt> provinceList(String countryCode) {
        if(string.isNotEmpty(countryCode)){
            return [SELECT
                Country_Name__c,
                Country_Code__c,
                MasterLabel,
                RegionCode__c,
                RegionName__c,
                Region_Label_AGN__c 
                FROM AGN_CR_CountryRegionMapping__mdt WHERE Country_Code__c =:countryCode];
        }
        else{           
       
        return [SELECT
                Country_Name__c,
                Country_Code__c,
                MasterLabel,
                RegionCode__c,
                RegionName__c,
                Region_Label_AGN__c 
                FROM AGN_CR_CountryRegionMapping__mdt WHERE Country_Code__c =:AGN_OAMConstant.USERCOUNTRYCODE];
            
             }
    }
    
    @AuraEnabled(cacheable=true)
    public static Allergan_Customer_Registration_AGN__c getCustomerRegDetails() {
        try{
            User uInfo = [SELECT Id, ContactId from User where Id =: UserInfo.getUserId() limit 1];
            //Contact con = getContactDetails();        
            Allergan_Customer_Contact_AGN__c customerContact = [SELECT Id,Parent_AGN__c,Contact_AGN__c,Contact_Person_Type_AGN__c 
                                                                FROM Allergan_Customer_Contact_AGN__c 
                                                                WHERE Contact_AGN__c =: uInfo.ContactId];
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
            
            Allergan_Customer_Registration_AGN__c custReg = Database.query(query);  
            
            return custReg;              
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
     @AuraEnabled
    public static List<Allergan_Customer_Address_AGN__c> getCustomerAddressDetails(String custRegId) {
        try{
            //Allergan_Customer_Registration_AGN__c custReg = getCustomerRegDetails();
            String RegId = String.escapeSingleQuotes(custRegId); 
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
            query = 'select '+ commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Parent_AGN__c ='+'\''+ RegId + '\'' + ' ORDER BY createdDate DESC';
            
            List<Allergan_Customer_Address_AGN__c> custAdd = Database.query(query); 
            
            
            return custAdd;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
     }
    
    @AuraEnabled(cacheable=true)
    public static AGN_GCSP_PortalCustomerRegUtils.PicklistOption[] getPicklistOptions(String ObjectName ,string fieldName) {
        
        try{
            return AGN_GCSP_PortalCustomerRegUtils.getPicklistOptions(ObjectName,fieldName);
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static AGN_GCSP_Common_Setting_AGN__mdt getCommonSettings(){
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = new AGN_GCSP_Common_Setting_AGN__mdt();
        
        try{
            commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return commonOktaConfig;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Allergan_Consent_Footer_Info__c> fetchFooterConsents(String langCode){
        List<Allergan_Consent_Footer_Info__c> footerList = AGN_GCSP_PortalCustomerRegUtils.getFooterConsents(langCode);
        return footerList;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<Allergan_Consent_Footer_Info__c> getCustomerCofing(String langCode){
        List<Allergan_Consent_Footer_Info__c> footerList = AGN_GCSP_PortalCustomerRegUtils.getFooterConsents(langCode);
        return footerList;
    }
    
    @AuraEnabled
    public static AGN_GCSP_CustomerRegUtils.AddressDetail getAddressInformation(String cepCode){
        AGN_GCSP_CustomerRegUtils.AddressDetail addDetail = AGN_GCSP_CustomerRegUtils.getAddressDetail(cepCode);
        return addDetail;
    }
    
   
}