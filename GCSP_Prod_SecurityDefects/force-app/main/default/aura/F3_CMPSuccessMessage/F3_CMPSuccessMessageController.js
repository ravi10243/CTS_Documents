({
	doInit : function(component, event, helper) {
    	var elementWrapperObject = component.get("v.elementWrapper");
        if(elementWrapperObject.PageFormComponentBrandingJSON != undefined && elementWrapperObject.PageFormComponentBrandingJSON.AreaKey == 'SuccessMessage'){
            var listComponentBranding = elementWrapperObject.PageFormComponentBrandingJSON.ListElement;
            var componentBranding;
            for(componentBranding in listComponentBranding){
            	var styleProperty;
                var styleProperties = listComponentBranding[componentBranding].ListProperty;
                for(styleProperty in styleProperties){
                    if(styleProperties[styleProperty].PropertyKey == 'font'){
                        component.set("v.headerFont",styleProperties[styleProperty].PropertyValue);
                    }
                    if(styleProperties[styleProperty].PropertyKey == 'font-style'){
                        component.set("v.headerFontStyle",styleProperties[styleProperty].PropertyValue);
                    }
                    if(styleProperties[styleProperty].PropertyKey == 'font-color'){
                        component.set("v.headerColor",styleProperties[styleProperty].PropertyValue);
                    }
                    if(styleProperties[styleProperty].PropertyKey == 'font-size'){
                        component.set("v.headerFontSize",styleProperties[styleProperty].PropertyValue);
                    }
                    if(styleProperties[styleProperty].PropertyKey == 'background-color') {
                        component.set("v.backgroundColor",styleProperties[styleProperty].PropertyValue);
                    }
                }
            }
            
        }
    },
})