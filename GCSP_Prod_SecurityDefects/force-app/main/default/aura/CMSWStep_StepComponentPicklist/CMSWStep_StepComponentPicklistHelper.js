({
	doInitHelper : function(component, event) 
    {
        var actionLanguage = component.get("c.GetLocalisedMDStepComponentRecords");
        //alert('*****1 record Id***'+component.get("v.recordId"));
        actionLanguage.setParams({
            mdStepComponentId : component.get("v.recordId")
        });
        actionLanguage.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            if(state === "SUCCESS") 
            {
                try
                {
                    //alert(JSON.stringify(response.getReturnValue()));
                    component.set("v.listLocalisedMDStepComponent",response.getReturnValue());
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_StepComponentPicklist - doInit - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionLanguage); 	
	}
})