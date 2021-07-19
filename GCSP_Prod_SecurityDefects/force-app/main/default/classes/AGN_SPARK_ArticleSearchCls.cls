public Without Sharing class AGN_SPARK_ArticleSearchCls {  //added without sharing keyword for Spring '21 release

    @AuraEnabled
    Public static List<KnowledgeArticleVersion> getKnowledgeArticles(String searchText){
      searchText= '%'+searchText+'%';
      return [SELECT Title, ArticleType,Summary FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND language ='en_US' AND Title LIKE :searchText];
    }
        
}