({
    showMessage : function(component,fieldName) {
        component.find('notifLib').showNotice({
            "variant": "error",
            "header": "Required Field : " + fieldName,
            "message": "This field is Required!!",
            
        });
    },
    
    doRequiredValidation : function(component,helper){
        var isSuccess = true;
        var fieldName = '';
        var nameField = component.find("NameField").get("v.value");
        var urlField = component.find("urlField").get("v.value");
        var typeField = component.find("typeField").get("v.value");
        var formTitleField = component.find("formTitleField").get("v.value");
        var formDescriptionField = component.find("formDescriptionField").get("v.value");
       
        
        if (formDescriptionField == '' || formDescriptionField == null) {
            isSuccess = false;
            fieldName = "Form Description";
        }
        
        if (formTitleField == '' || formTitleField == null) {
            isSuccess = false;
            fieldName = "Form Title";
        } 
        
        
        console.log('nameField val--' + nameField);
        
        if(typeField == '') {
            isSuccess = false;
            fieldName = "Type";
        }        
        
        if(urlField == '' || urlField == null){
            isSuccess = false;
            fieldName = "URL Key";
        }
        
        if(nameField == '' || nameField == null){
            isSuccess = false;
            fieldName = "Developer Name";
            //$A.util.addClass(component.find("urlField"), "myClass");
        }
        
        if(isSuccess == false){
            helper.showMessage(component,fieldName);
        } else {
            //isSuccess = true;
            component.find("editform").submit();
            try {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success Message',
                    message: 'Form Details have been saved!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                
                toastEvent.fire();
            }
            catch(err) {
                alert('MDFormBuilderController - CMSWStep_FormDetailsController - doRequiredValidation - Error :: ' + err);
            }
        }
        
        return isSuccess; 
    }
})