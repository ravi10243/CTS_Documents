({
	invokeRefreshBuilder : function(component, event, helper) {
		var refreshBuilderEvent = $A.get("e.c:CMS_BuilderRefreshEvent");
        //alert(refreshBuilderEvent);
        //refreshBuilderEvent.setParams({"currentStepId" :selectedStepId}); 
        refreshBuilderEvent.fire();
	},
    
    showMessage : function(component,fieldName) {
		component.find('notifLib').showNotice({
                "variant": "error",
                "header": "Required Field : " + fieldName,
                "message": "This field is Required!!",
                
            });
	},
    
    doRequiredValidation : function(component,helper){
        let developerName = component.find("developerName");
        let localisedShortName = component.find("localisedShortName");
        let localisedLongName = component.find("localisedLongName");
        let stepOrder = component.find("stepOrder");
        console.log("Doing validation");
        let res = developerName.get("v.value") &&
           localisedShortName.get("v.value") &&
           localisedLongName.get("v.value") && 
           stepOrder.get("v.value");
           component.set("v.requiredValidationFailed", !res);
		
        if (res) {
            component.find("editStep").submit();
        }
        
        return res;
        
        /*
        if(component.find("developerName")){
            devloperNameVal = component.find("developerName").get("v.value");
            if(devloperNameVal == 'undefined' || devloperNameVal == '' || devloperNameVal == undefined){
                isSuccess = false;
                fieldName = "Developer Name";
        	}
        }
        if(component.find("stepOrder")){
            sortOrderVal = component.find("stepOrder").get("v.value");
            if(sortOrderVal == 'undefined' || sortOrderVal == '' || sortOrderVal == undefined){
                isSuccess = false;
                fieldName = "Step Order";
        	}
        }

        if(isSuccess == false){
            helper.showMessage(component,fieldName);
        }else {
            //isSuccess = true;
            component.find("editStep").submit();
        }
        
        return isSuccess; */
    }
})