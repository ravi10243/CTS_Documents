({
	doInit : function(component, event, helper) {
		helper.doInitHelper(component, event) ;
	},
    doSaveFormBranding : function(component, event, helper) {
        helper.doSaveBrandingHelper(component, event) ;
	},
    saveComponentData: function(component, event,helper)
    {
        //alert('FormLanguages - Inside Save Component Data');
         helper.doSaveBrandingHelper(component, event) ;
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