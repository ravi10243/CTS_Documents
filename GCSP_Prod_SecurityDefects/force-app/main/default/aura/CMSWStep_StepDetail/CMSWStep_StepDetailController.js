({
    doInit : function(component, event, helper) {
        
    },
    doSaveDetails : function(component, event, helper) {
        //console.l('Saving form details---'+component.find("editform").Name);
        //component.find("editStep").submit();
        var isSuccess = helper.doRequiredValidation(component,helper);
    },
    handleSubmit : function(component, event){
        
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        console.log('fields--'+JSON.stringify(fields));
        //component.find("editStep").submit();
    },
    OnCloseProperty : function(component, event, helper) {
        
    },
    saveComponentData: function(component, event, helper)
    {
        var isSuccess = true;
        var params = event.getParam('arguments');
        if(params)
        {
            return helper.doRequiredValidation(component,helper);
        }
        return false;
        
    },
    onFormSuccess : function(component, event, helper) {
        helper.invokeRefreshBuilder(component,event,helper);
        
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
        
        //helper.doInitHelper(component, event);
        //event.preventDefault();
    },
    onFormError : function(component, event, helper) {
        //alert("An error has occurred when submitting");
    }
    
})