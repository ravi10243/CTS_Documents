public without sharing class AGN_OAMCustomerRegStep1Controller {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo) {
        
        return AGN_OAMCustomerRegUtils.getLayoutCountrySetting(country, stepNo, null, null, null); 
    }
    
    @AuraEnabled
    public static Map<String , List<AGN_CommunityDependentLayout__mdt>> getDependantLayout(String country) {
        
        return AGN_OAMCustomerRegUtils.getDependantFieldSettings(country);   
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo, String customerType, String customerSubType) {
        
        return AGN_OAMCustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, null);
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<AGN_Community_Layout_Setting__mdt>> getLayout(String country, String stepNo, String customerType, String customerSubType, List<Customer_Type_Configuration_AGN__c> custTypeConfig) {
        
        return AGN_OAMCustomerRegUtils.getLayoutCountrySetting(country, stepNo, customerType, customerSubType, custTypeConfig);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Allergan_Consent_Footer_Info__c> fetchFooterConsents(String pageLang){
        List<Allergan_Consent_Footer_Info__c> footerList = AGN_OAMCustomerRegUtils.getFooterConsents(pageLang);
        return footerList;
    }
    
    @AuraEnabled
    public static String getCustomerGroup(String countryCode, String customerType , String customerSubType) {
        
        String customerGroup = '';
        
        if(String.isNotBlank(countryCode)){
            List<Customer_Type_Configuration_AGN__c> configs = new List<Customer_Type_Configuration_AGN__c>([SELECT Id,Customer_Group_AGN__c 
                                                                                                             FROM Customer_Type_Configuration_AGN__c 
                                                                                                             WHERE Country_Code_AGN__c =:countryCode 
                                                                                                             AND (Category_AGN__c =: customerType OR Category_Label_AGN__c =: customerType ) 
                                                                                                             AND (Sub_Category__c =: customerSubType OR Sub_Category_Label_AGN__c =:customerSubType )]);
            if(configs.size() > 0 && String.isNotBlank(configs.get(0).Customer_Group_AGN__c)){
                customerGroup = configs.get(0).Customer_Group_AGN__c;
            }
        }
        return customerGroup;
    }
    
    @AuraEnabled
    public static Account getAccountDetails()
    {
        return AGN_OAMCustomerRegStep2Controller.getAccountHeaderDetails();
    }
    
    @AuraEnabled
    public static String[] getValidAddress(Allergan_Customer_Address_AGN__c customerAddress , String province){
        system.debug('Address Validation>>>>>>>>>>>>>>>>>>'+customerAddress+province);
        List<String> address = new List<String>();
        try{
            if(customerAddress != null && String.isNotBlank(province)){
                //String addressInput = customerAddress.Suite_AGN__c +' '+ customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.City_AGN__c +' '+ province +' '+ customerAddress.Zip_AGN__c;
                system.debug('customerAddress>>>>>>>>>>>>>>>>>>>>>'+customerAddress);
                String addressInput = '';
                if(String.isNotBlank(customerAddress.Suite_AGN__c)){
                    addressInput = customerAddress.Suite_AGN__c +' '+customerAddress.Address_Line_1_AGN__c +' '+ province +' '+ customerAddress.Zip_AGN__c;
                }else{
                    addressInput = customerAddress.Address_Line_1_AGN__c +' '+ province +' '+ customerAddress.Zip_AGN__c;
                }
                //String addressInput = customerAddress.Suite_AGN__c +' '+customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.Zip_AGN__c;
                //String addressInput = customerAddress.Address_Line_1_AGN__c +' '+ customerAddress.Zip_AGN__c;
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
    public static boolean isDuplicateUser(String email){
        return AGN_OAMCustomerRegUtils.checkForDuplicateCustomer(email);
    }
    
    @AuraEnabled
    public static Account createAccount(Allergan_Customer_Registration_AGN__c customer){
        try{
            return AGN_OAMCustomerRegUtils.createAccount(customer);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static Id createCommunityUser1(Id customerAccountId){
        try{
            return AGN_OAMCustomerRegUtils.createCommunityUser(customerAccountId);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static Id createCommunityUser(Id customerAccountId, String userLocale){
        try{
            /*if(customerAccountId.contains(',')){
String[] params = customerAccountId.split(',');
system.debug('params>>>>>>>>>>>>>>>>>>>>>>>>>'+params);
Id accountId = params[0];
String selectedUserLocale = params[1];
return AGN_OAMCustomerRegUtils.createCommunityUser(accountId , selectedUserLocale);
}else{
return AGN_OAMCustomerRegUtils.createCommunityUser(customerAccountId);
}*/
            
            return AGN_OAMCustomerRegUtils.createCommunityUser(customerAccountId , userLocale);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static Id createNewCustomerRegistration(Allergan_Customer_Registration_AGN__c customer, 
                                                   Allergan_Customer_Address_AGN__c customerAddress, 
                                                   List<Customer_Type_Configuration_AGN__c> configList,
                                                   Account customerAccount)
    {
        
        try{
            return AGN_OAMCustomerRegUtils.createNewCustomerRegistration(customer, customerAddress, configList, customerAccount);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static Id createNewCustomerRegistration(Allergan_Customer_Registration_AGN__c customer, 
                                                   Allergan_Customer_Address_AGN__c customerAddress, 
                                                   List<Customer_Type_Configuration_AGN__c> configList,
                                                   Account customerAccount, String userLocale)
    {
        
        try{
            return AGN_OAMCustomerRegUtils.createNewCustomerRegistration(customer, customerAddress, configList, customerAccount, userLocale);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    } 
    @AuraEnabled
    public static String createOktaUserSendLink(Allergan_Customer_Registration_AGN__c customer, Account customerAccount)
    {
        
        try{
            return AGN_OAMCustomerRegUtils.createOktaUserSendLink(customer, customerAccount);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    
    @AuraEnabled
    public static String createOktaUserSendLink1(Allergan_Customer_Registration_AGN__c customer, Account customerAccount, String userLocale)
    {
        
        try{
            return AGN_OAMCustomerRegUtils.createOktaUserSendLink(customer, customerAccount, userLocale);
        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException(e.getMessage()); 
        }
    }
    @AuraEnabled
    public static void inactivateUser(Id communityUserId)
    {
        AGN_OAMCustomerRegUtils.inactivateUser(communityUserId);
    }
    
    /*@AuraEnabled
public static void sendEmail(List<AGN_EmailMessageWrapper> listEmailMessageWrapper, String emailTemplateName)
{
AGN_OAMCustomerRegUtils.sendEmail(listEmailMessageWrapper, emailTemplateName);
}
*/
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
    
    @AuraEnabled(cacheable=true)
    public static Boolean isRegistrationCompleted()
    {
        return AGN_OAMCustomerRegUtils.isRegistrationCompleted();
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
    
    //ICL is enable for User's country
    @AuraEnabled(cacheable=true)
    public static Boolean isICLEnabled()
    {
        Boolean isEnable = false;
        try{
            AGN_ICL_Portal_Settings__c iclSetting = AGN_ICL_Portal_Settings__c.getInstance();
            
            if(!String.isEmpty(iclSetting.OAM_Enabled_AGN__c)){
                Pattern p = Pattern.compile('(?i)' + AGN_OAMConstant.USERCOUNTRYCODE); //(?i)-> ignore case
                Matcher m = p.matcher(iclSetting.OAM_Enabled_AGN__c);
                if(m.find()) {
                    isEnable = true;
                }
            }
        }catch(Exception ex){
            isEnable = false;
        }
        return isEnable;
    }
    //Aritra//
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
    //Aritra//
}