/*
 *  Controller class fpr login component 
 */
global Without Sharing class AGN_SPARK_LoginController {  //added without sharing keyword for Spring '21 release
	
    public AGN_SPARK_LoginController() {
        
    }
	
    /*
     *  Method for login
     */
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
       
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            aura.redirect(lgn);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
     /*
     *  Method to check for is Username Password enabled
     */    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }
	
    /*
     *  Method to check for is self registration enabled
     */
    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    /*
     *  Method to get Self Registration Url
     */
    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }
	
    /*
     *  Method to get Forgot Password Url
     */
    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    /*
     *  Method to get AuthConfig
     */
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    /*
     *  Method to populate the value of the experience ID (expid) cookie in the user’s web browser.
     */
    @AuraEnabled
    global static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null; 
        } catch (Exception ex) {
            return ex.getMessage();            
        }
    }
    
    /*
     * This method is written for checking the user who logged in updated the profile or not
     */

    @AuraEnabled
    public static Boolean getUpdateProfile(String userId) {
        
        Allergan_Customer_Registration_AGN__c cReg = [SELECT id, AGN_SPARK_Update_my_Profile__c FROM Allergan_Customer_Registration_AGN__c WHERE AGN_SPARK_Update_my_Profile__c = False ];
    	return cReg.AGN_SPARK_Update_my_Profile__c;	
    }
    
    /*
     * This method is written for checking the site is under maintenace or not
     */
    @AuraEnabled
    public static boolean isSiteUnderMaintenance(){
        return boolean.valueOf(AGN_SPARK_Utility.SPARK_SETTINGS.AGN_Spark_Under_Maintainance__c);
    }

    
    
    
}