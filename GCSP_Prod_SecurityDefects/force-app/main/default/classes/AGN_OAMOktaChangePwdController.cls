public class AGN_OAMOktaChangePwdController {
    public User uInfo {get;set;}
    public String userLanguage {get;set;}
    public String userName {get;set;}
    public String userEmail {get;set;}
    public Id customerAccountId {get;set;}
    public String newPassord {get;set;}
    public String confirmNewPassord {get;set;}
    public String recoveryAnswer {get;set;}
    public List<SelectOption> recoveryQuestions {get; set;}
    public String selectedRecoveryQuestion {get;set;}
    public Boolean renderContent {get;set;}
    public Boolean renderPW {get;set;}
    public String formLabel {get;set;}
    public String formTitle {get;set;}
    public String passwordResetKey {get;set;}
    
    //public Component.Apex.OutputText output { public get; private set; }
    //public String labelName { public get; private set; }
    
    public AGN_OAMOktaChangePwdController (){
        
        if(ApexPages.currentPage().getParameters().get('language') != null && !String.isBlank(ApexPages.currentPage().getParameters().get('language'))){
            userLanguage = ApexPages.currentPage().getParameters().get('language');
        }else{
            userLanguage = UserInfo.getLanguage();
        }
        
        uInfo = [SELECT Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        /*uInfo = [SELECT Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];


userLanguage = UserInfo.getLanguage();
recoveryQuestions = new List<SelectOption>();

system.debug('UserLanguage------->'+userLanguage);

String labelName = 'AGN_OAM_Okta_Security_Question_';
String labelValue = getLabelString(labelName,userLanguage);
recoveryQuestions.add(new SelectOption('',''));

for(String val : labelValue.split('_')){

recoveryQuestions.add(new SelectOption(val,val));
}
*/
        //renderContent = true;
        // renderPW = true;
    }
    
    public static String getLabelString(String labelName ,String language){
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        //output.expressions.value = '{!$Label.' + labelName + '}';
        output.expressions.value = '{!$Label.' + labelName + language + '}';
        return String.valueOf(output.value);
    }
    
    public PageReference ValidateRequest() {
        
        //userLanguage = UserInfo.getLanguage();
        
        if(ApexPages.currentPage().getParameters().get('language') != null && !String.isBlank(ApexPages.currentPage().getParameters().get('language'))){
            userLanguage = ApexPages.currentPage().getParameters().get('language');
        }else{
            userLanguage = UserInfo.getLanguage();
        }
        recoveryQuestions = new List<SelectOption>();
        
        system.debug('UserLanguage------->'+userLanguage);
        
        String labelName = 'AGN_OAM_Okta_Security_Question_';
        String labelValue = getLabelString(labelName,userLanguage);
        recoveryQuestions.add(new SelectOption('',''));
        
        for(String val : labelValue.split('_')){
            
            recoveryQuestions.add(new SelectOption(val,val));
        }
        
        try{
            String token = ApexPages.currentPage().getParameters().get('token');
            String showQA = ApexPages.currentPage().getParameters().get('r'); // if found => only show Q&A (skip showing password option) else show both Q&A and password
            if (String.isBlank(showQA)){
                renderPW = true;
                formLabel = System.Label.AGN_OAM_Body_ChangePassword;
                formTitle = System.Label.AGN_OAM_Okta_Password_Policy; //'Password requirements: at least 8 characters, a lowercase letter, an uppercase letter, a number, no parts of your username';
            }
            else{
                renderPW = false;
                formLabel = System.Label.AGN_OAM_Body_Change_Recovery_Question_Password_AGN;
                formTitle = '';
            }
            if (!String.isBlank(token)) { //String.isBlank(token) =>checks for null, empty and all whitespace
                String privateKey = AGN_OAMConstant.PRIVATEKEY;
                
                //no need of url decode as gets decoded automatically by Apex
                //token = EncodingUtil.urlDecode(token.trim(),'UTF-8');
                //token = token.replace(' ','+');
                
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Original Token ==>' + token));
                AGN_CryptoUtils cUtil = new AGN_CryptoUtils();
                String decryptedData = cUtil.Decrypt('AES256', privateKey, token);
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Decrypted information ==>' + decryptedData));
                
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(decryptedData);
                
                Datetime validtill = Datetime.valueOf((String)m.get('validtill'));
                decimal diffNanoSecs = validtill.getTime() - Datetime.now().getTime(); //getTime() returns in Nano Sec
                
                if(diffNanoSecs < 0){ //link is expired
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_OAM_Recovery_Link_Expired)); //TODO: need to localize
                    renderContent = false;
                }
                else{
                    this.userName = (String)m.get('portalusername');
                    this.userEmail = (String)m.get('portaluseremail');
                    String passwordResetToken = (String)m.get('passwordResetToken');
                    passwordResetKey = passwordResetToken;
                    User[] currentUser = [Select Account.Id,Account.Community_Okta_Password_Reset_Token_AGN__c from User where username =: this.userName and isactive=true limit 1];
                    
                    if (currentUser.size() > 0){
                        if(currentUser[0].Account.Community_Okta_Password_Reset_Token_AGN__c != passwordResetToken){ //link is expired
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_OAM_Recovery_Link_Expired)); //TODO: need to localize
                            renderContent = false;
                        }
                        else{
                            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,this.userName));
                            renderContent = true;
                            this.customerAccountId = currentUser[0].Account.Id;
                            //this.userEmail = currentUser[0].Email;
                        }
                    }
                    else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_OAM_Unknown_user)); //TODO: need to localize
                        renderContent = false;
                    }
                }
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_OAM_Recovery_Link_Expired)); //TODO: need to localize
                renderContent = false;
            }
        }
        catch(SecurityException se){
            System.debug('@@@Security exception@@@' + se.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_OAM_Recovery_Link_Expired)); //TODO: need to localize
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,se.getMessage()));
            renderContent = false;
        }
        catch(Exception ex){
            System.debug('@@@Security exception@@@' + ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_OAM_Recovery_Link_Expired)); //TODO: need to localize
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            renderContent = false;
        }
        //}  
        return null;
    }
    
    public PageReference updatePwdRecovery() {
        
        PageReference retpage = null;
        
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, this.selectedRecoveryQuestion));
        if(this.renderPW && (this.newPassord == null || String.isBlank(this.newPassord))){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Enter_New_Password)); //TODO: need to localize
            return null;
        }
        if(this.renderPW && (this.confirmNewPassord == null || String.isBlank(this.confirmNewPassord))){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Enter_Confirm_Password)); //TODO: need to localize
            return null;
        }
        if(this.selectedRecoveryQuestion == null || String.isBlank(this.selectedRecoveryQuestion)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Select_Recovery_Question)); //TODO: need to localize
            return null;
        }
        if(this.recoveryAnswer == null || String.isBlank(this.recoveryAnswer)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Enter_Recovery_Answer)); //TODO: need to localize
            return null;
        }
        
        if(!String.isBlank(this.newPassord) && !String.isBlank(this.confirmNewPassord) && !this.confirmNewPassord.equals(this.newPassord)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_New_Password_and_Confirmation_not_same)); //TODO: need to localize
            return null;
        }
        
        Account accToUpdate = [SELECT Community_Okta_Password_Reset_Token_AGN__c FROM ACCOUNT WHERE Id =: this.customerAccountId];
        
        
        //rechecking if url signature has expired
        if(accToUpdate.Community_Okta_Password_Reset_Token_AGN__c == passwordResetKey){
            String reqBody;
            
            String reqPrefix = '{'+
                +'"credentials": {';
            
            String reqQABody = '"recovery_question": {'+
                +'"question": "'+ this.selectedRecoveryQuestion +'",'+
                +'"answer": "'+ this.recoveryAnswer +'"'+
                +'}';
            
            if(this.renderPW){
                String reqPWDBody = '"password" : { "value": "'+ this.newPassord +'"}';
                reqBody = reqPrefix + reqPWDBody +',' +reqQABody +'}}';
            }
            else{
                reqBody = reqPrefix + reqQABody +'}}';
            }
            
            /* reqBody = '{'+
+'"credentials": {'+
+'"password" : { "value": "'+ this.newPassord +'"}';

String reqBodyQA =',"recovery_question": {'+
+'"question": "'+ this.selectedRecoveryQuestion +'",'+
+'"answer": "'+ this.recoveryAnswer +'"'+
+'}';

if(this.renderPW){
reqBody = reqBody + reqBodyQA +'}}';
}
else{
reqBody = reqBody +'}}';
}
*/
            AGN_OktaUtils oUtil = new AGN_OktaUtils();
            String oktaUser = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? this.username : this.userEmail;
            
            AGN_OktaUserFailedResponse resMessage = oUtil.ChangeOktaPassword(reqBody, oktaUser);
            if(resMessage.errorCode.equalsignorecase('SUCCESS')){
                
                renderContent = false;
                if(this.renderPW){
                    //Do automatic login
                    retpage = oktaLogin();
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.AGN_OAM_Update_Successful_login_new_password)); //TODO: need to localize
                }
                else{
                    //Redirect to change password screen with Email as parameter
                    retpage = redirectToChangePasswordScreen();
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Successfully updated Recovery Q&A'));
                }
                try{                   
                    accToUpdate.Community_Okta_Password_Reset_Token_AGN__c = '0';
                    //------CheckMarx--Updated on 25/07/2020----------   
                    if(Schema.sObjectType.Account.fields.Community_Okta_Password_Reset_Token_AGN__c.isUpdateable()){
                        update accToUpdate;
                    }
                    else{
                        throw new AGN_CommonException('Error: Insufficient Edit Access On Account [Class Name: AGN_OAMOktaChangePwdController and Method Name: updatePwdRecovery]');
                    }  
                    //----------------------------------------------
                    
                } catch(DmlException e) {
                    System.debug('An unexpected error has occurred: ' + e.getMessage());
                }
            }
            else
            {
                String errorSummary = resMessage.errorCauses.size() >0 ? resMessage.errorCauses[0].errorSummary : resMessage.errorSummary;
                if(errorSummary.containsIgnoreCase('securityAnswer: The security question answer must be at least')){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_The_security_question_answer_must_be_at_least));
                }
                else if(errorSummary.containsIgnoreCase('password: Password requirements were not met. Password requirements:')){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_OAM_Password_requirements_were_not_met));
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorSummary));
                }
            }
            
            /*String resMessage = oUtil.ChangePassword(reqBody, oktaUser);

if(resMessage.equalsignorecase('SUCCESS')){

renderContent = false;
if(this.renderPW){
//Do automatic login
retpage = oktaLogin();
//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.AGN_OAM_Update_Successful_login_new_password)); //TODO: need to localize
}
else{
//Redirect to change password screen with Email as parameter
retpage = redirectToChangePasswordScreen();
//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Successfully updated Recovery Q&A'));
}
try{                   
accToUpdate.Community_Okta_Password_Reset_Token_AGN__c = '0';
update accToUpdate;
} catch(DmlException e) {
System.debug('An unexpected error has occurred: ' + e.getMessage());
}
}
else
{
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, resMessage));
}*/
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,System.Label.AGN_OAM_Recovery_Link_Expired)); //TODO: need to localize
            renderContent = false;
        }
        return retpage;
    }
    
    public static Boolean nullOrEmpty(Object o) {
        return (null == o) ||
            ((o instanceof String) && (0 == ((String)o).trim().length())) ||
            ((o instanceof List<object>) && (0 == ((List<object>)o).size()));
    }
    
    public PageReference redirectToChangePasswordScreen() {
        String email = this.userEmail;
        //String email = 'avijit_DE@sharklasers.com';
        String urlToRedirect = Site.getbaseUrl() + '/AGN_CustomerOktaForgotPassword?un='+ EncodingUtil.urlEncode(email,'UTF-8')+'&language='+this.userLanguage;
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Site.getbaseUrl()));
        PageReference retpage = new PageReference(urlToRedirect);
        return retpage;
    }
    
    public PageReference testChgOktaPWD() {
        PageReference retpage = null;
        this.renderPW = true;
        String reqBody;
        
        String reqPrefix = '{'+
            +'"credentials": {';
        
        String reqQABody = '"recovery_question": {'+
            +'"question": "'+ this.selectedRecoveryQuestion +'",'+
            +'"answer": "'+ this.recoveryAnswer +'"'+
            +'}';
        
        if(this.renderPW){
            String reqPWDBody = '"password" : { "value": "'+ this.newPassord +'"}';
            reqBody = reqPrefix + reqPWDBody +',' +reqQABody +'}}';
        }
        else{
            reqBody = reqPrefix + reqQABody +'}}';
        }
        AGN_OktaUtils oUtil = new AGN_OktaUtils();
        String oktaUser = 'qa_test_de@mailinator.com';
        String resMessage = oUtil.ChangePassword(reqBody, oktaUser);
        
        if(resMessage.equalsignorecase('SUCCESS')){
            renderContent = false;
            if(this.renderPW){
                //Do automatic login
                retpage = oktaLogin();
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, System.Label.AGN_OAM_Update_Successful_login_new_password)); //TODO: need to localize
            }
            else{
                //Redirect to change password screen with Email as parameter
                retpage = redirectToChangePasswordScreen();
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Successfully updated Recovery Q&A'));
            }
        }
        else
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, resMessage));
        }
        
        return retpage;
    }
    
    
    public PageReference oktaLogin() {
        
        String oktaToken = '';
        PageReference retpage = null;
        
        AGN_OktaUtils.Session oktaSession = new AGN_OktaUtils.Session();
        
        Boolean loginSuccessful  = false;
        String oktaError;
        //String oktaUser = 'avijit_de@sharklasers.com';
        String oktaUser = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? this.username : this.userEmail;
        String bodyString = '{ "username" : "'+ oktaUser +'", "password" : "'+ this.newPassord +'" }';
        
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