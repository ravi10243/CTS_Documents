({
	onFormStepChangeEventHandler : function(component, event, helper){
        var currentStepId = event.getParam("currentStepId");
        //alert('designer' + currentStepId);
        component.set("v.stepId", currentStepId);
        
        var sitePageDesigner = component.find("sitePageDesigner");
        if(sitePageDesigner)
        {
            sitePageDesigner.refreshOnStepChange(currentStepId);
        }
        
    },
})