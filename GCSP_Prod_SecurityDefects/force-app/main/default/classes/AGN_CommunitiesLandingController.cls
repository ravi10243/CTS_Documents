/**
* An apex page controller that takes the user to the right start page based on credentials or lack thereof
*/
public with sharing class AGN_CommunitiesLandingController {
    public static string userCountryCode{get{return AGN_OAMConstant.USERCOUNTRYCODE;}}  
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        
        User currentUser = [Select Contact.Customer_Registration_AGN__c,Account.Customer_Registration_AGN__c,LocaleSidKey from User where Id =: UserInfo.getUserId() limit 1];
        system.debug('@@@@@@@@@@@userCountryCode ' + userCountryCode);
        system.debug('@@@@@@@@@@@' + AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Registration_Step2_Page__c'));
        
        if (currentUser.Account.Customer_Registration_AGN__c == 'In Progress' || currentUser.Contact.Customer_Registration_AGN__c == 'In Progress'){
            
            String pageUrl = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Registration_Step2_Page__c') +'?language='+currentUser.LocaleSidKey;
            //return new PageReference(AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Registration_Step2_Page__c'));//'/s/agncustomerregistration2');
            return new PageReference(pageUrl);
            
        }
        else{    
            //return Network.communitiesLanding();
            String pageUrl;
            if(AGN_OAMConstant.COMMUNITY_SUFFIX.equals('/') || String.isBlank(AGN_OAMConstant.COMMUNITY_SUFFIX)){
                pageUrl = AGN_OAMConstant.COMMUNITY_BASE_URL + '/s/?language='+currentUser.LocaleSidKey;
            }
            else{
                pageUrl = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX +'/s/?language='+currentUser.LocaleSidKey;
            }
            return new PageReference(pageUrl);
        }
    }
    
    public AGN_CommunitiesLandingController () {}
}