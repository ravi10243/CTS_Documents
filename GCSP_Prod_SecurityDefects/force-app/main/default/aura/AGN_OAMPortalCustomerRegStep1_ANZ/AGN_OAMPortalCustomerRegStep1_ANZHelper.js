({
    fetchCountrySettings : function(component, event) {
        var country = component.get("v.SAPCountryCode");
        if($A.util.isEmpty(country)){
            country = component.get("v.selectedCountryCode");
        }        
        //component.set("v.showSpinner", true);
        console.log('selectedCountryCode --> '+component.get("v.selectedCountryCode"));
        var action = component.get('c.getLayout');
        if(component.get("v.selectedCountryCode") === 'IT'){
            action.setParams({       
                'country': country,//component.get("v.selectedCountryCode"), //IT            
                'stepNo': '1'
            });
        }
        else{
            action.setParams({       
                'country': country,//component.get("v.selectedCountryCode"), //FR, DE, GB, ES
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
                //console.log(JSON.stringify(component.get('v.sectionHeaderMap')));                
               
            } else {
                this.logActionErrors(component, response);
            }
            //component.set("v.showSpinner", false);
            
            
        });
        $A.enqueueAction(action);
        
    },
    
    fetchDependantFields : function(component , country){
        
        var country = component.get("v.SAPCountryCode");
        if($A.util.isEmpty(country)){
            country = component.get("v.selectedCountryCode");
        }
        var action = component.get('c.getDependantLayout');
        action.setParams({       
            'country': country//component.get("v.selectedCountryCode")
        });
        action.setCallback(this, function(response) {
            //console.log("Dependent settings call status>>>>>>"+response.getState());
            //alert(response.getState());
            if(response.getState() === 'SUCCESS') {
                var settings = [];
                var prescribingDoctorsSettings = [];
                var settingsMap = response.getReturnValue();
                
                for(var key in settingsMap){
                    if(key === 'Doctors_Email_AGN__c'){
                        var flist = settingsMap[key];
                        //console.log(flist);
                        for(var item in flist){
                            var rec = flist[item];
                            rec.FieldValue_AGN__c = "";
                            prescribingDoctorsSettings.push(rec);
                        } 
                    }
                }
                prescribingDoctorsSettings.sort((a, b) => (a.Sort_Order_AGN__c > b.Sort_Order_AGN__c) ? 1 : -1); // Added by Ravi for soting the Records order by Sort_Order_AGN__c
                
                /* prescribingDoctorsSettings.sort(function(a, b){
                  return a.Sort_Order_AGN__c > b.Sort_Order_AGN__c;
                });*/
                var customerType = component.get("v.selectedCustomerType");
                var customerSubType = component.get("v.selectedCustomerSubType");
                
                if(customerType.toUpperCase() === 'HOSPITAL' || customerType.toUpperCase() === 'PHARMACIES' || customerType.toUpperCase() === 'WHOLESALERS' || customerSubType.toUpperCase() ==='NURSE PRACTITIONER'){                    
                    component.set("v.PrescribingDoctorsDependantFields" , []);
                    component.set("v.showPrescribingDrSlider" , false);                  
                }else{
                    component.set("v.PrescribingDoctorsDependantFields" , prescribingDoctorsSettings);
                    component.set("v.showPrescribingDrSlider" , true);
                }
                
                //alert(component.get("v.showPrescribingDr"));
                
                component.set("v.showPrescribingDr" , true); 
                component.set("v.isPrescribingDr" , false); 
                component.set("v.clearPrescribingDrValues" , true);
                component.set("v.clearPrescribingDrRequiredFields" , true);
                
                
                component.set("v.showPrescribingDr" , false); 
                component.set("v.isPrescribingDr" , true); 
                component.set("v.disablePrescribingDr" , false); 
                component.set("v.clearPrescribingDrValues" , false);
                component.set("v.clearPrescribingDrRequiredFields" , false);
                
                var e = component.getEvent("refreshChildComponent");
                e.setParams({ "componentName": "AGN_OAMPortalCustomerRegStep1_ANZ"});
                e.fire();
                
            } else {
                //alert("error");
                this.logActionErrors(component, response);
            }
            //component.set("v.showSpinner", false);
            //console.log(component.get("v.BuyingGroupDependantFields"));
        });
        $A.enqueueAction(action);
    } ,
    
    fetchFooterConsents : function(component, event) {
        //console.log("Local " + $A.get("$Locale.langLocale"));
        var action = component.get("c.fetchFooterConsents");
        action.setParams({       
            'pageLang': $A.get("$Locale.langLocale")        
        });        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('T&C'+state);
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
            
            /********* Prescribibg Dr Field Assignments Starts***********/
            var lcmp = component.find("PrescribingDrField");
            if(!$A.util.isEmpty(lcmp)){
                var licenseCmp = component.get("v.PrescribingDoctorsDependantFields");
                var hasValue = true;
                licenseCmp.forEach( function (cmp){
                    if(!$A.util.isEmpty(cmp.FieldValue_AGN__c)){
                        hasValue = false;
                    }
                    if(cmp.SObject_Name_AGN__c === 'Allergan_Customer_Address_AGN__c'){
                        var derivedField = 'v.objAGNCustAddr.' + cmp.Field_Name_AGN__c; 
                        component.set(derivedField,cmp.FieldValue_AGN__c);
                    }
                    else if(cmp.SObject_Name_AGN__c === 'Allergan_Customer_Registration_AGN__c'){
                        var derivedField = 'v.objAGNCustReg.' + cmp.Field_Name_AGN__c; 
                        component.set(derivedField,cmp.FieldValue_AGN__c);
                    } 
                })
                
                component.set("v.objAGNCustAddr.Are_You_The_Prescribing_Doctor_AGN__c" , hasValue);
               /* if(!hasValue){
                     component.set("v.objAGNCustAddr.Are_You_The_Prescribing_Doctor_AGN__c" , false);
                }else{
                    component.set("v.objAGNCustAddr.Are_You_The_Prescribing_Doctor_AGN__c" , false);
                } */
            }
            /*********Prescribibg Dr Field Assignments for Canada Ends*************/
            
            var countryOptions = component.get("v.countryOptions");
            var countrySFDCId;
            var countryName;
            if ($A.util.isArray(countryOptions)){               
                countryOptions.forEach(function(currRow){                   
                    if(component.get("v.SAPCountryCode").toUpperCase() == 'NZ'){
                        if(currRow.Alpha_2_Code_vod__c.toUpperCase() === component.get("v.CountryCode").toUpperCase()){
                            countrySFDCId = currRow.Id;
                        }
                        if(currRow.Alpha_2_Code_vod__c.toUpperCase() === component.get("v.SAPCountryCode").toUpperCase()){
                            countryName = currRow.AGN_Country_Name__c;
                        }
                    }else if(currRow.Alpha_2_Code_vod__c.toUpperCase() === component.get("v.CountryCode").toUpperCase()){ 
                        countrySFDCId = currRow.Id;
                        countryName = currRow.AGN_Country_Name__c;
                    }
                });
            }
                        
            component.set('v.objAGNCustReg.Country_Code_AGN__c', component.get("v.CountryCode")); // eg. AN
            component.set('v.objAGNCustReg.SAP_Country_Code_AGN__c', component.get("v.SAPCountryCode")); // eg. NZ,Au
            
            component.set('v.objAGNCustReg.Country_AGN__c', countrySFDCId); // eg. Country SFDC Id
            component.set('v.objAGNCustReg.Customer_Category_AGN__c', component.get("v.selectedCustomerType"));
            component.set('v.objAGNCustReg.Customer_Sub_Category_AGN__c', component.get("v.selectedCustomerSubType"));
            
            //Setting up extra fields/values in to Allergen Customer Address Object
            component.set('v.objAGNCustAddr.Country_Lookup_AGN__c', countrySFDCId); // eg. Country SFDC Id (AN)            
            component.set('v.objAGNCustAddr.Country_AGN__c', countryName); // Country Name, e.g New Zealand(NZ) 
            
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
                            'customerAddress' : component.get('v.objAGNCustAddr')
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
                                                    'countryCode' : component.get("v.SAPCountryCode")//component.get("v.selectedCountryCode")
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
                                                                'customerContact' : contactResp
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
                                                                        
                                                                        
                                                                        /* We need to remove here and add to After completion of Okta user Creation */	
                                                                        self.makeEmptyValue(component, event);
                                                                        jQuery('.basic_details .infr_det').slideUp(500);
                                                                        //jQuery(".basic_details .no_det" ).css("border", "2px solid #bfbfbf");
                                                                        jQuery( ".basic_detail .no_det" ).css("background", "#a3d233");
                                                                        jQuery( ".basic_detail .no_det" ).css("border", "2px solid #a3d233");
                                                                        jQuery( ".basic_detail .no_det img" ).show();
                                                                        //jQuery( ".basic_detail .divider" ).hide();
                                                                        self.hideSpinner(component, event);                                                                            
                                                                        var messageStep1Completion = component.getEvent("messageStep1Completion");
                                                                        messageStep1Completion.setParams({"isCompleted": true});
                                                                        messageStep1Completion.fire();
                                                                        
                                                                        
                                                                        
                                                                        //*********5. Okta User creation*************
                                                                        self.callServerAction(component, 'c.createOktaUserSendLink', {                
                                                                            'customer' : component.get('v.objAGNCustReg'),
                                                                            'customerContact' : contactResp
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
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            cmps.forEach( function (cmp){
                //if (cmp.get("v.required") && $A.util.isEmpty(cmp.get("v.fieldValue")) && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                    //console.log('is empty');
                    cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                    console.log("field missing>>"+cmp.get("v.fieldName")+', ');
                    requiredMissing = true;
                }
                else{
                    cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                }
            });
            /********* Prescribibg Dr Validation Starts***********/
            var lcmp = component.find("PrescribingDrField");
            if(!$A.util.isEmpty(lcmp) && component.get("v.isPrescribingDr")){
                var licenseCmp = component.get("v.PrescribingDoctorsDependantFields");
                var isPrescribingDrRequired = false;
                var nonMandatoryFields = "";
                var mandatoryFields = "";
                licenseCmp.forEach( function (cmp){
                    if ($A.util.isEmpty(cmp.FieldValue_AGN__c) && cmp.Required_AGN__c){
                        console.log("Prescribibg Dr require field missing>>"+cmp.Field_Name_AGN__c);
                        requiredMissing = true;  
                        cmp.FieldValue_Missing_AGN__c = true;
                        isPrescribingDrRequired = true;
                    } 
                    
                    if(!cmp.Required_AGN__c){
                        nonMandatoryFields = nonMandatoryFields + "-" + cmp.Field_Name_AGN__c;
                    }else{
                        mandatoryFields = mandatoryFields + "-" + cmp.Field_Name_AGN__c;
                    }
                });
                
                //To display required red color in buying group fields
                if(isPrescribingDrRequired){
                    console.log("inside condition"+isPrescribingDrRequired);
                    if($A.util.isArray(lcmp)){
                        lcmp.forEach( function (cmp){
                            cmp.set("v.nonMandatoryFields" , nonMandatoryFields);
                            cmp.set("v.mandatoryFields" , mandatoryFields);
                            var actualVal = cmp.get("v.isRequiredAdded");
                            if(actualVal == true){
                                cmp.set("v.isRequiredAdded" , false);
                            }else{
                                cmp.set("v.isRequiredAdded" , true);
                            }
                            
                        });
                    }else{
                        lcmp.set("v.nonMandatoryFields" , nonMandatoryFields);
                        lcmp.set("v.mandatoryFields" , mandatoryFields);
                        var actualVal = lcmp.get("v.isRequiredAdded");
                        if(actualVal == true){
                            lcmp.set("v.isRequiredAdded" , false);
                        }else{
                            lcmp.set("v.isRequiredAdded" , true);
                        } 
                    }
                    
                }
            }
            console.log("Prescribibg Doctor validation completed");
            /********* Prescribibg Dr Validation End*************/
            //return;
            if(requiredMissing){
                component.set("v.doValidate" , true);
                component.set("v.requireFieldMissing",true);
                console.log('requireFieldMissing');
                this.showTosteMessage(component, '', 'error', $A.get("$Label.c.AGN_OAM_Required_Fields_Missing_Error"), 'dismissible');
            }
            else{
                component.set("v.doValidate" , false);
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
            /********* Prescribibg Dr Format for ANZ Starts***********/
            var lcmp = component.find("PrescribingDrField");
            if(!$A.util.isEmpty(lcmp) && component.get("v.isPrescribingDr")){
                var isValid = true;
                var notFormattedFields = "";
                var licenseCmp = component.get("v.PrescribingDoctorsDependantFields");
                licenseCmp.forEach( function (cmp){
                    
                    if(!cmp.Is_Format_Valid_AGN__c){
                        cmp.FieldValue_Missing_AGN__c = true; //to show red color bottom border
                        wellFormatted = false;                          
                        whichFields += $A.get("$Label.c."+cmp.Field_Custom_Label_AGN__c) + ", ";
                        isValid = false;
                        notFormattedFields = notFormattedFields + "-" + cmp.Field_Name_AGN__c;
                    }
                    else{
                        cmp.FieldValue_Missing_AGN__c = false; //to hide red color bottom border
                    }						
                });
                if(!isValid){
                    lcmp.forEach( function (cmp){
                        var actualVal = cmp.get("v.isFormatValid");
                        if(actualVal == true){
                            cmp.set("v.isFormatValid" , false);
                        }else{
                            cmp.set("v.isFormatValid" , true);
                        }
                        cmp.set("v.notFormattedFields" , notFormattedFields);
                    });
                }
            }
            console.log("Prescribing Doctor format validation completed");
            /********* Prescribing Dr Format Validation for ANZ Ends*************/
            if(!wellFormatted){
                component.set("v.doValidate" , true);
                component.set("v.fieldWellFormated",false);
                console.log('not formatted');
                whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                this.showTosteMessage(component, '', 'error', msg, 'dismissible');
            }
            else{  
                component.set("v.doValidate" , false);
                var self = this;
                // waiting to get captcha response
                window.setTimeout(
                    $A.getCallback(function() {
                        
                        try{
                            const cmps = component.find("fieldId");
                            if ($A.util.isArray(cmps)){
                                cmps.forEach( function (cmp){
                                    if(cmp.get("v.sobjectName") === 'Allergan_Customer_Address_AGN__c'){
                                        var derivedField = 'v.objAGNCustAddr.' + cmp.get("v.fieldName"); 
                                        component.set(derivedField,cmp.get("v.fieldValue"));
                                    }
                                });
                            }
                           // console.log("selected address>>>>>>>>>>>>>>>"+component.get('v.objAGNCustAddr.Address_Line_1_AGN__c'));
                           // console.log("selected zip>>>>>>>>>>>>>>>"+component.get('v.objAGNCustAddr.Zip_AGN__c'));
                            
                            /*var isLoqateEnabled = component.get("v.isLoqateEnabled");*/
                            var isLoqateEnabled = true;
                            self.callServerAction(component, 'c.isLoqateEnabled', {
                                'country' : component.get("v.selectedCountryCode")
                            })
                            .then($A.getCallback(function(resp) {
                                console.log("Loqate Respose>>>>>>>>>>>>>",resp);
                                if(resp == true){
                                        
                                        if(!component.get("v.isAddressVerified")){
                                            self.showSpinner(component, event);
                                            component.set("v.addressType" , "Address");
                                            self.callServerAction(component, 'c.getValidAddress', {
                                                'customerAddress' : component.get('v.objAGNCustAddr'),
                                                'country' : component.get("v.selectedCountryCode")
                                            })
                                            .then($A.getCallback(function(resp) {
                                                console.log("Address Respose>>>>>>>>>>>>>",resp);
                                                if(resp.length > 0){
                                                    component.set("v.activeAddressFound" , true);
                                                    component.set('v.isAddressVerified' , true);
                                                }else{
                                                    component.set("v.activeAddressFound" , false);
                                                }
                                                self.hideSpinner(component, event);
                                                //open popup
                                                component.set("v.addressOps" , resp);
                                                component.set("v.isOpen", true);                                   
                                            }))   
                                            
                                        }  
                                        if(component.get("v.isAddressVerified")){ 
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
                                        }
                                }else{
                                    
                                    if(component.get("v.isCaptchaValid")){
                                        console.log("Captcha Pass");
                                        //calling registration process
                                        self.createNewRegistration(component, event);                            
                                    }else{
                                        //show message
                                        console.log("Captcha Error");
                                        var recaptchaCmp = component.find("openModal");
                                        $A.util.removeClass(component.find("openModal"), 'captcha-hide');
                                        
                                        //self.showTosteMessage(component, '', 'error', 'Please verify not a robot', 'dismissible');
                                    }
                                }
                                
                            }));
                            /*console.log("isLoqateEnabled>>>>>>>>"+isLoqateEnabled);*/
                            //alert(isLoqateEnabled);
                        
                        }catch(err){
                            console.log(err);
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
        
        //Avijit
        //const orgWideDuplicateUserErrorMessage = 'DUPLICATE_USERNAME';
        //if(message.includes(orgWideDuplicateUserErrorMessage)){
        //    message = 'An user already exists for this email address, please use a different email to continue.';
        //}
        
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
    
    fetchProductInterestOptions : function(component,event){
        this.callServerAction(component, 'c.getPicklistOptions', {                
            ObjectName : 'Allergan_Customer_Registration_AGN__c',
            fieldName : 'Product_Interest_AGN__c'
        })
        .then(
            $A.getCallback(function(resp) {
                var prodOptions = [];
                var optionMap = new Map();
                var options = resp; 
                if(!$A.util.isEmpty(options)){
                    options.forEach(function(cmp){
                        optionMap.set(cmp.value ,cmp.label);                            
                    });
                }
                console.log('optionMap>>>>>>>>>>>>>>>>>>>>>',optionMap);
                component.set("v.productInterestOptions" , optionMap);
            }))
        .catch($A.getCallback(function(errorsresp) {
            console.log("error in fetching product interest options");
        }));
    },
   
})