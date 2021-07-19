/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class AGN_CustomerForgotPasswordController {
    public String username {get; set;}   
    public boolean isSuccess {get; set;}
    public static final String USERNAME_SUFFIX = (String)AGN_GCSP_Settings__c.getValues('GB').get('CR_UserName_Suffix__c');
    
       
    public AGN_CustomerForgotPasswordController () {}
    
    public PageReference forgotPassword() {
        boolean success = Site.forgotPassword(username);
        PageReference pr = Page.ForgotPasswordConfirm;
        pr.setRedirect(true);
        
        if (success) {              
            return pr;
        }
        return null;
    }
    
    public void customforgotPassword() {
    	string userToReset = username + '.' + USERNAME_SUFFIX;
        boolean success = Site.forgotPassword(userToReset);
        isSuccess=success;
    }
    
}