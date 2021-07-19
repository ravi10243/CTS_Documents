global class AGN_ICL_OktaUserCreationBatch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    global static List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,name,Active_AGN__c,Clinic_Admin_Email_AGN__c,Data_Loaded_AGN__c,Clinic_Admin_AGN__c,Registered_from_OAM_AGN__c,Registered_For_Clinic_Locator_AGN__c,Account_AGN__c,User_Language_AGN__c  FROM Locator_Listing_AGN__c where Registered_For_Clinic_Locator_AGN__c= true and Registered_from_OAM_AGN__c = false and Data_Loaded_AGN__c = true and Active_AGN__c = false]);   
    }
    
     global void execute(Database.BatchableContext bc, List<Locator_Listing_AGN__c> scope){
         
         List<Account> acctoupdate = new List<Account>();
         List<Locator_Listing_AGN__c> loctoupdate = new List<Locator_Listing_AGN__c>();
         for(Locator_Listing_AGN__c loc : scope)
         {
            String locid = loc.id;
            String userlang = loc.User_Language_AGN__c;
            Account ClinicAdminAcc = [Select id,PersonContactId,name,Salutation,FirstName,LastName,PersonEmail,Phone,Primary_Parent_vod__c,Country_Code__c from Account where id =:loc.Clinic_Admin_AGN__c limit 1];
            AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        //Account ClinicAdminAcc = (Account)JSON.deserialize(ClinicAdminAcc1, Account.class);
        String returnMessage = 'FAILURE';
        
        String userName = loc.Clinic_Admin_Email_AGN__c;//ClinicAdminAcc.PersonEmail;
        
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
            string reqBody = '{"profile": {'+'"firstName": "'+ClinicAdminAcc.FirstName +'","lastName": "'+ClinicAdminAcc.LastName+'","email": "'+userName.toLowercase()+'","login": "'+userName.toLowercase()+'","countryCode": "'+ClinicAdminAcc.Country_Code__c+'"},"credentials": {"recovery_question": {"question": "'+portalSetting.Default_Recovery_Question_AGN__c+'","answer": "'+portalSetting.Default_Recovery_Answer_AGN__c+'"}},'+'"groupIds": [' +AGN_ICL_Portal_Settings__c.getInstance().Okta_Group_Id_AGN__c + ']}';              
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
                    Account acc = [Select Okta_Id_AGN__c,Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: ClinicAdminAcc.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    //update acc;
                    
                    loc.Active_AGN__c = true;
                    loctoupdate.add(loc);
                    //update loc;
                    String token = AGN_ICL_OktaUserCreationBatch.SendExpiryLinkChangePassword(ClinicAdminAcc,portalSetting,locid,userlang,userName);
                    acc.Community_Okta_Password_Reset_Token_AGN__c = token;
                    acctoupdate.add(acc);
                    
                }
                
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
                    /*Account acc = [Select Okta_Id_AGN__c,Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: ClinicAdminAcc.Id];
                    acc.Okta_Id_AGN__c = userOktaId; //Update Okta Id in Account/Customer
                    update acc;*/
                }
                //AGN_ICLOktaUserCreation.SendExpiryLinkChangePassword(ClinicAdminAcc,portalSetting,locid,userlang);
            } else {
                returnMessage = 'DEPROVISIONED';
            }
        }
             //loc.Active_AGN__c = true;
             //update loc;
         }
         //------CheckMarx Phase2--Added on 17/09/2020----------
         String objAcc = 'Account';
                                SObjectType accObjType = ((SObject)(Type.forName('Schema.'+objAcc).newInstance())).getSObjectType();
                                AGN_FLSCheck.check(acctoupdate,accObjType,'UPDATE');
         String objloc = 'Locator_Listing_AGN__c';
                                SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objloc).newInstance())).getSObjectType();
                                AGN_FLSCheck.check(loctoupdate,locObjType,'UPDATE');
         //----CheckMarx Phase2--Ends here
         update acctoupdate;
         update loctoupdate;
         if(!Test.isRunningTest()){
            Messaging.sendEmail(listSingleEmailMessages);
        }
     }
    
    public static String SendExpiryLinkChangePassword(Account ClinicAdminAcc,AGN_ICL_Portal_Settings__c portalSetting,String locid,String userlang,String userName) {
        String dataToEncrypt;
        String encryptedData;
        String privateKey = (String)portalSetting.Encryption_Private_Key_AGN__c;//AGN_OAMConstant.PRIVATEKEY; //config
        
        AGN_ICL_CryptoUtils cUtil = new AGN_ICL_CryptoUtils();
        
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(portalSetting.Password_Activation_Token_Valid_till_AGN__c));
        
        String passwordResetToken = cUtil.getRandomKey();
     //------CheckMarx Phase2--Added on 17/09/2020----------
     // String forgotpassword = 'First_time_Password';
        String forgotpassword =System.Label.AGN_ICL_PasswordResetToken;
    //------CheckMarx Phase2--Ends here---------- 
        dataToEncrypt = '{' +
            +'"portalusername": "' + userName.toLowercase() + '.' + (String)portalSetting.ICL_Username_Suffix_AGN__c + '",' +
            +'"portaluseremail": "' + userName.toLowercase() + '",' +
            +'"countrycode": "' + ClinicAdminAcc.Country_Code__c + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '",' +
            +'"reset": "' + forgotpassword + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        
        
        //Update generated password reset token with the Account/Customer
        /*Account acc = [Select Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =: ClinicAdminAcc.Id];
        acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        update acc;*/
        
        SendWelcomeMail(ClinicAdminAcc, encryptedData,portalSetting,locid,userlang,userName); 
        return passwordResetToken;
    }
    
    public static void SendWelcomeMail(Account clinicAdmin, String encryptedData,AGN_ICL_Portal_Settings__c portalSetting,String locid,String userlang,String userName){
        Decimal expirationInDays = portalSetting.Password_Activation_Token_Valid_till_AGN__c/24; 
        Map<String, String> mapSubjectParams = new Map<String, String>();
        
        List<Locator_Listing_AGN__c> ClinicName = [SELECT Name,DCR_Reference_Number_AGN__c FROM Locator_Listing_AGN__c where Id =: locid];
        String expLink = portalSetting.ICL_Community_Portal_Base_URL_AGN__c+portalSetting.ICL_Community_Portal_Suffix_AGN__c+ '/AGN_ICL_OktaFirstChangePassword?token=' + encryptedData ;

        
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => clinicAdmin.FirstName,
                '{!Recipient.LastName}' => clinicAdmin.LastName,
                '{!Recipient.Email}' => userName.toLowercase(),
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd'),
                '{!ExpiryLink}' => expLink,
                '{!Recipient.ClinicName}' => ClinicName[0].Name,
                '{!Recipient.DCRNumber}' => ClinicName[0].DCR_Reference_Number_AGN__c
                };
             
            List<Messaging.SendEmailResult> listEmailResult = null;
        //List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
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
            mail.setToAddresses(new String[] { userName.toLowercase() }); 
            mail.setHtmlBody(htmlBody);
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(plainBody);
        listSingleEmailMessages.add(mail);
        if(!Test.isRunningTest()){
            //listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
        }
        
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }  
}