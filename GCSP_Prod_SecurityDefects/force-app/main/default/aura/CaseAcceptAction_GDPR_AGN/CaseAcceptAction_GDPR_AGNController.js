({
	doInit : function(component, event, helper) {
        
       var action1 = component.get("c.acceptCase");
       action1.setParams({"caseId": component.get("v.recordId")});
       action1.setCallback(this, function(response){
           var res =JSON.stringify(response.getReturnValue());
           var pareseVal=JSON.parse(res);
           console.log('Sudipta');
           console.log(pareseVal);
            if(pareseVal=='underReview')
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
           
            if(pareseVal=='New')
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Case Accepted!!!!',
                    messageTemplate: 'Record {0} created! See it {1}!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
               
            }
           
        if(pareseVal=='notVerified')
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error!!!!',
                    message:'Case can only be Accepted After Email Verification !!!!!',
                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        
           if(pareseVal=='CaseRejected')
            { 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Info Message',
                    message: 'Rejected case Cant Be Accept !!!!!', 
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'dismissible'
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
           if(pareseVal=='deletionInvalid')
           {
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error!!!!',
                    message:'Invalid Deletion Status to Accept a Case',
                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
               
           }

           $A.get("e.force:closeQuickAction").fire();
           $A.get('e.force:refreshView').fire();  
        }); $A.enqueueAction(action1);
		
	},
    
    
})