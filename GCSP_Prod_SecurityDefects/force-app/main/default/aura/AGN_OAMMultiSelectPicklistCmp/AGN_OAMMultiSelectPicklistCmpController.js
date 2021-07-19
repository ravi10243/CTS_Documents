({
	doInit : function(component) {
        // console.log("inside multi select picklist");
        var fieldName = component.get("v.fieldName");
       // console.log(fieldName);
        if(fieldName === 'Product_Interest_AGN__c' && !$A.util.isEmpty(component.get("v.customLabel"))){
           // helper.getPicklistOptions(component,helper);
           // console.log("customLabel>>>>>>>>>>>>>>"+component.get("v.customLabel"));
            var dynamicLabel = $A.getReference("$Label.c." + component.get("v.customLabel"));
            //console.log("dynamicLabel>>>>>>>>>>>>>>>"+dynamicLabel);
            component.set("v.customLabelName" , dynamicLabel);
            component.set("v.required" , true);
            
           
        var action = component.get("c.getOptions");
        action.setParams({ 
                           ObjectName : component.get("v.sobjectName"),
                           fieldName : component.get("v.fieldName")
                        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server:::::::::::::: "+ JSON.stringify(response.getReturnValue()));
                component.set("v.options" , response.getReturnValue());
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action); 
        }
        
       
    	// Initialize input select options
    	/*
        var opts = [
            { "class": "optionClass", label: "Option1", value: "opt1", selected: "true" },
            { "class": "optionClass", label: "Option2", value: "opt2" },
            { "class": "optionClass", label: "Option3", value: "opt3" }

        ];
        cmp.find("InputSelectDynamic").set("v.options", opts);*/
        
    },
    onMultiSelectChange: function(component,event) {

         var selectCmp = component.find("InputSelectMultiple");
        // var resultCmp = component.find("multiResult");
         //resultCmp.set("v.value", selectCmp.get("v.value"));
                
        // console.log("selected value>>>>>>>>>>>>>"+selectCmp.get("v.value"));
         component.set("v.fieldValue" , selectCmp.get("v.value"));
          console.log("selected value>>>>>>>>>>>>>"+component.get("v.fieldValue"));
	 }
})