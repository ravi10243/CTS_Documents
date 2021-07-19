({    
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
        component.set("v.showSpinner", true); //Experian related change
        helper.hasDataFields(component, event, helper);
        var hasObjectFieldsOnUI = component.get("v.hasObjectFieldsOnUI");
        
        if(hasObjectFieldsOnUI)
        {
            component.find('editform').submit();
        }
        else
        {
            helper.navigateStep(component, event, helper);
            component.set("v.showSpinner", false);//Experian related change
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
        ////alert('StepStandard - onEditFormLoad');
        
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
                            ////alert(dataFieldAPIName);
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
                        console.log('Parent record id in stepstandardhelper 1-' + component.get("v.recordId"));
                        formElement.set("v.parentRecordId", component.get("v.recordId"));
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
                        console.log('Parent record id in stepstandardhelper 2-' + component.get("v.recordId"));
                        var formFieldElementType = formElement.get("v.elementWrapper.PageElement").ComponentType__c;
                        if(formFieldElementType == 'ChildObjectOne') 
                        {
                            var formFieldClassName = formElement.get("v.elementWrapper.class");
                            formElement.set("v.parentRecordId", component.get("v.recordId"));
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
                            formElement.set("v.parentRecordId", component.get("v.recordId"));
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
    getMessage : function(component, messageKey, language, callback) {
        try {
            console.log("Geting Message");
            let action = component.get("c.getMessage");
            
            action.setParams({
                'key': messageKey,
                'language': language
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    try {
                        const value = response.getReturnValue();
                        console.log(value);
                        if (value) {
                            callback(value[0].Title__c, value[0].Message__c);
                        } else {
                            console.error("Message could not be retrieved!");
                        }
                    } catch(err) {
                        console.log(err);
                    }
                } else {
                    console.error("Something went wrong with getting the message: F3_SitePageFormStepStandardHelper");
                }
            });
            
            $A.enqueueAction(action);
            
        } catch (err) {
            console.log(err);
        }
    },
    setDefaultStyle : function(component) {
        component.set("v.bodyBackground", "background-color: white");
        component.set("v.buttonStyle", "font-size: 13px;");
        component.set("v.buttonBackground", "background-color: #f1f1f1");
    },
    applyStyleAction : function(component, action) {
        action(component, "v.bodyBackground");
        action(component, "v.buttonStyle");
        action(component, "v.buttonBackground");
       
    },
    increaseFontSize: function(component, style) {
        let styleString = component.get(style);
        component.set(style, styleString.replace(/\d+px/g, (match) => (parseInt(match) + 2) + "px"));
    },
    decreaseFontSize : function(component, style) {
        let styleString = component.get(style);
        component.set(style, styleString.replace(/\d+px/g, (match) => (parseInt(match) - 2) + "px"));
    },
    increaseLetterSpacing : function(component, style) {
        let styleString = component.get(style);
        styleString.includes("letter-spacing: 0.2em") ? "" : component.set(style, styleString + '; letter-spacing: 0.2em');
    },
    highContrastWhite : function(component, style) {
        const currentStyle = component.get(style) + ";";
        
        if(style == "v.buttonStyle" && !currentStyle.includes("color")) {
            component.set(style, currentStyle + "background-color: black; color: white;"); return;
        }
        let backgroundColor = "black";
        backgroundColor = (style == "v.buttonBackground") ? "#1f262a" : backgroundColor;
        component.set(style, currentStyle.replace(/(background-color|color)\:.{3,19};/g, match => { 
            return match.includes("background") ? "background-color: " + backgroundColor + "; " : "color: white;"
        }));
    },
    highContrastYellow : function(component, style) {
        const currentStyle = component.get(style) + ";";
       
        if(style == "v.buttonStyle" && !currentStyle.includes("color")) {
            component.set(style, currentStyle + "background-color: black; color: yellow;"); return;
        } 
        let backgroundColor = "black";
        backgroundColor = (style == "v.buttonBackground") ? "#2c3539" : backgroundColor;
        component.set(style, currentStyle.replace(/(background-color|color)\:.{3,19};/g, match => { 
            return match.includes("background") ? "background-color: " + backgroundColor + "; " : "color: yellow;"
        }));
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
     handleOnLoadViewState : function(component, event, helper){
        try
        {
        	var currentViewState = component.get("v.currentViewState");
            if(currentViewState)
            {
                var listFieldVisibility = JSON.parse(currentViewState);
                ////alert(listFieldVisibility);
                
                for(var j=0;j<listFieldVisibility.length;j++)
                {
                    var formField = listFieldVisibility[j];
                    
                    var listFormFields = component.get("v.listPageElements");
                    console.log('listFormFields---'+listFormFields);
                    if(listFormFields)
                    {
                        for(var i=0;i<listFormFields.length;i++)
                        {
                            console.log(listFormFields[i].DeveloperName + '  '+ formField.DeveloperName);
                            if(listFormFields[i].DeveloperName == formField.DeveloperName)
                            {
                                console.log('Set visibility on load--'+formField.visibility + ' for field name = '+ formField.DeveloperName);
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
            //alert(err.message);
        }
    },
    getRecordTypeId: function(component, event, helper){
        var recTypeAction = component.get("c.getPrimaryObjRecTypeId");// get record type id if specified on MD form for primary object
        console.log('object--'+component.get("v.primaryFormObjectAPIName"));
        console.log('Record type developer name--'+component.get("v.currentSitePage.DefaultPageForm.ObjectRecordTypeAPIName__c"));
        recTypeAction.setParams({
            objectAPI:component.get("v.primaryFormObjectAPIName"),
            recordTypeDevName:component.get("v.currentSitePage.DefaultPageForm.ObjectRecordTypeAPIName__c")
        });
        recTypeAction.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                ////alert(response.getReturnValue());
                
                component.set("v.primaryObjRecordTypeId",response.getReturnValue());
                console.log('Primaryobjectrecordtypeid-- '+component.get("v.primaryObjRecordTypeId"));
            } else {
                //alert('ERROR IN getting record type of primary object - F3_SitePageStepStandardHelper.js');
            }
        });
        $A.enqueueAction(recTypeAction);
    }
})