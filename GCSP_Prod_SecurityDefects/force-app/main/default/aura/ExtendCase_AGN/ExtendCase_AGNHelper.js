({
	doInitHelper : function(component,helper)
    {
       // console.log('HELP MEE HELPER');
          var action = component.get("c.getTextValues");
        action.setParams({
            "caseId":component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var allValues = response.getReturnValue();
            console.log(allValues.provideReason);
            component.set('v.DSLanguage','Data Subject Language : '+allValues.DSLanguage);
            //console.log('Response ',allValues.response);
            
            if(allValues.response == 'statusError')
            {
                component.set('v.norender',true);
                component.set('v.render',false);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Case Cannot Be Extended for this Status',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire() ;  
                
            }
            
            else if(allValues.response == 'alreadyExtended')
            {
                component.set('v.norender',true);
                component.set('v.render',false);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Case Already Extended Once',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire(); 
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire() ;                  
            }
                else if(allValues.response == 'extend')
                {
                    component.set('v.norender',false);
                    component.set('v.render',true);
                    component.set("v.extensionReason",allValues.provideReason);   
                }
            
        });
        $A.enqueueAction(action);
	},
    extendCase : function(component,helper)
    {
         console.log('Reason-->',component.get("v.extensionReason"));
        
        if(component.get("v.extensionReason") != undefined)
        {
            var action = component.get("c.getextendCase");
            action.setParams({
                "caseId":component.get("v.recordId"),
                "text":component.get("v.extensionReason")
            });
            action.setCallback(this, function(response) {
                var allValues = response.getReturnValue();
                console.log('Response from Apex Controller '+allValues);
                if(allValues == true)
                {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Case Extended',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire() ;  
                    
                }
                else if(allValues == false)
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:'Extension Reason not provided',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire(); 
                }
                
                
            });
            $A.enqueueAction(action);
            
        }
        else if(component.get("v.extensionReason") == undefined)
        {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error Message',
                message:'Extension Reason not provided',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire(); 
        }   
    }
})