({
	doInitHelper : function(component, helper, event) 
    {
        var actionFormArea = component.get("c.GetMDComponentBranding");
        actionFormArea.setParams({
            mdComponentId : component.get("v.recordId")
        });
        actionFormArea.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            if(state === "SUCCESS") 
            {
                try
                {
                    var formAreaWrapper = response.getReturnValue();
                    //alert(formAreaWrapper.ListElement.length);
                    
                    component.set("v.formArea", response.getReturnValue());
                    console.log("Set formArea");
                    helper.initAttributes(component);
                    console.log(component.get("v.Font"));
                    console.log(component.get("v.FontStyle"));
                    console.log(component.get("v.Color"));
                    console.log(component.get("v.FontSize"));
                    //alert(component.get("v.formArea"));
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_StepComponentBrandingController - doInit - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionFormArea); 	
	},
    initAttributes : function(component) {
        const formArea = component.get("v.formArea");
        const listProperties = formArea.ListElement[0].ListProperty;
        listProperties.forEach(e => console.log(e));
        listProperties.forEach(property => component.set("v."+property.PropertyType, property.PropertyValue));
    },
    doSaveBrandingHelper : function(component, event) {
        //alert('Hi');
        console.log("Saving branding1");
        var actionFormArea = component.get("c.SaveMDComponentBranding");
        const formArea = component.get("v.formArea");
		console.log(formArea.ListElement[0].ListProperty);
        actionFormArea.setParams({
            formArea : component.get("v.formArea"),
            mdComponentId : component.get("v.recordId")
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
                        message: 'Component Branding information has been saved!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    
                    toastEvent.fire();
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_StepComponentBrandingController - doSaveBrandingHelper - Error :: ' + err);
                }
            } else {
                console.log(response.getError());
                console.log(JSON.stringify(response.getError()));
            }
        });
        try {
            $A.enqueueAction(actionFormArea); 
        } catch (err) {
            console.log('Error');
            console.log(err);
        }
        
    }
})