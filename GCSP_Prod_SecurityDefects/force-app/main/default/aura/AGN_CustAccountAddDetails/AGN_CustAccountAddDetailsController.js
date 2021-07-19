({
	init : function(component, event, helper) {
        
        var action = component.get("c.getAddressDetails");
        var shipToCount = 0;
        var billToCount = 0;
        action.setCallback(this, function(actionResult) {
            var address = actionResult.getReturnValue();            
            var i = 0;
			while (i < address.length) {  
                
                if(address[i].accountAddress.Account_vod__r.SAP_Sold_To_AGN__c && address[i].accountType == 'ShipTo'){//address[i].accountAddress.Account_vod__r.SAP_Ship_To_AGN__c){
                    component.set("v.shipToSameAsSoldTo", true);
                }
                if(address[i].accountAddress.Account_vod__r.SAP_Sold_To_AGN__c && address[i].accountType == 'BillTo'){//address[i].accountAddress.Account_vod__r.SAP_Bill_To_AGN__c){
                    component.set("v.billToSameAsSoldTo",true);
                }
                if(address[i].accountType == 'ShipTo'){
                    shipToCount++;
                   
                }
                if(address[i].accountType == 'BillTo'){
                    billToCount++;
                }
                i++;
            }             
        	component.set("v.addresses", actionResult.getReturnValue());
            component.set("v.shipToCount", shipToCount);
            component.set("v.billToCount", billToCount);
            
            helper.getGCSPSettingsDetails(component, event);
        });
        $A.enqueueAction(action);
        
       
	},
    
    gotoURL : function (component, event, helper) {
        var address = event.target.dataset.address;
        var type = event.target.dataset.type;
        var activity = event.target.dataset.activity;
            
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/customer-update?type=" + type + "&addressId=" + address+ "&activity="+ activity
        });
        urlEvent.fire();
    },
    
    newShipTo : function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");          
        urlEvent.setParams({
            "url": "/customer-update?type=ShipTo&activity=new"
        });        
        urlEvent.fire();
    },
    
    newBillTo : function (component, event, helper) {              
        var urlEvent = $A.get("e.force:navigateToURL");              
        urlEvent.setParams({
            "url": "/customer-update?type=BillTo&activity=new"
        });             
        urlEvent.fire();
    },
    
    scriptsLoaded : function(component, event, helper) {
		/*jQuery.noConflict();
        
        jQuery('#carousel').elastislide( {
				minItems : 2
		} );
		
        jQuery('#carousel1').elastislide( {
				minItems : 2
		} );*/
        
		console.log('javaScript files loaded successful'); 
	}
})