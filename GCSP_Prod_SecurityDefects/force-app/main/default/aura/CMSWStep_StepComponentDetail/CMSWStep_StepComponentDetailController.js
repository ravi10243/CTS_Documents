({
    doInit : function(component, event, helper) {
        
    },
    doSaveDetails : function(component, event, helper) {
        //console.l('Saving form details---'+component.find("editComponent").Name);
        //component.find("editComponent").submit();
        var isSuccess = helper.doRequiredValidation(component,helper);
    },
    handleSubmit : function(component, event){
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        console.log('fields--'+JSON.stringify(fields));
    },
    saveComponentData: function(component, event,helper)
    {
       var isSuccess;
        var params = event.getParam('arguments');
        if(params)
        {
            isSuccess = helper.doRequiredValidation(component,helper);
        }
        return isSuccess; 
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
    },
    
    onRecordFormLoad : function(component, event, helper){
    	var recordUI = event.getParam("recordUi");
        if(recordUI)
        {
            var recordFields = recordUI.record.fields;
        }
    }

})