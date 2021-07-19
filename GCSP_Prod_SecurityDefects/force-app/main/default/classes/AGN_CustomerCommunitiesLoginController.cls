/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class AGN_CustomerCommunitiesLoginController {
    
    global String username{get;set;}
    global String password{get;set;}
    global string musername{get;set;}
    global string mpassword{get;set;}
    
    public static final String USERNAME_SUFFIX = (String)AGN_GCSP_Settings__c.getValues('GB').get('CR_UserName_Suffix__c');

    global AGN_CustomerCommunitiesLoginController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        return Network.forwardToAuthPage(startUrl, displayType);
    }
    
    global PageReference login() {
        
        if (username != '' && password != '')
            return Site.login(username.trim() + '.' + USERNAME_SUFFIX, password, null);
        else if (musername != '' && mpassword != '')
            return Site.login(musername.trim() + '.' + USERNAME_SUFFIX, mpassword, null);
        else 
            return null;
    }

}