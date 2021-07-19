({
    doInit: function(component, event, helper){
        helper.getcustomerAccountDetails(component,event); //ICL
        helper.registrationCompleted(component, event);
        helper.getADOktaSSOUrl(component, event);
        //For ICL
        //helper.isICLEnableForOAM(component, event);
        //helper.isICLCustomercategory(component, event);
        //TM2.0 Portal banner related change//
        var serverAction = component.get("c.isSiteUnderMaintenance");
        serverAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isSiteUnderMaintenance", response.getReturnValue()); 
            }
        });
        $A.enqueueAction(serverAction);
        //TM2.0 Portal banner related change//
    },
    
    goToADOktaSSOUrl: function(component, event, helper){
        console.log('component.get("v.adOktaSSOUrl")' + component.get("v.adOktaSSOUrl"));
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
        if(jsonprim["Registered_For_Clinic_Locator_AGN__c"]){
            urlEvent.setParams({
                "url": "/agn-icl-message"
            });
        }else{*/
            urlEvent.setParams({
                "url": "/agn-icl-cliniclistview"
            });
        //}
        
        urlEvent.fire();
    },
})