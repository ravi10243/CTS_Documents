({
	sendEmail : function(component, event, helper) {
        var allValid = component.find('messageForm').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        
        if(allValid){
            helper.sendEmailMessage(component, event, helper); 
        }
	},    
})