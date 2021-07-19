({
    fetchPaymentSectionFields : function(component, event) {
        
        var action = component.get('c.getLayout');   
        if(component.get("v.countryCode") === 'IT'){
            action.setParams({       
                'country': 'IT', //IT                 
                'stepNo': '4'            
            });       
        }
        else{
            action.setParams({       
                'country': component.get("v.countryCode"), //FR, DE            
                'stepNo': '4',
                'customerType': component.get("v.customerType"),
                'customerSubType': component.get("v.customerSubType"),
                'custTypeConfig': component.get("v.customerTypeConfig")
            });
        } 
        action.setStorable();
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                //var countrySettings = response.getReturnValue();
                //component.set('v.fieldMetadata', countrySettings);
                var settings = [];
                var settingsMap = response.getReturnValue();
                //console.log('@@@Step4Field>>>>'+JSON.stringify(settingsMap));
                for(var key in settingsMap){
                    settings.push({value:settingsMap[key], key:key});
                    
                }               
                component.set('v.sectionPaymentMap', settings);
                
                //console.log(JSON.stringify(component.get('v.sectionHeaderMap')));
            } else {
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCustomerDetails : function(component, event) {
        var action = component.get("c.getCustomerRegDetails");        
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {  
                var custReg = response.getReturnValue();             
                console.log('CRRecord>>>>>',custReg);
                component.set('v.customerGroup', custReg.Customer_Group_AGN__c);
                //  get Address  start // 
                var soldToAddr;        
                var action1 = component.get("c.getCustomerAddressDetails");
                 action1.setParams({
                	'custRegId': custReg.Id
           		 });
                action1.setCallback(this, function(response) {
                    var state1 = response.getState();                    
                    if (state1 === "SUCCESS") {
                        var addressList = response.getReturnValue();                 
                        if(addressList){
                            for(var i in addressList){
                                if(addressList[i].Sold_To_AGN__c){ //only 1 SoldTo Address will be present
                                    soldToAddr = addressList[i];
                                    break;
                                    console.log('CRARecord>>>>>',soldToAddr);
                                    
                                }
                            }
                            if(soldToAddr.Consent_For_Communication_AGN__c){
                                component.set("v.isConsentAccepted",true);
                            }
                        }
                        try{
                            var result = Object.assign({}, custReg, soldToAddr); //Merging registration and address data
                            // console.log('fetchCustomerAddressDetails---->'+ JSON.stringify(result));
                            component.set('v.objMixType', result);
                        }
                        catch(err)
                        {
                            var result = jQuery.extend({}, custReg, soldToAddr); //Merging registration and address data
                            //console.log('fetchCustomerAddressDetails---->'+ JSON.stringify(result));
                            component.set('v.objMixType', result);
                            console.error(err.message);
                        }
                    }
                });
                $A.enqueueAction(action1);
                //end get Address
                
            } else {
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);
    },    
   onChangePaymentTerm: function(component, event, helper){    
        var CG = component.get("v.customerGroup");        
        var pTerm = component.get("v.PaymentTerm1"); 
        var pMethod = component.get("v.PaymentMethod1");
        console.log('pTerm>>>>>'+pTerm);
        var secVal = [];           
            if(!$A.util.isEmpty(pTerm) && pTerm == $A.get("$Label.c.AGN_OAM_Payment_Time_of_Order")){                 
                component.set('v.sectionPaymentCreditList',secVal); 
            }
            if(!$A.util.isEmpty(pTerm) && pTerm != $A.get("$Label.c.AGN_OAM_Payment_Time_of_Order")){                
               component.set("v.sectionPaymentCreditList",component.get('v.sectionPaymentMap'));                 
            }
            if($A.util.isEmpty(pTerm)){
                component.set('v.sectionPaymentCreditList',secVal); 
            }
    },
    validateAndUpsert : function(component, event) {
        
        jQuery.noConflict();
        component.set("v.requireFieldMissing", false);
        component.set("v.fieldWellFormated", true);
        var requiredMissing = false;
        
        const cmpfield = component.find("fieldId");        
        const cmpSBS = [];        
        cmpSBS.push(cmpfield);
        
        var pmethod = component.find("paymentMethod").get("v.value");
        var paymentTerm = component.find("paymentTerm").get("v.value");
        if(component.get("v.isConsentAccepted")){
            component.set("v.objAGNCustReg.Consent_For_Communication_AGN__c" , true);
        }
        
        if($A.util.isEmpty(pmethod)){ 
            requiredMissing = true;
            component.set("v.required", true);
            component.set("v.fieldValueMissing", true);
            this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Required_Fields_Missing_Error"), 'dismissible');
        }else{
            component.set("v.required", false);
            component.set("v.fieldValueMissing", false);
        }
        console.log('PT Value>>>>>>>>>>>>>>>>>'+paymentTerm);
        if($A.util.isEmpty(paymentTerm)){           
            requiredMissing = true;
            component.set("v.required", true);
            component.set("v.PTfieldValueMissing", true);
            this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Required_Fields_Missing_Error"), 'dismissible');
        }else{
            component.set("v.required", false);
            component.set("v.PTfieldValueMissing", false);
            
        }
        
        /* if Payment term is "Payment at time of order" that time our functionality stop to with in if only. */
        
        if(component.get("v.countryCode") == 'CA' && paymentTerm == $A.get("$Label.c.AGN_OAM_Payment_Time_of_Order")){               
            var self = this; 
            var action = component.get("c.finishRegistration");        
            action.setParams({
                cust : component.get("v.objAGNCustReg"),
                custAddress : component.get("v.objAGNCustAddr"),
                formofPayment : pmethod,
                PaymentTerm : paymentTerm
            });
            
            action.setCallback(this, function(response) {
                //  console.log('response.getState() --' + response.getState() );            
                if(component.isValid() && response.getState() === 'SUCCESS') {
                    //   console.log('resp--' + response.getReturnValue());                
                    var notifyRegStepChange = component.getEvent("notifyRegStepChange");
                    notifyRegStepChange.setParams({"Operation": 'FINISH', "StepNo": '5'});
                    notifyRegStepChange.fire();                
                    
                }else{
                    self.logActionErrors(component, response);
                }
                
            }); 
            $A.enqueueAction(action);
            
        }else{        
            
            if (!cmpSBS) return;
            if ($A.util.isArray(cmpSBS)){
                cmpSBS.forEach( function (cmps){
                    cmps.forEach( function (cmp){
                        if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                            cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                            requiredMissing = true;
                        }
                        else{
                            cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                        }
                    });
                });
                
                if(requiredMissing){                    
                    component.set("v.requireFieldMissing",true);
                    console.log('requireFieldMissing');
                    this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Required_Fields_Missing_Error"), 'dismissible');
                }
                else{
                    this.validateFormatFields(component, event);
                }
            }
            
        }
        
    },
    validateFormatFields: function(component, event) {
        jQuery.noConflict();
        var wellFormatted = true;
        var whichFields = '';
        
        const cmpfield = component.find("fieldId");
        const cmpSBS = [];
        
        cmpSBS.push(cmpfield);
        
        
        if (!cmpSBS) return;
        if ($A.util.isArray(cmpSBS)){
            //console.log('cmpSBS inside loop== : '+cmpSBS.size());
            cmpSBS.forEach( function (cmps){
                cmps.forEach(function (cmp){
                    //if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && !$A.util.isEmpty(cmp.get("v.fieldValue")) ){
                    if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && jQuery.trim(cmp.get("v.fieldValue")) != ''){
                        if(!cmp.get("v.isFormatValid")){
                            //console.log('not formatted');
                            cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                            wellFormatted = false;
                            whichFields += cmp.get("v.customLabelName") + ", ";
                        }
                        else{
                            //console.log('formatted');
                            cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                        }
                    }                
                });
            }); 
            if(!wellFormatted){
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
                whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
            }
            else{
                //calling registration process	
                console.log("upsertCustomerDetails function");
                
                this.finishCustomerRegistration(component, event);  
                
            }  
        }
    },
    finishCustomerRegistration : function(component, event) {  
        console.log("Inside upsertRegistration For payment");
        
        var pmethod = component.find("paymentMethod").get("v.value");
        var PaymentTerm = component.find("paymentTerm").get("v.value");        
        
        const cmps = component.find("fieldId");  
        if(!cmps) return;
        if($A.util.isArray(cmps)){             
            cmps.forEach(function (cmp){
                if(cmp.get("v.sobjectName") === 'Allergan_Customer_Registration_AGN__c'){
                    var derivedField = 'v.objAGNCustReg.'+ cmp.get("v.fieldName");
                    component.set(derivedField, cmp.get("v.fieldValue"));              
                    
                }
                else if(cmp.get("v.sobjectName") === 'Allergan_Customer_Address_AGN__c'){
                    var derivedField = 'v.objAGNCustAddr.' + cmp.get("v.fieldName");
                    component.set(derivedField,cmp.get("v.fieldValue"));
                }
            });        
            
            //end forEach 
        }
        
        var self = this; 
        
        //console.log('customerReg = ' +JSON.stringify(component.get('v.objAGNCustReg')));  
        console.log('addressList = ' +JSON.stringify(component.get('v.objAGNCustAddr')));         
        
        var action = component.get("c.finishRegistration");        
        action.setParams({
            cust : component.get("v.objAGNCustReg"),
            custAddress : component.get("v.objAGNCustAddr"),
            formofPayment : pmethod,
            PaymentTerm : PaymentTerm
        });
        
        action.setCallback(this, function(response) {
            //  console.log('response.getState() --' + response.getState() );            
            if(component.isValid() && response.getState() === 'SUCCESS') {
                //   console.log('resp--' + response.getReturnValue());
                
                var notifyRegStepChange = component.getEvent("notifyRegStepChange");
                notifyRegStepChange.setParams({"Operation": 'FINISH',
                                               "StepNo": '5'}
                                             );
                notifyRegStepChange.fire();               
                
            }else{
                self.logActionErrors(component, response);
            }
            
        }); 
        $A.enqueueAction(action);
        
    },
    logActionErrors: function(component, response) {
        console.log(JSON.stringify(response, null, 2));
        
        var state = response.getState();
        var message = '';
        
        if (state === "INCOMPLETE") {
            message = "No Response From Server or Server could not be reached. Check your internet connection";
        } else
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    for (var i = 0; i < errors.length; i++) {
                        for (var j = 0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j];
                        }
                        if (errors[i].fieldErrors) {
                            for (var fieldError in errors[i].fieldErrors) {
                                var thisFieldError = errors[i].fieldErrors[fieldError];
                                for (var j = 0; j < thisFieldError.length; j++) {
                                    message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                                }
                            }
                        }
                        if (errors[i].message) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].message;
                        }
                    }
                } else {
                    message = "Unknown Error";
                }
            } else {
                message = "Unknown Status Error: " + state;
            }
        
        console.log('ERROR = ' + JSON.stringify(message, null, 2));
        this.showTosteMessage(component, '', 'error', message, 'sticky');
    },
    showTosteMessage: function(component, title, type, message, mode) {
        var toastEvent = $A.get("e.force:showToast");
        
        if (toastEvent) {
            
            toastEvent.setParams({
                title: title,
                type: type,
                message: message,
                mode: mode
            });
            
            toastEvent.fire();
        }
        // if not running in LEX or SF1, toast is not available - use alert
        else {
            alert(title + ': ' + message);
        }
    },
    callServerAction: function(component, actionName, params){
        var helper = this;       
        var p = new Promise(function(resolve, reject) {
            var action = component.get(actionName);
            
            if ( params ) {
                action.setParams(params);
            }
            action.setCallback(helper, function(resp){
                if(component.isValid() && resp.getState() === 'Success'){
                    // console.log('resp-->'+resp);
                    resolve(resp.getReturnValue());
                }else{
                    reject(resp);
                }
            }); 
            $A.enqueueAction(action); 
        });
        return p;
        
    }
})