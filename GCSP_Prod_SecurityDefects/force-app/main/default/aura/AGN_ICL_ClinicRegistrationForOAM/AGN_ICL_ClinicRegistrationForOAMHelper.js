({
	validateAndSaveRecords : function(component,event) {
		//jQuery.noConflict();
        const cmps = component.find("fieldId");
         var FinalBrand = '';
        var requiredMissing = false;
        if (!cmps) return;
        
        var brval = component.get("v.selectedBrandvalues");
        //console.log('brval :'+brval);
        if($A.util.isArray(brval) && brval.length === 0)
        {
            console.log('NULLL VAL');
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
                    //console.log('Zero'+FinalBrand);
                }
                else
                {
                    FinalBrand = FinalBrand + ';' + brval[i];
                    //console.log('More'+FinalBrand);
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
                    reqfield += cmp.get("v.customLabelName") + ", ";
                    //cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                    requiredMissing = true;
                }
                else{
                    console.log('is empty'+jQuery.trim(cmp.get("v.fieldValue")));
                    //cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                }
            });
            if(requiredMissing){
                //component.set("v.RequiredFieldMissing",true);
                console.log('RequiredFieldMissing');
                 reqfield = reqfield.replace(/,\s*$/, "");
                var errmsg = $A.get("$Label.c.AGN_ICL_Required_Field_Error") + ' ' +reqfield;
                this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
            }
            else{
                //this.validateFormatFields(component, event);
                this.validateTime(component, event);
                console.log('Not required');
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
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
             cmps.forEach( function (cmp){
                 if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && jQuery.trim(cmp.get("v.fieldValue")) != ''){
                     if(!cmp.get("v.isFormatValid")){
                         formatfields += cmp.get("v.customLabelName") + ", ";
                        //console.log('not formatted');
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
                //component.set("v.fieldWellFormated",false);
                //console.log('not formatted');
                //whichFields = whichFields.replace(/,\s*$/, ""); //This will remove the last comma and any whitespace after it
                //var msg = $A.get("$Label.c.AGN_OAM_Body_PleaseCheckFormatFor") + ' ' + whichFields;
                formatfields = formatfields.replace(/,\s*$/, "");
                var errmsg = $A.get("$Label.c.AGN_ICL_Field_Format") + ' '+formatfields;
                this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
            }
            else if(component.get("v.termsandcondition"))
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
    },
    CreateDifferentObjectData : function(component,event){
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            
            cmps.forEach( function (cmp){
                
                //storing all screen data in to relevant object
                if(cmp.get("v.sobjectName") === 'Locator_Listing_AGN__c'){
                    console.log('Locator Listing');
                    var derivedField = 'v.Locator_Listing.' + cmp.get("v.fieldName");
                    component.set(derivedField,cmp.get("v.fieldValue"));
                }
            });
           
            this.createloc(component,event);
            //this.updateAcc(component,event);
    }
    },
    createloc :function(component,event)
    {
        var action = component.get("c.createLocatorListingData"); 
        action.setParams({
            "loc": component.get("v.Locator_Listing"),
            "clinicAcc":component.get("v.Clinic_details"),
            "clinicAdd":component.get("v.Address_details"),
        }); 
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS') {
                
            this.updateAcc(component,event);
            }
            else
            {
                component.set("v.spinner",false);
                this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
            }
        });$A.enqueueAction(action);
    },
    updateAcc : function(component,event)
    {
         var action = component.get("c.updateClinic"); 
        action.setParams({
            
            "clinicAcc":component.get("v.Clinic_details"),
            "clinicId":component.get("v.clinicID"),
           
        }); 
        action.setCallback(this, function(response){ 
            if(response.getState() === 'SUCCESS') {
                component.set("v.spinner",false);
                component.set("v.RegistrationComplete",true);
                this.showTosteMessage(component, '', 'success',$A.get("$Label.c.AGN_ICL_Registration_Congrts"), 'dismissible');
                //this.Backbuttonhelper(component,event);
                    
            }
            else
            {
                this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
            }
        });$A.enqueueAction(action);
    },
    Backbuttonhelper : function(component,event){
        var urlEvent = $A.get("e.force:navigateToURL");
         urlEvent.setParams({
                "url": "/agn-icl-cliniclistview"
            });
        urlEvent.fire();
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