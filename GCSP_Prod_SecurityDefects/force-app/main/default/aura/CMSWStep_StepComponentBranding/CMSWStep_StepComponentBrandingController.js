({
    doInit : function(component, event, helper) {
		helper.doInitHelper(component, helper, event) ;
	},
    doSaveComponentBranding : function(component, event, helper) {
        //let property = component.get("v.formArea").ListElement[0].ListProperty[3];
        

        helper.doSaveBrandingHelper(component, event) ;
	},
	saveComponentData: function(component, event)
    {
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