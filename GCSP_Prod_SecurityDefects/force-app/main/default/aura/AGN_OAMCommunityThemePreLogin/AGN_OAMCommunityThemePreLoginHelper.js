({
	fetchFooterConsents : function(component, event) {
        
        var locale = $A.get("$Locale.langLocale");
        if(locale == 'en_AU' || locale == 'en_NZ'){
            var forNotANZ = component.find("notInANZ");
            forNotANZ.destroy();       
            
        }else{
            var forANZ = component.find("forANZ");
            forANZ.destroy();
        }
        
        var action = component.get("c.fetchFooterConsents");
        action.setParams({       
            'pageLang': $A.get("$Locale.langLocale")        
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log(">>>>>>>>"+JSON.stringify(response.getReturnValue()));
                component.set("v.footerConsentsList",response.getReturnValue());
            }
        }); 
        $A.enqueueAction(action);
    },
    fetchUserLocale : function(component, event) {
        var action = component.get("c.userLocale");      
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.userLocale",response.getReturnValue());
            }
        }); 
        $A.enqueueAction(action);
    }
})