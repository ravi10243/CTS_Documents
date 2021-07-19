({
    doInitHelper : function(component, event) 
    {
        var recordId = component.get("v.recordId");
        
        if(recordId)
        {
            var actionWrapper = component.get("c.GetMDFormWrapper");
            actionWrapper.setParams({
                mdFormId : component.get("v.recordId")
            });
            actionWrapper.setCallback(this, function(response){
                var state = response.getState();
                //alert(state);
                if(state === "SUCCESS") 
                {
                    try
                    {
                        var mdFormWrapper = response.getReturnValue();
                        component.set("v.mdFormWrapper", mdFormWrapper);
                    }
                    catch(err)
                    {
                        alert('MDFormBuilderController - CMS_BuilderTreeModeHelper - doInit - Error :: ' + err);
                    }
                }
            });
            $A.enqueueAction(actionWrapper); 
        }
    },
    onDragStart : function(id) {
    }
})