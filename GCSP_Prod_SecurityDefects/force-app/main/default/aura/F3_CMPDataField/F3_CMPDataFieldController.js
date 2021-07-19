({
    doInit : function(component, event, helper) {
        try {
            helper.setDefaultStyle(component);
            const elementWrapper = component.get("v.elementWrapper");
            const isHidden = elementWrapper.PageElement.IsHidden__c;
            const readOnly = elementWrapper.PageElement.ReadOnly__c;
            console.log('elementWrapper--->'+elementWrapper);
            console.log(isHidden);
            if(isHidden || readOnly) {
                component.set("v.inputValue", elementWrapper.DefaultValue);
                if(isHidden) {
                    component.set("v.componentBodyStyle", "height: 0;");
                } 
            }
        } catch (err) {
            console.log(err);
        }
    },
	isValid: function(component, event){
        var params = event.getParam('arguments');
        if(params)
        {
            var isSuccess = params.isSuccess;
            var componentWrapperElement = component.get("v.elementWrapper.PageElement");
            var isRequired = componentWrapperElement.Required__c;
            var fieldValue = component.get("v.fieldValue");
            console.log('cmp name ' + fieldValue);
            //Experian changes
            var urlKey = component.get("v.currentSitePage.urlKey");
            if(urlKey === 'ccpa' && component.get("v.elementWrapper.PageElement").DataFieldAPIName__c === 'Data_Subject_Phone_GDPR_AGN__c'){
                if(isRequired){
                    console.log('fieldValue ' + fieldValue);
                    if(!fieldValue || !fieldValue.match(/^\d{10}$/)){
                        /*var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Error in ' + component.get("v.elementWrapper.PageElement").PortalLabel__c + ' format',
                            message: 'Please Enter 10 Numeric Digits Only!',
                            type: 'error',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                        */
                        component.set("v.componentClass", 'slds-form-element slds-has-error slds-noshadow');
                        return isSuccess;
                    }
                }
            }
            else if(!fieldValue && isRequired)
            {
                component.set("v.componentClass", 'slds-form-element slds-has-error slds-noshadow');
                return isSuccess;
            }
            //Experian changes
            /*if(!fieldValue && isRequired) //Experian changes
            {
                component.set("v.componentClass", 'slds-form-element slds-has-error slds-noshadow');
                return isSuccess;
            }*/
            
            isSuccess = true;
            return isSuccess;
        } 
    },
    dataFieldOnChange: function(component, event, helper) {
        
        var fieldvalue = event.getSource().get("v.value");
        console.log('fieldvalue---->'+fieldvalue);
        component.set("v.fieldValue", fieldvalue);
        if(fieldvalue == true ){ fieldvalue = 'true';}
        if(fieldvalue == false){fieldvalue = 'false';}
        var componentWrapperElement = component.get("v.elementWrapper.PageElement");
        
        var isRequired = componentWrapperElement.Required__c;
        
        if(isRequired && !fieldvalue)
        {
            component.set("v.componentClass", "slds-form-element slds-has-error slds-noshadow");
        }
        else
        {
            component.set("v.componentClass", "slds-form-element");
        }
                
        var fielddependent = component.get("v.elementWrapper.OnChangeViewState");
        //console.log('Onchange of Field--OnChangeViewState-'+fielddependent);
       
        if(fielddependent)
        {
            var parsedJSONList = JSON.parse(fielddependent);
            //console.log('parsedJSONList--->'+parsedJSONList);
            if(parsedJSONList)
            {
                for(var i=0;i<parsedJSONList.length;i++)
                {
                    var str = parsedJSONList[i].FieldValue;
                    var result = false;
                    //console.log('1 parsedJSONList[i].FieldValue--'+parsedJSONList[i].FieldValue + ' ' + fieldvalue);
                    if (typeof str === "string"){
                        
						console.log('if parsedJSONList[i].FieldValue--'+parsedJSONList[i].FieldValue + ' ' + !parsedJSONList[i].FieldValue.startsWith("!"));
                        if((!parsedJSONList[i].FieldValue.startsWith("!") && parsedJSONList[i].FieldValue == fieldvalue) || 
                           (parsedJSONList[i].FieldValue.startsWith("!") && fieldvalue && parsedJSONList[i].FieldValue.slice(1)!=fieldvalue))
                        {
                            result = true;  
                        }
                    }
                    
                    else{
                        //console.log(' else parsedJSONList[i].FieldValue--'+parsedJSONList[i].FieldValue + ' ' + fieldvalue);
                        if(parsedJSONList[i].FieldValue==fieldvalue)
                        { 
                            console.log('Setting visibility for other than string changes--'+ parsedJSONList[i].FieldValue + ' changed value--' + fieldvalue);
                            result = true;    
                        }
                    }
                    //alert(result);
                    if(result){
                        var compEvent = component.getEvent("fielddependentevent");
                        compEvent.setParams({"param" : parsedJSONList[i] });
                        compEvent.fire();
                    }
                    
                    try 
                    {                        
                        if(parsedJSONList[i].ValueToCheck && parsedJSONList[i].Operator){
                            var value = JSON.stringify(parsedJSONList[i].ValueToCheck);
                            var operator = parsedJSONList[i].Operator;
                            if(fieldvalue)
                            {
                            	fieldvalue = parseInt(fieldvalue);
                            }
                            if(eval(fieldvalue + operator + value))
                            {     
                                var compEvent = component.getEvent("fielddependentevent");
                                compEvent.setParams({"param" : parsedJSONList[i] });
                                compEvent.fire();
                            }                                                                
                        }
                    }
                    catch(err)
                    {
                        console.log('>>>err'+err.message);
                    }
                }
            }
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
                case "reset" : 					helper.setDefaultStyle(component); break;
                default : return;
            }            
        } catch (err) {
            console.error(err);
        }
        
    }
})