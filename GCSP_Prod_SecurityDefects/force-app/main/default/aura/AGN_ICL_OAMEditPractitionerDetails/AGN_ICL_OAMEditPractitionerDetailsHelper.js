({
	updatePractitioner: function(component, event) {
        
       //alert('updatePractitioner helper')
       var practitioner = component.get("v.practitioner"); 
       var action = component.get("c.updatePractitionerRecord");
       action.setParams({
            'practitioner': practitioner
        });
        
        action.setCallback(this,function(response){
            if(response.getState()==="SUCCESS" ){
                var compEvent = component.getEvent("CloseEditPopup");
                compEvent.setParams({ "CloseEditPopupvalue": false });
                //compEvent.setParams({ "message": 'Cool' });
                compEvent.fire();
                //alert(practitioner.First_Name_AGN__c+'--Record Updated : ');
                //this.showTosteMessage(component, '', 'success',$A.get("$Label.c.AGN_ICL_Required_Field_Error"), 'dismissible'); 
            }
            });
        $A.enqueueAction(action); 
     },
    ValidateFields : function(component,event){
        const cmps = component.find("fieldId");
        var FinalBrand = ''
        var requiredMissing = false;
        if (!cmps) return;
        var brval = component.get("v.selectedBrandvalues");
        //console.log('brval :'+brval);
        if($A.util.isArray(brval) && brval.length === 0)
        {
            //console.log('NULLL VAL');
            //alert('No brand11');
            this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Required_Field_Error"), 'dismissible'); 
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
            var loclst = component.get("v.practitioner");
            
             //AWS
            var parentid=loclst.Id;
            //AWS
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
                this.validateFormatFields(component,event,parentid);
                console.log('Not required');
            }
        }
        }
        
        /*var cmpEvent = component.getEvent("addPractitionerList");
        cmpEvent.setParams( { "practitioner" : component.get("v.practitioner") } );
        cmpEvent.fire();*/
    },
    validateFormatFields : function(component,event,parentid){
        var wellFormatted = true;
        var whichFields = '';
        const cmps = component.find("fieldId");
        if (!cmps) return;
        if ($A.util.isArray(cmps)){
            cmps.forEach( function (cmp){
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
                    var practitionerFieldVal = cmp.get("v.fieldValue"); 
                    component.set(practitionerField,practitionerFieldVal);*/
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
                var salutation = component.get("v.practitioner.Salutation_AGN__c");
                var practitionerName = salutation.concat(' ',component.get("v.practitioner.First_Name_AGN__c"),' ',component.get("v.practitioner.Last_Name_AGN__c"));
                component.set("v.practitioner.Name",practitionerName);
                //this.updatePractitioner(component,event);
                //AWS
                component.set("v.spinner",true);
                this.uploadHelper(component,event,parentid);
                //AWS
            }
        }
        
    },
     //AWS
    // MAX_FILE_SIZE: 750000,
uploadHelper: function(component, event,parentid) {
        component.set("v.showLoadingSpinner", true);
	var fileInput = component.find("fileId").getElement();
    var file = fileInput.files[0];
    if(file==undefined){
      this.updatePractitioner(component,event);
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
                       //this.showTosteMessage(component, '', 'success',$A.get("$Label.c.AGN_ICL_imagesuccess"), 'dismissible');
                       //$A.get('e.force:refreshView').fire();
                       var attachId = response.getReturnValue();
            console.log('awsupload'+attachId);
                      var loclst = component.get("v.practitioner");
            
            loclst.Practitioner_Image_AGN__c = attachId;
            component.set("v.practitioner",loclst);
                      this.updatePractitioner(component,event);
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