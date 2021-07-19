public class AGN_OAMPortalLandingController {
    
    public static string userCountryCode{get{return AGN_OAMConstant.USERCOUNTRYCODE;}}  
    
    public AGN_OAMPortalLandingController () {}
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        
        User currentUser = [Select Contact.Customer_Registration_AGN__c,LocaleSidKey from User where Id =: UserInfo.getUserId() limit 1];
        system.debug('@@@@@@@@@@@userCountryCode ' + userCountryCode);
        system.debug('@@@@@@@@@@@' + AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Registration_Step2_Page__c'));
        
        if (currentUser.Contact.Customer_Registration_AGN__c == 'In Progress'){
            
            String pageUrl;
            //String pageUrl = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX + (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Registration_Step2_Page__c') +'?language='+currentUser.LocaleSidKey;
            if(userCountryCode != 'BR'){             
                if(AGN_OAMConstant.COMMUNITY_SUFFIX.equals('/') || String.isBlank(AGN_OAMConstant.COMMUNITY_SUFFIX)){
                    pageUrl = AGN_OAMConstant.COMMUNITY_BASE_URL + '/' + (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Registration_Step2_Page__c') 
                        +'?language='+currentUser.LocaleSidKey;
                }
                else{
                    pageUrl = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX 
                        + (String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Registration_Step2_Page__c') 
                        +'?language='+currentUser.LocaleSidKey;
                }
            }else{
                pageUrl = '/apex/'+(String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Registration_Step2_Page__c');
            }
            return new PageReference(pageUrl);
        }
        else{    
            //return Network.communitiesLanding();
            String pageUrl;
            if(AGN_OAMConstant.COMMUNITY_SUFFIX.equals('/') || String.isBlank(AGN_OAMConstant.COMMUNITY_SUFFIX)){
                //pageUrl = AGN_OAMConstant.COMMUNITY_BASE_URL + '/s/?language='+currentUser.LocaleSidKey;
                pageUrl = AGN_OAMConstant.COMMUNITY_BASE_URL + '/s/';
            }
            else{
                //pageUrl = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX +'/s/?language='+currentUser.LocaleSidKey;
                pageUrl = AGN_OAMConstant.COMMUNITY_BASE_URL + AGN_OAMConstant.COMMUNITY_SUFFIX +'/s/';
            }
            if(userCountryCode != 'BR'){
                pageUrl += '?language='+currentUser.LocaleSidKey;
            }
            return new PageReference(pageUrl);
        }
    }
}