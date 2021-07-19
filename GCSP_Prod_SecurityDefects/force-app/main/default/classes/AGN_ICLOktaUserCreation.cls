/*
Modified by :ICL Project Team
Description: Updated code as part of Cluster country go live,since country code__c and country vod c in account card is different.
Release :ICL Wave-3
*/
/*
Modified by :ICL Project Team
Description: Line 325 is added and line 312 is updated as a part of DCR Enablement
Modify Date :3 Mar 2021
*/

public class AGN_ICLOktaUserCreation {
    
    
    public AGN_ICLOktaUserCreation()
    {
        
    }
    
    @Future(callout=true)
    public Static void createClinicAdminUser(String ClinicAdminAcc1,String Clinic_Id,String contactid,String locid,String userlang,String clinicadminemail)
    {
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        Account ClinicAdminAcc = (Account)JSON.deserialize(ClinicAdminAcc1, Account.class);
       
        //Account ClinicAdminAcc = [Select id,PersonContactId,name,Salutation,FirstName,LastName,PersonEmail,Phone,Primary_Parent_vod__c,Country_Code__c from Account where Primary_Parent_vod__c =:locatorlistingData.Account_AGN__c];
        //String contactid = AGN_ICLOktaUserCreation.CreateContact(ClinicAdminAcc,Clinic_Id);
        Map<String,AGN_ICL_Settings__c> icl_setting = AGN_ICL_Settings__c.getAll();
        if(contactid !=null)
        {
            string alias = '';
            if (ClinicAdminAcc.FirstName.length() > 0){
                alias += ClinicAdminAcc.FirstName.substring(0, 1);
            }
            if(ClinicAdminAcc.LastName.length()>0){
                
                alias += ClinicAdminAcc.LastName.substring(0,Math.min(ClinicAdminAcc.LastName.length(), 4));
            }
            
            integer existingUserCount = [SELECT COUNT() FROM User WHERE SMB_Alias_External_Id__c LIKE :alias + '%'];
            if(existingUserCount > 0){
                alias += existingUserCount;
            }
            try {
                User clincAdminUser = new User();
                clincAdminUser.FirstName = ClinicAdminAcc.FirstName;
                clincAdminUser.LastName = ClinicAdminAcc.LastName;
                clincAdminUser.Email = clinicadminemail.toLowerCase();//ClinicAdminAcc.PersonEmail.toLowercase();
                clincAdminUser.EmailEncodingKey = 'UTF-8'; 
                clincAdminUser.LanguageLocaleKey = userlang;//'en_US';
               // clincAdminUser.LocalesIdKey = icl_setting.get(ClinicAdminAcc.Country_Code__c).User_Locale_Id_AGN__c;//'en_GB';  //Custom Setting to be created
                //clincAdminUser.TimezonesIdKey =icl_setting.get(ClinicAdminAcc.Country_Code__c).User_Timezone_Id_AGN__c;//'Europe/London'; //Custom Setting to be created
                
                //Updated code as part of Cluster country go live as a part of ICL Wave-3
                Account ac=[Select country_vod__r.name from Account where id=: ClinicAdminAcc.Id];
                //End
                
                clincAdminUser.LocalesIdKey = icl_setting.get(ac.country_vod__r.name).User_Locale_Id_AGN__c;//'en_GB';  //Custom Setting to be created
                clincAdminUser.TimezonesIdKey =icl_setting.get(ac.country_vod__r.name).User_Timezone_Id_AGN__c;//'Europe/London'; //Custom Setting to be created
                
                clincAdminUser.Username = clinicadminemail + '.' + (String)portalSetting.ICL_Username_Suffix_AGN__c;
                clincAdminUser.Alias = alias;
                //clincAdminUser.Locator_Listing_Id_AGN__c = locid;    
                //clincAdminUser.Country_Code__c = ClinicAdminAcc.Country_Code__c;
                
               //Updated code as part of Cluster country go live as a part of ICL Wave-3
                clincAdminUser.Country_Code__c = ac.country_vod__r.name;
                //End
                
                clincAdminUser.profileId = [SELECT Id FROM Profile WHERE Name = 'Allergan Clinic Locator' limit 1].Id; // Profile to be created
                clincAdminUser.ContactId = contactid;//ClinicAdminAcc.PersonContactId;
                clincAdminUser.FederationIdentifier = clinicadminemail.toLowercase();

                //------CheckMarx Phase2--Added on 24/09/2020----------
                
                List<User> userList = new List<User>();
                userList.add(clincAdminUser);
                String objUser = 'User';
                SObjectType userObjType = ((SObject)(Type.forName('Schema.'+objUser).newInstance())).getSObjectType();
                AGN_FLSCheck.check(userList,userObjType,'INSERT');
                //-------------CheckMarx Phase2 end------------------------------------------------------------
                //---- "DLO" doesnot required FLS check------------
                Database.DMLOptions dlo = new Database.DMLOptions();
                dlo.EmailHeader.triggerUserEmail = false;
                
                Database.insert(clincAdminUser,dlo);
                //insert clincAdminUser; 
                //String msg = CreateOKTAUser(ClinicAdminAcc);
            } catch (DmlException dx) {
                throw new DmlException(dx.getMessage());
            }
        }
        
    }
    
