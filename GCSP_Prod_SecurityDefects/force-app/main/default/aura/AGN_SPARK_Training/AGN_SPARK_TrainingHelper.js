({
	navigateTotrainingProvider : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
         	"url" : '/training-providers'
        });
        urlEvent.fire();
    },
    getpdfAndVisitSiteUrl : function (component, event, helper) {
        console.log('getpdfAndVisitSiteUrl');
        var action = component.get('c.getUrls');
		action.setCallback(this,function(response){
            component.set('v.urlMap',response.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})