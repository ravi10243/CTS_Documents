/**
* Customer Self Registration Portal
* <p>
* OKTA Service Util class
*
* @author          Avijit Gorai 
* @version         1.0
* @date            06-OCT-2018 
* @description     OKTA Service Util class
* @Current Version 1.0
*/
public class AGN_OktaUtils {
    
    public String baseUrl {get;set;}
    public String apiKey {get;set;}
    public String sfdcUserName {get;set;}
    
    public AGN_OktaUtils(){
        this.baseUrl = AGN_OAMConstant.OKTABASEURL;
        this.apiKey = AGN_OAMConstant.OKTAAPIKEY;
        String userName = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? UserInfo.getUserName() : UserInfo.getUserName();
        this.sfdcUserName = userName;
    }
    public AGN_OktaUtils(String countryCode, String sfdcUserName){
        this.baseUrl = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_Base_URL_AGN__c');// AGN_CustomerPortal_Constant.OKTABASEURL;
        this.apiKey = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_API_Key_AGN__c');
        this.sfdcUserName = sfdcUserName;
    }
    public AGN_OktaUtils(String baseUrl, String apiKey, String sfdcUserName){
        this.baseUrl = baseUrl;
        this.apiKey = apiKey;
        this.sfdcUserName = sfdcUserName;
    }
    public Boolean IsOktaPWDChangedSinceUserCreation(){
        
        Boolean forcePWDReset = false;
        HttpResponse response = AGN_Okta.GetUserDetails(this.baseUrl,this.apiKey,this.sfdcUserName);
        try {
            if(response != null){
                if (response.getStatusCode() == 200) {
                    AGN_OktaUserSuccessResponse respUser = AGN_OktaUserSuccessResponse.parse(response.getBody());
                    System.debug('@@@Okta Success response@@@' + respUser);
                    if(respUser.status.equalsignorecase('ACTIVE') || respUser.status.equalsignorecase('PROVISIONED')){
                        
                        String strCreated = respUser.created; //2018-07-06T11:24:04.000Z
                        String strPasswordChanged = respUser.passwordChanged; //2018-07-06T11:24:04.000Z
                        
                        strCreated = strCreated.replace('T', ' ').replace('.000Z', ''); //2018-07-06 11:24:04
                        //strCreated = strCreated.replace('.000Z', ''); //2018-07-06 11:24:04
                        
                        strPasswordChanged = strPasswordChanged.replace('T', ' ').replace('.000Z', ''); //2018-07-06 11:24:04
                        //strPasswordChanged = strPasswordChanged.replace('.000Z', ''); //2018-07-06 11:24:04
                        
                        Datetime dtCreated = Datetime.valueOf(strCreated);
                        Datetime dtPasswordChanged = Datetime.valueOf(strPasswordChanged);
                        decimal diffSecs = ((dtPasswordChanged.getTime())/1000) - ((dtCreated.getTime())/1000);
                        
                        //Okta User 'passwordChanged' minus 'created' date <=10 secs, User did not change password since user created. 
                        //Then forcefully display password change page.
                        forcePWDReset = diffSecs <=10 ? true : false;
                    }
                    else{
                        //User is Inactive
                        //raise error
                        System.debug('@@@Okta Error response@@@ User is Inactive in Okta');
                    }
                    
                } else {
                    AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
                    
                    System.debug('@@@Okta Error response@@@' + respUserErr); 
                    //raise error
                }
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return forcePWDReset;
    }
    
/**
* @author           Avijit Gorai
* @version          1.0
* @date             06-OCT-2018  
* @description      This method is to check if the user is present in OKTA
* @param            Salesforce User Name as String
* @return           String
*/ 
    public String isPresentInOkta(String oktaUserName){
        
        String message = '';
        HttpResponse response = AGN_Okta.GetUserDetails(this.baseUrl, this.apiKey, oktaUserName);
        if(response != null){
            //found user
            system.debug('response body>>>>>>>>>>>>>>>>>>>>'+response.getBody());
            if (response.getStatusCode() == 200) {
                AGN_OktaUserSuccessResponse respUser = AGN_OktaUserSuccessResponse.parse(response.getBody());
                
                message = '{'+
                    +'"messagetype": "SUCCESS",'+
                    +'"Id": "'+ respUser.id +'",'+
                    +'"Status": "'+ respUser.status +'"'+
                    +'}';               
            } else {
                //no user found
                AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
                string errMsg = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                message = '{'+
                    +'"messagetype": "ERROR",'+
                    +'"message": "'+ errMsg +'"'+
                    +'}';  
            }
        }
        return message;
    }
    
    public String ChangePassword(String reqBody, String userName){
        
        String successMessage = '';
        HttpResponse response = AGN_Okta.FirstTimeChgPWDSecurityQuestion(reqBody, this.baseUrl, this.apiKey, userName);
        try {
            if(response != null){
                if (response.getStatusCode() == 200) { //success
                    System.debug('@@@Okta Success response@@@' + response.getBody());
                    successMessage = 'SUCCESS';
                } else {
                    AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    System.debug('@@@Okta Error response@@@' + respUserErr);  
                }
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return successMessage;
    }
    
    public AGN_OktaUserFailedResponse ChangeOktaPassword(String reqBody, String userName){
        
        String successMessage = '';
        AGN_OktaUserFailedResponse respUserErr = new AGN_OktaUserFailedResponse();
        HttpResponse response = AGN_Okta.FirstTimeChgPWDSecurityQuestion(reqBody, this.baseUrl, this.apiKey, userName);
        try {
            if(response != null){
                if (response.getStatusCode() == 200) { //success
                    System.debug('@@@Okta Success response@@@' + response.getBody());
                    respUserErr.errorCode = 'SUCCESS';
                } else {
                    respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
                    //successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    System.debug('@@@Okta Error response@@@' + respUserErr);  
                }
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return respUserErr;
    }
    
    public String AddUserToGroup(String groupId, String userName){
        
        String successMessage = '';
        HttpResponse response = null;
        try {
            HttpResponse responseUser = AGN_Okta.GetUserDetails(this.baseUrl,this.apiKey,userName);
            if(responseUser != null){
                if (responseUser.getStatusCode() == 200) {
                    AGN_OktaUserSuccessResponse respUser = AGN_OktaUserSuccessResponse.parse(responseUser.getBody());
                    System.debug('@@@Okta Success response@@@' + respUser);
                    
                    List<String> lstGroupId = groupId.split(','); //"00g1ejknx1aUagHTf1d8","00g1eox23lscKXT1c1d8"
                    for(String gpId : lstGroupId){
                        response = AGN_Okta.AddUserToGroup(gpId.replace('"',''), respUser.id, this.baseUrl, this.apiKey);
                        
                        if(response != null){
                            if (response.getStatusCode() == 204) { //success =>(204 No Content) The server successfully processed the request, but is not returning any content.
                                System.debug('@@@Okta Success response@@@' + response.getBody());
                                successMessage = 'SUCCESS';
                            } else {
                                AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
                                successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                                System.debug('@@@Okta Error response@@@' + respUserErr);  
                            }
                        }
                    }
                }
                else{
                    successMessage = 'User not found: '+ this.sfdcUserName;
                }
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return successMessage;
    }
    
    public String removeUserFromGroups(String groupId, String oktaUserId){
        
        String successMessage = '';
        HttpResponse response = null;
        try {
            List<String> lstGroupId = groupId.split(','); //"00g1ejknx1aUagHTf1d8","00g1eox23lscKXT1c1d8"
            for(String gpId : lstGroupId){
                response = AGN_Okta.removeUserFromGroup(gpId.replace('"',''), oktaUserId, this.baseUrl, this.apiKey);               
                if (response.getStatusCode() == 204) { //success =>(204 No Content) The server successfully processed the request, but is not returning any content.
                    System.debug('@@@Okta Success response@@@' + response.getBody());
                    successMessage = 'SUCCESS';
                } else {
                    AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    System.debug('@@@Okta Error response@@@' + respUserErr);  
                }
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return successMessage;
    }
    
    public String GetSecurityQuestion(String userName){
        
        String successMessage = '';
        try {
            HttpResponse responseUser = AGN_Okta.GetUserDetails(this.baseUrl,this.apiKey,userName);
            if(responseUser != null){
                if (responseUser.getStatusCode() == 200) {
                    AGN_OktaUserSuccessResponse respUser = AGN_OktaUserSuccessResponse.parse(responseUser.getBody());
                    //AGN_OktaUserSuccessResponse.Recovery_question objRecovery_question = new AGN_OktaUserSuccessResponse.Recovery_question(System.JSON.createParser(responseUser.getBody()));
                    //System.debug('@@@Okta Success response@@@' + objRecovery_question);
                    String recoveryQuestion;
                    
                    try{
                        recoveryQuestion = respUser.credentials.recovery_question.question;
                    }
                    catch(Exception e){
                        recoveryQuestion = '';
                    }
                    successMessage = '{'+
                        +'"messagetype": "SUCCESS",'+
                        +'"message": "'+ recoveryQuestion +'",'+
                        //+'"message": "'+ respUser.credentials.recovery_question.question +'",'+
                        +'"oktauserid": "'+ respUser.id +'",'+
                        +'"oktauserstatus": "'+ respUser.status +'"'+
                        +'}';                    
                }
                else{
                    AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(responseUser.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    System.debug('@@@Okta Error response@@@' + respUserErr);
                    successMessage = '{'+
                        +'"messagetype": "ERROR",'+
                        +'"message": "'+ successMessage +'"'+
                        +'}'; 
                }
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return successMessage;
    }
    
    public HttpResponse GetAssociatedOktaGroups(String userName){
        
        HttpResponse responseUser = AGN_Okta.GetAssociatedOktaGroups(this.baseUrl, this.apiKey, userName);
        
        return responseUser;
    }
    public String SetPassword(String userId, String reqBody){
        
        String successMessage = '';
        try {
            HttpResponse responseUser = AGN_Okta.SetPassword(this.baseUrl, this.apiKey, userId, reqBody);
            if(responseUser != null){
                if (responseUser.getStatusCode() == 200) {                    
                    successMessage = '{"messagetype": "SUCCESS"}';                    
                }
                else{
                    AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(responseUser.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    System.debug('@@@Okta Error response@@@' + respUserErr);
                    successMessage = '{'+
                        +'"messagetype": "ERROR",'+
                        +'"message": "'+ successMessage +'"'+
                        +'}';  
                }
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return successMessage;
    }
    
    public String UpdateUser(String userId, String reqBody){
        
        String successMessage = '';
        try {
            HttpResponse responseUser = AGN_Okta.UpdateUser(userId, reqBody, this.baseUrl, this.apiKey);
            if(responseUser != null){
                if (responseUser.getStatusCode() == 200) {                    
                    successMessage = '{"messagetype": "SUCCESS"}';                    
                }
                else{
                    AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(responseUser.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    System.debug('@@@Okta Error response@@@' + respUserErr);
                    successMessage = '{'+
                        +'"messagetype": "ERROR",'+
                        +'"message": "'+ successMessage +'"'+
                        +'}'; 
                }
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return successMessage;
    }
    
    public String FirstTimeChgPWDSecurityQuestion(String reqBody){
        
        String successMessage = '';
        HttpResponse response = AGN_Okta.FirstTimeChgPWDSecurityQuestion(reqBody,this.baseUrl,this.apiKey,this.sfdcUserName);
        try {
            if(response != null){
                if (response.getStatusCode() == 200) { //success
                    System.debug('@@@Okta Success response@@@' + response.getBody());
                    successMessage = 'SUCCESS';
                } else {
                    AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    System.debug('@@@Okta Error response@@@' + respUserErr);  
                }
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return successMessage;
    }
    
    //Creating the Okta user as an inactive so that Okta does not send any email by default, email needs to be send from salesforce
    //Next step to activate that user as 'sendEmail=false' [preventing Okta to send any email]
    public String CreateUser(String reqBody){
        
        String successMessage = '';
        String result = '';
        //Creating the Okta user as an inactive so that Okta does not send any email by default, email needs to be send from salesforce
        HttpResponse response = AGN_Okta.CreateUserAsInactive(reqBody,this.baseUrl,this.apiKey);
        
        result = JSON.serialize(response.getBody());
        
        try {
            if(response != null){
                if (response.getStatusCode() == 200) { //success
                    System.debug('@@@Okta Success response-CreateUserAsInactive()@@@' + response.getBody());
                    AGN_OktaUserSuccessResponse respUser = AGN_OktaUserSuccessResponse.parse(response.getBody());
                    
                    successMessage = '{'+
                        +'"messagetype": "SUCCESS",'+
                        +'"Id": "'+ respUser.id +'",'+
                        +'"response": '+ result +
                        +'}'; 
                    //Next step to activate that user as 'sendEmail=false' [preventing Okta to send any email]
                    HttpResponse responseUser = AGN_Okta.ActivateUser(respUser.id, this.baseUrl, this.apiKey); 
                    
                    String resultUser = JSON.serialize(responseUser.getBody());
                    
                    if (responseUser.getStatusCode() == 200) { //success
                        //successMessage = 'SUCCESS';
                        System.debug('@@@Okta Success response-ActivateUser()@@@' + response.getBody());
                    }
                    else {                        
                        AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(responseUser.getBody());
                        String  errMsg = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                        successMessage = '{'+
                            +'"messagetype": "ERROR",'+
                            +'"message": "'+ errMsg +'",'+
                            +'"response": '+ resultUser +
                            +'}';
                        System.debug('@@@Okta Error response-ActivateUser()@@@' + successMessage);  
                    }
                } else {
                    AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
                    String  errMsg = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    successMessage = '{'+
                        +'"messagetype": "ERROR",'+
                        +'"message": "'+ errMsg +'",'+
                        +'"response": '+ result +
                        +'}';
                    System.debug('@@@Okta Error response-CreateUserAsInactive()@@@' + successMessage);  
                } 
            }
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return successMessage;
    }
    
    public String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz@$!#';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        Set<String> setArray = new Set<String> {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
            string randomUpper = getRandomString(setArray);
        setArray = new Set<String>{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
            string randomLower = getRandomString(setArray);        
        return randomUpper+randStr+'4$'+randomLower; 
    }
    public static String getRandomString(Set<String> setArray)
    {
        // Convert the Set to a list<br>
        List<String> lstArray = new List<String>();
        lstArray.addAll(setArray);
        //Generate a random list index
        Double randomNumber = Math.random();
        Integer arrayLength = lstArray.size();
        Integer randomIndex = (randomNumber *(arrayLength-1)).intValue();
        //Output the element at the list index generated above
        return lstArray[randomIndex];
    }
    
    /*
public void SendMail(String firstName, String userName, String userEmail, String userPassword){
Messaging.reserveSingleEmailCapacity(2);
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

String[] toAddresses = new String[] { userEmail }; 

mail.setToAddresses(toAddresses);

// Specify the address used when the recipients reply to the email. 
//mail.setReplyTo('UKCustomerServices@Allergan.com');

// Specify the name used as the display name.
mail.setSenderDisplayName('Allergan GCSP Support');

// Specify the subject line for your email address.
mail.setSubject('Allergan New Account Registration-Test');

mail.setHtmlBody('Dear '+ firstName +',<br />'+
'Your temporary Password:<b> ' + userPassword +' </b><br />'+
'Your Username :<b> ' + userName +' </b><br />'+
'To login <a href=https://gcspeudev-allergancommunityeu.cs84.force.com/customerUKI>click here.</a>');

// Send the email you have created.
List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
if (!results.get(0).isSuccess()) {
System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
String errorMessage = results.get(0).getErrors()[0].getMessage();
System.debug('Email ERROR: '+ errorMessage);
}
}
*/
    public HttpResponse CheckOktaLogin(String reqBody){
        
        HttpResponse response;
        try {
            response = AGN_Okta.CheckOktaLogin(this.baseUrl, this.apiKey, reqBody);
        }
        catch(System.CalloutException cex) {
            System.debug('Callout Error: '+ cex);          
        }
        catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
        }
        return response;
    }
    
    public class Session {
        public String id;
        public String userId;
        public Boolean mfaActive;
        public String cookieToken;
        public String cookieTokenUrl;
    }
    
    public static Session parseToSession(String json) {
        return (Session) System.JSON.deserialize(json, Session.class);
    }
}