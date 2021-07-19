({
    doInit : function(component, event, helper) {
        var action = component.get("c.checkCase");
        action.setParams({"caseId": component.get("v.recordId")});
        
        action.setCallback(this, function(response){
            var r =JSON.stringify(response.getReturnValue());
            var res=JSON.parse(r);
            console.log('Result '+res);
            
            if(res == 'Email Send')
            {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Email Sent To Data Subject!!!!',      
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            }            
            else if(res=='Alraeady Sent')
            {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info Message',
                    message: 'DPO cant Sent Mail More than Once!!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
                else if(res=='NotVerifiedByDPO')
                {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info Message',
                        message: 'DPO Need to Verify DS Email Body Content and confirm!!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'info',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    
                }
                    else if(res=='Invalid Status')
                    {
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Info Message',
                            message: 'Email Sending criteria does not match!!',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'info',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        
                    }
            $A.get('e.force:refreshView').fire(); 
            $A.get("e.force:closeQuickAction").fire(); 
            
        }); $A.enqueueAction(action);
    }
})