({
    addPractitioner : function(component, event, helper) {
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            cmps.forEach( function (cmp){
                console.log('APIName-'+cmp.get("v.fieldName"));
                console.log('APIValue-'+cmp.get("v.fieldValue"));
                var practitionerField = 'v.practitioner.' + cmp.get("v.fieldName"); 
                var practitionerFieldVal = cmp.get("v.fieldValue"); 
                component.set(practitionerField,practitionerFieldVal);
            });
        }
        var salutation = component.get("v.Salutation");
        var practitionerName = salutation.concat(' ',component.get("v.practitioner.First_Name_AGN__c"),' ',component.get("v.practitioner.Last_Name_AGN__c"));
        component.set("v.practitioner.Name",practitionerName);
        var practitionerType = component.get("v.practitionerType");
        var practitioner=component.get("v.practitioner");
        component.set("v.practitioner.Type_AGN__c",practitionerType);
        var action = component.get("c.addPractitionerRecord");
        action.setParams({
            practitioner : practitioner
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                alert('SUCCESS');
            }
        });
        $A.enqueueAction(action);
        var cmpEvent = component.getEvent("addPractitionerList");
        cmpEvent.setParams( { "practitioner" : component.get("v.practitioner") } );
        cmpEvent.fire();
    },
    fetchGenderPicklist : function(component){
        //alert('Inside doInit');
        var action = component.get("C.fetchPicklistValues");
        action.setParams({
            'objectName': 'Practitioner_Listing_AGN__c',
            'field_apiName': 'Gender_AGN__c',
            'nullRequired': true 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.Genderlist", response.getReturnValue());
                //alert('Gender values--'+response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    fetchSalutationPicklist : function(component){
        var action = component.get("C.fetchPicklistValues");
        action.setParams({
            'objectName': 'Account',
            'field_apiName': 'Salutation',
            'nullRequired': true 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.Salutationlist", response.getReturnValue());
                //alert('Brand values--'+response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    ValidateFields : function(component,event){
        const cmps = component.find("fieldId");
        var requiredMissing = false;
        if (!cmps) return;
        var FinalBrand = '';
        var brval = component.get("v.selectedBrandvalues");
        console.log('brval :'+brval);
        if($A.util.isArray(brval) && brval.length === 0)
        {
            console.log('NULLL VAL');
            //alert('No brand11');
            this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Required_Field_Error"), 'dismissible'); 
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
            var loclst = component.get("v.practitioner");
            loclst.Brand_AGN__c = FinalBrand;
            component.set("v.practitioner",loclst);
            
            if ($A.util.isArray(cmps)){
                cmps.forEach( function (cmp){
                    if (cmp.get("v.required") && jQuery.trim(cmp.get("v.fieldValue")) == ''){
                        console.log('is empty');
                        //cmp.set("v.fieldValueMissing",true); //to show red color bottom border
                        requiredMissing = true;
                        //alert(cmp.get("v.customLabelName") +'---is Required.');
                    }
                    else{
                        console.log('is empty'+jQuery.trim(cmp.get("v.fieldValue")));
                        //cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                    }
                });
                if(requiredMissing){
                    //component.set("v.RequiredFieldMissing",true);
                    console.log('RequiredFieldMissing');
                    this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Required_Field_Error"), 'dismissible'); 
                    //alert(cmp.get("v.customLabelName") +'---is RequiredFieldMissing.');
                }
                else{
                    this.validateFormatFields(component,event);
                    console.log('Not required');
                }
            }
        }
        
        
        /*var cmpEvent = component.getEvent("addPractitionerList");
        cmpEvent.setParams( { "practitioner" : component.get("v.practitioner") } );
        cmpEvent.fire();*/
    },
    validateFormatFields : function(component,event){
        var wellFormatted = true;
        var whichFields = '';
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            cmps.forEach( function (cmp){
                console.log('FieldName : '+cmp.get("v.fieldName"));
                if (!$A.util.isEmpty(cmp.get("v.fieldRegex")) && jQuery.trim(cmp.get("v.fieldValue")) != ''){
                    if(!cmp.get("v.isFormatValid")){
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
                    //Create the record here.
                    /*var practitionerField = 'v.practitioner.' + cmp.get("v.fieldName"); 
                    console.log('FieldName 11: '+cmp.get("v.fieldName"));
                    var practitionerFieldVal = cmp.get("v.fieldValue"); 
                    console.log('FieldValue 11: '+cmp.get("v.fieldValue"));
                    component.set(practitionerField,practitionerFieldVal);
                    console.log('Practitioner type val:'+component.get("v.practitioner.Type_AGN__c"));*/
                }
            });
            if(!wellFormatted){
                //alert(cmp.get("v.customLabelName") +'---Not WellFormatted');
                this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Field_Format"), 'dismissible');
                console.log('not formatted');
            }
            else{
                const cmps = component.find("fieldId");
                if (!cmps) return;
                if ($A.util.isArray(cmps)){
                    
                    cmps.forEach( function (cmp){
                        var practitionerField = 'v.practitioner.' + cmp.get("v.fieldName"); 
                        //console.log('FieldName 11: '+cmp.get("v.fieldName"));
                        var practitionerFieldVal = cmp.get("v.fieldValue"); 
                        //console.log('FieldValue 11: '+cmp.get("v.fieldValue"));
                        component.set(practitionerField,practitionerFieldVal);
                        });
                }
                console.log('Record Creation Starts');
                //var practitionerType = component.get("v.practitionerType");
                var practitioner=component.get("v.practitioner");
                //console.log('JSON List :'+JSON.stringify(component.get("v.practitioner")));
                //component.set("v.practitioner.Type_AGN__c",practitionerType);
                var salutation = component.get("v.practitioner.Salutation_AGN__c");
                var practitionerName = salutation.concat(' ',component.get("v.practitioner.First_Name_AGN__c"),' ',component.get("v.practitioner.Last_Name_AGN__c"));
                component.set("v.practitioner.Name",practitionerName);
                var action = component.get("c.addPractitionerRecord");
                action.setParams({
                    practitioner : practitioner,
                    loclstId : component.get("v.LocatorListingId")
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        //alert('SUCCESS');
                        var newpract = response.getReturnValue();
                        /*var compEvent = component.getEvent("ClosePopup");
                        compEvent.setParams({ "ClosePopupvalue": false });
                        //compEvent.setParams({ "message": 'Cool' });
                        compEvent.fire();*/
                        
                        var practEvent = $A.get("e.c:AGN_ICL_AddPractitioners"); // Event to refresh practitioners list
                        //Set event attribute value
                        var ab = 'ffdfd';
                        practEvent.setParams({"practitionerid" : newpract.id}); 
                        //practEvent.fire();  
                        setTimeout(function(){ practEvent.fire();  }, 5000);
                        //AWS                       
                     //console.log(newpract);
                      for(var propt in newpract)
               	 {
                    //console.log(propt +"  "+ newpract[propt]);
                    if(propt=='Id')
                    {
                         component.set("v.parentId", newpract[propt]);
                    }
                    
                
                }
                        var parentid=component.get("v.parentId");
			            //console.log('inserthelperaws1'+component.get("v.parentId"));
                      
                          this.uploadHelper(component, event,parentid);
                                                
                         
                     //AWS
                    }
                });
                $A.enqueueAction(action);
            }
        }
        
    },
      //AWS
   // MAX_FILE_SIZE: 750000,
	uploadHelper: function(component, event,parentid) {
        //component.set("v.showLoadingSpinner", true);
			var fileInput = component.find("fileId").getElement();
        console.log('files',fileInput);
        var file = fileInput.files[0];
       
           if(file==undefined){
               component.set("v.spinner",false);
      //this.updatellisting(component,event);
       var compEvent = component.getEvent("ClosePopup");
                        compEvent.setParams({ "ClosePopupvalue": false });
                        //compEvent.setParams({ "message": 'Cool' });
                        compEvent.fire();
        } 
        else
        {
var file = fileInput.files[0];          
    console.log('parentid'+parentid);
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
        var action = component.get("c.image"); 
 	    console.log('parentid'+parentid);
        
                  action.setParams({
             parentId: parentid,
            fileName1: file.name,
            base64Data: encodeURIComponent(fileContents), 
            contentType: file.type
        });
       
        
        action.setCallback(this, function(response) {
             if(component.isValid()) {
                    if(response.getState() === 'SUCCESS') {
                     //alert( $A.get("$Label.c.AGN_ICL_imagesuccess"));
                     this.showTosteMessage(component, '', 'success',$A.get("$Label.c.AGN_ICL_imagesuccess"), 'dismissible');
                       //$A.get('e.force:refreshView').fire();
                       var attachId = response.getReturnValue();
            console.log('awsupload'+attachId);
                        component.set("v.spinner",false);
                      var compEvent = component.getEvent("ClosePopup");
                        compEvent.setParams({ "ClosePopupvalue": false });
                        //compEvent.setParams({ "message": 'Cool' });
                        compEvent.fire();
                      
                  }
                 else
                 {
                     component.set("v.spinner",false);
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
            
       
            $A.enqueueAction(action); 
       
    },
   
    //AWS
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