({
    clearValues : function(component, event, helper) {
        var oldValue = event.getParam("oldValue");
        var value = event.getParam("value");
        if(value){
            var items = component.find("fieldId");
            items.forEach(function(cmp){
                if(!$A.util.isEmpty(cmp.get("v.fieldName"))){
                    cmp.set("v.fieldValue" , "");
                }
                
            });
        }else{
            
        }
    },
    handleRequiredFields : function(component, event, helper) {
        var comps = component.find("fieldId");
        var fieldList = "";
        comps.forEach(function(cmp){
            if(!fieldList.includes(cmp.get("v.fieldName")) 
               && !$A.util.isEmpty(cmp.get("v.fieldName")) 
               && !$A.util.isEmpty(cmp.get("v.fieldValueMissing")) 
               && !$A.util.isEmpty(cmp.get("v.required")) ){
                fieldList = fieldList + "-" + cmp.get("v.fieldName");
                console.log("field name>>>>"+cmp.get("v.fieldName")+">>required>>>>>"+cmp.get("v.required"));
                if($A.util.isEmpty(cmp.get("v.fieldValue"))){
                    if(!cmp.get("v.required")){
                        cmp.set("v.required" , true);//added 24/5/2019
                        cmp.set("v.required" , false);
                    }else{
                        cmp.set("v.required" , false); 
                        cmp.set("v.required" , true);
                    }
                    if(cmp.get("v.fieldValueMissing")){
                        cmp.set("v.fieldValueMissing",false);
                        cmp.set("v.fieldValueMissing",true);
                    }else{
                        cmp.set("v.fieldValueMissing",true);
                    }
                    
                }else{
                    console.log("setting fieldValueMissing FALSE>>>>>>>>");
                    if(cmp.get("v.fieldValueMissing")){
                        cmp.set("v.fieldValueMissing",false);
                    }else{
                        cmp.set("v.fieldValueMissing",true);
                        cmp.set("v.fieldValueMissing",false);
                    }
                    
                }
                console.log("nonMandatoryFields>>>>>>>>>>>>>>>"+component.get("v.nonMandatoryFields"));
                 console.log("after>>>>>>>>>>>>>>>");
                if(!$A.util.isEmpty(component.get("v.nonMandatoryFields"))){
                    var nonMandatoryFields = component.get("v.nonMandatoryFields");
                    console.log("nonMandatoryFields>>>>>>>>>>>>>>>",nonMandatoryFields);
                        if(nonMandatoryFields.includes(cmp.get("v.fieldName"))){
                            if(cmp.get("v.fieldValueMissing")){
                            cmp.set("v.fieldValueMissing",false);
                            }else{
                                cmp.set("v.fieldValueMissing",true);
                                cmp.set("v.fieldValueMissing",false);
                            }
                        }
                }
                
                if(!$A.util.isEmpty(component.get("v.mandatoryFields"))){
                    var mandatoryFields = component.get("v.mandatoryFields");
                    console.log("mandatoryFields>>>>>>>>>>>>>>>",mandatoryFields);
                        if(mandatoryFields.includes(cmp.get("v.fieldName"))){
                            if(cmp.get("v.required")){
                                cmp.set("v.required" , false);
                                cmp.set("v.required" , true);
                            }else{
                                cmp.set("v.required" , true);
                            }
                        }
                }
            }
            
            
            
            
        });
    },
    handleNonFormattedFields : function(component, event, helper) {
        var comps = component.find("fieldId");
        var fieldList = "";
        comps.forEach(function(cmp){
            if(!fieldList.includes(cmp.get("v.fieldName")) 
               && !$A.util.isEmpty(cmp.get("v.fieldName")) 
               && !$A.util.isEmpty(cmp.get("v.fieldValueMissing")) 
               && !$A.util.isEmpty(cmp.get("v.required")) 
               && !$A.util.isEmpty(cmp.get("v.isFormatValid"))){
                
                fieldList = fieldList + "-" + cmp.get("v.fieldName");
                if(!cmp.get("v.isFormatValid")){
                    if(!cmp.get("v.required")){
                        cmp.set("v.required" , true);
                    }
                    console.log("setting fieldValueMissing TRUE");
                    if(cmp.get("v.fieldValueMissing")){
                        cmp.set("v.fieldValueMissing",false);
                        cmp.set("v.fieldValueMissing",true);
                    }else{
                        cmp.set("v.fieldValueMissing",true);
                    }
                    
                }else{
                    console.log("setting fieldValueMissing FALSE");
                    if(cmp.get("v.fieldValueMissing")){
                        cmp.set("v.fieldValueMissing",false);
                    }else{
                        cmp.set("v.fieldValueMissing",true);
                        cmp.set("v.fieldValueMissing",false);
                    }
                    
                }
            }
        });
    },
    removeRequiredFields : function(component, event, helper) {
        var isOpen = event.getParam("value");
        var step = component.get("v.step");
        if(!$A.util.isEmpty(step)){
            if(step == 1 || (step == 2 && isOpen)){
                var comps = component.find("fieldId");
                comps.forEach(function(cmp){
                    if(!$A.util.isEmpty(cmp.get("v.fieldName")) 
                       && !$A.util.isEmpty(cmp.get("v.fieldValueMissing")) 
                       && !$A.util.isEmpty(cmp.get("v.required"))){
                        if(cmp.get("v.fieldValueMissing")){
                            cmp.set("v.fieldValueMissing",false);
                        }else{
                            cmp.set("v.fieldValueMissing",true);
                            cmp.set("v.fieldValueMissing",false);
                        }
                    }
                });
            }
        }
    }
})