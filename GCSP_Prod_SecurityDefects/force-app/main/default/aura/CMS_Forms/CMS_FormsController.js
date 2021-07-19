({
	doInit : function(component, event, helper) {
		helper.getApplication(component, event, helper);
        helper.getApplicationForms(component, event, helper);
	},
    
    startForm : function(component, event, helper) {
        var button = event.getSource();
        var formid = button.get("v.value");
        var appId = component.get("v.applicationId");
		component.set("v.formId",formid); 
        var action = component.get("c.getMDForm");
           action.setParams({
                lexFormId : formid
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {		
                    helper.updateStatus(component, event, helper);
                    console.log(JSON.stringify(response.getReturnValue()));
                    window.open("/nessy/s/appform?pagekey="+response.getReturnValue()+"&formid="+formid +"&appId="+appId,'_self');
                }
            });
            $A.enqueueAction(action);
    },
    
    
})