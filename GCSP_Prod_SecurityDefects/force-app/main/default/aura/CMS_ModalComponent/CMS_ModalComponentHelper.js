({
	invokeRefreshBuilder : function(component, event, helper) {
		var refreshBuilderEvent = $A.get("e.c:CMS_BuilderRefreshEvent");
        //alert(refreshBuilderEvent);
        //refreshBuilderEvent.setParams({"currentStepId" :selectedStepId}); 
        refreshBuilderEvent.fire();
	}
})