({
    doInit : function(component, event, helper) {
        helper.setDefaultStyles(component, helper);
    },
    showHelp : function(component, event, helper) {
        try { 
            $A.createComponent("c:F3_ModalHelp",  {
                "helpText": component.get("v.currentSitePage").DefaultPageForm.HelpText__c,
                "headerStyle" : component.get("v.headerStyle"),
                "headerTextStyle": component.get("v.portalStyle")
            }, 
            function(modalComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    //Appending the newly created component in div
                    var body = component.find('helpModal').get("v.body");
                    body.push(modalComponent);
                    component.find('helpModal').set("v.body", body);
                } 
                else if (status === "INCOMPLETE") {
                    console.log('Server issue or client is offline.');
                } 
                    else if (status === "ERROR")  {
                        console.log('error3');
                        console.log(errorMessage);
                    }
            });
        } catch (err) {
            console.log(err);
        }
    },
    accessibilityAction : function(component, event, helper) {
        try {
            switch(event.getParams().action) {
                case "decreaseFontSize" : 		helper.applyStyleAction(component, helper.decreaseFontSize); break;
                case "increaseFontSize" : 		helper.applyStyleAction(component, helper.increaseFontSize); break;
                case "increaseLetterSpacing" : 	helper.applyStyleAction(component, helper.increaseLetterSpacing); break;
                case "highContrastWhite" : 		helper.applyStyleAction(component, helper.highContrastWhite); break;   
                case "highContrastYellow" : 	helper.applyStyleAction(component, helper.highContrastYellow); break;
                case "reset" : 					helper.setDefaultStyles(component, helper); break;
                default : return;
            }            
        } catch (err) {
            console.error(err);
        }
        
    }
})