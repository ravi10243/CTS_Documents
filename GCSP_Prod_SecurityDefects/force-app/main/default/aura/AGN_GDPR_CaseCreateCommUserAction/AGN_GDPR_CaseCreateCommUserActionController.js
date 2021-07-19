({
    doInit : function(component, event, helper) 
    {        
        var action1 = component.get("c.createAcc");
        action1.setParams({"caseId": component.get("v.recordId")} );
        action1.setCallback(this, function(response) 
                            {
                                var r= response.getReturnValue();
                                if(r=='UserExisting')
                                {
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title : 'Error Message',
                                        message:$A.get("$Label.c.AGN_GDPR_ComUserExist"),
                                        duration:' 5000',
                                        key: 'info_alt',
                                        type: 'error',
                                        mode: 'pester'
                                    });
                                    toastEvent.fire();
                                    
                                    $A.get("e.force:closeQuickAction").fire();
                                    $A.get('e.force:refreshView').fire();   
                                    
                                }
                                else if(r =='Task Completed CCPA')
                                {
                                    component.set("v.render",false);
                                    
                                }
                                    else if (r=='UserCreated')
                                    {
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title : 'Success',
                                            message:$A.get("$Label.c.AGN_GDPR_CommUserCreated"),
                                            messageTemplate: 'Record {0} created! See it {1}!',
                                            duration:' 5000',
                                            key: 'info_alt',
                                            type: 'success',
                                            mode: 'pester'
                                        });
                                        toastEvent.fire();   
                                        $A.get("e.force:closeQuickAction").fire();
                                        $A.get('e.force:refreshView').fire();   
                                    }
                                        else if(r=='UserActivated')
                                        {
                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                title : 'Info Message',
                                                message: $A.get("$Label.c.AGN_GDPR_UserActivated"),
                                                messageTemplate: 'Record {0} created! See it {1}!',
                                                duration:' 5000',
                                                key: 'info_alt',
                                                type: 'info',
                                                mode: 'dismissible'
                                            });
                                            toastEvent.fire();
                                            
                                            $A.get("e.force:closeQuickAction").fire();
                                            $A.get('e.force:refreshView').fire();   
                                            
                                        }
                                            else
                                            {
                                                
                                                var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    title : 'Info Message',
                                                    message: $A.get("$Label.c.AGN_GDPR_UserCannotCreated"),
                                                    messageTemplate: 'Record {0} created! See it {1}!',
                                                    duration:' 5000',
                                                    key: 'info_alt',
                                                    type: 'info',
                                                    mode: 'dismissible'
                                                });
                                                toastEvent.fire();
                                                $A.get("e.force:closeQuickAction").fire();
                                                $A.get('e.force:refreshView').fire();   
                                                
                                            }                                     
                            }); $A.enqueueAction(action1);                          
    },
    /* Method created by Rahil for populating textarea on selection of picklist value in popup */
    populateEmailBodyForInformationType: function(component, event, helper)
    {
        var idstr = component.find('InputSelectSingle'); 
        var val = idstr.get("v.value");
        if(val == "ACCESS COMPLETE & INSTRUCTIONS")
        {
            
            var pass = $A.get('$Label.c.AGN_ACCESS_COMPLETE_AND_INSTRUCTIONS_Body1');  
            component.set("v.textt",pass);
            component.set("v.buttonstate",false); 
            component.set("v.isFullTaskCompleted",true);
            component.set("v.isPartialTaskCompleted",false);
        }
        else if(val == "ACCESS PARTIALLY COMPLETE AND EXPLANATION")
        {
            
            var pass = $A.get('$Label.c.AGN_ACCESS_PARTIALLY_COMPLETE_AND_EXPLANATION_Body1');
            component.set("v.textt",pass); 
            component.set("v.buttonstate",false); 
            component.set("v.isPartialTaskCompleted",true);
            component.set("v.isFullTaskCompleted",false);
        }  
        else
        {
            component.set("v.isFullTaskCompleted",false);
            component.set("v.isPartialTaskCompleted",false);
            component.set("v.buttonstate",true); 
            component.set("v.textt","");
        }
    },
    
    /* Method created by Rahil for Cancel button */
    cancel: function(component, event, helper) 
    {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire() ;       
    },
    
    /* Method created by Rahil for Submit button */
    submit: function(component, event, helper) 
    {
        var idstr = component.find('message'); 
        var val = idstr.get("v.value");
        if(val =='')
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Info Message',
                message: 'Blank Message cannot be sent',
                messageTemplate: 'Record {0} created! See it {1}!',
                duration:' 5000',
                key: 'info_alt',
                type: 'info',
                mode: 'dismissible'
            });
            toastEvent.fire();
            
        }
        else if(val !='')
        {
            var action= component.get("c.sendMailMethod");
            action.setParams({
                'caseId':component.get("v.recordId"),
                'body':component.get("v.textt"),
                'partialcompleted':component.get("v.isPartialTaskCompleted"),
                'fullCompleted':component.get("v.isFullTaskCompleted")
            });
            action.setCallback(this, function(response) {
                var r= response.getReturnValue();
                if(r=='UserExisting')
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:$A.get("$Label.c.AGN_GDPR_ComUserExist"),
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();    
                }
                    else if (r=='UserCreated')
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Success',
                            message:$A.get("$Label.c.AGN_GDPR_CommUserCreated"),
                            messageTemplate: 'Record {0} created! See it {1}!',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'success',
                            mode: 'pester'
                        });
                        toastEvent.fire();   
                        $A.get("e.force:closeQuickAction").fire() ; 
                        $A.get('e.force:refreshView').fire();  
                    }
                        else if(r=='UserActivated')
                        {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Info Message',
                                message: $A.get("$Label.c.AGN_GDPR_UserActivated"),
                                messageTemplate: 'Record {0} created! See it {1}!',
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'info',
                                mode: 'dismissible'
                            });
                            toastEvent.fire();  
                        }
                            else
                            {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : 'Info Message',
                                    message: $A.get("$Label.c.AGN_GDPR_UserCannotCreated"),
                                    messageTemplate: 'Record {0} created! See it {1}!',
                                    duration:' 5000',
                                    key: 'info_alt',
                                    type: 'info',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire(); 
                            }                            
               
            }); 
            $A.enqueueAction(action); 
            
            setTimeout(function() {
               $A.get("e.force:closeQuickAction").fire() ; 
                $A.get('e.force:refreshView').fire();  
            }, 500);
           
       }      
    },
})