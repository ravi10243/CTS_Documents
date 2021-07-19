/**
 *
 * @Class Name: AGN_SPARK_Utility
 * @Created Date: 
 * @Description: Class for spark common methods
 * @Author: 
 * @History     :  
 */
public class AGN_SPARK_Utility { 
    
    public static final string ARTICLE_PUBLISH_STATUS = 'Online'; 
    public static AGN_SPARK_Settings__c SPARK_SETTINGS = AGN_SPARK_Settings__c.getOrgDefaults(); 
    public static AGN_SPARK_Enable_Countries__c EnableCountries = AGN_SPARK_Enable_Countries__c.getOrgDefaults();
    
   
    /*
     * Common method to get pickList values by object name & filed name
     */ 
    public static Map<String, String> getPicklist(String objectType, String selectedField){

        Map<String, String> options             = new Map<String, String>();        
        if(String.isNotBlank(objectType) && String.isNotBlank(selectedField) ){
            Schema.SObjectType convertToObj         = Schema.getGlobalDescribe().get(objectType);
            Schema.DescribeSObjectResult res        = convertToObj.getDescribe();
            Schema.DescribeFieldResult fieldResult  = res.fields.getMap().get(selectedField).getDescribe();
            List<Schema.PicklistEntry> pList        = fieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry pickList: pList) {
                options.put(pickList.getValue(), pickList.getLabel());
            }
        }
        return options;
    }
    
    /*
    * Method to get the page image URLs from the Custom metadatatype by the pagename 
    */    
    public static Map<String, String> getImageURL(String pageName){
        Map<String, String> imageDetails = new Map<String, String>();
        for (AGN_SPARK_Images__mdt img: [SELECT Label, Image_URL__c, Page_Name__c FROM AGN_SPARK_Images__mdt WHERE Page_Name__c =: pageName AND Active__c = TRUE]) {
            imageDetails.put(img.Label, img.Image_URL__c);
        }
        return imageDetails;
    }
    
    /*
    * Method to identify logined user
    */
    public static Boolean isUserLogin(){   
         string userType =  UserInfo.getUserType();
         if(userType =='Guest'){
            return false;
         }
         return true;
     
     }
    
    /*
    * Method to fetch all Knowledge Article categories 
    */           
    public static DescribeDataCategoryGroupResult[] getAllMainCategories(){
      List<DescribeDataCategoryGroupResult> describeCategoryResult;
      try {
         //Creating the list of sobjects to use for the describe call
         List<String> objType = new List<String>();
         objType.add('KnowledgeArticleVersion');
         //Describe Call
         describeCategoryResult = Schema.describeDataCategoryGroups(objType);
      } catch(Exception e){
          AGN_SPARK_ErrorLogHandler.createExceptionsLog(e, 'AGN_SPARK_Utility' ); 
          system.debug('Error:'+e.getMessage());
      }

      return describeCategoryResult;
   }
    
   /*
    * Method to fetch Knowledge Hub Article categories 
    */
    public static DescribeDataCategoryGroupStructureResult[] getKnowledgeHubCategories(){
        return getCategoriesByGroupName(getKnowledgeHubGroupName());
    }
    
    /*
    * Method to fetch Training Provider Article categories 
    */
    public static DescribeDataCategoryGroupStructureResult[] getTrainingProviderCategories(){
            return getCategoriesByGroupName(getTrainingProviderGroupName());
    } 
    
    /*
    * Method to fetch Training Provider Main categories 
    */
    public static Map<String, String> getTrainingMainCatgories(){
         return getTopLevelCatgories(getTrainingProviderGroupName());
    }
    
    /*
    * Method to fetch Training Provider sub-categories 
    */
    public static Map<String, String> getTrainingSubCatgories(String mainCat){
         return getSubCatgories(getTrainingProviderGroupName(), mainCat, '');
    }
    
    /*
    * Method to fetch  Knowledge Hub Article main categories by group name
    */
    public static Map<String, String> getKnowledgeMainCatgories(){
         return getTopLevelCatgories(getKnowledgeHubGroupName());
    }
    
    /*
    * Method to fetch  Knowledge Hub Article main sub-categories
    */
    public static Map<String, String> getKnowledgeSubCatgories(String mainCat){
         return getSubCatgories(getKnowledgeHubGroupName(), mainCat, '');
    }
    
    /*
    * Method to fetch Article top level categories by group name
    */
    private static Map<String, String> getTopLevelCatgories(String groupName){
        Map<String, String> catList = new Map<String, String>();
        if(String.isNotBlank(groupName)){
            DescribeDataCategoryGroupStructureResult[] dataCatGroup  = getCategoriesByGroupName(groupName);

           if(dataCatGroup.size() > 0){
               
                for(DataCategory topLevel : dataCatGroup[0].getTopCategories()){
                    for(DataCategory firstLevel : topLevel.getChildCategories()){
                        catList.put(firstLevel.getName(), firstLevel.getLabel());
                    }
                }
            }
        }
        return catList;
    }
    
    /*
    * Method to fetch Article sub-categories by group name
    */
    private static Map<String, String> getSubCatgories(String groupName, String mainCat, String subCat){
        Map<String, String> catList = new Map<String, String>();
        if(String.isNotBlank(groupName) && String.isNotBlank(mainCat)){
            DescribeDataCategoryGroupStructureResult[] dataCatGroup  = getCategoriesByGroupName(groupName);

           if(dataCatGroup.size() > 0){
               
                for(DataCategory topLevel : dataCatGroup[0].getTopCategories()){
                    for(DataCategory firstLevel : topLevel.getChildCategories()){
                        if(firstLevel.getName() != mainCat){
                            continue;
                        }
                        
                        for(DataCategory secondLevel : firstLevel.getChildCategories()){
                            if(!String.isNotBlank(subCat)){
                                catList.put(secondLevel.getName(), secondLevel.getLabel());
                            }else{
                               if(secondLevel.getName() != subCat){
                                    continue;
                               }
                               for(DataCategory thirdLevel : secondLevel.getChildCategories()){
                                   catList.put(thirdLevel.getName(), thirdLevel.getLabel());
                               }
                            }
                        } 
                        
                    }
                }
            }
        }
        return catList;
    }
    
    /*
    * Method to fetch Article categories by group name
    */
    public static DescribeDataCategoryGroupStructureResult[] getCategoriesByGroupName(String groupName){
        
        List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
        if(String.isNotBlank(groupName)){
            try {
             // Making the call to the describeDataCategoryGroups to
             // get the list of category groups associated
            
             List<DescribeDataCategoryGroupResult> describeCategoryResult;

             List<String> objType = new List<String>();
             objType.add('KnowledgeArticleVersion');
             describeCategoryResult = Schema.describeDataCategoryGroups(objType);
             
             //Creating a list of pair objects to use as a parameter
             //for the describe call
             List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
             
             //Looping throught the first describe result to create
             //the list of pairs for the second describe call
             for(DescribeDataCategoryGroupResult singleResult :  describeCategoryResult){
                
                if(singleResult.getName() != groupName){
                     continue;
                }
                DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
                p.setSobject(singleResult.getSobject());
                p.setDataCategoryGroupName(singleResult.getName());
                pairs.add(p);
             }
             
             //describeDataCategoryGroupStructures
             describeCategoryStructureResult =   Schema.describeDataCategoryGroupStructures(pairs, false);
    
             //Getting data from the result
             for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
                //Get name of the associated Sobject
                singleResult.getSobject();
    
                //Get the name of the data category group
                singleResult.getName();
    
                //Get the name of the data category group
                singleResult.getLabel();
    
                //Get the description of the data category group
                singleResult.getDescription();
    
                //Get the top level categories
                DataCategory [] toplevelCategories =  singleResult.getTopCategories();
                
                //Recursively get all the categories
                List<DataCategory> allCategories =   getAllCategories(toplevelCategories);
    
                for(DataCategory category : allCategories) {
                   //Get the name of the category
                   category.getName();
    
                   //Get the label of the category
                   category.getLabel();
    
                   //Get the list of sub categories in the category
                   DataCategory [] childCategories =  category.getChildCategories();
                    
                }
             }
          } catch (Exception e){
             AGN_SPARK_ErrorLogHandler.createExceptionsLog(e, 'AGN_SPARK_Utility' ); 
             system.debug('Error:'+e.getMessage());
          } 
        }
        //system.debug('Child Categories '+ JSON.serialize(describeCategoryStructureResult));
        return describeCategoryStructureResult;
    }
    
    /*
    * Method to fetch Article categories by group name
    */
    public static DescribeDataCategoryGroupStructureResult[] getAllCategories(){
      List<DescribeDataCategoryGroupResult> describeCategoryResult;
      List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
      try {
         //Making the call to the describeDataCategoryGroups to
         //get the list of category groups associated
         List<String> objType = new List<String>();
         objType.add('KnowledgeArticleVersion');
         describeCategoryResult = Schema.describeDataCategoryGroups(objType);
         
         //Creating a list of pair objects to use as a parameter
         //for the describe call
         List<DataCategoryGroupSobjectTypePair> pairs = 
            new List<DataCategoryGroupSobjectTypePair>();
         
         //Looping throught the first describe result to create
         //the list of pairs for the second describe call
         for(DescribeDataCategoryGroupResult singleResult : 
         describeCategoryResult){
            DataCategoryGroupSobjectTypePair p =
               new DataCategoryGroupSobjectTypePair();
            p.setSobject(singleResult.getSobject());
            p.setDataCategoryGroupName(singleResult.getName());
            pairs.add(p);
         }
         
         //describeDataCategoryGroupStructures()
         describeCategoryStructureResult = 
            Schema.describeDataCategoryGroupStructures(pairs, false);

         //Getting data from the result
         for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
            //Get name of the associated Sobject
            singleResult.getSobject();

            //Get the name of the data category group
            singleResult.getName();

            //Get the name of the data category group
            singleResult.getLabel();

            //Get the description of the data category group
            singleResult.getDescription();

            //Get the top level categories
            DataCategory [] toplevelCategories = 
               singleResult.getTopCategories();
            
            //Recursively get all the categories
            List<DataCategory> allCategories = 
               getAllCategories(toplevelCategories);

            for(DataCategory category : allCategories) {
               //Get the name of the category
               category.getName();

               //Get the label of the category
               category.getLabel();

               //Get the list of sub categories in the category
               DataCategory [] childCategories = 
                  category.getChildCategories();
               // system.debug('Child Categories '+ childCategories);
                //system.debug('allCategories '+ allCategories);
                //system.debug('toplevelCategories '+ toplevelCategories);
            }
         }
      } catch (Exception e){
          AGN_SPARK_ErrorLogHandler.createExceptionsLog(e, 'AGN_SPARK_Utility' ); 
          system.debug('Error:'+e.getMessage());
      } 
      return describeCategoryStructureResult;
    }
    
    /*
    *  Recursive  Method to fetch sub categories of a given category
    */
    private static DataCategory[] getAllCategories(DataCategory [] categories){
      if(categories.isEmpty()){
         return new DataCategory[]{};
      } else {
         DataCategory [] categoriesClone = categories.clone();
         DataCategory category = categoriesClone[0];
         DataCategory[] allCategories = new DataCategory[]{category};
         categoriesClone.remove(0);
         categoriesClone.addAll(category.getChildCategories());
         allCategories.addAll(getAllCategories(categoriesClone));
         return allCategories;
      }
   }
   
   /*
   * Method to fetch Knowledge Hub categories group name from Custom Settings
   */
   public static String getKnowledgeHubGroupName(){
      return SPARK_SETTINGS.Knowledge_Hub_Article_Group__c;
   }
   
   /*
   * Method to fetch Training Provider categories group name from Custom Settings
   */
   public static String getTrainingProviderGroupName(){
      return SPARK_SETTINGS.Training_Provider_Article_Group__c;
   }
   
   /*
   * Method to fetch Training Provider List Page Limit from Custom Settings
   */
   public static integer getTrainingProviderPageLimit(){
      return Integer.valueOf(SPARK_SETTINGS.AGN_SPARK_TrainingProviderPageLimit__c);
   }
   
   /*
   * Method to fetch KnowledgeHub List Page Limit from Custom Settings
   */
   public static integer getKnowledgeHubPageLimit(){
      return Integer.valueOf(SPARK_SETTINGS.AGN_SPARK_KnowledgeHubPageLimit__c);
   }

   /*
   * Method to fetch Spark CRO RecordType name from Custom Settings
   */
   public static string getSparkCroRecordType(){
      return SPARK_SETTINGS.AGN_SPARK_cro_record_type_name__c;
   }
    
   /*
   * Method to fetch Spark CRO RecordType id from Custom Settings
   */
   public static id getSparkCroRecordTypeId(){
        id recordTypeId;
        try{
            string croRecName = getSparkCroRecordType();
            if(String.isNotBlank(croRecName)){
                        recordTypeId = Schema.SObjectType.Allergan_Customer_Registration_AGN__c.getRecordTypeInfosByName().get(croRecName).getRecordTypeId();               
            }
        }catch(Exception e){
        
        }
       return recordTypeId;
   }
    
  
   
   /*
   * Method to fetch AMI Register URL from Custom Settings
   */
   public static string getSparkAMIRegisterURL(){
      return SPARK_SETTINGS.AGN_AMI_Register_URL__c;
   } 
   
   /*
   * Method to fetch Spark Team Email Settings from Custom Settings
   */    
   public static map<string, string> getSparkTeamEmailSettings(){
       return new map<string, string>{
           'toEmail' => SPARK_SETTINGS.SPARK_team_email_AGN__c,
           'emailTemplate' => SPARK_SETTINGS.SPARK_team_email_template_AGN__c
               };
   }
    
   /*
   * Method to fetch Spark Team Email Template from Custom Settings
   */ 
   public static EmailTemplate getSparkTeamEmailTemplate(){
       EmailTemplate template;
        for(EmailTemplate tpl : [SELECT id, Subject, Body FROM EmailTemplate where DeveloperName =:SPARK_SETTINGS.SPARK_team_email_template_AGN__c LIMIT 1]){
            template = tpl;
        }
        
     return template;
   }
    
   /*
   * Method to fetch user registrion details for logined used
   */
    public static Allergan_Customer_Registration_AGN__c getUserRegistrationDetails() {
        Id accountId;
        Id contactId;
        for(user u :[SELECT Name,userName,Email,ContactId FROM User WHERE Id =: UserInfo.getUserId() ]){
            contactId = u.ContactId;
        }

        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();
        for(AccountContactRelation acrL : [SELECT ContactId, AccountId FROM AccountContactRelation WHERE ContactId != NULL AND ContactId = :contactId AND Account.recordTypeId =:accRecordTypeId]){
            accountId = acrL.AccountId;
        }
        
        Allergan_Customer_Registration_AGN__c acrObj = new Allergan_Customer_Registration_AGN__c();
        for (Allergan_Customer_Registration_AGN__c details:[SELECT Id, Name, Account_AGN__c,AGN_SPARK_Update_my_Profile__c FROM Allergan_Customer_Registration_AGN__c WHERE Account_AGN__c != NULL AND Account_AGN__c =:accountId LIMIT 1]){
                 acrObj =  details;                                
        }
        return acrObj;
    }
    
   /*
   * Method to fetch current community URL
   */
    public static String getCommunityUrl(){
        string cUrl = Site.getBaseCustomUrl();
        if(!cUrl.endsWith(Site.getPathPrefix())){
            cUrl += Site.getPathPrefix();
        }
        return cUrl;
    }
}