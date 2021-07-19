({
    fetchPaymentSectionFields : function(component, event) {
        
        var country = component.get("v.SAPCountryCode");
        if($A.util.isEmpty(country)){
            country = component.get("v.countryCode");
        }
        
        var action = component.get('c.getLayout');   
        if(component.get("v.countryCode") === 'IT'){
            action.setParams({       
                'country': 'IT', //IT                 
                'stepNo': '4'            
            });       
        }
        else{
            action.setParams({       
                'country': country, //FR, DE, GB, IE, ES //v.countryCode v.SAPCountryCode (to fetch meta data configuration)            
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
                
               // console.log('@@@@@settingsMap-->'+JSON.stringify(settingsMap));                
                
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
                
                //console.log('Sobject-->'+JSON.stringify(custReg));                                                            
                
                //component.set('v.objMixType', custReg);
                
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
                                }
                            }
                        }
                        try{
                            var result = Object.assign({}, custReg, soldToAddr); //Merging registration and address data
                            //console.log('fetchCustomerAddressDetails---->'+ JSON.stringify(result));
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
    //  get Address  start // 
    fetchCustomerAddressDetails : function(component, event) {
        var soldToAddr;        
        var action = component.get("c.getCustomerAddressDetails");        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var addressList = response.getReturnValue();                 
                if(!addressList) return;
                if($A.util.isArray(addressList)){
                    for(var i in addressList){
                        
                        if(addressList[i].Sold_To_AGN__c){ //only 1 SoldTo Address will be present
                            soldToAddr = addressList[i];
                        }                        
                    }
                }
                component.set('v.objMixType', soldToAddr);
            }
        });
        $A.enqueueAction(action);
    },  
    
    onChangePaymentTerm: function(component, event, helper){
        //var pTerm = component.find("paymentTerm").get("v.value"); 
        var pTerm = component.get("v.PaymentTerm1"); 
        console.log('pTerm>>>>>'+pTerm);
        if(pTerm = 'CCNT' && component.get('v.countryCode') == 'IT' ){
            var sectionMap =  component.get('v.sectionPaymentMap');
            var listval;
            var secVal = [];
            
            for (var i in sectionMap) {                             
                listval = sectionMap[i].value; 
                for(var i in listval){                    
                    if(listval[i].SObject_Name_AGN__c != 'Allergan_Customer_Address_AGN__c'){
                        //console.log('listval[j]>>>'+ JSON.stringify(listval[i]));                      
                        secVal.push(listval[i]); //{value:listval[i], key:i}
                    }
                }
            }
            
           // console.log('listval[j]>>>'+ JSON.stringify(secVal));
            component.set('v.sectionPaymentCreditList',secVal);             
           // console.log('ptCreditcard1111111111>>>'+JSON.stringify(component.get('v.sectionPaymentCreditList')));
        }

        
    },
    
    //  get Address  end  // 
    validateAndUpsert : function(component, event) {
        
        jQuery.noConflict();
        component.set("v.requireFieldMissing", false);
        component.set("v.fieldWellFormated", true);
        var requiredMissing = false;
        
        const cmpfield = component.find("fieldId");        
        const cmpSBS = [];        
        cmpSBS.push(cmpfield);
        
        var pmethod = component.find("paymentMethod").get("v.value");
        var paymentTerm = component.get("v.PaymentTerm1"); //component.find("paymentTerm").get("v.value");
        
        if($A.util.isEmpty(pmethod)){ 
            requiredMissing = true;
            component.set("v.required", true);
            component.set("v.fieldValueMissing", true);
           
        }else{
            component.set("v.required", false);
            component.set("v.fieldValueMissing", false);
        }
         console.log('PT Value>>>>>>>>>>>>>>>>>'+paymentTerm);
        if($A.util.isEmpty(paymentTerm)){           
            requiredMissing = true;
            component.set("v.required", true);
            component.set("v.PTfieldValueMissing", true);
           
        }else{
            component.set("v.required", false);
            component.set("v.PTfieldValueMissing", false);
        }
        //console.log('cmpSBS'+JSON.stringify(cmpSBS));        
        if (!cmpSBS) return;
        if ($A.util.isArray(cmpSBS)){
            cmpSBS.forEach( function (cmps){
                cmps.forEach( function (cmp){
                    if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){                           
                            cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                            requiredMissing = true;
                            console.log('requireFieldMissing>>' + cmp.get("v.fieldName"));
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
            
            var self = this; 
            
           // console.log('customerReg = ' +JSON.stringify(component.get('v.objAGNCustReg')));  
           // console.log('addressList = ' +JSON.stringify(component.get('v.objAGNCustAddr'))); 
            
            var pmethod = component.find("paymentMethod").get("v.value");
            var PaymentTerm = component.get("v.PaymentTerm1");  //component.find("paymentTerm").get("v.value");
            //console.log('pmethod --' + pmethod );
            //component.set("v.objAGNCustReg.Form_of_Payment_AGN__r.Name",pmethod);
            //
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
                    
                    /*jQuery('.basic_detail .no_det span').hide();
                    jQuery( ".basic_detail .no_det" ).css("background", "#a3d233");
                    jQuery( ".basic_detail .no_det img.tick" ).show();
                    jQuery( '.cus_details').hide();
                    jQuery( ".add_det .no_det span" ).hide();
                    jQuery( ".add_det .no_det img.tick" ).show();
                    jQuery( ".add_det .no_det" ).css("background", "#a3d233");
                    jQuery( ".add_det .no_det" ).css("border", "2px solid #a3d233");
                    jQuery( ".add_det .divider" ).hide();
                    jQuery( ".add_det .infr_det" ).hide();
                    jQuery( ".upload_doc" ).css("margin-top", "30px");
                    jQuery( ".upload_doc .no_det span" ).hide();
                    jQuery( ".upload_doc .no_det img.tick" ).show();
                    jQuery( '.upload_doc .no_det').css("background", "#a3d233");
                    jQuery( ".upload_doc .no_det" ).css("border", "2px solid #a3d233");
                    jQuery( ".upload_doc .divider" ).hide();
                    jQuery( ".upload_doc .infr_det" ).hide();
                    
                    jQuery( ".payment" ).css("margin-top", "30px");
                    jQuery( '.payment .no_det span').hide();
                    jQuery( ".payment .no_det img.tick" ).show();
                    jQuery( ".payment .no_det" ).css("background", "#a3d233");
                    jQuery( ".payment .no_det" ).css("border", "2px solid #a3d233");
                    jQuery( ".payment .infr_details" ).hide();
                    
                    jQuery('.com_fully').slideDown();
                    jQuery(".basic_details li" ).css("float", "left");*/
                    
                }else{
                    self.logActionErrors(component, response);
                }
                
            });
            
        }
        $A.enqueueAction(action);
        /*  
           this.callServerAction(component, "c.finishRegistration", {
            "customer" : component.get("v.objAGNCustReg"),
            "customerAddress" : component.get("v.objAGNCustAddr")
        })
        .then(
            $A.getCallback(function(resp) {
                console.log('updateCustomerRegistration--' + resp);
                if ($A.util.isEmpty(resp)) {
                    console.log('CustomerRegistration error');
                     self.showTosteMessage(component, '', 'error', 'Unknown Error ', 'dismissible');
                } else {
                    console.log('Successfully CustomerRegistration updated');
                }
            }))
        .catch($A.getCallback(function(errorsresp) {
            
            self.logActionErrors(component, errorsresp);
            
        }));   */
        
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