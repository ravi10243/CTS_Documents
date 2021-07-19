({
    doInitHelper : function(component, event, helper) 
    {
        var mdComponentRecordId = component.get("v.elementWrapper.PageElement.Id");
        //alert(mdComponentRecordId);
        
        if(mdComponentRecordId)
        {
            var actionLanguage = component.get("c.GetComponentConfigJSON");
            actionLanguage.setParams({
                mdComponentId : mdComponentRecordId,
                languageKey: component.get("v.currentSitePage").languageCode
            });
            actionLanguage.setCallback(this, function(response){
                var state = response.getState();
                //alert(state);
                if(state === "SUCCESS") 
                {
                    try
                    {
                        var returnValue = response.getReturnValue();
                        let configJSON = returnValue[0];
                        console.log(configJSON);
                        if(returnValue.length == 2) {
                            let localisedConfigJSON = JSON.parse(returnValue[1]);
                        }
                        try {
                            var mdChildObjectOneConfig = JSON.parse(configJSON);
                            if(returnValue.length == 2) {
                                let localisedConfigJSON = JSON.parse(returnValue[1]);
                                let listFieldConfig = mdChildObjectOneConfig.ListFieldConfig;
                                listFieldConfig = listFieldConfig.map(field => {
                                    let localisedField = localisedConfigJSON.find(item => item.FieldAPIName == field.FieldAPIName);
                                    if (localisedField) {
                                    	field.DisplayLabel = localisedField.DisplayLabel;
                                    	field.QuickHelpText = localisedField.QuickHelpText;
                                	}
                                    return field;
                                });
                                mdChildObjectOneConfig.ListFieldConfig = listFieldConfig;
                            }
                        } catch (err) {
                            console.error(err);
                        }

                        
                        if(mdChildObjectOneConfig)
                        {
                            component.set("v.mdChildObjectOneConfig", mdChildObjectOneConfig);
                            var childObjectAPIName = mdChildObjectOneConfig.ChildObjectAPIName;
                            var relationshipFieldAPIName = mdChildObjectOneConfig.RelationshipFieldAPIName;
                            if(childObjectAPIName)
                            {
                                component.set("v.childObjectAPIName", childObjectAPIName);
                            }
                            if(relationshipFieldAPIName)
                            {
                                component.set("v.relationshipFieldAPIName", relationshipFieldAPIName);
                            }
                            if(mdChildObjectOneConfig.ListFieldConfig)
                            {
                                component.set("v.listFieldConfig", mdChildObjectOneConfig.ListFieldConfig);
                            }
                            helper.getChildRecordId(component, event, helper);
                        }
                    }
                    catch(err)
                    {
                        alert('MDFormBuilderController - CMSWStep_StepComponentChildObjectOneConfig - doInit - Error :: ' + err);
                    }
                }
            });
            $A.enqueueAction(actionLanguage); 	
        }
    },
    handleOnFormLoad : function(component, event, helper)
    {
        //alert('ChildObjectOne - handleOnFormLoad');
        
        var relationshipFieldAPIName = component.get("v.relationshipFieldAPIName");
        
        var recordUI = event.getParam("recordUi");
        
        if(recordUI)
        {
            var recordFields = recordUI.record.fields;
            var listFormStepElements = component.find("childobjectfield");
            if(listFormStepElements)
            {
                for(var j=0;j<listFormStepElements.length;j++)
                {
                    if(listFormStepElements[j].get("v.fieldName") != relationshipFieldAPIName)
                    {
                        var formElement = listFormStepElements[j];
                        if(formElement)
                        {
                            var formFieldAPIName = formElement.get("v.elementWrapper").FieldAPIName;
                            if(formFieldAPIName)
                            {
                                var fieldValue = recordFields[formFieldAPIName].value;
                                if(fieldValue)
                                {
                                    listFormStepElements[j].set("v.fieldValue", fieldValue);    
                                }
                            }
                        }    
                    }
                }
            }  
        }        
    },
    
    getChildRecordId : function(component, event, helper)
    {
        var objectAPIName = component.get("v.childObjectAPIName");
        var parentRecordId = component.get("v.parentRecordId");
        var parentObjectRelationshipFieldAPIName = component.get("v.relationshipFieldAPIName");
        
        if(parentRecordId)
        {
            var actionGetRecordId=component.get("c.GetChildRecordId");
            actionGetRecordId.setParams({
                objectAPIName : objectAPIName,
                parentRecordId : parentRecordId,
                parentRelationField : parentObjectRelationshipFieldAPIName
            });
            
            actionGetRecordId.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS") 
                {
                    component.set("v.childRecordId", response.getReturnValue());
                }
                else if (state === "INCOMPLETE") 
                {
                    // do something
                }
                    else if (state === "ERROR") 
                    {
                        var errors = response.getError();
                        if (errors) 
                        {
                            if (errors[0] && errors[0].message) 
                            {
                                console.log("Error message: " + errors[0].message);
                                alert("Error message: " + errors[0].message);
                            }
                        } 
                        else 
                        {
                            console.log("Unknown error");
                        }
                    }
                
            });
            $A.enqueueAction(actionGetRecordId); 
        }        
    }
})