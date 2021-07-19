({ 
    doInit: function(component, event, helper) { 
             
        var query = location.search.substr(1);
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            if(item[0] === 'lcid')
            {
                component.set("v.LocatorListingId",decodeURIComponent(item[1]));
            }
        });        
        //var action = component.get("c.getCountryWiseFieldList");
        component.set("v.spinner",true);
        var action1 = component.get("c.getBrandPicklistValues");
        component.set("v.showGAInit",true);
        //action.setStorable();
        action1.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var lst = response.getReturnValue();
                console.log('Salutation lst'+lst);
                //var BrandList = [];
                var BrandList1 = [];
                var itr=0;
                for(var key in lst){
                    itr++;
                    console.log('nu'+key);
                    //BrandList.push({Name: lst[key], selected: false});
                    BrandList1.push({label : lst[key],value : lst[key]});
                }
                //component.set("v.BrandValues",BrandList);
                component.set("v.brandSize",itr);
                component.set("v.BrandValues1",BrandList1);
                //console.log('Salutation lst111'+component.get("v.SalutationList"));
            }
        });
        $A.enqueueAction(action1);
                // Duallist Box Logic added for Brand 
               component.get("v.brandSize");
            var action5 = component.get("c.getMultipicklistBrandCount");
            action5.setCallback(this, function(response) {
                if(response.getState() === 'SUCCESS') {
                    var mbp = response.getReturnValue();               
                 if( component.get("v.brandSize") > mbp )
                 {
                  component.set("v.showMultiselect",true);
                 }
                }
            });
            $A.enqueueAction(action5);
        // Duallist Box Logic added for Brand END
        
        
        var action = component.get("c.getCountryWiseFieldList");
        /*action.setParams({
            'CountryCode': 'GB' 
            });*/
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('CountryWiseFields list'+result);
                component.set("v.CountryWiseFieldList",result);
                component.set("v.spinner",false);
            }
        });
        $A.enqueueAction(action);
         
        /* var action2 = component.get("c.getPractitionerType");
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                component.set("v.practitionerTypeList", response.getReturnValue());
            } 
           console.log('practitionerTypeList--'+response.getReturnValue());  
        });
        $A.enqueueAction(action2);*/
    },  
    
    scriptsLoaded : function(component, event, helper) {
        jQuery.noConflict();
        console.log('*************** Inside do Init1 Method *****************')
        jQuery("document").ready(function(){
            console.log('Inside jquery'); 
        });
    },
    handleBrandChange: function(component,event, helper){
        
    },
    addPractitioner : function(component, event, helper) {
        helper.ValidateFields(component,event);
        /* const cmps = component.find("fieldId");
        var requiredMissing = false;
        if (!cmps) return;
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
                    cmp.set("v.fieldValueMissing",false); //to hide red color bottom border
                }
            });
            if(requiredMissing){
                //component.set("v.RequiredFieldMissing",true);
                console.log('RequiredFieldMissing');
                this.showTosteMessage(component, '', 'error',$A.get("$Label.c.AGN_ICL_Required_Field_Error"), 'dismissible'); 
                //alert(cmp.get("v.customLabelName") +'---is RequiredFieldMissing.');
            }
            else{
                helper.validateFormatFields(component,event);
                console.log('Not required');
            }
        }
        var cmpEvent = component.getEvent("addPractitionerList");
        cmpEvent.setParams( { "practitioner" : component.get("v.practitioner") } );
        cmpEvent.fire();*/
        
        
    },
    cancelPractitioner : function(component, event, helper) {
        var compEvent = component.getEvent("ClosePopup");
        compEvent.setParams({ "ClosePopupvalue": false });
        //compEvent.setParams({ "message": 'Cool' });
        compEvent.fire();
    },
    //AWS
    handleFilesChange: function(component, event, helper) {
        console.log('dosomething');
        var fileName = $A.get("$Label.c.AGN_ICL_NoneSelected") ;
        
        var fileInput = component.find("fileId").getElement();
        var file = fileInput.files[0];
        console.log('file',file);
        //var fileName;        
        var fileExt = (file.name).substring((file.name).indexOf(".")+1);
        //if (fileExt != 'png' && fileExt != 'jpeg' && fileExt != 'jpg' && fileExt != 'gif') {
        //
        if(!(file.name.indexOf(' ') >= 0))
        {
            if(file.type == 'image/jpeg' || file.type =='image/png'){
                if (file.size <=750000) {            
                    fileName = file.name;
                    component.set("v.imageurl",URL.createObjectURL(file));
                }
                else{
                    alert($A.get("$Label.c.AGN_ICL_Filesize") + '\n' +
                          $A.get("$Label.c.AGN_ICL_Selectedfile")  + file.size/1000 + 'KB');
                    component.set("v.imageurl",null);
                    component.set("v.showLoadingSpinner", false);                
                    return;
                }
            }
            else{
                alert($A.get("$Label.c.AGN_ICL_ImageUpload_ErrMsg") +" "+ fileExt);
                component.set("v.imageurl",null);
                return;
            }
        }
        else{
            alert($A.get("$Label.c.AGN_ICL_ImageUpload_InvalidNameFormat"));
            component.set("v.imageurl",null);
            return;
        }        
        
        component.set("v.fileName", fileName);
    },
    //AWS
    /*showTosteMessage : function(component, title, type, message, mode) {
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
    }*/
})