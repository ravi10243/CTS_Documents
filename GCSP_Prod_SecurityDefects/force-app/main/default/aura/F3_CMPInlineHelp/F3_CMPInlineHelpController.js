({
    doInit : function(component, event, helper) {
        var elementWrapperObject = component.get("v.elementWrapper");
        if(elementWrapperObject.PageFormComponentBrandingJSON != undefined && elementWrapperObject.PageFormComponentBrandingJSON.AreaKey == 'InlineHelp') {
            var listComponentBranding = elementWrapperObject.PageFormComponentBrandingJSON.ListElement;
            var componentBranding;
            for(componentBranding in listComponentBranding){
                var styleProperty;
                var styleProperties = listComponentBranding[componentBranding].ListProperty;
                for(styleProperty in styleProperties){
                    if(styleProperties[styleProperty].PropertyKey == 'font-style'){
                        component.set("v.fontStyle",styleProperties[styleProperty].PropertyValue);
                    }
                    if(styleProperties[styleProperty].PropertyKey == 'font-color'){
                        component.set("v.color",styleProperties[styleProperty].PropertyValue);
                    }
                    if(styleProperties[styleProperty].PropertyKey == 'font-size'){
                        component.set("v.fontSize",styleProperties[styleProperty].PropertyValue);
                    }
                    if(styleProperties[styleProperty].PropertyKey == 'background-color') {
                        component.set("v.backgroundColor",styleProperties[styleProperty].PropertyValue);
                    }
                }
            }
        }
        helper.setDefaultStyles(component);
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