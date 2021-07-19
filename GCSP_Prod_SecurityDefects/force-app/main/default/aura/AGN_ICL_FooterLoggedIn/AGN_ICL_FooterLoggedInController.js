({
	doInit : function(component, event, helper) {
        var today = new Date();
        component.set("v.currentyear", today.getFullYear());      
        var action4 = component.get("c.getPrivacyLinkLoggedUser");
        action4.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {                              
                var privacylink = response.getReturnValue();               
                component.set("v.privacyLink",privacylink);
            }
        });
        $A.enqueueAction(action4);
         //Vault Code Changes for LATAM
         var action5 = component.get("c.getVaultLoggedUser");
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
    },
    
    
})