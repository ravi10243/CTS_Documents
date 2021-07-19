({
	getPicklistOptions : function(component,helper) {
        console.log("getPicklistOptions>>>>>>>>>>>"+component.get("v.sobjectName") + ">>>>" + component.get("v.fieldName"));
		var action = component.get("c.getOptions");
        action.setParams({ 
                           ObjectName : component.get("v.sobjectName"),
                           fieldName : component.get("v.fieldName")
                        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server:::::::::::::: "+ JSON.stringify(response.getReturnValue()));
                component.set("v.options" , response.getReturnValue());
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action); 
	}
})