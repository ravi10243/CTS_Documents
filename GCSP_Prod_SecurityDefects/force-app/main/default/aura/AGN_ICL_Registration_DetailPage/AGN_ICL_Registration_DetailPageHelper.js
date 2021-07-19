({
    validateAndSaveRecords1 : function(component,event) {
        console.log('save button111111');
        var FinalBrand = '';
        const cmps = component.find("fieldId");
        //console.log('dfdfd');
        if (!cmps) return;
        var requiredMissing = false;
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
                //console.log('NULLL VAL11');
                if(i === 0)
                {
                    //console.log('NULLL VAL1122');
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
            
              //AWS
            var parentid=loclst.Id;
            console.log('Parent',parentid);
            //AWS
            var reqfield = '';
            if ($A.util.isArray(cmps)){
                cmps.forEach( function (cmp){
                    if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                        reqfield += cmp.get("v.customLabelName") + ", ";
                        //console.log('is empty');
                        //cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                        requiredMissing = true;
                    }
                    else{
                        //console.log('is empty'+jQuery.trim(cmp.get("v.fieldValue")));
                        //cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                    }
                });
                
                if(requiredMissing)
                {
                    //component.set("v.RequiredFieldMissing",true);
                     reqfield = reqfield.replace(/,\s*$/, "");
                    var errmsg = $A.get("$Label.c.AGN_ICL_Required_Field_Error") + ' ' +reqfield;
                    this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
                }
                else{
                    //this.validateFormatFields(component, event,parentid);
                    this.validateTime(component, event,parentid);
                    //this.CreateDifferentObjectData(component,event);
                }  
            }
        }
        
    },
    validateTime : function(component,event,parentid){
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
			this.validateFormatFields(component, event,parentid);
		}
        
         
    },
    validateFormatFields : function(component,event,parentid){
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
                        //cmp.set("v.fieldValueMissing",true);
                        wellFormatted = false;
                        //whichFields += cmp.get("v.customLabelName") + ", ";
                    }
                }
                else
                {
                    //cmp.set("v.fieldValueMissing",false);
                }
            });
            if(!wellFormatted){
                formatfields = formatfields.replace(/,\s*$/, "");
                var errmsg = $A.get("$Label.c.AGN_ICL_Field_Format") + ' '+formatfields;
                this.showTosteMessage(component, '', 'error',errmsg, 'dismissible');
            }
            else
            {
                this.CreateDifferentObjectData(component,event,parentid);
            }
        }
    },
    CreateDifferentObjectData : function(component,event,parentid){
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            
            cmps.forEach( function (cmp){
                
                //Storing all screen data in to relevant object
                if(cmp.get("v.sobjectName") === 'Account'){
                    console.log('Account');
                    if(cmp.get("v.TypeofAccount") === 'Clinic')
                    {
                        console.log('Account Clinic');
                        var derivedField = 'v.Clinic_details.' + cmp.get("v.fieldName"); 
                        component.set(derivedField,cmp.get("v.fieldValue"));
                    }
                    else if(cmp.get("v.TypeofAccount") ==='Clinic Admin')
                    {
                        console.log('Account Admin');
                        var derivedField = 'v.Clinic_Admin_details.' + cmp.get("v.fieldName"); 
                        
                        component.set(derivedField,cmp.get("v.fieldValue"));
                    }
                }
                else if(cmp.get("v.sobjectName") === 'Locator_Listing_AGN__c'){
                    
                    var derivedField = 'v.Locator_Listing.' + cmp.get("v.fieldName"); 
                    component.set(derivedField,cmp.get("v.fieldValue"));
                }
            });
            component.set("v.spinner",true);
            //this.updatellisting(component,event);
            //AWS
                this.uploadHelper(component,event,parentid);
            //AWS
        }
    },
    updatellisting :function(component,event)
    {
        console.log('update locater listing');
        //console.log('Locator_Listing : '+JSON.stringify(component.get("v.Locator_Listing")));
        //console.log('LocatorListingID : '+component.get("v.LocatorListingID"));
        var action = component.get("c.updateRec"); 
        action.setParams({
            'loc' : JSON.stringify(component.get("v.Locator_Listing")),
            'lc_Id' :component.get("v.LocatorListingID")
        }); 
       
        action.setCallback(this, function(response){
            //console.log('state'+response.getState());
            if(response.getState() === 'SUCCESS') {
            var lc= response.getReturnValue(); 
                component.set("v.spinner",false);
                component.set("v.editBtn",true);  
            //console.log('call back'+lc);
            }
            else
            {
                component.set("v.spinner",false);
                this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Unknown_Error"), 'dismissible');
            }
        });$A.enqueueAction(action);
    },
    /*updateTime : function(component,event)
    {          
        const cmps = component.find("dateId");
        if ($A.util.isArray(cmps)){
            cmps.forEach( function (cmp){
                if (cmp.get("v.required") && jQuery.trim(cmp.get("v.value")) == ''){
                    console.log("Hello Fireinds Value de do ");
                    //missing message
                }
                else{
                    console.log('Balle Balle Time '+jQuery.trim(cmp.get("v.value")));
                    
                } 
            });
        }
        this.DbTimeUpadte(component,event);
    },
    DbTimeUpadte :function(component,event)
    {
        var action = component.get("c.updateTimeDB"); 
        action.setParams({
            "loc": component.get("v.Locator_Listing"),
            "lc_Id":component.get("v.LocatorListingID")
        }); 
        action.setCallback(this, function(a){  
        });$A.enqueueAction(action);
    },*/
    //AWS
     uploadHelper: function(component, event,parentid) {
        component.set("v.showLoadingSpinner", true);
	var fileInput = component.find("fileId").getElement();
   var file = fileInput.files[0];
    if(file==undefined){
      this.updatellisting(component,event);
        } 
        else
        {
var file = fileInput.files[0];    
   
    console.log('ParentID'+parentid);
        var fr = new FileReader();
        
        var self = this;
        fr.onload =  $A.getCallback(function() {
            var fileContents = fr.result;
        var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
 
            fileContents = fileContents.substring(dataStart);
        self.upload(component, file, fileContents,parentid);
        });
 
        fr.readAsDataURL(file);
        }
    },
        
    upload: function(component, file, fileContents,parentid) {
        var actions = component.get("c.locatorimage"); 
      console.log('ParentID'+parentid);
        actions.setParams({
             parentId: parentid,
            fileName1: file.name,
            base64Data: encodeURIComponent(fileContents), 
            contentType: file.type
        });
 
        actions.setCallback(this, function(response) {
             if(component.isValid()) {
                  if(response.getState() === 'SUCCESS') {
                         alert( $A.get("$Label.c.AGN_ICL_imagesuccess"));
                       var attachId = response.getReturnValue();
            console.log('awsupload'+attachId);
                      var loclst = component.get("v.Locator_Listing");
            
            loclst.Clinic_Image_AGN__c = attachId;
            component.set("v.Locator_Listing",loclst);
                      console.log('done');
                      this.updatellisting(component,event);
                  }
                 else
                 {
                     console.log('awserror');
                     var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                }
                 }
             }
             });
            
       
            $A.enqueueAction(actions); 
    
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
            alert(title + ' ' + message);
        }
    }
})