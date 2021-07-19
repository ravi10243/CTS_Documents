/**
 * @File Name          : AGN_GCSP_OktaAuthController.cls
 * @Description        : To Support all Okta related login, change password and reset recovery Q&A
 * @Author             : Dev Team
 * @Group              :
 * @Last Modified By   : Dev Team
 * @Last Modified On   : 13/01/2021
 * @Modification Log   :
 * Ver       Date            Author              Modification
 * 1.0    13/01/2021   Dev Team    Initial Version
 **/
public without sharing class AGN_GCSP_OktaAuthController {

/**
 * @description : To validate Okta login
 * @author Dev Team
 * @param oktaUserName
 * @param oktaPassword
 * @return String
 **/
  @AuraEnabled(cacheable=true)
  public static String validateAndLogInOkta(String oktaUserName, String oktaPassword) {
    String oktaResponse = '';
    AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();

    //String suffix = !String.isEmpty(commonOktaConfig.UsernameSuffix_AGN__c) ? commonOktaConfig.UsernameSuffix_AGN__c : '';
    //String sfdcUserName = oktaUserName + suffix;

    //checking if user is present in Salesforce and active
    System.debug('Username_cl::'+oktaUserName);
    List<User> pUser = AGN_GCSP_Utilities.geUserDetails(oktaUserName);
    if(pUser.isEmpty()) {
      //USER NOT FOUND
      oktaResponse = '{"isSuccess":false, "response":"'+ System.Label.AGN_OAM_User +' '+ oktaUserName +' '+ System.Label.AGN_OAM_Not_found +'"}';
      return oktaResponse;
    }
    
    string userCountry = pUser.isEmpty() ? '' : pUser[0].Country_Code__c;
      userCountry =  userCountry.equalsIgnoreCase('IE') ? 'GB' : userCountry;
        String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Base_URL_AGN__c');           
        String comSuffix = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Suffix_AGN__c');
        
        String oktaBaseUrl = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Okta_Base_URL_AGN__c');
        String oktaApiKey =  (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Okta_API_Key_AGN__c');  

    AGN_OktaUtils oUtil = new AGN_OktaUtils(oktaBaseUrl, oktaApiKey, null);

    //checking if user is present in OKTA
    String okatMessage = oUtil.isPresentInOkta(oktaUserName);
    Map < String, Object > m = (Map <String, Object>)JSON.deserializeUntyped(okatMessage);

    String messagetype = (String) m.get('messagetype');
    String message = (String) m.get('message');
    //messagetype = ERROR -> User not found
    if (messagetype.equalsIgnoreCase('ERROR')) {
      //USER NOT FOUND in Okta
      oktaResponse = '{"isSuccess":false, "response":" Okta - '+ System.Label.AGN_OAM_User +' '+ oktaUserName +' '+ System.Label.AGN_OAM_Not_found +'"}';
    }
    //User found
    else{
      String userOktatatus = (String) m.get('Status');
      String userOktaId = (String) m.get('Id');

      userOktatatus = userOktatatus.toUpperCase();

      switch on userOktatatus {
        when 'ACTIVE' {
          oktaResponse = doOktaLogin(oktaUserName, oktaPassword, commonOktaConfig, oUtil, userCountry);
        }
        when 'PASSWORD_EXPIRED', 'PASSWORD_WARN', 'RECOVERY', 'STAGED', 'PROVISIONED' {
          //Redirect to change password screen
          String urlToRedirect;
          //String COMMUNITY_BASE_URL = commonOktaConfig.Community_Base_URL_AGN__c;
         // String COMMUNITY_SUFFIX = commonOktaConfig.Community_Suffix_AGN__c;
          if(String.isEmpty(comSuffix) || comSuffix.equals('/')) {
            urlToRedirect = comBaseURL;
          }
          else{
            urlToRedirect = comBaseURL + comSuffix;
          }
          urlToRedirect += commonOktaConfig.Manage_Password_Page_Name_AGN__c +'?un='+ EncodingUtil.urlEncode(oktaUserName,'UTF-8')+'&language='+pUser[0].LanguageLocaleKey;
          oktaResponse = '{"isSuccess":true, "response":"'+ urlToRedirect +'"}';
        }
        when else {
          oktaResponse = '{"isSuccess":false, "response":"Currently User ('+ oktaUserName +') is '+ userOktatatus +' in Okta, please get in touch with customer service team."}';
        }
      }
    }
    return oktaResponse;
  }

/**
 * @description : To do Okta login
 * @author Dev Team
 * @param oktaUserName
 * @param oktaPassword
 * @param commonOktaConfig
 * @param okta
 * @return String
 **/
  @TestVisible
  private static String doOktaLogin(String oktaUserName,
                                    String oktaPassword,
                                    AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig,
                                    AGN_OktaUtils okta,
                                    String countryCode) {

    String oktaToken = '';
    String oktaResponse = '';
    
    String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Community_Base_URL_AGN__c');           
    String comSuffix = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Community_Suffix_AGN__c');
        
    String oktaBaseUrl = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_Base_URL_AGN__c');
    String oktaApiKey =  (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_API_Key_AGN__c'); 
	String oktaRedirectURL =  (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Okta_Redirect_URL_AGN__c'); 

    AGN_OktaUtils.Session oktaSession = new AGN_OktaUtils.Session();

    Boolean loginSuccessful = false;
    String oktaError;

    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('username', oktaUserName);
    gen.writeStringField('password', oktaPassword);
    gen.writeEndObject();

    HttpResponse response = okta.CheckOktaLogin(gen.getAsString());

    if(response != null) {
      if (response.getStatusCode() == 200) { //success
        System.debug('@@@Okta Success response@@@' + response.getBody());
        String stringResponse = response.getBody();
        oktaSession = String.isBlank(stringResponse) ? null : AGN_OktaUtils.parseToSession(stringResponse);
        if(AGN_GCSP_Utilities.nullOrEmpty(oktaSession.cookieToken)) {
          loginSuccessful = false;
          oktaResponse = '{"responseType": "OKTA_ERROR","isSuccess:false, "response":"Empty Okta Cookie Token"}';
        }
        else{
          oktaToken = oktaSession.cookieToken;
          loginSuccessful = true;
        }
      } else {
        AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
        oktaError = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, oktaError));
        System.debug('@@@Okta Error response@@@' + respUserErr);
        loginSuccessful = false;
        oktaResponse = '{"responseType": "OKTA_ERROR","isSuccess":false, "response":"'+ oktaError +'"}';
      }

      if(loginSuccessful) {
          
        String redirectURL = oktaRedirectURL; 
            //commonOktaConfig.Okta_Redirect_URL_AGN__c;
        String retUrl = EncodingUtil.urlEncode(redirectURL,'UTF-8');
        oktaResponse = oktaBaseUrl +'/login/sessionCookieRedirect?token='+ oktaToken +'&redirectUrl=' + retUrl;
        oktaResponse = '{"responseType": "SUCCESS","isSuccess":true, "response":"'+ oktaResponse +'"}';
      }
    }
    return oktaResponse;
  }

/**
 * @description : Get Security question
 * @author Dev Team
 * @param oktaUserName
 * @return String
 **/
  @AuraEnabled(cacheable=true)
  public static String getOktaSecurityQuestion(String oktaUserName) {
    String oktaResponse = '';
    AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();

    //checking if user is present in Salesforce and active
    List<User> pUser = AGN_GCSP_Utilities.geUserDetails(oktaUserName);
    if(pUser.isEmpty()) {
      //USER NOT FOUND
      oktaResponse = '{"responseType": "USER_NOT_FOUND_SFDC", "response":"'+ System.Label.AGN_OAM_User +' '+ oktaUserName +' '+ System.Label.AGN_OAM_Not_found +'"}';
      return oktaResponse;
    }
	string userCountry = pUser.isEmpty() ? '' : pUser[0].Country_Code__c;
		userCountry = userCountry.equalsIgnoreCase('IE')?'GB':userCountry;
        String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Base_URL_AGN__c');           
        String comSuffix = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Suffix_AGN__c');
        
        String oktaBaseUrl = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Okta_Base_URL_AGN__c');
        String oktaApiKey =  (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Okta_API_Key_AGN__c'); 
		String oktaRedirectURL =  (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Okta_Redirect_URL_AGN__c'); 
    AGN_OktaUtils oUtil = new AGN_OktaUtils(oktaBaseUrl, oktaApiKey, null);
    String okatMessage = oUtil.GetSecurityQuestion(oktaUserName);
    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(okatMessage);
    String messagetype = (String)m.get('messagetype');
    String oktaUserStatus = (String)m.get('oktauserstatus');

    if(messagetype.equalsIgnoreCase('SUCCESS')) {
      String recoveryQuestion = (String)m.get('message');
      if(!String.isEmpty(recoveryQuestion) && recoveryQuestion != 'Name of this company?') {
        oktaResponse = '{"responseType": "SUCCESS", "recoveryQuestion": "'+ recoveryQuestion +'"}';
        return oktaResponse;
      }
      else{
        oktaResponse = '{"responseType": "OKTA_ERROR_UNDEFINED_RECOVERY_Q", "response": "'+ System.Label.AGN_OAM_Recovery_question_not_defined +'"}';
        return oktaResponse;
      }
    }
    else{
      oktaResponse = '{"responseType": "OKTA_ERROR_UNKNOWN", "response": "'+ (String)m.get('message') +'"}';
      return oktaResponse;
    }
  }

/**
 * @description : Change Password
 * @author Dev Team
 * @param oktaUserName
 * @param oktaNewPassword
 * @param oktaSecurityAns
 * @return String
 **/

  @AuraEnabled(cacheable=true)
  public static String forgotPassword(String oktaUserName, String oktaNewPassword, String oktaSecurityAns) {
    String oktaResponse = '';
    AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();

    //checking if user is present in Salesforce and active
    List<User> pUser = AGN_GCSP_Utilities.geUserDetails(oktaUserName);
    if(pUser.isEmpty()) {
      //USER NOT FOUND
      oktaResponse = '{"responseType": "USER_NOT_FOUND_SFDC", "response":"'+ System.Label.AGN_OAM_User +' '+ oktaUserName +' '+ System.Label.AGN_OAM_Not_found +'"}';
      return oktaResponse;
    }
	string userCountry = pUser.isEmpty() ? '' : pUser[0].Country_Code__c;
		userCountry = userCountry.equalsIgnoreCase('IE')?'GB':userCountry;
        String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Base_URL_AGN__c');           
        String comSuffix = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Suffix_AGN__c');
        
        String oktaBaseUrl = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Okta_Base_URL_AGN__c');
        String oktaApiKey =  (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Okta_API_Key_AGN__c'); 
		String oktaRedirectURL =  (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Okta_Redirect_URL_AGN__c');
      
    AGN_OktaUtils oUtil = new AGN_OktaUtils(oktaBaseUrl, oktaApiKey, null);
    String okatMessage = oUtil.GetSecurityQuestion(oktaUserName);
    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(okatMessage);
    String messagetype = (String)m.get('messagetype');
    String oktaUserStatus = (String)m.get('oktauserstatus');
    System.debug('messagetype -> ' + messagetype);
    System.debug('oktaUserStatus -> ' + oktaUserStatus);
    if(messagetype.equalsIgnoreCase('SUCCESS')) {
      String recoveryQuestion = (String)m.get('message');
      System.debug('recoveryQuestion -> ' + recoveryQuestion);
      if(!String.isEmpty(recoveryQuestion) && recoveryQuestion != 'Name of this company?') {

        oktaUserStatus = oktaUserStatus.toUpperCase();

        switch on oktaUserStatus {
          when 'PROVISIONED', 'RECOVERY' {
            //String reqBody;
            /* String reqPrefix = '{'+
             +'"credentials": {';
               String reqPWDBody = '"password" : { "value": "'+ this.newPassword +'"}';
               reqBody = reqPrefix + reqPWDBody +'}}'; */

            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('credentials');
            gen.writeStartObject();
            gen.writeFieldName('password');
            gen.writeStartObject();
            gen.writeStringField('value', oktaNewPassword);
            gen.writeEndObject();
            //String jsonData = gen.getAsString();
            String resMessage = oUtil.ChangePassword(gen.getAsString(), oktaUserName);

            if(resMessage == 'SUCCESS') {
              //Do automatic login
              return validateCookieTokenLogin(oktaUserName, oktaNewPassword, commonOktaConfig, oUtil, recoveryQuestion);
            }
            else
            {
              resMessage = parseErrorMessage(resMessage);
              oktaResponse = '{"responseType": "OKTA_ERROR", "response": "'+ resMessage +'", "recoveryQuestion": "'+ recoveryQuestion +'"}';
              return oktaResponse;
            }
          }
          when 'ACTIVE', 'PASSWORD_EXPIRED', 'PASSWORD_WARN', 'STAGED' {

            String oktaUserId = (String)m.get('oktauserid');

            /* String reqBody = '{'+
             +'"password" : { "value": "'+ this.newPassword +'"},'+
             +'"recovery_question" : { "answer": "'+ this.recoveryAnswer +'"}'+
             +'}'; */
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('password');
            gen.writeStartObject();
            gen.writeStringField('value', oktaNewPassword);
            gen.writeEndObject();

            gen.writeFieldName('recovery_question');
            gen.writeStartObject();
            gen.writeStringField('answer', oktaSecurityAns);
            gen.writeEndObject();

            String okatSetPwdResp = oUtil.SetPassword(oktaUserId, gen.getAsString());
            Map<String, Object> okatSetPwdRespMap = (Map<String, Object>)JSON.deserializeUntyped(okatSetPwdResp);
            String messagetypeSetPwd = (String)okatSetPwdRespMap.get('messagetype');
            if(messagetypeSetPwd == 'SUCCESS') {
              //Do automatic login
              return validateCookieTokenLogin(oktaUserName, oktaNewPassword, commonOktaConfig, oUtil, recoveryQuestion);
            }
            else
            {
              String parseErrorMessage = parseErrorMessage((String)okatSetPwdRespMap.get('message'));
              oktaResponse = '{"responseType": "OKTA_ERROR", "response": "'+ parseErrorMessage +'", "recoveryQuestion": "'+ recoveryQuestion +'"}';
              return oktaResponse;
            }
          }
          when else {
            oktaResponse = '{"responseType": "OKTA_ERROR", "response":"Currently User ('+ oktaUserName +') is '+ oktaUserStatus +' in Okta, please get in touch with customer service team.", "recoveryQuestion": "'+ recoveryQuestion +'"}';
            return oktaResponse;
          }
        }
      }
      else{
        oktaResponse = '{"responseType": "OKTA_ERROR_UNDEFINED_RECOVERY_Q", "response": "'+ System.Label.AGN_OAM_Recovery_question_not_defined +'"}';
        return oktaResponse;
      }
    }
    else{
      oktaResponse = '{"responseType": "OKTA_ERROR_UNKNOWN", "response": "'+ (String)m.get('message') +'"}';
      return oktaResponse;
    }
    //return oktaResponse;
  }

/**
 * @description : Validate Okta Cookie Token
 * @author Dev Team
 * @param oktaUserName
 * @param oktaPassword
 * @param commonOktaConfig
 * @param okta
 * @param recoveryQuestion
 * @return String
 **/
  @TestVisible
  private static String validateCookieTokenLogin(String oktaUserName,
                                                 String oktaPassword,
                                                 AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig,
                                                 AGN_OktaUtils okta, String recoveryQuestion){
         String oktaResponse = '';                                           
    	 List<User> pUser = AGN_GCSP_Utilities.geUserDetails(oktaUserName);
        if(pUser.isEmpty()) {
          //USER NOT FOUND
          oktaResponse = '{"isSuccess":false, "response":"'+ System.Label.AGN_OAM_User +' '+ oktaUserName +' '+ System.Label.AGN_OAM_Not_found +'"}';
          return oktaResponse;
        }
        string userCountry = pUser.isEmpty() ? '' : pUser[0].Country_Code__c;
         userCountry = userCountry.equalsIgnoreCase('IE') ? 'GB' : userCountry;
        /*String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Base_URL_AGN__c');           
        String comSuffix = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Community_Suffix_AGN__c');
        
        String oktaBaseUrl = (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Okta_Base_URL_AGN__c');
        String oktaApiKey =  (String)AGN_GCSP_Settings__c.getValues(userCountry)?.get('Okta_API_Key_AGN__c');  */                                               
	        
     oktaResponse = doOktaLogin(oktaUserName, oktaPassword, commonOktaConfig, okta, userCountry);
    Map < String, Object > m = (Map <String, Object>)JSON.deserializeUntyped(oktaResponse);

    String responseType = (String) m.get('responseType');
    String responseMessage = (String) m.get('response');

    if(responseType == 'OKTA_ERROR') {
      oktaResponse = '{"responseType": "OKTA_ERROR", "response": "'+ responseMessage +'", "recoveryQuestion": "'+ recoveryQuestion +'"}';
    }
    return oktaResponse;
  }

/**
 * @description : Parse Okta related message to custom label
 * @author Dev Team
 * @param errorSummary
 * @return String
 **/
  @TestVisible
  private static String parseErrorMessage(String errorSummary){
    String parsedMessage;
    if(errorSummary.containsIgnoreCase('password requirements were not met')) {
      parsedMessage = System.Label.AGN_OAM_Password_requirements_were_not_met;
    }
    else if(errorSummary.containsIgnoreCase('The credentials provided were incorrect')) {
      parsedMessage = System.Label.AGN_OAM_Okta_Recovery_Ans_Incorrect;
    }
    else if(errorSummary.containsIgnoreCase('Password cannot be your current password')) {
      parsedMessage = System.Label.AGN_OAM_Okta_OldNewPassword;
    }
    else if(errorSummary.containsIgnoreCase('User is currently locked out')) {
      parsedMessage = System.Label.AGN_OAM_Okta_User_Locked;
    }
    else if(errorSummary.containsIgnoreCase('Password has been used too recently')) {
      parsedMessage = 'Password has been used too recently'; // Need custom label
    }
    else if(errorSummary.containsIgnoreCase('securityAnswer: The security question answer must be at least 4 characters in length')) {
      parsedMessage = 'The security question answer must be at least 4 characters in length'; // Need custom label
    }
    else{
      parsedMessage = errorSummary;
    }
    return parsedMessage;
  }

/**
 * @description : To validate password reset token
 * @author Dev Team
 * @param activationToken
 * @return String
 **/

  @AuraEnabled
  public static String validateAccountActivationToken(String activationToken) {
    String oktaResponse = '';
    AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();

    String privateKey = commonOktaConfig.Encrypt_Decrypt_Private_Key_AGN__c;

    AGN_CryptoUtils cUtil = new AGN_CryptoUtils();

    try{
      String decryptedData = cUtil.Decrypt('AES256', privateKey, activationToken);

      Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(decryptedData);

      Datetime validtill = Datetime.valueOf((String)m.get('validtill'));
      decimal diffNanoSecs = validtill.getTime() - Datetime.now().getTime();     //getTime() returns in Nano Sec

      if(diffNanoSecs < 0) {    //link is expired
        oktaResponse = '{"responseType": "EXPIRED_LINK", "response":"'+ System.Label.AGN_OAM_Recovery_Link_Expired +'"}';
        return oktaResponse;
      }
      else{
        String userName = (String)m.get('portalusername');
        String userEmail = (String)m.get('portaluseremail');
        String passwordResetToken = (String)m.get('passwordResetToken');

        User[] currentUser = [Select Contact.Id, Contact.Community_Okta_Password_Reset_Token_AGN__c,
                              Contact.Okta_Id_AGN__c, FederationIdentifier, LanguageLocaleKey from User where username =:userName and isactive=true limit 1];

        if (!currentUser.isEmpty()) {
          if(currentUser[0].Contact.Community_Okta_Password_Reset_Token_AGN__c != passwordResetToken) {    //link is expired
            oktaResponse = '{"responseType": "EXPIRED_LINK", "response":"'+ System.Label.AGN_OAM_Recovery_Link_Expired +'"}';
            return oktaResponse;
          }
          else{
            User u = currentUser[0];
            if(String.isEmpty(u.FederationIdentifier)) {
              //Updating Okta Id in FederationIdentifier for SSO
              u.FederationIdentifier = currentUser[0].Contact.Okta_Id_AGN__c;
              update u;
            }
            oktaResponse = '{"responseType": "SUCCESS", "passwordResetKey":"'+ passwordResetToken +'", "customerContactId":"'+ currentUser[0].Contact.Id +'", "userLanguage":"'+ currentUser[0].LanguageLocaleKey +'", "userEmail":"'+ userEmail +'"}';
            return oktaResponse;
          }
        }
        else{
          oktaResponse = '{"responseType": "UNKNOWN_USER", "response":"'+ System.Label.AGN_OAM_Unknown_user +'"}';
          return oktaResponse;
        }
      }
    }
    catch(SecurityException se) {
      oktaResponse = '{"responseType": "EXPIRED_LINK", "response":"'+ System.Label.AGN_OAM_Recovery_Link_Expired +'"}';
      return oktaResponse;
    }
    catch(Exception ex) {
      oktaResponse = '{"responseType": "SYSTEM_EXCEPTION", "response":"'+ ex.getMessage() +'"}';
      return oktaResponse;
    }
  }

/**
 * @description : To validate password reset token
 * @author Dev Team
 * @param activationToken
 * @return String
 **/

  @AuraEnabled
  public static String updateOktaPwdRecovery(Boolean renderPW, String customerContactId,
                                             String passwordResetKey, String selectedRecoveryQuestion,
                                             String recoveryAnswer, String newPassword,
                                             String userEmail, String userLanguage) {
    String oktaResponse = '';
    AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();

    Contact contToUpdate = [SELECT Community_Okta_Password_Reset_Token_AGN__c, Account.Country_Code__c, Account.SAP_Country_Code_AGN__c FROM Contact WHERE Id =: customerContactId];

	String countryCode = contToUpdate?.Account?.SAP_Country_Code_AGN__c;
    if(String.isEmpty(countryCode) || countryCode.equalsIgnoreCase('IE')){
          countryCode =   contToUpdate.Account.Country_Code__c;                                        
    } 
    String oktaBaseURL = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_Base_URL_AGN__c');
    String oktaApiKey = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_API_Key_AGN__c');
    String comBaseURL = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Community_Base_URL_AGN__c');           
    String comSuffix = (String)AGN_GCSP_Settings__c.getValues(countryCode)?.get('Community_Suffix_AGN__c'); 
    //rechecking if url signature has expired
    if(contToUpdate.Community_Okta_Password_Reset_Token_AGN__c == passwordResetKey) {
      String reqBody;

      String reqPrefix = '{'+
                         +'"credentials": {';

      String reqQABody = '"recovery_question": {'+
                         +'"question": "'+ selectedRecoveryQuestion +'",'+
                         +'"answer": "'+ recoveryAnswer +'"'+
                         +'}';

      if(renderPW) {
        String reqPWDBody = '"password" : { "value": "'+ newPassword +'"}';
        reqBody = reqPrefix + reqPWDBody +',' +reqQABody +'}}';
      }
      else{
        reqBody = reqPrefix + reqQABody +'}}';
      }
	  
      AGN_OktaUtils oUtil = new AGN_OktaUtils(oktaBaseURL, oktaApiKey, null);
      AGN_OktaUserFailedResponse resMessage = oUtil.ChangeOktaPassword(reqBody, userEmail);
      if(resMessage.errorCode.equalsignorecase('SUCCESS')) {
        //renderContent = false;

        if(renderPW) {
          //Do automatic login
          oktaResponse = doOktaLogin(userEmail, newPassword, commonOktaConfig, oUtil, countryCode);
        }
        else{
          String urlToRedirect;
         // String COMMUNITY_BASE_URL = commonOktaConfig.Community_Base_URL_AGN__c;
         // String COMMUNITY_SUFFIX = commonOktaConfig.Community_Suffix_AGN__c;
          if(String.isEmpty(comSuffix) || comSuffix.equals('/')) {
            urlToRedirect = comBaseURL;
          }
          else{
            urlToRedirect = comBaseURL + comSuffix;
          }
          //Redirect to change password screen with Email as parameter
          urlToRedirect += commonOktaConfig.Manage_Password_Page_Name_AGN__c +'?un='+ EncodingUtil.urlEncode(userEmail,'UTF-8')+'&language='+userLanguage;
          //String urlToRedirect = Site.getbaseUrl() + '/AGN_CustomerOktaForgotPassword?un='+ EncodingUtil.urlEncode(userEmail,'UTF-8')+'&language='+this.userLanguage;
          oktaResponse = '{"responseType": "SUCCESS", "response":"'+ urlToRedirect +'"}';
        }
        contToUpdate.Community_Okta_Password_Reset_Token_AGN__c = '0';
        update contToUpdate;
        return oktaResponse;
      }
      else
      {
        String errorSummary = resMessage.errorCauses.size() > 0 ? resMessage.errorCauses[0].errorSummary : resMessage.errorSummary;
        errorSummary = parseErrorMessage(errorSummary);
        oktaResponse = '{"responseType": "OKTA_ERROR", "response": "'+ errorSummary +'"}';
        return oktaResponse;
      }
    }
    else
    {
      oktaResponse = '{"responseType": "EXPIRED_LINK", "response":"'+ System.Label.AGN_OAM_Recovery_Link_Expired +'"}';
      return oktaResponse;
      //renderContent = false;
    }
  }

/**
 * @description : To reset recovery Q&A
 * @author Dev Team
 * @param userEmail
 * @param hasOktaRecoveryQuestion
 * @param country
 * @return String
 **/
  @AuraEnabled
  public static Boolean forgotRecoveryQA(String userEmail, Boolean hasOktaRecoveryQuestion) {
    List<User> customer = AGN_GCSP_Utilities.geUserDetails(userEmail);
    AGN_GCSP_CustomerRegUtils.forgotRecoveryQA(customer[0], hasOktaRecoveryQuestion, customer[0].Country_Code__c);

    return true;
  }

/**
 * @description : Get custom label
 * @author Dev Team
 * @param lang
 * @return String
 **/
  @AuraEnabled(cacheable=true)
  public static String getLabelString(String lang){
    return AGN_GCSP_Utilities.getLabelString(lang);
  }
}