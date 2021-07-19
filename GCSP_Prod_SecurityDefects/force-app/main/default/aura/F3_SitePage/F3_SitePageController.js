({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper) ;      
    }
    ,
    onFormStepChangeEventHandler : function(component, event, helper){
        var currentStepId = event.getParam("currentStepId");
        var buttonType = event.getParam("BUTTONTYPE");
        
        if(buttonType == 'SAVEPREV')
        {
            var actionPagePrevious = component.get("c.GetPreviousStepId");
            actionPagePrevious.setParams({
                mdPageFormStepId : currentStepId
            });
            actionPagePrevious.setCallback(this, function(response){
                var state = response.getState();
                
                if(state === "SUCCESS") 
                {
                    var previousStepId = response.getReturnValue();
                    //alert(previousStepId);
                    if(previousStepId == 'START')
                    {
                        alert(previousStepId);
                    }
                    else
                    {
                        component.set("v.stepId", previousStepId);
                        helper.navigateToStep(component, event, helper);
                    }
                }
            });
            $A.enqueueAction(actionPagePrevious); 
        }
        else if(buttonType == 'SAVENEXT')
        {
            var actionPageNext = component.get("c.GetNextStepId");
            actionPageNext.setParams({
                mdPageFormStepId : currentStepId
            });
            actionPageNext.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS") 
                {
                    var nextStepId = response.getReturnValue();
                    //alert(nextStepId);
                    
                    if(nextStepId == 'END')
                    {
                        alert(nextStepId);  
                    }
                    else
                    {   
                        component.set("v.stepId", nextStepId);
                        helper.navigateToStep(component, event, helper);
                    }
                }
            });
            $A.enqueueAction(actionPageNext); 
        }
        else if(buttonType == 'SAVE') 
        {
               // TBD 
        }
    },
    onGotObjectRecordIdInContextHandler : function(component, event, helper){
        var recordIdInContext = event.getParam("recordIdInContext");
        component.set("v.recordIdInContext", recordIdInContext);
    },
    increaseFontSize : function (component, event, helper) {
		component.find("sitePageHeader").increaseFontSize();
    },  
})