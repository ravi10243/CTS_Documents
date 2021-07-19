({
	 getGCSPSettingsDetails: function(component, event) {
        var action = component.get("c.getGCSPSettingsDetails");
       
         action.setCallback(this, function(response) {
            var state = response.getState();
             if (state === "SUCCESS") {                 
                 component.set('v.gcspSettings',response.getReturnValue());
                 
                 var BillToAddressSize = component.get("v.gcspSettings.Number_Of_BillTo_Allowed_AGN__c");                 
                 var billtoCount = parseInt(component.get("v.billToCount"));
                 if( parseInt(component.get("v.billToCount")) < parseInt(BillToAddressSize)){    //&& parseInt(BillToAddressSize)>1               
                     component.set('v.isBillToVisible', false);
                 }else if(component.get("v.billToSameAsSoldTo") && parseInt(component.get("v.billToCount")) == 1){
                     component.set('v.isBillToVisible', false);
                 }else{
                     component.set('v.isBillToVisible', true);
                 }
                 
                 var ShipToAddressSize = component.get("v.gcspSettings.Number_Of_ShipTo_Allowed_AGN__c");
                 
                 var shipToCount = parseInt(component.get("v.shipToCount"));
                 if( parseInt(component.get("v.shipToCount")) < parseInt(ShipToAddressSize)){
                    console.log('shipToCount');
                     component.set('v.isShipToVisible', false);
                 }else{
                     component.set('v.isShipToVisible', true);
                 }
                 
             }
         });
         $A.enqueueAction(action);
    },
})