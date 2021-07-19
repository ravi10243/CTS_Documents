({
    doInit : function(component, event, helper) {
        console.log('parentRecordId--' + component.get("v.parentRecordId"));
        helper.doInitHelper(component, event, helper) ;
    },
    OnEdit : function(component, event, helper) {
        component.set("v.addNewMode",false);
        component.set("v.selectedLocalisedFormId", event.getSource().get("v.value"));
    },
    OnDelete : function(component, event, helper) {
        //alert('Inside OnDelete');
        //alert(event.getSource().get("v.value"));
        component.set("v.recordIdToDelete", event.getSource().get("v.value"));
        component.find("recordtoDelete").reloadRecord();
    },
    OnAddNew : function(component, event, helper) {
        //component.set("v.selectedLocalisedFormId",null);
        component.set("v.addNewMode",true);
        
        var newRecord = new Object();
        newRecord.DataCapture__c	= component.get("v.parentRecordId");
        
        component.set("v.newLocalisedForm", newLocalisedForm);
    },
    OnCloseProperty : function(component, event, helper) {
        
        //component.set("v.addNewMode",false);
        //component.set("v.selectedLocalisedFormId",null)
    },
    Save: function(component, event)
    {
        return true;
    },
    onSaveClick : function(component, event){
        console.log('editFormRelatedRecordMultiple' + component.find('editFormRelatedRecordMultiple'));
        component.find('editFormRelatedRecordMultiple').submit();
    },
    handleSaveEvent : function(component, event,helper){
        var saveEditRecordId = event.getParam("recId");
        component.set("v.selectedRecordId",saveEditRecordId);
        console.log('Handle Save event---' + component.get("v.selectedRecordId"));
        helper.doInitHelper(component, event, helper) ;
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
        
        //component.set("v.addNewMode",false);
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'Save operation successful!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        
        toastEvent.fire();
        component.set("v.childRecordId",null);
        helper.doInitHelper(component, event, helper) ;
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