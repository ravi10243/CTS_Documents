public class AGN_ICL_OktaFirstChangePwdController {
	public User uInfo {get;set;}
    public String userLanguage {get;set;}
    public String userName {get;set;}
    public String userEmail {get;set;}
    public Id customerAccountId {get;set;}
    public String newPassord {get;set;}
    public String confirmNewPassord {get;set;}
    public String recoveryAnswer {get;set;}
    public String selectedRecoveryQuestion {get;set;}
    public Boolean renderContent {get;set;}
    public Boolean renderPW {get;set;}
    public String passwordResetKey {get;set;}
    public Boolean forgotpassword {get;set;}
    public String oktauserid;
    public String countrycode;
    public Boolean isLinkExpired {get;set;}
    public Boolean isPasswordSame {get;set;}
    public Boolean isRequirementMet {get;set;}
    public AGN_ICL_OktaFirstChangePwdController()
    {
        renderPW = true;
        isLinkExpired =false;
        isPasswordSame =false;
        isRequirementMet =false;
        selectedRecoveryQuestion = (String)AGN_ICL_Portal_Settings__c.getInstance().Okta_Security_Question_AGN__c;
        recoveryAnswer = (String)AGN_ICL_Portal_Settings__c.getInstance().Okta_Security_Answer_AGN__c;
        renderContent = true;
    }
    
    public PageReference ValidateRequest() {
        //renderContent = true;
        //renderPW = true;
        
        
        // For testing/fix design issue, blocking/bypass the code
        //Boolean isBlock = true;
        //if(!isBlock){
        try{
            String token = ApexPages.currentPage().getParameters().get('token');
            String showQA = ApexPages.currentPage().getParameters().get('r'); // if found => only show Q&A (skip showing password option) else show both Q&A and password
            /*String forgot = ApexPages.currentPage().getParameters().get('reset');
            if (!String.isBlank(forgot) && forgot ==''){
                forgotpassword = true;
            }*/
            if (String.isBlank(showQA)){
                renderPW = true;
                //formLabel = System.Label.AGN_OAM_Body_ChangePassword;
                //formTitle = System.Label.AGN_OAM_Okta_Password_Policy; //'Password requirements: at least 8 characters, a lowercase letter, an uppercase letter, a number, no parts of your username';
            }
            else{
                renderPW = false;
                //formLabel = System.Label.AGN_OAM_Body_Change_Recovery_Question_Password_AGN;
                //formTitle = '';
            }
            if (!String.isBlank(token)) { //String.isBlank(token) =>checks for null, empty and all whitespace
                String privateKey = (String)AGN_ICL_Portal_Settings__c.getInstance().Encryption_Private_Key_AGN__c;//AGN_OAMConstant.PRIVATEKEY;
                
                //no need of url decode as gets decoded automatically by Apex
                //token = EncodingUtil.urlDecode(token.trim(),'UTF-8');
                //token = token.replace(' ','+');
                
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Original Token ==>' + token));
                AGN_ICL_CryptoUtils cUtil = new AGN_ICL_CryptoUtils();
                String decryptedData = cUtil.Decrypt('AES256', privateKey, token);
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Decrypted information ==>' + decryptedData));
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(decryptedData);
                Datetime validtill = Datetime.valueOf((String)m.get('validtill'));
                decimal diffNanoSecs = validtill.getTime() - Datetime.now().getTime(); //getTime() returns in Nano Sec
                
                if(diffNanoSecs < 0){ //link is expired
                    isLinkExpired = true;
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Password_Recovery_Link_Expired)); //TODO: need to localize
                    renderContent = false;
                }
                else{
                    this.userName = (String)m.get('portalusername');
                    this.userEmail = (String)m.get('portaluseremail');
                    String passwordResetToken = (String)m.get('passwordResetToken');
                    passwordResetKey = passwordResetToken;
                    if((String)m.get('reset')=='forgot_password')
                    {
                        forgotpassword = true;
                    }
                    User[] currentUser = [Select Locator_Listing_Id_AGN__c,Country_Code__c,contactId,Account.Id,LanguageLocaleKey,Account.Community_Okta_Password_Reset_Token_AGN__c from User where username =: this.userName and isactive=true limit 1];
                    AccountContactRelation acc_con = [SELECT AccountId,Account.IsPersonAccount,ContactId,EndDate,Id,IsActive FROM AccountContactRelation WHERE ContactId =:currentUser[0].contactId and Account.IsPersonAccount = true limit 1];
                    if (currentUser.size() > 0 && acc_con != null){
                        //Locator_Listing_AGN__c loc = [Select id,name,Clinic_Admin_AGN__c,User_Language_AGN__c from Locator_Listing_AGN__c where id =:currentUser[0].Locator_Listing_Id_AGN__c limit 1];
                        String accid = acc_con.AccountId;
                        countrycode = currentUser[0].Country_Code__c;
                        userLanguage = currentUser[0].LanguageLocaleKey;//loc.User_Language_AGN__c;
                        Account acc = [Select id,Community_Okta_Password_Reset_Token_AGN__c From Account Where Id =:accid];
                        /*if(currentUser[0].Account.Community_Okta_Password_Reset_Token_AGN__c != passwordResetToken){ //link is expired
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Password_Recovery_Link_Expired)); //TODO: need to localize
                            renderContent = false;
                        }*/
                        if(acc.Community_Okta_Password_Reset_Token_AGN__c != passwordResetToken){
                            isLinkExpired = true;
                            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Password_Recovery_Link_Expired)); //TODO: need to localize
                            renderContent = false;
                        }
                        else{
                            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,this.userName));
                            renderContent = true;
                            //this.customerAccountId = currentUser[0].Account.Id;
                            this.customerAccountId = acc.Id;
                            //this.userEmail = currentUser[0].Email;
                        }
                    }
                    else{
                        
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Unknown_User)); //TODO: need to localize
                        renderContent = false;
                    }
                }
            }
            else{
                isLinkExpired = true;
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Password_Recovery_Link_Expired)); //TODO: need to localize
                renderContent = false;
            }
        }
        catch(SecurityException se){
            isLinkExpired = true;
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Password_Recovery_Link_Expired)); //TODO: need to localize
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,se.getMessage()));
            renderContent = false;
        }
        catch(Exception ex){
            isLinkExpired = true;
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Password_Recovery_Link_Expired)); //TODO: need to localize
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            renderContent = false;
        }
        //}  
        return null;
    }
    public PageReference updatePwdRecovery() {
        
        PageReference retpage = null;
        //return new PageReference('/AGN_ICL_Registration?country='+'GB'+'&lang='+'en_US');
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, this.selectedRecoveryQuestion));
        if(this.renderPW && (this.newPassord == null || String.isBlank(this.newPassord))){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Enter_New_Password)); //TODO: need to localize
            return null;
        }
        if(this.renderPW && (this.confirmNewPassord == null || String.isBlank(this.confirmNewPassord))){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Enter_Confirm_Password)); //TODO: need to localize
            return null;
        }
     
        if(!String.isBlank(this.newPassord) && !String.isBlank(this.confirmNewPassord) && !this.confirmNewPassord.equals(this.newPassord)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_ICL_New_and_Confirm_Password_Mismatch)); //TODO: need to localize
            return null;
        }      
        //Updated to check if password contains username
        if(this.renderPW && (this.newPassord == this.userEmail) || (this.confirmNewPassord == this.userEmail)){
            isPasswordSame =false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, System.Label.AGN_ICL_password_not_username)); 
            //isPasswordSame =false;
            return null;
        }
     
        
        Account accToUpdate = [SELECT Community_Okta_Password_Reset_Token_AGN__c FROM ACCOUNT WHERE Id =: this.customerAccountId];
        
        
        //rechecking if url signature has expired
        if(accToUpdate.Community_Okta_Password_Reset_Token_AGN__c == passwordResetKey){
            String reqBody;
			Boolean toupdateacc = false;            
            String reqPrefix = '{'+
                +'"credentials": {';
            
            String reqQABody = '"recovery_question": {'+
                +'"question": "'+ this.selectedRecoveryQuestion +'",'+
                +'"answer": "'+ this.recoveryAnswer +'"'+
                +'}';
            
            //if(this.renderPW){
                String reqPWDBody = '"password" : { "value": "'+ this.newPassord +'"}';
                reqBody = reqPrefix + reqPWDBody +',' +reqQABody +'}}';
            //}
            //else{
                //reqBody = reqPrefix + reqQABody +'}}';
            //}
            AGN_ICL_OKTA_Util oUtil = new AGN_ICL_OKTA_Util();
            //String oktaUser = this.userEmail;
            if(forgotpassword == true)
            {
                String okatMessage = oUtil.isPresentInOkta(this.userEmail);
                Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
                String messagetype = (String) m.get('messagetype');
                String oktauserStatus = (String)m.get('Status');
                if (messagetype.equalsIgnoreCase('SUCCESS') && oktauserStatus.equalsIgnoreCase('ACTIVE')) {
                    oktauserid = (String)m.get('Id');
                    String reqforgotBody = '{'+
                        +'"password" : { "value": "'+ this.newPassord +'"},'+
                        +'"recovery_question" : { "answer": "'+ this.recoveryAnswer +'"}'+
                        +'}';
                    String okatSetPwdResp = oUtil.SetPassword(oktauserid, reqforgotBody);
                    Map<String, Object> okatSetPwdRespMap = (Map<String, Object>)JSON.deserializeUntyped(okatSetPwdResp);
                    String messagetypeSetPwd = (String)okatSetPwdRespMap.get('messagetype');
                    if(messagetypeSetPwd.equalsIgnoreCase('SUCCESS')){
                        //Do automatic login
                        //pRef = oktaLogin();
                        toupdateacc = true;
                    }
                    else{
                        String errorSummary = (String)okatSetPwdRespMap.get('message');
                        if(errorSummary.containsIgnoreCase('E0000001')){
                            isPasswordSame =true;
                            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Okta_OldNewPassword));
                        }else{
                        apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, (String)okatSetPwdRespMap.get('message')));
                        //isSuccess=false;
                      }
                    }
                }
                else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Unknown_User));
                    return null;
                }
            }
            else
            {
                AGN_ICL_OktaUserFailedResponse resMessage = oUtil.ChangeOktaPassword(reqBody, this.userEmail);
                if(resMessage.errorCode.equalsignorecase('SUCCESS')){
                    toupdateacc = true;
                    renderContent = false;
                    if(this.renderPW){
                        //Do automatic login
                        //retpage = oktaLogin(); ***************
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.AGN_OAM_Update_Successful_login_new_password)); //TODO: need to localize
                    }
                    else{
                        //Redirect to change password screen with Email as parameter
                        //retpage = redirectToChangePasswordScreen();
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Successfully updated Recovery Q&A'));
                    }
                    
                }
                else
                {
                    String errorSummary = resMessage.errorCauses.size() >0 ? resMessage.errorCauses[0].errorSummary : resMessage.errorSummary;
                    isRequirementMet =true;
                   // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, errorSummary));
                    
                }
            }
            if(toupdateacc){
                try{                   
                        accToUpdate.Community_Okta_Password_Reset_Token_AGN__c = '0';
                        update accToUpdate;
                    retpage = new PageReference('/AGN_ICL_Registration?country='+countrycode+'&lang='+userLanguage);
                    
                    } catch(DmlException e) {
                    }
            }
        }
        else
        {
            isLinkExpired = true;
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_ICL_Password_Recovery_Link_Expired)); //TODO: need to localize
            renderContent = false;
        }
        return retpage;
    }
    
    public PageReference redirectToChangePasswordScreen() {
        String email = this.userEmail;
        //String email = 'avijit_DE@sharklasers.com';
        String urlToRedirect = Site.getbaseUrl() + '/AGN_CustomerOktaForgotPassword?un='+ EncodingUtil.urlEncode(email,'UTF-8');
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Site.getbaseUrl()));
        PageReference retpage = new PageReference(urlToRedirect);
        return retpage;
    }
    
    public PageReference oktaLogin() {
        
        String oktaToken = '';
        PageReference retpage = null;
        
        AGN_ICL_OKTA_Util.Session oktaSession = new AGN_ICL_OKTA_Util.Session();
        
        Boolean loginSuccessful  = false;
        String oktaError;
        //String oktaUser = 'avijit_de@sharklasers.com';
        String oktaUser = this.userEmail;
        String bodyString = '{ "username" : "'+ oktaUser +'", "password" : "'+ this.newPassord +'" }';
        
        AGN_ICL_OKTA_Util okta = new AGN_ICL_OKTA_Util();
        
        HttpResponse response = okta.CheckOktaLogin(bodyString);
        
        if(response != null){
            if (response.getStatusCode() == 200) { //success
                String stringResponse = response.getBody();
                oktaSession = String.isBlank(stringResponse) ? null : AGN_ICL_OKTA_Util.parseToSession(stringResponse);
                if(nullOrEmpty(oktaSession.cookieToken)){
                    loginSuccessful = false;
                }
                else{
                    oktaToken = oktaSession.cookieToken;
                    loginSuccessful = true;
                }  
            } else {
                AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(response.getBody());
                oktaError = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oktaError));
                loginSuccessful = false;
                retpage = null;  
            }
            
            if(loginSuccessful){
                //String startURL = '&startURL=' + Site.getbaseUrl()+'/s';
                //String redirectURL = EncodingUtil.urlEncode(startURL, 'UTF-8');
                String redirectURL = (String)AGN_ICL_Portal_Settings__c.getInstance().Okta_Redirect_URL_AGN__c;//AGN_OAMConstant.OKTAREDIRECTURL;//(String)AGN_GCSP_Settings__c.getValues(uInfo.Country_Code__c).get('Okta_Redirect_URL_AGN__c');
                //String retUrl = EncodingUtil.urlEncode('https://allergandev.okta.com/home/salesforce_portal/0oa1ejfqjexdoPawW1d8/1339','UTF-8');
                String retUrl = EncodingUtil.urlEncode(redirectURL,'UTF-8');
                retpage = new PageReference((String)AGN_ICL_Portal_Settings__c.getInstance().ICL_Community_Portal_Base_URL_AGN__c +'/login/sessionCookieRedirect?token='+ oktaToken +'&redirectUrl=' + retUrl);
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
    
     public static Boolean nullOrEmpty(Object o) {
        return (null == o) ||
            ((o instanceof String) && (0 == ((String)o).trim().length())) ||
            ((o instanceof List<object>) && (0 == ((List<object>)o).size()));
    }
}