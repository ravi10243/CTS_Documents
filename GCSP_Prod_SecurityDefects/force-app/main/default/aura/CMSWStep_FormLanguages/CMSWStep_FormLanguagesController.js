({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component, event) ;
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
        component.set("v.selectedLocalisedFormId",null);
        component.set("v.addNewMode",true);
        
        var newLocalisedForm = new Object();
        newLocalisedForm.MDForm__c	= component.get("v.recordId");
        
        component.set("v.newLocalisedForm", newLocalisedForm);
    },
    OnCloseProperty : function(component, event, helper) {
        component.set("v.newLocalisedForm",null);
        component.set("v.addNewMode",false);
        component.set("v.selectedLocalisedFormId",null)
    },
    OnSubmitFormClick : function(component, event, helper) {
        //var isSuccess = helper.doRequiredValidation(component,helper);
        component.find("editform").submit();
        
    },
    OnSubmitFormError : function(component, event, helper) {
        //alert('Inside OnSubmitFormError');
        var error = event.getParam("error");
        console.log(error.message); // main error message
        
        // top level error messages
        error.data.output.errors.forEach(
            function(msg) { console.log(msg.errorCode); 
                           console.log(msg.message); }
        );
        
        // field specific error messages
        Object.keys(error.data.output.fieldErrors).forEach(
            function(field) { 
                error.data.output.fieldErrors[field].forEach(
                    function(msg) { console.log(msg.fieldName); 
                                   console.log(msg.errorCode); 
                                   console.log(msg.message); }
                )
            });
    },
    OnFormSubmitSuccess : function(component, event, helper) {
        //alert('Inside OnFormSubmitSuccess');
        component.set("v.newLocalisedForm",null);
        component.set("v.addNewMode",false);
        
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
        
        helper.doInitHelper(component, event);
        //event.preventDefault();
    },
    OnFormSubmit : function(component, event, helper) {
        alert('Inside onFormSubmit - This should never get called');
        event.preventDefault();
    },
    handleRecordUpdated: function(component, event, helper) {
        //alert('Inside handleRecordUpdated');
        var eventParams = event.getParams();
        //alert(eventParams.changeType);
        
        if(eventParams.changeType === "LOADED") 
        {
            component.find("recordtoDelete").deleteRecord($A.getCallback(function(deleteResult) {
                //alert(deleteResult.state);
                if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") 
                {
                    var toastEvent = $A.get("e.force:showToast");
                    
                    toastEvent.setParams({
                        "type" :"success",
                        "title": "Success!",
                        "message": "The record has been deleted successfully."
                    });
                    
                    helper.doInitHelper(component, event, helper) ;
                    toastEvent.fire();
                } 
                else if (deleteResult.state === "INCOMPLETE") 
                {
                    console.log("User is offline, device doesn't support drafts.");
                    //alert("User is offline, device doesn't support drafts.");
                } else if (deleteResult.state === "ERROR") 
                {
                    console.log('Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
                    //alert('Problem deleting record, error: ' + JSON.stringify(deleteResult.error))
                } else 
                {
                    console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
                    //alert('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
                }
            }));
        }
    },
    saveComponentData: function(component, event)
    {
        //console.log('FormLanguages - Inside Save Component Data'+ component.find("editform"));
        if(component.find("editform") != undefined){
        	component.find("editform").submit();
        }
        var params = event.getParam('arguments');
        if(params)
        {
            var isSuccess = params.isSuccess;
            // Do the code here
            isSuccess = true;
            return isSuccess; 
        }
    }
})