({
    fetchCountrySettings : function(component, event) {        
        var action = component.get('c.getLayout');
        if(component.get("v.selectedCountryCode") === 'IT'){
            action.setParams({       
                'country': component.get("v.selectedCountryCode"), //IT            
                'stepNo': '1'
            });
        }
        else{
            action.setParams({       
                'country': component.get("v.selectedCountryCode"), //FR, DE, GB, ES
                'stepNo': '1',
                'customerType': component.get("v.selectedCustomerType"),
                'customerSubType': component.get("v.selectedCustomerSubType"),
                'custTypeConfig': component.get("v.customerTypeConfig")
            });
        }
        action.setStorable();
        action.setCallback(this, function(response) {
            console.log(response.getState());
            if(response.getState() === 'SUCCESS') {
                //var countrySettings = response.getReturnValue();
                //component.set('v.fieldMetadata', countrySettings);
                var settings = [];
                var settingsMap = response.getReturnValue();
                for(var key in settingsMap){
                    settings.push({value:settingsMap[key], key:key});
                }
                component.set('v.sectionHeaderMap', settings);
                console.log(JSON.stringify(component.get('v.sectionHeaderMap')));
            } else {
                this.logActionErrors(component, response);
            }
        });
        $A.enqueueAction(action);
        
    },
    fetchFooterConsents : function(component, event) {
        var action = component.get("c.fetchFooterConsents");
        action.setParams({       
            'pageLang': $A.get("$Locale.language")        
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('T&C'+state);
            if (state === "SUCCESS") {
                var lst = response.getReturnValue();
                //console.log('dfdff'+JSON.stringify(lst));
                for (var i in lst) {
                    //console.log(lst[i].Name);
                    if(lst[i].Name == 'Terms of Use'){
                        component.set("v.footerConsentsList", lst[i]);
                        break;
                    }
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    
    makeEmptyValue : function(component, event) {
        
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            
            cmps.forEach( function (cmp){
                cmp.set("v.fieldValue",'');
            });
        }
    },
    createNewRegistration : function(component, event) { 
        
        this.showSpinner(component, event);
        
        var self = this;
        
        const cmps = component.find("fieldId");
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
            
            var countryOptions = component.get("v.countryOptions");
            var countrySFDCId;
            var countryName;
            if ($A.util.isArray(countryOptions)){               
                countryOptions.forEach(function(currRow){
                    if(currRow.Alpha_2_Code_vod__c.toUpperCase() === component.get("v.selectedCountryCode").toUpperCase()){
                        countrySFDCId = currRow.Id;
                        countryName = currRow.AGN_Country_Name__c;
                    }
                });
            }
            
            //Setting extra fields/values in to Allergen Customer Registration Object
            //component.set('v.objAGNCustReg.Country_Code_AGN__c', component.get("v.selectedCountryCode")); // eg. IT
            //component.set('v.objAGNCustReg.SAP_Country_Code_AGN__c', component.get("v.selectedCountryCode")); // eg. IT
            
            component.set('v.objAGNCustReg.Country_Code_AGN__c', component.get("v.CountryCode")); // eg. IT
            component.set('v.objAGNCustReg.SAP_Country_Code_AGN__c', component.get("v.SAPCountryCode")); // eg. IT
            
            component.set('v.objAGNCustReg.Country_AGN__c', countrySFDCId); // eg. Country SFDC Id
            component.set('v.objAGNCustReg.Customer_Category_AGN__c', component.get("v.selectedCustomerType"));
            component.set('v.objAGNCustReg.Customer_Sub_Category_AGN__c', component.get("v.selectedCustomerSubType"));
            
            //Setting up extra fields/values in to Allergen Customer Address Object
            component.set('v.objAGNCustAddr.Country_Lookup_AGN__c', countrySFDCId); // eg. Country SFDC Id
            if(component.get("v.selectedCountryCode") != 'IT'){
               component.set('v.objAGNCustAddr.Country_AGN__c', countryName); // Country Name, e.g Italy         
             }         
            
            //console.log(JSON.stringify(component.get('v.objAGNCustReg'), null, 2));
            //console.log(JSON.stringify(component.get('v.objAGNCustAddr'), null, 2));
            
            
            //*********0. Duplicate User check*************
            this.callServerAction(component, 'c.isDuplicateUser', {                
                'email' : component.get('v.objAGNCustReg.Email_AGN__c')               
            })
            .then(
                $A.getCallback(function(resp) {
                    console.log(resp);
                    if(resp){
                        console.log('Duplicate User');
                        self.hideSpinner(component, event);
                        self.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Apex_DuplicateEmail"), 'dismissible');
                    } else {
                        
                        //*********1. Account Create*************
                        self.callServerAction(component, 'c.createAccount', {                
                            'customerAddress' : component.get('v.objAGNCustAddr'),
                            'customer' : component.get('v.objAGNCustReg')
                        })
                        .then(
                            $A.getCallback(function(accountResp) {
                                console.log('@@@@accountResp>>>'+accountResp);
                                if($A.util.isEmpty(accountResp)){
                                    console.log('Account Error');
                                    self.hideSpinner(component, event);
                                    self.showTosteMessage(component, '', 'error', 'Unknown Error ', 'dismissible');
                                } else {
                                    console.log('Successfully Account created');
                                    
                                    //*********2. Contact Create*************
                                    
                                    self.callServerAction(component, 'c.createContact', {                
                                        'customer' : component.get('v.objAGNCustReg'),
                                        'acc' : accountResp
                                    })
                                    .then( 
                                        $A.getCallback(function(contactResp) {
                                            //console.log(contactResp);
                                            if($A.util.isEmpty(contactResp)){
                                                console.log('Contact Error');
                                                self.hideSpinner(component, event);
                                                self.showTosteMessage(component, '', 'error', 'Unknown Error ', 'dismissible');
                                            }else{
                                                console.log('Successfully Contact created'); 
                                                
                                                //*********3. Community User creation*************
                                                self.callServerAction(component, 'c.createCommunityUser', {                
                                                    'customerContactId' : contactResp.Id,
                                                    'countryCode' : component.get("v.selectedCountryCode"),
                                                    'userLocale' : component.get("v.language")
                                                })
                                                .then(
                                                    $A.getCallback(function(userResp) {
                                                        console.log("communityUserId " + userResp);
                                                        if($A.util.isEmpty(userResp)){
                                                            console.log('User Error');
                                                            self.hideSpinner(component, event);
                                                            self.showTosteMessage(component, '', 'error', 'Unknown Error ', 'dismissible');
                                                        } else {
                                                            console.log('Successfully User created');
                                                            
                                                            //*********4. CustomerRegistration creation*************
                                                            self.callServerAction(component, 'c.createNewCustomerRegistration', {                
                                                                'customer' : component.get('v.objAGNCustReg'),
                                                                'customerAddress' : component.get('v.objAGNCustAddr'),
                                                                'configList' : component.get('v.customerTypeConfig'),
                                                                'customerContact' : contactResp,
                                                                'userLocale' : component.get("v.language")
                                                            })
                                                            .then(
                                                                $A.getCallback(function(resp) {
                                                                    console.log(resp);
                                                                    if($A.util.isEmpty(resp)){
                                                                        console.log('CustomerRegistration Error');
                                                                        self.hideSpinner(component, event);
                                                                        self.showTosteMessage(component, '', 'error', 'Unknown Error ', 'dismissible');
                                                                    } else {
                                                                        console.log('Successfully CustomerRegistration created');
                                                                        
                                                                        
                                                                        //*********5. Okta User creation*************
                                                                        self.callServerAction(component, 'c.createOktaUserSendLink', {                
                                                                            'customer' : component.get('v.objAGNCustReg'),
                                                                            'customerContact' : contactResp,
                                                                            'userLocale' : component.get("v.language")
                                                                        })
                                                                        .then(
                                                                            $A.getCallback(function(resp) {
                                                                                console.log(resp);
                                                                                if(resp.toUpperCase() === 'FAILURE'){
                                                                                    console.log('Okta User creation Error');
                                                                                    self.hideSpinner(component, event);
                                                                                    self.showTosteMessage(component, '', 'error', 'Unknown Error, please contact customer service team.', 'sticky');
                                                                                }
                                                                                else if(resp.toUpperCase() === 'DEPROVISIONED'){
                                                                                    console.log('User exists in Okta as DEPROVISIONED/Inactive State');
                                                                                    
                                                                                    self.makeEmptyValue(component, event);
                                                                                    jQuery('.basic_details .infr_det').slideUp(500);
                                                                                    jQuery(".basic_details .no_det" ).css("border", "2px solid #bfbfbf");
                                                                                    self.hideSpinner(component, event);
                                                                                    self.showTosteMessage(component, '', 'error', 'User exists in Okta as DEPROVISIONED/Inactive State, please contact customer service team.', 'sticky');
                                                                                }
                                                                                    else {
                                                                                        console.log('Successfully Okta User created');
                                                                                        
                                                                                        self.makeEmptyValue(component, event);
                                                                                        jQuery('.basic_details .infr_det').slideUp(500);
                                                                                        //jQuery(".basic_details .no_det" ).css("border", "2px solid #bfbfbf");
                                                                                        jQuery( ".basic_detail .no_det" ).css("background", "#a3d233");
                                                                                        jQuery( ".basic_detail .no_det" ).css("border", "2px solid #a3d233");
                                                                                        jQuery( ".basic_detail .no_det img" ).show();
                                                                                        //jQuery( ".basic_detail .divider" ).hide();
                                                                                        self.hideSpinner(component, event);
                                                                                        //var msg = $A.get("$Label.c.AGN_OAM_Body_Confirm_Youhave") + ' ' + $A.get("$Label.c.AGN_OAM_Body_Confirm_SuccessfullyCompleted") + ' ' + $A.get("$Label.c.AGN_OAM_Body_Confirm_FirstStep")
                                                                                        //self.showTosteMessage(component, '', 'success', msg, 'sticky');
                                                                                        
                                                                                        //Show Success message on Parent Component
                                                                                        var messageStep1Completion = component.getEvent("messageStep1Completion");
                                                                                        messageStep1Completion.setParams({"isCompleted": true});
                                                                                        messageStep1Completion.fire();                                                                     
                                                                                    }              
                                                                            }))
                                                                        .catch($A.getCallback(function(errorsresp) {
                                                                            self.hideSpinner(component, event);
                                                                            self.logActionErrors(component, errorsresp);
                                                                        }));
                                                                        //*********End of 5. Okta User creation************* 
                                                                    }              
                                                                }))
                                                            .catch($A.getCallback(function(errorsresp) {
                                                                self.hideSpinner(component, event);
                                                                self.logActionErrors(component, errorsresp);
                                                                
                                                                //updating IsActive,IsPortalEnabled to false of the community user
                                                                /*self.callServerAction(component, 'c.inactivateUser', {                
                                                        'communityUserId' : userResp
                                                    });*/
                                                            }));
                                                            //*********End of 4. CustomerRegistration creation*************
                                                        }              
                                                    }))
                                                .catch($A.getCallback(function(errorsresp) {
                                                    self.hideSpinner(component, event);
                                                    self.logActionErrors(component, errorsresp);
                                                }));
                                                
                                                //*********End of 3. Community User creation*************
                                            }										
                                        }))
                                    .catch($A.getCallback(function(errorsresp) {
                                        self.hideSpinner(component, event);
                                        self.logActionErrors(component, errorsresp);
                                    }));
                                    //*********End of 2. Contact Create************* 
                                }              
                            }))
                        .catch($A.getCallback(function(errorsresp) {
                            self.hideSpinner(component, event);
                            self.logActionErrors(component, errorsresp);
                        }));
                        //*********End of 1. Account Create*************
                    }              
                }))
            .catch($A.getCallback(function(errorsresp) {
                self.hideSpinner(component, event);
                self.logActionErrors(component, errorsresp);
            }));
            //*********End of 0. Duplicate User check*************
        }
    }, 
    
    validateAndInsert: function(component, event) {
        jQuery.noConflict();
        component.set("v.requireFieldMissing",false);
        component.set("v.fieldWellFormated",true);
        var requiredMissing = false;
        var requiredMissingESNavarra = false;
        const cmps = component.find("fieldId");
        
         /* Added only for FR */
        if(component.get("v.selectedCountryCode") === 'FR'){
            var acceptCondition=component.get("v.isTCAccepted");
            console.log('acceptCondition : '+acceptCondition);
            var msg = $A.get("$Label.c.AGN_OAM_Accept_Condition_Message");
            console.log('msg : '+msg);
            if(acceptCondition == false){  
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
                return;
            }
       }
        /* Added only for FR */
        
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            cmps.forEach( function (cmp){
                //if (cmp.get("v.required") && $A.util.isEmpty(cmp.get("v.fieldValue")) && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                    //console.log('is empty');
                    cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                    requiredMissing = true;
                }
                else{
                    cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                }
            });
            
            //Pharmacies with  Navarra not allow they have to contact to CS
            var country =  component.get("v.selectedCountryCode");           
            var customerType =component.get("v.selectedCustomerType"); 
                     
            if(country === 'ES' && customerType=='Pharmacies'){                             
               //console.log('getOwnPropertyNames-->'+JSON.stringify(cmps));
                
               cmps.forEach( function (cmp){                
                   var name= cmp.get("v.fieldName"); 
                   var val=cmp.get("v.fieldValue");
                   
                   if(val === 'ES-Comunidad Foral de Navarra' && name === 'Province_AGN__c'){
                       
                        requiredMissingESNavarra = true;
                       
                   }
            });
          	//console.log('requiredMissingESNavarra : '+requiredMissingESNavarra);
          }
            
           if(requiredMissingESNavarra){               
                
                this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Pharmacy_Navarra"), 'dismissible');
                return;
            }
            
            //return;
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
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){            
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
            
            if(!wellFormatted){
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
                whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
            }
            else{
                var self = this;
                // waiting to get captcha response
                window.setTimeout(
                    $A.getCallback(function() {
                        if(component.get("v.isCaptchaValid")){
                            console.log("Captcha Pass");
                            //calling registration process
                            self.createNewRegistration(component, event);                            
                        }
                        else
                        {
                            //show message
                            console.log("Captcha Error");
                            var recaptchaCmp = component.find("openModal");
                            $A.util.removeClass(component.find("openModal"), 'captcha-hide');
                            
                            //self.showTosteMessage(component, '', 'error', 'Please verify not a robot', 'dismissible');
                        }
                    }), 500
                );
            }
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
    showSpinner: function(component, event) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.showSpinner", true); 
    },
    
    hideSpinner : function(component,event){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.showSpinner", false);
    },
})