({
	/*fetchAllPractioners : function(component, event, helper) {
       var action = component.get("c.fetchAllPractioners");
       var practitioners = component.get("v.practitioners");
         action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                practitioners = component.get("v.practitioners");
                component.set("v.practitioners", practitioners);
                alert('SUCCESS--fetchAllPractioners');
            }
        });
        $A.enqueueAction(action);
        
        var practitioner = event.getParam("practitioner");
        practitioners.push(practitioner);
        component.find("allPractId").set("v.practitioners",practitioners);

        }*/
    getCountryWiseField : function(component, event) {
        var action = component.get("c.getCountryWiseFieldList");
        /*action.setParams({
            'CountryCode': 'GB' 
            });*/
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                //console.log('CountryWiseFields list'+result);
                component.set("v.CountryWiseFieldList",result);
            }
        });
        $A.enqueueAction(action);
    },
    GetAllPractitionersOfLocatorListing : function(component, event) {
        var action = component.get("c.fetchAllPractioners");
        action.setParams({
            loclstId : component.get("v.LocatorListingId") 
            });
         action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.practitioners",response.getReturnValue());
                               
                console.log('First list '+component.get("v.practitioners"));
                //alert('fetchAllPractioners success'+response.getReturnValue());
            }
        });
         $A.enqueueAction(action);
    },
    deletePractitionerById : function(component, event) {
           var target = event.getSource();
           var txtVal = target.get("v.value") ;
           //alert('---'+txtVal);
           var practitionerList = component.get("v.practitioners");
        	//console.log('Practitioner list'+practitionerList[txtVal]);
        //console.log('Practitioner Id : '+practitionerList[txtVal].Id);
           var action = component.get("c.deltePractitionerById");
           /*action.setParams({listIndex:txtVal,
                             practitionerList:practitionerList
                            });*/
        	action.setParams({Practitioner : practitionerList[txtVal]});
           action.setCallback(this, function(response) {
               if(response.getReturnValue())
               {
                   this.GetAllPractitionersOfLocatorListing(component, event);
               }
               else
               {
                   this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
               }
           //component.set("v.practitioners",response.getReturnValue());
               //alert('SUCCESS');
        });
        $A.enqueueAction(action);
	},
    
    editPractitionerById : function(component, event) {
           var target = event.getSource();
           var txtVal = target.get("v.value") ;
           //alert('txtVal'+txtVal);
           var practitionerList = component.get("v.practitioners");
        //console.log('Single practt11'+practitionerList[txtVal]);
        component.set("v.practitioner",practitionerList[txtVal]);
           /*var action1 = component.get("c.fetchPractitionerToEdit");
           action1.setParams({listIndex:txtVal,
                             practitionerList:practitionerList
                            });
           action1.setCallback(this, function(response) {
               if(response.getState()=== "SUCCESS")
               component.set("v.practitioner",response.getReturnValue());
               //Get the event using event name. 
              var appEvent = $A.get("e.c:AGN_ICL_EditPractitioner"); 
        //Set event attribute value
        appEvent.setParams({"practitioner" : response.getReturnValue()}); 
        appEvent.fire(); 
               //var evt = component.getEvent("editPractitioner");
               //evt.setParam("practitioner",component.get("v.practitioner"));
               //evt.setParam("practitioner",response.getReturnValue());
               //evt.fire();
              // alert("Sucesss");
          });
         $A.enqueueAction(action1);*/
        
       /** var evt = component.getEvent("editPractitioner");
            evt.setParam("practitioner",component.get("v.practitioner"));
            evt.fire();**/
        //For Display Modal, Set the "openModal" attribute to "true"
        component.set("v.openModal", true);
    },
    showTosteMessage : function(component, title, type, message, mode) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent){
            toastEvent.setParams({
                title: title,
                type: type,
                message: message,
                mode: mode
            });
            toastEvent.fire();
        }
        // if not running in LEX or SF1, toast is not available - use alert
        else {
            alert(message);
        }
    }
})