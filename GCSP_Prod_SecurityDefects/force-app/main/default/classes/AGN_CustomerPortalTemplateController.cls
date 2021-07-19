public class AGN_CustomerPortalTemplateController {
    
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
    
    public AGN_CustomerPortalTemplateController(){
        isSuccess=false;
        renderUserName = true;
        renderQAPassword = false;
        
        //userLanguage = UserInfo.getLanguage();
        
        if(ApexPages.currentPage().getParameters().get('language') != null){
            userLanguage = ApexPages.currentPage().getParameters().get('language');
        }else{
            
            userLanguage = UserInfo.getLocale();
            //userLanguage = UserInfo.getLanguage();
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
                if(oktaError.containsIgnoreCase('Authentication failed')){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Okta_Auth_Failed));
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oktaError));
                }
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