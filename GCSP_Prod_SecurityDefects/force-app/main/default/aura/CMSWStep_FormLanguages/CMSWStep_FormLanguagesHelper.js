({
	doInitHelper : function(component, event) 
    {
        //alert('doInitHelper' + component.get("v.recordId"));
        var actionLanguage = component.get("c.GetLocalisedMDFormRecords");
        actionLanguage.setParams({
            mdFormId : component.get("v.recordId")
        });
        actionLanguage.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") 
            {
                try
                {
                    component.set("v.listLocalisedMDForm",response.getReturnValue());
                    //alert('doInitHelper' + component.get("v.listLocalisedMDForm").length);
                }
                catch(err)
                {
                    alert('MDFormBuilderController - CMSWStep_FormLanguagesController - doInit - Error :: ' + err);
                }
            }
        });
        $A.enqueueAction(actionLanguage); 	
	},
    doRequiredValidation : function(component,helper){
        var isSuccess = true;
        var fieldName = '';
        console.log('saving lang--');
        var langValue = component.find("langField").get("v.value");
        //var titleValue = component.find("titleField").get("v.value");
        console.log('saving lang2--' + langValue);
        //alert(component.find("titleField").size);
        if(langValue == undefined || langValue == ''){
            isSuccess = false;
            fieldName = "Language";
        }
        if(titleValue == undefined || titleValue == ''){
            isSuccess = false;
            //fieldName = "Form Title";
        }
      	//alert(fieldName);
        if(!isSuccess){
            helper.showMessage(component,fieldName);
        }else {
            //isSuccess = true;
            alert(fieldName);
            component.find("editform").submit();
        }
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