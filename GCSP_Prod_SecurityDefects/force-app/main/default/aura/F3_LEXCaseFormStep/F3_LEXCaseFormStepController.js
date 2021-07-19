({
	doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper) ;      
    },
    RefreshCurrentViewWithNewStep: function(component, event){
        //alert('Inside RefreshCurrentViewWithNewStep'); 
        var params = event.getParam('arguments');
        if(params)
        {
            component.set("v.currentStepId", null);
            component.set("v.parentCaseRecordId", null);
            
            var currentStepId = params.currentStepId;
            var parentCaseRecordId = params.parentCaseRecordId;
            var isFirstStep = params.isFirstStep;
            var isLastStep = params.isLastStep;
            
            component.set("v.currentStepId", currentStepId);
            component.set("v.parentCaseRecordId", parentCaseRecordId);
            component.set("v.IsFirstStep", isFirstStep);
            component.set("v.IsLastStep", isLastStep);
            
            helper.doInitHelper(component, event) ;   
        }
    },
    onClickBookmark: function(component, event, helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'The current step has been book-marked!',
            duration:' 5000',
            key: 'info_alt',
            type: 'info',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    onClickSaveNext: function(component, event, helper) 
    {
        component.set("v.clickedButtonType", 'SAVENEXT');
        
        helper.checkRequiredValidations(component, event, helper);
        var requiredValidationFailed = component.get("v.requiredValidationFailed");
        
        if(!requiredValidationFailed) 
        {
            helper.onCumulativeSave(component, event, helper);
        }
        else 
        {
            const errorMessage = component.get("v.requiredValidationFailedErrorMessage");
            if(errorMessage) 
            {
            	helper.showOnErrorToast(component.get("v.requiredValidationFailedErrorTitle"), errorMessage);
            } 
            else 
            {
                const language = component.get("v.listPageElements")[0].CurrentLanguageCode;
                helper.showOnErrorToast('Validation Errors', 'Fields marked red/with * are mandatory.');
                
                /**
                helper.getMessage(component, "error_fields_required", language, (title, message) => {
                    component.set("v.requiredValidationFailedErrorTitle", title);
                    component.set("v.requiredValidationFailedErrorMessage", message);
                    helper.showOnErrorToast(title, message);
                });
                **/
            }
            
        }
    },
    onClickSavePrevious: function(component, event, helper) {
        component.set("v.clickedButtonType", 'SAVEPREV');
        
        helper.checkRequiredValidations(component, event, helper);
        var requiredValidationFailed = component.get("v.requiredValidationFailed");
        
        if(!requiredValidationFailed) 
        {
            helper.onCumulativeSave(component, event, helper);
        }
        else 
        {
            const errorMessage = component.get("v.requiredValidationFailedErrorMessage");
            if(errorMessage) 
            {
            	helper.showOnErrorToast(component.get("v.requiredValidationFailedErrorTitle"), errorMessage);
            } 
            else 
            {
                helper.showOnErrorToast('Validation Errors', 'Fields marked red/with * are mandatory.');
                /**
                const language = component.get("v.listPageElements")[0].CurrentLanguageCode;
                
                helper.getMessage(component, "error_fields_required", language, (title, message) => {
                    component.set("v.requiredValidationFailedErrorTitle", title);
                    component.set("v.requiredValidationFailedErrorMessage", message);
                    helper.showOnErrorToast(title, message);
                });
                **/
            }
        }
    },
    onClickSave: function(component, event, helper) {
        component.set("v.clickedButtonType", 'SAVE');

        helper.checkRequiredValidations(component, event, helper);
        var requiredValidationFailed = component.get("v.requiredValidationFailed");
        
        if(!requiredValidationFailed) 
        {
            helper.onCumulativeSave(component, event, helper);
        }
        else 
        {
            helper.showOnErrorToast('Validation Errors', 'Fields marked red/with * are mandatory.');
            const errorMessage = component.get("v.requiredValidationFailedErrorMessage");
            if(errorMessage) {
            	helper.showOnErrorToast(component.get("v.requiredValidationFailedErrorTitle"), errorMessage);
            } 
            else 
            {
                helper.showOnErrorToast('Validation Errors', 'Fields marked red/with * are mandatory.');
                /**
                const language = component.get("v.listPageElements")[0].CurrentLanguageCode;
                helper.getMessage(component, "error_fields_required", language, (title, message) => {
                    component.set("v.requiredValidationFailedErrorTitle", title);
                    component.set("v.requiredValidationFailedErrorMessage", message);
                    helper.showOnErrorToast(title, message);
                });
                **/
            }
        }
    },
    onSubmitForm : function(component, event, helper){
    	alert('Inside onSubmitForm - This should never get called');
        event.preventDefault();
	},
    onSubmitSuccess: function(component, event, helper){
        //alert('Inside onSubmitSuccess');
        
        var payload = event.getParams().response;
        var submittedRecordId = payload.id; 
        //alert('submittedRecordId ->' + submittedRecordId);
        
        component.set("v.formObjectRecordId", submittedRecordId);
        component.set("v.recordId", submittedRecordId);
        var currentViewState = component.get("v.currentViewState");
        
        //alert(currentViewState);
        
        var gotObjectRecordIdInContext = $A.get("e.c:F3_GotObjectRecordIdInContext");
        gotObjectRecordIdInContext.setParams({"recordIdInContext" :submittedRecordId, "currentFormStepViewState" : currentViewState});
        gotObjectRecordIdInContext.fire();
		
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Form saved successfully!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();

        helper.saveChildComponents(component, event, helper);
        helper.navigateStep(component, event, helper);
    },
    onSubmitError: function(component, event, helper){
        var eventName = event.getName();
    	var eventDetails = event.getParam("error");
        
        alert('Error Event received');
        alert(JSON.stringify(eventDetails));
        alert('TBD - onSubmitError');
        
        component.set("v.hasOtherErrors", true);
        helper.showOnErrorToast("Unknown Error", hasOtherErrorsMessage);
    },
    onEditFormLoad : function(component, event, helper) 
    {
        helper.onEditFormLoad(component, event, helper);  
    },
    componentViewStateHandler : function(component, event, helper) {
        var selectedValueJSON = event.getParam("param");
        var listFieldVisibility = selectedValueJSON.VisisbilityArray;
        
        for(var i=0; i<listFieldVisibility.length; i++)
        {
            var formField = listFieldVisibility[i];    
            var listFormStepElements = component.find("formstepComponent");
            
            for(var j=0;j<listFormStepElements.length;j++)
            {               
                if(listFormStepElements[j].get("v.elementWrapper").DeveloperName == formField.DeveloperName)
                {
                    listFormStepElements[j].set("v.elementWrapper.class", formField.visibility);                    
                    helper.modifyViewState(component, event, helper, formField.DeveloperName, formField.visibility);
                    break;
                }
            }
        }
    }
})