({
	doInit : function(component, event, helper) {
        helper.setDefaultStyles(component);
        try {
            
            let formSteps = component.get("v.listPageFormSteps");
            console.log(formSteps);
            let currentFormStepId = component.get("v.currentStepId");
            let currentFormStep = formSteps.find(step => step.PageFormStepId == currentFormStepId);
            if (currentFormStep) {
                component.set("v.currentLongName", currentFormStep.PortalLabel);
                try {
                    component.set("v.currentDescription", currentFormStep.Description);
                } catch (err) {
                    console.log(err);
                }
            }
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
                case "reset" : 					helper.setDefaultStyles(component); break;
                default : return;
            }            
        } catch (err) {
            console.error(err);
        }
        
    }
})