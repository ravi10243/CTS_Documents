({
	doInit : function(component, event, helper) {
		var formStepId= component.get("v.currentStepId");
        //alert('Inside Form Step -> ' + formStepId);
        
        if(formStepId)
        {
            var currentFormStep = component.get("v.pageFormStep");
            if(currentFormStep)
            {
                var renderCustom = currentFormStep.PageFormStep.IsCustom__c;
                component.set("v.IsCustom", renderCustom);
                helper.loadComponent(component, event, helper);
            }
        }
	}
})