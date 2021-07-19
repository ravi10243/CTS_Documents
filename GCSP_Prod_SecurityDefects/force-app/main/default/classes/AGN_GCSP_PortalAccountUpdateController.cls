/**
 * @description       : Update/create the GCSP customer Address information.
 * @author            : GCSP Core Plus Dev Team
 * @group             : 
 * @last modified on  : 15-04-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   05-02-2021   GCSP Core Plus Dev Team   Initial Version
**/
public without sharing class AGN_GCSP_PortalAccountUpdateController {
    
    
    public static Set<string> CroFieldsToBooleanify = new Set<string>();
    public static Set<string> CraFieldsToBooleanify = new Set<string>(); 
    public static Map<string, string> CroToAccountFieldMap = new Map<string, string>();//if Person Account exist
    public static Map<string, string> ContactToCroFieldMap = new Map<string, string>();
    public static Map<string, string> AddressToCraFieldMap = new Map<string, string>();
    public static Map<string, string> BizAccountToCraFieldMap = new Map<string, string>();  
    public static Map<string, string> SAPCustomerToCraFieldMap = new Map<string, string>(); 
    
    
    @AuraEnabled
    public Allergan_Customer_Registration_AGN__c newRegistration {get;set;}
    
    @AuraEnabled
    public list<Allergan_Customer_Address_AGN__c> existingSoldToAddress {get;set;}
    
    @AuraEnabled
    public list<Allergan_Customer_Address_AGN__c> existingShipToAddress {get;set;}
    
    @AuraEnabled
    public list<Allergan_Customer_Address_AGN__c> existingBillToAddress {get;set;}
    
    @AuraEnabled
    public list<Allergan_Customer_Address_AGN__c> addressList {get;set;}
    
    @AuraEnabled
    public Customer_Type_Configuration_AGN__c config {get;set;}
    
    @AuraEnabled
    public Contact primaryContact {get;set;}
    
    @AuraEnabled
    public list<Allergan_Customer_Payment_AGN__c> custPayment {get;set;}
    
     @AuraEnabled
    public String province {get;set;}
    
    //record types
    private static map<string, RecordType> CroRecordTypes;
    private static map<string, RecordType> CraRecordTypes;
    private static map<string, RecordType> CaseRecordTypes;
    
    public static list<AGN_GCSP_PortalAccountDetailController.SAPdataWrapper> sapwrapList;
    public static AGN_GCSP_PortalAccountDetailController.PrymaryContactWrapData primaryConWrapRec;
    
    @AuraEnabled
    public static AGN_GCSP_PortalAccountUpdateController doInit(string sapId, string source){
        
        AGN_GCSP_PortalAccountUpdateController obj = new AGN_GCSP_PortalAccountUpdateController();
        
        obj.existingSoldToAddress = new list<Allergan_Customer_Address_AGN__c>();
        obj.existingShipToAddress = new list<Allergan_Customer_Address_AGN__c>();
        obj.existingBillToAddress = new list<Allergan_Customer_Address_AGN__c>();
        obj.addressList = new list<Allergan_Customer_Address_AGN__c>();
        obj.newRegistration = new Allergan_Customer_Registration_AGN__c();
        obj.config = new Customer_Type_Configuration_AGN__c();
        
        sapwrapList = new list<AGN_GCSP_PortalAccountDetailController.SAPdataWrapper>();
        primaryConWrapRec = new AGN_GCSP_PortalAccountDetailController.PrymaryContactWrapData();
        
        fetchFieldMappings();
        
        CroRecordTypes = fetchRecordTypes('Allergan_Customer_Registration_AGN__c');
        CraRecordTypes = fetchRecordTypes('Allergan_Customer_Address_AGN__c');
        
        Customer_Detail_AGN__c soldToSapData = new Customer_Detail_AGN__c();        
        
        if(source.equalsIgnoreCase('cs')){
            sapwrapList = AGN_GCSP_PortalAccountDetailController.getSAPDetailsSoldTo(sapId);
        }
        if(source.equalsIgnoreCase('oam')){
            sapwrapList = AGN_GCSP_PortalAccountDetailController.getSAPDetailsByContact();
        }
        
        //Stores the bzzAccId with SapCustomer data
        Map<Id, Customer_Detail_AGN__c> accIdCustomerDatamap = new Map<Id, Customer_Detail_AGN__c>();
        //Stores the bzzAccId with AddressVodId
        Map<Id, Id> addressAccMap = new Map<Id, Id>();
        
        Map<Id, Allergan_Customer_Address_AGN__c> addressSapDetailsMap = new Map<Id, Allergan_Customer_Address_AGN__c>();
        
        //Contact.Is_Primary_Contact_AGN__c
        for(AGN_GCSP_PortalAccountDetailController.SAPdataWrapper sapData : sapwrapList){
            
            String type = sapData.accountType;
            accIdCustomerDatamap.put(sapData.sapDetails.Parent_Account_AGN__c, sapData.sapDetails);         
            //accSAPCustomerDataMap.put(type, accIdCustomerDatamap);
            
        }       
        
        for(Address_vod__c add : [SELECT Id, Account_vod__c FROM Address_vod__c WHERE Account_vod__c =:accIdCustomerDatamap.keySet()]){
            
            addressAccMap.put(add.Account_vod__c, add.Id);
            
        }
        for(AGN_GCSP_PortalAccountDetailController.SAPdataWrapper sapData : sapwrapList){
           Allergan_Customer_Address_AGN__c crAddress = new Allergan_Customer_Address_AGN__c(); 
            String type = sapData.accountType;
            //crAddress = getNewAddress(sapData.sapDetails, type);
           // crAddress.Parent_Address_AGN__c = addressAccMap.get(sapData.sapDetails.Parent_Account_AGN__c);
            //obj.addressList.add(crAddress);
            
            if(type.equalsIgnoreCase('SoldTo')){
                crAddress = getNewAddress(sapData.sapDetails, type);
                crAddress.Parent_Address_AGN__c = addressAccMap.get(sapData.sapDetails.Parent_Account_AGN__c);
                crAddress.RecordTypeId = CraRecordTypes.get('Amend').Id;
                obj.existingSoldToAddress.add(crAddress);                
                soldToSapData = sapData.sapDetails;
                addressSapDetailsMap.put(sapData.sapDetails.Id, crAddress);
            }
            if(type.equalsIgnoreCase('ShipTo')){
                crAddress = getNewAddress(sapData.sapDetails, type);
                crAddress.RecordTypeId = CraRecordTypes.get('Amend').Id;
                crAddress.Parent_Address_AGN__c = addressAccMap.get(sapData.sapDetails.Parent_Account_AGN__c);
                obj.existingShipToAddress.add(crAddress);
            }
            if(type.equalsIgnoreCase('BillTo')){
                crAddress = getNewAddress(sapData.sapDetails, type);
                crAddress.Parent_Address_AGN__c = addressAccMap.get(sapData.sapDetails.Parent_Account_AGN__c);
                crAddress.RecordTypeId = CraRecordTypes.get('Amend').Id;
                obj.existingBillToAddress.add(crAddress);
                addressSapDetailsMap.put(sapData.sapDetails.Id, crAddress);
            }
            
            
            
        }
        
        if(!addressSapDetailsMap.isEmpty()){
            addressSapDetailsMap = getPaymentDetails(addressSapDetailsMap);
        }
        
        if(String.isNotEmpty(soldToSapData.Id)){
            system.debug('getHeaderWrapDetailsBySAPId:::: '+soldToSapData);
            primaryConWrapRec = source.equalsIgnoreCase('cs') ? AGN_GCSP_PortalAccountDetailController.getHeaderWrapDetailsBySAPId(soldToSapData) : AGN_GCSP_PortalAccountDetailController.getHeaderWrapDetailsByContact(soldToSapData);            
            
            obj.config = primaryConWrapRec.customerTypeConfig;
            obj.primaryContact = primaryConWrapRec.con; 
            Contact customerContact = primaryConWrapRec.con;  
            
            String personAccountId = ''; 
            list<AccountContactRelation> acrList= [SELECT Id,ContactId,AccountID FROM AccountContactRelation WHERE ContactId =:customerContact.Id AND Account.Primary_Parent_vod__c =:customerContact.AccountId LIMIT 1];
            if(!acrList.isEmpty()) personAccountId = acrList[0].AccountID;  
            
            if(!string.isEmpty(personAccountId)){      // If PA exist
                Account PersonAccount = getAccountDetails(personAccountId);
                for(string conField : CroToAccountFieldMap.keySet()){ 
                    string crField = CroToAccountFieldMap.get(conField);
                    if (CroFieldsToBooleanify.contains(crField)){
                        object val = PersonAccount.get(crField);                    
                        if (val != null){
                            Boolean theBool = Boolean.valueOf(val);
                            String boolVal = (theBool) ? 'Yes' : '';
                            obj.newRegistration.put(crField, boolVal);  //                     
                        }
                    }else{
                        obj.newRegistration.put(crField, PersonAccount.get(conField));
                    }
                    
                }
                
            }else{        
                for(string conField : ContactToCroFieldMap.keySet()){           
                    string crField = ContactToCroFieldMap.get(conField);
                    if (CroFieldsToBooleanify.contains(crField)){
                        object val = customerContact.get(crField);                    
                        if (val != null){
                            Boolean theBool = Boolean.valueOf(val);
                            String boolVal = (theBool) ? 'Yes' : '';
                            obj.newRegistration.put(crField, boolVal);  //                     
                        }
                    }else{
                        obj.newRegistration.put(crField, customerContact.get(conField));
                    } 
                    
                }
            }
            system.debug('CRdata>>>>>>>>>>>>>>'+obj.newRegistration);
            
            obj.newRegistration.Customer_Category_AGN__c = soldToSapData.Customer_Category_AGN__c;
            obj.newRegistration.Customer_Sub_Category_AGN__c = soldToSapData.Customer_Sub_Category_AGN__c;
            obj.newRegistration.Customer_Group_AGN__c = soldToSapData.SAP_Customer_Group_AGN__c;
            obj.newRegistration.Country_Code_AGN__c = soldToSapData.Country_Code_AGN__c;
            obj.newRegistration.SAP_Country_Code_AGN__c = soldToSapData.SAP_Country_Code_AGN__c;
            obj.newRegistration.Country_AGN__c = soldToSapData.Country_AGN__c;
            obj.newRegistration.OwnerId= customerContact.OwnerID; 
            obj.newRegistration.Province_AGN__c = soldToSapData.State_AGN__c;
             
            string countryCode = soldToSapData.SAP_Country_Code_AGN__c;
            countryCode = String.isEmpty(countryCode) ? countryCode : soldToSapData.SAP_Country_Code_AGN__c;
            string lang = userinfo.getLanguage();
            if(lang.equalsIgnoreCase('en')){
              obj.province = [SELECT MasterLabel, Region_Label_AGN__c FROM AGN_CR_CountryRegionMapping__mdt WHERE Country_Code__c =:countryCode AND RegionCode__c =:soldToSapData.State_AGN__c ]?.MasterLabel;
            }else{
              obj.province = [SELECT MasterLabel, Region_Label_AGN__c FROM AGN_CR_CountryRegionMapping__mdt WHERE Country_Code__c =:countryCode AND RegionCode__c =:soldToSapData.State_AGN__c ]?.Region_Label_AGN__c;  
            }
            
            obj.newRegistration.Online_Registration_AGN__c = customerContact.Has_Allergan_Direct_Access_AGN__c;
            obj.newRegistration.Allergan_Direct_Access_Requested_AGN__c = customerContact.Has_Allergan_Direct_Access_AGN__c;   
            obj.newRegistration.RecordTypeId= CroRecordTypes.get('Update').Id;
            
            
        }
        
        return obj;
        
    }
    
    public static Map<Id, Allergan_Customer_Address_AGN__c> getPaymentDetails(Map<Id, Allergan_Customer_Address_AGN__c> custPaymentMap){
        
        Map<Id, Allergan_Customer_Address_AGN__c> crAddressMap = new Map<Id, Allergan_Customer_Address_AGN__c>();
        for (Allergan_Customer_Payment_AGN__c payment : [SELECT Id, Account_AGN__c, Bank_Name_AGN__c, Bank_Account_Number_AGN__c, IBAN_AGN__c,IBAN_Text_AGN__c, 
                                                                 Sort_Code_AGN__c, SWIFT_BIC_AGN__c,Form_Of_Payment_AGN__c,Payment_Term_AGN__c,Parent_SAP_Customer_AGN__c,
                                                                 Business_Name_Reference1_AGN__c,Business_Name_Reference2_AGN__c,Business_Name_Reference3_AGN__c,
                                                                 Contact_Name_Reference1_AGN__c,Contact_Name_Reference2_AGN__c,Contact_Name_Reference3_AGN__c,
                                                                 Fax_Reference1_AGN__c,Fax_Reference2_AGN__c,
                                                                 Phone_Reference1_AGN__c,Phone_Reference2_AGN__c,Phone_Reference3_AGN__c,
                                                                 Email_Reference1_AGN__c,Email_Reference2_AGN__c,Email_Reference3_AGN__c
                                                                 FROM Allergan_Customer_Payment_AGN__c 
                                                                 WHERE Parent_SAP_Customer_AGN__c =: custPaymentMap.keyset() 
                                                        ]){
                                                            Allergan_Customer_Address_AGN__c crAddress = custPaymentMap.get(payment.Parent_SAP_Customer_AGN__c);
                                                            crAddress.Form_Of_Payment_AGN__c = payment.Form_Of_Payment_AGN__c;
                                                            crAddress.Payment_Term_AGN__c = payment.Payment_Term_AGN__c;
                                                            crAddress.Customer_Payment__c = payment.Id;
                                                            crAddress.IBAN_AGN__c = payment.IBAN_Text_AGN__c;
                                                            crAddress.IBAN_Text_AGN__c = payment.IBAN_Text_AGN__c;
                                                            crAddress.SWIFT_BIC_AGN__c = payment.SWIFT_BIC_AGN__c;
                                                            crAddress.Bank_Name_AGN__c = payment.Bank_Name_AGN__c;
                                                            crAddress.Bank_Account_Number_AGN__c = payment.Bank_Account_Number_AGN__c;
                                                            crAddress.Sort_Code_AGN__c = payment.Sort_Code_AGN__c;
                                                            crAddress.Customer_Payment__c = payment.Id;
                                                            crAddress.Business_Name_Reference1_AGN__c = payment.Business_Name_Reference1_AGN__c;
                                                            crAddress.Business_Name_Reference2_AGN__c = payment.Business_Name_Reference2_AGN__c;
                                                            crAddress.Business_Name_Reference3_AGN__c = payment.Business_Name_Reference3_AGN__c;
                                                            crAddress.Contact_Name_Reference1_AGN__c = payment.Contact_Name_Reference1_AGN__c;
                                                            crAddress.Contact_Name_Reference2_AGN__c = payment.Contact_Name_Reference2_AGN__c;
                                                            crAddress.Contact_Name_Reference3_AGN__c = payment.Contact_Name_Reference3_AGN__c;
                                                            crAddress.Fax_Reference1_AGN__c = payment.Fax_Reference1_AGN__c;
                                                            crAddress.Fax_Reference2_AGN__c = payment.Fax_Reference2_AGN__c;
                                                            crAddress.Phone_Reference1_AGN__c = payment.Phone_Reference1_AGN__c;
                                                            crAddress.Phone_Reference2_AGN__c = payment.Phone_Reference2_AGN__c;
                                                            crAddress.Phone_Reference3_AGN__c = payment.Phone_Reference3_AGN__c;
                                                            crAddress.Email_Reference1_AGN__c = payment.Email_Reference1_AGN__c;
                                                            crAddress.Email_Reference2_AGN__c = payment.Email_Reference2_AGN__c;
                                                            crAddress.Email_Reference3_AGN__c = payment.Email_Reference3_AGN__c;
                                                            
                                                            crAddressMap.put(payment.Parent_SAP_Customer_AGN__c, crAddress);
                                                        }
        for(String sapid : custPaymentMap.keyset()){
            if(!crAddressMap.containsKey(sapid)){
                crAddressMap.put(sapid, custPaymentMap.get(sapid));
            }
        }
        return crAddressMap;
    }
    
    @AuraEnabled
    public static Allergan_Customer_Address_AGN__c getNewAddress(Customer_Detail_AGN__c sapCustomerDataRec, string type){
        
        Allergan_Customer_Address_AGN__c newAddress = new Allergan_Customer_Address_AGN__c();
        Address_vod__c oldAddress;        
        // newAddress.Country_AGN__c = country.AGN_Country_Name__c;
        
        if (type == 'SoldTo'){
            newAddress.Sold_To_AGN__c = true;
        }else if (type == 'ShipTo'){
            newAddress.Ship_To_AGN__c = true;
        }else if (type == 'BillTo'){
            newAddress.Bill_To_AGN__c = true;
        }
        
        
        newAddress.Parent_SAP_Customer_AGN__c = sapCustomerDataRec.Id;
        newAddress.Account_AGN__c = sapCustomerDataRec.Parent_Account_AGN__c;
        newAddress.Sold_To_AGN__c = sapCustomerDataRec.SAP_Sold_To_AGN__c;
        newAddress.Ship_To_AGN__c = sapCustomerDataRec.SAP_Ship_To_AGN__c;
        newAddress.Bill_To_AGN__c = sapCustomerDataRec.SAP_Bill_To_AGN__c;
        // newAddress.Parent_Address_AGN__c = [SELECT Id FROM Address_vod__c WHERE Account_vod__c =: sapCustomerDataRec.Parent_Account_AGN__c LIMIT 1]?.Id;
        
        if(!string.isEmpty(sapCustomerDataRec.SAP_Country_Code_AGN__c) && sapCustomerDataRec.Country_Code_AGN__c !='IT'){                
            newAddress.State_AGN__c = string.isBlank(sapCustomerDataRec.State_AGN__c)? '':(sapCustomerDataRec.SAP_Country_Code_AGN__c+ '-' +sapCustomerDataRec.State_AGN__c) ;
                }else{
                    newAddress.State_AGN__c = string.isBlank(sapCustomerDataRec.State_AGN__c)? '':(sapCustomerDataRec.Country_Code_AGN__c+'-'+sapCustomerDataRec.State_AGN__c) ;
                        }  
        
        newAddress.RecordTypeId = CraRecordTypes.get('Amend').Id;
        
        for (string sapCustomerField : SAPCustomerToCraFieldMap.keySet()){                     
            string craField1 = SAPCustomerToCraFieldMap.get(sapCustomerField);
            if (CraFieldsToBooleanify.contains(craField1)){
                object val = sapCustomerDataRec.get(craField1);                    
                if (val != null){
                    Boolean theBool = Boolean.valueOf(val);
                    String boolVal = (theBool) ? 'Yes' : '';
                    newAddress.put(craField1, boolVal);
                }
            }else{
                newAddress.put(craField1, sapCustomerDataRec.get(sapCustomerField));
            }
        }
        
        newAddress.House_Number_AGN__c= String.isNotBlank(sapCustomerDataRec.Address_line_1_AGN__c)&& sapCustomerDataRec.Address_line_1_AGN__c.Contains(',') ?sapCustomerDataRec.Address_line_1_AGN__c.split(',')[1].Trim():'';
        newAddress.Street_Name_AGN__c = String.isNotBlank(sapCustomerDataRec.Address_line_1_AGN__c)&& sapCustomerDataRec.Address_line_1_AGN__c.Contains(',') ?sapCustomerDataRec.Address_line_1_AGN__c.split(',')[0].Trim():String.isEmpty(sapCustomerDataRec.Address_line_1_AGN__c)? '':sapCustomerDataRec.Address_line_1_AGN__c.Trim();
        
        
        
        
        system.debug('newAddress>>>>>>>>>>'+newAddress);
        return newAddress;
    }   
    
    
    @AuraEnabled
    public static Allergan_Customer_Registration_AGN__c getNewRegistration(Contact customerContact, Customer_Type_Configuration_AGN__c config){
        Allergan_Customer_Registration_AGN__c custReg = new Allergan_Customer_Registration_AGN__c();
        
        return custReg;
    }
    
    @AuraEnabled
    public static Account getAccountDetails(String accId) {      
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
        
        Account acc = Database.query(query);  
        
        return acc;
    }     
    
    public static Map<string, RecordType> fetchRecordTypes(string sobjecttype)    {
        Map<string, RecordType> output = new Map<string, RecordType>();
        for (RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType = :sobjecttype])
        {
            output.put(rt.DeveloperName, rt);
        }
        
        return output;
    }
    
    public static void fetchFieldMappings()
    {        
        // Pull out the CRO->Account mappings...
        List<CR_To_Account_Mapping_AGN__mdt> crmapping = [SELECT Customer_Registration_Field_AGN__c, Account_Field_Name_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CR_To_Account_Mapping_AGN__mdt];
        
        for (CR_To_Account_Mapping_AGN__mdt mapping : crmapping)
        {
            system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+mapping);
            
            CroToAccountFieldMap.put(mapping.Account_Field_Name_AGN__c, mapping.Customer_Registration_Field_AGN__c );
            system.debug('mapping'+CroToAccountFieldMap);
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CroFieldsToBooleanify.add(mapping.Account_Field_Name_AGN__c);
            }
        }
        
        // Pull out the CRO->Contact mappings...
        List<CR_to_Contact_Mapping_AGN__mdt> crmapping1 = [SELECT Customer_Registration_Field_AGN__c, Contact_Field_Name_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CR_to_Contact_Mapping_AGN__mdt];
        
        for (CR_to_Contact_Mapping_AGN__mdt mapping : crmapping1)
        {
            //system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+mapping);           
            ContactToCroFieldMap.put(mapping.Contact_Field_Name_AGN__c, mapping.Customer_Registration_Field_AGN__c);
            system.debug('mapping'+ContactToCroFieldMap);
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CroFieldsToBooleanify.add(mapping.Contact_Field_Name_AGN__c);
            }            
        }
        
        // Pull out the CRA->Address mappings...
        List<CRA_To_Address_Mapping_AGN__mdt> cramapping = [SELECT CRA_Field_AGN__c, Address_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CRA_To_Address_Mapping_AGN__mdt];
        
        for (CRA_To_Address_Mapping_AGN__mdt mapping : cramapping)
        {
            AddressToCraFieldMap.put(mapping.Address_Field_AGN__c, mapping.CRA_Field_AGN__c);
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.Address_Field_AGN__c);
            }
        }
        
        // Pull out the CRA->BizAccount mappings...
        List<CRA_to_Business_Account_Mapping_AGN__mdt> crabamapping = [SELECT CRA_Field_AGN__c, Account_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CRA_to_Business_Account_Mapping_AGN__mdt];
        
        for (CRA_to_Business_Account_Mapping_AGN__mdt mapping : crabamapping)
        {
            BizAccountToCraFieldMap.put(mapping.Account_Field_AGN__c, mapping.CRA_Field_AGN__c);
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.Account_Field_AGN__c);
            }
        }
        
        //Pull out the SAP Customer -> Address Mappings
        List<CRA_to_SAP_Customer_Mapping_AGN__mdt> craSapCustomerMapping = [SELECT CRA_Field_AGN__c, SAP_Customer_Field_AGN__c, Is_Address_Fromula_Field_AGN__c, Convert_Yes_No_To_Boolean_AGN__c FROM CRA_to_SAP_Customer_Mapping_AGN__mdt];
        
        for (CRA_to_SAP_Customer_Mapping_AGN__mdt mapping : craSapCustomerMapping)
        {
            if(!mapping.Is_Address_Fromula_Field_AGN__c){
                SAPCustomerToCraFieldMap.put(mapping.SAP_Customer_Field_AGN__c, mapping.CRA_Field_AGN__c);  
            }          
            
            if (mapping.Convert_Yes_No_To_Boolean_AGN__c == true)
            {
                CraFieldsToBooleanify.add(mapping.CRA_Field_AGN__c);
            }
        }
    }
    
    @AuraEnabled
    public static List<sObject> getPickListValues(string objectName,String columnName,String columnId, String whereCondition){
        String wherecond = whereCondition != null ? String.valueOf(whereCondition) : '';
        String query = 'select '+String.escapeSingleQuotes(String.valueOf(columnName))+','+String.escapeSingleQuotes(String.valueOf(columnId))+' From '+String.escapeSingleQuotes(objectName) + wherecond;
        system.debug('@@@@query@@@'+ query);
        List<sObject> PicklistValues = Database.query(query);
        system.debug('@@@@PicklistValues@@@'+ PicklistValues);
        return PicklistValues;         
    }
    
    @AuraEnabled
    public static List<Object> getPaymentDetails(string formofPayment,String paymentTerm, String countryCode){
        system.debug('@@@@getPaymentDetails>>>>'+formofPayment+'>>>>'+paymentTerm+'>>>>'+countryCode);
        List<Object> optionsObject = new List<Object>();
        Form_of_Payment_AGN__c fop;
        if(countryCode == 'CA'){
            if(formofPayment != null){
                fop = [SELECT ID,Name, Form_Of_Payment_Label_AGN__c, Bank_Details_Required_AGN__c FROM Form_of_Payment_AGN__c 
                       WHERE (Form_Of_Payment_Label_AGN__c =: formofPayment OR Name =: formofPayment) 
                       AND Country_code_AGN__c =: countryCode
                       AND Active_AGN__c = true];
                
                optionsObject.add(fop);               
                
            } 
        }       
        if(paymentTerm != null){            
            Payment_Term_AGN__c pt;            
            if(countryCode == 'CA'){                
                pt = [SELECT ID, Name,Payment_Term_Label_AGN__c, Bank_Details_Required_AGN__c FROM Payment_Term_AGN__c 
                      WHERE (Name =: paymentTerm OR Payment_Term_Label_AGN__c =: paymentTerm)
                      AND Form_Of_Payment__c =: fop.Id
                      AND Active_AGN__c = true];
                
            }else{
                
                pt = [SELECT ID, Name,Payment_Term_Label_AGN__c, Bank_Details_Required_AGN__c FROM Payment_Term_AGN__c 
                      WHERE SAP_Payment_Term_Code_AGN__c =: paymentTerm 
                      AND Form_Of_Payment__c =: formofPayment
                      AND Active_AGN__c = true];
                
            }
            
            optionsObject.add(pt);  
        }   
        system.debug('@@@@getPaymentDetails>>>>'+optionsObject);
        return optionsObject;         
    }
    
    @AuraEnabled
    public static Case saveCustomerUpdate(Allergan_Customer_Registration_AGN__c customerReg,
                                          list<Allergan_Customer_Address_AGN__c> newShippingAddress,
                                          list<Allergan_Customer_Address_AGN__c> newBillingAddress,
                                          list<Allergan_Customer_Address_AGN__c> oldShippingAddress,
                                          list<Allergan_Customer_Address_AGN__c> oldBillingAddress,
                                          list<Allergan_Customer_Address_AGN__c> oldSoldAddress,
                                          Contact primaryContact,
                                          string source,
                                          string soldToSAPId,
                                          list<Object> filesUploads){
        CroRecordTypes = fetchRecordTypes('Allergan_Customer_Registration_AGN__c');
        CraRecordTypes = fetchRecordTypes('Allergan_Customer_Address_AGN__c');
        CaseRecordTypes = fetchRecordTypes('Case');
                                              
        fetchFieldMappings(); //for changelist                                  
        String changeList = '';
                                              
        list<Allergan_Customer_Address_AGN__c> crAddressList = new list<Allergan_Customer_Address_AGN__c>();
        //Allergan_Customer_Address_AGN__c customerAddress = new Allergan_Customer_Address_AGN__c();
        Map<Id, Id> accSapDataMap = new Map<Id, Id>();
        Customer_Detail_AGN__c soldToSapData= getSoldToSapDetails(soldToSAPId);
        Map<Id, Customer_Detail_AGN__c> sapDetailsMap = new Map<Id, Customer_Detail_AGN__c>();
        /*if (!String.isBlank(oldaddress.House_Number_AGN__c) && !String.isBlank(oldaddress.Street_Name_AGN__c)){
                oldaddress.Address_Line_1_AGN__c =  oldaddress.Street_Name_AGN__c + ' , ' + oldaddress.House_Number_AGN__c;
            } */
        
                                              
        for(Allergan_Customer_Address_AGN__c oldaddress : oldSoldAddress){
            crAddressList.add(oldaddress);
            accSapDataMap.put(oldaddress.Parent_SAP_Customer_AGN__c, oldaddress.Account_AGN__c);
            
        }
        for(Allergan_Customer_Address_AGN__c oldaddress : oldBillingAddress){
        
            crAddressList.add(oldaddress);
            accSapDataMap.put(oldaddress.Parent_SAP_Customer_AGN__c, oldaddress.Account_AGN__c);
        }
        for(Allergan_Customer_Address_AGN__c oldaddress : oldShippingAddress){                      
            crAddressList.add(oldaddress);
            accSapDataMap.put(oldaddress.Parent_SAP_Customer_AGN__c, oldaddress.Account_AGN__c);
        }
        for(Allergan_Customer_Address_AGN__c newaddress : newBillingAddress){           
            newaddress.Bill_To_AGN__c = true;
            newaddress.RecordTypeId =   CraRecordTypes.get('New').Id;
            crAddressList.add(newaddress);
        }
        for(Allergan_Customer_Address_AGN__c newaddress : newShippingAddress){          
            newaddress.Ship_To_AGN__c = true;
            newaddress.RecordTypeId =   CraRecordTypes.get('New').Id;
            newaddress.KB23_Article_AGN__c =  oldSoldAddress.isEmpty() ? soldToSapData.SAP_KB23_Article_AGN__c : oldSoldAddress[0].KB23_Article_AGN__c ;
            
            crAddressList.add(newaddress);
        }
        
        sapDetailsMap = getSapDetails(accSapDataMap);
        
        System.debug('crAddressList>>>>>>'+crAddressList);
        System.debug('sapDetailsMap>>>>>>'+sapDetailsMap);
        string countrycode;
            if(!string.isEmpty(customerReg.SAP_Country_Code_AGN__c) && customerReg.Country_Code_AGN__c.equalsIgnoreCase('AN')){
                if(customerReg.SAP_Country_Code_AGN__c.equalsIgnoreCase('AU')){
                countrycode = 'AN';
                }else{
                    countrycode = customerReg.SAP_Country_Code_AGN__c;
                }
            }
            if(String.isEmpty(countrycode)){
                 countrycode = customerReg.Country_Code_AGN__c;//soldToSapData.Country_Code_AGN__c;
            } 
              Map<Id, Allergan_Customer_Address_AGN__c> oldAddressMap = new Map<Id, Allergan_Customer_Address_AGN__c>();   
        for(Allergan_Customer_Address_AGN__c address : crAddressList){   
             if(String.isNotEmpty(address.Parent_SAP_Customer_AGN__c)){
                 Customer_Detail_AGN__c oldCustomerAddress = sapDetailsMap.get(address.Parent_SAP_Customer_AGN__c);                  
                 Allergan_Customer_Address_AGN__c oldRegAddress = getNewAddress(oldCustomerAddress, ''); //for changelist
                 oldAddressMap.put(oldRegAddress.Parent_SAP_Customer_AGN__c, oldRegAddress);
            } 
        }
        
        if(!oldAddressMap.isEmpty()){
            oldAddressMap = getPaymentDetails(oldAddressMap);
        } 
        for(Allergan_Customer_Address_AGN__c address : crAddressList){ 
            
                    if(countrycode == 'BR'){
                         address.Company_Name_AGN__c = String.isBlank(address.Company_Name_AGN__c) ? (customerReg.Salutation_AGN__c + ' ' + customerReg.First_Name_AGN__c + ' ' + customerReg.Last_Name_AGN__c) : address.Company_Name_AGN__c; 
                         address.SAP_Name_1_AGN__c = String.isEmpty(address.SAP_Name_1_AGN__c) ? address.Company_Name_AGN__c : address.SAP_Name_1_AGN__c;
                        
                    }
                    else if(countrycode != 'AN'){                    
                       if(source.equalsIgnoreCase('oam')){
                            address.Company_Name_AGN__c = String.isBlank(address.Company_Name_AGN__c) ? (customerReg.Salutation_AGN__c + ' ' + customerReg.First_Name_AGN__c + ' ' + customerReg.Last_Name_AGN__c) : address.Company_Name_AGN__c;
                            address.SAP_Name_1_AGN__c = String.isEmpty(address.SAP_Name_1_AGN__c) ? address.Company_Name_AGN__c : address.SAP_Name_1_AGN__c;
                       		
                    }
                    else{
                            address.SAP_Name_1_AGN__c = String.isBlank(address.SAP_Name_1_AGN__c) ? (customerReg.Salutation_AGN__c + ' ' + customerReg.First_Name_AGN__c + ' ' + customerReg.Last_Name_AGN__c) : address.SAP_Name_1_AGN__c;
                            address.Company_Name_AGN__c = String.isEmpty(address.Company_Name_AGN__c) ? address.SAP_Name_1_AGN__c : address.Company_Name_AGN__c;
                        }
                    }
                   if(String.isNotEmpty(address.Parent_SAP_Customer_AGN__c)){
                		 Customer_Detail_AGN__c oldCustomerAddress = sapDetailsMap.get(address.Parent_SAP_Customer_AGN__c);
	                	 //changeList += AGN_CustomerRegistrationUtils.generateNewChangeList(address, oldCustomerAddress);
               			  Allergan_Customer_Address_AGN__c oldRegAddress = oldAddressMap.get(address.Parent_SAP_Customer_AGN__c); //for changelist
                		 changeList += AGN_CustomerRegistrationUtils.generateAddressChangeList(address, oldRegAddress); //for changelist
               		 }   
            
        }
        
        Case caseNewCr = new Case();
        caseNewCr.Service_AGN__c = 'Customer Registration';     
        caseNewCr.Priority = 'Medium';
        caseNewCr.Origin = source.equalsIgnoreCase('oam')?'Web':'Email';                                
       //caseNewCr.Origin = 'Web';
        caseNewCr.Status = 'New';
        caseNewCr.AccountId = primaryContact.AccountId;
        caseNewCr.ContactId = primaryContact.Id;
        //RecordType caseRecordType = [SELECT Id, Name,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'AGN_Support_Request_Customer_Update' LIMIT 1][0];        
        caseNewCr.RecordTypeId = CaseRecordTypes.get('AGN_Support_Request_Customer_Update').Id;
        string firstName =   string.isEmpty(primaryContact.FirstName) ? '' : primaryContact.FirstName;
        string lastName =   string.isEmpty(primaryContact.LastName) ? '' : primaryContact.LastName;        
        caseNewCr.SuppliedName = String.isNotEmpty(primaryContact.Name) ? primaryContact.Name : String.isNotEmpty(soldToSapData.Name) ? soldToSapData.Name : soldToSapData.SAP_Name_1_AGN__c;
        caseNewCr.SuppliedEmail = primaryContact.Email;
        caseNewCr.SuppliedPhone = primaryContact.Phone;
        caseNewCr.Country_Code_AGN__c = customerReg.Country_Code_AGN__c;
        caseNewCr.Description_Rich_Text__c = changeList;        
        caseNewCr.Type = 'Update';
        caseNewCr.Reason = 'Update Customer Address'; 
        caseNewCr.Business_Unit_AGN__c = customerReg.Business_Unit_AGN__c; 
        system.debug('Reg:::::'+customerReg);
        system.debug('SAp Countrycode:::::'+soldToSapData.SAP_Country_Code_AGN__c);
        system.debug('Countrycode:::::'+soldToSapData.Country_Code_AGN__c);
                                        
        caseNewCr.EntitlementId = AGN_GCSP_PortalCustomerRegUtils.setEntitlement(CaseRecordTypes.get('AGN_Support_Request_Customer_Update').Name, caseNewCr.Type, countrycode);
        
        List<Case> tempCRCaseList = new List<Case>();
	    tempCRCaseList.add(caseNewCr);              
	    String objCRCase = 'Case';
	    SObjectType objCRCaseType = ((SObject)(Type.forName('Schema.'+objCRCase).newInstance())).getSObjectType();
	    AGN_FLSCheck.check(tempCRCaseList,objCRCaseType,'INSERT');
        insert caseNewCr;
        
        customerReg.Case_AGN__c = caseNewCr.Id; 
        customerReg.Processed_By_SAP_AGN__c = 'In Progress';
        customerReg.Change_List_AGN__c = changeList;
        customerReg.Online_Registration_AGN__c= true;
        customerReg.Business_Account_SAP_ID__c = soldToSapData.External_ID_AGN__c;//bzzAcc.External_ID2_AGN__c;        
        customerReg.Language_AGN__c = String.isNotEmpty(customerReg.Language_AGN__c)? customerReg.Language_AGN__c : UserInfo.getLanguage();
        
        List<Allergan_Customer_Registration_AGN__c> tempCRRegList = new List<Allergan_Customer_Registration_AGN__c>();
	    tempCRRegList.add(customerReg);              
	    String objCRReg = 'Allergan_Customer_Registration_AGN__c';
	    SObjectType objCRRegType = ((SObject)(Type.forName('Schema.'+objCRReg).newInstance())).getSObjectType();
	    AGN_FLSCheck.check(tempCRRegList,objCRRegType,'INSERT');  
        insert customerReg;
        if(!filesUploads.isEmpty()){
          saveFiles(filesUploads, customerReg.Id);
        }                                      
                                              
        for(Allergan_Customer_Address_AGN__c address : crAddressList){              
                    
                if(countrycode == 'IT' && String.isEmpty(address.Parent_SAP_Customer_AGN__c)){
                    if(address.Country_AGN__c == 'Italy' ){
                        address.Tax_Classification_AGN__c = '9';
                    }else{
                        address.Tax_Classification_AGN__c = '0';
                    }
                }else{
                    address.Tax_Classification_AGN__c = soldToSapData.SAP_Tax_Classification_AGN__c; 
                } 
              /* if(countrycode != 'AN'){                    
                   if(source.equalsIgnoreCase('oam')){
                   
                        address.Company_Name_AGN__c = String.isBlank(address.Company_Name_AGN__c) ? (customerReg.Salutation_AGN__c + ' ' + customerReg.First_Name_AGN__c + ' ' + customerReg.Last_Name_AGN__c) : address.Company_Name_AGN__c;

                        //address.Company_Name_AGN__c = String.isEmpty(address.Company_Name_AGN__c) ? address.SAP_Name_1_AGN__c : address.Company_Name_AGN__c;
                   		address.SAP_Name_1_AGN__c =  address.Company_Name_AGN__c;
                   }
                    else{
                        address.Company_Name_AGN__c = address.SAP_Name_1_AGN__c;
                    }
                } */
              
                    
                if(countrycode != 'IT'){
                    address.Country_AGN__c =  soldToSapData.Country_AGN__r.AGN_Country_Name__c; 
                }                       
                address.Country_Lookup_AGN__c = soldToSapData.Country_AGN__c;
        
                address.Account_Type_AGN__c = soldToSapData.Parent_Account_AGN__r.RecordType.DeveloperName;
                address.Parent_AGN__c = customerReg.Id;
                // Add account owner information for new account
                address.Are_You_The_Prescribing_Doctor_AGN__c = soldToSapData.Are_you_the_prescribing_doctor_AGN__c;
                address.Doctors_Email_AGN__c = soldToSapData.SAP_Doctors_Email_AGN__c;
                address.Doctors_First_Name_AGN__c = soldToSapData.SAP_Doctors_First_Name_AGN__c;
                address.Doctors_Middle_Name_AGN__c = soldToSapData.SAP_Doctors_Middle_Name_AGN__c;
                address.Doctors_Last_Name_AGN__c = soldToSapData.SAP_Doctors_Last_Name_AGN__c;
                address.Doctors_Phone_AGN__c = soldToSapData.SAP_Doctors_Phone_AGN__c;
                
                if(address.Ship_To_AGN__c && String.isEmpty(address.Parent_SAP_Customer_AGN__c) && address.Are_You_The_Prescribing_Doctor_AGN__c == false ){
                    address.Are_You_The_Prescribing_Doctor_AGN__c = true;
                }
            
             
        }
                                              
        List<Allergan_Customer_Address_AGN__c> updateList =  new List<Allergan_Customer_Address_AGN__c>();
        
        if(!crAddressList.isEmpty()){
            upsert crAddressList;
            list<Allergan_Customer_Address_AGN__c> addList = new list<Allergan_Customer_Address_AGN__c>();
            for(Allergan_Customer_Address_AGN__c address : crAddressList){
                if(address.Ship_To_AGN__c && String.isEmpty(address.Parent_SAP_Customer_AGN__c) && address.Are_You_The_Prescribing_Doctor_AGN__c == true){
                    address.Are_You_The_Prescribing_Doctor_AGN__c = false;
                    addList.add(address);
                }
            }
            
            if(!addList.isEmpty()){                
                  for(Allergan_Customer_Address_AGN__c addObj: addList){ 
                    if(String.isEmpty(addObj.Tax_Classification_AGN__c)){  
                        if(customerReg.Country_Code_AGN__c == 'IT'){
                            if(addObj.Country_AGN__c == 'Italy' ){
                                addObj.Tax_Classification_AGN__c = '9';
                            }else{
                                addObj.Tax_Classification_AGN__c = '0';
                            }
                        }else if(!String.isEmpty(customerReg.Tax_Exempted_AGN__c)){
                            addObj.Tax_Classification_AGN__c = customerReg.Tax_Exempted_AGN__c;
                        }
                        else{
                            addObj.Tax_Classification_AGN__c = '9';
                        }
                    }
                    updateList.add(addObj);
                }
                String obj = 'Allergan_Customer_Address_AGN__c';
            	SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
            	AGN_FLSCheck.check(updateList,objType,'UPSERT');
                upsert updateList;
                
                
            }
        }
        Allergan_Customer_Contact_AGN__c crContact = new Allergan_Customer_Contact_AGN__c();
        if(String.isNotEmpty(primaryContact.Id)){
            crContact.Parent_AGN__c = customerReg.Id; 
            crContact.Contact_AGN__c = primaryContact.Id;
            crContact.Allergan_Direct_Access_Requested_AGN__c = primaryContact.Has_Allergan_Direct_Access_AGN__c;
            crContact.First_Name_AGN__c = primaryContact.FirstName;
            crContact.Last_Name_AGN__c  = primaryContact.LastName;
            crContact.Email_AGN__c =  primaryContact.Email;
            crContact.Salutation_AGN__c = primaryContact.Salutation;
            crContact.Phone_AGN__c = primaryContact.Phone;
            crContact.Primary_Contact_AGN__c = primaryContact.Is_Primary_Contact_AGN__c;
            crContact.Contact_Person_Type_AGN__c = primaryContact.SAP_Contact_Person_Type_AGN__c;
            crContact.Enable_Portal_User_AGN__c = String.isEmpty(primaryContact.Okta_Id_AGN__c) ? false : true;//String.isNotEmpty(source) ? source.equalsIgnoreCase('oam') ? true : false : false;
            if((Boolean)AGN_GCSP_Settings__c.getValues(countrycode).get('Enable_HCP_AGN__c') != null){
            	crContact.Enable_HCP_AGN__c = (Boolean)AGN_GCSP_Settings__c.getValues(countrycode).get('Enable_HCP_AGN__c');
            }else{
            	crContact.Enable_HCP_AGN__c = false;
            }  
                                                               
            List<Allergan_Customer_Contact_AGN__c> tempCRContactList = new List<Allergan_Customer_Contact_AGN__c>();
            tempCRContactList.add(crContact);
            String obj = 'Allergan_Customer_Contact_AGN__c';
            SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCRContactList,objType,'INSERT');                                                    
            insert crContact; 
        }
                            
        if(source.containsIgnoreCase('oam')){
            system.debug('crAddressList::::: '+crAddressList);
            list<Allergan_Address_Contact_Mapping_agn__c> addConMapList = new List<Allergan_Address_Contact_Mapping_agn__c>();												   
            for(Allergan_Customer_Address_AGN__c address : crAddressList){
                Allergan_Address_Contact_Mapping_agn__c addConRec = new Allergan_Address_Contact_Mapping_agn__c();            
                    addConRec.Allergan_Customer_Address_agn__c = address.Id;
                    addConRec.Allergan_Customer_Contact_agn__c = crContact.Id;
                    addConRec.Allergan_Customer_Registration_agn__c = customerReg.Id;
                    addConMapList.add(addConRec);
            }
            
            if(!addConMapList.isEmpty()){
                String obj1 = 'Allergan_Address_Contact_Mapping_agn__c';
                SObjectType objType1 = ((SObject)(Type.forName('Schema.'+obj1).newInstance())).getSObjectType();
                AGN_FLSCheck.check(addConMapList,objType1,'UPSERT');
                upsert addConMapList;
            }
                
             AGN_Case_Next.gotoNextStep(caseNewCr.Id);   
        }  
        
        return [select CaseNumber, Id from Case where Id =: caseNewCr.Id limit 1];  
    
    }
    
    
    public static Map<Id, Customer_Detail_AGN__c> getSapDetails(Map<Id, Id> accSapDataMap){
        String commaSepratedFields = AGN_GCSP_PortalAccountDetailController.getAllSobjectFields('Customer_Detail_AGN__c');
        set<Id> sapDataIds = accSapDataMap.keySet();
        list<Id> accIds = accSapDataMap.values();
        String query = 'select '+commaSepratedFields + ' from Customer_Detail_AGN__c' + ' WHERE Id IN:sapDataIds OR Parent_Account_AGN__c IN:accIds';
        Map<Id, Customer_Detail_AGN__c> sapDetailsMap = new Map<Id, Customer_Detail_AGN__c>();
        for(Customer_Detail_AGN__c sapData  : Database.query(query)){            
           sapDetailsMap.put(sapData.Id, sapData);
        }
        
        return sapDetailsMap;
    }

    public static Customer_Detail_AGN__c getSoldToSapDetails(String sapId){//Id bzzAccId
        String commaSepratedFields = AGN_GCSP_PortalAccountDetailController.getAllSobjectFields('Customer_Detail_AGN__c');
        String query = 'select '+' Parent_Account_AGN__r.RecordType.DeveloperName, Country_AGN__r.AGN_Country_Name__c, '+commaSepratedFields + ' from Customer_Detail_AGN__c' + ' WHERE External_ID_AGN__c =:sapId';
        list<Customer_Detail_AGN__c> sapDetailsList = Database.query(query);
        
        return sapDetailsList.isEmpty() ? new Customer_Detail_AGN__c(): sapDetailsList[0];
    }       
    
    
    
    public class SelectOption {
        
        @AuraEnabled
        public String label { get;set; }
        @AuraEnabled
        public String value { get;set; }
        @AuraEnabled
        public Boolean disabled { get;set; }
        @AuraEnabled
        public Boolean escapeItem { get;set; }
        
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;
            this.disabled = false;
            this.escapeItem = false;
        }
        
        public SelectOption(String value, String label, Boolean isDisabled) {
            this.value = value;
            this.label = label;
            this.disabled = isDisabled;
            this.escapeItem = false;
        } 
    }
    
     @AuraEnabled
    public static void saveFiles(list<Object> filesToInsert, String parentId){
        
        list<Id> lstCntVerIds = new list<Id>();
        List<Attachment> lstVersionsToInsert = new List<Attachment>();
        for (Object file : filesToInsert) {
            FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
            Attachment objCntVersion = new Attachment();
            objCntVersion.Name = fileData.Title;
            objCntVersion.ContentType = fileData.ContentType;
            objCntVersion.Body = fileData.VersionData;
            objCntVersion.Description = String.IsNotEmpty(fileData.Description) ? fileData.Description.trim(): '';
            objCntVersion.ParentId = parentId;
            lstVersionsToInsert.add(objCntVersion);
        }
                    
        String objAttachment = 'Attachment';
        SObjectType objattachmentType = ((SObject)(Type.forName('Schema.'+objAttachment).newInstance())).getSObjectType();
        AGN_FLSCheck.check(lstVersionsToInsert,objattachmentType,'UPSERT');

        insert lstVersionsToInsert;        
      
    }


    public class FileInfo {
        public String Title;
        public Blob VersionData;
        public String ContentType;
        Public String Description;
    }
    
}