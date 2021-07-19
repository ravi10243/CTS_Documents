({
	 getCustomerAccountDetails : function(component, event) {
          var action = component.get('c.getAccountICLDetails');
         
          action.setStorable();
          action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var customerAcc = response.getReturnValue();
                 component.set("v.customerAcc",customerAcc);
                var clinictype = component.get("v.customerAcc").Customer_Category_AGN__c;
                var iclenabled = component.get("v.customerAcc").IsICLEnabled_AGN__c;
                component.set("v.isICLEnabledInAccount",iclenabled);
                if(clinictype.includes("Clinic") || clinictype.includes("clinic"))
                {
                    component.set("v.isClinic",true);
                }
            }
        });
        $A.enqueueAction(action);
     },
    getOAMEnabled : function(component, event) {
         var action = component.get('c.isICLEnabled');
         
          action.setStorable();
          action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                component.set("v.isICLEnabled", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    getOAMMenuEnabled : function(component, event) {
         var action = component.get('c.isICLMenuEnabled');
         
          action.setStorable();
          action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                component.set("v.isICLMenuEnabled", response.getReturnValue());
                if(component.get("v.isICLMenuEnabled"))
                {
                    this.getCustomerAccountDetails(component, event);
                    this.getOAMEnabled(component, event);
                }
            }
        });
        $A.enqueueAction(action);
    }
})