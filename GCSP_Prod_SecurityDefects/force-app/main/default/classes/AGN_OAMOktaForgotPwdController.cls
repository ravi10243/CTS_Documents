public class AGN_OAMOktaForgotPwdController {
    
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
    public Integer btnClickCnt {get;set;}
    
    //forgot password
    public String username {get; set;}
    public String userEmail {get; set;}
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
    
    public AGN_OAMOktaForgotPwdController(){
        this.btnClickCnt = 0;
        isSuccess=false;
        renderUserName = true;
        renderQAPassword = false;
        
        userRecord = [select Id, Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        //to support multiple languages for Country (eg. Canada having en_CA and fr_CA)
        String language = ApexPages.currentPage().getParameters().get('language');
        if (!String.isBlank(language)){
            this.userLanguage = language;
        }
        else{
            if(userRecord.Country_Code__c.equalsIgnoreCase('BR')){
            	this.userLanguage = UserInfo.getLanguage(); //getting language from Community Guest User
            }
            else{
                this.userLanguage = UserInfo.getLocale(); //getting language from Community Guest User
            }
        }
        //userLanguage = UserInfo.getLanguage();
        
        //userRecord = [select Id, Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        USERNAME_SUFFIX = (String)OAM_User_Settings__c.getValues(userRecord.Country_Code__c).get('Username_Suffix__c'); 
        registrationStep1Page = (String)AGN_GCSP_Settings__c.getValues(userRecord.Country_Code__c).get('Registration_Step1_Page__c');
        
        //Start-Okta
        OKTABASEURL = (String)AGN_GCSP_Settings__c.getValues(userRecord.Country_Code__c).get('Okta_Base_URL_AGN__c');
        OKTAOAUTH2ISSUER = (String)AGN_GCSP_Settings__c.getValues(userRecord.Country_Code__c).get('Okta_OAuth2_Issuer_AGN__c');
        OKTAREDIRECTURL = (String)AGN_GCSP_Settings__c.getValues(userRecord.Country_Code__c).get('Okta_Redirect_URL_AGN__c');
        //End-Okta
    }
    
    
    public PageReference customforgotPassword() {
        
        PageReference pRef = null;
        
        if(this.userEmail == null || String.isBlank(this.userEmail)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Please_Enter_Username));
        }
        else{
            this.username = this.userEmail + '.'+ USERNAME_SUFFIX;
            User[] currentUser = [Select Username,FirstName, LastName, Country_Code__c, Email, Account.Id, Contact.Id, LocaleSidKey, LanguageLocaleKey from User where username =: this.username and isactive=true limit 1];
            
            if (currentUser.size() > 0){
                this.resetUserRecord = currentUser[0];
                System.debug('@@@customforgotPassword->Country_Code__c-->' + this.resetUserRecord.Country_Code__c);
                if(this.resetUserRecord.Country_Code__c.equalsIgnoreCase('BR')){
                    this.userLanguage = this.resetUserRecord.LanguageLocaleKey;
                }
                else{
                	this.userLanguage = this.resetUserRecord.LocaleSidKey;    
                }	
                System.debug('@@@customforgotPassword->userLanguage-->' + this.userLanguage);
                renderUserName = false;
                renderQAPassword = true;
                AGN_OktaUtils oUtil = new AGN_OktaUtils();
                String oktaUser = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? this.username : this.userEmail;
                String okatMessage = oUtil.GetSecurityQuestion(oktaUser);
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(okatMessage);
                String messagetype = (String)m.get('messagetype');
                String oktaUserStatus = (String)m.get('oktauserstatus');
                
                if(messagetype.equalsIgnoreCase('SUCCESS')){
                    this.recoveryQuestion = (String)m.get('message');
                    if(!String.isEmpty(this.recoveryQuestion)){
                        
                        if(this.btnClickCnt > 0 && InputValidation()){
                            if(oktaUserStatus.equalsIgnoreCase('ACTIVE') 
                               || oktaUserStatus.equalsIgnoreCase('PASSWORD_EXPIRED') 
                               || oktaUserStatus.equalsIgnoreCase('PASSWORD_WARN')
                               || oktaUserStatus.equalsIgnoreCase('STAGED')){
                                   
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
                                       //apexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.AGN_OAM_Update_Successful_login_new_password));
                                       //AGN_OAMCustomerRegUtils.SendMailPasswordChangeConfirmation(this.resetUserRecord.FirstName, this.resetUserRecord.Email);
                                       isSuccess=true;
                                       //Do automatic login
                                       pRef = oktaLogin();
                                   }
                                   else
                                   {
                                       String errorSummary = (String)okatSetPwdRespMap.get('message');
                                       if(errorSummary.containsIgnoreCase('password requirements were not met')){
                                           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Password_requirements_were_not_met));
                                       }
                                       else if(errorSummary.containsIgnoreCase('The credentials provided were incorrect')){
                                           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Okta_Recovery_Ans_Incorrect));                                           
                                       }
                                       else if(errorSummary.containsIgnoreCase('Password cannot be your current password')){
                                           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Okta_OldNewPassword));                                           
                                       }
                                       else if(errorSummary.containsIgnoreCase('User is currently locked out')){
                                           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Okta_User_Locked));                                           
                                       }
                                       else{
                                           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorSummary));
                                       }
                                       isSuccess=false;
                                   }
                               }
                            else if(oktaUserStatus.equalsIgnoreCase('PROVISIONED') || oktaUserStatus.equalsIgnoreCase('RECOVERY')){
                                String reqBody;
                                
                                String reqPrefix = '{'+
                                    +'"credentials": {';                              
                                String reqPWDBody = '"password" : { "value": "'+ this.newPassword +'"}';
                                reqBody = reqPrefix + reqPWDBody +'}}';
                                
                                String resMessage = oUtil.ChangePassword(reqBody, oktaUser);
                                
                                if(resMessage.equalsignorecase('SUCCESS')){
                                    //Do automatic login
                                    pRef = oktaLogin();
                                    isSuccess = true;
                                }
                                else
                                {
                                    isSuccess = false;
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, resMessage));
                                } 
                            }
                            else //if(oktaUserStatus.equalsIgnoreCase('DEPROVISIONED'))
                            {
                                apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'User\'s Okta Status : ' + oktaUserStatus +', please get in touch with customer service team.'));
                                //apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Okta User Status DEPROVISIONED, call Customer Service'));
                                isSuccess = false;
                            }
                        }
                    }
                    else{
                        apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Recovery_question_not_defined));
                        isSuccess=false;
                    }
                }
                else{
                    apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, (String)m.get('message')));
                    isSuccess=false;
                }
                this.btnClickCnt ++;
            }
            else{
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_User + this.username +System.Label.AGN_OAM_Not_found));
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_User +' '+ this.userEmail +' '+System.Label.AGN_OAM_Not_found));
                isSuccess=false;
            }
        }
        return pRef;
    }
    
    public static Boolean nullOrEmpty(Object o) {
        return (null == o) ||
            ((o instanceof String) && (0 == ((String)o).trim().length())) ||
            ((o instanceof List<object>) && (0 == ((List<object>)o).size()));
    }
    
    public PageReference oktaLogin() {
        
        String oktaToken = '';
        PageReference retpage = null;
        
        AGN_OktaUtils.Session oktaSession = new AGN_OktaUtils.Session();
        
        //String userName = 'avijit_de@sharklasers.com';
        //String passWord = 'Asdf!12345';
        
        Boolean loginSuccessful  = false;
        String oktaError;
        String oktaUser = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? this.username : this.userEmail;
        String bodyString = '{ "username" : "'+ oktaUser +'", "password" : "'+ this.newPassword +'" }';
        //String bodyString = '{ "username" : "'+ userName +'", "password" : "'+ passWord +'" }';
        //String method = 'POST';
        
        AGN_OktaUtils okta = new AGN_OktaUtils();
        
        HttpResponse response = okta.CheckOktaLogin(bodyString);
        
        if(response != null){
            if (response.getStatusCode() == 200) { //success
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
                //String startURL = '&startURL=' + Site.getbaseUrl()+'/s';
                //String redirectURL = EncodingUtil.urlEncode(startURL, 'UTF-8');
                String redirectURL = AGN_OAMConstant.OKTAREDIRECTURL;//(String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Okta_Redirect_URL_AGN__c');
                //String retUrl = EncodingUtil.urlEncode('https://allergandev.okta.com/home/salesforce_portal/0oa1ejfqjexdoPawW1d8/1339','UTF-8');
                String retUrl = EncodingUtil.urlEncode(redirectURL,'UTF-8');
                retpage = new PageReference(AGN_OAMConstant.OKTABASEURL +'/login/sessionCookieRedirect?token='+ oktaToken +'&redirectUrl=' + retUrl);
                //https://acndev-allergancommunity.cs10.force.com/AllerganPortal/login?so=00DD0000000JsCM
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
    
    public PageReference CheckURLParam() {
        
        try{
            String userEmail = ApexPages.currentPage().getParameters().get('un');
            if (!String.isBlank(userEmail)){
                this.userEmail = userEmail;
                customforgotPassword();
            }
        }catch(Exception ex){}
        
        return null;
    }
    public Boolean InputValidation(){
        
        if(this.recoveryAnswer == null || String.isBlank(this.recoveryAnswer)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,  System.Label.AGN_OAM_Enter_Recovery_Answer));
            return false;
        }
        if(this.newPassword == null || String.isBlank(this.newPassword)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Enter_New_Password));
            return false;
        }
        if(this.verifyNewPassword == null || String.isBlank(this.verifyNewPassword)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Please_verify_new_password));
            return false;
        }
        if(!this.verifyNewPassword.equals(this.newPassword)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_New_Password_and_Confirmation_not_same));
            return false;
        }
        return true;
    }
    
    public PageReference changePassword() {
        
        return Site.changePassword(newPassword, verifyNewPassword);    
    }
    public PageReference sendQAResetLink() {
        Boolean hasOktaRecoveryQuestion = (Boolean)!String.isEmpty(this.recoveryQuestion);
        AGN_OAMPortalCustomerRegUtils.forgotRecoveryQA(resetUserRecord, hasOktaRecoveryQuestion);
        /*if(userLanguage.equalsIgnoreCase('en_AU') || userLanguage.equalsIgnoreCase('en_NZ') || userLanguage.equalsIgnoreCase('pt_BR')){
            AGN_OAMPortalCustomerRegUtils.forgotRecoveryQA(resetUserRecord, hasOktaRecoveryQuestion);
        }
        else{
        	AGN_OAMCustomerRegUtils.forgotRecoveryQA(resetUserRecord, hasOktaRecoveryQuestion);
        }
		*/
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.AGN_OAM_Successfully_reset_and_check_inbox));
        isSuccess=true;
        return null;    
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
}