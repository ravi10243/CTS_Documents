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
                    
                   
                
                
                var action = component.get("c.getPicklistOptions");
                action.setParams({ 
                                   ObjectName : component.get("v.sobjectName"),
                                   fieldName : component.get("v.fieldName")
                                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        console.log("From server:::::::::::::: "+ JSON.stringify(response.getReturnValue()));
                        //component.set("v.options" , response.getReturnValue());
                        var prodOptions = [];
                        var optionMap = new Map();
                        var options = response.getReturnValue();
                        if(!$A.util.isEmpty(options)){
                            options.forEach(function(cmp){
                                 optionMap.set(cmp.value ,cmp.label);                            
                            });
                        }
                        console.log('optionMap>>>>>>>>>>>>>>>>>>>>>',optionMap);
                        var customerGroup = component.get("v.customerGroup");
                        var customerTypeConfig = component.get("v.customerTypeConfig");
                        console.log('customerGroup>>>>>>>>>>>>>>>>>>>>'+customerGroup);
                        console.log('customerTypeConfig>>>>>>>>>>>>>>>>>>>>'+JSON.stringify(customerTypeConfig));
                        if(!$A.util.isEmpty(customerTypeConfig) && !$A.util.isEmpty(optionMap)){
                            customerTypeConfig.forEach(function(cmp){
                                
                              //  console.log('cmp.Customer_Group_AGN__c : '+cmp.Customer_Group_AGN__c+ 'customerGroup : '+customerGroup+' cmp.Product_Interest_AGN__c : '+cmp.Product_Interest_AGN__c);
                                if(!$A.util.isEmpty(customerGroup) 
                                   && !$A.util.isEmpty(cmp.Product_Interest_AGN__c) 
                                   && cmp.Customer_Group_AGN__c === customerGroup){
                                 
                                    var ops = cmp.Product_Interest_AGN__c.split(';');
                                    console.log('Current Product Interest Options>>>>>>>>>>>>>>>',ops);
                                    if(!$A.util.isEmpty(ops)){
                                        ops.forEach(function(op){
                                            
                                            if(optionMap.has(op)){
                                                prodOptions.push({label : optionMap.get(op) , value : op});
                                            }
                                        });
                                    }
                                }
                            });
                        }
                        console.log('prodOptions>>>>>>>>>>>>>>>>>>>>>>>>>>>>',prodOptions);
                        component.set("v.options" , prodOptions);
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
    
    onChkSelect : function(component , event) {
        console.log(event.getSource().get("v.name"));
        //console.log(component.find("yo").get("v.name"));
        
        var ops = component.find("options");
        console.log(ops);
        var selected = [];
        for(var op in ops){
            
            console.log("selected value>>>>>>>>>>>",op);
            //selected.push(op.g)        
        }
        //var selectedLabel = component.find("optionChks").get("v.value");
        //console.log(selectedLabel);
    }
})