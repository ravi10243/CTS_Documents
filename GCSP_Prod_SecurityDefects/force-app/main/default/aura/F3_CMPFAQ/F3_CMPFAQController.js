({
    doInit : function (component, event, helper) {
    	helper.setDefaultStyles(component);
	},
	getElementJSON: function(component, event){
         var formfield = component.get("v.formfield");
         var elementJSON = new Object();
         elementJSON.ElementType = formfield.ShGl_LEXElementType__c;
         elementJSON.ElementDeveloperName = formfield.DeveloperName;
         elementJSON.VisibilityState = formfield.class;
         elementJSON.PortalLabel = formfield.ShGl_LEXPortalLabel__c;
         elementJSON.HtmlorText = formfield.ShGl_LEXTextHTML__c;
         elementJSON.ElementValue = '';
         
         return elementJSON;
    },
    accessibilityAction : function(component, event, helper) {
        //alert('access ' + event.getParams().action);
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