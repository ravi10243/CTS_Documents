/* 
 *  The controller class for Footer lightning component
 */
public without sharing class AGN_SPARK_pageFooterController {
	
    /* 
     *  Method to fetch user details and page setting for the footer component 
     */
    @AuraEnabled
    public static map<string, string> getFooterSettings(){
        map<string, string> setup = new map<string, string>{'userType' => UserInfo.getUserType() ,
            												'croId' => '', 
            												'amiUrl' => AGN_SPARK_Utility.getSparkAMIRegisterURL(),
            												'siteUrl' => AGN_SPARK_Utility.getCommunityUrl()
            												};
                                                                
        Allergan_Customer_Registration_AGN__c cro = AGN_SPARK_Utility.getUserRegistrationDetails();
        if(cro != null){
           setup.put('croId', cro.Id);
        }
        
        return setup;
    }
    
    
}