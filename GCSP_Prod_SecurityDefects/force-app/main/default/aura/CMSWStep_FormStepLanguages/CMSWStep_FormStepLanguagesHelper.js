({
	doInitHelper : function(component, event) 
    {
        //alert('doInitHelper' + component.get("v.recordId"));
        var actionLanguage = component.get("c.GetLocalisedMDFormStepRecords");
        actionLanguage.setParams({
            mdFormStepId : component.get("v.recordId")
        });
        actionLanguage.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                try
                {
                    component.set("v.listLocalisedMDFormStep",response.getReturnValue());
                    //alert('doInitHelper' + component.get("v.listLocalisedMDFormStep").length);
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_FormStepLanguagesController - doInit - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionLanguage); 	
	}
})