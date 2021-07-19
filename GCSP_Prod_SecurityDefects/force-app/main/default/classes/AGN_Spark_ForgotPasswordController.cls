/**
 *
 * @Class Name: AGN_Spark_ForgotPasswordController
 * @Created Date: 
 * @Description: Controller class for forget password controller
 * @Author: 
 * @History     :  
 */
public Without Sharing class AGN_Spark_ForgotPasswordController {  //added without sharing keyword for Spring '21 release
	
    public AGN_Spark_ForgotPasswordController() {
        
    }
   
	/*
     *  Method to trigger system forget password functionality
     */
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        String message =  '';
        Boolean isSuccess = true;
        try {
            Site.forgotPassword(username);
            message = Label.AGN_SPARK_Forgot_Email_Success;
            if(!Site.isValidUsername(username)) {
                message = Label.Site.invalid_email;
                isSuccess = false;
            }            
        }catch (Exception ex) {
            isSuccess = false;
            message =  ex.getMessage();
        }
        
        return '{"isSuccess" : '+isSuccess+', "message":"'+message+'"}';
    }

    /*
     *  Method to populate the value of the experience ID (expid) cookie in the user’s web browser.
     */
    @AuraEnabled
    public static String setExperienceId(String expId) {    
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
}