/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class AGN_CustomerCommunitiesLandingController {
    public static string userCountryCode{get{return AGN_CustomerRegistrationUtils.uInfo.Country_Code__c;}}  
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        
        User currentUser = [Select Account.Customer_Registration_AGN__c from User where Id =: UserInfo.getUserId() limit 1];
        
        if (currentUser.Account.Customer_Registration_AGN__c == 'In Progress')
            return new PageReference('/apex/'+(String)AGN_GCSP_Settings__c.getValues(userCountryCode).get('Registration_Step2_Page__c'));
        else    
            return Network.communitiesLanding();
    }
    
    public AGN_CustomerCommunitiesLandingController () {}
}