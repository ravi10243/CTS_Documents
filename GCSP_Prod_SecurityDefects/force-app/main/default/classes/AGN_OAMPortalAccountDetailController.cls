/*
Type Name: AGN_OAMPortalAccountDetailController
Reason: Controller class for Cusomer home page lightning components
10-06-2019 - SG - Initial Version
*/
public without sharing class AGN_OAMPortalAccountDetailController {  
    
    @AuraEnabled
    public static List<String> getCummunityURL()
    {
        List<String> strLst = new List<String>();
        strLst.add(AGN_OAMConstant.COMMUNITY_BASE_URL);
        strLst.add(AGN_OAMConstant.COMMUNITY_SUFFIX);
        return strLst;
    }
    
    @AuraEnabled
    public static User getUserDetail() {
        User usr = 
            [SELECT Id,Name,Profile.Name,SmallPhotoUrl,Contact.Customer_Registration_AGN__c  
             FROM User WHERE Id= :UserInfo.getUserId()];
        return usr;
    } 
    
    @AuraEnabled
    public static AGN_GCSP_Settings__c getGCSPSettingsDetails() {
        User uInfo = [SELECT Id, Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        AGN_GCSP_Settings__c gcspset = AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c);
        return gcspset;
    }
    
    @AuraEnabled
    public static Contact getContactDetails() {
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
        
        return con;
    }
    @AuraEnabled
    public static Account getBussinessAccountDetails(String accId) {
       // Contact Con = getContactDetails();
        String conAccId = String.escapeSingleQuotes(accId);
        String SobjectApiName = 'Account';
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
        query = 'select Country_vod__r.AGN_Country_Name__c, ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE ID ='+'\''+ conAccId+ '\'';
        
        Account bzAcc = Database.query(query);  
        
        return bzAcc;
    }     
    //get all 3 types of addresses based on affiliation
    @AuraEnabled
    public static list<AddressWrapper> getAddressDetails(){
        Contact con = getContactDetails();
        list<AddressWrapper> addresses = new list<AddressWrapper>();        
        map<string, set<Id>> parentIdMap = new map<string, set<Id>>();
        set<Id> parentIds = new set<Id>();
        system.debug('con.AccID>>>>>>'+con.AccountId);
        
        parentIds.add(con.AccountId);// for soldTo AccountData
        
       /*  for (Child_Account_vod__c ch : [SELECT Parent_Account_vod__c,Child_Account_vod__c,
                                        Sold_To_AGN__c,Ship_To_AGN__c,Bill_To_AGN__c 
                                        FROM Child_Account_vod__c WHERE Parent_Account_vod__c = : con.AccountId]){
                                            //WHERE Child_Account_vod__c = : con.AccountId AND Customer_Managed_AGN__c = True
                                           if (ch.Sold_To_AGN__c){ //
                                                if (!parentIdMap.containsKey('SoldTo'))
                                                    parentIdMap.put('SoldTo', new set<Id>{ch.Parent_Account_vod__c});
                                                else
                                                    parentIdMap.get('SoldTo').add(ch.Parent_Account_vod__c);
                                                
                                                parentIds.add(ch.Parent_Account_vod__c);
                                            }
                                            else if (ch.Ship_To_AGN__c){
                                                if (!parentIdMap.containsKey('ShipTo'))
                                                    parentIdMap.put('ShipTo', new set<Id>{ch.Child_Account_vod__c});
                                                else
                                                    parentIdMap.get('ShipTo').add(ch.Child_Account_vod__c);
                                                
                                                parentIds.add(ch.Child_Account_vod__c);
                                            }
                                            else if (ch.Bill_To_AGN__c){
                                                if (!parentIdMap.containsKey('BillTo'))
                                                    parentIdMap.put('BillTo', new set<Id>{ch.Child_Account_vod__c});
                                                else
                                                    parentIdMap.get('BillTo').add(ch.Child_Account_vod__c);
                                                
                                                parentIds.add(ch.Child_Account_vod__c);
                                            } 
                                        }  */
        
        for (Address_vod__c a : [SELECT Id, 
                                 Account_vod__c, 
                                 Account_vod__r.External_ID2_AGN__c, 
                                 Account_vod__r.Name,
                                 Account_vod__r.SAP_Sold_To_AGN__c,
                                 Account_vod__r.SAP_Ship_To_AGN__c,
                                 Account_vod__r.SAP_Bill_To_AGN__c,
                                 Account_vod__r.Calling_Name_AGN__c, 
								 Account_vod__r.Primary_Parent_vod__c,
                                 Name, 
                                 Province_AGN__c,                                 
                                 Address_line_2_vod__c, 
                                 toLabel(State_vod__c), 
                                 City_vod__c, 
                                 Country_vod__c, 
                                 Phone_vod__c, 	
                                 Email_AGN__c,
                                 Zip_vod__c 
                                 FROM Address_vod__c WHERE                                  
								 (Account_vod__r.Primary_Parent_vod__c = : con.AccountId
								 OR Account_vod__c = : con.AccountId)
                                 AND Inactive_vod__c= False ]){ //AND Customer_Managed_AGN__c = True                                   
                                      
                                     system.debug('@@@Add>>>>'+a);                                    
                                   
                                         if(a.Account_vod__r.SAP_Sold_To_AGN__c){
                                             addresses.add(new AddressWrapper(a.Account_vod__r.Calling_Name_AGN__c, a, 'SoldTo'));  // fetching soldTo data 
                                          }     
                                          if(a.Account_vod__r.SAP_Ship_To_AGN__c){
                                             addresses.add(new AddressWrapper(a.Account_vod__r.Calling_Name_AGN__c, a, 'ShipTo'));
                                          }
                                          if(a.Account_vod__r.SAP_Bill_To_AGN__c){
                                             addresses.add(new AddressWrapper(a.Account_vod__r.Calling_Name_AGN__c, a, 'BillTo'));
                                          }
                                  
                                     /*       if (parentIdMap.containsKey('SoldTo') && parentIdMap.get('SoldTo').contains(a.Account_vod__c)){
                                                addresses.add(new AddressWrapper(a.Account_vod__r.Calling_Name_AGN__c, a, 'SoldTo'));
                                                } 
                                             
                                             if (parentIdMap.containsKey('ShipTo') && parentIdMap.get('ShipTo').contains(a.Account_vod__c)){
                                                 addresses.add(new AddressWrapper(a.Account_vod__r.Calling_Name_AGN__c, a, 'ShipTo'));
                                             }
                                             if (parentIdMap.containsKey('BillTo') && parentIdMap.get('BillTo').contains(a.Account_vod__c)){
                                                 addresses.add(new AddressWrapper(a.Account_vod__r.Calling_Name_AGN__c, a, 'BillTo'));
                                             }
                                         
                                     */
                                     
                                 }
        
        return addresses;
        
    }
    
    @AuraEnabled
    public static Country_vod__c getCountry() {
        User uInfo = [SELECT Id, Country_Code__c,ContactId from User where Id =: UserInfo.getUserId() limit 1];
        string countryCode = '';
        if(uInfo.Country_Code__c == 'AU'){
            countryCode = 'AN';
        }else{
            countryCode = uInfo.Country_Code__c;
        }
        Country_vod__c country = [SELECT ID,Name,AGN_Country_Name__c,Alpha_2_Code_vod__c FROM Country_vod__c WHERE Alpha_2_Code_vod__c =: countryCode limit 1]; 
        system.debug('country-->'+country.AGN_Country_Name__c);
        return country;
    }
    
    @AuraEnabled
    public static Customer_Type_Configuration_AGN__c getCustomertypeConfigDetails(String countryCode, string customerGroup, string custCategory, string subCategory){
        return [SELECT 
                Account_Record_Type_AGN__c,
                Category_AGN__c,
                Country_Code_AGN__c,
                Customer_Country_AGN__c,
                Customer_Country_AGN__r.Alpha_2_Code_vod__c,
                Customer_Group_AGN__c,
                Sub_Category__c,
                Specialty_Allergan_AGN__c,
                Sub_Specialty_Allergan_AGN__c,
                Category_Label_AGN__c,
                Sub_Category_Label_AGN__c                       
                FROM Customer_Type_Configuration_AGN__c
                WHERE Customer_Country_AGN__r.Alpha_2_Code_vod__c =:countryCode
                AND Applicable_For_Online_Registration_AGN__c = true 
                AND Customer_Group_AGN__c =: customerGroup
                AND (Category_AGN__c =:custCategory OR Category_Label_AGN__c =:custCategory)
                AND (Sub_Category__c =:subCategory OR Sub_Category_Label_AGN__c =:subCategory) 
                LIMIT 1
               ];
        
    }
    
    //wrapper class for address
    public class AddressWrapper{
        @AuraEnabled
        public string accountName {get;set;}
        @AuraEnabled
        public Address_vod__c accountAddress {get;set;}
        @AuraEnabled
        public string accountType {get;set;}
        @AuraEnabled
        public string houseNumber{get;set;}
        @AuraEnabled
        public string streetName {get;set;}
        
        public AddressWrapper(string name, Address_vod__c add){
            this.accountName = name;
            this.accountAddress = add;
            houseNumber= '';
            streetName= '';
            
        }
        
        public AddressWrapper(string name, Address_vod__c add, string type){
            this.accountName = name;
            this.accountAddress = add;
            this.accountType = type;
            houseNumber = !String.isBlank(add.Name)&& add.Name.Contains(',') ?add.Name.split(',')[1].Trim():'';
            streetName = !String.isBlank(add.Name)&& add.Name.Contains(',') ?add.Name.split(',')[0].Trim():add.Name.Trim();
            
        }
    }
    
    @AuraEnabled
    public static String getAD_OktaSSOUrl()
    {
        if(AGN_OAMConstant.USERCOUNTRYCODE.equalsIgnoreCase('CA')){
            if(AGN_OAMConstant.USERLANGUAGE.containsIgnoreCase('en')){
                return AGN_OAMConstant.ALLERGAN_DIRECT_OKTA_SSO_URL;
            }else{
                return (String)AGN_GCSP_Settings__c.getValues(AGN_OAMConstant.USERCOUNTRYCODE).get('E_Commerce_Okta_SSO_URL_1_AGN__c'); 
            }
        }else{
            return AGN_OAMConstant.ALLERGAN_DIRECT_OKTA_SSO_URL;
        }
        
    }
}