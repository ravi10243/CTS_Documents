({
	invokeRefreshBuilder : function(component, event, helper) {
		var refreshBuilderEvent = $A.get("e.c:CMS_BuilderRefreshEvent");
        //alert(refreshBuilderEvent);
        //refreshBuilderEvent.setParams({"currentStepId" :selectedStepId}); 
        refreshBuilderEvent.fire();
	},
    invokeRefreshComponentsBar : function(component, event, helper) {
		var refreshComponentsBar = $A.get("e.c:CMS_ComponentsRefreshEvent");
        //alert(refreshComponentsBar);
        //refreshBuilderEvent.setParams({"currentStepId" :selectedStepId}); 
        refreshComponentsBar.fire();
	}
})