({
	navigateToPage : function(pageName) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
      		"url": pageName,
      		
   		});
    	urlEvent.fire();
    },
    
    fetchFooterSettings : function(component){

        var action = component.get("c.getFooterSettings");       
        action.setCallback(this, function(response) {
            if(response.getState() == 'SUCCESS'){
                var fSettings = response.getReturnValue();
                console.log('fSettings', fSettings);
            	component.set("v.fSettings", fSettings);
            }
            
        }); 
        $A.enqueueAction(action); 
   },
    
})