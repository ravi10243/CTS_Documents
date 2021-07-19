({
	getPageImages : function(component) {
       
		var action = component.get("c.getImages");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
            	component.set("v.AGNSPARKImage", response.getReturnValue());
           		//console.log(JSON.stringify(response.getReturnValue()));
                }
            });
        $A.enqueueAction(action);
	}
})