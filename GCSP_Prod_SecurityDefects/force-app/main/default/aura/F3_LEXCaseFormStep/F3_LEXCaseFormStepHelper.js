({
    doInitHelper : function(component, event, helper){
        var currentFormStepId = component.get("v.currentStepId");
        //alert(currentFormStepId);
        
        if(currentFormStepId)
        {
            var actionCaseFormStep = component.get("c.GetLEXFormStepWrapper");
            actionCaseFormStep.setParams({
                formStepId : currentFormStepId
            });
            actionCaseFormStep.setCallback(this, function(response){
                var state = response.getState();
                
                if(state === "SUCCESS")
                {
                    //alert('doInitHelper - Sucess');
                    component.set("v.primaryFormObjectAPIName", null);
                    component.set("v.formObjectRecordId", null);
                    component.set("v.parentObjectRelationshipFieldAPIName", null);
                    component.set("v.listPageElements", null);   
                    
                    var currentStepWrapper = response.getReturnValue();
                    component.set("v.currentStepWrapper", currentStepWrapper);
                    //alert(JSON.stringify(currentStepWrapper));
                    if(currentStepWrapper)
                    {
                        component.set("v.primaryFormObjectAPIName", currentStepWrapper.CaseFormObjectAPIName);
                        component.set("v.formObjectRecordId", currentStepWrapper.CaseFormObjectRecordId);
                        component.set("v.parentObjectRelationshipFieldAPIName", currentStepWrapper.CaseRelationshipFieldAPIName);
                        component.set("v.listPageElements", currentStepWrapper.ListComponent);
                        component.set("v.currentViewState", currentStepWrapper.CurrentViewState);
                        //alert(currentStepWrapper.ListComponent);
                        
                        helper.handleOnLoadViewState(component, event, helper);
                    }
                }
            });
            
            $A.enqueueAction(actionCaseFormStep);
        }
    },
    handleOnLoadViewState : function(component, event, helper){
        try
        {
        	var currentViewState = component.get("v.currentViewState");
            if(currentViewState)
            {
                var listFieldVisibility = JSON.parse(currentViewState);
                //alert(listFieldVisibility);
                
                for(var j=0;j<listFieldVisibility.length;j++)
                {
                    var formField = listFieldVisibility[j];
                    
                    var listFormFields = component.get("v.listPageElements");
                    if(listFormFields)
                    {
                        for(var i=0;i<listFormFields.length;i++)
                        {
                            if(listFormFields[i].DeveloperName == formField.DeveloperName)
                            {
                                listFormFields[i].class = formField.visibility;
                                break;
                            }
                        }    
                    }  
                }
                component.set("v.listPageElements", listFormFields);
            }
        }
        catch(err)
        {
            alert(err.message);
        }
    },
    checkRequiredValidations : function(component, event, helper) {
        component.set("v.requiredValidationFailed", false);
        let listFormStepElements = component.find("formstepComponent");
        let isFormStepValidated = true;
        if(listFormStepElements)
        {
            if(listFormStepElements && !listFormStepElements.length) {
                let formElement = listFormStepElements;
                if(formElement) {
                    var formFieldElementType = formElement.get("v.elementWrapper.PageElement").ComponentType__c;
                    if(formFieldElementType == 'ObjectField' || formFieldElementType == 'ChildObjectOne') {
                        var formFieldClassName = formElement.get("v.elementWrapper.class");
                        if(!formFieldClassName)
                        {
                            var isValidated = formElement.isValid(false);
                            if(!isValidated && isFormStepValidated){
                                isFormStepValidated = false;
                            }
                        }
                        if(formFieldClassName == 'slds-show'){
                            var isValidated = formElement.isValid(false);
                            if(!isValidated && isFormStepValidated){
                                isFormStepValidated = false;
                            } 
                        }
                    }
                }
            } else if (listFormStepElements && listFormStepElements.length) {
                for(var j = 0; j < listFormStepElements.length; j++) {
                    var formElement = listFormStepElements[j];
                    if(formElement) {
                        var formFieldElementType = formElement.get("v.elementWrapper.PageElement").ComponentType__c;
                        if(formFieldElementType == 'ObjectField' || formFieldElementType == 'ChildObjectOne') {
                            var formFieldClassName = formElement.get("v.elementWrapper.class");
                            if(!formFieldClassName){
                                var isValidated = formElement.isValid(false);
                                if(!isValidated && isFormStepValidated){
                                    isFormStepValidated = false;
                                }
                            }
                            if(formFieldClassName == 'slds-show'){
                                var isValidated = formElement.isValid(false);
                                if(!isValidated && isFormStepValidated){
                                    isFormStepValidated = false;
                                } 
                            }
                        }
                    } 
                }
            }
        }
        
        component.set("v.requiredValidationFailed", !isFormStepValidated);
    },
    showOnErrorToast: function(errorTitle, errorMessage) {   
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": errorTitle,
            "message": errorMessage,
            "type": "error"
        });
        toastEvent.fire();
    },
    onCumulativeSave: function(component, event, helper){
        helper.hasDataFields(component, event, helper);
        var hasObjectFieldsOnUI = component.get("v.hasObjectFieldsOnUI");
        
        if(hasObjectFieldsOnUI)
        {
            component.find('editform').submit();
        }
        else
        {
            helper.navigateStep(component, event, helper);
        }
    },
    hasDataFields: function(component, event, helper){
        var listFormStepComponents = component.find("formstepComponent");
        if(listFormStepComponents)
        {
            if(listFormStepComponents && !listFormStepComponents.length){
                let formStepComponent = listFormStepComponents;
                if(formStepComponent)
                {
                    var formStepComponentType = formStepComponent.get("v.elementWrapper.PageElement").ComponentType__c;
                    if(formStepComponentType == 'ObjectField')
                    {
                        component.set("v.hasObjectFieldsOnUI", true);
                    }
                }
            }
            else
            {
                for(var j=0;j<listFormStepComponents.length;j++)
                {
                    var formStepComponent = listFormStepComponents[j];
                    if(formStepComponent)
                    {
                        var formStepComponentType = formStepComponent.get("v.elementWrapper.PageElement").ComponentType__c;
                        if(formStepComponentType == 'ObjectField')
                        {
                            component.set("v.hasObjectFieldsOnUI", true);
                            break;
                        }
                    }
                }
            }     
        }
    },
    onEditFormLoad : function(component, event, helper) 
    {
        //alert('StepStandard - onEditFormLoad');
        
        var recordUIStandard = event.getParam("recordUi");
        
        if(recordUIStandard)
        {
            var recordFields = recordUIStandard.record.fields;
            
            var listFormStepComponents = component.find("formstepComponent");
            
            if(listFormStepComponents)
            {
                for(var j=0;j<listFormStepComponents.length;j++)
                {
                    var formStepComponent = listFormStepComponents[j];
                    if(formStepComponent)
                    {
                        var formStepComponentType = formStepComponent.get("v.elementWrapper.PageElement").ComponentType__c;
                        if(formStepComponentType == 'ObjectField')
                        {
                            var dataFieldAPIName = formStepComponent.get("v.elementWrapper.PageElement").DataFieldAPIName__c;
                            //alert(dataFieldAPIName);
                            if(dataFieldAPIName)
                            {
                                var fieldValue = recordFields[dataFieldAPIName].value;
                                if(fieldValue)
                                {
                                    listFormStepComponents[j].set("v.fieldValue", fieldValue);    
                                }                                
                            }
                        }
                    }
                }
            }  
        }       
    },
    navigateStep : function(component, event, helper) {
        var currentStepId = component.get("v.currentStepId");
        var clickedButtonType = component.get("v.clickedButtonType");
        
        var formStepChangeEvent = $A.get("e.c:F3_FormStepChangeEvent");
        formStepChangeEvent.setParams({"currentStepId" :currentStepId, "BUTTONTYPE" :clickedButtonType}); 
        formStepChangeEvent.fire();
    },
    saveChildComponents : function(component, event, helper)
    {
        let listFormStepElements = component.find("formstepComponent");
        if(listFormStepElements)
        {
            if(listFormStepElements && !listFormStepElements.length) 
            {
                let formElement = listFormStepElements;
                if(formElement) 
                {
                    var formFieldElementType = formElement.get("v.elementWrapper.PageElement").ComponentType__c;
                    if(formFieldElementType == 'ChildObjectOne') 
                    {
                        var formFieldClassName = formElement.get("v.elementWrapper.class");
                        console.log('Parent record id in stepstandardhelper 1-' + component.get("v.formObjectRecordId"));
                        formElement.set("v.parentRecordId", component.get("v.formObjectRecordId"));
                        if(!formFieldClassName)
                        {
                            var isDataSaved = formElement.Save();
                        }
                        if(formFieldClassName == 'slds-show')
                        {
                            var isDataSaved = formElement.Save();
                        }
                    }
                }
            }
            else if (listFormStepElements && listFormStepElements.length) 
            {
                for(var j = 0; j < listFormStepElements.length; j++) 
                {
                    var formElement = listFormStepElements[j];
                    if(formElement) 
                    {
                        console.log('Parent record id in stepstandardhelper 2-' + component.get("v.formObjectRecordId"));
                        var formFieldElementType = formElement.get("v.elementWrapper.PageElement").ComponentType__c;
                        if(formFieldElementType == 'ChildObjectOne') 
                        {
                            var formFieldClassName = formElement.get("v.elementWrapper.class");
                            formElement.set("v.parentRecordId", component.get("v.formObjectRecordId"));
                            if(!formFieldClassName)
                            {
                                var isDataSaved = formElement.Save();
                            }
                            if(formFieldClassName == 'slds-show')
                            {
                                var isDataSaved = formElement.Save();
                            }
                        }
                        
                        if(formFieldElementType == 'ChildObjectMany') 
                        {
                            var formFieldClassName = formElement.get("v.elementWrapper.class");
                            formElement.set("v.parentRecordId", component.get("v.formObjectRecordId"));
                            if(!formFieldClassName)
                            {
                                var isDataSaved = formElement.Save();
                            }
                            if(formFieldClassName == 'slds-show')
                            {
                                var isDataSaved = formElement.Save();
                            }
                        }
                    } 
                }
            }
        }
    },
    modifyViewState : function(component, event, helper, fieldDeveloperName, visibilityClass)
    {
        var currentVisibilityState = component.get("v.currentViewState");
        if(currentVisibilityState)
        {
            var listFieldVisibility = JSON.parse(currentVisibilityState);
            if(listFieldVisibility)
            {
                for(var j=0;j<listFieldVisibility.length;j++)
                {
                    var formField = listFieldVisibility[j];
                    
                    if(formField.DeveloperName == fieldDeveloperName)
                    {
                        formField.visibility = visibilityClass;
                        break;
                    }
                }    
            }        
            currentVisibilityState = JSON.stringify(listFieldVisibility);        
            component.set("v.currentViewState", currentVisibilityState);   
        }
    },
})