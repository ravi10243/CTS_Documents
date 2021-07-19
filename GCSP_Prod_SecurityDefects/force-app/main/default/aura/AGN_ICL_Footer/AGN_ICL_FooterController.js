({
	doInit : function(component, event, helper) {
        var today = new Date();
        component.set("v.currentyear", today.getFullYear());
        var pageReference = component.get("v.pageReference");
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            vars[key] = value;
        });
        component.set("v.countryCode",vars["country"]);
        if(vars["country"])
        {
            var action4 = component.get("c.getPrivacyLinkURL");
            action4.setParams({
                "countryCode": component.get("v.countryCode")
            });
            action4.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS') {
                    var privacylink = response.getReturnValue();               
                    component.set("v.privacyLink",privacylink);
                }
            });
            $A.enqueueAction(action4); 
            
            //Vault Code Changes for LATAM
             var action5 = component.get("c.getFooter");
            action5.setParams({
                "countryCode": component.get("v.countryCode")
            });
            action5.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS') {
                    var VaultCode = response.getReturnValue();               
                    component.set("v.VaultCode",VaultCode);
                }
            });
            $A.enqueueAction(action5); 
        }
        else if(vars["lcid"])
        {  
            var action3 = component.get("c.getPrivacyLinkURLFromLoc");
            action3.setParams({
                "LocId": vars["lcid"]
            });
            action3.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS') {
                    var privacylink = response.getReturnValue();               
                    component.set("v.privacyLink",privacylink);
                }
            });
            $A.enqueueAction(action3);  
            
                var action6 = component.get("c.getVaultFromLoc");
            action6.setParams({
                "LocId": vars["lcid"]
            });
            action6.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS') {
                    var VaultCode = response.getReturnValue();               
                    component.set("v.VaultCode",VaultCode);
                }
            });
            $A.enqueueAction(action6); 
        }
        
    },
})