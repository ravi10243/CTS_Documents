({
    
    scriptsLoaded : function(component, event, helper) {
        
        console.log('javaScript files loaded successfully') 
        
        jQuery.noConflict();
        
    },
    doneRendering : function(component,event, helper){
        
        //console.log("doneRendering");
        jQuery.noConflict();
        
        jQuery('.input-identifier').each(function(){
            if( jQuery(this).attr("data-inputfiedlvalue") == 'null'|| jQuery.trim(jQuery(this).attr("data-inputfiedlvalue"))==''){
                jQuery(this).find('label').find('span').removeClass("inputHasValue");
            }
            else{
                jQuery(this).find('label').find('span').addClass("inputHasValue");
            }
        });
    },
    
    doInit : function(component, event, helper) { 
        
        helper.fetchPaymentSectionFields(component, event);
        helper.fetchCustomerDetails(component, event);
        //helper.fetchCustomerAddressDetails(component, event);
        
        var country = component.get("v.SAPCountryCode");
        if($A.util.isEmpty(country)){
            country = component.get("v.countryCode");
        }
        
        var action = component.get("c.getPickListValues");      
        var columnName = 'Name,Form_Of_Payment_Label_AGN__c'
        var columnId='Id';
        var objectName='Form_Of_Payment_AGN__c';
        var countryCode = "'" + country + "'";
        var whereCondition=' where SAP_Country_Code_AGN__c='+countryCode+' AND Active_AGN__c= true';
        
        //action.setStorable();        
        action.setParams({
            objectName : objectName,
            columnName : columnName,
            columnId : columnId,
            whereCondition: whereCondition
        });
        
        action.setCallback(this, function(actionResult) {
           // component.set("v.PaymentMethod", actionResult.getReturnValue());
            var paymentMethodVal = actionResult.getReturnValue();            
            var PmVal=[];
            if(!paymentMethodVal) return;
            if($A.util.isArray(paymentMethodVal)){
                for(var i in paymentMethodVal){                 
                    PmVal.push(paymentMethodVal[i]);                                            
                }
            }
            
            component.set("v.PaymentMethod", PmVal);                  
            
             console.log('v.PaymentMethod===>'+JSON.stringify(component.get("v.PaymentMethod")));
        });       
        
        $A.enqueueAction(action); 
    },
    
    onChangePaymentMethod : function(component, event, helper){
        component.set("v.showSpinner", true);
        try{
            
            var pmethod = component.find("paymentMethod").get("v.value");
            
            if(pmethod != null && pmethod != '' ){
                component.set("v.isPaymentTerm", false);
                var action = component.get("c.getPickListValues");
                var pmethodvalue = "'" + pmethod + "'";
                
                console.log('pmethodvalue-->'+pmethodvalue);
                
                var columnName='Id,Name,Payment_Term_Label_AGN__c';
                var columnId='SAP_Payment_Term_Code_AGN__c';
                var objectName='Payment_Term_AGN__c';
                var whereCondition=' where Form_Of_Payment__c='+pmethodvalue;
                
                action.setParams({
                    objectName : objectName,
                    columnName : columnName,  
                    columnId : columnId,              
                    whereCondition : whereCondition
                });        
                
                action.setCallback(this, function(a) {  
                    var paymentTermval = a.getReturnValue();                  
                    component.set("v.PaymentTerm", paymentTermval);
                });        
                
                $A.enqueueAction(action);  
            }else{
                component.set("v.PaymentTerm", '');
                component.set("v.PaymentTerm1", '');
                component.set("v.isPaymentTerm", true);
            }
            helper.onChangePaymentTerm(component, event, helper);
             component.set("v.showSpinner", false); 
        }catch(err){
           component.set("v.showSpinner", false); 
            console.log('err'+err.message);
            
        }
       
    },
    onChangePaymentTerm: function(component, event, helper){
        
        helper.onChangePaymentTerm(component, event, helper);
        
    },
    
    finishRegistrationForCust : function(component, event, helper){
        
        helper.validateAndUpsert(component, event);
    },
})