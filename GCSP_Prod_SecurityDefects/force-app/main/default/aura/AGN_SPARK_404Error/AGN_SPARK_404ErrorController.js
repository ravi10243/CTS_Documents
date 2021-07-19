({
	doInit : function(component, event, helper) {
       helper.getPageImages(component);
	},
    showKnowledgeHub : function(component, event, helper) {
       helper.navigateToPage('knowledge-hub');
	},
    showTraining : function(component, event, helper) {
       helper.navigateToPage('training');
	},
    showContactus : function(component, event, helper) {
       helper.navigateToPage('contactus');
	},
})