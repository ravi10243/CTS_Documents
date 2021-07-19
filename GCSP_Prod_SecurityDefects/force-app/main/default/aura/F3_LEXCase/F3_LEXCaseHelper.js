({
    doInitHelper : function(component,event,helper) {
        //alert('Inside - LEXCase doInitHelper');
        var action = component.get("c.GetLEXFormsForACase");
        action.setParams({
            caseId: component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();     
            if(state === "SUCCESS") 
            {
                var listCaseForms = response.getReturnValue();
                component.set("v.listCaseForms", listCaseForms);
                
                if(listCaseForms)
                {
                    var currentFormId = component.get("v.currentFormId");     
                    if(!currentFormId)
                    {
                        if(listCaseForms.length > 0 )
                        {
                            currentFormId = listCaseForms[0].Id;
                            component.set("v.currentFormId", currentFormId);
                            
                            if(currentFormId)
                            {
                                var actionFormStep = component.get("c.GetLEXFormStepsForAForm");
                                actionFormStep.setParams({
                                    lexFormId: currentFormId
                                });
                                actionFormStep.setCallback(this,function(response){
                                    var state = response.getState();
                                    if(state === "SUCCESS") 
                                    {
                                        var listCaseFormSteps = response.getReturnValue();                                        
                                        component.set("v.listCaseFormSteps", listCaseFormSteps);
                                        var currentFormStepId = listCaseFormSteps[0].Id;
                                        component.set("v.currentFormStepId", currentFormStepId);
                                        component.set("v.IsFirstStep", true);
                                        component.set("v.IsLastStep", false);
                                    }
                                });
                                $A.enqueueAction(actionFormStep);
                            }
                        }    
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    navigateToStep : function(component, event, helper){
        var currentCaseFormStep = component.find("currentCaseFormStep");
        if(currentCaseFormStep)
        {
            var recordId = component.get("v.recordId");
            var currentFormStepId = component.get("v.currentFormStepId");
            var isFirstStep = component.get("v.IsFirstStep");
            var isLastStep = component.get("v.IsLastStep");
            
            // Refresh View of the child step
            currentCaseFormStep.RefreshCurrentViewWithNewStep(currentFormStepId, recordId, isFirstStep, isLastStep);
        }
    }
})