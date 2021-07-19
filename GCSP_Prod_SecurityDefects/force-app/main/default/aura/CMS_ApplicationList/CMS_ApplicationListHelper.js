({
	getApplications : function(component, event, helper){
		var getApplications = component.get("c.getAllApplications");
        
        getApplications.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.applicationList",response.getReturnValue());                
            }
            else if (state === "ERROR"){
                var errors = response.getError();
                if (errors){
                    if (errors[0] && errors[0].message){
                        console.log("Error message: " + errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(getApplications);
	}
})