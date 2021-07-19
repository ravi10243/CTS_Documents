/*
 *  Controller class for contact us body component
 */
public Without Sharing class AGN_SPARK_ContactUs { //added without sharing keyword for Spring '21 release
   
   /*
    *  Method to fetch contactus page images
    */
   @AuraEnabled
   public static Map<String, String> getImages(){        
        return AGN_SPARK_Utility.getImageURL('ContactPage');
    }
}