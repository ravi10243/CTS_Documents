({
	init : function(component, event, helper) {
        
        var action = component.get("c.getContactDetails");
	    
    	action.setCallback(this, function(actionResult) {
        component.set("v.customer", actionResult.getReturnValue());   
            //console.log('Contact details--->'+JSON.stringify(component.get('v.customer')));
            
        });
        $A.enqueueAction(action); 
      /*
       * var accAction = component.get("c.getBussinessAccountDetails");	
            accAction.setParams({       
                'accId' : component.get("v.customer.AccountId")
            });            
            action.setCallback(this, function(ar) {
            component.set("v.bzAcc", ar.getReturnValue());   
                console.log('Account details--->'+JSON.stringify(component.get('v.bzAcc')));
                //console.log('Account--->'+JSON.stringify(component.get('v.customer.Country_vod__r.AGN_Country_Name__c')));
            });
            $A.enqueueAction(accAction);
            //console.log('Account--->'+JSON.stringify(component.get('v.customer.Country_vod__r.AGN_Country_Name__c')));
         */        
      var country = component.get("c.getCountry");        
        country.setCallback(this, function(response) {            
            var state = response.getState();
            console.log('config response--->'+state);           
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();  
               // console.log(JSON.stringify(storeResponse));
                component.set("v.country", storeResponse);
            }            
        });
        $A.enqueueAction(country); 
	}
})