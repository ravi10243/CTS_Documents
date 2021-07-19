/**
 * @description       : Enble the portal access for GCSP customers.
 * @author            : GCSP Core Plus Dev Team
 * @group             : 
 * @last modified on  : 04-15-2021
 * @last modified by  : Ravi Sirigiri
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   03-04-2021   GCSP Core Plus Dev Team   Initial Version
**/
Public class AGN_GCSP_OktaProcessNew{

    Public Static String displayMsg = '';
    
    Public Static Map<String, Boolean> isPasswordResetContactMap = new Map<String, Boolean>();
    
    public static String processADRequestOkta(Allergan_Customer_Registration_AGN__c crRecord){        
        
        System.debug('crRecordId @@@ : '+crRecord.Id);
        String countryCode;
        if(!String.isEmpty(crRecord.SAP_Country_Code_AGN__c) && !crRecord.SAP_Country_Code_AGN__c.equalsIgnoreCase('IE')){
            countryCode = crRecord.SAP_Country_Code_AGN__c;
        }
        else{
            countryCode = crRecord.Country_Code_AGN__c;
        }
        
        String crRecordId = crRecord.Id;     
       
        //for Multple Allergan customer contact Records
        processADRequestOktaBulk(crRecord, countryCode);
        
        system.debug('displayMsg>>>>>>>>>>'+displayMsg);
        
        return displayMsg;
    }
    
    public static Boolean findUserByContactId(Id contactId, List<User> existingUserWithContact){
        
        return findUserBy(contactId, null, existingUserWithContact);
    }
    
    public static Boolean findUserByUserName(String userName, List<User> existingUserWithContact){
        
        return findUserBy(null, userName, existingUserWithContact);
    }
    
    private static Boolean findUserBy(Id contactId, String userName, List<User> existingUserWithContact){
        
        for(User u : existingUserWithContact){
            if(contactId != null && (u.ContactId == contactId)){
                return true;
            }
            
            if(userName != null && (u.UserName.equalsIgnoreCase(userName))){
                return true;
            }
        }
        return false;
    }
    
    public static void processADRequestOktaBulk(Allergan_Customer_Registration_AGN__c crRecord, String countryCode){
        
        String userLocal = (String)OAM_User_Settings__c.getValues(countryCode).get('User_Locale__c');
        
        String suffixUserName = (String)OAM_User_Settings__c.getValues(countryCode).get('Username_Suffix__c');

        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        String USERNAME_SUFFIX =  commonOktaConfig.UsernameSuffix_AGN__c; //(String)OAM_User_Settings__c.getValues(countryCode).get('Username_Suffix__c');
       
        
        //Set<ID> contactIds = new Set<ID>();
        Set<String> contactUserNames = new Set<String>();       
        
        Map<Id, Contact> conMap = new Map<Id, Contact>();
        
        //put the ContactId and SOLDTo SAPID
        Map<Id, String> conSoldToSapIdMap = new Map<Id, String>();
        
        //put the ContactId and Person AccountID
        Map<Id, Id> conPersonAccMap = new Map<Id, Id>();
        
        //add the contacts after add the oktaId
        list<Contact> contactList = new list<Contact>();
        
        List<Allergan_Customer_Contact_AGN__c> acContacts = [Select Enable_Portal_User_AGN__c, 
                                                             Allergan_Direct_Access_Requested_AGN__c,
                                                             Contact_AGN__r.Id,
                                                             Contact_AGN__r.AccountId,
                                                             Contact_AGN__r.Email,
                                                             Contact_AGN__r.Phone,
                                                             Contact_AGN__r.Community_Okta_Password_Reset_Token_AGN__c,
                                                             Contact_AGN__r.FirstName,
                                                             Contact_AGN__r.LastName,
                                                             Contact_AGN__r.Salutation,
                                                             Contact_AGN__r.Okta_Id_AGN__c,
                                                             //Contact_AGN__r.Account.External_Id2_AGN__c,
                                                             Contact_AGN__r.Customer_Registration_AGN__c,
                                                             Contact_AGN__r.Has_Allergan_Direct_Access_AGN__c
                                                             From Allergan_Customer_Contact_AGN__c
                                                             Where Parent_AGN__c =: crRecord.Id];
        
        
        if(!acContacts.isEmpty()){
            list<Id> soldToAccIds = new list<Id>();
            for(Allergan_Customer_Contact_AGN__c acContact : acContacts){
                if(acContact.Enable_Portal_User_AGN__c){
                    soldToAccIds.add(acContact.Contact_AGN__r.AccountId);
                }
            }
            Map<Id, String> accIdSapIdMap = new Map<Id, String>();
            if(!soldToAccIds.isEmpty()){
                accIdSapIdMap = getParentSapId(soldToAccIds);
            }             
            
            for(Allergan_Customer_Contact_AGN__c acContact : acContacts){
                if(acContact.Enable_Portal_User_AGN__c){
                    
                    Boolean enableADAccess = false;
                    if(crRecord.Allergan_Direct_Access_Requested_AGN__c && acContact.Allergan_Direct_Access_Requested_AGN__c){
                        enableADAccess = true;                      
                    }
                    
                    Contact cont = new Contact(
                        Id  = acContact.Contact_AGN__r.Id,
                        AccountId = acContact.Contact_AGN__r.AccountId,
                        Email = acContact.Contact_AGN__r.Email,
                        Phone = acContact.Contact_AGN__r.Phone,
                        Community_Okta_Password_Reset_Token_AGN__c = acContact.Contact_AGN__r.Community_Okta_Password_Reset_Token_AGN__c,
                        FirstName = acContact.Contact_AGN__r.FirstName,
                        LastName = acContact.Contact_AGN__r.LastName,
                        Salutation = acContact.Contact_AGN__r.Salutation,
                        Okta_Id_AGN__c = acContact.Contact_AGN__r.Okta_Id_AGN__c,
                        //Account = new Account (External_Id2_AGN__c = acContact.Contact_AGN__r.Account.External_Id2_AGN__c),
                        Customer_Registration_AGN__c = acContact.Contact_AGN__r.Customer_Registration_AGN__c,
                        Has_Allergan_Direct_Access_AGN__c = enableADAccess
                    );
                    
                    conMap.put(cont.Id, cont);//add the all contacts if enable portal ueseraccess
                    
                    conSoldToSapIdMap.put(acContact.Contact_AGN__r.Id, accIdSapIdMap.get(acContact.Contact_AGN__r.AccountId)); // put the contact id and associated SoldTo Account SapId
                   
                    contactUserNames.add(acContact.Contact_AGN__r.Email + USERNAME_SUFFIX);
                    
                }else{
                    //displayMsg = 'Enable Portal user check box is not enabled for this ACC Record ::'+acContact.Id;
                    system.debug('Enable Portal user check box is not enabled for this ACC Record ::'+acContact.Id);
                   // return;
                }
            }
            
            //get all the existing users 
            List<User> existingContactUsers = [Select Id, UserName, ContactId From User 
                                               Where (ContactId =: conMap.keySet() OR UserName =: contactUserNames) 
                                               AND IsActive = true];
            //get all the Person Accounts
            list<AccountContactRelation> acRelationlist = [SELECT AccountId,ContactId FROM AccountContactRelation 
                                                           WHERE ContactId =: conMap.keySet() AND Account.IsPersonAccount = true];
            
            
            for(AccountContactRelation acr : acRelationlist){
                //put all the Person Accounts associated Contacts
                conPersonAccMap.put(acr.ContactId, acr.AccountId);              
            }
            
            
            Map<string, string> SAPIdsOnShipToBillTo = new Map<string, string>();  
            Map<String, Map<String, List<String>>> condataMap = new Map<String, Map<String, List<String>>>();
            
            condataMap = getAffiliatedSapDetails(conMap.keySet());
            //Check the validations for enable portal access
            Map<String, List<String>> dataMap = new Map<String, List<String>>(); 
            for(Contact con : conMap.values()){                               
                
                if(String.isEmpty(con.Email)){
                    
                    displayMsg = System.Label.AGN_OAM_ContactEmailEmpty +': ' + con.Id; 
                    system.debug('Okta AD Attributes Update ERROR - Email field is empty of Contact ' + con.Id);
                    return;                    
                }
                else{
                    //Contact is not linked with a community User   
                    if(!findUserByContactId(con.Id, existingContactUsers)){
                        
                        //Contact's email is linked with a community User (Username)
                        if(findUserByUserName(con.Email + USERNAME_SUFFIX, existingContactUsers)){                      
                            
                            displayMsg = System.Label.AGN_OAM_DuplicateUserEmail + ': ' + con.Email;
                            system.debug('Okta AD Attributes Update ERROR - Duplicate User found with Contact Email ' + con.Email);
                            return;
                        }
                        
                    }
                    
                    if(!String.isEmpty(conSoldToSapIdMap.get(con.Id))){
                        
                        String PAAOktaAllowedCountries  = System.label.AGN_OAM_PaAffiliationOktaAllowedCountries;  // Person Account Affliations Allowed Countries like : BR;DE;CA;FR; 
                        List<String> PAAOktaAllowedCountriesList = PAAOktaAllowedCountries.split(';');
                        boolean isPaaffliation = false;
                        
                        for(String cnt : PAAOktaAllowedCountriesList){
                            if(cnt == countryCode){
                                isPaaffliation = true;
                                break;
                            }
                        }
                        
                      /*if(!String.isEmpty(conPersonAccMap.get(con.Id)) && isPaaffliation){ // if Person Account Exist Then Send PA Id    
                            
                            dataMap = getBillToShipToSAPIds('', conPersonAccMap.get(con.Id));
                            
                        }else{ // if Person Account Doesn't Exist then send SoldTo SAPId
                            
                            dataMap = getBillToShipToSAPIds(conSoldToSapIdMap.get(con.Id), '');
                            
                        } 
                        */
                        dataMap = condataMap.containsKey(con.Id) ? condataMap.get(con.Id) : new Map<String, List<String>>();
                        system.debug('dataMap::::'+dataMap);                     
                        //Throw error if Shipto and Billto(If applicable) Sap Id's not foumd
                        if(dataMap.get('shiptoValueActive').size()<=0 && Boolean.valueOf(system.label.AGN_OAM_CheckShipToSAPIDExist) ){ 
                          
                            displayMsg = system.label.AGN_OAM_SAPIdNotFoundShipTo + con.AccountId ; 
                            System.debug('Okta AD Attributes Update ERROR - ShipTo SAP Ids not found for SoldTo Account record ::(Id = ' + con.AccountId + ')' );   
                            return;
                            
                        }else if(dataMap.get('billtoValueActive').size()<=0 && !countryCode.equalsIgnoreCase('BR') && Boolean.valueOf(system.label.AGN_OAM_CheckBillToSAPIDExist) ){
                           
                            displayMsg = system.label.AGN_OAM_SAPIdNotFoundBillTo + con.AccountId;
                            System.debug('Okta AD Attributes Update ERROR - Billto SAP Ids not found for SoldTo Account record ::(Id = ' + con.AccountId + ')');
                            return; 
                            
                        }else{                           
                            SAPIdsOnShipToBillTo.put(conSoldToSapIdMap.get(con.Id), JSON.serialize(dataMap));
                        }                     
                        
                    }else {                        
                        displayMsg = system.label.AGN_OAM_SAPIdNotFoundSoldTo + con.AccountId;
                        System.debug('Okta AD Attributes Update ERROR - SAP Id not found for SoldTo Account record (Id = ' + con.AccountId + ')');
                        return;
                    }
                    
                }  
                
            }
           
            //create okta user and Community User
            list<Contact> conList = new list<Contact>();
            Map<String, Contact> oktaIdConMap = createOktaUser(conMap, conSoldToSapIdMap, userLocal, countryCode, crRecord.Id, SAPIdsOnShipToBillTo, existingContactUsers);
            
            list<User> federationIdMappedUserList = [Select Id, isActive,FederationIdentifier, ContactId FROM user Where FederationIdentifier IN: oktaIdConMap.keyset()];
            Boolean isCreateCustomerUser = true;
            
            if(!federationIdMappedUserList.isEmpty()){
                for(User us : federationIdMappedUserList){
                    //check the FederationId is mapped or not to exesting Users. && Contact is not linked with a community User
                    if(oktaIdConMap.containsKey(us.FederationIdentifier) && !findUserByContactId(us.ContactId, existingContactUsers)){
                        displayMsg = system.label.AGN_OAM_OktaIdMapedToAnotherUser + '(UserId = ' + us.Id + ')'  + ' - ( FederationId = '+ us.FederationIdentifier +' ) ';
                        System.debug('Okta AD Attributes Update ERROR - The specified Federation ID ('+ us.FederationIdentifier +' ) Maped to another User (Id = ' + us.Id + ')');
                        isCreateCustomerUser = false;
                        //return;
                    }
                } 
            }
            
           
            if(isCreateCustomerUser){ 

                System.enqueueJob(new AGN_OAM_AD_Enable_Queueable(oktaIdConMap.values(),userLocal, countryCode, crRecord.Id, JSON.serialize(existingContactUsers), suffixUserName, isPasswordResetContactMap));
                
            }  
           
        }
    }
    
    public static void createCommunityUser(String contactStr, String selectedUserLocale, String sapCountryCode, String crRecordId, string existingusers, string suffix) { //string userOktaId,
         AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
         String USERNAME_SUFFIX =  commonOktaConfig.UsernameSuffix_AGN__c; //(String)OAM_User_Settings__c.getValues(countryCode).get('Username_Suffix__c');
        string alias = '';
        system.debug('contactStr::::::::'+contactStr);
        system.debug('existingusers::::::::'+existingusers);
        list<Contact> customerContactList = (list<Contact>)JSON.deserialize(contactStr, list<Contact>.class);
        
        list<User> existingUserList = (list<User>)JSON.deserialize(existingusers, list<User>.class);
        
        list<User> userList = new list<user>();
        list<User> updateUserList = new list<user>();
        
        list<Contact> conList = new list<Contact>();
        
        OAM_User_Settings__c allDetails = OAM_User_Settings__c.getInstance(sapCountryCode);
        
        Map<Id, Id> conUserExistMap = new Map<Id, Id>();
        
        for(User conUserExist : existingUserList){
            conUserExistMap.put(conUserExist.ContactId, conUserExist.id);
        }
        
        for(Contact customerContact : customerContactList){
            //Contact is not linked with a community User   &&  
            if(!findUserByContactId(customerContact.Id, existingUserList)) {      
                
                //Contact's email is not linked with a community User (Username)
                if(!findUserByUserName(customerContact.Email + USERNAME_SUFFIX, existingUserList)){
                    User customerUser = new User();
                    if(sapCountryCode == 'CA'){
                        if(String.isNotBlank(selectedUserLocale)){
                            if(selectedUserLocale.containsIgnoreCase('en')){
                                customerUser.LanguageLocaleKey = 'en_US';
                                customerUser.LocalesIdKey = 'en_CA';
                            }else if(selectedUserLocale.containsIgnoreCase('fr')){
                                customerUser.LanguageLocaleKey = 'fr';
                                customerUser.LocalesIdKey = 'fr_CA';
                            }
                        }else{
                            customerUser.LanguageLocaleKey = allDetails.User_Language__c;
                            customerUser.LocalesIdKey = allDetails.User_Locale__c; 
                        }
                    }else{
                        customerUser.LanguageLocaleKey = allDetails.User_Language__c;
                        customerUser.LocalesIdKey = allDetails.User_Locale__c; 
                    }
                    //get okta id for this contact
                    //String contOktaId = [Select Okta_Id_AGN__c From Contact Where Id =: customerContact.Id].Okta_Id_AGN__c;
                    //System.debug('contOktaId -->'+ contOktaId);
                    //System.debug('customerContact.Id -->'+ customerContact.Id);
                    
                    alias = AGN_GCSP_CustomerRegUtils.generateRandomString(8);
                    
                    customerUser.Email = customerContact.Email.toLowercase();
                    customerUser.Phone = customerContact.Phone;
                    customerUser.FirstName = customerContact.FirstName;
                    customerUser.LastName = customerContact.LastName;
                    customerUser.Alias = alias;
                    customerUser.EmailEncodingKey = 'UTF-8';
                    customerUser.TimezonesIdKey = allDetails.User_Timezone__c;
                    customerUser.ProfileId = [SELECT Id FROM Profile WHERE Name =: allDetails.User_Profile__c limit 1]?.Id;
                    customerUser.UserName = customerContact.Email.toLowercase() + USERNAME_SUFFIX;
                    customerUser.ContactId = customerContact.Id;
                    customerUser.Country_Code__c = sapCountryCode;
                    customerUser.FederationIdentifier = String.isEmpty(customerContact.Okta_Id_AGN__c) ? '': customerContact.Okta_Id_AGN__c; //SSO Mapping
                    
                    userList.add(customerUser);
                    //insert customerUser;                    
                }
            }else{
                User existingCustomerUser = new User();
                existingCustomerUser.id = conUserExistMap.get(customerContact.id);
                existingCustomerUser.Phone = customerContact.Phone;
                existingCustomerUser.FirstName = customerContact.FirstName;
                existingCustomerUser.LastName = customerContact.LastName;
                existingCustomerUser.FederationIdentifier = String.isEmpty(customerContact.Okta_Id_AGN__c) ? '': customerContact.Okta_Id_AGN__c; //SSO Mapping
                updateUserList.add(existingCustomerUser);
            }           
        }
       
        try{  
            // Insert new users list;
            if(!userList.isEmpty()) {
                
                String obj = 'User';
                SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
                AGN_FLSCheck.check(userList,objType,'INSERT');
                insert userList;
            }
                
            //update execting users
            if(!updateUserList.isEmpty()) {
                String obj = 'User';
                SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
                AGN_FLSCheck.check(updateUserList,objType,'UPDATE');
                update updateUserList;
            }
            
        }catch(Exception ex){
            system.debug('Ex>>>>>>'+ex);
            
             String errorId = AGN_OAM_LogService.getRandom(32);
            
            //logging exception
            OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                ErrorId_AGN__c = errorId,               
                ExceptionMessage_AGN__c = ex.getMessage(),
                ExceptionType_AGN__c = ex.getTypeName(),
                ExceptionStackTrace_AGN__c = ex.getStackTraceString(),
                RunningUserId_AGN__c = UserInfo.getUserId(),
                //Reference_Email_AGN__c = customerContact.Email,
                Allergan_Customer_Registration_AGN__c = crRecordId
            );            
            //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
            EventBus.publish(log);
            
        }       
        
    }
    
    public static String sendExpiryLinkChangePassword(Contact customerContact, String userLocale, String sapCountryCode)
    {    
       
       AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
       
        String PRIVATEKEYVAL = commonOktaConfig.Encrypt_Decrypt_Private_Key_AGN__c;
        String dataToEncrypt;
        String encryptedData;
        String privateKey = PRIVATEKEYVAL; //config
        
        AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
        Decimal TOKENVALIDTILL = (Decimal)AGN_GCSP_Settings__c.getValues(sapCountryCode).get('Activation_Token_Valid_Till_AGN__c');
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(TOKENVALIDTILL));
        
        String passwordResetToken = cUtil.getRandomKey();
        
        String USERNAME_SUFFIX = !String.isEmpty(commonOktaConfig.UsernameSuffix_AGN__c) ? commonOktaConfig.UsernameSuffix_AGN__c : '';
       
        dataToEncrypt = '{' +
            +'"portalusername": "' + customerContact.Email + USERNAME_SUFFIX + '",' +
            +'"portaluseremail": "' + customerContact.Email + '",' +
            +'"customercontactid": "' + customerContact.Id + '",' +
            +'"countrycode": "' + sapCountryCode + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '"' +
            +'}';        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        //Update generated password reset token with in Contact
        system.debug('@@@Contact>>>>'+customerContact);
        customerContact.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        //update customerContact;
        
        
        SendWelcomeMail(customerContact, encryptedData, userLocale, sapCountryCode); 
        
        return passwordResetToken;
    }
    
    public static void SendWelcomeMail(Contact customerContact, String encryptedData, String userLocale, String sapCountryCode){
        
          Decimal expirationInDays = 0;
        String accepteddate;
        String expiryLink;
        //AGN_OAMConstant.TOKENVALIDTILL/24;
        Decimal TOKENVALIDTILL = (Decimal)AGN_GCSP_Settings__c.getValues(sapCountryCode).get('Activation_Token_Valid_Till_AGN__c');
        if(sapCountryCode.equalsIgnoreCase('FR') || sapCountryCode.equalsIgnoreCase('AN') || sapCountryCode.equalsIgnoreCase('AU') || sapCountryCode.equalsIgnoreCase('NZ')) {
            expirationInDays = TOKENVALIDTILL;
            accepteddate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('dd MMM YYYY');
        }
        else{
            expirationInDays = TOKENVALIDTILL/24;
            accepteddate = DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd');
        }
        
        String lang;
        String langSidKey='';
        System.debug('SendWelcomeMail -- customer.Country_Code_AGN__c ->' +customerContact.Country_Code_AGN__c);
        System.debug('SendWelcomeMail -- userLocale ->' +userLocale);
        
        if(sapCountryCode.equalsIgnoreCase('CA')) {
            if(!String.isEmpty(userLocale)) {
                if(userLocale.containsIgnoreCase('en')) {
                    lang = 'en_US';
                }else if(userLocale.containsIgnoreCase('fr')) {
                    lang = 'fr';
                    langSidKey = 'fr_CA';
                }
                else{
                    //lang = AGN_OAMConstant.USER_LANGUAGE;
                    lang = userLocale;
                }
            }
            else{
                //lang = AGN_OAMConstant.USER_LANGUAGE;
                lang = userLocale;
            }
        }
        else if(sapCountryCode.equalsIgnoreCase('AU') || sapCountryCode.equalsIgnoreCase('NZ') || sapCountryCode.equalsIgnoreCase('AN')) {
            //lang = (String)OAM_User_Settings__c.getValues(customer.SAP_Country_Code_AGN__c).get('User_Language__c');
            lang = userLocale;
        }
        else{
            //lang = AGN_OAMConstant.USER_LANGUAGE;
            lang = userLocale;
        }
        
        List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
        Map<String, String> mapSubjectParams = new Map<String, String>();
        
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        
        String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(sapCountryCode)?.get('Community_Base_URL_AGN__c');           
        String comSuffix = (String)AGN_GCSP_Settings__c.getValues(sapCountryCode)?.get('Community_Suffix_AGN__c');
        
       // String COMMUNITY_BASE_URL = commonOktaConfig.Community_Base_URL_AGN__c;
       // String COMMUNITY_SUFFIX = commonOktaConfig.Community_Suffix_AGN__c;
        if(String.isEmpty(comSuffix) || comSuffix.equals('/')) {
            expiryLink = comBaseURL;
        }
        else{
            expiryLink = comBaseURL + comSuffix;
        }
        
        string languageSidkeyValue = String.isEmpty(langSidKey) ? lang :langSidKey;
		expiryLink += commonOktaConfig.Account_Activation_Page_Name_AGN__c+'?token=' + encryptedData + '&language='+languageSidkeyValue;
        
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => customerContact.FirstName,
                '{!Recipient.LastName}' => customerContact.LastName,
                '{!Recipient.Email}' => customerContact.Email,
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => accepteddate,
                '{!ExpiryLink}' => expiryLink
                };
                  system.debug('expiryLink::::'+expiryLink);  
                    listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', 
                                                                            customerContact.Email, null, 
                                                                            null, null, mapSubjectParams, 
                                                                            null, mapBodyParams));   
        
        String senderEmailAddress = (String)AGN_GCSP_Settings__c.getValues(sapCountryCode).get('Sender_Email_AGN__c');
        
        if(listEmailMessageWrapper.size() > 0){
            System.debug('sapCountryCode-->' + sapCountryCode);
            System.debug('userLocale-->' + userLocale);
            String welcomeEmailTemplateName;
            
            if(sapCountryCode.equalsIgnoreCase('BR')){
                //need to send 2 emails
                welcomeEmailTemplateName = String.Format('Self Registration: Welcome Email-{0}',new String[]{lang});
                
                String welcomeEmailEnablePortalTemplateName = String.Format('Self Registration: Welcome Email Enable Portal-{0}',new String[]{lang});
                
                AGN_GCSP_Utilities.sendEmail(listEmailMessageWrapper, welcomeEmailEnablePortalTemplateName, senderEmailAddress);
            }
            else if(sapCountryCode.equalsIgnoreCase('AU') || sapCountryCode.equalsIgnoreCase('NZ') || sapCountryCode.equalsIgnoreCase('AN')){
                welcomeEmailTemplateName = String.Format('Self Registration: Welcome Email-{0}_{1}', new String[]{sapCountryCode, userLocale});
            }
            else{
                welcomeEmailTemplateName = String.Format('Self Registration: Welcome Email_CS-{0}', new String[]{lang});
                EmailTemplate[] emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :welcomeEmailTemplateName limit 1];
                if(emailTemplate.isEmpty())
                {
                    welcomeEmailTemplateName = String.Format('Self Registration: Welcome Email-{0}', new String[]{lang});
                }
            }
            
            System.debug('welcomeEmailTemplateName-->' + welcomeEmailTemplateName);            
            
            AGN_GCSP_Utilities.sendEmail(listEmailMessageWrapper, welcomeEmailTemplateName, senderEmailAddress);
        }
    } 
    
       /*
* Create / Update user in okta
*/  
    public static Map<String, Contact> createOktaUser(Map<Id, Contact> conMap, Map<Id, String> conSoldToSapIdMap, String userLocale, String countryCode, String crRecordId, Map<string, string> SAPIdsOnShipToBillTo, list<User> existingUserList) {
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        String adGroups = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_AD_Group_Id_AGN__c');
        String adsfGroups = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_SF_Community_Group_Id_AGN__c');
        
        System.debug('adGroups ' + adGroups);
        System.debug('adsfGroups ' + adsfGroups);
        
        list<Contact> contactList = new list<Contact>(); 
        Map<String, Contact> oktaIdConMap = new Map<String, Contact>();
        Boolean isPasswordReset = false;
        String userOktaId = '';
        String ShipToBillToSAPIds = '';
        
        try{
            
            for(Contact con : conMap.values()){
                
                userOktaId = '';
                isPasswordReset = false;
                
                ShipToBillToSAPIds = string.isNotEmpty(SAPIdsOnShipToBillTo.get(conSoldToSapIdMap.get(con.Id)))? SAPIdsOnShipToBillTo.get(conSoldToSapIdMap.get(con.Id)) : JSON.serialize(new Map<String, List<String>>());
                system.debug('ShipToBillToSAPIds:::::'+ShipToBillToSAPIds);
                system.debug('SAPIdsOnShipToBillTo::::'+SAPIdsOnShipToBillTo);
                system.debug('conSoldToSapIdMap::::'+ conSoldToSapIdMap);
                Map<String, List<String>> dataMap = (Map<String, List<String>>)JSON.deserialize(ShipToBillToSAPIds, Map<String, List<String>>.class);
                
                if(!con.Has_Allergan_Direct_Access_AGN__c && !String.isEmpty(adGroups)){
                    List<String> adGroupsList = adGroups.split(',');
                    
                    List<String> adsfGroupsList = adsfGroups.split(',');
                    
                    for(Integer i = adsfGroupsList.size() - 1; i >= 0; i--) {
                        for(integer j=0;j<adGroupsList.size();j++){
                            if(adsfGroupsList[i].equals(adGroupsList[j])) {
                                adsfGroupsList.remove(i);
                                break;
                            }
                        }
                    }
                    adsfGroups = String.join(adsfGroupsList,',');
                }
                
                String returnMessage = 'FAILURE';
                
                String oktaUserName =  con.Email;
                System.debug('oktaUserName @@@ : '+oktaUserName);
                
                boolean logRequest ;
                
                if(countryCode != NULL && AGN_GCSP_Settings__c.getValues(countryCode)!= NULL){               
                    logRequest = (boolean)AGN_GCSP_Settings__c.getValues(countryCode).get('Enable_Logs__c');                
                } 
                
                String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Community_Base_URL_AGN__c');           
                String comSuffix = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Community_Suffix_AGN__c');
                
                String oktaBaseUrl = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_Base_URL_AGN__c');
                String oktaApiKey =  (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_API_Key_AGN__c'); 
                String oktaRedirectURL =  (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_Redirect_URL_AGN__c'); 
                
                //AGN_OktaUtils oUtil = new AGN_OktaUtils(countryCode, '');
                AGN_OktaUtils oUtil = new AGN_OktaUtils(oktaBaseUrl, oktaApiKey, null);
                
                //checking if user is present in OKTA
                String okatMessage = oUtil.isPresentInOkta(oktaUserName);
                System.debug('okatMessage @@@ : '+okatMessage);
                Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
                
                String messagetype = (String) m.get('messagetype');
                System.debug('messagetype @@@ : '+messagetype);
                //ERROR -> User not found, need to create the user
                if (messagetype.equalsIgnoreCase('ERROR')) {
                    
                    String adAttributesBody =  formatedADAttributeString(conSoldToSapIdMap.get(con.Id), countryCode, dataMap);  

                    String firstName = String.isNotEmpty(con.FirstName) ? con.FirstName : '';
                    String lastName = String.isNotEmpty(con.LastName) ? con.LastName : '';
                    String mobilePhone = String.isNotEmpty(con.Phone) ? con.Phone : '';
                    String title = String.isNotEmpty(con.Salutation) ? con.Salutation : '';
                    countryCode = String.isNotEmpty(countryCode) ? countryCode : '';
                    
                    String reqBody = '{"profile":' +
                        +'{"firstName": "' + firstName + '",' +
                        +'"lastName": "' + lastName + '",' +
                        +'"email": "' + con.Email.toLowercase() + '",' +
                        +'"login": "' + oktaUserName.toLowercase() + '",' +
                        +'"countryCode": "' + countryCode + '",' +
                        +'"mobilePhone": "' + mobilePhone + '",' +
                        +'"title": "' + title + '",' +
                        +'"ad_has_consented_gdpr": "true",' +
                        + adAttributesBody +
                        +'},' +
                        +'"credentials":{' +
                        +'"recovery_question":' +
                        +'{"question": "' + 'Name of this company?' + '","answer": "' + 'ALLERGAN' + '"' +
                        +'}' +
                        +'},' +
                        +'"groupIds": [' + adsfGroups + ']}';
                    
                    //+'"groupIds": [' + (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_SF_Community_Group_Id_AGN__c')+ ']}';
                    
                    system.debug('reqBody@@@@ ==== '+reqBody);
                    
                    if (logRequest) AGN_ErrorLogger.addCustomerRegsistrationError('Salesforce', 'Request', reqBody, crRecordId, NULL);
                    
                    String userCreateMsg = oUtil.CreateUser(reqBody);
                    system.debug('userCreateMsg@@@@ ==== '+userCreateMsg);
                    Map <String, Object> userCreateMsgMap = (Map < String, Object >) JSON.deserializeUntyped(userCreateMsg);
                    
                    system.debug('userCreateMsgMap@@@@ ==== '+userCreateMsgMap);
                    
                    System.debug('Response Body>>>>>>>>>'+String.valueOf(userCreateMsgMap.get('response')));
                    
                    if (String.valueOf(userCreateMsgMap.get('messagetype')).equalsIgnoreCase('SUCCESS')) {
                        returnMessage = 'SUCCESS';
                        userOktaId = String.valueOf(userCreateMsgMap.get('Id'));
                        system.debug('userOktaId ==== '+userOktaId);                   
                        
                        if (logRequest) AGN_ErrorLogger.addCustomerRegsistrationError('OKTA', 'Response', String.valueOf(userCreateMsgMap.get('response')), crRecordId, NULL);
                        
                        isPasswordReset = true;
                    }else{
                        if (logRequest) AGN_ErrorLogger.addCustomerRegsistrationError('OKTA', 'Response', String.valueOf(userCreateMsgMap.get('response')), crRecordId, NULL);
                        isPasswordReset = false;
                        displayMsg = 'Data Processed to okta is fail';                        
                    }
                }
                //User found
                else {
                    String userOktatatus = (String) m.get('Status');
                    userOktaId = (String) m.get('Id');
                    
                    system.debug('userOktatatus ==== '+userOktatatus);
                    system.debug('userOktaId$$ ==== '+userOktaId);
                    system.debug('else part createOktaUserSendLink userOktaId ==== '+userOktaId);
                    //Not inactive (DEPROVISIONED)
                    if (!userOktatatus.equalsignorecase('DEPROVISIONED')){
                        system.debug('@@adsfGroups>>>'+adsfGroups);
                        
                        oUtil.AddUserToGroup(adsfGroups, userOktaId);
                        
                        //oUtil.AddUserToGroup((String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_SF_Community_Group_Id_AGN__c'), userOktaId);
                        returnMessage = 'SUCCESS';
                        
                        // Update the Shipto and Billto(if applicable) Id's in Okta
                        updateADAttributesOkta(con, conSoldToSapIdMap.get(con.Id), userOktaId, countryCode, dataMap, crRecordId); 
                       
                        // Contact is not linked with a community User // Then we generate email to customer
                       if(!findUserByContactId(con.Id, existingUserList)) {
                       	isPasswordReset = true;
                       }
                        
                    } else {
                        returnMessage = 'DEPROVISIONED';
                    }
                }
                
                if(string.isNotEmpty(userOktaId)){
                      con.Okta_Id_AGN__c = userOktaId;
                      con.Customer_Registration_AGN__c = 'Complete';                        
                }
                
                isPasswordResetContactMap.put(con.id, isPasswordReset);
                contactList.add(con);
                oktaIdConMap.put(con.Okta_Id_AGN__c,con);
            }
            
        }
        catch(Exception ex){            
            
            displayMsg = 'Exception - ' + ex;
            System.debug('Exception - ' + ex );
            AGN_ErrorLogger.addCustomerRegsistrationError('OKTA', ex.getTypeName(), ex.getMessage(), crRecordId, NULL); 
            displayMsg = ex.getMessage();
        }
        finally{
            
            AGN_ErrorLogger.saveLogs();  
        }
        
        
        return oktaIdConMap;
        
    }
    
    public static void changeUserName(String oktaUserId, String currentEmail, 
                                      String toBeEmail, String countryCode, 
                                      String oldCommUserStr, 
                                      String crRecordId)
    {        
        System.debug('oktaUserId @@@ : '+oktaUserId);
        System.debug('toBeUserName @@@ : '+toBeEmail);
        
        try{
            AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
             String oktaBaseUrl = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_Base_URL_AGN__c');
             String oktaApiKey =  (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_API_Key_AGN__c'); 
             String oktaRedirectURL =  (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_Redirect_URL_AGN__c');
            
            //AGN_OktaUtils oUtil = new AGN_OktaUtils(countryCode, ''); 
            AGN_OktaUtils oUtil = new AGN_OktaUtils(oktaBaseUrl, oktaApiKey, null);
            
            //checking if user is present in OKTA
            String okatMessage = oUtil.isPresentInOkta(toBeEmail);
            
            System.debug('okatMessage @@@ : '+okatMessage);
            Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
            
            String messagetype = (String) m.get('messagetype');
            
            System.debug('messagetype @@@ : '+messagetype);
            
            //ERROR -> User not found, need to relpace username in Okta
            if (messagetype.equalsIgnoreCase('ERROR')) {
                
                String jsonBody = generateOktaProfileJSONBody(toBeEmail);
                
                System.debug('OktaProfileJSONBody -' + jsonBody);
                
                //calling Okta to replace username
                okatMessage = oUtil.UpdateUser(oktaUserId, jsonBody);
                
                //parsing the message. SUCCESS -> successfully replaced username
                Map <String, Object> mapUpdateUser = (Map <String, Object>) JSON.deserializeUntyped(okatMessage);
                messagetype = (String)mapUpdateUser.get('messagetype');
                
                System.debug('Okta User replace ' + messagetype);
                if(messagetype.equalsIgnoreCase('SUCCESS')){
                    String USERNAME_SUFFIX = commonOktaConfig.UsernameSuffix_AGN__c;
                    //(String)OAM_User_Settings__c.getValues(countryCode).get('Username_Suffix__c');
                    User oldCommUser = (User)JSON.deserialize(oldCommUserStr, User.class);                    
                    
                    User newCommUser = new User();
                    string alias = generateRandomString(8);
                    
                    newCommUser.UserName = toBeEmail + USERNAME_SUFFIX;
                    newCommUser.Email = toBeEmail;
                    newCommUser.Phone = oldCommUser.Phone;
                    newCommUser.FirstName = oldCommUser.FirstName;
                    newCommUser.LastName = oldCommUser.LastName;
                    newCommUser.Alias = alias;   
                    newCommUser.LanguageLocaleKey = oldCommUser.LanguageLocaleKey;
                    newCommUser.EmailEncodingKey = oldCommUser.EmailEncodingKey;        
                    newCommUser.LocalesIdKey = oldCommUser.LocalesIdKey;
                    newCommUser.TimezonesIdKey = oldCommUser.TimezonesIdKey;
                    newCommUser.ProfileId = oldCommUser.ProfileId;
                    newCommUser.ContactId = oldCommUser.ContactId; 
                    newCommUser.Country_Code__c = oldCommUser.Country_Code__c;
                    newCommUser.Division = oldCommUser.Division;
                    newCommUser.FederationIdentifier = oldCommUser.FederationIdentifier; //SSO
                    
                    //Inactive old community user
                    oldCommUser.IsActive = false;
                    oldCommUser.IsPortalEnabled = false;
                    oldCommUser.FederationIdentifier = null;
                    update oldCommUser;
                    
                    //create new community user
                    List<User> tempuserList = new List<User>();
                    tempuserList.add(newCommUser);              
                    String objCustomerAdd = 'User';
                    SObjectType objuserType = ((SObject)(Type.forName('Schema.'+objCustomerAdd).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(tempuserList,objuserType,'INSERT');

                    insert newCommUser;
                }
                else if(messagetype.equalsIgnoreCase('ERROR')){
                    String errorMessage  = (String)mapUpdateUser.get('message');
                    if(errorMessage.containsIgnoreCase('An object with this field already exists in the current organization')){
                        errorMessage = 'Okta Change Username ERROR - Duplicate User found in Okta with Email ' + toBeEmail;
                    }
                    System.debug('ERROR: '+ errorMessage);
                    //throw new AGN_CommonException(errorMessage);
                    
                    //Error Logging
                    //getting unique error Id
                    String errorId = AGN_OAM_LogService.getRandom(32);
                    
                    //logging exception
                    OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                        ErrorId_AGN__c = errorId,
                        Data_AGN__c = jsonBody,
                        MethodName_AGN__c = 'AGN_OktaProcessNew.changeUserName',
                        ExceptionMessage_AGN__c = errorMessage,
                        //ExceptionType_AGN__c = e.getTypeName(),
                        //ExceptionStackTrace_AGN__c = e.getStackTraceString(),
                        RunningUserId_AGN__c = UserInfo.getUserId(),
                        Reference_Email_AGN__c = currentEmail,
                        Allergan_Customer_Registration_AGN__c = crRecordId
                    );
                    
                    //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
                    EventBus.publish(log);
                }
            } //User found
            else{
                System.debug('ERROR: Okta Change Username ERROR - Duplicate User found in Okta with Email ' + toBeEmail);
                //throw new AGN_CommonException('Okta Change Username ERROR - Duplicate User found in Okta with Email ' + toBeEmail);
                
                //Error Logging
                //getting unique error Id
                String errorId = AGN_OAM_LogService.getRandom(32);
                
                //logging exception
                OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                    ErrorId_AGN__c = errorId,
                    Data_AGN__c = toBeEmail,
                    MethodName_AGN__c = 'AGN_OktaProcessNew.changeUserName',
                    ExceptionMessage_AGN__c = 'ERROR: Okta Change Username ERROR - Duplicate User found in Okta with Email ' + toBeEmail,
                    //ExceptionType_AGN__c = e.getTypeName(),
                    //ExceptionStackTrace_AGN__c = e.getStackTraceString(),
                    RunningUserId_AGN__c = UserInfo.getUserId(),
                    Reference_Email_AGN__c = currentEmail,
                    Allergan_Customer_Registration_AGN__c = crRecordId
                );
                
                //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
                EventBus.publish(log);
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);
            String errorId = AGN_OAM_LogService.getRandom(32);
            
            //logging exception
            OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                ErrorId_AGN__c = errorId,
                //Data_AGN__c = toBeEmail,
                MethodName_AGN__c = 'AGN_OktaProcessNew.changeUserName',
                ExceptionMessage_AGN__c = cex.getMessage(),
                ExceptionType_AGN__c = cex.getTypeName(),
                ExceptionStackTrace_AGN__c = cex.getStackTraceString(),
                RunningUserId_AGN__c = UserInfo.getUserId(),
                Reference_Email_AGN__c = currentEmail,
                Allergan_Customer_Registration_AGN__c = crRecordId
            );
            
            //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
            EventBus.publish(log);
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
            
            String errorId = AGN_OAM_LogService.getRandom(32);
            
            //logging exception
            OAM_Log_AGN__e log = new OAM_Log_AGN__e(
                ErrorId_AGN__c = errorId,
                //Data_AGN__c = toBeEmail,
                MethodName_AGN__c = 'AGN_OktaProcessNew.changeUserName',
                ExceptionMessage_AGN__c = ex.getMessage(),
                ExceptionType_AGN__c = ex.getTypeName(),
                ExceptionStackTrace_AGN__c = ex.getStackTraceString(),
                RunningUserId_AGN__c = UserInfo.getUserId(),
                Reference_Email_AGN__c = currentEmail,
                Allergan_Customer_Registration_AGN__c = crRecordId
            );
            
            //Call method to publish events (exception will be saved to OAM_Log_Recording_AGN__c)
            EventBus.publish(log);
        }
    }
    
     /*
* Update ShipTo and Billto Id's in okta
*/  
    public static void updateADAttributesOkta(Contact con, String soldToSAPId, String userOktaId, String userCountryCode, Map<String,List<String>> dataMap, String crRecordId){ 
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        System.debug('updateADAttributesToOkta countryCode == '+userCountryCode); 
        // System.debug('soldToId @@@ : ' + soldToSAPId);
        // System.debug('oktaId @@@ : ' + userOktaId);
        
         String systemPermission = '';
         String sitePermission = '';
         String directUserRole = '';
         boolean logRequest = false;
        if(userCountryCode != NULL && AGN_GCSP_Settings__c.getValues(userCountryCode)!= NULL){               
            logRequest = (boolean)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Enable_Logs__c'); 
            systemPermission = (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Allergan_Direct_System_Permissions_AGN__c');
            sitePermission = (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Allergan_Direct_Site_Permissions_AGN__c');
            directUserRole  = (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Allergan_Direct_User_Role_AGN__c');
        }
        //getBillToShipToSAPIds method
        //get Active, InActive ShipTo and BillTo SAP IDs from SF
        // Map<String,List<String>> dataMap = getBillToShipToSAPIds(soldToSAPId);
        
        System.debug('updateADAttributesToOkta shiptoValueActive : ' + dataMap.get('shiptoValueActive'));
        System.debug('updateADAttributesToOkta shiptoValueInActive : ' + dataMap.get('shiptoValueInActive'));
        System.debug('updateADAttributesToOkta billtoValueActive : ' + dataMap.get('billtoValueActive'));
        System.debug('updateADAttributesToOkta billtoValueInactive : ' + dataMap.get('billtoValueInactive'));
        
        //getBillToShipToFilter method
        //InActive ShipTo, BillTo will be removed from Okta
        //Active ShipTo, BillTo will be added to Okta
        //Any ShipTo/BillTo present in Okta but not present in SF, we are keeping these as it is in Okta
        
        Map<String,List<String>> data = getBillToShipToFilter(dataMap.get('billtoValueActive'),
                                                              dataMap.get('shiptoValueActive'),
                                                              dataMap.get('billtoValueInactive'),
                                                              dataMap.get('shiptoValueInActive'),
                                                              userOktaId, 
                                                              userCountryCode);
        
        System.debug('updateADAttributesToOkta billToActiveList : '+data.get('billToActiveList'));
        System.debug('updateADAttributesToOkta shipToActiveList : '+data.get('shipToActiveList'));
        
        String reqBody = prepareOktaJsonString(con,
                              data.get('billToActiveList'),
                                               data.get('shipToActiveList'),
                                               systemPermission,
                                               sitePermission,
                                               directUserRole,
                                               userCountryCode); 
        
        System.debug('reqBody @@@@ == '+reqBody);
        if (logRequest) AGN_ErrorLogger.addCustomerRegsistrationError('Salesforce', 'Request', reqBody, crRecordId, NULL);
        
      	//AGN_OktaUtils a = new AGN_OktaUtils(userCountryCode, '');
        String oktaBaseUrl = (String)AGN_GCSP_Settings__c.getValues(userCountryCode)?.get('Okta_Base_URL_AGN__c');
        String oktaApiKey =  (String)AGN_GCSP_Settings__c.getValues(userCountryCode)?.get('Okta_API_Key_AGN__c'); 
        String oktaRedirectURL =  (String)AGN_GCSP_Settings__c.getValues(userCountryCode)?.get('Okta_Redirect_URL_AGN__c');
            
        AGN_OktaUtils a = new AGN_OktaUtils(oktaBaseUrl, oktaApiKey, null);
        
        String response = a.UpdateUser(userOktaId, reqBody);
        
        if (logRequest) AGN_ErrorLogger.addCustomerRegsistrationError('OKTA', 'Response', response, crRecordId, NULL);
        System.debug('response @@@@ == ' + response);
    }
    
    public static Map<Id, String> getParentSapId(List<Id> soldToAccIds){
        Map<Id, String> accIdSapIdMap = new Map<Id, String>();
        for(Customer_Detail_AGN__c sapData : [SELECT Id, Parent_Account_AGN__c, External_ID_AGN__c FROM Customer_Detail_AGN__c WHERE Parent_Account_AGN__c In : soldToAccIds]){
            accIdSapIdMap.put(sapData.Parent_Account_AGN__c, sapData.External_ID_AGN__c);
        }
        return accIdSapIdMap;
        
    }
    
    public Static  Map<String, Map<String, list<String>>> getAffiliatedSapDetails(Set<Id> contactIds){
        Map<String, list<Contact_Custmer_Detail_Relation_AGN__c>> conjunctionObjList = new Map<String, list<Contact_Custmer_Detail_Relation_AGN__c>>();
                
        for(Contact con : [SELECT Id, (SELECT Id,Contact_AGN__c, 
                                       Customer_Detail_AGN__c,
                                       Customer_Detail_AGN__r.External_ID_AGN__c,                                                          
                                       Sold_To_AGN__c, 
                                       Ship_To_AGN__c, 
                                       Bill_To_AGN__c,
                                       Is_Active_AGN__c
                                       FROM Contact_Custmer_Detail_Relations__r) FROM Contact WHERE Id In: contactIds]){
                                           conjunctionObjList.put(con.Id, con.Contact_Custmer_Detail_Relations__r);
                                       }
        
        
        
        Map<String, Map<String, List<String>>> conDataMap = new Map<String, Map<String, List<String>>>();
        Map<String, List<String>> dataMap = new Map<String, List<String>> ();
        
        Map<String, List<String>> shipToActiveMap = new Map<String, List<String>>();
        Map<String, List<String>> shipToInActiveMap = new Map<String, List<String>>();
        Map<String, List<String>> billToActiveMap = new Map<String, List<String>>();
        Map<String, List<String>> billToInActiveMap = new Map<String, List<String>>();
        for(Id conId : contactIds){
            system.debug('conId::::'+conId);
            system.debug('conjunctionObjList::::'+conjunctionObjList.get(conId));
            List<String> shipToActiveList = new List<String>();
            List<String> shipToInActiveList = new List<String>();
            List<String> billToActiveList = new List<String>();
            List<String> billToInActiveList = new List<String>();
            for(Contact_Custmer_Detail_Relation_AGN__c con : conjunctionObjList.get(conId)){
                system.debug('SapId:::'+con.Customer_Detail_AGN__r.External_ID_AGN__c);                
                if(con.Is_Active_AGN__c && con.Ship_To_AGN__c){
                    shipToActiveList.add(con.Customer_Detail_AGN__r.External_ID_AGN__c);
                    shipToActiveMap.put(con.Contact_AGN__c, shipToActiveList);
                }
                if(!con.Is_Active_AGN__c && con.Ship_To_AGN__c){
                    shipToInActiveList.add(con.Customer_Detail_AGN__r.External_ID_AGN__c);
                    shipToInActiveMap.put(con.Contact_AGN__c, shipToInActiveList);
                }
                if(con.Is_Active_AGN__c && con.Bill_To_AGN__c){
                    billToActiveList.add(con.Customer_Detail_AGN__r.External_ID_AGN__c);
                    billToActiveMap.put(con.Contact_AGN__c, billToActiveList);
                }
                if(!con.Is_Active_AGN__c && con.Bill_To_AGN__c){
                    billToInActiveList.add(con.Customer_Detail_AGN__r.External_ID_AGN__c);
                    billToInActiveMap.put(con.Contact_AGN__c, billToInActiveList);
                }
                /*system.debug('billToInActiveMap:::'+billToInActiveMap);
system.debug('billToActiveMap:::'+billToActiveMap);
system.debug('shipToInActiveMap:::'+shipToInActiveMap);
system.debug('shipToActiveMap:::'+shipToActiveMap); */
            }
            if(shipToActiveMap.get(conId) != null){
                dataMap.put('shiptoValueActive', shipToActiveMap.get(conId));
            }else{
                dataMap.put('shiptoValueActive', new List<String>());
            }
            if(shipToInActiveMap.get(conId) != null){
                dataMap.put('shiptoValueInActive', shipToInActiveMap.get(conId));
            }else{
                dataMap.put('shiptoValueInActive', new List<String>());
            }
            if(billToActiveMap.get(conId) != null){
                dataMap.put('billtoValueActive', billToActiveMap.get(conId));
            }else{
                dataMap.put('billtoValueActive', new List<String>());
            }
            if(billToInActiveMap.get(conId) != null){
                dataMap.put('billtoValueInactive', billToInActiveMap.get(conId));   
            }else{
                dataMap.put('billtoValueInactive', new List<String>());
            }            
            
            conDataMap.put(conId, dataMap);
            
            system.debug('getAffliation::::'+conDataMap.get(conId));
        }
        
        return conDataMap;
    }
    
    public static Map<String,List<String>> getBillToShipToFilter(List<String> billToSapIdActiveSF,
                                                                 List<String> shipToSapIdActiveSF,                                                                 
                                                                 List<String> billToSapIdInActiveSF,
                                                                 List<String> shipToSapIdInActiveSF,
                                                                 String oktaId,
                                                                 String countryCode)
    {	
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        String OKTABASEURL = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_Base_URL_AGN__c');
            //commonOktaConfig.Okta_Base_URL_AGN__c;
        String OKTAAPIKEY = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_API_Key_AGN__c'); 
            //commonOktaConfig.Okta_API_Key_AGN__c;
        
        
        Map<String,List<String>> dataMap = null;
        
        List<String> billToSapIdActiveOkta =new List<String>();
        List<String> shipToSapIdActiveOkta= new List<String>();
        
        HttpResponse response = AGN_Okta.GetUserDetails(OKTABASEURL, OKTAAPIKEY, oktaId);
        
        if(response != null){
            dataMap = new Map<String,List<String>>();
            //found user
            if (response.getStatusCode() == 200) {
                AGN_OktaUserSuccessResponse respUser = AGN_OktaUserSuccessResponse.parse(response.getBody());
                
                shipToSapIdActiveOkta = respUser.profile.ad_associated_shipto_accounts;
                billToSapIdActiveOkta = respUser.profile.ad_associated_payer_accounts;
                
                System.debug('shipToSapIdActiveOkta : '+shipToSapIdActiveOkta);
                System.debug('billToSapIdActiveOkta : '+billToSapIdActiveOkta);                                                         
                
                if(billToSapIdActiveOkta !=null && !billToSapIdActiveOkta.isEmpty()){
                    billToSapIdActiveSF.addAll(billToSapIdActiveOkta); 
                }
                if(shipToSapIdActiveOkta !=null && !shipToSapIdActiveOkta.isEmpty()){
                    shipToSapIdActiveSF.addAll(shipToSapIdActiveOkta);
                }
                
                Set<String> billToActiveSet = new Set<String>(billToSapIdActiveSF);
                Set<String> shipToActiveSet = new Set<String>(shipToSapIdActiveSF);
                
                System.debug('billToActiveSet : ' + billToActiveSet);
                System.debug('shipToActiveSet : ' + shipToActiveSet);  
                
                Set<String> billToInActiveSet = new Set<String>(billToSapIdInActiveSF);
                Set<String> shipToInActiveSet = new Set<String>(shipToSapIdInActiveSF);
                
                System.debug('billToInActiveSet : ' + billToInActiveSet);
                System.debug('shipToInActiveSet : ' + shipToInActiveSet);                                                         
                
                for(String sapIdBillTo: billToInActiveSet){
                    if(billToActiveSet.contains(sapIdBillTo))
                        billToActiveSet.remove(sapIdBillTo);
                }
                
                // system.debug('====billToActiveSet==='+billToActiveSet);
                // system.debug('====billToInActiveSet==='+billToInActiveSet);                                                         
                
                for(String sapIdShipTo: shipToInActiveSet){
                    if(shipToActiveSet.contains(sapIdShipTo))
                        shipToActiveSet.remove(sapIdShipTo);
                }
                
                // system.debug('====shipToActiveSet==='+shipToActiveSet);
                // system.debug('====shipToInActiveSet==='+shipToInActiveSet); 
                
                List<String> listShipTo = new List<String>();
                listShipTo.addAll(shipToActiveSet);
                
                List<String> listBillTo=new List<String>();
                listBillTo.addAll(billToActiveSet);
                
                dataMap.put('shipToActiveList', listShipTo); 
                dataMap.put('billToActiveList', listBillTo);  
                
                system.debug('====billToActiveList final===' + listShipTo);
                system.debug('====billToInActiveList final===' + listBillTo);
            }
            else{
                throw new AGN_CommonException('Okta AD Attributes Update ERROR - No Okta User found with OktaId = ' + oktaId);
            }
        }
        return dataMap;
    }

    public static String prepareOktaJsonString(Contact con,
                             String[] billToSapIdValue,
                                               String[] shipToSapIdValue,
                                               String systemPermission,
                                               String sitePermission,
                                               String directUserRole,
                                               String userCountryCode)
    {
        String profileStart='{"profile": {';
        String profileEnd='} }';
        String billToAccountStart='"ad_associated_payer_accounts": [';
        String billToAccountEnd=']';
        String shipToAccountStart='"ad_associated_shipto_accounts": [';
        String shipToAccountEnd=']';
        
        String systemPermissionStart='"ad_system_permissions": [';
        String systemPermissionEnd=']';
        String sitePermissionStart='"ad_site_permissions": [';
        String sitePermissionEnd=']';
        String adRole='"ad_user_role":' ;
        String billtoFinalText='';
        String shiptoFinalText='';
        String billtoDetails='';
        String shiptoDetails='';
        String doubleQuotes='\"';
        String systemPermissionText='';
        String sitePermissionText='';
        String adRoleText='';
        String response='';
        
        String firstName = String.isNotEmpty(con.FirstName) ? con.FirstName : '';
        String lastName = String.isNotEmpty(con.LastName) ? con.LastName : '';
        String mobilePhone = String.isNotEmpty(con.Phone) ? con.Phone : '';
        String title = String.isNotEmpty(con.Salutation) ? con.Salutation : '';
        String countryCode = String.isNotEmpty(userCountryCode) ? userCountryCode : '';
        
        String Userinfo = '"firstName": "' + firstName + '", ' + '"lastName": "' + lastName + '", ' + '"mobilePhone": "' + mobilePhone + '", ' + '"title": "' + title + '", ' + '"countryCode": "' + countryCode + '"';
      
        
        if(billToSapIdValue.size() > 0){
            for (Integer i = 0; i<billToSapIdValue.size(); i++) {
                billtoFinalText+=doubleQuotes;
                billtoFinalText+=billToSapIdValue[i];
                billtoFinalText+=doubleQuotes;
                billtoFinalText+=',';                
            }            
            billtoFinalText = billtoFinalText.subString(0, billtoFinalText.length()-1);            
            billtoDetails = billToAccountStart + billtoFinalText + billToAccountEnd;            
        }else{
            billtoDetails = billToAccountStart + billToAccountEnd;
        }
        
        if(shipToSapIdValue.size() > 0){
            for (Integer i = 0; i < shipToSapIdValue.size(); i++) {
                shiptoFinalText += '\"';
                shiptoFinalText += shipToSapIdValue[i];
                shiptoFinalText += '\"';
                shiptoFinalText += ',';                
                // system.debug('shiptoFinalText: '+shiptoFinalText);
            }
            shiptoFinalText = shiptoFinalText.subString(0, shiptoFinalText.length()-1);
            shiptoDetails = shipToAccountStart + shiptoFinalText + shipToAccountEnd;            
        }else{
            shiptoDetails = shipToAccountStart + shipToAccountEnd;
        }        
        
        systemPermissionText = systemPermissionStart + systemPermission + systemPermissionEnd;
        sitePermissionText = sitePermissionStart + sitePermission + sitePermissionEnd;
        adRoleText = adRole + directUserRole;
        
        response = profileStart + ' ' + Userinfo + ', '+ billtoDetails + ',' + shiptoDetails + ',' + sitePermissionText + ',' + systemPermissionText + ',' + adRoleText + profileEnd;
        
        System.debug('response=== '+response);
        
        return response;
    }
    
    public static String getADAttributeJsonString(String[] billToSapIdValue,
                                                  String[] shipToSapIdValue,
                                                  String systemPermission,
                                                  String sitePermission,
                                                  String directUserRole)
    {
        
        String billToAccountStart = '"ad_associated_payer_accounts": [';
        String billToAccountEnd = ']';
        String shipToAccountStart = '"ad_associated_shipto_accounts": [';
        String shipToAccountEnd = ']';
        
        String systemPermissionStart = '"ad_system_permissions": [';
        String systemPermissionEnd = ']';
        String sitePermissionStart = '"ad_site_permissions": [';
        String sitePermissionEnd = ']';
        String adRole = '"ad_user_role":' ;
        String billtoFinalText = '';
        String shiptoFinalText = '';
        String billtoDetails = '';
        String shiptoDetails = '';
        String doubleQuotes = '\"';
        String systemPermissionText = '';
        String sitePermissionText = '';
        String adRoleText = '';
        String response = '';
        
        if(billToSapIdValue.size() > 0){
            for (Integer i = 0; i<billToSapIdValue.size(); i++) {
                billtoFinalText += doubleQuotes;
                billtoFinalText += billToSapIdValue[i];
                billtoFinalText += doubleQuotes;
                billtoFinalText += ',';
            }
            billtoFinalText = billtoFinalText.subString(0, billtoFinalText.length()-1);
            billtoDetails = billToAccountStart + billtoFinalText + billToAccountEnd;
        }else{
            billtoDetails = billToAccountStart + billToAccountEnd;
        }
        
        if(shipToSapIdValue.size() > 0){
            for (Integer i = 0; i<shipToSapIdValue.size(); i++) {
                shiptoFinalText += '\"';
                shiptoFinalText += shipToSapIdValue[i];
                shiptoFinalText += '\"';
                shiptoFinalText += ',';
            }
            shiptoFinalText = shiptoFinalText.subString(0, shiptoFinalText.length()-1);
            shiptoDetails = shipToAccountStart + shiptoFinalText + shipToAccountEnd;
        }else{
            shiptoDetails = shipToAccountStart + shipToAccountEnd;
        }        
        
        systemPermissionText = systemPermissionStart + systemPermission + systemPermissionEnd;
        sitePermissionText = sitePermissionStart + sitePermission + sitePermissionEnd;
        adRoleText = adRole + directUserRole;
        
        response = billtoDetails + ',' + shiptoDetails + ',' + sitePermissionText + ',' + systemPermissionText + ',' + adRoleText;
        
        System.debug('response=== '+response);
        return response;
    }
    
    public static String formatedADAttributeString(String soldToId, String countryCode, Map<String, List<String>> dataMap){  
        
        System.debug('response countryCode == '+countryCode); 
        System.debug('soldToId @@@ : '+soldToId);
        String reqBody;
        
        String systemPermission = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_System_Permissions_AGN__c');
        String sitePermission = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_Site_Permissions_AGN__c');
        String directUserRole = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Allergan_Direct_User_Role_AGN__c');
        
        //Map<String,List<String>> dataMap = getBillToShipToSAPIds(soldToId);
        
        System.debug('shiptoValueActive : ' + dataMap.get('shiptoValueActive'));
        System.debug('shiptoValueInActive : ' + dataMap.get('shiptoValueInActive'));
        System.debug('billtoValueActive : ' + dataMap.get('billtoValueActive'));
        System.debug('billtoValueInactive : ' + dataMap.get('billtoValueInactive'));
        
        reqBody = getADAttributeJsonString(dataMap.get('billtoValueActive'),
                                           dataMap.get('shiptoValueActive'),
                                           systemPermission,
                                           sitePermission,
                                           directUserRole);   
        
        return reqBody;
    }
    
    private static String generateOktaProfileJSONBody(String toBeEmail){
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();     
        gen.writeFieldName('profile');
        gen.writeStartObject();
        gen.writeStringField('login', toBeEmail);
        gen.writeStringField('email', toBeEmail);
        gen.writeEndObject();
        gen.writeEndObject();
        
        return gen.getAsString();
    }
    
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }

}