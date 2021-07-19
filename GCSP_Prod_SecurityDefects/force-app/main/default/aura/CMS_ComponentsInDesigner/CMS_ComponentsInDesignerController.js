({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component, event) ;    
    },
    onCurrentStepChange : function(component, event, helper){
        var selectedStepId = event.getSource().get("v.value");
        if(selectedStepId)
        {
            component.set("v.currentStepId", selectedStepId);
            
            if(selectedStepId!='--')
            {
                var selectedStepLabel;
                var listFormSteps = component.get("v.listFormSteps");
                
                for(var i=0; i<listFormSteps.length;i++)
                {
                    if(listFormSteps[i].StepId === selectedStepId)
                    {
                        selectedStepLabel = listFormSteps[i].DeveloperName;
                        component.set("v.currentStepDeveloperName", selectedStepLabel);
                        break;
                    }
                }
                
                var formStepChangeEvent = $A.get("e.c:CMS_FormStepChangeEvent");
                formStepChangeEvent.setParams({"currentStepId" :selectedStepId}); 
                formStepChangeEvent.fire();    
            }
            
        }
    },
    openDataFieldAddComponent: function(component, event, helper)
    {
        var currentDataField = event.getSource().get("v.value");
        
        if(currentDataField)
        {
            var currentStepId = component.get("v.currentStepId");
            var currentStepDeveloperName = component.get("v.currentStepDeveloperName");
            var objectFieldIcon = 'standard:all';
            
            $A.createComponent("c:CMS_ModalComponent", {
                "componentType": "ObjectField",
                "componentTypeLabel" : "Object Field",
                "componentTypeIcon" : objectFieldIcon,
                "formStepId" : currentStepId,
                "formStepDeveloperName" : currentStepDeveloperName,
                "dataFieldAPIName" : currentDataField.FieldAPIName,
                "dataFieldLabel" : currentDataField.FieldLabel
            },
                               function(modalComponent, status, errorMessage) {
                                   if (status === "SUCCESS") 
                                   {
                                       //Appending the newly created component in div
                                       var body = component.find('showChildModal').get("v.body");
                                       body.push(modalComponent);
                                       component.find('showChildModal').set("v.body", body);
                                   } 
                                   else if (status === "INCOMPLETE") 
                                   {
                                       console.log('Server issue or client is offline.');
                                   } 
                                       else if (status === "ERROR") 
                                       {
                                           console.log('error');
                                       }
                               }
                              );
        }
        
    },
    openAddComponent: function(component, event, helper){
        var mdComponentType = event.getSource().get("v.value");
        //alert(JSON.stringify(mdComponentType));
        
        if(mdComponentType)
        {
            var currentStepId = component.get("v.currentStepId");
            //alert('**1***'+currentStepId);
            //alert('**2***'+mdComponentType.RecordId);
            var currentStepDeveloperName = component.get("v.currentStepDeveloperName");
            var componentType = mdComponentType.DeveloperName;
            var componentTypeIcon = mdComponentType.IconName;
            var componentTypeLabel = mdComponentType.Label;
            
            $A.createComponent("c:CMS_ModalComponent", {
                "componentType": componentType,
                "componentTypeLabel" : componentTypeIcon,
                "componentTypeIcon" : componentTypeIcon,
                "formStepId" : currentStepId,
                "formStepDeveloperName" : currentStepDeveloperName
            },
                               function(modalComponent, status, errorMessage) {
                                   if (status === "SUCCESS") 
                                   {
                                       //Appending the newly created component in div
                                       var body = component.find('showChildModal').get("v.body");
                                       body.push(modalComponent);
                                       component.find('showChildModal').set("v.body", body);
                                   } 
                                   else if (status === "INCOMPLETE") 
                                   {
                                       console.log('Server issue or client is offline.');
                                   } 
                                       else if (status === "ERROR") 
                                       {
                                           console.log('error');
                                       }
                               }
                              );
        }
    },
    componentsRefreshEventHandler : function(component, event, helper){
        //alert('Inside Components Refresh');
        //component.set("v.componentsInDesignerWrapper", null);
        //component.set("v.listComponentTypes", componentsInDesignerWrapper.ListComponentType);
        //component.set("v.listObjectField", componentsInDesignerWrapper.ListObjectField);
        //component.set("v.listFormSteps", componentsInDesignerWrapper.ListFormSteps);
        helper.doInitHelper(component, event);    
    },
    searchComponentsAndObjects : function(component, event, helper) {
        let query = component.get("v.searchQuery").trim();
        let componentTypes = component.get("v.originalListComponentTypes"); 
        let objectFields = component.get("v.originalListObjectField"); 
        if(query != "") {
            if(componentTypes) {
                let filteredComponentTypes = componentTypes.filter(componentType => componentType.DeveloperName.toLowerCase().includes(query.toLowerCase()));
                component.set("v.listComponentTypes", filteredComponentTypes);
            }
            if(objectFields) {
                let filteredObjectFields = objectFields.filter(objectField => objectField.FieldLabel.toLowerCase().includes(query.toLowerCase()));
                component.set("v.listObjectField", filteredObjectFields);
            }
        } else {
            component.set("v.listComponentTypes", componentTypes);
            component.set("v.listObjectField", objectFields);
        } 
    }
})