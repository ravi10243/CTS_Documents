/**
 *
 * @Class Name: AGN_SPARK_PrivacyPolicy
 * @Created Date: 
 * @Description: Controller class for Priavacy Policy lightning component 
 * @Author: 
 * @History     :  
 */
public Without Sharing class AGN_SPARK_PrivacyPolicy {  //added without sharing keyword for Spring '21 release
    
 /*
 * Method to get image setups for privacy policy page
 */  
  @AuraEnabled
  public static Map<String, String> getImages(){
    return AGN_SPARK_Utility.getImageURL('PrivacyPolicy');
  }

}