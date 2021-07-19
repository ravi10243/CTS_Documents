({
    doInit : function(component, event, helper) {
        var Id = component.get("v.recordId");
        var action1 = component.get("c.ValidateCaseDetails");
        
        action1.setParams({"caseId": component.get("v.recordId")});
        
        action1.setCallback(this, function(response) {
            var state = response.getState();
            var res =JSON.stringify(response.getReturnValue());
            console.log('Reqt Type'+JSON.parse(res)[0].Request_Type_GDPR_AGN__c.includes(';'));
            
            if(JSON.parse(res)[0].Status=='Under Review' && JSON.parse(res)[0].Split_Case_AGN__c ==false)
            {
                if(JSON.parse(res)[0].Request_Type_GDPR_AGN__c.includes(';') == false)
                {
                    console.log('HII');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:$A.get("$Label.c.AGN_GDPR_SingleReqCase"),
                        messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();    
                }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message:$A.get("$Label.c.AGN_GDPR_Case_Splitted"),
                        messageTemplate: 'Record {0} created! See it {1}!',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire(); 
                }
            }
            else if(JSON.parse(res)[0].Split_Case_AGN__c ==true )
            {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:$A.get("$Label.c.AGN_GDPR_Already_Splitted"),
                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();    
            }
                else if(JSON.parse(res)[0].Status!='Under Review' && JSON.parse(res)[0].Split_Case_AGN__c ==false)
                {
                    if(JSON.parse(res)[0].Request_Type_GDPR_AGN__c.includes(';') == false)
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error Message',
                            message:$A.get("$Label.c.AGN_GDPR_SingleReqCase"),
                            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();    
                    }
                    else
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Info Message',
                            message:$A.get("$Label.c.AGN_GDPR_Case_Split_for_Under_Review"),
                            messageTemplate: 'Record {0} created! See it {1}!',
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'info',
                            mode: 'dismissible'
                        });
                        toastEvent.fire(); 
                    }
                }
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();  
        });
        
        
        $A.enqueueAction(action1);
        
    }
})