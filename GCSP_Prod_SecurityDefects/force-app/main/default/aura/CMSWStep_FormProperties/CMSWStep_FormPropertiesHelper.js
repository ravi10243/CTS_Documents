({
	doInitHelper : function(component, event) 
    {
        var actionProperties = component.get("c.GetMDFormProperties");
        actionProperties.setParams({
            mdFormId : component.get("v.recordId")
        });
        actionProperties.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                try
                {
                    component.set("v.listProperties",response.getReturnValue());
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_FormPropertiesController - doInit - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionProperties); 	
	},
    
    doSavePropertiesHelper : function(component, event) {
        var actionProperties = component.get("c.SaveMDFormProperties");
        actionProperties.setParams({
            listProperties : component.get("v.listProperties"),
            mdFormId : component.get("v.recordId")
        });
        actionProperties.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                try
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message: 'Form Properties have been saved!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    
                    toastEvent.fire();
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_FormPropertiesController - doSaveProperties - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionProperties); 
    }
})