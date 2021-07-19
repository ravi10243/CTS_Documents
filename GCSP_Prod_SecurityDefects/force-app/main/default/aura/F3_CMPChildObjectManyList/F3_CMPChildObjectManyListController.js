({
	OnEdit : function(component, event, helper) {
        alert("clicked on edit");
        component.set("v.selectedChildRecordId", event.getSource().get("v.value"));
    },
    OnDelete : function(component, event, helper) {
        //alert('Inside OnDelete');
        //alert(event.getSource().get("v.value"));
        component.set("v.recordIdToDelete", event.getSource().get("v.value"));
        component.find("recordtoDelete").reloadRecord();
    },
    OnCloseProperty : function(component, event, helper) {
        component.set("v.selectedChildRecordId",null);
        
    },
    Save: function(component, event)
    {
       console.log('button Id: ' + event.getSource().get("v.value"));
       component.find("recordEdit").submit();
       
       var saveEditEvt = component.getEvent("saveEditEvent");
       
        saveEditEvt.setParams({
            "recId": event.getSource().get("v.value")
        });
        saveEditEvt.fire();
       console.log('recId: ');
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
        //component.set("v.childRecordId",null);
        //helper.doInitHelper(component, event, helper) ;
    },
    onFormSubmit : function(component, event, helper) 
    {
        
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
    onFormSubmitError: function(component, event, helper) 
    {
        component.set("v.hasSubmissionErrors",true);
    },
    onFormLoad: function(component, event, helper) 
    {
        
    }
})