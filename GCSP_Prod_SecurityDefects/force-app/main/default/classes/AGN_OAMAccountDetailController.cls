/*
Type Name: AGN_OAMAccountDetailController
Reason: Controller class for Cusomer home page lightning components
20-03-2017 - SG - Initial Version
*/
public without sharing class AGN_OAMAccountDetailController {  
    
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
            [SELECT Id,Name,Profile.Name,SmallPhotoUrl,Contact.Customer_Registration_AGN__c, Account.Customer_Registration_AGN__c  
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
    public static Account getAccountDetails() {
        User uInfo = [SELECT Id, ContactId from User where Id =: UserInfo.getUserId() limit 1];
        Account acc = [SELECT Id, 
                       Additional_Specialties_AGN__c,
                       Consent_to_Contact_AGN__c,
                       Consent_to_Email_AGN__c,
                       Consent_to_Mail_AGN__c,
                       Consent_to_Phone_AGN__c,
                       Country_vod__c, 
                       Country_vod__r.AGN_Country_Name__c, 
                       Country_vod__r.Alpha_2_Code_vod__c,
                       Country_Code__c,
                       SAP_Contact_Person_Type_AGN__c,
                       SAP_Country_Code_AGN__c,
                       Customer_Managed_AGN__c,
                       Distribution_ID_AGN__c,
                       Email_Internal_AGN__c,
                       External_ID4_AGN__c,
                       Fax_Internal_AGN__c,
                       FirstName,
                       Graduation_Year_AGN__c,
                       Gender_vod__c,
                       Language_vod__c,
                       LastName,
                       Middle_vod__c,
                       PersonBirthdate,
                       PersonEmail,
                       PersonMobilePhone,
                       Phone,
                       Physician_Registration_Reference_AGN__c,
                       Salutation,
                       SAP_Customer_Group_AGN__c,
                       Specialty_Allergan_1_AGN__c,
                       Specialty_Allergan_1_AGN__r.Name,
                       Status_AGN__c,
                       Sub_Specialty_Allergan_AGN__c,
                       Sub_Specialty_Allergan_AGN__r.Name,
                       Type_AGN__c,
                       Overseeing_account_ID_AGN__c,
                       
                       OwnerID, 
                       PersonContactId, 
                       Customer_Registration_AGN__c,
                       
                       Primary_Parent_vod__c, 
                       Primary_Parent_vod__r.RecordType.DeveloperName, 
                       
                       Primary_Parent_vod__r.Account_Type__c,
                       Primary_Parent_vod__r.Country_vod__c ,
                       Primary_Parent_vod__r.Distribution_ID_AGN__c,   
                       Primary_Parent_vod__r.Email_Internal_AGN__c,
                       Primary_Parent_vod__r.External_ID2_AGN__c ,
                       Primary_Parent_vod__r.External_ID4_AGN__c,  
                       Primary_Parent_vod__r.Name,
                       Primary_Parent_vod__r.Organization_Registration_Reference_AGN__c ,
                       Primary_Parent_vod__r.Status_AGN__c,                        
                       Primary_Parent_vod__r.Sub_Type_AGN__c, 
                       Primary_Parent_vod__r.Type_AGN__c,  
                       
                       Primary_Parent_vod__r.Customer_Category_AGN__c,
                       Primary_Parent_vod__r.Customer_Sub_Category_AGN__c,
                       
                       Primary_Parent_vod__r.Calling_Name_AGN__c,
                       Primary_Parent_vod__r.Country_Code__c,
                       Primary_Parent_vod__r.Fax,
                       
                       Primary_Parent_vod__r.SAP_Additional_Shipping_Instructions_AGN__c,
                       Primary_Parent_vod__r.SAP_Customer_group_1_AGN__c,
                       Primary_Parent_vod__r.SAP_Customer_Group_AGN__c,
                       Primary_Parent_vod__r.SAP_Default_Address_AGN__c,
                       Primary_Parent_vod__r.SAP_Name_2_AGN__c,
                       Primary_Parent_vod__r.SAP_Name_3_AGN__c,
                       Primary_Parent_vod__r.SAP_Name_4_AGN__c,
                       Primary_Parent_vod__r.SAP_SalesText_AGN__c,
                       Primary_Parent_vod__r.SAP_Search_Term_1_AGN__c,
                       Primary_Parent_vod__r.SAP_Search_Term_2_AGN__c,
                       Primary_Parent_vod__r.SAP_Shipping_Instructions_AGN__c,
                       Primary_Parent_vod__r.SAP_Sold_To_AGN__c,
                       Primary_Parent_vod__r.SAP_Tax_Classification_AGN__c,
                       Primary_Parent_vod__r.SAP_VAT_Number_AGN__c,
                       Primary_Parent_vod__r.SAP_NIF_CIF_number_AGN__c,
                       Primary_Parent_vod__r.SAP_Tax_Number_AGN__c //important for updating the cif_nif number
                       
                       FROM Account WHERE PersonContactId  =: uInfo.ContactId limit 1];
        
        return acc;
    }  
    
    
    //get all 3 types of addresses based on affiliation
    @AuraEnabled
    public static list<AddressWrapper> getAddressDetails(){
        Account acc = getAccountDetails();
        list<AddressWrapper> addresses = new list<AddressWrapper>();        
        map<string, set<Id>> parentIdMap = new map<string, set<Id>>();
        set<Id> parentIds = new set<Id>();
        
        for (Child_Account_vod__c ch : [SELECT Parent_Account_vod__c, 
                                        Sold_To_AGN__c, Ship_To_AGN__c, 
                                        Bill_To_AGN__c 
                                        FROM Child_Account_vod__c WHERE Child_Account_vod__c = : acc.Id AND Customer_Managed_AGN__c = True]){
                                            if (ch.Sold_To_AGN__c){
                                                if (!parentIdMap.containsKey('SoldTo'))
                                                    parentIdMap.put('SoldTo', new set<Id>{ch.Parent_Account_vod__c});
                                                else
                                                    parentIdMap.get('SoldTo').add(ch.Parent_Account_vod__c);
                                                
                                                parentIds.add(ch.Parent_Account_vod__c);
                                            }
                                            else if (ch.Ship_To_AGN__c){
                                                if (!parentIdMap.containsKey('ShipTo'))
                                                    parentIdMap.put('ShipTo', new set<Id>{ch.Parent_Account_vod__c});
                                                else
                                                    parentIdMap.get('ShipTo').add(ch.Parent_Account_vod__c);
                                                
                                                parentIds.add(ch.Parent_Account_vod__c);
                                            }
                                            else if (ch.Bill_To_AGN__c){
                                                if (!parentIdMap.containsKey('BillTo'))
                                                    parentIdMap.put('BillTo', new set<Id>{ch.Parent_Account_vod__c});
                                                else
                                                    parentIdMap.get('BillTo').add(ch.Parent_Account_vod__c);
                                                
                                                parentIds.add(ch.Parent_Account_vod__c);
                                            }
                                        }
        
        for (Address_vod__c a : [SELECT Id, 
                                 Account_vod__c, 
                                 Account_vod__r.External_ID2_AGN__c, 
                                 Account_vod__r.Name, 
                                 Account_vod__r.Calling_Name_AGN__c, 
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
                                 Account_vod__c IN : parentIds AND Inactive_vod__c= False AND Customer_Managed_AGN__c = True]){            
                                     if (parentIdMap.containsKey('SoldTo') && parentIdMap.get('SoldTo').contains(a.Account_vod__c)){
                                         addresses.add(new AddressWrapper(a.Account_vod__r.Calling_Name_AGN__c, a, 'SoldTo'));
                                     }
                                     else if (parentIdMap.containsKey('ShipTo') && parentIdMap.get('ShipTo').contains(a.Account_vod__c)){
                                         addresses.add(new AddressWrapper(a.Account_vod__r.Calling_Name_AGN__c, a, 'ShipTo'));
                                     }
                                     else if (parentIdMap.containsKey('BillTo') && parentIdMap.get('BillTo').contains(a.Account_vod__c)){
                                         addresses.add(new AddressWrapper(a.Account_vod__r.Calling_Name_AGN__c, a, 'BillTo'));
                                     }
                                     
                                 }
        
        return addresses;
        
    }
    
    @AuraEnabled
    public static Customer_Type_Configuration_AGN__c getCustomertypeConfigDetails(){
        
        
        Account acc = getAccountDetails();
        //String custCategory=acc.Primary_Parent_vod__r.Customer_Category_AGN__c;
        //String subCategory=acc.Primary_Parent_vod__r.Customer_Sub_Category_AGN__c;
        //System.debug('acc.Country_Code__c -->' + acc.Country_Code__c);
        return [SELECT 
                Account_Record_Type_AGN__c,
                Category_AGN__c,
                Country_Code_AGN__c,
                Customer_Group_AGN__c,
                Sub_Category__c,
                Specialty_Allergan_AGN__c,
                Sub_Specialty_Allergan_AGN__c,
                Category_Label_AGN__c,
                Sub_Category_Label_AGN__c                       
                FROM Customer_Type_Configuration_AGN__c
                WHERE Country_Code_AGN__c =:acc.Country_Code__c
                AND Applicable_For_Online_Registration_AGN__c = true 
                AND Customer_Group_AGN__c =:acc.SAP_Customer_Group_AGN__c
                //AND Category_AGN__c =:custCategory
                //AND Sub_Category__c =:subCategory 
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