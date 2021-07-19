({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component,event,helper);
    },
    onGotObjectRecordIdInContextHandler : function(component, event, helper){
        var recordIdInContext = event.getParam("recordIdInContext");
        var currentStepViewState = event.getParam("currentFormStepViewState");
        //alert('Inside onGotObjectRecordIdInContextHandler' + recordIdInContext);
        component.set("v.recordIdInContext", recordIdInContext);
        var currentFormId = component.get("v.currentFormId");
        var currentFormStepId = component.get("v.currentFormStepId");
        
        var actionUpdateRecordId = component.get("c.UpdateObjectRecordID");
        actionUpdateRecordId.setParams({
            lexFormRecordId : currentFormId,
            formObjectRecordId : recordIdInContext,
            lexFormStepId : currentFormStepId,
            currentStepViewState : currentStepViewState
        });
        actionUpdateRecordId.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                var currentForm = response.getReturnValue();
                //alert('Updated form object record Id' + recordIdInContext);
            }
        });
        $A.enqueueAction(actionUpdateRecordId); 
    },
    onFormStepChangeEventHandler : function(component, event, helper){
        var currentStepId = event.getParam("currentStepId");
        var buttonType = event.getParam("BUTTONTYPE");
        var currentCaseId = component.get("v.recordId");
        
        //alert('Inside onFormStepChangeEventHandler' + 'STEP Id' + currentStepId + 'Button Type ' + buttonType);
        
        if(buttonType == 'SAVEPREV')
        {
            var actionPagePrevious = component.get("c.GetPreviouStepContext");
            actionPagePrevious.setParams({
                currentStepId : currentStepId,
                caseId : currentCaseId
            });
            actionPagePrevious.setCallback(this, function(response){
                var state = response.getState();
                
                if(state === "SUCCESS") 
                {
                    component.set("v.currentFormStepId", null);
                    component.set("v.currentFormId", null);
                    component.set("v.IsFirstStep", null);
                    component.set("v.IsLastStep", null);
                    
                    var previousStepContext = response.getReturnValue();
                    //alert(JSON.stringify(previousStepContext));
                    
                    component.set("v.IsFirstStep", previousStepContext.IsFirstStep);
                    component.set("v.IsLastStep", previousStepContext.IsLastStep);     
                    
                    var actionFormStep = component.get("c.GetLEXFormStepsForAForm");
                    actionFormStep.setParams({
                        lexFormId: previousStepContext.LEXFormId
                    });
                    actionFormStep.setCallback(this,function(response){
                        var state = response.getState();
                        if(state === "SUCCESS") 
                        {
                            component.set("v.listCaseFormSteps", null);
                            var listCaseFormSteps = response.getReturnValue();     
                            //alert(JSON.stringify(listCaseFormSteps));
                            component.set("v.listCaseFormSteps", listCaseFormSteps);
                            
                            helper.navigateToStep(component, event, helper);
                            
                            component.set("v.currentFormStepId", previousStepContext.LEXFormStepId);
                            component.set("v.currentFormId", previousStepContext.LEXFormId);
                        }
                    });
                    $A.enqueueAction(actionFormStep);
                }
            });
            $A.enqueueAction(actionPagePrevious); 
        }
        else if(buttonType == 'SAVENEXT')
        {
            var actionPageNext = component.get("c.GetNextStepContext");
            actionPageNext.setParams({
                currentStepId : currentStepId,
                caseId : currentCaseId
            });
            actionPageNext.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS") 
                {
                    component.set("v.currentFormStepId", null);
                    component.set("v.currentFormId", null);
                    component.set("v.IsFirstStep", null);
                    component.set("v.IsLastStep", null);
                    
                    var nextStepContext = response.getReturnValue();
                    //alert(JSON.stringify(nextStepContext));
                    
                    component.set("v.IsFirstStep", nextStepContext.IsFirstStep);
                    component.set("v.IsLastStep", nextStepContext.IsLastStep);   
                    
                    var actionFormStep = component.get("c.GetLEXFormStepsForAForm");
                    actionFormStep.setParams({
                        lexFormId: nextStepContext.LEXFormId
                    });
                    actionFormStep.setCallback(this,function(response){
                        var state = response.getState();
                        if(state === "SUCCESS") 
                        {
                            component.set("v.listCaseFormSteps", null);
                            var listCaseFormSteps = response.getReturnValue();     
                            //alert(JSON.stringify(listCaseFormSteps));
                            component.set("v.listCaseFormSteps", listCaseFormSteps);
                            
                            helper.navigateToStep(component, event, helper);
                            
                            component.set("v.currentFormStepId", nextStepContext.LEXFormStepId);
                            component.set("v.currentFormId", nextStepContext.LEXFormId);
                        }
                    });
                    $A.enqueueAction(actionFormStep);
                }
            });
            $A.enqueueAction(actionPageNext); 
        }
            else if(buttonType == 'SAVE') 
            {
                // TBD 
            }
    },
})