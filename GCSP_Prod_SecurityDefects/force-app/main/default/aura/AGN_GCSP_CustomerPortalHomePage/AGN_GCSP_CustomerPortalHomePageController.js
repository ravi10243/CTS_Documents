({
    doInit: function(component, event, helper){
        //helper.getcustomerAccountDetails(component,event);
        //helper.registrationCompleted(component, event);
        helper.getCommunityUrl(component, event);
        helper.getADOktaSSOUrl(component, event);
        //For ICL
       // helper.isICLEnableForOAM(component, event);
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
   
})