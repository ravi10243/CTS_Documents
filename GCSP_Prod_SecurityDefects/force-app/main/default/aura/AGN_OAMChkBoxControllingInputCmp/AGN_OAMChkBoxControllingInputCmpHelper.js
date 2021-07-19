({
	handlechkBox :  function(component, event) {
		var selected = event.getSource().get("v.value");
        if(!selected){
            component.set("v.fieldValue" , "");
        }
		component.set("v.displayRequiredInput" , selected );
        component.set("v.required" , selected);
        var fieldName = component.get("v.fieldName");
        if(fieldName === 'Doctors_Email_AGN__c'){
            component.set("v.uploadAccountOwnerDocument" , selected);
        }
	},
    handleAccountOwnerchkBox :  function(component, event) {
		var selected = event.getSource().get("v.value");
        //console.log("selected value>>>>>>>>>>>>"+selected);
        var displayRequiredInput;
        if(selected){
            displayRequiredInput = false;
            component.set("v.fieldValue" , "");
        }else{
            displayRequiredInput = true;
        }
		component.set("v.displayRequiredInput" , displayRequiredInput );
        component.set("v.required" , displayRequiredInput);
        component.set("v.uploadAccountOwnerDocument" , displayRequiredInput);
	}
})