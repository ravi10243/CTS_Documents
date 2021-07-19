({
    doInit : function(component, event, helper) 
    {
        var renderMode = component.get("v.renderMode");
        var elementWrapper = component.get("v.elementWrapper");
        
        var paramLangCode;
        if(elementWrapper != null & elementWrapper != undefined){
        	paramLangCode = elementWrapper.CurrentLanguageCode;
       
            
            if(paramLangCode == undefined){
                paramLangCode = 'enGB'
            };
            var elementId = elementWrapper.PageElement.Id;
            var actionTranslate = component.get("c.GetPicklistOptions");
            actionTranslate.setParams({
                elementId : elementId,
                langCode : paramLangCode
            });
            actionTranslate.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS") 
                {
                    component.set("v.translatedOptions", response.getReturnValue());
                    //alert('hhhh--'+component.find("hiddenPickList").get("v.value"));
                }
            });
        	$A.enqueueAction(actionTranslate);
        }
    },
    
    onRadioChange : function(component, event, helper){
        
        component.find("hiddenPickList").set("v.value",event.getSource().get("v.value"));
        
    },
    onPickChange : function(component, event, helper) {
        try {
            const pickedValue = component.find("visiblePickList").get("v.value");
            component.find("hiddenPickList").set("v.value", pickedValue);
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