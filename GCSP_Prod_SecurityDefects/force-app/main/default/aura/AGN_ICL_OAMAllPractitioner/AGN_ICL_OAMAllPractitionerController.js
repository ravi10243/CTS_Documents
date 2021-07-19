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
         helper.GetAllPractitionersOfLocatorListing(component,event);
         helper.getCountryWiseField(component,event);
     },
    RefreshPractitionerList : function(component,event,helper){
        helper.GetAllPractitionersOfLocatorListing(component,event);
         /*var action = component.get("c.fetchAllPractioners");
         action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.practitioners",response.getReturnValue());
                //alert('fetchAllPractioners success'+response.getReturnValue());
            }
        });
         $A.enqueueAction(action);*/
    },
    deletePractitioner: function(component,event,helper){                 
        if(confirm('Are you sure?'))
    	helper.deletePractitionerById(component,event);        
    },
    addPractitioner : function(component,event,helper){
        //jQuery.noConflict();
        //jQuery('.AddNewPractitioner').fadeIn('fast'); 
        console.log('dfdhfdhf');
        component.set("v.openaddModal",true);
    },
    HandlePopup : function(component,event,helper){
        component.set("v.openaddModal",false);
    },
    editPractitioner: function(component,event,helper){ 
    	helper.editPractitionerById(component,event);        
    },
     handleOpenModal: function(component, event, helper) {
        //For Display Modal, Set the "openModal" attribute to "true"
        component.set("v.openModal", true);
    },
    handleCloseModal: function(component, event, helper) {
        //For Close Modal, Set the "openModal" attribute to "fasle"  
        component.set("v.openModal", false);
    },
    HandleEditPopup: function(component, event, helper) {
        helper.GetAllPractitionersOfLocatorListing(component,event);
        component.set("v.openModal", false);
    },
    updatePractitioner: function(component, event, helper) {
        alert('update');
        var editablePractId = component.find('editablePractId');
        alert('editablePractId'+editablePractId);
        var fName= editablePractId.get('v.practitioner.First_Name_AGN__c');
        alert('fName'+fName);
    }
})