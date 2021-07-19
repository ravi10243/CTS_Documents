({
    doInitHelper : function(component, event) 
    {
        //alert('FormObject - doInitHelper');
        var actionSObject = component.get("c.GetListOfSObject");
        actionSObject.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                try
                {
                    component.set("v.listSObject",response.getReturnValue());
                    
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_FormPropertiesController - doInit - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionSObject);
        
    },
    doRequiredValidation : function(component,helper){
        console.log("Inside do requied...");
        var isSuccess = true;
        var fieldName = '';

        var objectValue = component.find("objectNameField").get("v.value");
        

        console.log("Object 777: " + objectValue);
        console.log("v.selectedObject SAVEaaaa: " + component.get("v.selectedObject"));
        
        console.log("saveAndNextButtonLabel: " + saveAndNextButtonLabel);
        console.log("saveButtonLabel:" + saveButtonLabel);
        console.log("saveAndPreviousButtonLabel: " + saveAndPreviousButtonLabel);
        
        console.log('object Value:' + objectValue);
        
        if(objectValue == undefined || objectValue == '' || objectValue == null) {
            isSuccess = false;
            fieldName = "Select Object";
            component.set("v.validationFailed", true);
            helper.showMessage(component,fieldName);
            return isSuccess;
        } 
        else {
            var saveButtonLabel = component.find("saveButtonLabelField").get("v.value");
            var saveAndNextButtonLabel = component.find("saveAndNextButtonLabelField").get("v.value");
            var saveAndPreviousButtonLabel = component.find("saveAndPreviousButtonLabelField").get("v.value");
            if (saveButtonLabel == '' || saveButtonLabel == undefined || saveButtonLabel == null) {
                console.log("saveButtonLabel == '' || saveButtonLabel == undefined || saveButtonLabel == null");
                isSuccess = false;
                fieldName = "Save Button Label";
                console.log("saveButtonLabel valdationfailed true");
                component.set("v.validationFailed", true);
                console.log("showmesage");
                helper.showMessage(component,fieldName);
                console.log("returning");
                return isSuccess;
            } else if (saveAndNextButtonLabel == '' || saveAndNextButtonLabel == undefined || saveAndNextButtonLabel == null) {
                console.log("saveAndNextButtonLabel == '' || saveAndNextButtonLabel == undefined || saveAndNextButtonLabel == null");
                isSuccess = false;
                fieldName = "Save and Next Button Label";
                component.set("v.validationFailed", true);
                helper.showMessage(component,fieldName);
                return isSuccess;
            } else if (saveAndPreviousButtonLabel == '' || saveAndPreviousButtonLabel == undefined || saveAndPreviousButtonLabel == null) {
                console.log("saveAndPreviousButtonLabel == '' || saveAndPreviousButtonLabel == undefined || saveAndPreviousButtonLabel == null");
                isSuccess = false;
                fieldName = "Save and Previous Button Label";
                component.set("v.validationFailed", true);
                helper.showMessage(component,fieldName);
                return isSuccess;
            }
        } 
        /*
        //alert(fieldName);
        if(isSuccess == false){
            helper.showMessage(component,fieldName);
        }else {
            //isSuccess = true;
            try {
                console.log("Submitting editform");
                component.find("editform").submit();
            } catch(err) {
                console.log("err " + err);
                console.log(JSON.stringify(err));
                isSuccess = false;
            }
            
        }
        */
        console.log("Subbmitting form...");
        let theForm = component.find("editformobject");
        console.log(theForm);
        component.find("editformobject").submit();
        console.log("Submitted form");
        
        return isSuccess; 
    },
    showMessage : function(component,fieldName) {
        component.find('notifLib').showNotice({
            "variant": "error",
            "header": "Required Field : " + fieldName,
            "message": "This field is Required!!",
            
        });
    }
})