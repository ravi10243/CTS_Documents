({
    getArticleInfo : function(component) {
        var action = component.get("c.getArticles");    
        action.setParams({
            "searchId" :  component.get("v.searchIdValue")
        });
        this.showCommunitySpinner(component);
        action.setCallback(this, function(result){
            var state = result.getState();
                if(state == 'SUCCESS' && result.getReturnValue()!=null){
                    component.set("v.article",result.getReturnValue().knowArticle);
                    component.set("v.backGroundImage",result.getReturnValue().knowArticle.Main_URL_AGN__c);
                    component.set("v.vote",result.getReturnValue().myVote);
                    var articleType =  result.getReturnValue().knowArticle.Category_Name__c;
                    if(articleType === "General"){
                        articleType = "Video";
                    }
                    component.set("v.articleType", articleType + " Article");
                    this.getKnowledgeHubArticleSettings(component, articleType);
                }
        });
        $A.enqueueAction(action);
    },
    
    getKnowledgeHubArticleSettings : function(component, categoryType) {
        var action = component.get("c.getArticleSettings");    
        action.setParams({
            "categoryType" :  categoryType
        });
        this.showCommunitySpinner(component);
        action.setCallback(this, function(result){
            var state = result.getState();
                if(state == 'SUCCESS' && result.getReturnValue()!=null){
                    component.set("v.articleSettings", result.getReturnValue());
                    this.hideCommunitySpinner(component);
                    component.get("v.parent").selectArticle(categoryType);
                }
        });
        $A.enqueueAction(action);
    },
    
    getVoteInfo : function(component) {
        var vote = component.get("v.vote");  
        var action = component.get("c.setVote"); 
        action.setParams({
            "articleId" :  component.get("v.searchIdValue"),
            "voteValue" : vote
        });
        this.showCommunitySpinner(component);
        action.setCallback(this, function(result){
            var state = result.getState();
            if(state == 'SUCCESS') {
                if(result.getReturnValue()!=null){
                    
                    console.log(result.getReturnValue());
                }
            }else{
                $A.log("Errors", result.getError());
                console.log(result.getError());
            }
            this.hideCommunitySpinner(component);
        });
        $A.enqueueAction(action);
    },
    showCommunitySpinner: function(component){       
        $A.util.removeClass(component.find("siteSpinner"), "hideEl");        
	},
    hideCommunitySpinner: function(component){
        $A.util.addClass(component.find("siteSpinner"), "hideEl");
    },
    
    
})