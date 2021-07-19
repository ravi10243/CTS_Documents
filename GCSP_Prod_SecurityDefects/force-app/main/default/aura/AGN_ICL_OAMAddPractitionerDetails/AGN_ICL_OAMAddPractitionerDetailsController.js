({ 
     doInit: function(component, event, helper) { 
        //var action = component.get("c.getCountryWiseFieldList");
        //
       
         var query = location.search.substr(1);
		query.split("&").forEach(function(part) {
		var item = part.split("=");
		 if(item[0] === 'lcid')
            {
                component.set("v.LocatorListingId",decodeURIComponent(item[1]));
            }
		   });     
        component.set("v.spinner",true);
         var action1 = component.get("c.getBrandPicklistValues");
        
        //action.setStorable();
        action1.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var lst = response.getReturnValue();
                console.log('Salutation lst'+lst);
                //var BrandList = [];
                var BrandList1 = [];
                for(var key in lst){
                    console.log('nu'+key);
                    //BrandList.push({Name: lst[key], selected: false});
                    BrandList1.push({label : lst[key],value : lst[key]});
                }
                //component.set("v.BrandValues",BrandList);
                component.set("v.BrandValues1",BrandList1);
                //console.log('Salutation lst111'+component.get("v.SalutationList"));
                
            }
        });
         $A.enqueueAction(action1);
        var action = component.get("c.getCountryWiseFieldList");
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('CountryWiseFields list'+result);
                component.set("v.CountryWiseFieldList",result);
                component.set("v.spinner",false);
            }
        });
       $A.enqueueAction(action);
         
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
            if (fileExt != 'png' && fileExt != 'jpeg' && fileExt != 'jpg' && fileExt != 'gif') {
                alert(' Only image files (png, jpeg, jpg and gif) are supported.\n Selected file type: .' + fileExt);
                return;
            }
       
       if (file.size <=750000) {
     
            fileName = file.name;
        
          component.set("v.imageurl",URL.createObjectURL(file));
                   
        }
            if (file.size > 750000) {
             alert($A.get("$Label.c.AGN_ICL_Filesize") + '\n' +
              $A.get("$Label.c.AGN_ICL_Selectedfile")  + file.size/1000 + 'KB');
                 component.set("v.imageurl",null);
             component.set("v.showLoadingSpinner", false);
        return;
        
       
     
        }
          component.set("v.fileName", fileName);

            
    },
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