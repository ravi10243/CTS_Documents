({
	getApplication : function(component, event, helper) {

        var getApplication = component.get("c.getApplicationById");
        getApplication.setParams({
            appId : component.get("v.recordId")
        });
        component.set("v.applicationId",component.get("v.recordId")); 
        getApplication.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.application",response.getReturnValue());                
            }
        });
        $A.enqueueAction(getApplication);
    },
    
    getApplicationForms : function(component, event, helper) {

        var getApplicationForms = component.get("c.getApplicationForms");
        getApplicationForms.setParams({
            appId : component.get("v.applicationId")
        });
        getApplicationForms.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.formList",response.getReturnValue());                
            }
        });
        $A.enqueueAction(getApplicationForms);
    },
    
    updateStatus : function(component, event, helper) {

    var updateStatus = component.get("c.updateFormStatus");
        updateStatus.setParams({
            lexFormId : component.get("v.formId")
        });
        updateStatus.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.formList",response.getReturnValue());                
            }
        });
        $A.enqueueAction(updateStatus);
    },
})