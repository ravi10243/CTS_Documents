/**
 *
 * @Class Name: AGN_SPARK_ResetPasswordController
 * @Created Date: 
 * @Description: Controller class for reset password VF page 
 * @Author: 
 * @History     :  
 */
public without sharing class AGN_SPARK_ResetPasswordController {
    
    public boolean changeSuccess {get; set;}
    public String userId {get; set;}
    public String newPassword {get; set;}
  	public String verifyNewPassword {get; set;}
    public string pageName {get;set;}
    public SPARK_Page_ZincCode_AGN__mdt zinc {get;set;}
    public String verifyUser {get; set;}
    
    /* 
     * Constructor  
     */
    public AGN_SPARK_ResetPasswordController(){
        zinc = new SPARK_Page_ZincCode_AGN__mdt();
        
        for (user usr:[SELECT id , Username FROM user WHERE id=: userInfo.getUserId()]){
            userId = usr.Username;
        }
        for(SPARK_Page_ZincCode_AGN__mdt znc : [SELECT Label,Date_of_Prep_AGN__c, Zinc_Code_AGN__c FROM SPARK_Page_ZincCode_AGN__mdt WHERE Label = 'ResetPasswordPage'  LIMIT 1]){
            zinc =  znc;
        }
    }
    
    /* 
     * Method to initiate system reset password  
     */
    public PageReference internalChangePassword() {
        changeSuccess = false;
        
        if(String.isNotBlank(newPassword) && String.isNotBlank(verifyNewPassword) && newPassword == verifyNewPassword ){
            System.setPassword(userInfo.getUserId(), verifyNewPassword);
            changeSuccess = true;
            PageReference pr = new PageReference(Site.getBaseUrl());
            return pr;
        }
        	return null;
	} 
}