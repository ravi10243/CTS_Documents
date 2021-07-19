({
    displaySpecialty : function(component, event) {
        console.log('Specialityin-->'+JSON.stringify(component.get("v.objSpecialty"))); 
        var action = component.get("c.getPickListValues");
        var columnName='Translated_Value_AGN__c';
        var columnId='Id';
        var objectName='Specialty_Allergan_AGN__c';
        var country = component.get('v.countryCode');
        var countryCode = "'" + country + "'";
        var whereCondition=' where Country_code_AGN__c='+countryCode+' AND Active_AGN__c= true AND Translated_Value_AGN__c !=Null';
        
        action.setStorable();        
        action.setParams({
            objectName : objectName,
            columnName : columnName,
            columnId : columnId,
            whereCondition: whereCondition
        });
        
        action.setCallback(this, function(response) {
          //  console.log('response.getState()-->'+response.getState());
            
            if(response.getState() === 'SUCCESS'){
                var dropdownlist = response.getReturnValue();
              
                component.set("v.objSpecialty", dropdownlist);
            }
            else {                   
              //  console.log('Error calling action "' + action + '" with state: ' + response.getState());                   
            }
            
        });       
        
        $A.enqueueAction(action); 
    },
    fetchDocumentSettings : function(component, event) {
        console.log('Document section is open successfully');
        var action = component.get('c.getLayout');   
        if(component.get("v.countryCode") === 'IT'){
            action.setParams({       
                'country': 'IT', //IT                 
                'stepNo': '3'            
            });       
        }
        else{
            action.setParams({       
                'country': component.get("v.countryCode"), //FR, DE            
                'stepNo': '3',
                'customerType': component.get("v.customerType"),
                'customerSubType': component.get("v.customerSubType"),
                'custTypeConfig': component.get("v.customerTypeConfig")
            });
        } 
        action.setStorable();
        action.setCallback(this, function(response) {
            console.log('Document section Resopnse---->'+response.getState());
            if(response.getState() === 'SUCCESS') {
                var settings = [];
                var settingsMap = response.getReturnValue();
                for(var key in settingsMap){
                    settings.push({value:settingsMap[key], key:key});
                }
                component.set('v.sectionHeaderMapDoc', settings);
               // console.log('sectionHeaderMapDoc---->'+ JSON.stringify(component.get('v.sectionHeaderMapDoc')));
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
                console.log('cust--->'+response.getState());
                var custReg = response.getReturnValue();               
                console.log('fetchCustomerDetails---->'+ JSON.stringify(custReg));
               
                
                /* for canada only */
                
                var taxExemptedVal = custReg.Tax_Exempted_AGN__c;  
                if(taxExemptedVal == null){
                    custReg.Tax_Exempted_AGN__c = '9';
                }
                component.set("v.taxExempted",taxExemptedVal);
               
                
                /* for canada only */ 
                
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
                            //console.log('fetchCustomerAddressDetailsCatch---->'+ JSON.stringify(result));
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
                for(var i in addressList){
                    
                    if(addressList[i].Sold_To_AGN__c){ //only 1 SoldTo Address will be present
                        soldToAddr = addressList[i];
                        break;
                    }
                }
                
                component.set('v.objMixType', soldToAddr);
               
                
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchSpecialityDetails : function(component, event) {
        var action = component.get("c.getSpecialityDetails");        
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {                 
                var spe = response.getReturnValue();                
               // console.log('spe------>'+spe);
                component.set("v.selectedSpecialty",spe);
               // console.log('objsspe------>'+JSON.stringify(component.get("v.selectedSpecialty")));
            }  
        });
        
        $A.enqueueAction(action);
    },
    /*fetchCustomerAddressDetails : function(component, event) {
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
    },*/                          
    //  get Address  end  // 
    
    
    validateAndUpsert : function(component, event) {
        console.log('inside validateAndUpsert');
        jQuery.noConflict();
        component.set("v.requireFieldMissing", false);
        component.set("v.fieldWellFormated", true);
        var requiredMissing = false;
        
        const cmpfield = component.find("fieldId_Doc");
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
                    if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
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
                    if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && jQuery.trim(cmp.get("v.fieldValue")) != ''){
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
        if (!cmps) return;
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
        var self = this; 
        
        var Specialty = component.find("speciality") !=null ? component.find("speciality").get("v.value") : '';
        if(!Specialty){
            Specialty = '';
        }
       // console.log('Speciality ====> ' +Specialty);
        
       //console.log('Registrstion = ' +JSON.stringify(component.get('v.objAGNCustReg')));  
       // console.log('addressList = ' +JSON.stringify(component.get('v.objAGNCustAddr')));
        
        //return;
        //*********upsert CustomerRegistration *************
       
      var taxExemptedVal = component.get("v.objAGNCustReg.Tax_Exempted_AGN__c");
        if(taxExemptedVal == '9' && component.get("v.countryCode") == 'CA'){
            component.set("v.isMandateTaxExempting", true);
        }
        
        //Assign VAT Number from CR to CRA - SOLDTO
      var vatNumber = component.get("v.objAGNCustReg.VAT_AGN__c");
      if(!$A.util.isEmpty(vatNumber)){
          component.set("v.objAGNCustAddr.VAT_Number_AGN__c" , vatNumber);
      }
      
        if(component.get("v.isMandate") && component.get("v.isMandateTaxExempting")){   
            this.callServerAction(component, "c.upsertCustomerDetails", {
                'customer' : component.get('v.objAGNCustReg'),
                'customerAddress' : component.get('v.objAGNCustAddr'),
                'Specialty'	: Specialty
            })          
            .then(             
                $A.getCallback(function(resp) {
                   //console.log('updateCustomerRegistration--'+resp);
                    if($A.util.isEmpty(resp)){
                        console.log('CustomerRegistration Error');
                        self.showTosteMessage(component, '', 'error', 'Unknown Error ', 'dismissible');
                    } 
                    else {
                        
                        var notifyRegStepChange = component.getEvent("notifyRegStepChange");
                        notifyRegStepChange.setParams({"Operation": 'UPDATE',
                                                       "StepNo": '4'}
                                                     );
                        notifyRegStepChange.fire();
                        
                        console.log('Successfully CustomerRegistration updated');
                    }                                     
                }))
            .catch($A.getCallback(function(errorsresp) {
                console.log('error');
                self.logActionErrors(component, errorsresp);                                                    
                //*********upsert CustomerRegistration *************
            }));  
        }else{
            console.log('error is Caling');
            var msg = $A.get("$Label.c.AGN_OAM_RequiredDocument_ErrorMsg");
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