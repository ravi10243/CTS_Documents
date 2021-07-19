({
    createTaskHelper: function(component, event, createtaskId,recordId) 
    {
        console.log('createtaskId '+ createtaskId);
        console.log('Record Id'+recordId);
        
        var action = component.get('c.createtask');
        action.setParams({
            "lstRecordId": createtaskId,
            "caserecordId":recordId
        });
        action.setCallback(this, function(response)
                           {
                               var state = response.getReturnValue();
                               
                               if (state === true) 
                               {
                                   console.log(state);
                                   if (response.getReturnValue() != true)
                                   {
                                       alert('The following error has occurred, while creating task ' + response.getReturnValue());
                                   } 
                                   else
                                   {  
                                       console.log('Task Created');
                                       $A.get('e.force:refreshView').fire();
                                       $A.get("e.force:closeQuickAction").fire() ;
                                       //Call email template
                                   }
                                   // call the onLoad function for refresh the List view    
                                   // this.onLoad(component, event);
                               }
                           });
        $A.enqueueAction(action);
    },
})