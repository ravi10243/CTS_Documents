({
    doInit : function(component, event, helper){
        helper.getArticleInfo(component);
    },
    positiveValue: function(component, event, helper){
       component.set("v.vote","Up");
       helper.getVoteInfo(component);
    },
    negativeValue: function(component, event, helper){
       component.set("v.vote","Down");
       helper.getVoteInfo(component);
    }
    
})