    public static String CreateContact(Account clinicAdmin,String Clinic_Id,String clinicadminemail){
        String consuccess ='';
        try {
            Contact con = new Contact();
            con.Salutation = clinicAdmin.Salutation;
            con.FirstName = clinicAdmin.FirstName;
            con.LastName = clinicAdmin.LastName;
            con.Email = clinicadminemail.toLowercase();
            con.Phone = clinicAdmin.Phone;
            con.AccountId = Clinic_Id;
            //------CheckMarx Phase2--Added on 24/09/2020--------------------------------------------------------------
            //   List<Contact> contactList = new List<Contact>();
            //  contactList.add(con);
            //  String objContact = 'Contact';
            //  SObjectType contactObjType = ((SObject)(Type.forName('Schema.'+objContact).newInstance())).getSObjectType();
            // AGN_FLSCheck.check(contactList,contactObjType,'INSERT');
            //-----------------CheckMarx Phase2 end----------------------------------------------------------------------
            insert con;  
            String success = AGN_ICLOktaUserCreation.CreateAccountContactRelationship(clinicAdmin,con.id);            
            if(success == 'success')
            {
                consuccess = con.id;
            }
            return consuccess;
        }
        catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
        
    }
    
    public Static String CreateAccountContactRelationship(Account clinicAdmin,String Contact_Id){
        //SELECT AccountId,ContactId,EndDate,Id,IsActive,Roles,StartDate FROM AccountContactRelation
        String success = '';
        try{
            AccountContactRelation acc_relation = new AccountContactRelation();
            acc_relation.AccountId = clinicAdmin.Id;
            acc_relation.ContactId = Contact_Id;
            acc_relation.IsActive = true;
            insert acc_relation;
            success = 'success';
            
        }
        catch (DmlException dx) {
            throw new DmlException(dx.getMessage());
        }
        return success;
    }
    @Future(callout=true)
    public static void CreateOKTAUser(String ClinicAdminAcc1,String locid,String userlang,String clinicadminemail)
    {
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        Account ClinicAdminAcc = (Account)JSON.deserialize(ClinicAdminAcc1, Account.class);
        String returnMessage = 'FAILURE';
        
        String userName = clinicadminemail.toLowerCase();//ClinicAdminAcc.PersonEmail;
        
       //Updated code as part of Cluster country go live as a part of ICL Wave-3
                Account ac=[Select country_vod__r.name from Account where id=: ClinicAdminAcc.Id];
        //End
        
        AGN_ICL_OKTA_Util oUtil = new AGN_ICL_OKTA_Util();
        
        //checking if user is present in OKTA
        String okatMessage = '';
        if(!Test.isRunningTest()){
            okatMessage = oUtil.isPresentInOkta(userName);
        }
        else{
            okatMessage ='{'+
                +'"messagetype": "ERROR"'+
                +'}';  
        }
        Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
        
        String messagetype = (String) m.get('messagetype');
        
        //messagetype = ERROR -> User not found, need to create the user
        if (messagetype.equalsIgnoreCase('ERROR')) {
            //string oktaPassword = oUtil.generateRandomString(10);    
            /*string reqBody = '{"profile":' +
+'{"firstName": "' + ClinicAdminAcc.FirstName + '",' +
+'"lastName": "' + ClinicAdminAcc.LastName + '",' +
+'"email": "' + ClinicAdminAcc.PersonEmail.toLowercase() + '",' +
+'"login": "' + userName.toLowercase() + '",' +
//+'"countryCode": "' + ClinicAdminAcc.Country_Code__c + '",' +
//+'"mobilePhone": "' + ClinicAdminAcc.Phone + '",' +
//+'"title": "' + ClinicAdminAcc.Salutation + '",' +
//+'"ad_has_consented_gdpr": "true"' +
+'},' +
+'"credentials":{' +
//+'"password" : '+
//+'{"value": "'+ oktaPassword +'"'+
//+'},'+
+'"recovery_question":' +
+'{"question": "' + AGN_ICL_Portal_Settings__c.getInstance().Default_Recovery_Question_AGN__c + '","answer": "' + AGN_ICL_Portal_Settings__c.getInstance().Default_Recovery_Answer_AGN__c + '"' +
+'}' +
+'},' +
+'"groupIds": [' + AGN_ICL_Portal_Settings__c.getInstance().Okta_Group_Id_AGN__c + ']}';*/
            
            //string reqBody = '{"profile": {"firstName": "Prithviraj","lastName": "xyz","email": "prithviraj123@example.com","login": "prithviraj123@example.com"},"credentials": {"recovery_question": {"question": "Who a major player in the cowboy scene?","answer": "Annie Oakley"}}}';              
            //string reqBody = '{"profile": {'+'"firstName": "'+ClinicAdminAcc.FirstName +'","lastName": "'+ClinicAdminAcc.LastName+'","email": "'+ClinicAdminAcc.PersonEmail.toLowercase()+'","login": "'+userName.toLowercase()+'"},"credentials": {"recovery_question": {"question": "'+portalSetting.Default_Recovery_Question_AGN__c+'","answer": "'+portalSetting.Default_Recovery_Answer_AGN__c+'"}}}'; 
            //string reqBody = '{"profile": {'+'"firstName": "'+ClinicAdminAcc.FirstName +'","lastName": "'+ClinicAdminAcc.LastName+'","email": "'+ClinicAdminAcc.PersonEmail.toLowercase()+'","login": "'+userName.toLowercase()+'"},"credentials": {"recovery_question": {"question": "'+portalSetting.Default_Recovery_Question_AGN__c+'","answer": "'+portalSetting.Default_Recovery_Answer_AGN__c+'"}},'+'"groupIds": [' +AGN_ICL_Portal_Settings__c.getInstance().Okta_Group_Id_AGN__c + ']}';              
           //string reqBody = '{"profile": {'+'"firstName": "'+ClinicAdminAcc.FirstName +'","lastName": "'+ClinicAdminAcc.LastName+'","email": "'+clinicadminemail.toLowercase()+'","login": "'+userName.toLowercase()+'","countryCode": "'+ClinicAdminAcc.Country_Code__c+'"},"credentials": {"recovery_question": {"question": "'+portalSetting.Default_Recovery_Question_AGN__c+'","answer": "'+portalSetting.Default_Recovery_Answer_AGN__c+'"}},'+'"groupIds": [' +AGN_ICL_Portal_Settings__c.getInstance().Okta_Group_Id_AGN__c + ']}'; 
            
             //Updated code as part of Cluster country go live as a part of ICL Wave-3
                string reqBody = '{"profile": {'+'"firstName": "'+ClinicAdminAcc.FirstName +'","lastName": "'+ClinicAdminAcc.LastName+'","email": "'+clinicadminemail.toLowercase()+'","login": "'+userName.toLowercase()+'","countryCode": "'+ac.country_vod__r.name+'"},"credentials": {"recovery_question": {"question": "'+portalSetting.Default_Recovery_Question_AGN__c+'","answer": "'+portalSetting.Default_Recovery_Answer_AGN__c+'"}},'+'"groupIds": [' +AGN_ICL_Portal_Settings__c.getInstance().Okta_Group_Id_AGN__c + ']}';              
            //End 
            String userCreateMsg = '';
            if(!Test.isRunningTest()){
                userCreateMsg = oUtil.CreateUser(reqBody);
            }
            else
            {
                userCreateMsg = '{'+
                    +'"messagetype": "SUCCESS",'+
                    +'"Id": "dkfddf45fssdhf" '+
                    +'}';  
            }
            Map < String, Object > userCreateMsgMap = (Map < String, Object > ) JSON.deserializeUntyped(userCreateMsg);
            
            if (String.valueOf(userCreateMsgMap.get('messagetype')).equalsIgnoreCase('SUCCESS')) {
                returnMessage = 'SUCCESS';
                String userOktaId = String.valueOf(userCreateMsgMap.get('Id'));
                if (!String.isEmpty(userOktaId)) {
                    //createClinicAdminUser(ClinicAdminAcc1);
                    Account acc = [Select Okta_Id_AGN__c From Account Where Id =: ClinicAdminAcc.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    //------CheckMarx Phase2--Added on 24/09/2020-------------------------------
                    list<Account> accountthirdList= new list<Account>();
                    accountthirdList.add(acc);
                    String objAccountthird = 'Account';
                    SObjectType accountthirdObjType = ((SObject)(Type.forName('Schema.'+objAccountthird).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(accountthirdList,accountthirdObjType,'UPDATE');
                    //------CheckMarx Phase2--Ends here------------------------------------------------------
                    
                    update acc;
                }
                SendExpiryLinkChangePassword(ClinicAdminAcc,portalSetting,locid,userlang,clinicadminemail);
            }
        }
        //User found
        else {
            String userOktatatus = (String) m.get('Status');
            String userOktaId = (String) m.get('Id');
            //Not inactive (DEPROVISIONED)
            if (!userOktatatus.equalsignorecase('DEPROVISIONED')) {
                oUtil.AddUserToGroup((String)portalSetting.Okta_Group_Id_AGN__c, userOktaId);
                returnMessage = 'SUCCESS';
                if (!String.isEmpty(userOktaId)) {
                    Account acc = [Select Okta_Id_AGN__c From Account Where Id =: ClinicAdminAcc.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    //------CheckMarx Phase2--Added on 24/09/2020-------------------------------
                    list<Account> accountsecondList= new list<Account>();
                    accountsecondList.add(acc);
                    String objAccountsecond = 'Account';
                    SObjectType accountsecondObjType = ((SObject)(Type.forName('Schema.'+objAccountsecond).newInstance())).getSObjectType();
                    AGN_FLSCheck.check(accountsecondList,accountsecondObjType,'UPDATE');
                    //------CheckMarx Phase2--Ends here------------------------------------------------------
                    update acc;
                }
                //SendExpiryLinkChangePassword(ClinicAdminAcc,portalSetting,locid,userlang,clinicadminemail);
            } else {
                returnMessage = 'DEPROVISIONED';
            }
        }
        
        
    }
    
    public static void SendExpiryLinkChangePassword(Account ClinicAdminAcc,AGN_ICL_Portal_Settings__c portalSetting,String locid,String userlang,String clinicadminemail) {
        String dataToEncrypt;
        String encryptedData;
        String privateKey = (String)portalSetting.Encryption_Private_Key_AGN__c;//AGN_OAMConstant.PRIVATEKEY; //config
        
        AGN_ICL_CryptoUtils cUtil = new AGN_ICL_CryptoUtils();
        
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(portalSetting.Password_Activation_Token_Valid_till_AGN__c));
        
        String passwordResetToken = cUtil.getRandomKey();
        //------CheckMarx Phase2--Added on 17/09/2020-------------------------------
        //String forgotpassword = 'First_time_Password';
        String forgotpassword =System.Label.AGN_ICL_PasswordResetToken;
        //------CheckMarx Phase2--Ends here--------------------------------------- 
        dataToEncrypt = '{' +
            +'"portalusername": "' + clinicadminemail.toLowercase() + '.' + (String)portalSetting.ICL_Username_Suffix_AGN__c + '",' +
            +'"portaluseremail": "' + clinicadminemail.toLowercase() + '",' +
            +'"countrycode": "' + ClinicAdminAcc.Country_Code__c + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '",' +
            +'"reset": "' + forgotpassword + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        
        //Update generated password reset token with the Account/Customer
        Account acc = [Select Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: ClinicAdminAcc.Id];
        acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        //------CheckMarx Phase2--Added on 24/09/2020-------------------------------
        list<Account> accountfirstList= new list<Account>();
        accountfirstList.add(acc);
        String objAccountfirst = 'Account';
        SObjectType accountfirstObjType = ((SObject)(Type.forName('Schema.'+objAccountfirst).newInstance())).getSObjectType();
        AGN_FLSCheck.check(accountfirstList,accountfirstObjType,'UPDATE');
        //------CheckMarx Phase2--Ends here------------------------------------------------------
        update acc;
        
        SendWelcomeMail(ClinicAdminAcc, encryptedData,portalSetting,locid,userlang,clinicadminemail);  
    }
    
    public static void SendWelcomeMail(Account clinicAdmin, String encryptedData,AGN_ICL_Portal_Settings__c portalSetting,String locid,String userlang,String clinicadminemail){
        Decimal expirationInDays = portalSetting.Password_Activation_Token_Valid_till_AGN__c/24; 
        Map<String, String> mapSubjectParams = new Map<String, String>();
        List<Locator_Listing_AGN__c> ClinicName = [SELECT Name,DCR_Reference_Number_AGN__c,ICL_Registration_Case__r.CaseNumber FROM Locator_Listing_AGN__c where Id =: locid];
        String expLink = portalSetting.ICL_Community_Portal_Base_URL_AGN__c+portalSetting.ICL_Community_Portal_Suffix_AGN__c+ '/AGN_ICL_OktaFirstChangePassword?token=' + encryptedData ;

        
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => clinicAdmin.FirstName,
                '{!Recipient.LastName}' => clinicAdmin.LastName,
                '{!Recipient.Email}' => clinicadminemail.toLowercase(),
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd'),
                '{!ExpiryLink}' => expLink,
                '{!Recipient.ClinicName}' => ClinicName[0].Name,
                '{!Recipient.DCRNumber}' => ClinicName[0].DCR_Reference_Number_AGN__c,
                '{!Recipient.CaseNumber}' => ClinicName[0].ICL_Registration_Case__r.CaseNumber
                };
                    
                    List<Messaging.SendEmailResult> listEmailResult = null;
        List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailTemplateName = 'ICL Registration Welcome_' + userlang;
        //String emailTemplateName = 'AGN_ICL_Password_Reset';
        String fromEmailAddress = (String)portalSetting.From_Email_Address_AGN__c;
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE Name = :emailTemplateName limit 1];  

        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: fromEmailAddress];
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        else{
            mail.setSenderDisplayName('Allergan Clinic Locator Portal'); 
        } 
        String subject = emailTemplate.Subject;
        mail.setSubject(subject); 
        
        String htmlBody = emailTemplate.HtmlValue;
        String plainBody = emailTemplate.Body;
        for (String key : mapBodyParams.keySet()) {
            htmlBody = htmlBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
            plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
        }
        mail.setToAddresses(new String[] { clinicadminemail.toLowercase() }); 
        mail.setHtmlBody(htmlBody);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(plainBody);
        mail.setCharset('UTF-8');
        listSingleEmailMessages.add(mail);
        
        ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();
        //Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(eTMap.get(emailTemplate.id, null, LocObj.id);
        emailLog.Subject_AGN__c =emailTemplate.Subject;
        emailLog.From_AGN__c = fromEmailAddress;          
        emailLog.Body_AGN__c = htmlBody;
        emailLog.Sent_On_AGN__c = datetime.now();
        emailLog.To_AGN__c = clinicadminemail.toLowercase();
      
        if(!Test.isRunningTest()){
            listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
            if(listEmailResult.size() > 0)
            { 
                emailLog.Success_Error_Message_AGN__c = listEmailResult[0].isSuccess() ? 'success' : JSON.serialize(listEmailResult[0].errors); 
                //------CheckMarx Phase2--Added on 18/11/2020----------
                List<ICL_Email_Status_Log_AGN__c> emailLogList =  new  List<ICL_Email_Status_Log_AGN__c> ();
                emailLogList.add(emailLog);
                String objlog = 'ICL_Email_Status_Log_AGN__c';
                SObjectType objlogType = ((SObject)(Type.forName('Schema.'+objlog).newInstance())).getSObjectType();
                AGN_FLSCheck.check(emailLogList,objlogType,'INSERT');
                //------CheckMarx Phase2--Ends here----------
                insert emailLog;
            }
        }
        
        
    }
    
}