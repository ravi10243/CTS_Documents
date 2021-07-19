public class AGN_OAM_CSUserPwdResetPageController {
    
    Public  String userName {get;set;}    
    public  Boolean ShowPb {get;set;}
    public  String newPassord {get;set;}
    public  Boolean isResetPassword {get;set;}
    public  list<OktaUserDatailsWrap> oktaUserWrapList{get;set;}
    public  Boolean showhideReset {get;set;}
    
    public AGN_OAM_CSUserPwdResetPageController(){
        oktaUserWrapList = new list<OktaUserDatailsWrap>();
        ShowPb = false;
        isResetPassword = false;
        showhideReset = false;
    }
    
    
    public  void getOktaUserData(){
        
        oktaUserWrapList = new list<OktaUserDatailsWrap>();
        oktaUserWrapList.clear();
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: <a href="http://www.regular-expressions.info/email.html" target="_blank" rel="nofollow">http://www.regular-expressions.info/email.html</a>
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(userName);
        
        if (!MyMatcher.matches()) {
            ApexPages.Message responseMessage = new ApexPages.Message(ApexPages.severity.Fatal, System.Label.AGN_OAM_PleaseEnterUserEmail);            
            Apexpages.addMessage(responseMessage);
            return; 
        }        
      
        String countryCode = System.Label.AGN_OAM_CountryCode;
        OktaUserDatailsWrap oktaUserWrap = new OktaUserDatailsWrap();
        String OKTABASEURL = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_Base_URL_AGN__c');
        String OKTAAPIKEY = (String)AGN_GCSP_Settings__c.getValues(countryCode).get('Okta_API_Key_AGN__c');
        String OktaUserId;
        
        HttpResponse response = AGN_Okta.GetUserDetails(OKTABASEURL, OKTAAPIKEY, userName);
        
       
                
        if(response != null && response.getStatusCode() == 200){
          AGN_OktaUserSuccessResponse respUser = AGN_OktaUserSuccessResponse.parse(response.getBody()); 
             
            System.debug('respUser :::::::::::::'+ respUser);
            
             HttpResponse responseUser = AGN_Okta.GetAssociatedOktaGroups(OKTABASEURL, OKTAAPIKEY, userName);
            
            list<AGN_OktaUserGroupsSuccessResponse> respUserGroups = AGN_OktaUserGroupsSuccessResponse.parse(responseUser.getBody()); 
            System.debug('responseUser::::::'+ respUserGroups);
            list<String> groupsList = new list<String>();
            
            Map<String, String> SfGroupMapIds = new Map<String, String>();
            
            for(AGN_GCSP_Settings__c groups : [SELECT Okta_SF_Community_Group_Id_AGN__c FROM AGN_GCSP_Settings__c]){
                if(String.isNotEmpty(groups.Okta_SF_Community_Group_Id_AGN__c)){
                    for(String sfGroup : groups.Okta_SF_Community_Group_Id_AGN__c.split(',')){
                        SfGroupMapIds.put(sfGroup,sfGroup);
                    }
                }
            }
            
            for(AGN_OktaUserGroupsSuccessResponse res : respUserGroups){
                
                String s = res.profile.Name+ ' : '+ res.Id;
                groupsList.add(s);
                if(String.isNotEmpty(SfGroupMapIds.get('"'+res.Id+'"'))){
                    isResetPassword =true;
                    break;
                }else{
                 isResetPassword = false;
                }                 
                
            }
                           
            system.debug('groupsList>>>>>>>>>'+groupsList);
                      
            oktaUserWrap.oktaUserName = respUser.Profile.login;
            oktaUserWrap.oktaUserEmail = respUser.Profile.email;
            oktaUserWrap.oktaUserId = respUser.Id;
            oktaUserWrap.oktaUserPayerIds = JSON.serialize(respUser.Profile.ad_associated_payer_accounts);
            oktaUserWrap.oktaUserShiptoIds = JSON.serialize(respUser.Profile.ad_associated_shipto_accounts);
            oktaUserWrap.oktaUserSitePermission = JSON.serialize(respUser.Profile.ad_site_permissions);
            oktaUserWrap.oktaUserSystemPermissions = JSON.serialize(respUser.Profile.ad_system_permissions);
            oktaUserWrap.oktaUserPwd = JSON.serialize(respUser.Credentials.password);
            oktaUserWrap.oktaUserRole = respUser.Profile.ad_user_role;
            oktaUserWrap.oktaUserFirstName = respUser.Profile.firstName;
            oktaUserWrap.oktaUserLstName = respUser.Profile.lastName; 
            oktaUserWrap.oktaUserPhone = respUser.Profile.mobilePhone; 
            oktaUserWrap.oktaAssignedGroupIds = JSON.serialize(groupsList);
            
            OktaUserId = String.isNotBlank(oktaUserWrap.oktaUserId) ? oktaUserWrap.oktaUserId : '';       
            
            list<User> uList = [SELECT ID, FirstName, LastName, Email, UserName, Phone, FederationIdentifier FROM User Where FederationIdentifier =: OktaUserId ];
            
            if(!uList.isEmpty()) oktaUserWrap.user = uList[0];
            
            oktaUserWrapList.add(oktaUserWrap); 
            
            if(!isResetPassword || uList.isEmpty()){
                ApexPages.Message infoMessage = new ApexPages.Message(ApexPages.severity.Error,  System.Label.AGN_OAM_CannotresetPwdErrorMsg);                
                Apexpages.addMessage(infoMessage);
                showhideReset = false;
            }else{
              showhideReset = true;
            
            }
            
            
        }else{
            
            ApexPages.Message responseMessage = new ApexPages.Message(ApexPages.severity.Fatal, System.Label.AGN_OAM_NoUserRecordsFound);
            
            Apexpages.addMessage(responseMessage);
            
            showhideReset = false;
            
        }
        
         if(oktaUserWrapList != null && !oktaUserWrapList.isEmpty()) ShowPb = true;
    }
    
    public class OktaUserDatailsWrap {
        public string oktaUserName {get;set;}
        public string oktaUserEmail {get;set;}
        public string oktaUserId {get;set;}
        public string oktaUserPayerIds {get;set;}
        public string oktaUserShiptoIds {get;set;}
        public string oktaUserSitePermission {get;set;}
        public string oktaUserSystemPermissions {get;set;}
        public string oktaUserPwd {get;set;}
        public string oktaUserRole {get;set;}
        public string oktaUserFirstName {get;set;}
        public string oktaUserLstName {get;set;}
        public string oktaUserPhone {get;set;}
        public string oktaUserRecoveryQ {get;set;}
        public string oktaAssignedGroupIds {get;set;}
        public User user {get;set;}
    }
    
    public  void resetPassword(){
        
        String apiKey = (String)AGN_GCSP_Settings__c.getValues('CA').get('Okta_API_Key_AGN__c');
        String baseUrl = (String)AGN_GCSP_Settings__c.getValues('CA').get('Okta_Base_URL_AGN__c');
        
        String reqBody;
        Boolean renderPW = true;   
       
        String reqPrefix = '{'+
            +'"credentials": {';
        
        String reqPWDBody = '"password" : { "value": "'+ newPassord +'"}';
        
        reqBody = reqPrefix + reqPWDBody +'}}';   
        
        ApexPages.Message successMessage;
        
        HttpResponse response = AGN_Okta.FirstTimeChgPWDSecurityQuestion(reqBody, baseUrl, apiKey, userName);
        
        System.debug('response:::::::::'+response);
        
        try {
            if(response != null){
                if (response.getStatusCode() == 200) { //success
                    System.debug('@@@Okta Success response@@@' + response.getBody());
                    successMessage = new ApexPages.Message(ApexPages.severity.confirm, System.Label.AGN_OAM_PwdResetSuccessMsg);
                } else {
                    AGN_OktaUserFailedResponse respUserErr = AGN_OktaUserFailedResponse.parse(response.getBody());
                    
                    String errorMsg = respUserErr.errorCauses.size() >0 ? respUserErr.errorCauses[0].errorSummary : respUserErr.errorSummary;
                    
                    successMessage = new ApexPages.Message(ApexPages.severity.Error, errorMsg); 
                    
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
      
      Apexpages.addMessage(successMessage);     
      
      showhideReset = false;

    }

}