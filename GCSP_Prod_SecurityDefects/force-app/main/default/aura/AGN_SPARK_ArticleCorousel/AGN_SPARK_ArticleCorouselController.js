({
	knowledgeArticle : function(component, event, helper) {

		helper.knowledgeArticle(component, event);
	},    
    displayArticle : function(component, event, helper){
        helper.displayArticle(component, event, helper);
    },    
    displayRender : function(component, event, helper){
        var items = component.get('v.KnowledgeArticles');
        if(items.length > 0){
            helper.initCarousel()
        }
    },
    selectedArticle : function(component, event, helper){        
        helper.navigateToArticlesDetails(component, event, helper);
    },
    scriptsLoaded : function(component, event, helper){        
       // alert(1);
    },
        
})