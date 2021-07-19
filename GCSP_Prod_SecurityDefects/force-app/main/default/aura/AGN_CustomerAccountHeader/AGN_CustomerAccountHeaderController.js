({
	init : function(component, event, helper) {
        
      /* var action = component.get("c.getAccountDetails");
	    
    	action.setCallback(this, function(actionResult) {
        component.set("v.customer", actionResult.getReturnValue());           
        });
        $A.enqueueAction(action); */
        
        var action = component.get("c.getContactDetails");       
        action.setCallback(this, function(response) {
            var state = response.getState();
           console.log('ContactData>>>>>'+JSON.stringify(response.getReturnValue())+'>>>>>>'+state);
            if(state == 'SUCCESS'){
              component.set("v.customerContact", response.getReturnValue());  
            }                       
        });
      
        $A.enqueueAction(action);
	}
})