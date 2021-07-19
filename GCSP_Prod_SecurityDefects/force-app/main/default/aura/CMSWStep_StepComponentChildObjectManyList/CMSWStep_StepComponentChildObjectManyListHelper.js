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
                    alert(JSON.stringify(mdChildObjectOneConfig));
                    
                    if(mdChildObjectOneConfig)
                    {
                        component.set("v.mdChildObjectOneConfig", mdChildObjectOneConfig);
                       
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
})