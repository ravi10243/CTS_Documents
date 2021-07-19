({
fetchDocumentSettings : function(component, event) {
        
    	var country = component.get("v.SAPCountryCode");
        if($A.util.isEmpty(country)){
            country = component.get("v.countryCode");        } 
    
        var action = component.get('c.getPortalLayout'); //getLayout
            action.setParams({       
                'country': country,          
                'stepNo': '3',
                'customerType': component.get("v.customerType"),
                'customerSubType': component.get("v.customerSubType")
                //'custTypeConfig' : component.get("v.customerTypeConfig")
                
            }); 
        action.setCallback(this, function(response) {
           // console.log('Document section Resopnse---->'+response.getState());
            var type = component.get("v.customerType");
            if(response.getState() === 'SUCCESS') {
                var settings = [];
                var settingsMap = response.getReturnValue();
                for(var key in settingsMap){
                   settings.push({value:settingsMap[key], key:key}); 
                    
                }                
                component.set('v.sectionHeaderMapDoc', settings);
                
                var headerSettings = component.get('v.sectionHeaderMapDoc');
                if($A.util.isEmpty(headerSettings) && component.get("v.AttachmentList").length == 0){
                    component.set("v.isBlankComponent",true);
                    
                }
               // console.log('sectionHeaderMapDoc---->'+ JSON.stringify(component.get('v.sectionHeaderMapDoc')));
            } else {
                this.logActionErrors(component, response);
                
            }
        });
        $A.enqueueAction(action); 
    },   
        
    fetchCustomerDetails : function(component, event) {
         //console.log('cust--->');
        var action = component.get("c.getCustomerRegDetails");        
        action.setCallback(this, function(response) {            
            if(response.getState() === 'SUCCESS') { 
                var custReg = response.getReturnValue();   
                
                //  get Address  start // 
                var soldToAddr;                
                var action1 = component.get("c.getCustomerAddressDetails"); 
                action1.setParams({
                    'custRegId': component.get("v.selectedCustRegID")
                }); 
                action1.setCallback(this, function(response) {
                    var state1 = response.getState();
                    if (state1 === "SUCCESS") {
                        var addressList = response.getReturnValue();                 
                        if(addressList){
                            
                            for(var i in addressList){                              
                                if(addressList[i].Sold_To_AGN__c){ //only 1 SoldTo Address will be present
                                    soldToAddr = addressList[i];
                                    var type = component.get("v.customerType");                                   
                                    if(type.toUpperCase() =='HEALTHCARE PRACTITIONERS' && addressList[i].Are_You_The_Prescribing_Doctor_AGN__c){
                                        component.set("v.isAccOwner",true);//addressList[i].Are_You_The_Prescribing_Doctor_AGN__c && $A.util.isEmpty(addressList[i].Doctors_Email_AGN__c)
                                        component.set("v.isdisabled",true);
                                    }                                                                        
                                    break;
                                }
                            }
                        }
                        //console.log('soldToAddr---->'+ JSON.stringify(soldToAddr));
                        try{                         
                            var result = Object.assign({}, custReg, soldToAddr); //Merging registration and address data
                            //console.log('fetchCustomerAddressDetails---->'+ JSON.stringify(result));
                            component.set('v.objMixType', result);
                             
                        }
                        catch(err)
                        {
                            var result = jQuery.extend({}, custReg, soldToAddr); //Merging registration and address data
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
 
    validateAndUpsert : function(component, event) {
        component.set("v.Spinner", true);
        component.set("v.isdisabled", true);
        console.log('inside validateAndUpsert');
        jQuery.noConflict();
        component.set("v.requireFieldMissing", false);
        component.set("v.fieldWellFormated", true);
        var requiredMissing = false;
        
        const cmpfield = component.find("fieldId_Doc");   
        if(!cmpfield){
            component.set("v.noFieldsAvailabel",true);
           this.upsertCustomerDetails(component, event);
        }
        console.log('cmpfield>>>>'+JSON.stringify(cmpfield));
        const cmpSBS = [];
        cmpSBS.push(cmpfield);
        
        console.log('cmpSBS'+JSON.stringify(cmpSBS));       
        
        if (!cmpSBS) return;
        if ($A.util.isArray(cmpSBS)){
            cmpSBS.forEach( function (cmps){
                if(cmps.length){
                    cmps.forEach( function (cmp){                        
                        if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                            console.log('is empty');
                            cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                            requiredMissing = true;
                        }
                        else{
                            cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                        }
                    });
                }
                else{
                    console.log('single element');
                    //if (cmps.get("v.required") && $A.util.isEmpty(cmps.get("v.fieldValue")) && jQuery.trim(cmps.get("v.fieldValue")) == ''){
                    if (cmps.get("v.required") && jQuery.trim(cmps.get("v.fieldValue")) == ''){
                        console.log('is empty');
                        cmps.set("v.fieldValueMissing",true); //to show red color bottom border
                        requiredMissing = true;
                    }
                    else{
                        cmps.set("v.fieldValueMissing",false); //to hide red color bottom border
                    }
                }
            });
            if(requiredMissing){
                component.set("v.requireFieldMissing",true);
                console.log('requireFieldMissing');
                // alert($A.get("$Label.c.AGN_OAM_Body_PleaseFill"));
                 component.set("v.Spinner", false);
                 component.set("v.isdisabled", false);
                this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Required_Fields_Missing_Error"), 'dismissible');
            }
            else{
                console.log('validateFormatFields');
                this.validateFormatFields(component, event);
            }
        }
        else{
            console.log('Not an array');
        }
        
    },            
    validateFormatFields: function(component, event) {
        jQuery.noConflict();
        var wellFormatted = true;
        var whichFields = '';
        
        const cmpfield = component.find("fieldId_Doc");
        const cmpSBS = [];
        
        cmpSBS.push(cmpfield);
        
        if (!cmpSBS) return;
        if ($A.util.isArray(cmpSBS)){ 
            cmpSBS.forEach( function (cmps){
                if(cmps.length){
                    cmps.forEach(function (cmp){
                        //if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && !$A.util.isEmpty(cmp.get("v.fieldValue"))){
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
                }
                else{
                    console.log('single element');
                    //if (!$A.util.isEmpty(cmps.get("v.fieldRegex")) && !$A.util.isEmpty(cmps.get("v.fieldValue")) ){
                    if (!$A.util.isEmpty(cmps.get("v.fieldRegex")) && jQuery.trim(cmps.get("v.fieldValue")) != ''){
                        if(!cmps.get("v.isFormatValid")){
                            //console.log('not formatted');
                            cmps.set("v.fieldValueMissing",true); //to show red color bottom border
                            wellFormatted = false;
                            whichFields += cmps.get("v.customLabelName") + ", ";
                        }
                        else{
                            //console.log('formatted');
                            cmps.set("v.fieldValueMissing",false); //to hide red color bottom border
                        }
                    } 
                }
            }); 
            if(!wellFormatted){
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
                whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                component.set("v.Spinner", false);
                component.set("v.isdisabled", false);
                var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
            }
            else{
                //calling registration process
                console.log("upsertCustomerDetails function");
                
                this.upsertCustomerDetails(component, event);  
                //console.log('addressList = ' +JSON.stringify(component.get('v.objBillTo')));              
            }  
        }
    },
    upsertCustomerDetails : function(component, event) {  
        console.log("Inside upsertRegistration For document");
        
        const cmps = component.find("fieldId_Doc");
        if(!component.get("v.noFieldsAvailabel")){
            if (!cmps) return;
        
        
        console.log("yo>>>>>>>>>>>");
        if ($A.util.isArray(cmps)){
            
            cmps.forEach( function (cmp){                
                //storing all screen data in to relevant object
                if(cmp.get("v.sobjectName") === 'Allergan_Customer_Address_AGN__c'){
                    var derivedField = 'v.objAGNCustAddr.' + cmp.get("v.fieldName"); 
                    component.set(derivedField,cmp.get("v.fieldValue"));                    
                    
                }
                else if(cmp.get("v.sobjectName") === 'Allergan_Customer_Registration_AGN__c'){
                    var derivedField = 'v.objAGNCustReg.' + cmp.get("v.fieldName"); 
                    component.set(derivedField,cmp.get("v.fieldValue"));
                   
                }
            });
            //end forEach
        }
        else{
            //single record
            //storing all screen data in to relevant object
            if(cmps.get("v.sobjectName") === 'Allergan_Customer_Address_AGN__c'){
                var derivedField = 'v.objAGNCustAddr.' + cmps.get("v.fieldName"); 
                component.set(derivedField,cmps.get("v.fieldValue"));
              
            }
            else if(cmps.get("v.sobjectName") === 'Allergan_Customer_Registration_AGN__c'){
                var derivedField = 'v.objAGNCustReg.' + cmps.get("v.fieldName"); 
                component.set(derivedField,cmps.get("v.fieldValue"));
            }
        }     
        }
        var self = this; 
        
    
        //*********upsert CustomerRegistration *************
        
        if(component.get("v.isMandate")){   
            this.callServerAction(component, "c.upsertCustomerDetails", {
                'customer' : component.get('v.objAGNCustReg'),
                'customerAddress' : component.get('v.objAGNCustAddr')
            })          
            .then(             
                $A.getCallback(function(resp) {
                   // console.log('updateCustomerRegistration--'+resp);
                    if($A.util.isEmpty(resp)){
                        console.log('CustomerRegistration Error');
                         component.set("v.Spinner", false);
                         component.set("v.isdisabled", false);
                        self.showTosteMessage(component, '', 'error', 'Unknown Error ', 'dismissible');
                    } 
                    else {
                        
                        var notifyRegStepChange = component.getEvent("notifyRegStepChange");
                        notifyRegStepChange.setParams({"Operation": 'UPDATE',
                                                       "StepNo": '4'}
                                                     );
                        notifyRegStepChange.fire();
                        component.set("v.Spinner", false);
                        component.set("v.isdisabled", false);
                        console.log('Successfully CustomerRegistration updated');
                    }                                     
                }))
            .catch($A.getCallback(function(errorsresp) {
                console.log('error');
                 component.set("v.Spinner", false);
                 component.set("v.isdisabled", false);
                self.logActionErrors(component, errorsresp);                                                    
                //*********upsert CustomerRegistration *************
            }));  
        }else{
            console.log('error is Caling');
            var msg = $A.get("$Label.c.AGN_OAM_RequiredDocument_ErrorMsg");
             component.set("v.Spinner", false);
             component.set("v.isdisabled", false);
            this.showTosteMessage(component, '', 'error', msg, 'dismissible');
        }
    },   
    logActionErrors : function(component, response) {
        console.log(JSON.stringify(response, null, 2));
        
        var state = response.getState();
        var message = '';
        
        if (state === "INCOMPLETE") {
            message = "No Response From Server or Server could not be reached. Check your internet connection";
        }
        else 
            if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    for(var i=0; i < errors.length; i++) {
                        for(var j=0; errors[i].pageErrors && j < errors[i].pageErrors.length; j++) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].pageErrors[j];
                        }
                        if(errors[i].fieldErrors) {
                            for(var fieldError in errors[i].fieldErrors) {
                                var thisFieldError = errors[i].fieldErrors[fieldError];
                                for(var j=0; j < thisFieldError.length; j++) {
                                    message += (message.length > 0 ? '\n' : '') + thisFieldError[j].message;
                                }
                            }
                        }
                        if(errors[i].message) {
                            message += (message.length > 0 ? '\n' : '') + errors[i].message;
                        }
                    }
                }
                else {
                    message = "Unknown Error";
                }
            }
            else {
                message = "Unknown Status Error: " + state;
            }
        
        console.log('ERROR = ' + JSON.stringify(message, null, 2));
        this.showTosteMessage(component,'', 'error', message, 'sticky');
    },
    
    showTosteMessage : function(component, title, type, message, mode) {
        var toastEvent = $A.get("e.force:showToast");
        
        if (toastEvent){
            
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
    
    callServerAction : function(component, actionName, params) {
        var helper = this;
        
        var p = new Promise(function(resolve, reject) {
            
            var action = component.get(actionName);
            
            if (params) {
                action.setParams(params);
            }
            action.setCallback(helper, function(response) {
                if (component.isValid() && response.getState() === 'SUCCESS'){
                    resolve(response.getReturnValue());
                } else {                   
                    //console.log('Error calling action "' + actionName + '" with state: ' + response.getState());                   
                    reject(response); 
                }
            });
            $A.enqueueAction(action);
        });       
        return p;
    }
})