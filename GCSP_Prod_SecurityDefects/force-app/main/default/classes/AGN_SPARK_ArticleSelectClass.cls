public Without Sharing class AGN_SPARK_ArticleSelectClass { //added without sharing keyword for Spring '21 release
    @AuraEnabled
    Public static  objectWrapper[]  getArticleTypes(){
        objectWrapper[] catList = new objectWrapper[]{};
        Map<String, String> tempList = AGN_SPARK_Utility.getKnowledgeMainCatgories();
        String pageName= 'ArticlePopup';//Label.AGN_SPARK_Articlepopup_pageName;
        Map<String, String> imageMap = AGN_SPARK_Register_Utility.getImageURL(pageName);
        if(tempList.size() > 0 ){
            for(String key : tempList.keySet()){
                String url = imageMap.get(key);
                catList.add(new objectWrapper(tempList.get(key), key,url));
            }
        }
      return  catList;
    } 
    
    
    public class objectWrapper {
        @auraEnabled public string label;
        @auraEnabled public string name;
        @auraEnabled public string url;

        
        public objectWrapper(String l, String n,String u){
            this.label = l;
            this.name = n;
            this.url = u;
        }
        
    }
}