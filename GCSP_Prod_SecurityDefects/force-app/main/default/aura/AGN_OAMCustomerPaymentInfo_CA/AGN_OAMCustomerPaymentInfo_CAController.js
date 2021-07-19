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
        
        var selectedLanguage =  $A.get("$Locale.langLocale"); //Ex: 'en_CA' 
        var selectedLanguageVar = selectedLanguage.split('_');
        var userLanguage = "";
        if(selectedLanguageVar.length > 1){
            userLanguage = selectedLanguageVar[0];
        }
        //alert('>>>'+userLanguage);
        component.set("v.CurrentUserLanguage", userLanguage);
        
        helper.fetchPaymentSectionFields(component, event);
        helper.fetchCustomerDetails(component, event);
        //helper.fetchCustomerAddressDetails(component, event);
        
        var action = component.get("c.getPickListValues");      
        var columnName = 'Name,Form_Of_Payment_Label_AGN__c'
        var columnId='Id';
        var objectName='Form_Of_Payment_AGN__c';
        var country = component.get('v.countryCode');
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
            var countrycode = component.get("v.countryCode");
            var cGroup = component.get("v.customerGroup");
            var CGForPaymentinfo = $A.get("$Label.c.AGN_OAM_CG_PaymentInfoSection"); 
            var PmVal=[];    
            // alert('CountryCode>>'+ countrycode + ' >>>Cgroup>>>>'+ cGroup +'Pmethodval>>'+ JSON.stringify(paymentMethodVal) +'>>> Label>>>>'+$A.get("$Label.c.AGN_OAM_CreditCard"));
            if(!paymentMethodVal) return;
            if($A.util.isArray(paymentMethodVal)){
                for(var i in paymentMethodVal){
                    if(countrycode=='CA' && CGForPaymentinfo.includes(cGroup)){ //(cGroup =='HR'||cGroup =='HS')
                        if(paymentMethodVal[i].Name!= $A.get("$Label.c.AGN_OAM_CreditCard")){
                            PmVal.push(paymentMethodVal[i]);
                        }
                        
                    }else{ 
                        PmVal.push(paymentMethodVal[i]);
                    }                        
                }
            }
            //alert('pmval>>>>>>>>'+JSON.stringify(PmVal));        
            component.set("v.PaymentMethod", PmVal);                  
            
            // console.log('v.PaymentMethod===>'+JSON.stringify(component.get("v.PaymentMethod")));
        });       
        
        $A.enqueueAction(action); 
    },
    
    onChangePaymentMethod : function(component, event, helper){
        try{
            
            var pmethod = component.find("paymentMethod").get("v.value");
            
            var secVal = [];
            
            if($A.util.isEmpty(pmethod)){
                component.set('v.sectionPaymentCreditList',secVal); 
            }
            
            if(pmethod != null && pmethod != '' ){
                component.set("v.isPaymentTerm", false);
                var action = component.get("c.getPickListValues");
                var pmethodvalue = "'" + pmethod + "'";
                
                console.log('pmethodvalue-->'+pmethodvalue);
                
                var columnName='Name,Payment_Term_Label_AGN__c';
                var columnId='SAP_Payment_Term_Code_AGN__c';
                var objectName='Payment_Term_AGN__c';
                var whereCondition=' where Form_Of_Payment__r.Form_Of_Payment_Label_AGN__c='+pmethodvalue + 'OR Form_Of_Payment__r.Name='+pmethodvalue;
                
                action.setParams({
                    objectName : objectName,
                    columnName : columnName,  
                    columnId : columnId,              
                    whereCondition : whereCondition
                });        
                
                action.setCallback(this, function(a) {  
                    var paymentTermval = a.getReturnValue();
                    //component.set("v.PaymentTerm", a.getReturnValue()); 
                    //console.log('v.PaymentTerm===>'+JSON.stringify(a.getReturnValue()));
                    // alert('v.PaymentTerm===>'+JSON.stringify(a.getReturnValue()));    'Credit Card'
                    if(pmethod != $A.get("$Label.c.AGN_OAM_CreditCard")){                        
                        for(var i in paymentTermval){
                            component.set("v.PaymentTerm1", paymentTermval[i].Name);                           
                        } 
                        helper.onChangePaymentTerm(component, event, helper);
                    }else{
                        component.set("v.PaymentTerm", paymentTermval);
                    }
                    // alert(component.get("v.PaymentTerm1"));
                });        
                
                $A.enqueueAction(action);  
            }else{
                component.set("v.PaymentTerm", '');
                component.set("v.PaymentTerm1", '');
                component.set("v.isPaymentTerm", true);
            }
            
        }catch(err){
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