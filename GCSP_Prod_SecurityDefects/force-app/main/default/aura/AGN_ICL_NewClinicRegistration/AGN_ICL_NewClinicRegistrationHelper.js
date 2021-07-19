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
        var countryCode = component.get("v.iclCountry");
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
                    console.log('formatted');
                    //cmp.set("v.fieldValueMissing",false);
                    //console.log('Arijit'+component.get("v.isCaptchaValid"));
                }
            });
            if(!wellFormatted){
                formatfields = formatfields.replace(/,\s*$/, "");
                var errmsg = $A.get("$Label.c.AGN_ICL_Field_Format") + ' '+formatfields;
                this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
            }
            else if(component.get("v.showClinicConsent"))
            {
                if(component.get("v.clinicConsent"))
                {                    
                    component.set("v.spinner",true);
                    component.set("v.Locator_Listing.Consent_AGN__c",true); 
                    component.set("v.Locator_Listing.Clinic_Consent_AGN__c",true);
                    this.CreateDifferentObjectData(component,event);                                 
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
                else{
                    component.set("v.spinner",true);
                    component.set("v.Locator_Listing.Consent_AGN__c",true); 
                    //component.set("v.Locator_Listing.Clinic_Consent_AGN__c",true);
                    this.CreateDifferentObjectData(component,event); 
                }
            /*if(component.get("v.termsandcondition"))
            {
                component.set("v.spinner",true);
                component.set("v.Locator_Listing.Consent_AGN__c",true);
                this.CreateDifferentObjectData(component,event);
            }
            else
            {
                this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Check_Terms_And_Condition"), 'dismissible');
            }*/
            
            /*if(component.get("v.termsandcondition"))
                {
                	component.set("v.spinner",true);
                    component.set("v.Locator_Listing.Consent_AGN__c",true);
                	this.CreateDifferentObjectData(component,event);*/
            /*}
                else
                {
                    this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Check_Terms_And_Condition"), 'dismissible');
                }*/
            
        }
    },
    CreateDifferentObjectData : function(component,event){
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            
            cmps.forEach( function (cmp){
                
                if(cmp.get("v.sobjectName") === 'Account'){
                    console.log('Account');
                    if(cmp.get("v.TypeofAccount") === 'Clinic')
                    {
                        var derivedField = 'v.Clinic_details.' + cmp.get("v.fieldName");
                        component.set(derivedField,cmp.get("v.fieldValue"));
                    }
                    /*else if(cmp.get("v.TypeofAccount") ==='Clinic Admin')
                    {
                        var derivedField = 'v.Clinic_Admin_details.' + cmp.get("v.fieldName");
                            component.set(derivedField,cmp.get("v.fieldValue"));
                    }*/
                }
                else if(cmp.get("v.sobjectName") === 'Locator_Listing_AGN__c'){
                    var derivedField = 'v.Locator_Listing.' + cmp.get("v.fieldName");
                    component.set(derivedField,cmp.get("v.fieldValue"));
                }
            });
        }
        this.CreateNewRecordInSystem(component,event);
    },
    CreateNewRecordInSystem : function(component,event){
        
        var action1 = component.get("c.CreateNewClinic");
        action1.setParams({
            'loc' : component.get('v.Locator_Listing')
        });
        action1.setCallback(this, function(response){
            console.log('Status :'+response.getState());
            if(response.getState() === 'SUCCESS') 
            {
                var accountResp = response.getReturnValue();
                console.log('accountResp'+accountResp.id);
                console.log('accountResp'+accountResp);
                /*if($A.util.isEmpty(accountResp)){*/
                
                component.set("v.spinner",false);
                component.set("v.RegistrationComplete",true);
                /*self.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
                } else {	
                    component.set("v.spinner",false);
                }*/
            }
            
        });
        $A.enqueueAction(action1);
        
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
    }
})