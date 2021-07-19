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
        var isSuccess = true;
        var fieldName = '';
        var devloperNameVal = '';
        var sortOrderVal = '';
        var portalLabelVal = '';
        var containerTextVal = '';
        var richTextVal = '';
        
        if (component.get("v.componentType") == "ObjectField") {
            const readOnly = component.find("readOnly").get("v.value");
            const isHidden = component.find("isHidden").get("v.value");
            const defaultValue = component.find("defaultValue").get("v.value");
            
            if ( (readOnly || isHidden) && !defaultValue ) {
                isSuccess = false;
                fieldName = "Default Value";
            }
        }

        
        if(component.find("developerName")){
            devloperNameVal = component.find("developerName").get("v.value");
            if(devloperNameVal == 'undefined' || devloperNameVal == '' || devloperNameVal == undefined){
                isSuccess = false;
                fieldName = "Developer Name";
        	}
        }
        if(component.find("sortOrder")){
            sortOrderVal = component.find("sortOrder").get("v.value");
            if(sortOrderVal == 'undefined' || sortOrderVal == '' || sortOrderVal == undefined){
                isSuccess = false;
                fieldName = "Sort Order";
        	}
        }
        if(component.find("portalLabel")){
            portalLabelVal = component.find("portalLabel").get("v.value");
            if(portalLabelVal == 'undefined' || portalLabelVal == '' || portalLabelVal == undefined){
                isSuccess = false;
                fieldName = "Portal Label";
        	}
        }
        if(component.find("containerText")){
            containerTextVal = component.find("containerText").get("v.value");
            if(containerTextVal == 'undefined' || containerTextVal == '' || containerTextVal == undefined){
            	isSuccess = false;
            	fieldName = "Container Text/Html";
        	}
        }
        if(component.find("richText")){
            richTextVal = component.find("richText").get("v.value");
            if(richTextVal == 'undefined' || richTextVal == '' || richTextVal == undefined){
            	isSuccess = false;
            	fieldName = "Container Rich Text";
        	}
        }
        
        console.log('containerTextVal in stepcomponentdetailhelper-- ' +containerTextVal);
        //var urlField = component.find("urlField").get("v.value");

        if(isSuccess == false){
            helper.showMessage(component,fieldName);
        }else {
            //isSuccess = true;
            component.find("editComponent").submit();
        }
        
        return isSuccess; 
    }
})