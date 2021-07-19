({
    doInit : function(component, event, helper) {
        //alert('FormObject - Init');
        helper.doInitHelper(component, event) ;
    },
    doSaveFormObjectInfo : function(component, event, helper) {
        var isSuccess = helper.doRequiredValidation(component,helper);
    },
    onFormLoad : function(component, event, helper) 
    {
        alert('FormObject - onFormLoad');
        var recordUI = event.getParam("recordUi");
        if(recordUI)
        {
            var recordFields = recordUI.record.fields;
            var formAPIName = recordFields["ObjectAPIName__c"].value;
            //alert(formAPIName);
            component.set("v.selectedObject", formAPIName);
        }
    },
    onFormSuccess : function(component, event, helper) 
    {
        alert('FormObject - onFormSuccess');
    },
    
    saveComponentData: function(component, event,helper)
    {
        console.log("Ready to save");
        var params = event.getParam('arguments');
        if(params)
        {
            console.log("running do requiredValdation");
            //alert("hello");
            var isSuccess = helper.doRequiredValidation(component,helper);
        }
        return isSuccess; 
    },
    showSelected : function(component, event, helper) {
        //console.log(component.get("v.formAPIName"));
    },
    onObjectChange : function(component, event, helper) {
        const objectSelected = component.find('objectSelect').get('v.value');
        //console.log("Picked: " + objectSelected);
        console.log(objectSelected);
        if(objectSelected && objectSelected != '' && objectSelected != 'Choose Object..') {
            //console.log("Changing value");
            component.set("v.selectedObject", objectSelected);
            //console.log("v.selectedObject: " + component.get("v.selectedObject"));
            
            component.find("objectNameField").set("v.value", objectSelected);
            
        } else {
            //console.log("Changing value");
            component.set("v.selectedObject", objectSelected);
            //console.log("v.selectedObject: " + component.get("v.selectedObject"));
            component.find("objectNameField").set("v.value", objectSelected);
        }
        
    },
    doneRendering : function(component, event, helper) {
        const selected = component.find("objectNameField").get("v.value"); 
        if(selected) {
            component.set("v.selectedObject", selected);
        }
    },
    onError : function(component, event, helper) {
        console.log("Error occured");
        var error = event.getParam("error");
        console.log(error.message); // main error message
        
        // top level error messages
        error.data.output.errors.forEach(
            function(msg) { console.log(msg.errorCode); 
                           console.log(msg.message); }
        );
        
        // field specific error messages
        Object.keys(error.data.output.fieldErrors).forEach(
            function(field) { 
                error.data.output.fieldErrors[field].forEach(
                    function(msg) { console.log(msg.fieldName); 
                                   console.log(msg.errorCode); 
                                   console.log(msg.message); }
                )
            });
    }
})