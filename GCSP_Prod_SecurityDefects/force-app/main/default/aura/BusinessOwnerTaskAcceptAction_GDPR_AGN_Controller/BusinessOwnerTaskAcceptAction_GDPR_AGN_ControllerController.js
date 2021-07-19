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
                alert('Case already Accepted!!!!!');
            }
           
            if(pareseVal=='New')
            {
                alert('Case Accepted!!!!');
            }
           
        if(pareseVal=='notVerified')
            {
                alert('Case only Accept After Email Verification !!!!!');
            }
         if(pareseVal=='other')
            {
                alert('Case already Accepted!!!!!');
            }

           $A.get("e.force:closeQuickAction").fire();
           $A.get('e.force:refreshView').fire();  
        }); $A.enqueueAction(action1);
		
	},
    
    
})