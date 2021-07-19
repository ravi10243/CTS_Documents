({
	doInit: function(component, event, helper) { 
        component.set("v.spinner",true);
    var action = component.get("c.getCountryWiseFieldList");
        /*action.setParams({
            'CountryCode': 'GB' 
            });*/
        action.setCallback(this, function(response) {
            if(response.getState() === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('CountryWiseFields list'+result);
                component.set("v.CountryWiseFieldList",result);
                //component.set("v.spinner",false);
                var action4 = component.get("c.getBrandPicklistValues");
                            
                            //action.setStorable();
                            action4.setCallback(this, function(response) {
                                if(response.getState() === 'SUCCESS') {
                                    var lst = response.getReturnValue();
                                    console.log('Salutation lst'+lst);
                                    var BrandList1 = [];
                                    for(var key in lst){
                                        console.log('nu'+key);
                                        BrandList1.push({label : lst[key],value : lst[key]});
                                    }
                                    component.set("v.BrandValues1",BrandList1);
                                    var pract = component.get("v.practitioner");
                                    var brandstr = pract.Brand_AGN__c;
                                    //AWS
                                    var image=pract.Practitioner_Image_AGN__c;
                                    component.set("v.image",image);
                                    console.log('Image'+component.get("v.image"));
                                    //AWS
                                    console.log('Brand list :'+brandstr);
                                    if(brandstr.includes(';') === true)
                                    {
                                        var opt = [];
                                        var singlebrand = brandstr.split(';');
                                        for(var key in singlebrand)
                                        {
                                            console.log('Each brand'+singlebrand[key]);
                                            opt.push(singlebrand[key]);
                                        }
                                        component.set("v.selectedBrandvalues",opt);
                                    }
                                    else
                                    {
                                        component.set("v.selectedBrandvalues",brandstr);
                                    }
                                    component.set("v.spinner",false);
                                }
                            });
                            $A.enqueueAction(action4);
            }
        });
        $A.enqueueAction(action);
        
    },
    HandleSpinner : function(component, event, helper) {
        component.set("v.spinner",false);
    },
	cancelEditPractitioner : function(component, event, helper) {
        var compEvent = component.getEvent("CloseEditPopup");
        compEvent.setParams({ "CloseEditPopupvalue": false });
		//compEvent.setParams({ "message": 'Cool' });
        compEvent.fire();
    },
    handleBrandChange : function(component, event, helper) {
    },
    editPractitioner: function(component, event, helper) {
        //alert('event handler');
       // var practitioner = event.getParams("practitioner"); 
        //alert('event handler'+practitioner);
        //component.set("v.practitioner",practitioner);
    },
    SaveEditPractitioner: function(component, event, helper) {
        helper.ValidateFields(component,event);
    },
    updatePractitioner: function(component, event, helper) {
       //var practitioner = component.get("v.practitioner"); 
       // var nameee=component.get("v.practitioner.First_Name_AGN__c");
       //alert('updatePractitioner controler---'+nameee);
       //helper.updatePractitioner(component,event);
      /** var requiredMissing = false;
       const inputFields = component.find("formId");
        if (!inputFields) return;
        if ($A.util.isArray(inputFields)){
              inputFields.forEach( function (input){
                 if (input.get("v.required") && jQuery.trim(input.get("v.practitioner.First_Name_AGN__c")) == ''){
                    alert('is empty');
                    input.set("v.fieldValueMissing",true); //to show red color bottom border
                    requiredMissing = true;
                    //alert(input.get("v.customLabelName") +'---is Required.');
                }
                else{
                    alert('Not empty'+jQuery.trim(input.get("v.practitioner.First_Name_AGN__c")));
                    input.set("v.fieldValueMissing",false); //to hide red color bottom border
                }
            });
        }**/
        //
        
       alert('Update');
        var practitioner = component.get('v.practitioner');
        
        //const type = component.find("typeId");
       // if(!type) return;
       // if(type !==null){
          var practType=component.get("v.practitioner.Type_AGN__c");
           if(practType ==''){
            alert($A.get("$Label.c.AGN_ICL_Type_Empty"));  
           }else{}
        //} 
        const salutation = component.find("salutationId");
        if(!salutation) return;
        if(salutation !==null){
          var practSalutation=component.get("v.practitioner.Salutation_AGN__c");
           if(practSalutation ==''){
             alert($A.get("$Label.c.AGN_ICL_Salutation_Empty")); 
           }else{}
        } 
        const fName = component.find("fNameId");
        //fNameLblId
        if(!fName) return;
        if(fName !==null){
          var practName=component.get("v.practitioner.First_Name_AGN__c");
           if(practName ==''){ 
             alert($A.get("$Label.c.AGN_ICL_FirstName_Empty")); 
           }else if(!(/^[a-zA-Z]+$/.test(practName)) || !(/^\S{3,}$/.test(practName))){
             alert($A.get("$Label.c.AGN_ICL_FirstName_Invalid"));  
           }else{}
        }
        const lName = component.find("lNameId");
        if(!lName) return;
        if(lName !==null){
          var practLName=component.get("v.practitioner.Last_Name_AGN__c");
           if(practLName ==''){
            alert($A.get("$Label.c.AGN_ICL_LastName_Empty"));
           }else if(!(/^[a-zA-Z]+$/.test(practLName)) || !(/^\S{3,}$/.test(practLName))){
             alert($A.get("$Label.c.AGN_ICL_LastName_Invalid"));  
           }else{} 
        } 
        const brand = component.find("brandId");
        if(!brand) return;
        if(brand !==null){
          var practBrand=component.get("v.practitioner.Brand_AGN__c");
           if(practBrand ==''){
              alert($A.get("$Label.c.AGN_ICL_Brand_Empty")); 
           }else{}
        } 
        
        const qualification = component.find("qualfId");
        if(!qualification) return;
        if(qualification !==null){
          var practQualification=component.get("v.practitioner.Qualification_AGN__c");
           if(practQualification =='' || practQualification == 'undefined'){
            alert($A.get("$Label.c.AGN_ICL_Qualification_Empty"));
           }else{}
        } 
        const gender = component.find("genderId");
        if(!gender) return;
        if(gender !==null){
          var practGender=component.get("v.practitioner.Gender_AGN__c");
           if(practGender ==''){
              alert($A.get("$Label.c.AGN_ICL_Gender_Empty")); 
           }else{}
        } 
        const experience= component.find("experienceId");
        if(!experience) return;
        if(experience !==null){
          var practExperience=component.get("v.practitioner.Years_of_Experience_AGN__c");
           if(practExperience ==''){
            alert($A.get("$Label.c.AGN_ICL_Experience_Empty"));   
           }else{
           }
        }
        const email = component.find("emailId");
        var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        if(!email) return;
        if(email !==null){
          var practEmail=component.get("v.practitioner.Email_AGN__c");
           if(practEmail ==''){
             alert($A.get("$Label.c.AGN_ICL_Email_Empty")); 
           }else if(reg.test(practEmail) == false){
             alert($A.get("$Label.c.AGN_ICL_Email_Invalid"));  
           }else{
           }
        }
        const physicianType= component.find("physiTypeId");
        if(!physicianType) return;
        if(physicianType!==null){
          var practPhysicianType=component.get("v.practitioner.Type_Of_Physician_AGN__c");
           //if(practPhysicianType =='' || physicianType==null){
           if(practPhysicianType ==''){
             alert($A.get("$Label.c.AGN_ICL_Physician_Type_Empty"));    
           }else{}
       }
        helper.updatePractitioner(component,event);
    },
    handleBlur : function(component, event) {
        jQuery.noConflict();
        //if(component.get('v.fieldValue')==null ||component.get('v.fieldValue')=='')
          if(component.get('v.practitioner')==null ||component.get('v.practitioner')=='')
        {
            component.set('v.containsValue',false);
            console.log('false');
        }
        else
        {
            component.set('v.containsValue',true);
            console.log('true');
        }
    },
    SetGenderValue :function(component, event) {
        alert('---'+component.get('v.practitioner.Gender_AGN__c'));
        component.set('v.practitioner.Gender_AGN__c',component.get('v.practitioner.Gender_AGN__c'));
 },
    SetSalutationValue :function(component, event) {
        alert('---'+component.get('v.practitioner.Salutation_AGN__c'));
        component.set('v.practitioner.Salutation_AGN__c',component.get('v.practitioner.Salutation_AGN__c'));
 },
    SetBrandValue :function(component, event) {
        alert('---'+component.get('v.practitioner.Brand_AGN__c'));
        component.set('v.practitioner.Brand_AGN__c',component.get('v.practitioner.Brand_AGN__c'));
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
        
          component.set("v.image",URL.createObjectURL(file));
                   
        }
            if (file.size > 750000) {
             alert($A.get("$Label.c.AGN_ICL_Filesize") + '\n' +
              $A.get("$Label.c.AGN_ICL_Selectedfile")  + file.size/1000+'KB');
                 component.set("v.image",null);
             component.set("v.showLoadingSpinner", false);
        return;
        
       
     
        }
          component.set("v.fileName", fileName);

            
    },
    //AWS
    SetTypeValue :function(component, event) {
        alert('---'+component.get('v.practitioner.Type_AGN__c'));
        component.set('v.practitioner.Type_AGN__c',component.get('v.practitioner.Type_AGN__c'));
   }
})