public without sharing class AGN_OAMPortalCustomerRegStep1Controller {
    
    static Boolean showGenericMessage = true;
    
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
    
    @AuraEnabled(cacheable=true)
    public static Map<String , List<AGN_CommunityDependentLayout__mdt>> getDependantLayout(String country) {
        
        return AGN_OAMPortalCustomerRegUtils.getDependantFieldSettings(country);   
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Allergan_Consent_Footer_Info__c> fetchFooterConsents(String pageLang){
        List<Allergan_Consent_Footer_Info__c> footerList = AGN_OAMPortalCustomerRegUtils.getFooterConsents(pageLang);
        return footerList;
    }
    
    @AuraEnabled
    public static String getCustomerGroup(String countryCode, String customerType , String customerSubType) {
        
        /*String customerGroup = '';
        
        if(String.isNotBlank(countryCode)){
            List<Customer_Type_Configuration_AGN__c> configs = new List<Customer_Type_Configuration_AGN__c>([SELECT Id,Customer_Group_AGN__c 
                                                                                                             FROM Customer_Type_Configuration_AGN__c 
                                                                                                             WHERE Customer_Country_AGN__r.Alpha_2_Code_vod__c=:countryCode 
                                                                                                             AND (Category_AGN__c =: customerType OR Category_Label_AGN__c =: customerType ) 
                                                                                                             AND (Sub_Category__c =: customerSubType OR Sub_Category_Label_AGN__c =:customerSubType )]);
            if(configs.size() > 0 && String.isNotBlank(configs.get(0).Customer_Group_AGN__c)){
                customerGroup = configs.get(0).Customer_Group_AGN__c;
            }
        }
        return customerGroup;*/
        
        //Moving to Utillity Class
        
        return AGN_OAMPortalCustomerRegUtils.getCustomerGroup(countryCode, customerType, customerSubType);
    } 
    
    @AuraEnabled
    public static boolean isDuplicateUser(String email){
        return AGN_OAMPortalCustomerRegUtils.checkForDuplicateCustomer(email);
    }
	
	 /*
    * @description Returns account data of Customer Addresss
    * @param soldto customerAddress data
    * @return returns new Business Account 
    * @modifiedby GCSP Development Team
    * @modifieddate 04-September-2019
    */
    
    @AuraEnabled
    public static Account createAccount(Allergan_Customer_Address_AGN__c customerAddress, Allergan_Customer_Registration_AGN__c customer){
        try{
            return AGN_OAMPortalCustomerRegUtils.createAccount(customerAddress, customer);
        }
        catch (Exception e) {
            if(showGenericMessage){
                //getting unique error Id
                String errorId = AGN_OAM_LogService.getRandom(32);
                
                //logging exception
                OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                    ErrorId_AGN__c = errorId,
                    Data_AGN__c = JSON.serialize(customerAddress),
                    MethodName_AGN__c = 'AGN_OAMPortalCustomerRegStep1Controller.createAccount',
                    ExceptionMessage_AGN__c = e.getMessage(),
                    ExceptionType_AGN__c = e.getTypeName(),
                    ExceptionStackTrace_AGN__c = e.getStackTraceString(),
                    RunningUserId_AGN__c = UserInfo.getUserId()
                );
                
                //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
                EventBus.publish(log);
                
                //throw generic message with error Id
                //sample error mesage : An error occurred while processing your request. Error ID : 5039587951-19094-83484-41093-5415399
                throw new AuraHandledException(System.Label.AGN_OAM_CustomerGenericErrorMessage + ' ' + errorId);
            }
            else{
                throw new AuraHandledException(e.getMessage());
            } 
        }
    }
	
	 /*
    * @description Returns contact data of registration
    * @param customer
    * @param acc
    * @return returns new Business Account 
    * @createdby GCSP Development Team
    * @modifieddate 04-September-2019
    */
    
    @AuraEnabled
    public static Contact createContact(Allergan_Customer_Registration_AGN__c customer, Account acc){
        
        system.debug('@@@@acc>>>>>>'+acc);
        try{
            return AGN_OAMPortalCustomerRegUtils.createContact(customer, acc);
        }
        catch (Exception e) {
            if(showGenericMessage){
                //getting unique error Id
                String errorId = AGN_OAM_LogService.getRandom(32);
                
                //logging exception
                OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                    ErrorId_AGN__c = errorId,
                    Data_AGN__c = 'Allergan_Customer_Registration_AGN__c data ---> ' + JSON.serialize(customer) + ' ---- Account data ---> ' + JSON.serialize(acc),
                    MethodName_AGN__c = 'AGN_OAMPortalCustomerRegStep1Controller.createContact',
                    ExceptionMessage_AGN__c = e.getMessage(),
                    ExceptionType_AGN__c = e.getTypeName(),
                    ExceptionStackTrace_AGN__c = e.getStackTraceString(),
                    RunningUserId_AGN__c = UserInfo.getUserId(),
                    Reference_Email_AGN__c = customer.Email_AGN__c
                );
                
                //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
                EventBus.publish(log);
                
                //throw generic message with error Id
                //sample error mesage : An error occurred while processing your request. Error ID : 5039587951-19094-83484-41093-5415399
                throw new AuraHandledException(System.Label.AGN_OAM_CustomerGenericErrorMessage + ' ' + errorId);
            }
            else{
                throw new AuraHandledException(e.getMessage());
            } 
        }
    }
	
	/*
    * @description Returns community user
    * @params customerContactId, countryCode, userLocale
    * @param userLocale
    * @return returns new Community user
    * @modifiedby GCSP Data Quality Project Team
    * @createdby GCSP Development Team
    * @modifieddate 04-September-2019
    */
	
    @AuraEnabled
    public static Id createCommunityUser(Id customerContactId , String countryCode , String userLocale ){
        try{      
            
            return AGN_OAMPortalCustomerRegUtils.createCommunityUser(customerContactId , countryCode, userLocale);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            if(e.getMessage().contains('DUPLICATE_USERNAME')){
                throw new AuraHandledException(Label.AGN_OAM_Apex_DuplicateEmail);
            }else{
                if(showGenericMessage){
                    //getting unique error Id
                    String errorId = AGN_OAM_LogService.getRandom(32);
                    
                    //logging exception
                    OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                        ErrorId_AGN__c = errorId,
                        Data_AGN__c = 'customerContactId ---> ' + customerContactId + ' --- countryCode ---> ' + countryCode,
                        MethodName_AGN__c = 'AGN_OAMPortalCustomerRegStep1Controller.createCommunityUser',
                        ExceptionMessage_AGN__c = e.getMessage(),
                        ExceptionType_AGN__c = e.getTypeName(),
                        ExceptionStackTrace_AGN__c = e.getStackTraceString(),
                        RunningUserId_AGN__c = UserInfo.getUserId()
                    );
                    
                    //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
                    EventBus.publish(log);
                    
                    //throw generic message with error Id
                    //sample error mesage : An error occurred while processing your request. Error ID : 5039587951-19094-83484-41093-5415399
                    throw new AuraHandledException(System.Label.AGN_OAM_CustomerGenericErrorMessage + ' ' + errorId);
                }
                else{
                    throw new AuraHandledException(e.getMessage());
                }
            } 
        }
    }
	 

	
	/*
    * @description Returns community user
    * @params customer,customerAddress,configList,customerContact,userLocale
    * @return returns CaseId 
    * @createdby GCSP Development Team
    * @modifieddate 04-September-2019
    */
    @AuraEnabled
    public static Id createNewCustomerRegistration(Allergan_Customer_Registration_AGN__c customer, 
                                                   Allergan_Customer_Address_AGN__c customerAddress, 
                                                   List<Customer_Type_Configuration_AGN__c> configList,
                                                   Contact customerContact , String userLocale) {
        
        try{
            return AGN_OAMPortalCustomerRegUtils.createNewCustomerRegistration(customer, customerAddress, configList, customerContact, userLocale);
        }
        catch (Exception e) {
            if(showGenericMessage){
                //getting unique error Id
                String errorId = AGN_OAM_LogService.getRandom(32);
                
                //logging exception
                OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                    ErrorId_AGN__c = errorId,
                    Data_AGN__c = 'Allergan_Customer_Registration_AGN__c data ---> ' + JSON.serialize(customer) 
                    + ' ---- Allergan_Customer_Address_AGN__c data ---> ' + JSON.serialize(customerAddress)
                    + ' ---- Contact data ---> ' + JSON.serialize(customerContact),
                    MethodName_AGN__c = 'AGN_OAMPortalCustomerRegStep1Controller.createNewCustomerRegistration',
                    ExceptionMessage_AGN__c = e.getMessage(),
                    ExceptionType_AGN__c = e.getTypeName(),
                    ExceptionStackTrace_AGN__c = e.getStackTraceString(),
                    RunningUserId_AGN__c = UserInfo.getUserId(),
                    Reference_Email_AGN__c = customer.Email_AGN__c
                );
                
                //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
                EventBus.publish(log);
                
                //throw generic message with error Id
                //sample error mesage : An error occurred while processing your request. Error ID : 5039587951-19094-83484-41093-5415399
                throw new AuraHandledException(System.Label.AGN_OAM_CustomerGenericErrorMessage + ' ' + errorId);
            }
            else{
                throw new AuraHandledException(e.getMessage());
            } 
        }
    } 
    
	
	
	/*
    * @description Returns community user
    * @params customer, customerContact, userLocale
    * @return returns new Community User  
    * @createdby GCSP Development Team
    * @modifieddate 04-Septembber-2019
    */
    @AuraEnabled
    public static String createOktaUserSendLink(Allergan_Customer_Registration_AGN__c customer, Contact customerContact, String userLocale)
    {
        
        try{
            return AGN_OAMPortalCustomerRegUtils.createOktaUserSendLink(customer, customerContact, userLocale);
        }
        catch (Exception e) {
            if(showGenericMessage){
                //getting unique error Id
                String errorId = AGN_OAM_LogService.getRandom(32);
                
                //logging exception
                OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                    ErrorId_AGN__c = errorId,
                    Data_AGN__c = 'Allergan_Customer_Registration_AGN__c data ---> ' + JSON.serialize(customer) + ' ---- Contact data ---> ' + JSON.serialize(customerContact),
                    MethodName_AGN__c = 'AGN_OAMPortalCustomerRegStep1Controller.createOktaUserSendLink',
                    ExceptionMessage_AGN__c = e.getMessage(),
                    ExceptionType_AGN__c = e.getTypeName(),
                    ExceptionStackTrace_AGN__c = e.getStackTraceString(),
                    RunningUserId_AGN__c = UserInfo.getUserId(),
                    Reference_Email_AGN__c = customer.Email_AGN__c
                );
                
                //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
                EventBus.publish(log);
                
                //throw generic message with error Id
                //sample error mesage : An error occurred while processing your request. Error ID : 5039587951-19094-83484-41093-5415399
                throw new AuraHandledException(System.Label.AGN_OAM_CustomerGenericErrorMessage + ' ' + errorId);
            }
            else{
                throw new AuraHandledException(e.getMessage());
            } 
        }
    } 
	
	@AuraEnabled(cacheable=true)
    public static List<String> getCummunityURL()
    {
        List<String> strLst = new List<String>();
        strLst.add(AGN_OAMConstant.COMMUNITY_BASE_URL);
        strLst.add(AGN_OAMConstant.COMMUNITY_SUFFIX);
        return strLst;
    }
    
    @AuraEnabled(cacheable=true)
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

	@AuraEnabled
    public static void inactivateUser(Id communityUserId)
    {
        AGN_OAMPortalCustomerRegUtils.inactivateUser(communityUserId);
    }
    
    @AuraEnabled
    public static Boolean isRegistrationCompleted()
    {
        return AGN_OAMPortalCustomerRegUtils.isRegistrationCompleted();
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean hasAllerganDirectAccess()
    {
        User currentUser = [Select Contact.Has_Allergan_Direct_Access_AGN__c from User where Id =: UserInfo.getUserId() limit 1]; 
        if(AGN_OAMConstant.USERCOUNTRYCODE.equalsIgnoreCase('BR') && (currentUser.Contact.Has_Allergan_Direct_Access_AGN__c == false || currentUser.Contact.Has_Allergan_Direct_Access_AGN__c == null)){
           return false;            
        }else{
           return true; 
        }
        
    }
    
    @AuraEnabled
    public static String[] getValidAddressCA(Allergan_Customer_Address_AGN__c customerAddress , String province){
        system.debug('Address Validation>>>>>>>>>>>>>>>>>>'+customerAddress+province);
        List<String> address = new List<String>();
        try{
            if(customerAddress != null && String.isNotBlank(province)){
                //String addressInput = customerAddress.Suite_AGN__c +' '+ customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.City_AGN__c +' '+ province +' '+ customerAddress.Zip_AGN__c;
                system.debug('customerAddress>>>>>>>>>>>>>>>>>>>>>'+customerAddress);
                String addressInput = '';
                if(String.isNotBlank(customerAddress.Suite_AGN__c)){
                    addressInput = customerAddress.Suite_AGN__c +' '+customerAddress.Address_Line_1_AGN__c +' '+ province +' '+ customerAddress.Zip_AGN__c;
                    system.debug('addressInput1>>>>>>>>>>>>>>>>>>>'+addressInput);
                }else{
                    addressInput = customerAddress.Address_Line_1_AGN__c +' '+ province +' '+ customerAddress.Zip_AGN__c;
                    system.debug('addressInput2>>>>>>>>>>>>>>>>>>>'+addressInput);
                }
                //String addressInput = customerAddress.Suite_AGN__c +' '+customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.Zip_AGN__c;
                //String addressInput = customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.Zip_AGN__c;
                
               // address = AGN_LoqateAddressLookupController.getValidAddresses(addressInput , '');
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
    public static String[] getValidAddress(Allergan_Customer_Address_AGN__c customerAddress, String country){
        
        List<String> address = new List<String>();
        try{
            if(customerAddress != null){
                system.debug('customerAddress>>>>>>>>>>>>>>>>>>>>>'+customerAddress);
                String state = '';
                if(String.isNotBlank(customerAddress.State_AGN__c)){
                    String selectedState = customerAddress.State_AGN__c;
                    if(selectedState.contains('AN-')){
                        if(selectedState == 'AN-NSW'){
                            state = 'NSW';
                        }else if(selectedState == 'AN-QLD'){
                            state = 'QLD';
                        }else if(selectedState == 'AN-SA'){
                            state = 'SA';
                        }else if(selectedState == 'AN-TAS'){
                            state = 'TAS';
                        }else if(selectedState == 'AN-VIC'){
                            state = 'VIC';
                        }else if(selectedState == 'AN-WA'){
                            state = 'WA';
                        }else if(selectedState == 'AN-ACT'){
                            state = 'ACT';
                        }else if(selectedState == 'AN-NT'){
                            state = 'NT';
                        }
                    }else if(selectedState.contains('NZ-')){
                        if(selectedState == 'NZ-NTL'){
                            state =   'WHANGAREI';
                        }     
                        else if(selectedState == 'NZ-AUK'){
                            state =   'AUCKLAND';
                        }else if(selectedState == 'NZ-WKO'){
                            state =   'HAMILTON';
                        }else if(selectedState == 'NZ-BOP'){
                            state =   'WHAKATANE';
                        }else if(selectedState == 'NZ-GIS'){
                            state =   'GISBORNE';
                        }else if(selectedState == 'NZ-HKB'){
                            state =   'NAPIER';
                        }else if(selectedState == 'NZ-TKI'){
                            state =   'STRATFORD';
                        }else if(selectedState == 'NZ-MWT'){
                            state =   'PALMERSTON NORTH';
                        }/*else if(selectedState == 'NZ-MWT'){
                    state =   'WHANGANUI';
                    }*/else if(selectedState == 'NZ-WGN'){
                        state =   'WELLINGTON';
                    }else if(selectedState == 'NZ-TAS'){
                        state =   'RICHMOND';
                    }else if(selectedState == 'NZ-NSN'){
                        state =   'NELSON';
                    }else if(selectedState == 'NZ-MHB'){
                        state =  'BLENHEIM';
                    }else if(selectedState == 'NZ-WTC'){
                        state =   'GREYMOUTH';
                    }else if(selectedState == 'NZ-CAN'){
                        state =   'CHRISTCHURCH';
                    }else if(selectedState == 'NZ-OTA'){
                        state =   'DUNEDIN';
                    }else if(selectedState == 'NZ-STL'){
                        state =   'INVERCARGILL';
                    }
                        //state =  selectedState.substringAfter('NZ-');
                    }
                }
                String addressInput = customerAddress.Address_Line_2_AGN__c + ' ' +customerAddress.Address_Line_1_AGN__c +' '+/* customerAddress.City_AGN__c +' '+ state +' '+*/ customerAddress.Zip_AGN__c;
                system.debug('addressInput in country method>>>>>>>>>>>>>>>>>>>'+addressInput);
                address = AGN_LoqateAddressLookupController.getValidAddresses(addressInput , country);
            }
        }
        catch (Exception e) {
            if(showGenericMessage){
                //getting unique error Id
                String errorId = AGN_OAM_LogService.getRandom(32);
                
                //logging exception
                OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                    ErrorId_AGN__c = errorId,
                    Data_AGN__c = 'Allergan_Customer_Address_AGN__c data ---> ' + JSON.serialize(customerAddress) + ' ---- country data ---> ' + country,
                    MethodName_AGN__c = 'AGN_OAMPortalCustomerRegStep1Controller.getValidAddress',
                    ExceptionMessage_AGN__c = e.getMessage(),
                    ExceptionType_AGN__c = e.getTypeName(),
                    ExceptionStackTrace_AGN__c = e.getStackTraceString(),
                    RunningUserId_AGN__c = UserInfo.getUserId()
                );
                
                //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
                EventBus.publish(log);
                
                //throw generic message with error Id
                //sample error mesage : An error occurred while processing your request. Error ID : 5039587951-19094-83484-41093-5415399
                throw new AuraHandledException(System.Label.AGN_OAM_CustomerGenericErrorMessage + ' ' + errorId);
            }
            else{
                throw new AuraHandledException(e.getMessage());
            }
        }
        return address;
    }
    
    @AuraEnabled
    public static PicklistOption[] getPicklistOptions(String ObjectName ,string fieldName) {
        List<PicklistOption> options = new List<PicklistOption>();
        sObject objObject = Schema.getGlobalDescribe().get(ObjectName).newSObject() ;
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values = fieldMap.get(fieldName).getDescribe().getPickListValues();
        PicklistOption option;
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
    @AuraEnabled(cacheable=true)
    public static Boolean isLoqateEnabled(String country){
        return (Boolean)AGN_GCSP_Settings__c.getValues(country).get('Address_Verification_Service_Enabled_AGN__c'); 
    }
    
    //ICL is enable for User's country
    @AuraEnabled(cacheable=true)
    public static ICLInformation isICLEnabled()
    {
        User u = [Select id,name,Country_code__c from User where Id =:UserInfo.getUserId() limit 1];
        String countrycode = u.Country_Code__c;
        if(countrycode == 'AU')
        {
            countrycode = 'AN';
        }
        Boolean isEnable = false;
        ICLInformation icl = new ICLInformation();
        icl.OAMEnabled = false;
        icl.customercategory = '';
        try{
            AGN_ICL_Portal_Settings__c iclSetting = AGN_ICL_Portal_Settings__c.getInstance();
            if(!String.isEmpty(iclSetting.OAM_Enabled_AGN__c)){
                Pattern p = Pattern.compile('(?i)' + countrycode);//AGN_OAMConstant.USERCOUNTRYCODE); //(?i)-> ignore case
                Matcher m = p.matcher(iclSetting.OAM_Enabled_AGN__c);
                if(m.find()) {
                    icl.OAMEnabled = true;
                    isEnable = true;
                }
            }
           icl.customercategory = iclSetting.OAM_Customer_Category_AGN__c;
        }catch(Exception ex){
            //isEnable = false;
            System.debug('Exception in isICLEnabled Method '+ex.getMessage());
        }
        return icl;
    }
     
    public class ICLInformation{
        @AuraEnabled public String customercategory;
        @AuraEnabled public Boolean OAMEnabled;
    }
	
	/*@AuraEnabled 
    public static Account getAccountDetails()
    {
        return AGN_OAMPortalCustomerRegStep2Controller.getAccountHeaderDetails();
    }*/
    
    @AuraEnabled(cacheable=true)
    public static Account getAccountHeaderDetails() {
        User uInfo = [SELECT AccountId from User where Id =: UserInfo.getUserId() limit 1];
        Account acc = [SELECT Id,                       
                        Type_AGN__c,
                        Customer_Category_AGN__c,
                        Customer_Sub_Category_AGN__c,
                        SAP_Country_Code_AGN__c, Registered_For_Clinic_Locator_AGN__c, IsICLEnabled_AGN__c 
                FROM Account WHERE Id  =: uInfo.AccountId];
        return acc;
    }
    //Tm2.0 portal banner related change//
    @AuraEnabled
    public static boolean isSiteUnderMaintenance(){
        User u = [Select id,Country_Code__c  from User where Id=: UserInfo.getUserId() LIMIT 1]; 
        String countryCode = u.Country_Code__c;
        if(countryCode != null){
            return OAM_User_Settings__c.getValues(countryCode).AGN_OAM_Maintenance_Alert__c;
            //return false;
        }
        return false;
    }
    //Tm2.0 portal banner related change//
}