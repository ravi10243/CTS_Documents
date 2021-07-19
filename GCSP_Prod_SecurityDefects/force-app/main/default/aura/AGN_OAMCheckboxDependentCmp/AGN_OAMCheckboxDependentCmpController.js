({
	doInit : function(component, event, helper) {
		var displayRequiredInput = component.get("v.displayRequiredInput");
        //console.log("displayRequiredInput>>>>>>>>>>>>>>>>>>>>>>>>"+displayRequiredInput);
        if(displayRequiredInput){
            component.set("v.required" , true);
        }else{
            component.set("v.required" , false);
        }
	}
})