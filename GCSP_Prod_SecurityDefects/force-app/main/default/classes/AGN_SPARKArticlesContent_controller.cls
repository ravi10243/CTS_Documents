/*
*  Controller calss for displaying articles in article detail lightning component
*/
public with sharing class AGN_SPARKArticlesContent_controller {
    
    /*
     * Method to fetch selected Knowledge ArticleSettings by CategoryType 
     */
    @AuraEnabled
    public static List<AGN_SPARK_KnowledgeHub_Article_Setting__mdt> getArticleSettings(string categoryType){
        
        List<AGN_SPARK_KnowledgeHub_Article_Setting__mdt> articleSettings = [SELECT ImagePath__c, Order__c FROM AGN_SPARK_KnowledgeHub_Article_Setting__mdt
                                                                            WHERE CategoryType__c=:categoryType AND IsActive__c = True ORDER BY Order__c];
        return articleSettings;
    }
    
    /*
     * Method to fetch selected Knowledge article by article id 
     */
    @AuraEnabled
    public static articleWrapper getArticles(string searchId){
        articleWrapper knowWrap = new articleWrapper();
        SPARK_KnowledgeHub_AGN__kav knowArticle = new SPARK_KnowledgeHub_AGN__kav();
        string KnowledgeArticleId;
        String publishStatus = 'Online';
        try{
            for( SPARK_KnowledgeHub_AGN__kav art : [SELECT Id, Title, Summary , Body_AGN__c, KnowledgeArticleId, Summary_URL_AGN__c, Main_URL_AGN__c, Category_Name__c,
                                                    AGN_SPARK_KH_Bullet_Point_1__c, AGN_SPARK_KH_Bullet_Point_2__c, AGN_SPARK_KH_Bullet_Point_3__c, AGN_SPARK_Sub_Title__c, AGN_SPARK_Sub_Title_Descr__c
                                                    FROM SPARK_KnowledgeHub_AGN__kav 
                                                    WHERE id = : searchId AND PublishStatus = 'Online' UPDATE VIEWSTAT
                                                   ]){
                                                       if(art.Body_AGN__c != null ){
                                                           art.Body_AGN__c = art.Body_AGN__c.replace('<br>','%br%');
                                                           
                                                           art.Body_AGN__c  = art.Body_AGN__c .replaceAll('<span[^>]*>','');
                                                           
                                                           art.Body_AGN__c = art.Body_AGN__c.replace('%br%','<br>');
                                                       }
                                                       
                knowArticle = art; 
                KnowledgeArticleId = art.KnowledgeArticleId;
            }
            for( Vote userVotes : [SELECT id,ParentId,Type FROM Vote WHERE ParentId=:KnowledgeArticleId]){
                knowWrap.myVote = userVotes.Type;
            }
        }catch(Exception e){
            
        }
        
        knowWrap.knowArticle = knowArticle;
        return knowWrap;
    }
    
    /*
     * Method to set vote for an Article
     */
    @AuraEnabled
    public static Vote setVote(Id articleId, string voteValue){
        
        SPARK_KnowledgeHub_AGN__kav articleList = [SELECT Id, Title,KnowledgeArticleId, Summary, Summary_URL_AGN__c FROM SPARK_KnowledgeHub_AGN__kav WHERE id =:articleId];
        list<Vote> userVotes = [SELECT id,ParentId,Type FROM Vote WHERE ParentId=:articleList.KnowledgeArticleId];
        Vote userVote = new Vote(ParentId = articleList.KnowledgeArticleId, Type = voteValue);
        if(userVotes != null){
            delete userVotes;  
        }
            insert userVote;
        
        return userVote;
        
        
    }
    
     /*
     * Wrapper class to hold article & its voting details
     */
    public class articleWrapper {
        @AuraEnabled public SPARK_KnowledgeHub_AGN__kav knowArticle {get;set;}
        @AuraEnabled public string myVote {get;set;}
    }
}