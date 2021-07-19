({
	validateAndSaveRecords : function(component,event) {
		
		 var FinalBrand = '';
        const cmps = component.find("fieldId");
        var requiredMissing = false;
        if (!cmps) return;
        var brval = component.get("v.selectedBrandvalues");
        if($A.util.isArray(brval) && brval.length === 0)
        {
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
                
                if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                    
                    reqfield += cmp.get("v.customLabelName") + ", ";
                    requiredMissing = true;
                }
                else{
                   
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
                    this.validateTime(component, event);
                	console.log('Not required');
                }
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
                //lclist.Monday_Open_Hours_AGN__c = lclist.Monday_Open_Hours_AGN__c + ':00.000';
                //lclist.Monday_Close_Hours_AGN__c = lclist.Monday_Close_Hours_AGN__c + ':00.000';
				istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Monday")+ ", ";
			}
		}
		
		if((lclist.Tuesday_Open_Hours_AGN__c != null || lclist.Tuesday_Open_Hours_AGN__c != undefined) && (lclist.Tuesday_Close_Hours_AGN__c != null || lclist.Tuesday_Close_Hours_AGN__c != undefined))
		{
			if(lclist.Tuesday_Open_Hours_AGN__c > lclist.Tuesday_Close_Hours_AGN__c)
			{
                //lclist.Tuesday_Open_Hours_AGN__c = lclist.Tuesday_Open_Hours_AGN__c + ':00.000';
                //lclist.Tuesday_Close_Hours_AGN__c = lclist.Tuesday_Close_Hours_AGN__c + ':00.000';
				istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Tuesday")+ ", ";
			}
		}
		
		if((lclist.Wednesday_Open_Hours_AGN__c != null || lclist.Wednesday_Open_Hours_AGN__c != undefined) && (lclist.Wednesday_Close_Hours_AGN__c != null || lclist.Wednesday_Close_Hours_AGN__c != undefined))
		{
			if(lclist.Wednesday_Open_Hours_AGN__c > lclist.Wednesday_Close_Hours_AGN__c)
			{
                //lclist.Wednesday_Open_Hours_AGN__c = lclist.Wednesday_Open_Hours_AGN__c + ':00.000';
                //lclist.Wednesday_Close_Hours_AGN__c = lclist.Wednesday_Close_Hours_AGN__c + ':00.000';
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
            /*else
            {
                lclist.Thursday_Open_Hours_AGN__c = lclist.Thursday_Open_Hours_AGN__c + ':00.000';
                lclist.Thursday_Close_Hours_AGN__c = lclist.Thursday_Close_Hours_AGN__c + ':00.000';
            }*/
		}
		
		if((lclist.Friday_Open_Hours_AGN__c != null || lclist.Friday_Open_Hours_AGN__c != undefined) && (lclist.Friday_Close_Hours_AGN__c != null || lclist.Friday_Close_Hours_AGN__c != undefined))
		{
			if(lclist.Friday_Open_Hours_AGN__c > lclist.Friday_Close_Hours_AGN__c)
			{
				istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Friday")+ ", ";
			}
            /*else
            {
                lclist.Friday_Open_Hours_AGN__c = lclist.Friday_Open_Hours_AGN__c + ':00.000';
                lclist.Friday_Close_Hours_AGN__c = lclist.Friday_Close_Hours_AGN__c + ':00.000';
            }*/
		}
		
		if((lclist.Saturday_Open_Hours_AGN__c != null || lclist.Saturday_Open_Hours_AGN__c != undefined) && (lclist.Saturday_Close_Hours_AGN__c != null || lclist.Saturday_Close_Hours_AGN__c != undefined))
		{
			if(lclist.Saturday_Open_Hours_AGN__c > lclist.Saturday_Close_Hours_AGN__c)
			{
				istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Saturday")+ ", ";
			}
            /*else
            {
                lclist.Saturday_Open_Hours_AGN__c = lclist.Saturday_Open_Hours_AGN__c + ':00.000';
                lclist.Saturday_Close_Hours_AGN__c = lclist.Saturday_Close_Hours_AGN__c + ':00.000';
            }*/
		}
		
		if((lclist.Sunday_Open_Hours_AGN__c != null || lclist.Sunday_Open_Hours_AGN__c != undefined) && (lclist.Sunday_Close_Hours_AGN__c != null || lclist.Sunday_Close_Hours_AGN__c != undefined))
		{
			if(lclist.Sunday_Open_Hours_AGN__c > lclist.Sunday_Close_Hours_AGN__c)
			{
				istimecorrect = false;
                timefield += $A.get("$Label.c.AGN_ICL_Sunday")+ ", ";
			}
            /*else
            {
                lclist.Sunday_Open_Hours_AGN__c = lclist.Sunday_Open_Hours_AGN__c + ':00.000';
                lclist.Sunday_Close_Hours_AGN__c = lclist.Sunday_Close_Hours_AGN__c + ':00.000';
            }*/
		}
		
		if(!istimecorrect)
		{
            timefield = timefield.replace(/,\s*$/, "");
            var errmsg = $A.get("$Label.c.AGN_ICL_Valid_start_end_time") + ' '+timefield;
            this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
		}
		else
		{
            component.set("v.Locator_Listing",lclist);
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
                        wellFormatted = false;
                     }
                 }
                 else
                 {
                     console.log('formatted');
                 }
             });
            if(!wellFormatted){
                 formatfields = formatfields.replace(/,\s*$/, "");
                var errmsg = $A.get("$Label.c.AGN_ICL_Field_Format") + ' '+formatfields;
                this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
            }
            else
            {
                component.set("v.spinner",true);
                component.set("v.Locator_Listing.Consent_AGN__c",true);
                this.CreateDifferentObjectData(component,event);
            }
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
        
       /* var action1 = component.get("c.UpdateLocatorListing");
        action1.setParams({
            'loc' : JSON.stringify(component.get("v.Locator_Listing")),
            'lc_Id' : component.get("v.LocatorlistingId")
        });*/
        
        var action1 = component.get("c.insertonlocatorlistingreject");
        action1.setParams({
            'loc' : JSON.stringify(component.get("v.Locator_Listing")),
            'lc_Id' : component.get("v.LocatorlistingId")
        });
        action1.setCallback(this, function(response){
            console.log('Status :'+response.getState());
            if(response.getState() === 'SUCCESS') 
            {
                var accountResp = response.getReturnValue();
                component.set("v.spinner",false);
                component.set("v.UpdateSubmitted",true);
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