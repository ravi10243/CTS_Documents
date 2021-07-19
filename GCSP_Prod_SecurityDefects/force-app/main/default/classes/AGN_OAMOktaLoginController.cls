public class AGN_OAMOktaLoginController {
    
    public String siteURL {get;set;}
    public String userLanguage {get;set;}
    public User userRecord {get;set;}
    public User resetUserRecord {get;set;}
    public String USERNAME_SUFFIX {get;set;}
    public String dusername{get;set;}
    public String dpassword{get;set;}
    public string musername{get;set;}
    public string mpassword{get;set;}
    public string registrationStep1Page{get;set;}
    public Boolean renderUserName {get;set;}
    public Boolean renderQAPassword {get;set;}
    
    //forgot password
    public String username {get; set;}   
    public boolean isSuccess {get; set;} 
    public String recoveryQuestion {get; set;} 
    public String recoveryAnswer {get; set;}
    public String newPassword {get; set;}
    
    //change password
    public String oldPassword {get; set;}
    public String verifyNewPassword {get; set;}
    
    //Start-Okta
    public String OKTABASEURL{get;set;}
    public string OKTAOAUTH2ISSUER{get;set;}
    public string OKTAREDIRECTURL{get;set;}
    //End-Okta    
    
    public String selectedLanguage {get;set;}
    
    public PageReference forwardToStartPage() {
        String selectedCountry;
        String userCountryCode;
        userRecord = [select Id, Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        userCountryCode = userRecord.Country_Code__c;
        List<AGN_GCSP_Country_Lang_Settings__c> allCountryLangSteeings = AGN_GCSP_Country_Lang_Settings__c.getall().values();
        for (AGN_GCSP_Country_Lang_Settings__c singleCountry: allCountryLangSteeings) {
            if(singleCountry.Country_Code_AGN__c == userRecord.Country_Code__c) {
                selectedCountry = singleCountry.Name;
            }
        }
        System.debug('---> selectedCountry: ' + selectedCountry);
        String langCode = AGN_GCSP_Country_Lang_Settings__c.getValues(selectedCountry).Lang_Code_AGN__c;
        String countryCode = AGN_GCSP_Country_Lang_Settings__c.getValues(selectedCountry).Country_Code_AGN__c;
        
        String urlToRedirect;
        AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
        final String COMMUNITY_BASE_URL = commonOktaConfig.Community_Base_URL_AGN__c;
        final String COMMUNITY_SUFFIX = commonOktaConfig.Community_Suffix_AGN__c;        
        final String siteLandingUrl = commonOktaConfig.Site_Landing_URL_AGN__c;
        Boolean issiteLanding = false;
        if(userCountryCode.equalsIgnoreCase('GB') || userCountryCode.equalsIgnoreCase('IE') || userCountryCode.equalsIgnoreCase('AN') || userCountryCode.equalsIgnoreCase('AU') || userCountryCode.equalsIgnoreCase('NZ')){
            urlToRedirect = siteLandingUrl;
            issiteLanding = true;
        }else{
            if(String.isEmpty(COMMUNITY_SUFFIX) || COMMUNITY_SUFFIX.equals('/') ) {
                urlToRedirect = COMMUNITY_BASE_URL;
            }
            else{
                urlToRedirect = COMMUNITY_BASE_URL + COMMUNITY_SUFFIX;
            }
            string landingPage = !String.isEmpty(commonOktaConfig.Redirection_Page__c) ? commonOktaConfig.Redirection_Page__c : ''; 
            urlToRedirect += '/'+landingPage;
        }
        
        PageReference pageRef = new PageReference(urlToRedirect);
        pageRef.setRedirect(true);
        if(!issiteLanding){
            if(String.isNotBlank(countryCode)){
                pageRef.getParameters().put('country',countryCode); 
            }
            if(String.isNotBlank(langCode)){
                pageRef.getParameters().put('language',langCode); 
            }
        }      
       
        return pageRef;
        
    }
    
    public AGN_OAMOktaLoginController(){
        
        isSuccess=false;
        renderUserName = true;
        renderQAPassword = false;
        
        if(ApexPages.currentPage().getParameters().get('language') != null){
            userLanguage = ApexPages.currentPage().getParameters().get('language');
        }else {         
            userLanguage = UserInfo.getLocale();
        }
        
        system.debug('==========userLanguage========'+userLanguage);
        userRecord = [select Id, Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        USERNAME_SUFFIX = (String)OAM_User_Settings__c.getValues(userRecord.Country_Code__c).get('Username_Suffix__c'); 
        registrationStep1Page = (String)AGN_GCSP_Settings__c.getValues(userRecord.Country_Code__c).get('Registration_Step1_Page__c');
        
        //Start-Okta
        OKTABASEURL = (String)AGN_GCSP_Settings__c.getValues(userRecord.Country_Code__c).get('Okta_Base_URL_AGN__c');
        OKTAOAUTH2ISSUER = (String)AGN_GCSP_Settings__c.getValues(userRecord.Country_Code__c).get('Okta_OAuth2_Issuer_AGN__c');
        OKTAREDIRECTURL = (String)AGN_GCSP_Settings__c.getValues(userRecord.Country_Code__c).get('Okta_Redirect_URL_AGN__c');
        //End-Okta
        
        //Site URL
        String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(userRecord.Country_Code__c).get('Community_Base_URL_AGN__c');
        String comSuffix = (String)AGN_GCSP_Settings__c.getValues(userRecord.Country_Code__c).get('Community_Suffix_AGN__c');
        
         if(comSuffix.equals('/') || String.isBlank(comSuffix)){
             siteURL = comBaseURL;
         }
         else{
             siteURL = comBaseURL + comSuffix;
         }
    }
    
    public List<SelectOption> getLanguages() {
        AGN_OAMLanguageSelectorController con = new AGN_OAMLanguageSelectorController();
        return con.getLanguages();
    }
    
    public PageReference refreshLanguage(){
        system.debug('inside refresh language'+ selectedLanguage);
        
        if(String.isNotBlank(userLanguage)){        
            PageReference page = new PageReference('/AGN_CustomerPortalOktaLogin?language='+userLanguage);
            page.setRedirect(true);
            return page;
        }
        return null;
    }
      
    /*
    public void customforgotPassword() {
        if(this.username == null || String.isBlank(this.username)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Enter Username'));
        }
        else{
            User[] currentUser = [Select Username,FirstName, LastName, Country_Code__c, Email, Account.Id from User where username =: this.username and isactive=true limit 1];
            
            if (currentUser.size() > 0){
                this.resetUserRecord = currentUser[0];
                renderUserName = false;
                renderQAPassword = true;
                AGN_OktaUtils oUtil = new AGN_OktaUtils();
                String okatMessage = oUtil.GetSecurityQuestion(this.username);
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(okatMessage);
                String messagetype = (String)m.get('messagetype');
                if(messagetype.equalsIgnoreCase('SUCCESS')){
                    this.recoveryQuestion = (String)m.get('message');
                    if(!String.isEmpty(this.recoveryQuestion)){
                        if(InputValidation()){
                            String oktaUserId = (String)m.get('oktauserid');
                            
                            //Need to implement escape of JSON body
                            String reqBody = '{'+
                                +'"password" : { "value": "'+ this.newPassword +'"},'+
                                +'"recovery_question" : { "answer": "'+ this.recoveryAnswer +'"}'+
                                +'}';
                            
                            String okatSetPwdResp = oUtil.SetPassword(oktaUserId, reqBody);
                            Map<String, Object> okatSetPwdRespMap = (Map<String, Object>)JSON.deserializeUntyped(okatSetPwdResp);
                            String messagetypeSetPwd = (String)okatSetPwdRespMap.get('messagetype');
                            if(messagetypeSetPwd.equalsIgnoreCase('SUCCESS')){
                                apexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Update is successful. Please login with your new password.'));
                                AGN_OAMCustomerRegUtils.SendMailPasswordChangeConfirmation(this.resetUserRecord);
                                isSuccess=true;
                                //To-do=> Need to send confirmation email
                            }
                            else{
                                apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, (String)okatSetPwdRespMap.get('message')));
                                isSuccess=false;
                            }
                        }
                    }
                    else{
                        apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Recovery Question is not defined'));
                        isSuccess=false;
                    }
                }
                else{
                    apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, (String)m.get('message')));
                    isSuccess=false;
                }
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'User ('+ this.username +') not found in the system'));
                isSuccess=false;
            }
        }
        //isSuccess=false;
    }
    */
    public Boolean InputValidation(){
        
        if(this.recoveryAnswer == null || String.isBlank(this.recoveryAnswer)){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Enter Recovery Answer'));
            return false;
        }
        if(this.newPassword == null || String.isBlank(this.newPassword)){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Enter New Password'));
            return false;
        }
        if(this.verifyNewPassword == null || String.isBlank(this.verifyNewPassword)){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please Enter Verify New Password'));
            return false;
        }
        if(!this.verifyNewPassword.equals(this.newPassword)){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'New Password and Confirm Password is not same'));
            return false;
        }
        return true;
    }
    
    public PageReference changePassword() {
        
        return Site.changePassword(newPassword, verifyNewPassword);    
    }
    /*
    public PageReference sendQAResetLink() {
        AGN_OAMCustomerRegUtils.SendExpiryLinkChangePassword(resetUserRecord);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'You have successfully reset the recovery question. Please check your inbox for further instruction.'));
        isSuccess=true;
        return null;    
    }
*/
    //login
    public PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        return Network.forwardToAuthPage(startUrl, displayType);
    }
    
    public PageReference login() {
        
        if (dusername != '' && dpassword != '')
            return Site.login(dusername.trim() + '.' + USERNAME_SUFFIX, dpassword, null);
        else if (musername != '' && mpassword != '')
            return Site.login(musername.trim() + '.' + USERNAME_SUFFIX, mpassword, null);
        else 
            return null;
    }
    
    public PageReference oktaLogin() {
        String tempUserName = '';
        String passWord = '';
        
        String bodyString = '{ "username" : "'+tempUserName+'", "password" : "'+passWord+'" }' ;
        String method = 'POST';
        
        AGN_OktaUtils okta = new AGN_OktaUtils();
        
        return null;
    } 
    
        public PageReference validateAndLogInOkta() {
        
        PageReference retpage = null;
        String oktaUserName = Apexpages.currentPage().getParameters().get('oktaUserName');
        String oktaPassword = Apexpages.currentPage().getParameters().get('oktaPassword'); 
        String isDesktopReq = Apexpages.currentPage().getParameters().get('isDesktopReq');
        
        String sfdcUserName = oktaUserName + '.'+ USERNAME_SUFFIX;
        System.debug('==========oktaUserName============= ' + oktaUserName);
        System.debug('==========oktaPassword============= ' + oktaPassword);
        System.debug('==========isDesktopReq============= ' + isDesktopReq);
        
        //checking if user is present in Salesforce and active
        List<User> pUser = [Select Id, Username, LanguageLocaleKey from User where UserName =:sfdcUserName and IsActive = true LIMIT 1];
        if(pUser.isEmpty()){
            //USER NOT FOUND
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_User +' '+ oktaUserName +' '+System.Label.AGN_OAM_Not_found));
            return retpage;
        }
        
        AGN_OktaUtils oUtil = new AGN_OktaUtils();
        
        //checking if user is present in OKTA
        String okatMessage = oUtil.isPresentInOkta(oktaUserName);
        Map < String, Object > m = (Map <String, Object>)JSON.deserializeUntyped(okatMessage);
        
        String messagetype = (String) m.get('messagetype');
        String message = (String) m.get('message');
        //messagetype = ERROR -> User not found
        if (messagetype.equalsIgnoreCase('ERROR')) {
            //USER NOT FOUND
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_User +' '+ oktaUserName +' '+System.Label.AGN_OAM_Not_found));
            return retpage;
        }
        //User found
        else{
            String userOktatatus = (String) m.get('Status');
            String userOktaId = (String) m.get('Id');
            
            system.debug('@@@recoveryQuestion@@@'+recoveryQuestion);
            
            userOktatatus = userOktatatus.toUpperCase();
            
            switch on userOktatatus {
                when 'ACTIVE' {
                    retpage = doOktaLogin(oktaUserName, oktaPassword);
                }
                when 'PASSWORD_EXPIRED', 'PASSWORD_WARN', 'RECOVERY', 'STAGED', 'PROVISIONED' {
                    //Redirect to change password screen
                    String urlToRedirect = Site.getbaseUrl() + '/AGN_CustomerOktaForgotPassword?un='+ EncodingUtil.urlEncode(oktaUserName,'UTF-8')+'&language='+pUser[0].LanguageLocaleKey;
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Site.getbaseUrl()));
                    retpage = new PageReference(urlToRedirect);                 
                }
                when else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'User\'s Okta Status : ' + userOktatatus +', please get in touch with customer service team.'));
                    System.debug('userOktatatus' + userOktatatus);
                }
            }
        }
        return retpage;
    }
    
    public static Boolean nullOrEmpty(Object o) {
        return (null == o) ||
            ((o instanceof String) && (0 == ((String)o).trim().length())) ||
            ((o instanceof List<object>) && (0 == ((List<object>)o).size()));
    }
    
    public PageReference doOktaLogin(String oktaUser, String oktaPassword) {
        
        String oktaToken = '';
        PageReference retpage = null;
        Boolean loginSuccessful  = false;
        String oktaError;        
        String bodyString = '{ "username" : "'+ oktaUser +'", "password" : "'+ oktaPassword +'" }';
        
        AGN_OktaUtils okta = new AGN_OktaUtils();
        
        HttpResponse response = okta.CheckOktaLogin(bodyString);
        
        if(response != null){
            if (response.getStatusCode() == 200) { //success
                AGN_OktaUtils.Session oktaSession = new AGN_OktaUtils.Session();
                System.debug('@@@Okta Success response@@@' + response.getBody());
                String stringResponse = response.getBody();
                oktaSession = String.isBlank(stringResponse) ? null : AGN_OktaUtils.parseToSession(stringResponse);
                if(nullOrEmpty(oktaSession.cookieToken)){
                    loginSuccessful = false;
                }
                else{
                    oktaToken = oktaSession.cookieToken;
                    loginSuccessful = true;
                }  
            } else {
                AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
                oktaError = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oktaError));
                System.debug('@@@Okta Error response@@@' + respUserErr);
                loginSuccessful = false;
                retpage = null;  
            }
            
            if(loginSuccessful){
                String redirectURL = AGN_OAMConstant.OKTAREDIRECTURL;
                String retUrl = EncodingUtil.urlEncode(redirectURL,'UTF-8');
                retpage = new PageReference(AGN_OAMConstant.OKTABASEURL +'/login/sessionCookieRedirect?token='+ oktaToken +'&redirectUrl=' + retUrl);
            }
            else{
                retpage = null;
            }
        }
        else{
            retpage = null;
        }
        
        return retpage;
    }
}