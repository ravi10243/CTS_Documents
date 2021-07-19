public without sharing class AGN_OAMCustomerRegStep2Controller {
    
    @AuraEnabled
    public static User getUserDetail() {
        User usr = 
            [SELECT Id,Name,Profile.Name,SmallPhotoUrl,Country_Code__c
                FROM User WHERE Id= :UserInfo.getUserId()];
        return usr;
    }
    
    @AuraEnabled
    public static String getCustomerGroup(String customerType , String customerSubType) {
        Account acc =  getAccountHeaderDetails();
        String customerGroup = '';
        
        if(String.isNotBlank(acc.Country_Code__c)){
            List<Customer_Type_Configuration_AGN__c> configs = new List<Customer_Type_Configuration_AGN__c>([SELECT Id,Customer_Group_AGN__c 
                                                                                                             FROM Customer_Type_Configuration_AGN__c 
                                                                                                             WHERE Category_Label_AGN__c =: customerType 
                                                                                                             AND Sub_Category_Label_AGN__c =: customerSubType 
                                                                                                             AND Country_Code_AGN__c =: acc.Country_Code__c]);
            if(configs.size() > 0 && String.isNotBlank(configs.get(0).Customer_Group_AGN__c)){
                customerGroup = configs.get(0).Customer_Group_AGN__c;
            }
        }
        return customerGroup;
    }
        
    @AuraEnabled
    public static Account getAccountHeaderDetails() {
        /*User uInfo = [SELECT Id, ContactId from User where Id =: UserInfo.getUserId() limit 1];
        Account acc = [SELECT Id,                       
                        Type_AGN__c,
                        Customer_Category_AGN__c,
                        Customer_Sub_Category_AGN__c,
                        Country_Code__c,
                        Primary_Parent_vod__c,
                       	Registered_For_Clinic_Locator_AGN__c,
						IsICLEnabled_AGN__c,
                        Primary_Parent_vod__r.Type_AGN__c,
                        Primary_Parent_vod__r.Country_Code__c,
						Primary_Parent_vod__r.Customer_Category_AGN__c,
						Primary_Parent_vod__r.Customer_Sub_Category_AGN__c,
						Primary_Parent_vod__r.IsICLEnabled_AGN__c,
                        Primary_Parent_vod__r.Registered_For_Clinic_Locator_AGN__c
                FROM Account WHERE PersonContactId  =: uInfo.ContactId limit 1]; */
        User uInfo = [SELECT Id, ContactId,AccountID,Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        String personContactId = '';         
        if(uInfo.Country_Code__c == 'BR'){
        	AccountContactRelation acr= [SELECT Id,ContactId,AccountID,Account.PersonContactId FROM AccountContactRelation WHERE ContactId =:uInfo.ContactId AND Account.Primary_Parent_vod__c =:uInfo.AccountId LIMIT 1];
        	personContactId = acr.Account.PersonContactId;
		}else{
			personContactId = uInfo.ContactId;
		}
		Account acc = [SELECT Id,                       
                        Type_AGN__c,
						Country_Code__c,
                        Customer_Category_AGN__c,
                        Customer_Sub_Category_AGN__c,						
						Registered_For_Clinic_Locator_AGN__c,
						IsICLEnabled_AGN__c,
                        Primary_Parent_vod__r.Type_AGN__c,
                        Primary_Parent_vod__r.Country_Code__c,
						Primary_Parent_vod__r.Customer_Category_AGN__c,
						Primary_Parent_vod__r.Customer_Sub_Category_AGN__c,
						Primary_Parent_vod__r.IsICLEnabled_AGN__c,
                        Primary_Parent_vod__r.Registered_For_Clinic_Locator_AGN__c 
                FROM Account WHERE PersonContactId  =: personContactId limit 1]; 
        system.debug('acc-->'+acc.Customer_Sub_Category_AGN__c+' '+acc.Primary_Parent_vod__r.IsICLEnabled_AGN__c);       
        return acc;
    } 
    
    /*      For Es Start */
    @AuraEnabled
    Public static List<Customer_Type_Configuration_AGN__c> customerTypeConfig(String CustomerType, string CustomerSubType) {
      
      List<Customer_Type_Configuration_AGN__c> configList = new List<Customer_Type_Configuration_AGN__c>();
        
        Map<string, list<String>> linkedCGmap = new  Map<string, list<String>>();
        
        list<String> CGList = new list<String>();
        
        
        Customer_Type_Configuration_AGN__c  config = [SELECT Customer_Group_AGN__c FROM Customer_Type_Configuration_AGN__c 
                                                      WHERE Country_Code_AGN__c=:AGN_OAMConstant.USERCOUNTRYCODE AND 
                                                      Applicable_For_Online_Registration_AGN__c = True AND 
                                                      Category_AGN__c =:CustomerType AND Sub_Category__c =:CustomerSubType];      
        if(config.Customer_Group_AGN__c == 'PH'){
            CGList.add('PH');
            CGList.add('CL');
            linkedCGmap.put('PH',CGList);
        }else if(config.Customer_Group_AGN__c == 'HR'){
            CGList.add('HR');
            CGList.add('CL');
            linkedCGmap.put('HR',CGList);
        }else if(config.Customer_Group_AGN__c == 'VP'){
            CGList.add('VP');
            CGList.add('VC');
            linkedCGmap.put('VP',CGList);
        }else if(config.Customer_Group_AGN__c == 'CL'){
            CGList.add('CL');
            CGList.add('HR');
            linkedCGmap.put('CL',CGList);
        }else if(config.Customer_Group_AGN__c == 'GP'){
            CGList.add('CL');
            CGList.add('HR');
            CGList.add('GP');
            linkedCGmap.put('GP',CGList);
        }else if(config.Customer_Group_AGN__c == 'PF'){
            CGList.add('PF');
            linkedCGmap.put('PF',CGList);
        }else if(config.Customer_Group_AGN__c == 'OW'){
            CGList.add('OW');
            linkedCGmap.put('OW',CGList);
        }else if(config.Customer_Group_AGN__c == 'OP'){
            CGList.add('OP');
            linkedCGmap.put('OP',CGList);
        }else if(config.Customer_Group_AGN__c == 'FW'){
            CGList.add('FW');
            linkedCGmap.put('FW',CGList);
        }       
        
        if(linkedCGmap.containsKey(config.Customer_Group_AGN__c)){
            configList =  [SELECT Account_Record_Type_AGN__c,
                                    Category_AGN__c,
                                    Country_Code_AGN__c,
                                    Customer_Group_AGN__c,
                                    Sub_Category__c,
                                    Specialty_Allergan_AGN__c,
                                    Sub_Specialty_Allergan_AGN__c,
                                    Category_Label_AGN__c,
                                    Sub_Category_Label_AGN__c                       
                                    FROM Customer_Type_Configuration_AGN__c WHERE Country_Code_AGN__c=:AGN_OAMConstant.USERCOUNTRYCODE AND Applicable_For_Online_Registration_AGN__c = True AND Customer_Group_AGN__c IN : linkedCGmap.get(config.Customer_Group_AGN__c)];
        
        }
        return configList;
    }
    
    /*  For Es End    */
     
    @AuraEnabled
    public static AGN_GCSP_Settings__c getGCSPSettingsDetails() {
                User uInfo = [SELECT Id, Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        AGN_GCSP_Settings__c gcspset = AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c);
        return gcspset;
    }
    
    @AuraEnabled
    public static Allergan_Customer_Registration_AGN__c getCustomerRegDetails() {
       // User uInfo = [SELECT Id, ContactId from User where Id =: UserInfo.getUserId() limit 1];
        Account acc = getAccountHeaderDetails();  
        
        Allergan_Customer_Registration_AGN__c custReg = [SELECT Id, Account_AGN__c,        
                                                                Case_AGN__c,
                                                                Country_AGN__c,
                                                                Country_AGN__r.AGN_Country_Name__c,
                                                                Country_Code_AGN__c,
                                                                Customer_Category_AGN__c,
                                                                Customer_Group_AGN__c,
                                                                Customer_Sub_Category_AGN__c,
                                                                SAP_Country_Code_AGN__c,
                                                                Online_Registration_Step_AGN__c,
                                                                Registration_License_Number_AGN__c,
                                                                Physician_Registration_Reference_AGN__c,
                                                                Specialty_Allergan_1_AGN__c,                                                                
                                                                Tax_Exempted_AGN__c,
                                                                VAT_AGN__c,
                                                                Salutation_AGN__c,
                                                                First_Name_AGN__c, 
                                                                Form_of_Payment_AGN__c,
                                                                Form_of_Payment_AGN__r.Name,
                                                                Payment_Term_AGN__c,
                                                                Payment_Term_AGN__r.Name,                       
                                                                Last_Name_AGN__c,
                                                                Consent_For_Communication_AGN__c,
                                                                toLabel(Province_AGN__c),
                                                                Language_AGN__c
                                                                FROM Allergan_Customer_Registration_AGN__c WHERE Account_AGN__c =: acc.Id LIMIT 1];  
                                                                
             return custReg;             
            
    } 
    
    
     @AuraEnabled
     public static List<Allergan_Customer_Address_AGN__c> getCustomerAddressDetails() {
     
         Allergan_Customer_Registration_AGN__c custReg = getCustomerRegDetails();
         
         List<Allergan_Customer_Address_AGN__c> custAdd = [SELECT Id, Country_Lookup_AGN__c,
                                                                  Account_Type_AGN__c,
                                                                  House_Number_AGN__c,
                                                                  Street_Name_AGN__c,
                                                                  Address_Line_1_AGN__c,
                                                                  Additional_Comments_AGN__c,
                                                                  City_AGN__c,
                                                                  Company_Name_AGN__c,
                                                                  Department_Name_AGN__c,
                                                                  Country_AGN__c,
                                                                  Country_Code_AGN__c,
                                                                  Email_AGN__c,
                                                                  Phone_AGN__c,                                     
                                                                  Parent_AGN__c,
                                                                  Parent_AGN__r.First_Name_AGN__c,
                                                                  Parent_AGN__r.Last_Name_AGN__c,
                                                                  Zip_AGN__c,
                                                                  Is_Registred_Home_Address_AGN__c,
                                                                  License_Number_US_AGN__c,
                                                                  State_Name_AGN__c,
                                                                  US_State_AGN__c,
                                                                  Buying_Group_Name_AGN__c,
                                                                  Member_Account_Number_AGN__c,
                                                                  US_License_HCP_AGN__c,
                                                                  Suite_AGN__c,
                                                                  Doctors_Email_AGN__c,
                                                                  Doctors_First_Name_AGN__c,
                                                                  Doctors_Last_Name_AGN__c,
                                                                  Ship_To_AGN__c,
                                                                  Sold_To_AGN__c,
                                                                  Bill_To_AGN__c,
                                                                  State_AGN__c,
                                                                  Province_AGN__c,
                                                                  RecordTypeId,
                                                                  Sort_Code_AGN__c,
                                                                  SWIFT_BIC_AGN__c,
                                                                  Bank_Name_AGN__c,                            
                                                                  Bank_Account_Number_AGN__c,
                                                                  IBAN_AGN__c,
                                                                 IBAN_Text_AGN__c,
                                                                  Mapping_1_AGN__c,
                                                                  Mapping_2_AGN__c,
                                                                  Website_Link_AGN__c,
                                                                  State_License_Number_AGN__c,
                                                                  Contract_Number_AGN__c,
                                                                  Distribution_ID_AGN__c,
                                                                  Sub_Type_AGN__c,
                                                                  VAT_Number_AGN__c,
                                                                  Apart_Buying_Group_AGN__c,
                                                                  Tax_Number_AGN__c,
                                                                  Service_code_AGN__c,
                                                                  Primary_Physician_Email_AGN__c,
                                                                  Primary_Physician_Name_AGN__c,
                                                                  Primary_Physician_Phone_AGN__c,
                                                                  Pharmacy_License_Number_AGN__c,
                                                                  Is_Verified_Address__c
                                                           FROM Allergan_Customer_Address_AGN__c WHERE Parent_AGN__c =: custReg.Id ORDER BY createdDate DESC];     
     return custAdd;
     } 
     
     @AuraEnabled
     public static string getSpecialityDetails() {
     
       Allergan_Customer_Registration_AGN__c custReg = getCustomerRegDetails();
     
      if(custReg.Specialty_Allergan_1_AGN__c != null){
       
        Specialty_Allergan_AGN__c spe = [SELECT Translated_Value_AGN__c From Specialty_Allergan_AGN__c WHERE ID =: custReg.Specialty_Allergan_1_AGN__c]; 
         return spe.Translated_Value_AGN__c;      
      }
       else{ return null;}      
     
     }

     
     @AuraEnabled
     public static Customer_Type_Configuration_AGN__c getCustomertypeConfigDetails(){
     
         Allergan_Customer_Registration_AGN__c custReg = getCustomerRegDetails();
         
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
                WHERE Country_Code_AGN__c =:custReg.Country_Code_AGN__c 
                AND Customer_Group_AGN__c =:custReg.Customer_Group_AGN__c 
                //AND Category_AGN__c =:custReg.Customer_Category_AGN__c 
                //AND Sub_Category__c =:custReg.Customer_Sub_Category_AGN__c 
                AND Applicable_For_Online_Registration_AGN__c = true limit 1];
     
     }
        
    @AuraEnabled
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo) {
        
        return AGN_OAMCustomerRegUtils.getLayoutCountrySetting(country, stepNo, null, null, null);
    }
    
    @AuraEnabled
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo, String customerType, String customerSubType) {
        
        return AGN_OAMCustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, null);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo, String customerType, String customerSubType, List<Customer_Type_Configuration_AGN__c> custTypeConfig) {
        
        return AGN_OAMCustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, custTypeConfig);
    }

    
    @AuraEnabled
    public static boolean isDuplicateUser(String email){
        return AGN_OAMCustomerRegUtils.checkForDuplicateCustomer(email);
    }

    @AuraEnabled
    public static Id upsertAddressDetails(Allergan_Customer_Address_AGN__c soldToAddr, 
                                          List<Allergan_Customer_Address_AGN__c> billToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> shipToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> newBillToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> newShipToAddrList)
    {
        
        try{
            
            return AGN_OAMCustomerRegUtils.upsertAddressDetails(soldToAddr, billToAddrList, shipToAddrList, newBillToAddrList, newShipToAddrList);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }     
    
    @AuraEnabled(cacheable=true)
    public static Boolean updateAddressDetails(List<Allergan_Customer_Address_AGN__c> records)
    {
        
        try{
            
            return AGN_OAMCustomerRegUtils.updateAddressDetails(records);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    } 
    
    @AuraEnabled
    public static Id upsertCustomerDetails(Allergan_Customer_Registration_AGN__c customer,Allergan_Customer_Address_AGN__c customerAddress, String Specialty)
    {
        
        try{
            
          return AGN_OAMCustomerRegUtils.upsertCustomerDetails(customer,customerAddress,Specialty);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    } 
    
   @AuraEnabled
    public static ID finishRegistration(Allergan_Customer_Registration_AGN__c cust,  Allergan_Customer_Address_AGN__c custAddress, String formofPayment, String PaymentTerm)        
    {
        system.debug('customerReg ravi--->'+formofPayment); 
        system.debug('customerAdd ravi--->'+PaymentTerm);
         try{
            return AGN_OAMCustomerRegUtils.finishCustomerRegistration_finalStep(cust, custAddress, formofPayment, PaymentTerm); 

        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        } 
       
    } 
    
    @AuraEnabled
    public static List<sObject> getPickListValues(string objectName,String columnName,String columnId, String whereCondition){
        String wherecond = whereCondition != null ? String.valueOf(whereCondition) : '';
        String query = 'select '+String.valueOf(columnName)+','+String.valueOf(columnId)+' From '+objectName + wherecond;
        system.debug('@@@@query@@@'+ query);
        List<sObject> PicklistValues = Database.query(query);
        return PicklistValues;         
    }
    
    @AuraEnabled
    public static void deleteAddress(Allergan_Customer_Address_AGN__c customerAddress){
        
        try{
            AGN_OAMCustomerRegUtils.deleteAddress(customerAddress);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static Sobject FetchObjectDetails(){    
       
     Sobject objCust = getCustomerRegDetails();  
                                                               
       
     Sobject objAdd = [SELECT Id, Parent_AGN__c, Parent_AGN__r.Registration_License_Number_AGN__c,
                                                                Parent_AGN__r.Specialty_Allergan_1_AGN__c,                                                                
                                                                Parent_AGN__r.Tax_Exempted_AGN__c,
                                                                Parent_AGN__r.Salutation_AGN__c,
                                                                Parent_AGN__r.First_Name_AGN__c,     
                                                                Country_Lookup_AGN__c, Account_Type_AGN__c,
                                                              House_Number_AGN__c,
                                                              Street_Name_AGN__c,
                                                              Address_Line_1_AGN__c,
                                                              Additional_Comments_AGN__c,
                                                              City_AGN__c,
                                                              Company_Name_AGN__c,
                                                              Department_Name_AGN__c,
                                                              Country_AGN__c,
                                                              Country_Code_AGN__c,
                                                              Email_AGN__c,
                                                              Phone_AGN__c,                                                             
                                                              Zip_AGN__c,
                                                              Ship_To_AGN__c,
                                                              Sold_To_AGN__c,
                                                              Bill_To_AGN__c,
                                                              State_AGN__c,
                                                              RecordTypeId,
                                                              Sort_Code_AGN__c,
                                                              SWIFT_BIC_AGN__c,
                                                              Bank_Name_AGN__c,
                                                              Bank_Account_Number_AGN__c,
                                                              IBAN_AGN__c,
                                                              IBAN_Text_AGN__c,
                                                              Sub_Type_AGN__c FROM Allergan_Customer_Address_AGN__c 
                                                              WHERE Parent_AGN__c =: objCust.Id AND Sold_To_AGN__c = True LIMIT 1]; 
                                                              
                 
       return objAdd;
    }
    
    @AuraEnabled
    public static Map<String , List<AGN_CommunityDependentLayout__mdt>> getDependantLayout(String country) {
        
        return AGN_OAMCustomerRegUtils.getDependantFieldSettings(country); 
}

    @AuraEnabled
    public static Boolean isExistingAddress(Allergan_Customer_Address_AGN__c customerAddress){
        Boolean isExisting = false;
        try{
            system.debug('customerAddress>>>>>>>>>>>>>>>>>>>>>>>'+customerAddress);
            
            if(customerAddress != null){
                String addressInput = customerAddress.Suite_AGN__c +' '+ customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.City_AGN__c +' '+ customerAddress.Zip_AGN__c;
                system.debug('addressInput>>>>>>>>>>>>>>>>>>>'+addressInput);
                isExisting = AGN_LoqateAddressLookupController.getSearchResults(addressInput , '');
            }
        }
        catch (Exception e) {
            isExisting = false;
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
            
        }
        return isExisting;
    }
    
    @AuraEnabled
    public static String[] getValidAddress(Allergan_Customer_Address_AGN__c customerAddress , String province){
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
                address = AGN_LoqateAddressLookupController.getValidAddresses(addressInput , '');
            }
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
            
        }
        return address;
    }
    
}