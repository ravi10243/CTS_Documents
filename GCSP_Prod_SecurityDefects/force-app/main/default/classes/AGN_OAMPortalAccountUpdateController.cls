/*
Type Name: AGN_OAMPortalAccountUpdateController
Reason: Controller class for Cusomer update page lightning components
12-06-2019 - SG - Initial Version
*/
public without sharing class AGN_OAMPortalAccountUpdateController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo) {
        
        return AGN_OAMPortalCustomerRegUtils.getLayoutCountrySetting(country, stepNo, null, null, null);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo, String customerType, String customerSubType) {
        
        return AGN_OAMPortalCustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, null);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo, String customerType, String customerSubType, List<Customer_Type_Configuration_AGN__c> custTypeConfig) {
        
        return AGN_OAMPortalCustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, custTypeConfig);
    }  
    
    public static Set<string> CroFieldsToBooleanify = new Set<string>();
    public static Set<string> CraFieldsToBooleanify = new Set<string>(); 
    public static Map<string, string> CroToAccountFieldMap = new Map<string, string>();//if Person Account exist
    public static Map<string, string> ContactToCroFieldMap = new Map<string, string>();
    public static Map<string, string> AddressToCraFieldMap = new Map<string, string>();
    public static Map<string, string> BizAccountToCraFieldMap = new Map<string, string>();    
    
    @AuraEnabled
    public Allergan_Customer_Registration_AGN__c newRegistration {get;set;}
    @AuraEnabled
    public Allergan_Customer_Address_AGN__c newAddress {get;set;}
    @AuraEnabled
    public static Customer_Type_Configuration_AGN__c config {get;set;}
    @AuraEnabled
    public Form_Of_Payment_AGN__c paymentMethod {get;set;}
    @AuraEnabled
    public Payment_Term_AGN__c paymentTerm {get;set;}
    @AuraEnabled
    public list<Allergan_Customer_Payment_AGN__c> custPayment {get;set;}
    
    //record types
    private static map<string, RecordType> CroRecordTypes;
    private static map<string, RecordType> CraRecordTypes;
    
    public static Account bussinessAccount;
    public static Contact customerContact;
    public static Country_vod__c country;
    
    @AuraEnabled
    public static AGN_OAMPortalAccountUpdateController doInit(Id addressId, string type){ 
        
        CroRecordTypes = fetchRecordTypes('Allergan_Customer_Registration_AGN__c');
        CraRecordTypes = fetchRecordTypes('Allergan_Customer_Address_AGN__c');
        config = getCustTypeConfigDetails();
        customerContact = AGN_OAMPortalAccountDetailController.getContactDetails();
        country = AGN_OAMPortalAccountDetailController.getCountry();
        fetchFieldMappings();       
        
        system.debug('@@@customerContact>>>>>>'+customerContact);
        
        AGN_OAMPortalAccountUpdateController obj = new AGN_OAMPortalAccountUpdateController();
        obj.newRegistration = new Allergan_Customer_Registration_AGN__c();
        obj.newRegistration.Customer_Category_AGN__c = customerContact.Account.Customer_Category_AGN__c;
        obj.newRegistration.Customer_Sub_Category_AGN__c = customerContact.Account.Customer_Sub_Category_AGN__c;
        obj.newRegistration.Customer_Group_AGN__c = customerContact.Account.SAP_Customer_Group_AGN__c;
        obj.newRegistration.Country_Code_AGN__c = customerContact.Account.Country_Code__c ;
        obj.newRegistration.SAP_Country_Code_AGN__c = customerContact.Account.SAP_Country_Code_AGN__c;
        obj.newRegistration.Country_AGN__c = customerContact.Account.Country_vod__c;
        obj.newRegistration.OwnerId= customerContact.OwnerID ; 
        
        String personAccountId = ''; 
        list<AccountContactRelation> acrList= [SELECT Id,ContactId,AccountID FROM AccountContactRelation WHERE ContactId =:customerContact.Id AND Account.Primary_Parent_vod__c =:customerContact.AccountId LIMIT 1];
        if(!acrList.isEmpty()) personAccountId = acrList[0].AccountID;  
        
        if(!string.isEmpty(personAccountId)){      // If PA exist
           Account PersonAccount = getBussinessAcc(personAccountId);
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
                        //string value = (string)(val);
                        //newRegistration.put(crField, value.toUpperCase() == 'YES');
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
        
        obj.newRegistration.Online_Registration_AGN__c = true;        
        obj.newRegistration.RecordTypeId= CroRecordTypes.get('Update').Id;
            //[SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'Update' LIMIT 1][0].Id;
        
        obj.newAddress = getNewAddress(addressId, type);
        obj.newAddress.Country_Lookup_AGN__c = customerContact.Account.Country_vod__c;
        
         system.debug('CRAdata>>>>>>>>>>>>>>'+obj.newAddress);
        
        if (type == 'SoldTo' || type == 'BillTo'){
            
            if (addressId != null){                
                Id accountId = [select Account_vod__c from Address_vod__c where Id =: addressId limit 1].Account_vod__c;                
                obj.custPayment = [SELECT Form_Of_Payment_AGN__c, Payment_Term_AGN__c FROM Allergan_Customer_Payment_AGN__c WHERE Account_AGN__c =: accountId LIMIT 1]; //customerAccount.Primary_Parent_vod__r.id LIMIT 1];
                system.debug('@@@@payment Value'+obj.custPayment);                
                if(obj.custPayment != null && !obj.custPayment.isEmpty()){
                    if(obj.custPayment[0].Form_Of_Payment_AGN__c != null){
                        obj.paymentMethod = [SELECT Id,Name, Form_Of_Payment_Label_AGN__c,SAP_Code_AGN__c,SAP_Country_Code_AGN__c,Country_Code_AGN__c FROM Form_Of_Payment_AGN__c WHERE ID=:obj.custPayment[0].Form_Of_Payment_AGN__c];  
                        //obj.newRegistration.Form_of_Payment_AGN__c = obj.paymentMethod.Id; 
                        if(customerContact.Account.Country_Code__c == 'AN'){
                          obj.newAddress.Form_of_Payment_AGN__c = obj.paymentMethod.Id;  
                        }                           
                        else{
                          obj.newRegistration.Form_of_Payment_AGN__c = obj.paymentMethod.Id;  
                        }
                    }else{
                        obj.paymentMethod = new Form_Of_Payment_AGN__c();
                    }
                    if( obj.custPayment[0].Payment_Term_AGN__c != null){
                        obj.paymentTerm = [SELECT Id,Name, SAP_Payment_Term_Code_AGN__c,Payment_Term_Label_AGN__c,Form_Of_Payment__c,SAP_Country_Code_AGN__c,Country_Code_AGN__c FROM Payment_Term_AGN__c WHERE ID=:obj.custPayment[0].Payment_Term_AGN__c];
                        //obj.newRegistration.Payment_Term_AGN__c = obj.paymentTerm.Id;
                        if(customerContact.Account.Country_Code__c == 'AN'){
                          obj.newAddress.Payment_Term_AGN__c = obj.paymentTerm.Id;  
                        }                           
                        else{
                            obj.newRegistration.Payment_Term_AGN__c = obj.paymentTerm.Id;                            
                        }
                        
                    }else{
                        obj.paymentTerm = new Payment_Term_AGN__c();
                    }
                    
                }             
                for (Allergan_Customer_Payment_AGN__c payment : [SELECT Account_AGN__c, Bank_Name_AGN__c, Bank_Account_Number_AGN__c, IBAN_AGN__c,IBAN_Text_AGN__c, 
                                                                 Sort_Code_AGN__c, SWIFT_BIC_AGN__c,
                                                                 Business_Name_Reference1_AGN__c,Business_Name_Reference2_AGN__c,Business_Name_Reference3_AGN__c,
                                                                 Contact_Name_Reference1_AGN__c,Contact_Name_Reference2_AGN__c,Contact_Name_Reference3_AGN__c,
                                                                 Fax_Reference1_AGN__c,Fax_Reference2_AGN__c,
                                                                 Phone_Reference1_AGN__c,Phone_Reference2_AGN__c,Phone_Reference3_AGN__c,
                                                                 Email_Reference1_AGN__c,Email_Reference2_AGN__c,Email_Reference3_AGN__c
                                                                 FROM Allergan_Customer_Payment_AGN__c WHERE Account_AGN__c =: accountId LIMIT 1]){              
                                                                     
                                                                     obj.newAddress.IBAN_AGN__c = payment.IBAN_Text_AGN__c;
                                                                     obj.newAddress.IBAN_Text_AGN__c = payment.IBAN_Text_AGN__c;
                                                                     obj.newAddress.SWIFT_BIC_AGN__c = payment.SWIFT_BIC_AGN__c;
                                                                     obj.newAddress.Bank_Name_AGN__c = payment.Bank_Name_AGN__c;
                                                                     obj.newAddress.Bank_Account_Number_AGN__c = payment.Bank_Account_Number_AGN__c;
                                                                     obj.newAddress.Sort_Code_AGN__c = payment.Sort_Code_AGN__c;
                                                                     obj.newAddress.Customer_Payment__c = payment.Id;
                                                                     obj.newAddress.Business_Name_Reference1_AGN__c = payment.Business_Name_Reference1_AGN__c;
                                                                     obj.newAddress.Business_Name_Reference2_AGN__c = payment.Business_Name_Reference2_AGN__c;
                                                                     obj.newAddress.Business_Name_Reference3_AGN__c = payment.Business_Name_Reference3_AGN__c;
                                                                     obj.newAddress.Contact_Name_Reference1_AGN__c = payment.Contact_Name_Reference1_AGN__c;
                                                                     obj.newAddress.Contact_Name_Reference2_AGN__c = payment.Contact_Name_Reference2_AGN__c;
                                                                     obj.newAddress.Contact_Name_Reference3_AGN__c = payment.Contact_Name_Reference3_AGN__c;
                                                                     obj.newAddress.Fax_Reference1_AGN__c = payment.Fax_Reference1_AGN__c;
                                                                     obj.newAddress.Fax_Reference2_AGN__c = payment.Fax_Reference2_AGN__c;
                                                                     obj.newAddress.Phone_Reference1_AGN__c = payment.Phone_Reference1_AGN__c;
                                                                     obj.newAddress.Phone_Reference2_AGN__c = payment.Phone_Reference2_AGN__c;
                                                                     obj.newAddress.Phone_Reference3_AGN__c = payment.Phone_Reference3_AGN__c;
                                                                     obj.newAddress.Email_Reference1_AGN__c = payment.Email_Reference1_AGN__c;
                                                                     obj.newAddress.Email_Reference2_AGN__c = payment.Email_Reference2_AGN__c;
                                                                     obj.newAddress.Email_Reference3_AGN__c = payment.Email_Reference3_AGN__c;
                                                                 }
            }
            else{     
                
                obj.newAddress.IBAN_AGN__c = '';
                obj.newAddress.IBAN_Text_AGN__c = '';
                obj.newAddress.SWIFT_BIC_AGN__c = '';
                obj.newAddress.Bank_Name_AGN__c = '';
                obj.newAddress.Bank_Account_Number_AGN__c = '';
                obj.newAddress.Sort_Code_AGN__c = '';
                obj.newAddress.Business_Name_Reference1_AGN__c = '';
                obj.newAddress.Business_Name_Reference2_AGN__c = '';
                obj.newAddress.Business_Name_Reference3_AGN__c = '';
                obj.newAddress.Contact_Name_Reference3_AGN__c = '';
                obj.newAddress.Contact_Name_Reference1_AGN__c = '';
                obj.newAddress.Contact_Name_Reference2_AGN__c = '';
                obj.newAddress.Fax_Reference1_AGN__c = '';
                obj.newAddress.Fax_Reference2_AGN__c = '';
                obj.newAddress.Phone_Reference1_AGN__c = '';
                obj.newAddress.Phone_Reference2_AGN__c = '';
                obj.newAddress.Phone_Reference3_AGN__c = '';
                obj.newAddress.Email_Reference1_AGN__c = '';
                obj.newAddress.Email_Reference2_AGN__c = '';
                obj.newAddress.Email_Reference3_AGN__c = '';
                
                //obj.newRegistration.Form_Of_Payment_AGN__c = [SELECT Id FROM Form_Of_Payment_AGN__c WHERE Country_Code_AGN__c=:customerAccount.Country_Code__c AND Active_AGN__c= true and Name = 'Direct Debit' LIMIT 1].Id;
            }
        }
        
        return obj;
    }
    
    @AuraEnabled
    public static Allergan_Customer_Address_AGN__c getNewAddress(Id addressId, string type){
        
        Allergan_Customer_Address_AGN__c newAddress = new Allergan_Customer_Address_AGN__c();
        Address_vod__c oldAddress;        
        newAddress.Country_AGN__c = country.AGN_Country_Name__c;
        
        if (type == 'SoldTo')
            newAddress.Sold_To_AGN__c = true;
        else if (type == 'ShipTo')
            newAddress.Ship_To_AGN__c = true;
        else if (type == 'BillTo')
            newAddress.Bill_To_AGN__c = true;
        
        if(addressId != null){
            oldAddress = getOldAddress(addressId);
            bussinessAccount = getBussinessAcc(oldAddress.Account_vod__c);
            newAddress.Account_AGN__c = bussinessAccount.Id;
            newAddress.Sold_To_AGN__c = bussinessAccount.SAP_Sold_To_AGN__c;
            newAddress.Ship_To_AGN__c = bussinessAccount.SAP_Ship_To_AGN__c;
            newAddress.Bill_To_AGN__c = bussinessAccount.SAP_Bill_To_AGN__c;
            newAddress.Parent_Address_AGN__c = oldAddress.Id;
            
            if(!string.isEmpty(customerContact.Account.SAP_Country_Code_AGN__c) && customerContact.Account.Country_Code__c !='IT'){                
                newAddress.State_AGN__c = string.isBlank(oldAddress.State_vod__c)? '':(customerContact.Account.SAP_Country_Code_AGN__c+ '-' +oldAddress.State_vod__c) ;
            }else{
                newAddress.State_AGN__c = string.isBlank(oldAddress.State_vod__c)? '':(customerContact.Account.Country_Code__c+'-'+oldAddress.State_vod__c) ;
            }  
            
            newAddress.RecordTypeId = CraRecordTypes.get('Amend').Id;
                //[SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'Amend' LIMIT 1][0].Id;
            for (string addField : AddressToCraFieldMap.keySet()){                     
                string craField = AddressToCraFieldMap.get(addField);
                if (CraFieldsToBooleanify.contains(craField)){
                    object val = oldAddress.get(craField);                    
                    if (val != null){
                        //string value = (string)(val); 
                        //newAddress.put(craField1, value.toUpperCase() == 'YES');
                        Boolean theBool = Boolean.valueOf(val);
                        String boolVal = (theBool) ? 'Yes' : '';
                        newAddress.put(craField, boolVal);
                    }
                }else{
                    if(craField.ToUpperCase() != 'STATE_CODE_AGN__C'){
                       newAddress.put(craField, oldAddress.get(addField));
                    }
                }
                
            }           
            for (string accField : BizAccountToCraFieldMap.keySet()){                     
                string craField1 = BizAccountToCraFieldMap.get(accField);
                if (CraFieldsToBooleanify.contains(craField1)){
                    object val = bussinessAccount.get(craField1);                    
                    if (val != null){
                        //string value = (string)(val);
                        //newAddress.put(craField1, value.toUpperCase() == 'YES');
                        Boolean theBool = Boolean.valueOf(val);
                        String boolVal = (theBool) ? 'Yes' : '';
                        newAddress.put(craField1, boolVal);
                    }
                }else{
                    newAddress.put(craField1, bussinessAccount.get(accField));
                }
                
            }
            newAddress.House_Number_AGN__c= !String.isBlank(oldAddress.Name)&& oldAddress.Name.Contains(',') ?oldAddress.Name.split(',')[1].Trim():'';
            newAddress.Street_Name_AGN__c = !String.isBlank(oldAddress.Name)&& oldAddress.Name.Contains(',') ?oldAddress.Name.split(',')[0].Trim():oldAddress.Name.Trim();
            for (Child_Account_vod__c ch : [SELECT Child_Account_vod__c,Sold_To_AGN__c, Ship_To_AGN__c, Bill_To_AGN__c 
                                            FROM Child_Account_vod__c WHERE Parent_Account_vod__c = : customerContact.AccountId 
                                            AND Child_Account_vod__c =: bussinessAccount.Id Limit 1]){ //AND Customer_Managed_AGN__c = True
                                                //newAddress.Sold_To_AGN__c = ch.Sold_To_AGN__c;
                                                newAddress.Ship_To_AGN__c = ch.Ship_To_AGN__c;                            
                                                newAddress.Bill_To_AGN__c = ch.Bill_To_AGN__c;                              
                                            } 
            
        }else{
            oldAddress = new Address_vod__c();
            newAddress.RecordTypeId = CraRecordTypes.get('New').Id;
                //[SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id;
            
        }
        
        system.debug('newAddress>>>>>>>>>>'+newAddress);
        return newAddress;
    }
    
    public static Map<string, RecordType> fetchRecordTypes(string sobjecttype)    {
        Map<string, RecordType> output = new Map<string, RecordType>();
        for (RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType = :sobjecttype])
        {
            output.put(rt.DeveloperName, rt);
        }
            
        return output;
    }
    
    Public static Address_vod__c getOldAddress(string addressId){
        String addId = String.escapeSingleQuotes(addressId);
        String SobjectApiName = 'Address_vod__c';
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
        query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE ID ='+'\''+ addId+ '\'';
        
        Address_vod__c oldAdd = Database.query(query); 
        
        return oldAdd;
    }
    
    Public static Account getBussinessAcc(string accId){
      
         Account bAcc = AGN_OAMPortalAccountDetailController.getBussinessAccountDetails(accId);
        
        return bAcc;
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
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getPickListValues(string objectName,String columnName,String columnId, String whereCondition){
        String wherecond = whereCondition != null ? String.valueOf(whereCondition) : '';
        String query = 'select '+String.escapeSingleQuotes(String.valueOf(columnName))+','+String.escapeSingleQuotes(String.valueOf(columnId))+' From '+String.escapeSingleQuotes(objectName) + wherecond;
        system.debug('@@@@query@@@'+ query);
        List<sObject> PicklistValues = Database.query(query);
        system.debug('@@@@PicklistValues@@@'+ PicklistValues);
        return PicklistValues;         
    }  
    
    @AuraEnabled(cacheable=true)
    public static List<Object> getPaymentDetails(string formofPayment,String paymentTerm, String countryCode){
        system.debug('@@@@getPaymentDetails>>>>'+formofPayment+'>>>>'+paymentTerm+'>>>>'+countryCode);
        List<Object> optionsObject = new List<Object>();
        Form_of_Payment_AGN__c fop;
        if(countryCode == 'CA'){
            if(formofPayment != null){
                fop = [SELECT ID,Name, Form_Of_Payment_Label_AGN__c FROM Form_of_Payment_AGN__c 
                       WHERE (Form_Of_Payment_Label_AGN__c =: formofPayment OR Name =: formofPayment) 
                       AND Country_code_AGN__c =: countryCode];
                
                optionsObject.add(fop);               
            
            } 
        }       
        if(paymentTerm != null){            
            Payment_Term_AGN__c pt;            
            if(countryCode == 'CA'){                
                pt = [SELECT ID, Name,Payment_Term_Label_AGN__c FROM Payment_Term_AGN__c 
                      WHERE (Name =: paymentTerm OR Payment_Term_Label_AGN__c =: paymentTerm)
                      AND Form_Of_Payment__c =: fop.Id];
                
            }else{
                
              pt = [SELECT ID, Name,Payment_Term_Label_AGN__c FROM Payment_Term_AGN__c 
                                      WHERE SAP_Payment_Term_Code_AGN__c =: paymentTerm 
                                      AND Form_Of_Payment__c =: formofPayment];
            
            }
            
            optionsObject.add(pt);  
        }   
        system.debug('@@@@getPaymentDetails>>>>'+optionsObject);
        return optionsObject;         
    } 
    
    @AuraEnabled
    public static Case saveCustomerUpdate(string newAddress, string newRegistration, string activity){
        system.debug('newAddress--->'+newAddress);
        system.debug('newRegistration--->'+newRegistration);
        system.debug('activity--->'+activity);
        
        Contact Con = AGN_OAMPortalAccountDetailController.getContactDetails();        
        Account bzzAcc = AGN_OAMPortalAccountDetailController.getBussinessAccountDetails(Con.AccountId);
        map<string, RecordType> CaseRecordTypes= fetchRecordTypes('Case');
        
        list<Allergan_Customer_Payment_AGN__c> payment = [SELECT Account_AGN__c,
                                                          Form_Of_Payment_AGN__c,Payment_Term_AGN__c,
                                                          Bank_Name_AGN__c, Bank_Account_Number_AGN__c, 
                                                          IBAN_AGN__c,IBAN_Text_AGN__c, Sort_Code_AGN__c, SWIFT_BIC_AGN__c,
                                                          Business_Name_Reference1_AGN__c,Business_Name_Reference2_AGN__c,Business_Name_Reference3_AGN__c,
                                                          Contact_Name_Reference1_AGN__c,Contact_Name_Reference2_AGN__c,Contact_Name_Reference3_AGN__c,
                                                          Fax_Reference1_AGN__c,Fax_Reference2_AGN__c,
                                                          Phone_Reference1_AGN__c,Phone_Reference2_AGN__c,Phone_Reference3_AGN__c,
                                                          Email_Reference1_AGN__c,Email_Reference2_AGN__c,Email_Reference3_AGN__c
                                                          FROM Allergan_Customer_Payment_AGN__c
                                                          WHERE Account_AGN__c =: bzzAcc.Id LIMIT 1];
        
        
        Allergan_Customer_Address_AGN__c customerAddress = (Allergan_Customer_Address_AGN__c)JSON.deserialize(newAddress, Allergan_Customer_Address_AGN__c.class);
        if (!String.isBlank(customerAddress.House_Number_AGN__c) && !String.isBlank(customerAddress.Street_Name_AGN__c)){
            customerAddress.Address_Line_1_AGN__c =  customerAddress.Street_Name_AGN__c + ' , ' + customerAddress.House_Number_AGN__c;
        }   
        Allergan_Customer_Registration_AGN__c  customerReg = (Allergan_Customer_Registration_AGN__c)JSON.deserialize(newRegistration, Allergan_Customer_Registration_AGN__c.class);
        String changeList = '';
        
        if(customerAddress.Parent_Address_AGN__c != null){
            Address_vod__c oldCustomerAddress = [SELECT Id, Account_vod__c, Account_vod__r.External_ID2_AGN__c, Account_vod__r.Name, Name, Address_line_2_vod__c, Address_line_3_AGN__c, State_vod__c, City_vod__c, 
                                                 Country_vod__c, Phone_vod__c, Zip_vod__c, Email_AGN__c, Department_Name_AGN__c FROM Address_vod__c 
                                                 WHERE Id =: customerAddress.Parent_Address_AGN__c LIMIT 1];
            changeList += AGN_CustomerRegistrationUtils.generateChangeList(customerAddress, oldCustomerAddress);
        }
        
        Case caseNewCr = new Case();
        caseNewCr.Service_AGN__c = 'Customer Registration';     
        caseNewCr.Priority = 'Medium';
        caseNewCr.Origin = 'Web';
        caseNewCr.Status = 'New';
        caseNewCr.AccountId = con.AccountId;
        caseNewCr.ContactId = con.Id;
        //RecordType caseRecordType = [SELECT Id, Name,DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'AGN_Support_Request_Customer_Update' LIMIT 1][0];        
        caseNewCr.RecordTypeId = CaseRecordTypes.get('AGN_Support_Request_Customer_Update').Id;
        caseNewCr.SuppliedName = con.FirstName + ' ' + con.LastName;
        caseNewCr.SuppliedEmail = con.Email;
        caseNewCr.SuppliedPhone = con.Phone;
        caseNewCr.Country_Code_AGN__c = customerReg.Country_Code_AGN__c;
        caseNewCr.Description_Rich_Text__c = changeList;
        
        if (activity == 'delete'){
            caseNewCr.Type = 'Deactivate';
            caseNewCr.Reason = 'Deactivate Customer Address';
            
        }
        else if (activity == 'new'){
            caseNewCr.Type = 'New';
            caseNewCr.Reason = 'New Customer Address';
        }  
        else{
            caseNewCr.Type = 'Update';
            caseNewCr.Reason = 'Update Customer Address'; 
        }
        //caseNewCr.Subject = con.FirstName + ' ' + con.LastName + ' - ' + caseNewCr.Type;
        system.debug('case details---->'+caseNewCr);
        system.debug('======setEntitlement========='+ CaseRecordTypes.get('AGN_Support_Request_Customer_Update').Name+'=='+ caseNewCr.Type+ '=='+con.Account.SAP_Country_Code_AGN__c);
            string countrycode;
            if(!string.isEmpty(con.Account.SAP_Country_Code_AGN__c) && con.Account.Country_Code__c.equalsIgnoreCase('AN')){
                if(con.Account.SAP_Country_Code_AGN__c.equalsIgnoreCase('AU')){
                countrycode = 'AN';
                }else{
                    countrycode = con.Account.SAP_Country_Code_AGN__c;
                }
            }else{
                countrycode = con.Account.Country_Code__c;
            }
            
        
        caseNewCr.EntitlementId = AGN_OAMPortalCustomerRegUtils.setEntitlement(CaseRecordTypes.get('AGN_Support_Request_Customer_Update').Name, caseNewCr.Type, countrycode);
        
        //------CheckMarx--Added on 24/07/2020----------      
        List<Case> tempCsList = new List<Case>();
        tempCsList.add(caseNewCr);
       /* SObjectAccessDecision decisionOnCs = Security.stripInaccessible(AccessType.CREATABLE,tempCsList);
        if(decisionOnCs.getRemovedFields().get('Case')!=null){
            throw new AGN_CommonException('Error: Insufficient Create Access On Case [Class Name: AGN_OAMPortalAccountUpdateController and Method Name: saveCustomerUpdate]');
        }
        else{
            insert caseNewCr;
        }*/
        String objCs = 'Case';
        SObjectType CsObjType = ((SObject)(Type.forName('Schema.'+objCs).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCsList,CsObjType,'INSERT');  
        insert caseNewCr;
        //--------------------
      
        
        system.debug('case--->'+caseNewCr.Id);
        
        customerReg.Case_AGN__c = caseNewCr.Id; 
        customerReg.Processed_By_SAP_AGN__c = 'In Progress';
        customerReg.Change_List_AGN__c = changeList;
        customerReg.Online_Registration_AGN__c= true;
        customerReg.Business_Account_SAP_ID__c =  bzzAcc.External_ID2_AGN__c;        
        customerReg.Language_AGN__c = UserInfo.getLanguage();
       
       if (activity == 'edit' && customerAddress.Sold_To_AGN__c == True && con.Account.Country_Code__c != 'AN'){            
            if(payment != null && !payment.isEmpty() && payment[0].Form_Of_Payment_AGN__c != null){
                customerReg.Form_of_Payment_AGN__c = payment[0].Form_Of_Payment_AGN__c;                 
            }
            if(payment != null && !payment.isEmpty() && payment[0].Payment_Term_AGN__c != null){
                customerReg.Payment_Term_AGN__c = payment[0].Payment_Term_AGN__c; 
            }          
        }  

        if(con.Account.Country_Code__c != 'CA' && con.Account.Country_Code__c != 'AN'){        
          if(activity == 'new' && customerAddress.Bill_To_AGN__c == True){              
              if(payment != null && !payment.isEmpty() && payment[0].Form_Of_Payment_AGN__c != null){
                  customerReg.Form_of_Payment_AGN__c = payment[0].Form_Of_Payment_AGN__c;
              }
              if(payment != null && !payment.isEmpty() && payment[0].Payment_Term_AGN__c != null){
                  customerReg.Payment_Term_AGN__c = payment[0].Payment_Term_AGN__c; 
              }          
          }  
       }
        
        //------CheckMarx--Added on 24/07/2020----------      
        List<Allergan_Customer_Registration_AGN__c> tempCrR = new List<Allergan_Customer_Registration_AGN__c>();
        tempCrR.add(customerReg);
        /*SObjectAccessDecision decisionOnCrR = Security.stripInaccessible(AccessType.CREATABLE,tempCrR);
        if(decisionOnCrR.getRemovedFields().get('Allergan_Customer_Registration_AGN__c')!=null){
            throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Registration_AGN__c [Class Name: AGN_OAMPortalAccountUpdateController and Method Name: saveCustomerUpdate]');
        }
        else{
             insert customerReg;
        }*/
        String objCRReg = 'Allergan_Customer_Registration_AGN__c';
        SObjectType CrObjType = ((SObject)(Type.forName('Schema.'+objCRReg).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCrR,CrObjType,'INSERT');  
        insert customerReg;
        //---------------------------------------------- 
      
        
        if(con.Account.Country_Code__c != 'AN'){
            customerAddress.SAP_Name_1_AGN__c = customerAddress.Company_Name_AGN__c;
        }        
        customerAddress.Parent_AGN__c = customerReg.Id;
        RecordType recordTypeName = [SELECT Name,DeveloperName FROM RecordType WHERE ID=:bzzAcc.RecordTypeID LIMIT 1];//query Bussiness Account Recordtype
        customerAddress.Account_Type_AGN__c = recordTypeName.DeveloperName;
           
        if (activity == 'edit' && customerAddress.Sold_To_AGN__c == True && payment != null && !payment.isEmpty() 
            && payment[0].Payment_Term_AGN__c != null&& payment[0].Form_Of_Payment_AGN__c != null && con.Account.Country_Code__c == 'AN'){
            customerAddress.Form_Of_Payment_AGN__c = payment[0].Form_Of_Payment_AGN__c;
            customerAddress.Payment_Term_AGN__c = payment[0].Payment_Term_AGN__c;
        }       
        
        if(con.Account.Country_Code__c != 'IT' &&  con.Account.Country_Code__c !='AN'){
            customerAddress.Country_AGN__c =  bzzAcc.Country_vod__r.AGN_Country_Name__c; 
        }
        //customerAddress.Country_AGN__c =  customerContact.Country_vod__r.AGN_Country_Name__c;         
        customerAddress.Country_Lookup_AGN__c = con.Account.Country_vod__c;
        
        if(activity == 'new'){
            system.debug('Tax classification --->'+bzzAcc.SAP_Tax_Classification_AGN__c );
            if(con.Account.Country_Code__c == 'IT'){
                if(customerAddress.Country_AGN__c == 'Italy' ){
                    customerAddress.Tax_Classification_AGN__c = '9';
                }else{
                    customerAddress.Tax_Classification_AGN__c = '0';
                }
            }else{
                customerAddress.Tax_Classification_AGN__c = bzzAcc.SAP_Tax_Classification_AGN__c; 
            }
                       
            // Add account owner information for new account
            customerAddress.Are_You_The_Prescribing_Doctor_AGN__c = bzzAcc.Are_you_the_prescribing_doctor_AGN__c;
            customerAddress.Doctors_Email_AGN__c = bzzAcc.SAP_Doctors_Email_AGN__c;
            customerAddress.Doctors_First_Name_AGN__c = bzzAcc.SAP_Doctors_First_Name__c;
            customerAddress.Doctors_Middle_Name_AGN__c = bzzAcc.SAP_Doctors_Middle_Name_AGN__c;
            customerAddress.Doctors_Last_Name_AGN__c = bzzAcc.SAP_Doctors_Last_Name_AGN__c;
            customerAddress.Doctors_Phone_AGN__c = bzzAcc.SAP_Doctors_Phone_AGN__c;
        }
        // added by abdul       
        if(activity == 'edit'){
            if(bzzAcc.SAP_Tax_Classification_AGN__c != null){
                customerAddress.Tax_Classification_AGN__c = bzzAcc.SAP_Tax_Classification_AGN__c;                
            }
            
        }
        // end 
        if (activity=='delete'){
            customerAddress.Request_for_Deactivation_AGN__c =  true;
        }
        if(activity == 'new' && customerAddress.Ship_To_AGN__c == true && customerAddress.Are_You_The_Prescribing_Doctor_AGN__c == false){            
            customerAddress.Are_You_The_Prescribing_Doctor_AGN__c = true;
            //------CheckMarx--Added on 24/07/2020----------      
            List<Allergan_Customer_Address_AGN__c> tempCrAddrIn = new List<Allergan_Customer_Address_AGN__c>();
            tempCrAddrIn.add(customerAddress);
           /* SObjectAccessDecision decisionOnCrAddrIn = Security.stripInaccessible(AccessType.CREATABLE,tempCrAddrIn);
            if(decisionOnCrAddrIn.getRemovedFields().get('Allergan_Customer_Address_AGN__c')!=null){
                throw new AGN_CommonException('Error: Insufficient Edit/Create Access On Allergan_Customer_Address_AGN__c [Class Name: AGN_OAMPortalAccountUpdateController and Method Name: saveCustomerUpdate]');
            }
            else{
                insert customerAddress;
            }*/
            String objCrAddr1 = 'Allergan_Customer_Address_AGN__c';
            SObjectType CrAddrObjType1 = ((SObject)(Type.forName('Schema.'+objCrAddr1).newInstance())).getSObjectType();
            AGN_FLSCheck.check(tempCrAddrIn,CrAddrObjType1,'INSERT');  
            insert customerAddress;
            //---------------------------------------------- 
           
            if(customerAddress.Are_You_The_Prescribing_Doctor_AGN__c == true){
                customerAddress.Are_You_The_Prescribing_Doctor_AGN__c = false;
            }
        }
        
        //------CheckMarx--Added on 24/07/2020----------      
        List<Allergan_Customer_Address_AGN__c> tempCrAddr = new List<Allergan_Customer_Address_AGN__c>();
        tempCrAddr.add(customerAddress);
        /*SObjectAccessDecision decisionOnCrAddr = Security.stripInaccessible(AccessType.UPSERTABLE,tempCrAddr);
        if(decisionOnCrAddr.getRemovedFields().get('Allergan_Customer_Address_AGN__c')!=null){
            throw new AGN_CommonException('Error: Insufficient Edit/Create Access On Allergan_Customer_Address_AGN__c [Class Name: AGN_OAMPortalAccountUpdateController and Method Name: saveCustomerUpdate]');
        }
        else{
            upsert customerAddress;
        }*/
        String objCrAddr = 'Allergan_Customer_Address_AGN__c';
        SObjectType CrAddrObjType = ((SObject)(Type.forName('Schema.'+objCrAddr).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCrAddr,CrAddrObjType,'UPSERT');  
        upsert customerAddress;
        //---------------------------------------------- 
        
        // add allergan customer registration and Contact relation
        Allergan_Customer_Contact_AGN__c crContact = new Allergan_Customer_Contact_AGN__c();
                                                           crContact.Parent_AGN__c = customerReg.Id; 
                                                           crContact.Contact_AGN__c = con.Id;
                                                           crContact.First_Name_AGN__c = con.FirstName;
                                                           crContact.Last_Name_AGN__c  = con.LastName;
                                                           crContact.Email_AGN__c =  con.Email;
                                                           crContact.Salutation_AGN__c = con.Salutation;
                                                           crContact.Phone_AGN__c = con.Phone;
                                                           crContact.Primary_Contact_AGN__c = con.Is_Primary_Contact_AGN__c;
                                                           crContact.Enable_Portal_User_AGN__c = true;
                                                           if((Boolean)AGN_GCSP_Settings__c.getValues(con.Account.Country_Code__c).get('Enable_HCP_AGN__c') != null){
                                                                crContact.Enable_HCP_AGN__c = (Boolean)AGN_GCSP_Settings__c.getValues(con.Account.Country_Code__c).get('Enable_HCP_AGN__c');
                                                            }else{
                                                                crContact.Enable_HCP_AGN__c = false;
                                                            }  
                                                           
        //------CheckMarx--Added on 24/07/2020----------      
        List<Allergan_Customer_Contact_AGN__c> tempCrCnt = new List<Allergan_Customer_Contact_AGN__c>();
        tempCrCnt.add(crContact);
       /* SObjectAccessDecision decisionOnCrCnt = Security.stripInaccessible(AccessType.CREATABLE,tempCrCnt);
        if(decisionOnCrCnt.getRemovedFields().get('Allergan_Customer_Contact_AGN__c')!=null){
            System.debug('No Permission on fields '+decisionOnCrCnt.getRemovedFields().get('Allergan_Customer_Contact_AGN__c'));
            throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Contact_AGN__c [Class Name: AGN_OAMPortalAccountUpdateController and Method Name: saveCustomerUpdate] No Permission on fields '+decisionOnCrCnt.getRemovedFields().get('Allergan_Customer_Contact_AGN__c'));
        }
        else{
            insert crContact;
        }*/
        String objCrCNT = 'Allergan_Customer_Contact_AGN__c';
        SObjectType CrCntObjType = ((SObject)(Type.forName('Schema.'+objCrCNT).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tempCrCnt,CrCntObjType,'INSERT');  
        insert crContact;
        //----------------------------------------------                                                                  
        
        
        if(activity == 'edit' && customerAddress.Sold_To_AGN__c == True){
            if(payment == null || payment.isEmpty()){
                Allergan_Customer_Payment_AGN__c acp = new Allergan_Customer_Payment_AGN__c();
                acp.Form_Of_Payment_AGN__c = customerReg.Form_of_Payment_AGN__c;
                acp.Payment_Term_AGN__c = customerReg.Payment_Term_AGN__c;
                acp.Account_AGN__c = con.AccountId;//con.Primary_Parent_vod__c; 
                acp.IBAN_AGN__c = customerAddress.IBAN_Text_AGN__c;
                acp.IBAN_Text_AGN__c = customerAddress.IBAN_Text_AGN__c;
                acp.SWIFT_BIC_AGN__c = customerAddress.SWIFT_BIC_AGN__c;
                acp.Bank_Name_AGN__c = customerAddress.Bank_Name_AGN__c;
                acp.Bank_Account_Number_AGN__c = customerAddress.Bank_Account_Number_AGN__c;
                acp.Sort_Code_AGN__c = customerAddress.Sort_Code_AGN__c;
                acp.Business_Name_Reference1_AGN__c = customerAddress.Business_Name_Reference1_AGN__c;
                acp.Business_Name_Reference2_AGN__c = customerAddress.Business_Name_Reference2_AGN__c;
                acp.Business_Name_Reference3_AGN__c = customerAddress.Business_Name_Reference3_AGN__c;
                acp.Contact_Name_Reference1_AGN__c = customerAddress.Contact_Name_Reference1_AGN__c;
                acp.Contact_Name_Reference2_AGN__c = customerAddress.Contact_Name_Reference2_AGN__c;
                acp.Contact_Name_Reference3_AGN__c = customerAddress.Contact_Name_Reference3_AGN__c;
                acp.Fax_Reference1_AGN__c = customerAddress.Fax_Reference1_AGN__c;
                acp.Fax_Reference2_AGN__c = customerAddress.Fax_Reference2_AGN__c;
                acp.Phone_Reference1_AGN__c = customerAddress.Phone_Reference1_AGN__c;
                acp.Phone_Reference2_AGN__c = customerAddress.Phone_Reference2_AGN__c;
                acp.Phone_Reference3_AGN__c = customerAddress.Phone_Reference3_AGN__c;
                acp.Email_Reference1_AGN__c = customerAddress.Email_Reference1_AGN__c;
                acp.Email_Reference2_AGN__c = customerAddress.Email_Reference2_AGN__c;
                acp.Email_Reference3_AGN__c = customerAddress.Email_Reference3_AGN__c;
                
                //------CheckMarx--Added on 24/07/2020----------      
                List<Allergan_Customer_Payment_AGN__c> tempacpList = new List<Allergan_Customer_Payment_AGN__c>();
                tempacpList.add(acp);
                /*SObjectAccessDecision decisionOnacp = Security.stripInaccessible(AccessType.CREATABLE,tempacpList);
                if(decisionOnacp.getRemovedFields().get('Allergan_Customer_Payment_AGN__c')!=null){
                    System.debug('No Permission on fields '+decisionOnacp.getRemovedFields().get('Allergan_Customer_Payment_AGN__c'));
                    throw new AGN_CommonException('Error: Insufficient Create Access On Allergan_Customer_Payment_AGN__c [Class Name: AGN_OAMPortalAccountUpdateController and Method Name: saveCustomerUpdate]');
                }
                else{
                    insert acp;
                }*/
                String objPay = 'Allergan_Customer_Payment_AGN__c';
                SObjectType objPayType = ((SObject)(Type.forName('Schema.'+objPay).newInstance())).getSObjectType();
                AGN_FLSCheck.check(tempacpList,objPayType,'INSERT');
                insert acp;
               //----------------------------------------------
            }
            
        } 
        
        AGN_Case_Next.gotoNextStep(caseNewCr.Id);        
        
        return [select CaseNumber, Id from Case where Id =: caseNewCr.Id limit 1];        
        
    }
    
    @AuraEnabled
    public static string savetestFile(){
        
        Case c=new Case();
        c=[select CaseNumber, Id from Case limit 1];
        return c.CaseNumber;
        
    }
    
    
    @AuraEnabled
    public static Id saveFile(Id parentId, String fileName, String base64Data, String contentType) {
        system.debug('== [FileUploadMethod].[saveTheFile] =='+parentId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        List<Attachment> attachmentList = new List<Attachment>();
        Allergan_Customer_Registration_AGN__c acr = new Allergan_Customer_Registration_AGN__c();
        acr = [SELECT Id, Case_AGN__c  FROM Allergan_Customer_Registration_AGN__c WHERE Case_AGN__c=:parentId LIMIT 1];
        
        
        Attachment attachmentFile = new Attachment(); 
        attachmentFile.ParentId = acr.Id;
        attachmentFile.Body = EncodingUtil.base64Decode(base64Data);
        attachmentFile.Name = fileName;
        attachmentFile.ContentType = contentType;
        
        system.debug('•attachmentFile•'+attachmentFile);
        //------CheckMarx--Added on 24/07/2020----------  
        List<Attachment> tmpattList = new List<Attachment>();        
        tmpattList.add(attachmentFile);
        /*SObjectAccessDecision decisionOnAtt = Security.stripInaccessible(AccessType.CREATABLE,tmpattList);
        if(decisionOnAtt.getRemovedFields().get('Attachment')!=null){
            System.debug('No Permission on fields '+decisionOnAtt.getRemovedFields().get('Attachment'));
            throw new AGN_CommonException('Error: Insufficient Create/Edit Access On Attachment [Class Name: AGN_OAMPortalAccountUpdateController and Method Name: saveFile]');
        }
        else{
            insert attachmentFile;
            return attachmentFile.Id;
        }*/
        String objCrAtt = 'Attachment';
        SObjectType ACRAttObjType = ((SObject)(Type.forName('Schema.'+objCrAtt).newInstance())).getSObjectType();
        AGN_FLSCheck.check(tmpattList,ACRAttObjType,'INSERT');
        insert attachmentFile;
        return attachmentFile.Id;
        //--------------------  
    }  
    @AuraEnabled
    public static Customer_Type_Configuration_AGN__c getCustTypeConfigDetails(){
        
        contact con = AGN_OAMPortalAccountDetailController.getContactDetails();
        string CountryCode = '';
        if(!string.isEmpty(con.Account.SAP_Country_Code_AGN__c) && con.Account.Country_Code__c != 'IT'){
            CountryCode = con.Account.SAP_Country_Code_AGN__c;
            if(CountryCode.equalsIgnoreCase('AU')){
                CountryCode = 'AN';
            }  
        }else{
            CountryCode = con.Account.Country_Code__c;
        }
        
       Customer_Type_Configuration_AGN__c ctypeConfig = AGN_OAMPortalAccountDetailController.getCustomertypeConfigDetails(CountryCode, con.Account.SAP_Customer_Group_AGN__c, con.Account.Customer_Category_AGN__c, con.Account.Customer_Sub_Category_AGN__c); 
        /*Customer_Type_Configuration_AGN__c ctypeConfig = [SELECT ID, Category_AGN__c,
                                                                      Category_Label_AGN__c,
                                                                      Country_Code_AGN__c,
                                                                      Customer_Country_AGN__r.Alpha_2_Code_vod__c,
                                                                      Customer_Group_AGN__c,
                                                                      Sub_Category_Label_AGN__c,                                                          
                                                                      Sub_Category__c,
                                                                      Specialty_Allergan_AGN__c,
                                                                      Sub_Specialty_Allergan_AGN__c,
                                                                      FROM Customer_Type_Configuration_AGN__c
                                                                      WHERE Customer_Group_AGN__c =: con.Account.SAP_Customer_Group_AGN__c 
                                                                      AND Customer_Country_AGN__r.Alpha_2_Code_vod__c =: CountryCode
                                                                      AND Category_AGN__c =: con.Account.Customer_Category_AGN__c
                                                                      AND Sub_Category__c =: con.Account.Customer_Sub_Category_AGN__c
                                                                      AND Applicable_For_Online_Registration_AGN__c = true
                                                                      LIMIT 1];  */  
        
        return ctypeConfig;        
        
    }
    
     @AuraEnabled 
    public static string getDocument(string type, string CustomerGroup){
        String communityBaseURL = AGN_OAMConstant.COMMUNITY_BASE_URL+AGN_OAMConstant.COMMUNITY_SUFFIX; 
        list<Document> docId;
        
        system.debug('Label.AGN_OAM_ShipTo_License_Doc>>>>>>'+Label.AGN_OAM_ShipTo_License_Doc);
        if(type =='Sold To' ){
            if(CustomerGroup=='PH'||CustomerGroup=='P2'||CustomerGroup=='P3'){
              docId =  [SELECT Id FROM Document WHERE Name =: Label.AGN_OAM_Account_Owner_SigDoc_Pharmacy];  
            }else{
              docId =  [SELECT Id FROM Document WHERE Name =: Label.AGN_OAM_Account_Owner_SigDoc];
            }
              
        }else if(type == 'Ship To'){
            docId =  [SELECT Id FROM Document WHERE Name =: Label.AGN_OAM_ShipTo_License_Doc]; 
        }  
        if(docId.size()>0){
            return communityBaseURL+'/servlet/servlet.FileDownload?file='+docId[0].Id;  
        }else{return null;}
        
    }
    
    @AuraEnabled
    public static Map<String , List<AGN_CommunityDependentLayout__mdt>> getDependantLayout(String country) {
        
        return AGN_OAMPortalCustomerRegUtils.getDependantFieldSettings(country); 
    }
    
      @AuraEnabled
    public static String[] getValidAddress(Allergan_Customer_Address_AGN__c customerAddress , String country){
        system.debug('Address Validation>>>>>>>>>>>>>>>>>>'+customerAddress+country); 
        List<String> address = new List<String>();
        try{
            if(customerAddress != null && String.isNotBlank(country)){
                system.debug('customerAddress>>>>>>>>>>>>>>>>>>>>>'+customerAddress);
                String state = '';
                if(String.isNotBlank(customerAddress.State_AGN__c)){
                   String selectedState = customerAddress.State_AGN__c;
                    if(country == 'AN' && selectedState.contains('AN-')){
                        state =  selectedState.substringAfter('AN-');
                    }else if(country == 'NZ' && selectedState.contains('NZ-')){
                        if(selectedState == 'NZ-Northland'){
                            state =   'WHANGAREI';
                        }     
                        else if(selectedState == 'NZ-Auckland'){
                            state =   'AUCKLAND';
                        }else if(selectedState == 'AN-South Australia'){
                            state =   'HAMILTON';
                        }else if(selectedState == 'NZ-Bay of Plenty'){
                            state =   'WHAKATANE';
                        }else if(selectedState == 'NZ-Gisborne'){
                            state =   'GISBORNE';
                        }else if(selectedState.contains('NZ-Hawke')){
                            state =   'NAPIER';
                        }else if(selectedState == 'NZ-Taranaki'){
                            state =   'STRATFORD';
                        }else if(selectedState == 'NZ-Manawatu-Wanganui'){
                            state =   'PALMERSTON NORTH';
                        }else if(selectedState == 'NZ-Manawatu-Wanganui'){
                            state =   'WHANGANUI';
                        }else if(selectedState == 'NZ-Wellington'){
                            state =   'WELLINGTON';
                        }else if(selectedState == 'NZ-Tasman'){
                            state =   'RICHMOND';
                        }else if(selectedState == 'NZ-Nelson'){
                            state =   'NELSON';
                        }else if(selectedState == 'NZ-Marlborough'){
                            state =  'BLENHEIM';
                        }else if(selectedState == 'NZ-West Coast'){
                            state =   'GREYMOUTH';
                        }else if(selectedState == 'NZ-Canterbury'){
                            state =   'CHRISTCHURCH';
                        }else if(selectedState == 'NZ-Otago'){
                            state =   'DUNEDIN';
                        }else if(selectedState == 'NZ-Southland'){
                            state =   'INVERCARGILL';
                        }
                        //state =  selectedState.substringAfter('NZ-');
                    }
                }
                 String addressInput = customerAddress.Address_Line_2_AGN__c + ' ' +customerAddress.Address_Line_1_AGN__c +' '+ /*customerAddress.City_AGN__c +' '+ state +' '+*/ customerAddress.Zip_AGN__c;
                system.debug('addressInput>>>>>>>>>>>>>>>>>>>'+addressInput);
                address = AGN_LoqateAddressLookupController.getValidAddresses(addressInput , country);
            }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
            
        }
        return address;
    }
    
    @AuraEnabled
    public static String[] getValidAddressCA(Allergan_Customer_Address_AGN__c customerAddress , String province){
        system.debug('Address Validation>>>>>>>>>>>>>>>>>>'+customerAddress+province);
        List<String> address = new List<String>();
        try{
            if(customerAddress != null && String.isNotBlank(province)){
                String addressInput = '';
                if(String.isNotBlank(customerAddress.Suite_AGN__c)){
                    addressInput = customerAddress.Suite_AGN__c +' '+customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.Zip_AGN__c;
                }else{
                    addressInput = customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.Zip_AGN__c;
                }
                system.debug('addressInput>>>>>>>>>>>>>>>>>>>'+addressInput);
                //address = AGN_LoqateAddressLookupController.getValidAddresses(addressInput , '');
                address = AGN_LoqateAddressLookupController.getFullValidAddresses(addressInput , '');
            }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
            
        }
        return address;
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
    
}