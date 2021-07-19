({
    doInit: function(component,event,helper) {
         var query = location.search.substr(1);
		query.split("&").forEach(function(part) {
		var item = part.split("=");
		 if(item[0] === 'lcid')
            {
                component.set("v.LocatorListingId",decodeURIComponent(item[1]));
            }
		   });     
    },
	sendEmailToContact : function(component, event, helper) {
	var action = component.get("c.sendEmailToContactMethod");
        console.log(component.get("v.searchEmail"));
			//Set parameter values
			action.setParams({
				"emailtocontact" : component.get("v.searchEmail"),
                "loclstId" : component.get("v.LocatorListingId")
			});
        	$A.enqueueAction(action);
			action.setCallback(this, function(response) {
				var state = response.getState();				
				if (component.isValid() && state === "SUCCESS") {
					var isEmailfound = response.getReturnValue();
					//console.log('isEmailfound'+ isEmailfound);
                    if(isEmailfound == false){
                        helper.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_ICL_Practitioner_do_not_exisit"), 'dismissible');
                        //component.set("v.notify", "Submitted practitioner email did not exist");
                        
                    }
                    else{
                        //component.set("v.notify", "Email Sent Successfully");
                        helper.showTosteMessage(component, '', 'success',$A.get("$Label.c.AGN_ICL_Opt_Out_Email_Sent_Successfully"), 'dismissible');
                    }
                    
				}else{
					helper.showTosteMessage(component, '', 'success', $A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
                   // component.set("v.error", "unknown error");
				}
			});
        
}
})