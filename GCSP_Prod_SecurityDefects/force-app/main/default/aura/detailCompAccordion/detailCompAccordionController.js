({
    doInit : function(component, event, helper) {
        console.log('parentRecordId--' + component.get("v.parentRecordId"));
        //helper.doInitHelper(component, event, helper) ;
    },
    Save: function(component, event)
    {
        console.log('editFormRelatedRecordMultiple' + component.find('editFormRelatedRecordMultiple'));
        component.find('editFormRelatedRecordMultiple').submit();
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
        //component.set("v.hasSubmissionErrors",true);
    },
    onFormLoad: function(component, event, helper) 
    {
        console.log("on form loaddddddd");
    },
    isValid: function(component, event)
    {
    }
})