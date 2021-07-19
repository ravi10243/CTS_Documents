/**
 * @Class Name: AGN_SPARK_TermsOfUse
 * @Created Date: 
 * @Description: Controller calss for the Terms of Use Page
 * @Author: 
 * @History     :  
 */
public Without Sharing class AGN_SPARK_TermsOfUse {  //added without sharing keyword for Spring '21 release
   /*
    * Method to get image setups for Terms of Use page 
    */
   @AuraEnabled
   public static Map<String, String> getImages(){
		return AGN_SPARK_Utility.getImageURL('TermsofusePage');
    }
}