({
	doInit : function(component, event, helper) {
        helper.doInitHelper(component, event) ;
    },
    // Added by Mona start 
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
    },
    // Added by Mona end
    
    OnEdit : function(component, event, helper) {
        component.set("v.selectedLocalisedStepComponentId", event.getSource().get("v.value"));
        
        var action = component.get("c.GetLocalisedPicklistValues");
        action.setParams({
            localisedPageElementId:component.get("v.selectedLocalisedStepComponentId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if(state === "SUCCESS") 
            {
                try
                {
                    component.set("v.picklistValues",response.getReturnValue());
                    //alert(component.get("v.picklistValues"));
                }
                catch(err)
                {
                    alert('MD_FormBuilderController - doInit - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(action);    
    },
    OnCloseProperty : function(component, event, helper) {
        component.set("v.selectedLocalisedStepComponentId",null);
    },
    OnSaveTranslatedPicklist: function(component, event, helper) {
        var selectedLocalisedComponentId = component.get("v.selectedLocalisedStepComponentId");
        
        var actionPicklist = component.get("c.SaveLocalisedPicklistValues");
        actionPicklist.setParams({
            localisedPageElementId : selectedLocalisedComponentId,
            listMDLocalisedPicklistVal : component.get("v.picklistValues")
        });
        actionPicklist.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                try
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success Message',
                        message: 'Picklist values have been saved!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    
                    toastEvent.fire();
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_StepComponentPicklist - OnSaveTranslatedPicklist - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionPicklist);
    }
})