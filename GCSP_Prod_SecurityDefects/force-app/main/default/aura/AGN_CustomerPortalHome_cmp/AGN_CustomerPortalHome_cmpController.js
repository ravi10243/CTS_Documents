({
    doInit: function(component, event, helper){
        helper.getcustomerAccountDetails(component,event);
        helper.registrationCompleted(component, event);
        helper.getADOktaSSOUrl(component, event);
        //For ICL
        helper.isICLEnableForOAM(component, event);
        //Aritra
        var serverAction = component.get("c.isSiteUnderMaintenance");
        serverAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isSiteUnderMaintenance", response.getReturnValue()); 
            }
        });
        $A.enqueueAction(serverAction);
        //Aritra
    },
    
    goToADOktaSSOUrl: function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get("v.adOktaSSOUrl"),
            "target": "_blank"
        });
        urlEvent.fire();
    },
    goToCustomerUpdate: function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/customerupdate"
        });
        urlEvent.fire();
    },
    goToregisterationicl : function(component, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        /*var jsoncust = JSON.parse(JSON.stringify(component.get("v.customerAcc")));
        var jsonprim = JSON.parse(JSON.stringify(jsoncust["Primary_Parent_vod__r"]));
        if(jsonprim["Registered_For_Clinic_Locator_AGN__c"]){*/
            urlEvent.setParams({
                "url": "/agn-icl-cliniclistview"
            });
        /*}else{
            urlEvent.setParams({
                "url": "/registerationicl"
            });
        }*/
        
        urlEvent.fire();
    },
})