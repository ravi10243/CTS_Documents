({
    doInitHelper : function(component, helper, event) {
        helper.getLocalisedMDStepComponentRecords(component, helper);
        helper.getListFieldConfig(component, helper);
        
    },
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
                        alert('Error: ' + err);
                        console.error(err);
                    }
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
    getListFieldConfig : function(component, helper) {
        let handleResponse = (response) => {
            const returnValue = response.getReturnValue();
            if(returnValue)
            {
            component.set("v.listFieldConfig", JSON.parse(returnValue).ListFieldConfig);
            console.log(JSON.parse(returnValue).ListFieldConfig);
        }
        
        };
    let parameters = { mdComponentId : component.get("v.recordId") };
 	helper.runApexAction(component, "c.GetComponentConfigJSON", parameters, handleResponse);
}
})