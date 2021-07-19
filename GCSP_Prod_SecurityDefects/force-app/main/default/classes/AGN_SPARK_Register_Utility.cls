public class AGN_SPARK_Register_Utility {
    public static Map<String, String> getPicklist(String objectType, String selectedField){
        Map<String, String> options             = new Map<String, String>();
        Schema.SObjectType convertToObj         = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res        = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult  = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> pList        = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickList: pList) {
            options.put(pickList.getValue(), pickList.getLabel());
        }
        return options;
    }
    
    /*this method is used to get the pagename and image URL from the Custom meta datatype by the pagename as parameter from the Component*/
    public static Map<String, String> getImageURL(String pageName){
        Map<String, String> imageDetails = new Map<String, String>();
        for (AGN_SPARK_Images__mdt img: [SELECT Label, Image_URL__c, Page_Name__c FROM AGN_SPARK_Images__mdt WHERE Page_Name__c =: pageName AND Active__c = TRUE]) {
            imageDetails.put(img.Label, img.Image_URL__c);
        }
        return imageDetails;
    }
    
    @future
    public static void insertUserWithRole(String userId) {
        System.resetPassword(userid,true);
    }
    
     public static Boolean userLogin(){   
         string userType =  UserInfo.getUserType();
         if(userType =='Guest')
         {
         return false;
         }
         else{
         return true;
         }
     
     }
     /*this method is created to generate unique alias value in order to aviod spark registartion failure*/
     public Static String generateAliasName(String fName , String lName){
      String firstName = fName;
      String lastName = lName;
      String prefix;
      Integer suff ;
        if((firstName != null && firstName.length() > 0) && (lastName != null && lastName.length() > 0)){
             prefix = firstName.substring(0, 1);
             prefix += lastName.substring(0,Math.min(lastName.length(), 4));
             
          List<Integer> suffixes = new List<Integer>();
          List<User> aliases = new List<User>([SELECT Alias,SMB_Alias_External_Id__c FROM User WHERE SMB_Alias_External_Id__c LIKE :prefix + '%']);   
            for(User usr : aliases){
                if(AGN_SPARK_Register_Utility.isNumeric(usr.Alias.substring(prefix.length()))){
                    suffixes.add(Integer.valueOf(usr.Alias.substring(prefix.length())));
                }
            }
            if(suffixes.size() == 0){
               suff =1;
               return prefix+suff;
            }
            suffixes.sort();
            
            List<Integer> applicableSuffixes = new List<Integer>();
            for(Integer i = 1; i<=999 ;i++){
                applicableSuffixes.add(i);
            }
            
            //List<Integer> unusedSuffixes = new List<Integer>();
            Integer availableSuffix;
            for(Integer item : applicableSuffixes){
                if (! suffixes.contains(item)){
                    availableSuffix = item;
                    break;
                }
               
            }
          return (prefix+availableSuffix);
          
       }
        return '';
     } 
   
    public static boolean isNumeric(String str) { 
      try {  
            Integer.valueOf(str);
            return true;
          } catch(Exception e){  
         return false;  
       }
    }
     
}