/*
 *  Controller class for 404 page
 */
public Without Sharing class AGN_SPARK_404Error { //added without sharing keyword for Spring '21 release
   
    /*
     *  Method to fetch image setup for 404 page
     */
   @AuraEnabled
   public static Map<String, String> getImages(){
        return AGN_SPARK_Utility.getImageURL('404Errorpage');
    }
    
}