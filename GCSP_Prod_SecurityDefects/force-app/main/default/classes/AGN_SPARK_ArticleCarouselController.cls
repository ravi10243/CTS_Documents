/*
 *  Controller class for Article Carousel Component
 */
public Without Sharing class AGN_SPARK_ArticleCarouselController {  //added without sharing keyword for Spring '21 release
    
    /*
     *  Method to fetch recent articles by article type
     */
    @AuraEnabled
    public static List<SPARK_KnowledgeHub_AGN__kav> getRecentArticles(String articleType){
        return database.query(AGN_SPARK_ArticleCarouselController.getKnowledgeArticleQuery(articleType, AGN_SPARK_Utility.ARTICLE_PUBLISH_STATUS, integer.valueof(AGN_SPARK_Utility.SPARK_SETTINGS.Article_Carousel_Limit__c), AGN_SPARK_Utility.getKnowledgeHubGroupName()));
    }
    
    /*
     *  Method to create dynamic query to fetch recent article data 
     */
    /*
      PMO - 2709
      Below query has been changed to show 3 most recent articles based on latest publish date 
      and irrespective of data category
    */ 
    public static string getKnowledgeArticleQuery(String articleType, String publishStatus, integer carouselLimit, string groupName){        
        String query = 'SELECT Id, Title, Summary, Summary_URL_AGN__c, Category_Name__c  '+
                       'FROM SPARK_KnowledgeHub_AGN__kav WHERE PublishStatus=\''+publishStatus+'\' '+
                       //' AND LastModifiedDate = LAST_N_DAYS:365'+
                       ' WITH DATA CATEGORY '+ groupName.trim() +'__c ';
                       
        if(String.isNotBlank(articleType)){
                //query += ' BELOW '+ articleType.trim() +'__c '; 
                query += ' BELOW '+ 'ALL' +'__c ';
        }
                query +=' ORDER BY LastModifiedDate DESC Limit '+carouselLimit;
       
       
       /*SELECT Id, Title, Summary, Summary_URL_AGN__c, Category_Name__c,LastModifiedDate  
       FROM SPARK_KnowledgeHub_AGN__kav WHERE PublishStatus='Online'   
       WITH DATA CATEGORY Spark_Knowledge_Hub__c  
       BELOW All__c  ORDER BY LastModifiedDate DESC Limit 3*/
       //system.debug('Artcle type' + articleType + ' Publish status '+ publishStatus + ' Carousel limit '+carouselLimit+ ' Group Name '+groupName);
       //system.debug('Query' + query);
        return query;
    }
}