({
    clearValues : function(component, event, helper) {
        console.log("clear valuesss>>>>>>>>>>>>>>>>");
        var oldValue = event.getParam("oldValue");
        var value = event.getParam("value");
        console.log("value>>>>>>>>>>>>>>>>>>",value);
        console.log("oldValue>>>>>>>>>>>>>>>>>>",oldValue);
        if(value /*&& oldValue != value*/){
            var items = component.find("fieldId");
            items.forEach(function(cmp){
                console.log("fieldName>>>>>>>>>>>>>>>>>", cmp.get("v.fieldName"));
                console.log("fieldval>>>>>>>>>>>>>>>>>", cmp.get("v.fieldValue"));
                if(!$A.util.isEmpty(cmp.get("v.fieldName"))){
                    cmp.set("v.fieldValue" , "");
                }
                
            });
        }else{
            var items = component.find("fieldId");
            items.forEach(function(cmp){
                console.log("fieldName>>>>>>>>>>>>>>>>>", cmp.get("v.fieldName"));
                console.log("fieldval>>>>>>>>>>>>>>>>>", cmp.get("v.fieldValue"));
                
            });
        }
    },
    handleRequiredFields : function(component, event, helper) {
        console.log("yo yo yo>>>>>>>>>>>>>>>");
        var comps = component.find("fieldId");
        var fieldList = "";
        comps.forEach(function(cmp){
            console.log("fieldValueMissing>>>>>>",cmp.get("v.fieldValueMissing"));
            console.log("fieldValue>>>>>>>>>>>>>>>>>>>>>>>>>>>>",cmp.get("v.fieldValue"));
            console.log("fieldList>>>>>>>>>>>>>>>>>",fieldList);
            console.log("fieldName>>>>>>>>>>",cmp.get("v.fieldName"));
            console.log("required>>>>>>>>>>",cmp.get("v.required"));
            if(!fieldList.includes(cmp.get("v.fieldName")) 
               && !$A.util.isEmpty(cmp.get("v.fieldName")) 
               && !$A.util.isEmpty(cmp.get("v.fieldValueMissing")) 
               && !$A.util.isEmpty(cmp.get("v.required"))){
                console.log("***************entering the condition********************");
                fieldList = fieldList + "-" + cmp.get("v.fieldName");
                if($A.util.isEmpty(cmp.get("v.fieldValue"))){
                    if(!cmp.get("v.required")){
                        cmp.set("v.required" , true);
                    }else{
                       cmp.set("v.required" , false); 
                        cmp.set("v.required" , true);
                    }
                    console.log("setting fieldValueMissing TRUE>>>>>>>>>>");
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
                console.log("after setting the value>>>>>>>>>required>>>",cmp.get("v.required"));
                console.log("after setting the value>>>>>>>>>fieldValueMissing>>>",cmp.get("v.fieldValueMissing"));
                console.log("***************exiting the condition********************");
            }
            
            
            
            
        });
    },
    handleNonFormattedFields : function(component, event, helper) {
        console.log("yo yo yo>>>>>>>>>>>>>>>");
        var comps = component.find("fieldId");
        var fieldList = "";
        comps.forEach(function(cmp){
            console.log("fieldValueMissing>>>>>>",cmp.get("v.fieldValueMissing"));
            console.log("fieldValue>>>>>>>>>>>>>>>>>>>>>>>>>>>>",cmp.get("v.fieldValue"));
            console.log("fieldList>>>>>>>>>>>>>>>>>",fieldList);
            console.log("fieldName>>>>>>>>>>",cmp.get("v.fieldName"));
            console.log("required>>>>>>>>>>",cmp.get("v.required"));
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
            
            //cmp.set("v.fieldValueMissing",true);
            console.log("after setting the value>>>>>>>>>required>>>",cmp.get("v.required"));
            console.log("after setting the value>>>>>>>>>fieldValueMissing>>>",cmp.get("v.fieldValueMissing"));
            
        });
    },
    removeRequiredFields : function(component, event, helper) {
        var isOpen = event.getParam("value");
        var step = component.get("v.step");
        if(!$A.util.isEmpty(step)){
            if(step == 1 || (step == 2 && isOpen)){
                var comps = component.find("fieldId");
                comps.forEach(function(cmp){
                    console.log("*************enter removeRequiredFields******************");
                    console.log("fieldValueMissing>>>>>>",cmp.get("v.fieldValueMissing"));
                    console.log("fieldValue>>>>>>>>>>>>>>>>>>>>>>>>>>>>",cmp.get("v.fieldValue"));
                    console.log("fieldName>>>>>>>>>>",cmp.get("v.fieldName"));
                    console.log("required>>>>>>>>>>",cmp.get("v.required"));
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
                    console.log("*************exit removeRequiredFields******************");
                });
            }
        }
    }
})