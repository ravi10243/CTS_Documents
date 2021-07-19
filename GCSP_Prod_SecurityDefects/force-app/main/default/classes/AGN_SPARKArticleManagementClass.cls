/*
 *  The controller class for AGN_SPARK_Knowledge Listing Lightning Component
 */
public without sharing class  AGN_SPARKArticleManagementClass {

   
    /*
     *  Method to fetch all categories from schema.
     */ 
   @AuraEnabled
   public static string getAllCategories(){
     List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult = AGN_SPARK_Utility.getKnowledgeHubCategories();
     return JSON.serialize(describeCategoryStructureResult);
   }
    
   
   /*
    *  Method to fetch Articles count for Pagination.
    */
   @AuraEnabled
   Public static integer getArticlesCount(string articleType, string searchText){
       List<SPARK_KnowledgeHub_AGN__kav> articleList= new List<SPARK_KnowledgeHub_AGN__kav>();

       string query;
       integer count;
       if(searchText != ''){
         query =  'FIND {\''+String.escapeSingleQuotes(searchText)+'\'} IN ALL FIELDS RETURNING SPARK_KnowledgeHub_AGN__kav (Id LIMIT 2000) WITH DATA CATEGORY Spark_Knowledge_Hub__c ';
             if(String.isNotBlank(articleType)){
                 query += ' BELOW \''+ String.escapeSingleQuotes(articleType)+'\'__c' ; //cc_AD
             }
             
         List<List <SPARK_KnowledgeHub_AGN__kav>> countQuery = search.query(query);
            for (List <SPARK_KnowledgeHub_AGN__kav> art : countQuery){
                articleList = art;
                
            }
           count= articleList.size();
       }else{
         query = 'SELECT COUNT()  FROM SPARK_KnowledgeHub_AGN__kav WHERE PublishStatus=\''+AGN_SPARK_Utility.ARTICLE_PUBLISH_STATUS+'\' WITH DATA CATEGORY Spark_Knowledge_Hub__c ';
         if(String.isNotBlank(articleType)){
             query += ' BELOW '+ articleType+'__c' ;
         }
           count = database.countQuery(query);
           
       }
       
       
       return count;

    }
    
    
    public static String formatArticleTypesFilterCriteria(String subCategory){
       //(Getting_Started_Product__c , Building_Exp_Product__c , Becoming_Est_Product__c)
       Integer count =1;
       String formatString = '('; 
       String[] mainCategories = new String[]{'Getting_Started_' , 'Building_Exp_' , 'Becoming_Est_'};
       for(String category : mainCategories){
         if(count > 2){
           formatString += category+subCategory+'__c)';
         }
         else{
           formatString += category+subCategory+'__c,';
           }
         count +=1;
       }
       System.debug('Format string '+ formatString);
       return formatString ;
    }
    /*
    *  Method to fetch Articles based on the search criteria or selected category or selected subcategory
    */
    @AuraEnabled
    Public static articleSearchWrapper getArticlesList(integer dataLimit,integer pageNumber ,string articleType ,string searchText){
        List<SPARK_KnowledgeHub_AGN__kav> articleList= new List<SPARK_KnowledgeHub_AGN__kav>();
        Integer articleDataLimit = Integer.valueOf(dataLimit);
        Integer articlePageNumber = Integer.valueOf(pageNumber);
        if(articleDataLimit < 1){
            articleDataLimit = AGN_SPARK_Utility.getKnowledgeHubPageLimit();
        }
        
        String allArticleTypes;
        if(String.isNotBlank(articleType)){
          
          
          if(articleType.contains('General')){
            allArticleTypes = formatArticleTypesFilterCriteria('General');
          }
          else if(articleType.contains('Clinical')) {
             allArticleTypes = formatArticleTypesFilterCriteria('Clinical');
          }
          else if(articleType.contains('Business')) {
             allArticleTypes = formatArticleTypesFilterCriteria('Business');
          }
          else if(articleType.contains('Product')) {
             allArticleTypes = formatArticleTypesFilterCriteria('Product');
          }
          else{
             allArticleTypes = formatArticleTypesFilterCriteria('Video');
          }
        }
        
        string query;
        
        if( searchText !=''){
           /* query =  'FIND {'+String.escapeSingleQuotes(searchText)+'} IN ALL FIELDS'; //cc_AD
            query +=' RETURNING SPARK_KnowledgeHub_AGN__kav ('
                                +'Id, Title, Summary, Summary_URL_AGN__c, Category_Name__c'
                                +' ORDER BY LastModifiedDate DESC'
                                +' LIMIT '+ articleDataLimit+' OFFSET '+articlePageNumber+')';
            query +=' WITH DATA CATEGORY Spark_Knowledge_Hub__c';*/
            
            query = 'SELECT Id, Title, Summary, Summary_URL_AGN__c, Category_Name__c from SPARK_KnowledgeHub_AGN__kav where ';
             query +=   'title like \'%'+String.escapeSingleQuotes(searchText)+'%\' OR Summary like  \'%'+String.escapeSingleQuotes(searchText)+'%\'' 
                 		+' ORDER BY LastModifiedDate DESC'
                                +' LIMIT '+ articleDataLimit+' OFFSET '+articlePageNumber+' ';
            
          /*  query +=' WITH DATA CATEGORY Spark_Knowledge_Hub__c';
            if(String.isNotBlank(articleType)){
                //query +=  ' BELOW '+ articleType+'__c'  ;
                //query +=  ' BELOW '+ allArticleTypes  ;
             //   query +=  ' BELOW ALL__c';
            }
            System.debug('RAW article search query '+ query);
            articleList = database.query(query);
            /*List<List <SPARK_KnowledgeHub_AGN__kav>> myQuery = search.query(query);
                for (List <SPARK_KnowledgeHub_AGN__kav>t :myQuery){
                    articleList = t;
                }*/
            articleList = database.query(query);
        }else{
            query = 'SELECT Id, Title, Summary, Summary_URL_AGN__c, Category_Name__c  FROM SPARK_KnowledgeHub_AGN__kav WHERE PublishStatus=\''+String.escapeSingleQuotes(AGN_SPARK_Utility.ARTICLE_PUBLISH_STATUS)+'\' WITH DATA CATEGORY Spark_Knowledge_Hub__c'; //cc_AD          
            if(String.isNotBlank(articleType)){
                //query +=  ' BELOW '+ articleType+'__c'  ;
                query +=  ' BELOW '+ allArticleTypes  ;
            }
            query += ' ORDER BY LastModifiedDate DESC LIMIT '+ articleDataLimit+' OFFSET '+articlePageNumber; 
            articleList = database.query(query);
        }
        System.debug('Article query '+ query +'articleList:'+articleList.size());
        /*for(SPARK_KnowledgeHub_AGN__kav kHub : articleList){
             String articleDesc = kHub.Body_AGN__c;
			 Integer length = 169;
			 String trimmedDesc = articleDesc.substring(0, length);
             kHub.Body_AGN__c = trimmedDesc;
             tempList.add(kHub);
        }*/
        articleSearchWrapper articleData = new articleSearchWrapper();
        articleData.articleResult = articleList ; 
        articleData.pageNumber = articlePageNumber;
        articleData.pageLimit = articleDataLimit;
        return articleData;
    }
    
    /*
    *  Method to fetch Images for knowledge hub page.
    */
    @AuraEnabled
    public static Map<String, String> getImageURL(String pageName){
        Map<String, String> ImageURL=  AGN_SPARK_Utility.getImageURL(pageName);
        return ImageURL;
    }
    
    /*
    *  Wrapper class to hold knoeledge articles with pagination
    */
    Public Class articleSearchWrapper{
       @auraenabled public List<SPARK_KnowledgeHub_AGN__kav> articleResult {get;set;}
       @auraenabled public integer pageNumber {get;set;}
       @auraenabled public integer pageLimit {get;set;}
            
    }

}