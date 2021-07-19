({
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