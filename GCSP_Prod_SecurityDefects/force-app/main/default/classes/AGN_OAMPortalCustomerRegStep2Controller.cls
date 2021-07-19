public without sharing class AGN_OAMPortalCustomerRegStep2Controller {
    
    @AuraEnabled
    public static User getUserDetail() {
        User usr = 
            [SELECT Id,Name,Profile.Name,SmallPhotoUrl,Country_Code__c
             FROM User WHERE Id= :UserInfo.getUserId()];
        return usr;
    }  
    
    @AuraEnabled
    public static String getCustomerGroup(String customerType , String customerSubType) {
        
        User uInfo = [SELECT Id, ContactId,AccountID,Account.Country_Code__c, Account.SAP_Country_Code_AGN__c from User where Id =: UserInfo.getUserId() limit 1];
        
        String customerGroup = ''; 
        String countryCode = '';
        if(String.isNotBlank(uInfo.Account.SAP_Country_Code_AGN__c) && !uInfo.Account.Country_Code__c.equalsIgnoreCase('IT')){
            countryCode = uInfo.Account.SAP_Country_Code_AGN__c;
            if(countryCode.equalsIgnoreCase('AU') ){
                countryCode = 'AN';
            }
        }else{
            countryCode = uInfo.Account.Country_Code__c;
        }      
        
        if(String.isNotBlank(countryCode)){
            List<Customer_Type_Configuration_AGN__c> configs = new List<Customer_Type_Configuration_AGN__c>([SELECT Id,Customer_Group_AGN__c 
                                                                                                             FROM Customer_Type_Configuration_AGN__c 
                                                                                                             WHERE Category_Label_AGN__c =: customerType 
                                                                                                             AND Sub_Category_Label_AGN__c =: customerSubType 
                                                                                                             AND Customer_Country_AGN__r.Alpha_2_Code_vod__c =: countryCode]);
            if(configs.size() > 0 && String.isNotBlank(configs.get(0).Customer_Group_AGN__c)){
                customerGroup = configs.get(0).Customer_Group_AGN__c;
            }
        }
        return customerGroup;
    }
    
    /* @AuraEnabled
        public static Account getAccountHeaderDetails() {       
        User uInfo = [SELECT Id, ContactId,AccountID,Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        String personContactId = '';        
        
        list<AccountContactRelation> acrList= [SELECT Id,ContactId,AccountID,Account.PersonContactId FROM AccountContactRelation WHERE ContactId =:uInfo.ContactId AND Account.Primary_Parent_vod__c =:uInfo.AccountId LIMIT 1];
        personContactId = acrList[0].Account.PersonContactId;        
        
        Account acc = new Account();
        if(!string.isEmpty(personContactId)){
        acc = [SELECT Id,                       
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
        }
        else{
        acc = [SELECT Id,                       
        Type_AGN__c,
        Customer_Category_AGN__c,
        Customer_Sub_Category_AGN__c,
        SAP_Country_Code_AGN__c, Registered_For_Clinic_Locator_AGN__c, IsICLEnabled_AGN__c 
        FROM Account WHERE Id  =: uInfo.AccountId]; 
        system.debug('SoldToAcc-->'+acc.Customer_Sub_Category_AGN__c+' -- '+acc.IsICLEnabled_AGN__c); 
        }       
        return acc;
        } */
    
    @AuraEnabled
    public static Contact getContactDetails() {
        User uInfo = [SELECT Id, ContactId from User where Id =: UserInfo.getUserId() limit 1];
        Contact con = [SELECT Id, 
                       Customer_Managed_AGN__c,
                       Country_Code__c,
                       Customer_Registration_AGN__c,
                       SAP_Country_Code_AGN__c
                       FROM Contact WHERE Id  =: uInfo.ContactId limit 1]; 
        return con;
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
    public static AGN_GCSP_Settings__c getGCSPSettingsDetails() {
        User uInfo = [SELECT Id, Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        AGN_GCSP_Settings__c gcspset = AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c);
        return gcspset;
    }
    
    /*
* @description Returns customer registration data 
* @param NIL
* @return returns Allergan Customer Registration
* @createdby GCSP Developer Team
* @modifieddate 05-Sept-2019
*/
    
    @AuraEnabled
    public static Allergan_Customer_Registration_AGN__c getCustomerRegDetails() {
        User uInfo = [SELECT Id, ContactId from User where Id =: UserInfo.getUserId() limit 1];
        //Contact con = getContactDetails();        
        Allergan_Customer_Contact_AGN__c customerContact = [SELECT Id,Parent_AGN__c,Contact_AGN__c,Contact_Person_Type_AGN__c FROM Allergan_Customer_Contact_AGN__c WHERE Contact_AGN__c =: uInfo.ContactId];
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
        
    } 
    
    /*
* @description Returns customer address data 
* @param custRegId
* @return returns list of Allergan Customer Address 
* @createdby GCSP Developer Team
* @modifieddate 05-Sept-2019
*/
    
    @AuraEnabled
    public static List<Allergan_Customer_Address_AGN__c> getCustomerAddressDetails(String custRegId) {
        
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
    }
    
    /*
* @description Returns Specialty Name data 
* @param null
* @return returns Specialty 
* @createdby GCSP Developer Team
* @modifieddate 05-Sept-2019
*/
    
    @AuraEnabled
    public static string getSpecialityDetails() {
        
        Allergan_Customer_Registration_AGN__c custReg = getCustomerRegDetails();
        
        if(custReg.Specialty_Allergan_1_AGN__c != null){
            
            Specialty_Allergan_AGN__c spe = [SELECT Translated_Value_AGN__c From Specialty_Allergan_AGN__c WHERE ID =: custReg.Specialty_Allergan_1_AGN__c]; 
            return spe.Translated_Value_AGN__c;      
        }
        else{ return null;}      
        
    }
    
    /*
* @description Returns Customer Type Configuration data 
* @param null
* @return returns Customer Type Configuration 
* @createdby GCSP Developer Team
* @modifieddate 05-Sept-2019
*/
    
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
                WHERE Customer_Country_AGN__r.Alpha_2_Code_vod__c =:custReg.Country_Code_AGN__c 
                AND Customer_Group_AGN__c =:custReg.Customer_Group_AGN__c 
                AND Category_AGN__c =:custReg.Customer_Category_AGN__c 
                AND Sub_Category__c =:custReg.Customer_Sub_Category_AGN__c 
                AND Applicable_For_Online_Registration_AGN__c = true limit 1];        
        
        
    }
    
    
    @AuraEnabled
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo) {
        
        return AGN_OAMPortalCustomerRegUtils.getLayoutCountrySetting(country, stepNo, null, null, null);
    }
    
    @AuraEnabled
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo, String customerType, String customerSubType) {
        
        return AGN_OAMPortalCustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, null);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo, String customerType, String customerSubType, List<Customer_Type_Configuration_AGN__c> custTypeConfig) {
        
        return AGN_OAMPortalCustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, custTypeConfig);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Portal_Community_Layout_Setting__mdt>> getPortalLayout(String country, String stepNo, String customerType, String customerSubType) {
        
        return AGN_OAMPortalCustomerRegUtils.getPortalLayoutCountrySetting(country, stepNo, customerType, customerSubType);
    }
    
    @AuraEnabled
    public static boolean isDuplicateUser(String email){
        return AGN_OAMPortalCustomerRegUtils.checkForDuplicateCustomer(email);
    }
    
    @AuraEnabled
    public static Id upsertAddressDetails(Allergan_Customer_Address_AGN__c soldToAddr, 
                                          List<Allergan_Customer_Address_AGN__c> billToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> shipToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> newBillToAddrList,
                                          List<Allergan_Customer_Address_AGN__c> newShipToAddrList)
    {
        
        try{
            
            return AGN_OAMPortalCustomerRegUtils.upsertAddressDetails(soldToAddr, billToAddrList, shipToAddrList, newBillToAddrList, newShipToAddrList);
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
            
            return AGN_OAMPortalCustomerRegUtils.updateAddressDetails(records);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }  
    
    @AuraEnabled
    public static List<sObject> getPickListValues(string objectName,String columnName,String columnId, String whereCondition){
        String wherecond = whereCondition != null ? String.valueOf(whereCondition) : '';
        String query = 'select '+String.escapeSingleQuotes(String.valueOf(columnName))+','+String.escapeSingleQuotes(String.valueOf(columnId))+' From '+String.escapeSingleQuotes(objectName) + wherecond;
        system.debug('@@@@query@@@'+ query);
        List<sObject> PicklistValues = Database.query(query);
        return PicklistValues;         
    }
    
    @AuraEnabled
    public static void deleteAddress(Allergan_Customer_Address_AGN__c customerAddress){
        
        try{
            AGN_OAMPortalCustomerRegUtils.deleteAddress(customerAddress);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static Allergan_Customer_Address_AGN__c FetchObjectDetails(){    
        
        Sobject objCust = getCustomerRegDetails();  
        
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
        query = 'select ' + commaSepratedFields + ' from ' + SobjectApiName + ' WHERE Parent_AGN__c ='+'\''+ objCust.Id+ '\'' + 'AND Sold_To_AGN__c = True Limit 1';
        
        Allergan_Customer_Address_AGN__c objAdd = Database.query(query);     
        
        return objAdd;
    }
    
    @AuraEnabled
    public static Map<String , List<AGN_CommunityDependentLayout__mdt>> getDependantLayout(String country) {
        
        return AGN_OAMPortalCustomerRegUtils.getDependantFieldSettings(country); 
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
    
    /* @AuraEnabled
public static Id upsertCustomerDetails(Allergan_Customer_Registration_AGN__c customer,Allergan_Customer_Address_AGN__c customerAddress)
{

try{ 
return AGN_OAMPortalCustomerRegUtils.upsertCustomerDetails(customer,customerAddress); 
}
catch (Exception e) {
// "Convert" the exception into an AuraHandledException
throw new AuraHandledException(e.getMessage()); 
}
} */
    
    @AuraEnabled
    public static Id upsertCustomerDetails(Allergan_Customer_Registration_AGN__c customer,Allergan_Customer_Address_AGN__c customerAddress, string Specialty)
    {
        
        try{ 
            return AGN_OAMPortalCustomerRegUtils.upsertCustomerDetails(customer,customerAddress,Specialty); 
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
            return AGN_OAMPortalCustomerRegUtils.finishCustomerRegistration_finalStep(cust, custAddress, formofPayment, PaymentTerm); 
            
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        } 
        
    }
    
    @AuraEnabled
    public static Boolean isLoqateEnabled(String country){
        return (Boolean)AGN_GCSP_Settings__c.getValues(country).get('Address_Verification_Service_Enabled_AGN__c'); 
    }
    
}