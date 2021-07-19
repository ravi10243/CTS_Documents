({
    runApexAction : function(component, action, parameters, callback) {
        try {
            var actionLanguage = component.get(action);
            actionLanguage.setParams(parameters); 
            actionLanguage.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS")  {
                    try {
                        callback(response);
                    } catch(err) {
                        console.error(err);
                    }
                } else {
                    console.error(response.getError());
                }
         	});
            $A.enqueueAction(actionLanguage); 
        } catch (err) {
            console.error(err);
        }
    },
    getLocalisedMDStepComponentRecords : function(component, helper) {
        let handleResponse = (response) => component.set("v.listLocalisedMDStepComponent",response.getReturnValue());
        let parameters = { mdStepComponentId : component.get("v.recordId") };
        helper.runApexAction(component, "c.GetLocalisedMDStepComponentRecords", parameters, handleResponse);
    },
    getLocalisedComponentConfigJSON : function(component, helper) {
        let handleResponse = (response) => {
        	const value = response.getReturnValue();
            if (value && value[0].ConfigJSON__c) {
            	component.set("v.listLocalisedFieldConfig", JSON.parse(value[0].ConfigJSON__c));
        	} else {
                const listFieldConfig = component.get("v.listFieldConfig");
                const listLocalisedFieldConfig = listFieldConfig.map((fieldConfig) => {
                    let localisedField = new Object();
                    localisedField.FieldAPIName = fieldConfig.FieldAPIName;
                    localisedField.DisplayLabel = "";
                    localisedField.QuickHelpText = "";
                    return localisedField;
                });
                component.set("v.listLocalisedFieldConfig", listLocalisedFieldConfig);
        	}
        };
        let parameters = { mdComponentId : component.get("v.selectedLocalisedStepComponentId") };
        helper.runApexAction(component, "c.GetLocalisedComponentConfigJSON", parameters, handleResponse);
    },
    getListFieldConfig : function(component, helper) {
        let handleResponse = (response) => component.set("v.listFieldConfig", JSON.parse(response.getReturnValue()).ListFieldConfig);
        let parameters = { mdComponentId : component.get("v.recordId") };
        helper.runApexAction(component, "c.GetComponentConfigJSON", parameters, handleResponse);
    },
    saveLocalisedComponentConfigJSON : function(component, helper) {
        let whenValid = () => {
            const id = component.get("v.selectedLocalisedStepComponentId");
            const config = JSON.stringify(component.get("v.listLocalisedFieldConfig"));
            let handleResponse = (response) => helper.showToast("Success", "Successfully saved field translations!", "success");
            let parameters = { mdComponentId : id, configJSON : config };
        	helper.runApexAction(component, "c.SaveLocalisedComponentConfigJSON", parameters, handleResponse);
    	};
        let whenInvalid = () => helper.showToast("Error Saving", "Please fill all the fields!", "error");
        helper.validateFields(component, whenValid, whenInvalid);
    },
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
	},
    validateFields : function(component, valid, invalid) {
		const config = component.get("v.listLocalisedFieldConfig");
        const empty = config.find(field => field.DisplayLabel == "" || field.QuickHelpText == "");
        empty ? invalid() : valid();
    }
})