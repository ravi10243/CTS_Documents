({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component, event);    
    },
    refreshOnStepChange: function(component, event, helper)
    {
        var params = event.getParam('arguments');
        if(params)
        {
            var selectedStepId = params.selectedStepId;
            
            //alert('inside sitepage designer aura' + selectedStepId);
            
            component.set("v.currentSitePage", null);
            component.set("v.stepId", selectedStepId);
            
            helper.doInitHelper(component, event);    
        }
    }
})