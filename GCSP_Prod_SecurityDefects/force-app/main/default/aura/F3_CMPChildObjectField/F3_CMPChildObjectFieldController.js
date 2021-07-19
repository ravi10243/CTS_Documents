({
	isValid: function(component, event){
        var params = event.getParam('arguments');
        if(params)
        {
            var isSuccess = params.isSuccess;
            var formfield = component.get("v.elementWrapper");
            var isRequired = formfield.Required;
            var fieldValue = component.get("v.fieldValue");
            
            var limitCrossed = false;
            
            if(formfield.MaxLength && fieldValue && fieldValue.length > formfield.MaxLength){
                limitCrossed = true
            }
            
            if(!fieldValue && (isRequired == 'True' || isRequired == 'true' || isRequired == true))
            {
                component.set("v.componentClass", 'slds-form-element slds-has-error');
                return isSuccess;
            }       
            else if(limitCrossed)
            {
                component.set("v.componentClass", 'slds-form-element slds-has-error');
                //component.set("v.errorMessage", 'Data value too large');
                return isSuccess;
            }
            
            isSuccess = true;
            return isSuccess; 
        } 
    },
    dataFieldOnChange : function(component, event, helper) 
    {
        var fieldvalue = event.getSource().get("v.value");
        component.set("v.fieldValue", fieldvalue);
		var isRequired = component.get("v.formfield.Required");
        if(isRequired && !fieldvalue)
        {
            component.set("v.componentClass", "slds-form-element slds-has-error");
        }
        else
        {
            component.set("v.componentClass", "slds-form-element");
        }        
    }
})