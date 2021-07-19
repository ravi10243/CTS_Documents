({
	openStartApplication : function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
    
     closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
      component.set("v.isOpenHelp", false);
   },
    
   showHelp : function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpenHelp", true);
   }, 
    
    startApplication : function(component, event, helper) {
        component.set("v.isLoading", true);
        var mdApplication = component.get("v.applicationdetails");
        var toastEvent = $A.get("e.force:showToast");
        var startApplicationAction = component.get("c.doInsertApplication");
        
        startApplicationAction.setParams({
            "mdId":mdApplication.Id,
            "appName": mdApplication.Name,
            "onlineHelpKey": mdApplication.HelpKey__c,
            "onlineChecklistKey": mdApplication.ShGl_CheckList__c
        });
        startApplicationAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.location.href = "../s/app?recordId=" + response.getReturnValue();
            } else {
                toastEvent.setParams({
                    "title": "Error",
                    "message": "error - start application",
                    "type": "error"
                });
                toastEvent.fire();
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(startApplicationAction);
      	component.set("v.isOpen", false);
   },
    
})