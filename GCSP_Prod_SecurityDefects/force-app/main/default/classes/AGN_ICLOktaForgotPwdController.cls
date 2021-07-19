public class AGN_ICLOktaForgotPwdController {
    public String userLanguage {get;set;}
    public String USERNAME_SUFFIX {get;set;}
    
    public String oktausername {get;set;}
    public String sfusername {get;set;}
    public Boolean renderPW {get;set;}
    public String Loginlink {get;set;}
    public String country {get;set;}
    //Start-Okta
    public String OKTABASEURL;
    public string OKTAOAUTH2ISSUER;
    public string OKTAREDIRECTURL;
    //End-Okta 
    public Boolean isValidUsername {get;set;}
    public String getlabelname{get;set;}
    
    
    public AGN_ICLOktaForgotPwdController(){
        
        userLanguage = ApexPages.currentPage().getParameters().get('lang');
        country = ApexPages.currentPage().getParameters().get('country');
        Loginlink = '/AGN_ICL_Registration?country='+country+'&lang='+userLanguage;
        AGN_ICL_Portal_Settings__c ICLAuth = AGN_ICL_Portal_Settings__c.getinstance();
        OKTABASEURL = ICLAuth.Okta_Base_URL_AGN__c;
        OKTAOAUTH2ISSUER = ICLAuth.Okta_OAuth2_Issuer_AGN__c;
        OKTAREDIRECTURL = ICLAuth.Okta_Redirect_URL_AGN__c;
        USERNAME_SUFFIX = ICLAuth.ICL_Username_Suffix_AGN__c;
        renderPW = true;
       /* if(country=='CA' && userLanguage=='fr_CA')
        getlabelname=[SELECT Value FROM ExternalStringLocalization WHERE ExternalString.name = 'AGN_ICL_Forgot_Password_Label' and language=:userLanguage].Value;
        
        else
            getlabelname=system.Label.site.forgot_password.Value;*/
                
    }
    
    public PageReference updatePwdRecovery()
    {
        
        PageReference pRef = null;
        if(this.oktausername == null || String.isBlank(this.oktausername)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Please_Enter_Username));
        }
        else
        {
            Boolean isOktapresent = false;
            AGN_ICL_OKTA_Util oUtil = new AGN_ICL_OKTA_Util();
            this.sfusername = this.oktausername + '.'+ USERNAME_SUFFIX;
            User[] currentUser = [Select contactId,Username,FirstName,LanguageLocaleKey,LastName,isactive,Locator_Listing_Id_AGN__c,Country_Code__c, Email, Account.Id from User where username =: this.sfusername and isactive=true limit 1];
            String okatMessage = oUtil.isPresentInOkta(this.oktausername);
            Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
            String messagetype = (String) m.get('messagetype');
            String oktauserStatus = (String)m.get('Status');
            if (messagetype.equalsIgnoreCase('SUCCESS') && oktauserStatus.equalsIgnoreCase('ACTIVE')) {
                isOktapresent = true;
            }
            if (currentUser.size() > 0 && isOktapresent == true){
                try{
                    sendPasswordChangeLink(currentUser[0]);
                }catch(Exception e)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Forgot_Password_Error));
                    oktausername = null;
                }
            }
            else
            {
                if(country == 'CA'){
                    isValidUsername = true;
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Forgot_Pwd_No_Username));
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Forgot_Pwd_No_Username));
                }

                 oktausername = null;
            }
            //renderPW = false;
        }
        //String str  = '/AGN_ICLOktaForgotPwd?country='+country+'&lang='+userLanguage;
        return null;
    }
    
    public void sendPasswordChangeLink(User sfuser){
        String dataToEncrypt;
        String encryptedData;
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String privateKey = (String)portalSetting.Encryption_Private_Key_AGN__c;//AGN_OAMConstant.PRIVATEKEY; //config
        
        AGN_ICL_CryptoUtils cUtil = new AGN_ICL_CryptoUtils();
        
        Datetime requestValidtill = datetime.now().addHours(Integer.valueOf(portalSetting.Password_Activation_Token_Valid_till_AGN__c));
        
        String passwordResetToken = cUtil.getRandomKey();
        String forgotpassword = 'forgot_password';
        
        dataToEncrypt = '{' +
            +'"portalusername": "' + sfuser.Email.toLowercase() + '.' + (String)portalSetting.ICL_Username_Suffix_AGN__c + '",' +
            +'"portaluseremail": "' + sfuser.Email.toLowercase() + '",' +
            +'"countrycode": "' + sfuser.Country_Code__c + '",' +
            +'"validtill": "' + requestValidtill + '",' +
            +'"passwordResetToken": "' + passwordResetToken + '",' +
            +'"reset": "' + forgotpassword + '"' +
            +'}';
        
        
        encryptedData = cUtil.Encrypt('AES256', privateKey, dataToEncrypt);
        encryptedData = EncodingUtil.urlEncode(encryptedData, 'UTF-8');
        AccountContactRelation acc_con = [SELECT AccountId,Account.IsPersonAccount,ContactId,EndDate,Id,IsActive FROM AccountContactRelation WHERE ContactId =:sfuser.contactId and Account.IsPersonAccount = true limit 1];
        //String loc = [Select id,name,Clinic_Admin_AGN__c from Locator_Listing_AGN__c where id =:sfuser.Locator_Listing_Id_AGN__c limit 1][0].Clinic_Admin_AGN__c;
        //updateOktaUserIdInAccount(customerAccount, '', passwordResetToken);
        String accid = acc_con.AccountId;
        //Update generated password reset token with the Account/Customer
        Account acc = [Select Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =:accid];
        acc.Community_Okta_Password_Reset_Token_AGN__c = passwordResetToken;
        update acc;
        
        Decimal expirationInDays = portalSetting.Password_Activation_Token_Valid_till_AGN__c/24; 
        Map<String, String> mapSubjectParams = new Map<String, String>();
        String expLink = portalSetting.ICL_Community_Portal_Base_URL_AGN__c+portalSetting.ICL_Community_Portal_Suffix_AGN__c+ '/AGN_ICL_OktaFirstChangePassword?token=' + encryptedData;
        Map<String, String> mapBodyParams = new Map<String, String> {
            '{!Recipient.FirstName}' => sfuser.FirstName,
                '{!Recipient.LastName}' => sfuser.LastName,
                '{!Recipient.Email}' => sfuser.Email.toLowercase(),
                '{!ExpirationDays}' => String.valueOf(expirationInDays.intValue()),
                '{!Accepteddate}' => DateTime.newInstance(Date.today().year(), Date.today().month(), Date.today().day()).format('YYYY-MMM-dd'),
                '{!ExpiryLink}' => expLink
                };
                    
                    List<Messaging.SendEmailResult> listEmailResult = null;
        List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailTemplateName = 'ICL Forgot Password_' + sfuser.LanguageLocaleKey;
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
        String subject = emailTemplate.Subject;//'Password Reset';
        mail.setSubject(subject); 
        
        String htmlBody = emailTemplate.HtmlValue;
        String plainBody = emailTemplate.Body;
        for (String key : mapBodyParams.keySet()) {
            htmlBody = htmlBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
            plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
        }
        mail.setToAddresses(new String[] { sfuser.Email.toLowercase() });
        mail.setHtmlBody(htmlBody);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(plainBody);
        mail.setWhatId(sfuser.id);
        mail.setCharset('UTF-8');
        listSingleEmailMessages.add(mail);
        //if(!Test.isRunningTest()){
        listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
        renderPW = false;
       
        ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();
        //Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(eTMap.get(emailTemplate.id, null, LocObj.id);
        emailLog.Subject_AGN__c =emailTemplate.Subject;
        emailLog.From_AGN__c = fromEmailAddress;          
        emailLog.Body_AGN__c = htmlBody;
        emailLog.Sent_On_AGN__c = datetime.now();
        emailLog.To_AGN__c = sfuser.Email.toLowercase();
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

        //}
    }
}