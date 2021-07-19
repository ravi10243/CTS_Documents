({
    doInit : function(component, event, helper) {
        var action = component.get("c.getMdFormRecordTypeId");
        action.setParams({
            recTypeDevName : component.get("v.mdFormRecordTypeName")
        });
        
        action.setCallback(this,function(resp){
            var state = resp.getState();
            
            if(state === 'SUCCESS') {
                //var res = resp.getReturnValue();
                component.set("v.mdFormRecordTypeId", resp.getReturnValue());
                console.log('record type id --' + component.get("v.mdFormRecordTypeId"));
                
            } else {
                console.log('Error while getting form record type..'+JSON.stringify(resp.getError()));

            }
        });
        
        $A.enqueueAction(action);
    },
    
    doSaveDetails : function(component, event, helper) {
        // do Required field validation and save record
        var isSuccess = helper.doRequiredValidation(component,helper);
    },
    handleSubmit : function(component, event){
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        console.log('fields--'+JSON.stringify(fields));
        
    },
    onFormLoad : function(component, event, helper){
        //console.log('Fields==== '+JSON.stringify(event.getParam("recordUi")));
    },
    saveComponentData: function(component, event,helper)
    {
        //alert('Inside Save Component Data');
        var isSuccess = false;
        var params = event.getParam('arguments');
        if(params)
        {
            isSuccess = helper.doRequiredValidation(component,helper);
        }
        return isSuccess; 
    }
})