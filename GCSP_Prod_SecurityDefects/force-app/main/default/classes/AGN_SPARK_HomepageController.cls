/*
 *  The controller class for AGN_SPARK_HomeBody Lightning Component
 */
public without sharing class AGN_SPARK_HomepageController {
	
   /*
	* This method is used to get the home page images and to show those images in the UI
	*/ 
   @AuraEnabled
   public static Map<String, String> getImages(){
      

        Map<String, String> imageMap = AGN_SPARK_Utility.getImageURL('HomePage');
        return imageMap;
   }
    
    /*
	* Method is get logined User profiles from Allergan Customer Registration Record
	*/
    @AuraEnabled
    public static Allergan_Customer_Registration_AGN__c getAcrDetails() {
        Allergan_Customer_Registration_AGN__c acr = AGN_SPARK_Utility.getUserRegistrationDetails();
       	return acr;
    }
    
    /*
	* Method to get logined User profiles
	*/
    @AuraEnabled
    public static BodyWrapper getUserDetails(){
        BodyWrapper bw  = new BodyWrapper();
        bw.logIn 		= UserInfo.getUserType();
        bw.acrDetails	= AGN_SPARK_HomepageController.getAcrDetails(); 
        bw.isLogined = AGN_SPARK_Utility.isUserLogin();
        return bw;
    }
    
    /*
	* Wrapper calss to sent data for lightning component
	*/
    public class BodyWrapper{
        @AuraEnabled public string logIn;
        @AuraEnabled public Allergan_Customer_Registration_AGN__c acrDetails;
        @AuraEnabled public Boolean isLogined; 
    }
}