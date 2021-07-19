({
	init : function(component, event, helper) {
        console.log('@@@Language>>>>>>>'+$A.get("$Locale.language"));
        component.set("v.language",$A.get("$Locale.language"));       
        
         var action = component.get("c.getContactDetails");
	    
    	action.setCallback(this, function(actionResult) {
        component.set("v.customer", actionResult.getReturnValue());            
            //console.log('Contact details--->'+JSON.stringify(component.get('v.customer')));
            
        var con = component.get('v.customer');
            var countryCode = '';
            if(con.Account.Country_Code__c == 'GB' && con.Account.SAP_Country_Code_AGN__c != null){
                countryCode = con.Account.SAP_Country_Code_AGN__c;
            }else{
                countryCode = con.Account.Country_Code__c;
            }
            //console.log('Cfgdetails--->'+countryCode+'>>CON>>'+JSON.stringify(con));
            
            var configAction = component.get("c.getCustomertypeConfigDetails"); 
            configAction.setParams({
                "countryCode": countryCode,
                "customerGroup": con.Account.SAP_Customer_Group_AGN__c,
                "custCategory": con.Account.Customer_Category_AGN__c,
                "subCategory": con.Account.Customer_Sub_Category_AGN__c
            });
            configAction.setCallback(this, function(response) {            
                var state = response.getState();
                console.log('config response--->'+state);           
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();  
                    console.log('config>>>>',JSON.stringify(storeResponse));
                    component.set("v.custConfig", storeResponse);
                }            
            });
            $A.enqueueAction(configAction);
        });
        $A.enqueueAction(action);
	} 
})