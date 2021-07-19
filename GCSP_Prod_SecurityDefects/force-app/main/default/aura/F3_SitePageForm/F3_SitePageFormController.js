({
	doInit : function(component, event, helper) {
		var currentSitePage = component.get("v.currentSitePage");
        if(currentSitePage)
        {
            var pageForm = currentSitePage.DefaultPageForm;
            var pageFormLabel = currentSitePage.FormPortalLabel;
            var pageFormDescription = currentSitePage.FormPortalDescription;
            var listPageFormSteps = currentSitePage.ListPageFormSteps;
            var currentStepId = currentSitePage.CurrentStepId;
            var currentPageFormStepWrapper = currentSitePage.PageFormStepWrapper;
            var primaryFormObjectAPIName = currentSitePage.DefaultPageForm.ObjectAPIName__c;
            
            if(currentPageFormStepWrapper)
            {
                var currentStepType = currentPageFormStepWrapper.StepType;
                component.set("v.currentStepType", currentStepType);
            }
            
            var numberOfSteps = 0;
            if(listPageFormSteps)
            {
                numberOfSteps = listPageFormSteps.length;
                
                if(numberOfSteps == 1)
                {
                    component.set("v.formStepSequence", 'ONLY');
                }
                else
                {
                    let firstStepId = listPageFormSteps[0].PageFormStepId;
                    let lastStepIndex = numberOfSteps - 1;
                    //alert(lastStepIndex);
                    let lastStepId = listPageFormSteps[lastStepIndex].PageFormStepId;
                    
                    if(currentStepId == firstStepId)
                    {
                        component.set("v.formStepSequence", 'START');
                    }
                    else if (currentStepId == lastStepId)
                    {
                        component.set("v.formStepSequence", 'END');
                    }
                    else
                    {
                        component.set("v.formStepSequence", 'MID');
                    }
                }
            }
            
            //alert(numberOfSteps);
            
            component.set("v.pageForm", pageForm);
            component.set("v.pageFormLabel", pageFormLabel);
            component.set("v.pageFormDescription", pageFormDescription);
            component.set("v.listPageFormSteps", listPageFormSteps);
            component.set("v.currentStepId", currentStepId);
            component.set("v.pageFormStepWrapper", currentPageFormStepWrapper);
            component.set("v.primaryFormObjectAPIName", primaryFormObjectAPIName);
            component.set("v.numberOfSteps", numberOfSteps);
        }
	}
})