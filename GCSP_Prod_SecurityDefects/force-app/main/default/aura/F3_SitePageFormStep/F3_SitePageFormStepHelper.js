({
	loadComponent : function(component, event, helper) {
        var currentFormStepWrapper = component.get("v.pageFormStep");
        var formStepId= component.get("v.currentStepId");
        var primaryFormObjectAPIName= component.get("v.primaryFormObjectAPIName");
        var numberOfSteps= component.get("v.numberOfSteps");
        var renderMode= component.get("v.renderMode");
        var recordIdInContext= component.get("v.recordIdInContext");
        var formStepSequence= component.get("v.formStepSequence");
        const currentSitePage = component.get("v.currentSitePage");
        
        var body = component.get("v.body");
        
        if(currentFormStepWrapper)
        {            
            if(currentFormStepWrapper.PageFormStep.IsCustom__c)
            {
                $A.createComponent(
                    currentFormStepWrapper.PageFormStep.CustomComponentName__c,
                    {
                        "currentFormStep": currentFormStepWrapper,
                        "currentStepId" : formStepId,
                        "primaryFormObjectAPIName" : primaryFormObjectAPIName,
                        "numberOfSteps" : numberOfSteps,
                        "renderMode" : renderMode,
                        "recordId" : recordIdInContext,
                        "formStepSequence" : formStepSequence
                    },
                    function(newcomponent, status, errorMessage){
                        if (status === "SUCCESS") {    
                            body.push(newcomponent);
                            component.set("v.body", body);
                        }
                    }
                );    
            }
            else
            {
                $A.createComponent(
                    'c:F3_SitePageFormStepStandard',
                    {
                        "currentSitePage": currentSitePage,
                        "currentFormStep": currentFormStepWrapper,
                        "currentStepId" : formStepId,
                        "primaryFormObjectAPIName" : primaryFormObjectAPIName,
                        "numberOfSteps" : numberOfSteps,
                        "renderMode" : renderMode,
                        "recordId" : recordIdInContext,
                        "formStepSequence" : formStepSequence
                    },
                    function(newcomponent, status, errorMessage){
                        if (status === "SUCCESS") {
                            body.push(newcomponent);
                            component.set("v.body", body);
                        }
                        else
                        {
                            alert('Standard Component Creation errorMessage' + errorMessage);
                        }
                    }
                );     
            }
        }
        
    }
})