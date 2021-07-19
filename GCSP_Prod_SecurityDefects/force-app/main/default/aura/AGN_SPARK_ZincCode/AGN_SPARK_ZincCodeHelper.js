({
	getZincDetail : function(component, event, helper) {
	   var pagename=component.get("v.pageName");
       var action=component.get("c.getZincDetail");
        action.setParams({
            pageName : pagename
        });
        action.setCallback(this, function(response){
            var state=response.getState();
            if(state='SUCCESS'){
            	component.set("v.zincValue", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})