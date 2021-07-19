({
	doInitHelper : function(component, event) 
    {
        var actionFormArea = component.get("c.GetMDFormBranding");
        actionFormArea.setParams({
            mdFormId : component.get("v.recordId")
        });
        actionFormArea.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                try
                {
                    component.set("v.listFormArea",response.getReturnValue());
                    component.set("v.json", component.get("v.listFormArea")[0]);
                    //alert(component.get("v.listFormArea"));
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_FormBrandingController - doInit - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionFormArea); 	
	},
    
    doSaveBrandingHelper : function(component, event) {
        var actionFormArea = component.get("c.SaveMDFormBranding");
		console.log(component.get("v.json"));
        let toSave = component.get("v.listFormArea");
        toSave[0] = component.get("v.json");
        component.set("v.listFormArea", toSave);
  
        actionFormArea.setParams({
            listFormArea : component.get("v.listFormArea"),
            mdFormId : component.get("v.recordId")
        });
        actionFormArea.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                try
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message: 'Form Branding information has been saved!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    
                    toastEvent.fire();
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_FormBrandingController - doSaveBrandingHelper - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionFormArea); 
    }
})