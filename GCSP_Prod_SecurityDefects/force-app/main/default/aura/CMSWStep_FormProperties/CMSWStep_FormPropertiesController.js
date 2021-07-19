({
	doInit : function(component, event, helper) {
		helper.doInitHelper(component, event) ;
	},
    doSaveProperties : function(component, event, helper) {
        //alert('doSaveProperties');
        //alert(component.get("v.listProperties"));
		helper.doSavePropertiesHelper(component, event) ;
	},
    saveComponentData: function(component, event,helper)
    {
        //alert('FormProperties - Inside Save Component Data');
        helper.doSavePropertiesHelper(component, event) ;
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