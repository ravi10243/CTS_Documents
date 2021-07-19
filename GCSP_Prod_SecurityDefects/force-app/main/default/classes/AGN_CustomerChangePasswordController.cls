/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class AGN_CustomerChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {        
        return Site.changePassword(newPassword, verifyNewPassword);    
    }     
    
    public AGN_CustomerChangePasswordController () {}
}