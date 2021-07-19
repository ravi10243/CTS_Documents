({
	doInit : function(component, event, helper) 
    {
        component.set('v.columns', [
            {label: 'Account Type', fieldName: 'Account_Type__c', type: 'text'},
            {label: 'Account Details', fieldName: 'Account_Details__c', type: 'text'},
            {label: 'Arrears Amount', fieldName: 'Arrears_Amount__c', type: 'currency', typeAttributes: { currencyCode: 'GBP', maximumSignificantDigits: 5}, cellAttributes: { alignment: 'left' }},
            {label: 'Full Min Due/CMP', fieldName: 'Full_Min_Due_CMP__c', type: 'currency', typeAttributes: { currencyCode: 'GBP', maximumSignificantDigits: 5}, cellAttributes: { alignment: 'left' }},
            {label: 'Due Date', fieldName: 'Due_Date__c' },
        ]);
        	var caseId = component.get("v.recordId");
            var CaseIDnew = component.get("v.parentId");
            
            var action = component.get("c.getProcessedCustomerData");
            
                action.setParams({
                    "recordID" : CaseIDnew
                });
            action.setCallback(this, function(response){
            var state = response.getState();
                if(state === "SUCCESS") 
                {
                    component.set("v.data", response.getReturnValue());
                }
                });
            $A.enqueueAction(action);
        
        
        /*
        var renderMode = component.get("v.renderMode");
        var elementWrapper = component.get("v.elementWrapper");
        var paramLangCode = elementWrapper.CurrentLanguageCode;
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
        $A.enqueueAction(actionTranslate); */
        
        
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