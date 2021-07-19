({
	fetchFooterConsents : function(component, event) {
        var action = component.get("c.fetchFooterConsents");
        action.setParams({       
            'pageLang': $A.get("$Locale.language")        
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.footerConsentsList",response.getReturnValue());
            }
        }); 
        $A.enqueueAction(action);
    },
})