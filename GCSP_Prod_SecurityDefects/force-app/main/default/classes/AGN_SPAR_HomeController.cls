public Without Sharing class AGN_SPAR_HomeController { //added without sharing keyword for Spring '21 release
    public static boolean userLogged;
    @auraenabled
    public static boolean userType(){
	AGN_SPARK_Utility agn = new AGN_SPARK_Utility();
    userLogged = AGN_SPARK_Utility.isUserLogin();
    return userLogged;
    }
    /*
	* This method is used to get the home page images and to show those images in the UI
	*/ 
   @AuraEnabled
   public static Map<String, String> getImages(){
      

        Map<String, String> imageMap = AGN_SPARK_Utility.getImageURL('HomePage');
        return imageMap;
   }
}