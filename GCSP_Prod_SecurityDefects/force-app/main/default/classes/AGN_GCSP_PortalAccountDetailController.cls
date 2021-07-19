/**
* @File Name          : AGN_GCSP_PortalAccountDetailController.cls
* @Description        : get the all the communty User information.
* @Author             : GCSP Core Plus Dev Team
* @Group              :
* @Last Modified By   : GCSP Core Plus Dev Team
* @Last Modified On   : 14/04/2021
* @Modification Log   :
* Ver       Date            Author                  			Modification
* 1.0    07/02/2021  		GCSP Core Plus Dev Team    			Initial Version
**/
public without sharing class AGN_GCSP_PortalAccountDetailController {
    
    @AuraEnabled
    public static List<String> getCummunityURL()
    {
        AGN_GCSP_Common_Setting_AGN__mdt commonSettings = AGN_GCSP_Utilities.getGCSPCommonSetting();
        List<User> pUser = [Select Id, Username, Country_Code__c, LanguageLocaleKey from User where Id =: Userinfo.getUserId() and IsActive = true LIMIT 1];
        string userCountry = pUser.isEmpty() ? '' : pUser[0].Country_Code__c;
		userCountry = userCountry.equalsIgnoreCase('IE')?'GB':userCountry;
       
        final String COMMUNITY_BASE_URL = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Base_URL_AGN__c');
            //commonOktaConfig.Community_Base_URL_AGN__c;
        final String COMMUNITY_SUFFIX = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Suffix_AGN__c');
            //commonOktaConfig.Community_Suffix_AGN__c;
        List<String> strLst = new List<String>();
        strLst.add(COMMUNITY_BASE_URL);//commonSettings.Community_Base_URL_AGN__c
        strLst.add(COMMUNITY_SUFFIX);//commonSettings.Community_Suffix_AGN__c
        system.debug('strLst>>>'+strLst);
        return strLst;
    }
    
    @AuraEnabled
    public static User getUserDetail() {
        try{
            User usr = [SELECT Id,
                        Name,
                        LocaleSidKey, 
                        Country_Code__c,
                        Profile.Name,
                        SmallPhotoUrl,
                        Contact.Customer_Registration_AGN__c,
                        Account.Customer_Registration_AGN__c  
                        FROM User WHERE Id= :UserInfo.getUserId()];
            return usr;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getredirectUrl(){
        
        String urlToRedirect;
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        final String COMMUNITY_BASE_URL = commonOktaConfig.Community_Base_URL_AGN__c;
        final String COMMUNITY_SUFFIX = commonOktaConfig.Community_Suffix_AGN__c;
        
        String RegStepNo = AGN_GCSP_Utilities.getADRegStepInfos();
        
        String urlRedirectPage = '';
        
        
        if(String.isEmpty(COMMUNITY_SUFFIX) || COMMUNITY_SUFFIX.equals('/') ) {
            urlToRedirect = COMMUNITY_BASE_URL;
        }
        else{
            urlToRedirect = COMMUNITY_BASE_URL + COMMUNITY_SUFFIX;
        }
        
        
        if(String.isNotEmpty(RegStepNo) && RegStepNo != '5')
        {
            //&& RegStepNo != '5'
            Switch on RegStepNo {
                When '1' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step1_Registration_Page_AGN__c; 
                }
                
                When '2' {
                    urlRedirectPage = commonOktaConfig.OAM_Step2_Registration_Page_AGN__c;
                }
                
                When '3' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step3_Registration_Page_AGN__c;
                }
                
                When '4' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step4_Registration_Page_AGN__c;
                }
                
            }
        }
        return urlRedirectPage;
    }
    
    @AuraEnabled
    public static string getRegistrationStepPage(){
        String urlToRedirect;
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        
        String RegStepNo = AGN_GCSP_Utilities.getADRegStepInfos();
        
        List<User> pUser = [Select Id, Username, Country_Code__c, LanguageLocaleKey from User where Id =: Userinfo.getUserId() and IsActive = true LIMIT 1];
        string userCountry = pUser.isEmpty() ? '' : pUser[0].Country_Code__c;
		userCountry = userCountry.equalsIgnoreCase('IE')?'GB':userCountry;
       
        final String COMMUNITY_BASE_URL = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Base_URL_AGN__c');
            //commonOktaConfig.Community_Base_URL_AGN__c;
        final String COMMUNITY_SUFFIX = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Suffix_AGN__c');
            //commonOktaConfig.Community_Suffix_AGN__c;
        
        String urlRedirectPage = '';
        
        if(String.isEmpty(COMMUNITY_SUFFIX) || COMMUNITY_SUFFIX.equals('/') ) {
            urlToRedirect = COMMUNITY_BASE_URL;
        }
        else{
            urlToRedirect = COMMUNITY_BASE_URL + COMMUNITY_SUFFIX;
        }
        
        if(String.isNotEmpty(RegStepNo))
        {
            //&& RegStepNo != '5'
            Switch on RegStepNo {
                When '1' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step1_Registration_Page_AGN__c; 
                }
                
                When '2' {
                    urlRedirectPage = commonOktaConfig.OAM_Step2_Registration_Page_AGN__c;
                }
                
                When '3' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step3_Registration_Page_AGN__c;
                }
                
                When '4' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step4_Registration_Page_AGN__c;
                }
                
                When '5' { 
                    urlRedirectPage = commonOktaConfig.OAM_Step4_Registration_Page_AGN__c;
                }
                
            }
            
            if(RegStepNo.equalsIgnoreCase('Complete')){
                urlRedirectPage = '/s';
            }            
            urlToRedirect +=  urlRedirectPage +'?language=' + AGN_GCSP_Utilities.getUserLocale +'&country='+userCountry;
            
        } else{
            urlToRedirect += '/AGN_GCSP_CustomerPortalOktaLogin/' + '?language=' + AGN_GCSP_Utilities.getUserLocale+'&country='+userCountry;
        } 
        
        return urlToRedirect;
        
    }
    
    @AuraEnabled
    public static AGN_GCSP_Settings__c getGCSPSettingsDetails(string countryCode) {
        string countryCodeVal = '';
        if(string.isEmpty(countryCode)){
            countryCodeVal = [SELECT Id, Country_Code__c from User where Id =: UserInfo.getUserId() limit 1]?.Country_Code__c;
        }
        else{
            countryCodeVal = countryCode;
        }
        
        AGN_GCSP_Settings__c gcspset = AGN_GCSP_Settings__c.getValues(countryCodeVal);
        return gcspset;
    }
    
    @AuraEnabled
    public static Contact getContactDetailsBySapID(String contactId) {
        try{
            String conId = String.escapeSingleQuotes(contactId);
            String SobjectApiName = 'Contact';
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
            string accFields = 'Account.Customer_Category_AGN__c, Account.Customer_Sub_Category_AGN__c, Account.SAP_Customer_Group_AGN__c, Account.Country_Code__c, Account.Country_vod__c, Account.Country_vod__r.AGN_Country_Name__c, Account.SAP_Country_Code_AGN__c';
            query = 'select '+accFields+', ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE ID ='+'\''+ conId+ '\'';
            
            Contact con = Database.query(query);  
            
            return con;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Contact getContactDetails() {
        try{
            User uInfo = [SELECT Id, ContactId from User where Id =: UserInfo.getUserId() limit 1];
            String conId = String.escapeSingleQuotes(uInfo.ContactId);
            String SobjectApiName = 'Contact';
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
            string accFields = 'Account.Customer_Category_AGN__c, Account.Customer_Sub_Category_AGN__c, Account.SAP_Customer_Group_AGN__c, Account.Country_Code__c, Account.Country_vod__c, Account.Country_vod__r.AGN_Country_Name__c, Account.SAP_Country_Code_AGN__c';
            query = 'select '+accFields+', ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE ID ='+'\''+ conId+ '\'';
            
            Contact con = Database.query(query);  
            
            system.debug('@@@con::::'+con);
            
            return con;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //get all 3 types of addresses based on affiliation
    @AuraEnabled
    public static list<SAPdataWrapper> getSAPDetailsByContact(){
        try{
            Contact con = getContactDetails();
            system.debug('con::::::'+con);
            list<SAPdataWrapper> sapDataWrap = new list<SAPdataWrapper>(); 
            set<Id> customerDetailRecIds = new set<Id>();      
            
            for(Contact_Custmer_Detail_Relation_AGN__c ccdr: [SELECT Id, Name, 
                                                              Contact_AGN__c, 
                                                              Customer_Detail_AGN__c, 
                                                              Sold_To_AGN__c, 
                                                              Ship_To_AGN__c, 
                                                              Bill_To_AGN__c,
                                                              Is_Active_AGN__c
                                                              FROM Contact_Custmer_Detail_Relation_AGN__c
                                                              WHERE Contact_AGN__c =: con.Id
                                                              AND Is_Active_AGN__c = true]){
                                                                  
                                                                  
                                                                  customerDetailRecIds.add(ccdr.Customer_Detail_AGN__c);                                                              
                                                                  
                                                              }
            
            String commaSepratedFields = getAllSobjectFields('Customer_Detail_AGN__c');
            String query = 'select '+commaSepratedFields + ' from Customer_Detail_AGN__c' + ' WHERE Id IN:customerDetailRecIds';
            
            for(Customer_Detail_AGN__c sapData  : Database.query(query)){
                
                if(sapData.SAP_Sold_To_AGN__c){
                    sapDataWrap.add(new SAPdataWrapper(sapData.Calling_Name_AGN__c, sapData, 'SoldTo'));
                } else if(sapData.SAP_Ship_To_AGN__c && !sapData.SAP_Sold_To_AGN__c){
                    sapDataWrap.add(new SAPdataWrapper(sapData.Calling_Name_AGN__c, sapData, 'ShipTo'));
                } else if(sapData.SAP_Bill_To_AGN__c && !sapData.SAP_Sold_To_AGN__c){
                    sapDataWrap.add(new SAPdataWrapper(sapData.Calling_Name_AGN__c, sapData, 'BillTo'));
                }
            } 
            
            return sapDataWrap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    //get all 3 types of addresses based on affiliation
    @AuraEnabled
    public static list<SAPdataWrapper> getSAPDetailsSoldTo(String soldToSAPID){
        try{
            String sapID = string.escapeSingleQuotes(soldToSAPID);
            list<SAPdataWrapper> sapDataWrap = new list<SAPdataWrapper>(); 
            set<Id> customerDetailRecIds = new set<Id>();      
            
            //Parent_SAP_Id_AGN__c External_ID_AGN__c
            String commaSepratedFields = getAllSobjectFields('Customer_Detail_AGN__c');
            String query = 'select '+commaSepratedFields + ' from Customer_Detail_AGN__c' + ' WHERE Parent_SAP_Id_AGN__c =:sapID OR External_ID_AGN__c =:sapID';
            system.debug('query>>'+query);
            for(Customer_Detail_AGN__c sapData  : Database.query(query)){
                if(!sapData.Inactive_AGN__c){
                    if(sapData.SAP_Sold_To_AGN__c){
                        sapDataWrap.add(new SAPdataWrapper(sapData.Calling_Name_AGN__c, sapData, 'SoldTo'));
                    } else if(sapData.SAP_Ship_To_AGN__c && !sapData.SAP_Sold_To_AGN__c){
                        sapDataWrap.add(new SAPdataWrapper(sapData.Calling_Name_AGN__c, sapData, 'ShipTo'));
                    } else if(sapData.SAP_Bill_To_AGN__c && !sapData.SAP_Sold_To_AGN__c){
                        sapDataWrap.add(new SAPdataWrapper(sapData.Calling_Name_AGN__c, sapData, 'BillTo'));
                    }
                } 
            } 
            
            return sapDataWrap;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    public static String getAllSobjectFields(String SobjectApiName){   
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
        return commaSepratedFields;
    }
    
    
    @AuraEnabled
    public static PrymaryContactWrapData getHeaderWrapDetailsByContact(Customer_Detail_AGN__c soldToSAPData) {
        system.debug('@@@soldToSAPData:::::  '+soldToSAPData);
        PrymaryContactWrapData conWrapData = new PrymaryContactWrapData();
        Contact con = getContactDetails();       
        Customer_Type_Configuration_AGN__c configData = getCustomertypeConfigDetails(soldToSAPData);
        conWrapData = new PrymaryContactWrapData(con, configData, soldToSAPData);
        return conWrapData;    
    }
    @AuraEnabled
    public static PrymaryContactWrapData getHeaderWrapDetailsBySAPId(Customer_Detail_AGN__c soldToSAPData) {
        system.debug('@@@soldToSAPData:::::  '+soldToSAPData);
        PrymaryContactWrapData conWrapData = new PrymaryContactWrapData();
        String contactId = [SELECT Contact_AGN__c FROM  Contact_Custmer_Detail_Relation_AGN__c 
                            WHERE Customer_Detail_AGN__c =: soldToSAPData.Id 
                            AND Sold_To_AGN__c = true AND Is_Active_AGN__c = true AND Contact_AGN__r.Is_Primary_Contact_AGN__c = true LIMIT 1]?.Contact_AGN__c;
        
        Contact con = String.isNotEmpty(contactId) ? getContactDetailsBySapID(contactId) : new Contact();  
        
        Customer_Type_Configuration_AGN__c configData = getCustomertypeConfigDetails(soldToSAPData);
        conWrapData = new PrymaryContactWrapData(con, configData, soldToSAPData);
        return conWrapData;    
    }
    
    @AuraEnabled
    public static Customer_Detail_AGN__c getSoldToSAPDetails(String soldToAcc) {
        try{
            String commaSepratedFields = getAllSobjectFields('Customer_Detail_AGN__c');
            String query = 'select '+commaSepratedFields + ' from Customer_Detail_AGN__c WHERE Parent_Account_AGN__c =:soldToAcc AND SAP_Sold_To_AGN__c = true LIMIT 1';
            list<Customer_Detail_AGN__c> sapDataList = Database.query(query);
            
            return sapDataList.isEmpty()? new Customer_Detail_AGN__c() : sapDataList[0];
            
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Customer_Type_Configuration_AGN__c getCustomertypeConfigDetails(Customer_Detail_AGN__c sapData){
        try{
            
            /*  String countryCode = '';
				if(sapData.Country_Code_AGN__c == 'GB' && sapData.SAP_Country_Code_AGN__c != null){
					countryCode = sapData.SAP_Country_Code_AGN__c;
				}else{
					countryCode = sapData.Country_Code_AGN__c;
				}*/
				String countryCode = sapData.SAP_Country_Code_AGN__c;
				if(String.isEmpty(countryCode) || countryCode.equalsIgnoreCase('AU')){
                countryCode = sapData.Country_Code_AGN__c;
            }
            
            String customerGroup = sapData.SAP_Customer_Group_AGN__c;
            String custCategory = sapData.Customer_Category_AGN__c; 
            String subCategory = sapData.Customer_Sub_Category_AGN__c;
            system.debug('>>>>'+countryCode+'>>>'+customerGroup+'>>>>'+custCategory+'>>>'+subCategory);
            Customer_Type_Configuration_AGN__c config = [SELECT 
                                                         Account_Record_Type_AGN__c,
                                                         Category_AGN__c,
                                                         Country_Code_AGN__c,
                                                         Customer_Country_AGN__c,
                                                         Customer_Country_AGN__r.Alpha_2_Code_vod__c,
                                                         Customer_Country_AGN__r.AGN_Country_Name__c,
                                                         Customer_Group_AGN__c,
                                                         Cust_Group_Desc_AGN__c,
                                                         Sub_Category__c,
                                                         Specialty_Allergan_AGN__c,
                                                         Sub_Specialty_Allergan_AGN__c,
                                                         Category_Label_AGN__c,
                                                         Sub_Category_Label_AGN__c                       
                                                         FROM Customer_Type_Configuration_AGN__c
                                                         WHERE Customer_Country_AGN__r.Alpha_2_Code_vod__c =:countryCode
                                                         AND Customer_Group_AGN__c =: customerGroup
                                                         AND (Category_AGN__c =:custCategory OR Category_Label_AGN__c =:custCategory)
                                                         AND (Sub_Category__c =:subCategory OR Sub_Category_Label_AGN__c =:subCategory) 
                                                         LIMIT 1
                                                        ];
            return config;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //wrapper class for SAP Data
    public class SAPdataWrapper{
        @AuraEnabled
        public string SAPName {get;set;}
        @AuraEnabled
        public Customer_Detail_AGN__c sapDetails {get;set;}
        @AuraEnabled
        public string accountType {get;set;}
        @AuraEnabled
        public string houseNumber{get;set;}
        @AuraEnabled
        public string streetName {get;set;}
        
        
        public SAPdataWrapper(string name, Customer_Detail_AGN__c sapData){
            this.SAPName = name;
            this.sapDetails = sapData;
            houseNumber= '';
            streetName= '';
            
        }
        
        public SAPdataWrapper(string name, Customer_Detail_AGN__c sapData, string type){
            system.debug('name::::::::'+name);
            system.debug('sapData::::::::'+sapData);
            this.SAPName = name;
            this.sapDetails = sapData;
            this.accountType = type;
            string addLine1 = string.isNotEmpty(sapData.Address_Line_1_AGN__c) ? sapData.Address_Line_1_AGN__c : '';
            houseNumber = !String.isBlank(addLine1)&& addLine1.Contains(',') ?addLine1.split(',')[1].Trim():'';
            streetName = !String.isBlank(addLine1)&& addLine1.Contains(',') ?addLine1.split(',')[0].Trim():addLine1.Trim();
            
        }
    }
    
    //get Contact and customer type configuaration objectdata 
    public class PrymaryContactWrapData{
        @AuraEnabled public Contact con {get;set;}
        // @AuraEnabled public Country_vod__c country {get;set;}
        @AuraEnabled public Customer_Type_Configuration_AGN__c customerTypeConfig {get;set;}
        @AuraEnabled public Customer_Detail_AGN__c soldToSAPData {get; set;}
        
        public PrymaryContactWrapData(){}
        public PrymaryContactWrapData(Contact con, Customer_Type_Configuration_AGN__c customerTypeConfig, Customer_Detail_AGN__c soldToSAPData){
            this.con = con;
            this.customerTypeConfig = customerTypeConfig;
            //this.country = country;
            this.soldToSAPData = soldToSAPData;
        }
    }
    
    @AuraEnabled
    public static String getAD_OktaSSOUrl()
    {
        try{
            if(AGN_OAMConstant.USERCOUNTRYCODE.equalsIgnoreCase('CA')){
                if(AGN_OAMConstant.USERLANGUAGE.containsIgnoreCase('en')){
                    return AGN_OAMConstant.ALLERGAN_DIRECT_OKTA_SSO_URL;
                }else{
                    return (String)AGN_GCSP_Settings__c.getValues(AGN_OAMConstant.USERCOUNTRYCODE).get('E_Commerce_Okta_SSO_URL_1_AGN__c'); 
                }
            }else{
                string userCountryCode = [Select Contact.SAP_Country_Code_AGN__c from User WHERE Id =: Userinfo.getUserId()]?.Contact.SAP_Country_Code_AGN__c;
                if (String.IsEmpty(userCountryCode)){
                    return  AGN_OAMConstant.ALLERGAN_DIRECT_OKTA_SSO_URL;
                }else{
                    return (String)AGN_GCSP_Settings__c.getValues(userCountryCode)?.get('E_Commerce_SSO_URL_AGN__c'); 
                }
                
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }     
    
    @AuraEnabled(cacheable=true)
    public static Boolean isRegistrationCompleted()
    {
        try{
            User currentUser = [Select Contact.Customer_Registration_AGN__c, Account.Customer_Registration_AGN__c from User where Id =: UserInfo.getUserId() limit 1];
            if(currentUser.Account.Customer_Registration_AGN__c == 'Complete' || currentUser.Contact.Customer_Registration_AGN__c == 'Complete'){
                return true;
            }
            else{
                return false;
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    } 
    
    @AuraEnabled(cacheable=true)
    public static Boolean hasAllerganDirectAccess()
    {
        try{
            User currentUser = [Select Contact.Has_Allergan_Direct_Access_AGN__c from User where Id =: UserInfo.getUserId() limit 1]; 
            if(AGN_OAMConstant.USERCOUNTRYCODE.equalsIgnoreCase('BR') && (currentUser.Contact.Has_Allergan_Direct_Access_AGN__c == false || currentUser.Contact.Has_Allergan_Direct_Access_AGN__c == null)){
                return false;            
            }else{
                return true; 
            }
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    } 
    
    
}