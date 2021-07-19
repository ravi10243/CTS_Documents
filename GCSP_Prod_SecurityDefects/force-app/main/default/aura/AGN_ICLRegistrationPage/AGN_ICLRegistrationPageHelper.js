({
    validateAndSaveRecords : function(component,event) {
        //jQuery.noConflict();
        var FinalBrand = '';
        const cmps = component.find("fieldId");
        var requiredMissing = false;
        
        if (!cmps) return;
        var brval = component.get("v.selectedBrandvalues");
        //console.log('brval :'+brval);
        if($A.util.isArray(brval) && brval.length === 0)
        {
            //console.log('NULLL VAL');
            //alert('No brand11');
            var errmsg = $A.get("$Label.c.AGN_ICL_Required_Field_Error") +' '+$A.get("$Label.c.AGN_ICL_Brand");
            this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
        }
        else
        {
            for(var i=0; i< brval.length;i++)
            {
                if(i === 0)
                {
                    FinalBrand = brval[i];
                }
                else
                {
                    FinalBrand = FinalBrand + ';' + brval[i];
                }
            }
            var loclst = component.get("v.Locator_Listing");
            loclst.Brand_AGN__c = FinalBrand;
            component.set("v.Locator_Listing",loclst);
            var reqfield = '';
            if ($A.util.isArray(cmps)){
                cmps.forEach( function (cmp){
                    //if (cmp.get("v.required") && $A.util.isEmpty(cmp.get("v.fieldValue")) && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                    if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                        //console.log('is empty');
                        //cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                        reqfield += cmp.get("v.customLabelName") + ", ";
                        requiredMissing = true;
                    }
                    else{
                        //console.log('is empty'+jQuery.trim(cmp.get("v.fieldValue")));
                        //cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                    }
                });
                if(requiredMissing){
                    component.set("v.RequiredFieldMissing",true);
                    reqfield = reqfield.replace(/,\s*$/, "");
                    var errmsg = $A.get("$Label.c.AGN_ICL_Required_Field_Error") + ' ' +reqfield;
                    this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
                }
                else{
                    if(component.get("v.Locator_Listing.Brand_AGN__c") === null)
                    {
                        this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Required_Field_Error"), 'dismissible'); 
                    }
                    else
                    {
                        //this.validateFormatFields(component, event);
                        this.validateTime(component, event);
                        console.log('Not required');
                    }
                    //this.CreateDifferentObjectData(component,event);
                }
            }
        }
        
        
    },
    validateTime : function(component,event){
        var istimecorrect = true;
        var timefield = '';
        var lclist = component.get("v.Locator_Listing");
        if((lclist.Monday_Open_Hours_AGN__c != null || lclist.Monday_Open_Hours_AGN__c != undefined) && (lclist.Monday_Close_Hours_AGN__c != null || lclist.Monday_Close_Hours_AGN__c != undefined))
        {
            if(lclist.Monday_Open_Hours_AGN__c > lclist.Monday_Close_Hours_AGN__c)
            {
                istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Monday")+ ", ";
            }
        }
        
        if((lclist.Tuesday_Open_Hours_AGN__c != null || lclist.Tuesday_Open_Hours_AGN__c != undefined) && (lclist.Tuesday_Close_Hours_AGN__c != null || lclist.Tuesday_Close_Hours_AGN__c != undefined))
        {
            if(lclist.Tuesday_Open_Hours_AGN__c > lclist.Tuesday_Close_Hours_AGN__c)
            {
                istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Tuesday")+ ", ";
            }
        }
        
        if((lclist.Wednesday_Open_Hours_AGN__c != null || lclist.Wednesday_Open_Hours_AGN__c != undefined) && (lclist.Wednesday_Close_Hours_AGN__c != null || lclist.Wednesday_Close_Hours_AGN__c != undefined))
        {
            if(lclist.Wednesday_Open_Hours_AGN__c > lclist.Wednesday_Close_Hours_AGN__c)
            {
                istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Wednesday")+ ", ";
            }
        }
        
        if((lclist.Thursday_Open_Hours_AGN__c != null || lclist.Thursday_Open_Hours_AGN__c != undefined) && (lclist.Thursday_Close_Hours_AGN__c != null || lclist.Thursday_Close_Hours_AGN__c != undefined))
        {
            if(lclist.Thursday_Open_Hours_AGN__c > lclist.Thursday_Close_Hours_AGN__c)
            {
                istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Thursday")+ ", ";
            }
        }
        
        if((lclist.Friday_Open_Hours_AGN__c != null || lclist.Friday_Open_Hours_AGN__c != undefined) && (lclist.Friday_Close_Hours_AGN__c != null || lclist.Friday_Close_Hours_AGN__c != undefined))
        {
            if(lclist.Friday_Open_Hours_AGN__c > lclist.Friday_Close_Hours_AGN__c)
            {
                istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Friday")+ ", ";
            }
        }
        
        if((lclist.Saturday_Open_Hours_AGN__c != null || lclist.Saturday_Open_Hours_AGN__c != undefined) && (lclist.Saturday_Close_Hours_AGN__c != null || lclist.Saturday_Close_Hours_AGN__c != undefined))
        {
            if(lclist.Saturday_Open_Hours_AGN__c > lclist.Saturday_Close_Hours_AGN__c)
            {
                istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Saturday")+ ", ";
            }
        }
        
        if((lclist.Sunday_Open_Hours_AGN__c != null || lclist.Sunday_Open_Hours_AGN__c != undefined) && (lclist.Sunday_Close_Hours_AGN__c != null || lclist.Sunday_Close_Hours_AGN__c != undefined))
        {
            if(lclist.Sunday_Open_Hours_AGN__c > lclist.Sunday_Close_Hours_AGN__c)
            {
                istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Sunday")+ ", ";
            }
        }
        
        if(!istimecorrect)
        {
            timefield = timefield.replace(/,\s*$/, "");
            var errmsg = $A.get("$Label.c.AGN_ICL_Valid_start_end_time") + ' '+timefield;
            this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
        }
        else
        {
            this.validateFormatFields(component, event);
        }
        
        
    },
    validateFormatFields : function(component,event){
        var wellFormatted = true;
        var whichFields = '';
        var formatfields = '';
        var countryCode = component.get("v.URLCountry");
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            cmps.forEach( function (cmp){
                if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && jQuery.trim(cmp.get("v.fieldValue")) != ''){
                    if(!cmp.get("v.isFormatValid")){
                        //console.log('not formatted');
                        formatfields += cmp.get("v.customLabelName") + ", ";
                        //cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                        wellFormatted = false;
                        //whichFields += cmp.get("v.customLabelName") + ", ";
                    }
                }
                else
                {
                    //cmp.set("v.fieldValueMissing",false);
                    //console.log('Arijit'+component.get("v.isCaptchaValid"));
                }
            });
            
            if(!wellFormatted){
                //component.set("v.fieldWellFormated",false);
                //console.log('not formatted');
                //whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                //var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                formatfields = formatfields.replace(/,\s*$/, "");
                var errmsg = $A.get("$Label.c.AGN_ICL_Field_Format") + ' '+formatfields;
                this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
            }
            else if(component.get("v.isCaptchaValid"))
            {
                if(component.get("v.showClinicConsent"))
                {
                    if(component.get("v.clinicConsent"))
                    {
                        if(component.get("v.termsandcondition"))
                        {
                          
                            //console.log('Captcha Valid');
                            component.set("v.spinner",true);
                            component.set("v.Locator_Listing.Consent_AGN__c",true); 
                            
                            this.CreateDifferentObjectData(component,event);
                        }
                        else
                        {
                            this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Check_Terms_And_Condition"), 'dismissible');
                        }                         
                    } 
                    else
                    {
                       if(countryCode== 'GB')
                    {
                     this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Clinic_Consent_ChkBx_ErrMsg_GB"), 'dismissible');
                    }
                    else
                    {
                    this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Clinic_Consent_ChkBx_ErrMsg"), 'dismissible');
                    }
                    } 
                    
                } 
                else if(component.get("v.termsandcondition"))
                {
                    //console.log('Captcha Valid');
                    component.set("v.spinner",true);
                    component.set("v.Locator_Listing.Consent_AGN__c",true); 
                    //component.set("v.Locator_Listing.Clinic_Consent_AGN__c",true);
                    //component.set("v.Locator_Listing.CASL_Consent_AGN__c",true);
                    this.CreateDifferentObjectData(component,event);
                    
                }
                else
                {
                    this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Check_Terms_And_Condition"), 'dismissible');
                }
                
                
            }
                else
                {
                    this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_You_are_not_robot"), 'dismissible');
                }
        }
    },
    CreateDifferentObjectData : function(component,event){
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            
            cmps.forEach( function (cmp){
                
                //storing all screen data in to relevant object
                if(cmp.get("v.sobjectName") === 'Account'){
                    if(cmp.get("v.TypeofAccount") === 'Clinic')
                    {
                        //console.log('Account Clinic');
                        var derivedField = 'v.Clinic_details.' + cmp.get("v.fieldName");
                        /*if(cmp.get("v.displayType") === 'INTEGER' || cmp.get("v.displayType") === 'DOUBLE')
                        {
                            var value = Number(cmp.get("v.fieldValue"));
                            component.set(derivedField,value);
                        }
                        else
                        {*/
                        component.set(derivedField,cmp.get("v.fieldValue"));
                        //}
                    }
                    else if(cmp.get("v.TypeofAccount") ==='Clinic Admin')
                    {
                        //console.log('Account Admin');
                       
                            var derivedField = 'v.Clinic_Admin_details.' + cmp.get("v.fieldName");
                       
                        /*if(cmp.get("v.displayType") === 'INTEGER' || cmp.get("v.displayType") === 'DOUBLE')
                        {
                            var value = Number(cmp.get("v.fieldValue"));
                            component.set(derivedField,value);
                        }
                        else
                        {*/
                        component.set(derivedField,cmp.get("v.fieldValue"));
                        //}
                        //component.set(derivedField,cmp.get("v.fieldValue"));
                    }
                }
                else if(cmp.get("v.sobjectName") === 'Locator_Listing_AGN__c'){
                    //console.log('Locator Listing');
                    var derivedField = 'v.Locator_Listing.' + cmp.get("v.fieldName");
                    /*if(cmp.get("v.displayType") === 'INTEGER' || cmp.get("v.displayType") === 'DOUBLE')
                    {
                        var value = Number(cmp.get("v.fieldValue"));
                        component.set(derivedField,value);
                    }
                    else
                    {*/
                    component.set(derivedField,cmp.get("v.fieldValue"));
                    //}
                    //component.set(derivedField,cmp.get("v.fieldValue"));
                }
            });
            //console.log('Clinic Admin'+component.get("v.Clinic_Admin_details"));
            //console.log('Clinic'+component.get("v.Clinic_details"));
            //console.log('Locator listing'+component.get("v.Locator_Listing"));
            //this.CreateRecordsInSystem(component,event);
            this.IsDuplicate(component,event);
            //this.CreateNewRecordInSystem(component,event);
        }
    },
    CreateNewRecordInSystem : function(component,event){
        var action = component.get("c.CreateClinicAccount");
        action.setParams({
            'clinic' : component.get('v.Clinic_details'),
            'loc' : component.get('v.Locator_Listing')   
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') 
            {
                var accountval = response.getReturnValue();
                if($A.util.isEmpty(accountval)){
                    component.set("v.spinner",false);
                    self.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
                } else {
                    var action1 = component.get("c.createClinicAdminPersonAccount");
                    action.setParams({
                        'Clinic_Admin_details' : component.get('v.Clinic_Admin_details'),
                        'clinic_detail' : accountval,
                        'loc' : component.get('v.Locator_Listing'),
                        'casl' : component.get('v.CASLConsent')
                       
                        
                    });
                    
                    action1.setCallback(this, function(response){
                        if(response.getState() === 'SUCCESS') 
                        {
                            var accountResp = response.getReturnValue();
                            if($A.util.isEmpty(accountResp)){
                                component.set("v.spinner",false);
                                self.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
                            } else {	
                                component.set("v.spinner",false);
                                component.set("v.RegistrationComplete",true);
                            }
                        }
                        
                    });
                    $A.enqueueAction(action1);
                }
            }
            
        });
        $A.enqueueAction(action);
        
        
        
    },
    IsDuplicate : function(component,event){
        var jsoncust = JSON.parse(JSON.stringify(component.get("v.Clinic_Admin_details")));
        var clinicAdminEmail = jsoncust["PersonEmail"];
        var action1 = component.get("c.IsDuplicateEmail");
        action1.setParams({
            'clinicAdminEmail' : clinicAdminEmail
        });
        action1.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') 
            {
               
                if(!response.getReturnValue())
                {
                     console.log('inside duplicate');
                    this.CreateRecordsInSystem(component,event);
                }
                else
                {
                    component.set("v.spinner",false);  
                    this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Email_Exist"), 'dismissible');
                }
            }
            else
            {
                component.set("v.spinner",false);  
            }
        });
        $A.enqueueAction(action1);
        
    },
    CreateRecordsInSystem : function(component,event){
        
        //GTM
        component.set("v.showGA",true);
        component.set("v.GTMCountry", component.get('v.Locator_Listing.Country_AGN__c'));
        component.set("v.GTMClinicName",component.get('v.Locator_Listing.Name'));
        var street= component.get('v.Locator_Listing.Street_AGN__c');
        var city=component.get('v.Locator_Listing.City_AGN__c');
        var postcode=component.get('v.Locator_Listing.Zip_Code_AGN__c');
        var adress= street + ' ' + city + ' ' + postcode;
        component.set("v.GTMAddress",adress);
        var brand=component.get('v.Locator_Listing.Brand_AGN__c');
        component.set("v.GTMBrand",brand);
        var pageURL=document.URL;
        pageURL =pageURL.split(".com")[1];
        pageURL =pageURL.split("?")[0];
        var pageTitile=document.title;
        component.set("v.GTMPageURL",pageURL);
        component.set("v.GTMPageTitle",pageTitile);
        
        //Added below lines for caslconsent logic
        var caslconsent;
        
            if(component.get("v.showCASLConsent"))
               {
                caslconsent=component.find("caslcheck").get("v.value");
                   
               }
            else
              {
                caslconsent=null;
             }
        //End
        //GTM
        jQuery.noConflict();
        var self = this;   
        self.callServerAction(component, 'c.CreateClinicAccount', {                
            'clinic' : component.get('v.Clinic_details'),
            'loc' : component.get('v.Locator_Listing'),
        })
        .then(
            $A.getCallback(function(accountval) {
                if($A.util.isEmpty(accountval)){
                    self.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
                } else {
                    self.callServerAction(component, 'c.createClinicAdminPersonAccount', {                
                        'Clinic_Admin_details' : component.get('v.Clinic_Admin_details'),
                        'clinic_detail' : accountval,
                        'loc' : component.get('v.Locator_Listing'),
                        'casl_consent' : caslconsent
                    })
                    .then(
                        $A.getCallback(function(accountResp) {
                            //console.log(accountResp);
                            if($A.util.isEmpty(accountResp)){
                                self.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
                            } else {
                                //console.log('PersonAccount id'+accountResp);
                                component.set("v.spinner",false);
                                component.set("v.RegistrationComplete",true);
                            }
                        }))
                    .catch($A.getCallback(function(errorsresp) {
                        component.set("v.spinner",false);
                        self.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error") + ' ' + JSON.stringify(errorsresp), 'dismissible');
                        //self.hideSpinner(component, event);
                        //self.logActionErrors(component, errorsresp);
                    }));
                }
            }))
        .catch($A.getCallback(function(errorsresp) {
            component.set("v.spinner",false);
            self.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error") + ' ' + JSON.stringify(errorsresp), 'dismissible');
            
            //self.hideSpinner(component, event);
            //self.logActionErrors(component, errorsresp);
        }));
        
        //component.set("v.RegistrationComplete",true);
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
            alert(message);
        }
    },
    handleBrandChange: function (component, event, helper) {
        //Get the Selected values   
        var selectedValues = event.getParam("value");         
        //Update the Selected Values  
        component.set("v.selectedBrandvalues", selectedValues);
    },
    
    getSelectedBrand : function(component, event, helper){
        //Get selected Genre List on button click 
        var selectedValues = component.get("v.selectedGenreList");
    }
})