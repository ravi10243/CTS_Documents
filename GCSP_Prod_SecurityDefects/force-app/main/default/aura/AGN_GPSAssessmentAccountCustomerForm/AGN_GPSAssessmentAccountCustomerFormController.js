({
	doInit : function(component, event, helper) {
        console.log('start');
        helper.fetchAssessmentAccountCustomerRecord(component, event, helper);
	},
    save : function(component, event, helper){
        console.log('save');
		helper.save(component,event,helper);
    },
    addCustomer : function(component, event, helper){
        console.log('addCustomer');
		helper.addCustomers(component,event,helper);
        component.set("v.isOpen", true);
    },
    closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
      component.set("v.isOpen", false);
    },
    createAccountCustomers : function(component, event, helper) {
        console.log('startcreate');
        var elements = document.getElementsByName('checkbox');
        var customerIds = [];
        for(var i = 0; i < elements.length; i++) {
            if(elements.item(i).checked === false) continue;

            customerIds.push(elements.item(i).dataset.customerid);
        }
    	helper.createAccountCustomers(component, event, customerIds);
        helper.fetchAssessmentAccountCustomerRecord(component, event, helper);
        component.set("v.isOpen", false);
    },
    deleteAccountCustomerAssessment : function(component, event, helper) {
        console.log("id:" + event.target.id);
        helper.deleteAccountCustomerAssessment(component, event);
    },
    
    //PMO 3408: GPS Enhancement: Start: Toggle columns
    toggleBusinessSize : function(component, event, helper) {
        component.set('v.showBusinessSize', !component.get('v.showBusinessSize'));
    },
    toggleAGNShare : function(component, event, helper) {
        component.set('v.showAGNShare', !component.get('v.showAGNShare'));
    },
    toggleCustomQuestions : function(component, event, helper) {
        component.set('v.showCustomQuestions', !component.get('v.showCustomQuestions'));
    },
    //PMO 3408: GPS Enhancement: Start: Toggle columns
})