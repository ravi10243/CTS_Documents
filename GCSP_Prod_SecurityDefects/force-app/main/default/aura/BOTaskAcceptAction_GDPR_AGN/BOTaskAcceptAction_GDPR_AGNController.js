({
	doInit : function(component, event, helper) {
        
       var action1 = component.get("c.acceptTask");
       action1.setParams({"taskId": component.get("v.recordId")});
       action1.setCallback(this, function(response){
           var res =JSON.stringify(response.getReturnValue());
           var pareseVal=JSON.parse(res);
           console.log('Sayanee');
           console.log(pareseVal);
            if(pareseVal=='InProgress')
            {
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info Message',
                    message: 'Task already Accepted!!!!!',
                    messageTemplate: 'Record {0} created! See it {1}!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                
            }
           
            if(pareseVal=='NotStarted')
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success Message',
                    message: 'Task Accepted!!!!',
                    messageTemplate: 'Record {0} created! See it {1}!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
           
        if(pareseVal=='Rejected')
            {
               
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Cant Accept Task as this was rejected !!!!!',
                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
           if(pareseVal=='other')
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info Message',
                    message: 'Case already Accepted!!!!!',
                    messageTemplate: 'Record {0} created! See it {1}!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                
            }

           $A.get("e.force:closeQuickAction").fire();
           $A.get('e.force:refreshView').fire();  
        }); $A.enqueueAction(action1);
		
	},
    
    
})