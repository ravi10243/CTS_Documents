({
    doInit : function(component, event, helper) {
        var action = component.get("c.checkTask");
        action.setParams({"taskId": component.get("v.recordId")});
        
        action.setCallback(this, function(response){
            var r =JSON.stringify(response.getReturnValue());
            var res=JSON.parse(r);
            console.log('Result '+res);
          
            if(res == 'Valid Field')
            {
               
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success Message',
                    message: 'Task Rejected!!!!',
                    messageTemplate: 'Record {0} created! See it {1}!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                
            }
            else if(res=='Invalid Field')
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Warning',
                    message:'Please provide rejection reason and rejection reason code for rejecting the task!!!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'warning',
                    mode: 'sticky'
                });
                toastEvent.fire();
              
              
            }
            else if(res=='Invalid Status')
            { 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Task Cannot be Rejected for this case status!!',
                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            else if(res=='Task Rejected')
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info Message',
                    message: 'Task already Rejected!!',
                    messageTemplate: 'Record {0} created! See it {1}!',
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