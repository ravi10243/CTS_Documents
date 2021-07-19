/**
 *
 * @Class Name: AGN_SPARK_TrainingProvidersController
 * @Created Date: 
 * @Description: Controller class for Training Provides List page component
 * @Author: 
 * @History     :  
 */
public with sharing class AGN_SPARK_TrainingProvidersController {
    
    /*
     * Method to get page Images and category list
     */
   @AuraEnabled
   public static Map<String,  Map<String, String>> getPageSettings(){

       return new Map<String, Map<String, String>>{'images'=> AGN_SPARK_Utility.getImageURL('trainigProviders'),
                                                   'categories' => AGN_SPARK_Utility.getTrainingMainCatgories()
                                                };
    }
   
    /*
     * Method to fetch training articles with based on selected category, data limit and pagenumber
     */
    @AuraEnabled
    public static WrapperTrainingProviderDetails getAllTrainingArticles(String selectedCatagory, integer dataLimit, integer pageNumber ){
        System.debug('Error occurred ' + selectedCatagory);
        WrapperTrainingProviderDetails trainingArticleAndCatagories =  new WrapperTrainingProviderDetails();
        trainingArticleAndCatagories.isSuccess = true;
        trainingArticleAndCatagories.message = 'Category Not selected';
        if(String.isNotBlank(selectedCatagory)){
            Integer articlePageNumber = Integer.valueOf(pageNumber);
            Integer articleDataLimit = Integer.valueOf(dataLimit);
            
            
            trainingArticleAndCatagories.trainingCatagories = AGN_SPARK_Utility.getTrainingMainCatgories();
                
            List<SPARK_TrainingProvider_AGN__kav> allTrainingArticles =  new List<SPARK_TrainingProvider_AGN__kav>();
            if(articleDataLimit < 1){
                articleDataLimit = AGN_SPARK_Utility.getTrainingProviderPageLimit();
            }
            String varTrainingProvidersGpNm = AGN_SPARK_Utility.getTrainingProviderGroupName();       
            try{         
                string baseqry = 'SELECT Region_AGN__c, Web_URL_AGN__c,Logo_URL_AGN__c, KnowledgeArticleId,Title FROM SPARK_TrainingProvider_AGN__kav WHERE PublishStatus = \'Online\' WITH DATA CATEGORY '+String.escapeSingleQuotes(varTrainingProvidersGpNm)+'__c';
                    baseqry += ' AT '+String.escapeSingleQuotes(selectedCatagory)+'__c' ; //cc_AD
                STring qry = baseqry + ' ORDER BY Sorting_order_AGN__c ASC LIMIT '+ String.escapeSingleQuotes(String.valueOf(articleDataLimit))+' OFFSET '+String.escapeSingleQuotes(String.valueOf(articlePageNumber)) ; //cc_AD
    
                System.debug('Raw query '+ qry); 
                allTrainingArticles = Database.query(qry);
                trainingArticleAndCatagories.trainingProviders = allTrainingArticles;
                
                trainingArticleAndCatagories.totalCount =  Database.query(baseqry).size();
                trainingArticleAndCatagories.message = 'Success';
            }catch(Exception e){
                trainingArticleAndCatagories.isSuccess = false;
                trainingArticleAndCatagories.message = e.getMessage();
                system.debug(e.getMessage());
            }
            trainingArticleAndCatagories.dataLimit = articleDataLimit;
        }
        return trainingArticleAndCatagories;
    }
    
    /*
     * Public class to get viewstat
     */
    @AuraEnabled
    public static string getViews(string articleId){


        try{
            for( SPARK_TrainingProvider_AGN__kav art : [SELECT Id, Title
                                                    FROM SPARK_TrainingProvider_AGN__kav 
                                                    WHERE id = : articleId AND PublishStatus = 'Online' UPDATE VIEWSTAT
                                                   ]){
                                                       // Loging article view count
                                                   }
           
        }catch(Exception e){
            return 'ERROR :'+e.getMessage();
        }
        return 'SUCCESS';
    }
    
   
    
    /*
     * Public class to hold training provider data list
     */
    public class WrapperTrainingProviderDetails{
       @auraEnabled
        public List<SPARK_TrainingProvider_AGN__kav> trainingProviders {
            get; set;
        }
        
        @auraEnabled
        public  Map<String, String> trainingCatagories {
            get; set;
        }
        
        @auraEnabled
        public integer totalCount {
            get; set;
        }
        @auraEnabled
        public integer dataLimit {
            get; set;
        }
        @auraEnabled
        public String message {
            get; set;
        }
        @auraEnabled
        public Boolean isSuccess {
            get; set;
        }
        
    }
    
}