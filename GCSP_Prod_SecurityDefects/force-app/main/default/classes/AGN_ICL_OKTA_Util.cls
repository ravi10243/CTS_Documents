public class AGN_ICL_OKTA_Util {
    
    public String baseUrl {get;set;}
    public String apiKey {get;set;}
    public String sfdcUserName {get;set;}
    
    public AGN_ICL_OKTA_Util(){
        this.baseUrl = AGN_ICL_Portal_Settings__c.getInstance().Okta_Base_URL_AGN__c;//AGN_OAMConstant.OKTABASEURL;
        this.apiKey = AGN_ICL_Portal_Settings__c.getInstance().Okta_API_Key_AGN__c;//AGN_OAMConstant.OKTAAPIKEY;
        //String userName = AGN_OAMConstant.OKTA_USER_SAMEAS_PORTAL_USER ? UserInfo.getUserName() : UserInfo.getUserName();
        //this.sfdcUserName = userName;
    }
    /*public AGN_ICL_OKTA_Util(String countryCode, String sfdcUserName){
        this.baseUrl = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_Base_URL_AGN__c');// AGN_CustomerPortal_Constant.OKTABASEURL;
        this.apiKey = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_API_Key_AGN__c');
        this.sfdcUserName = sfdcUserName;
    }*/
    
    public Boolean IsOktaPWDChangedSinceUserCreation(){
        
        Boolean forcePWDReset = false;
        HttpResponse response = AGN_ICLOkta.GetUserDetails(this.baseUrl,this.apiKey,this.sfdcUserName);
        try {
            if(response != null){
                if (response.getStatusCode() == 200) {
                    AGN_ICL_OktaUserSuccessResponse respUser = AGN_ICL_OktaUserSuccessResponse.parse(response.getBody());
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

                    }
                    
                } else {
                    AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(response.getBody());
                    
                    //raise error
                }
            }
        }
        catch(System.CalloutException cex) {
     
        }
        catch( System.Exception ex) {

        }
        return forcePWDReset;
    }
    
     public String getOktaUserCountry(String oktaUserName){
		       String message = '';
        HttpResponse response = AGN_ICLOkta.GetUserDetails(this.baseUrl, this.apiKey, oktaUserName);
        if(response != null){
            if(response.getStatusCode() == 200)
            {
                AGN_ICL_OktaUserSuccessResponse respUser = AGN_ICL_OktaUserSuccessResponse.parse(response.getBody());
                message = '{'+
                    +'"messagetype": "SUCCESS",'+
                    +'"Id": "'+ respUser.id +'",'+
                    +'"countrycode": "'+ respUser.profile.countryCode +'",'+
                    +'"Status": "'+ respUser.status +'"'+
                    +'}';  
            }
             else
             {
                 String errMsg = 'No user found';
                 message = '{'+
                    +'"messagetype": "ERROR",'+
                    +'"message": "'+ errMsg +'"'+
                    +'}';
             }
        }
       else {
                //no user found
                AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(response.getBody());
                string errMsg = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                message = '{'+
                    +'"messagetype": "ERROR",'+
                    +'"message": "'+ errMsg +'"'+
                    +'}';  
            }
       return message;
   }
	/*This method is to check if the user is present in OKTA*/ 
    public String isPresentInOkta(String oktaUserName){
        
        String message = '';
        HttpResponse response = AGN_ICLOkta.GetUserDetails(this.baseUrl, this.apiKey, oktaUserName);
        if(response != null){
            //found user
            if (response.getStatusCode() == 200) {
                AGN_ICL_OktaUserSuccessResponse respUser = AGN_ICL_OktaUserSuccessResponse.parse(response.getBody());
                message = '{'+
                    +'"messagetype": "SUCCESS",'+
                    +'"Id": "'+ respUser.id +'",'+
                    +'"Status": "'+ respUser.status +'"'+
                    +'}';               
            } else {
                //no user found
                AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(response.getBody());
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
        HttpResponse response = AGN_ICLOkta.FirstTimeChgPWDSecurityQuestion(reqBody, this.baseUrl, this.apiKey, userName);
        try {
            if(response != null){
                if (response.getStatusCode() == 200) { //success
                    successMessage = 'SUCCESS';
                } else {
                    AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(response.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                }
            }
        }
        catch(System.CalloutException cex) {
       
        }
        catch( System.Exception ex) {

        }
        return successMessage;
    }
    
    public AGN_ICL_OktaUserFailedResponse ChangeOktaPassword(String reqBody, String userName){
        
        String successMessage = '';
        AGN_ICL_OktaUserFailedResponse respUserErr = new AGN_ICL_OktaUserFailedResponse();
        HttpResponse response = AGN_ICLOkta.FirstTimeChgPWDSecurityQuestion(reqBody, this.baseUrl, this.apiKey, userName);
        try {
            if(response != null){
                if (response.getStatusCode() == 200) { //success
                    respUserErr.errorCode = 'SUCCESS';
                } else {
                    respUserErr = AGN_ICL_OktaUserFailedResponse.parse(response.getBody());
                    //successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                }
            }
        }
        catch(System.CalloutException cex) {
        
        }
        catch( System.Exception ex) {

        }
        return respUserErr;
    }
    
    public String AddUserToGroup(String groupId, String userName){
        
        String successMessage = '';
        HttpResponse response = null;
        try {
            HttpResponse responseUser = AGN_ICLOkta.GetUserDetails(this.baseUrl,this.apiKey,userName);
            if(responseUser != null){
                if (responseUser.getStatusCode() == 200) {
                    AGN_ICL_OktaUserSuccessResponse respUser = AGN_ICL_OktaUserSuccessResponse.parse(responseUser.getBody());
                    
                    //List<String> lstGroupId = groupId.split(','); //"00g1ejknx1aUagHTf1d8","00g1eox23lscKXT1c1d8"
                    //for(String gpId : lstGroupId){
                        response = AGN_ICLOkta.AddUserToGroup(groupId.replace('"',''), respUser.id, this.baseUrl, this.apiKey);
                        
                        if(response != null){
                            if (response.getStatusCode() == 204) { //success =>(204 No Content) The server successfully processed the request, but is not returning any content.
                                successMessage = 'SUCCESS';
                            } else {
                                AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(response.getBody());
                                successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                            }
                        }
                    //}
                }
                else{
                    successMessage = 'User not found: '+ this.sfdcUserName;
                }
            }
        }
        catch(System.CalloutException cex) {
          
        }
        catch( System.Exception ex) {

        }
        return successMessage;
    }
    public String GetSecurityQuestion(String userName){
        
        String successMessage = '';
        try {
            HttpResponse responseUser = AGN_ICLOkta.GetUserDetails(this.baseUrl,this.apiKey,userName);
            if(responseUser != null){
                if (responseUser.getStatusCode() == 200) {
                    AGN_ICL_OktaUserSuccessResponse respUser = AGN_ICL_OktaUserSuccessResponse.parse(responseUser.getBody());
                    //System.debug('@@@Okta Success response@@@' + objRecovery_question);
                    
                    successMessage = '{'+
                        +'"messagetype": "SUCCESS",'+
                        +'"message": "'+ respUser.credentials.recovery_question.question +'",'+
                        +'"message": "'+ respUser.credentials.recovery_question.question +'",'+
                        +'"oktauserid": "'+ respUser.id +'",'+
                        +'"oktauserstatus": "'+ respUser.status +'"'+
                        +'}';                    
                }
                else{
                    AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(responseUser.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    successMessage = '{'+
                        +'"messagetype": "ERROR",'+
                        +'"message": "'+ successMessage +'"'+
                        +'}'; 
                }
            }
        }
        catch(System.CalloutException cex) {
         
        }
        catch( System.Exception ex) {

        }
        return successMessage;
    }
    public String SetPassword(String userId, String reqBody){
        
        String successMessage = '';
        String errorCode = '';
        try {
            HttpResponse responseUser = AGN_ICLOkta.SetPassword(this.baseUrl, this.apiKey, userId, reqBody);
            if(responseUser != null){
                if (responseUser.getStatusCode() == 200) {                    
                    successMessage = '{"messagetype": "SUCCESS"}';                    
                }
                else{
                    AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(responseUser.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    errorCode = respUserErr.errorCode;
                    successMessage = successMessage +','+ errorCode;
                    successMessage = '{'+
                        +'"messagetype": "ERROR",'+
                        +'"message": "'+ successMessage +'"'+
                        +'}';  
                }
            }
        }
        catch(System.CalloutException cex) {
       
        }
        catch( System.Exception ex) {

        }
        return successMessage;
    }
    
    public String UpdateUser(String userId, String reqBody){
        
        String successMessage = '';
        try {
            HttpResponse responseUser = AGN_ICLOkta.UpdateUser(userId, reqBody, this.baseUrl, this.apiKey);
            if(responseUser != null){
                if (responseUser.getStatusCode() == 200) {                    
                    successMessage = '{"messagetype": "SUCCESS"}';                    
                }
                else{
                    AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(responseUser.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    successMessage = '{'+
                        +'"messagetype": "ERROR",'+
                        +'"message": "'+ successMessage +'"'+
                        +'}'; 
                }
            }
        }
        catch(System.CalloutException cex) {
         
        }
        catch( System.Exception ex) {

        }
        return successMessage;
    }
    
    public String FirstTimeChgPWDSecurityQuestion(String reqBody){
        
        String successMessage = '';
        HttpResponse response = AGN_ICLOkta.FirstTimeChgPWDSecurityQuestion(reqBody,this.baseUrl,this.apiKey,this.sfdcUserName);
        try {
            if(response != null){
                if (response.getStatusCode() == 200) { //success
                    successMessage = 'SUCCESS';
                } else {
                   AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(response.getBody());
                    successMessage = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                }
            }
        }
        catch(System.CalloutException cex) {          
        }
        catch( System.Exception ex) {
        }
        return successMessage;
    }
    
    //Creating the Okta user as an inactive so that Okta does not send any email by default, email needs to be send from salesforce
    //Next step to activate that user as 'sendEmail=false' [preventing Okta to send any email]
    public String CreateUser(String reqBody){
        
        String successMessage = '';
        
        //Creating the Okta user as an inactive so that Okta does not send any email by default, email needs to be send from salesforce
        HttpResponse response = AGN_ICLOkta.CreateUserAsInactive(reqBody,this.baseUrl,this.apiKey);
        try {
            if(response != null){
                if (response.getStatusCode() == 200) { //success
                    AGN_ICL_OktaUserSuccessResponse respUser = AGN_ICL_OktaUserSuccessResponse.parse(response.getBody());
                    
                    successMessage = '{'+
                        +'"messagetype": "SUCCESS",'+
                        +'"Id": "'+ respUser.id +'"'+
                        +'}'; 
                    //Next step to activate that user as 'sendEmail=false' [preventing Okta to send any email]
                    HttpResponse responseUser = AGN_ICLOkta.ActivateUser(respUser.id, this.baseUrl, this.apiKey); 
                    if (responseUser.getStatusCode() == 200) { //success
                        //successMessage = 'SUCCESS';
                    }
                    else {
                        AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(responseUser.getBody());
                        String  errMsg = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                        successMessage = '{'+
                            +'"messagetype": "ERROR",'+
                            +'"message": "'+ errMsg +'"'+
                            +'}'; 
                    }
                } else {
                   AGN_ICL_OktaUserFailedResponse respUserErr = AGN_ICL_OktaUserFailedResponse.parse(response.getBody());
                    String  errMsg = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    successMessage = '{'+
                        +'"messagetype": "ERROR",'+
                        +'"message": "'+ errMsg +'"'+
                        +'}';
                } 
            }
        }
        catch(System.CalloutException cex) {         
        }
        catch( System.Exception ex) {
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
    
     public HttpResponse CheckOktaLogin(String reqBody){
             
        HttpResponse response;
        try {
            response = AGN_ICLOkta.CheckOktaLogin(this.baseUrl, this.apiKey, reqBody);
        }
        catch(System.CalloutException cex) {

        }
        catch( System.Exception ex) {
 
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