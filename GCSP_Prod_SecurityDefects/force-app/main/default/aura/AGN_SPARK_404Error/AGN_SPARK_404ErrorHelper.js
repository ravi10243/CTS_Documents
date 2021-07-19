({
	getPageImages : function(component) {
       
		var action = component.get("c.getImages");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
            	component.set("v.AGNSPARKImage", response.getReturnValue());
           		console.log('ss',response.getReturnValue());
                }
            });
        $A.enqueueAction(action);
	},
    navigateToPage : function(pageName) {
       
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
      		"url": "/"+pageName,
      		
   		});
    	urlEvent.fire();
    }
})