({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component, event, helper) ;
    },
    Save: function(component, event)
    {
        component.find('editFormRelatedRecordSingle').submit();
        return true;
    },
    onFormSubmit : function(component, event, helper) 
    {
        //alert('Inside onFormSubmit - This should never get called');
        event.preventDefault();
    },
    onFormSubmitSuccess : function(component, event, helper) 
    {
        var payload = event.getParams().response;
        component.set("v.childRecordId",payload.id);
        component.set("v.hasSubmissionErrors",false);
    },
    onFormSubmitError: function(component, event, helper) 
    {
        component.set("v.hasSubmissionErrors",true);
    },
    onFormLoad: function(component, event, helper) 
    {
        var relationshipFieldAPIName = component.get("v.relationshipFieldAPIName");
        var parentrecordId = component.get("v.parentRecordId");
        var recordId = component.get("v.childRecordId");
        
        var recordfields =  component.find('relationshipFieldAPIName');
        
        for(var i=0;i<recordfields.length;i++)
        {
            if(recordfields[i].get("v.fieldName") == relationshipFieldAPIName)
            {
                if(!recordId)
                {
                   recordfields[i].set("v.value", parentrecordId);
                }
            } 
        }
        
        helper.handleOnFormLoad(component, event, helper);
    },
    isValid: function(component, event)
    {
        //alert('Inside isValid');
        var params = event.getParam('arguments');
        if(params)
        {
            var elementWrapper = component.get("v.elementWrapper");
            var isRequired = elementWrapper.Required__c;
            
            if(isRequired)
            {
                var isCompleteComponentValidated = true
                var listComponent = component.find("childobjectfield");
                if(listComponent)
                {
                    for(var j=0;j<listComponent.length;j++)
                    {
                        var formElement = listComponent[j];
                        if(formElement)
                        {
                            var isValidated = formElement.isValid(false);
                            if(!isValidated && isCompleteComponentValidated)
                            {
                                isCompleteComponentValidated = false;
                                //component.set("v.errorMessage",formElement.get("v.errorMessage"));
                            }
                        }
                    }
                }
                
                if(!isCompleteComponentValidated)
                {
                    component.set("v.elementClass", "border-required");    
                }
                
                return isFormStepValidated;
            }
            else
            {
                var isCompleteComponentValidated = true;
                var listComponent = component.find("childobjectfield");
                if(listComponent)
                {
                    for(var j=0;j<listComponent.length;j++)
                    {
                        var formElement = listComponent[j];
                        if(formElement)
                        {
                            var isValidated = formElement.isValid(false);
                            if(!isValidated && isCompleteComponentValidated)
                            {
                                isCompleteComponentValidated = false;
                                //component.set("v.errorMessage",formElement.get("v.errorMessage"));
                            }
                        }
                    }
                }
                return isCompleteComponentValidated;
            }
        }
    }
})