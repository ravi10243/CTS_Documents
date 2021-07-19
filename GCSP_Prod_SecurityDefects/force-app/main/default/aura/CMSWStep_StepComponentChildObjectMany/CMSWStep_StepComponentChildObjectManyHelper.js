({
	doInitHelper : function(component, event) 
    {
        //var actionLanguage = component.get("c.GetChildObjectOneConfig");
        var actionLanguage = component.get("c.GetComponentConfigJSON");
        actionLanguage.setParams({
            mdComponentId : component.get("v.recordId")
        }); 
        actionLanguage.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            if(state === "SUCCESS") 
            {
                try
                {
                    var configJSON = response.getReturnValue();
                    //alert(configJSON);
                    var mdChildObjectOneConfig = JSON.parse(configJSON);
                    //alert(mdChildObjectOneConfig);
                    
                    if(mdChildObjectOneConfig)
                    {
                        component.set("v.mdChildObjectOneConfig", mdChildObjectOneConfig);
                        if(mdChildObjectOneConfig.ListFieldConfig)
                        {
                            component.set("v.listFieldConfig", mdChildObjectOneConfig.ListFieldConfig);
                        }
                    }
                    if(!mdChildObjectOneConfig)
                    {
                        mdChildObjectOneConfig = new Object();
                        component.set("v.mdChildObjectOneConfig", mdChildObjectOneConfig);
                    }
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_StepComponentChildObjectOneConfig - doInit - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionLanguage); 	
	},
    
    doSaveHelper : function(component, helper, mdConfigObject, callback) {
        var configJSON = JSON.stringify(mdConfigObject);
        //alert(configJSON);
        
        var actionProperties = component.get("c.SaveChildObjectOneConfig");
        actionProperties.setParams({
            configJSON : configJSON,
            mdComponentId : component.get("v.recordId")
        });
        actionProperties.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                try
                {
                    callback ? callback() : helper.showToast("Success Message", "Child Object - One Configuration data has been saved!", "success");
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_StepComponentChildObjectOneConfig - doSaveHelper - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionProperties); 
    },
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        
        toastEvent.fire();
    }
})