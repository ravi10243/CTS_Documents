({
    doInit : function(component, event, helper) 
    {
        helper.doInitHelper(component, event);    
    },
    
    dragForm : function(component, event, helper) 
    {
        var dropEntity = new Object();
        var componentTypeAndName = event.target.id;
        var arraySplit = componentTypeAndName.split('~');
        var formId = arraySplit[0];
        var developerName = arraySplit[1];
        
        dropEntity.Id = formId;
        dropEntity.Type='Form';
        dropEntity.developerName = developerName;
        event.dataTransfer.setData("dropEntity", JSON.stringify(dropEntity));
    },
    dragendForm : function(component, event, helper) 
    {
        var listTreeNode = component.find("treenode");      
        if(listTreeNode)
        {
            for(var j=0;j<listTreeNode.length;j++)
            {
                
                var treeNodeItem = listTreeNode[j];
                if(treeNodeItem.getElement().className == 'selectedtreenode') {
                    $A.util.toggleClass(treeNodeItem, 'selectedtreenode');
                }
                //$A.util.removeClass(treeNodeItem, 'selectedtreenode');
            }
        }
        component.set("v.updatedComponentId", event.target.id);
    	event.target.setAttribute("class", "selectedtreenode");
    },
    dragFormStep : function(component, event, helper) 
    {
        //alert(event.target.id);
        var dropEntityFormStep = new Object();
        
        var formStepIdAndName = event.target.id;
        var arraySplit = formStepIdAndName.split('~');
        
        var stepid = arraySplit[0];
        var developerName = arraySplit[1];
        
        
        dropEntityFormStep.Id = stepid;
        dropEntityFormStep.Type='FormStep'; 
        dropEntityFormStep.developerName = developerName;
        event.dataTransfer.setData("dropEntity", JSON.stringify(dropEntityFormStep));
    },
    dragendFormStep : function(component, event, helper) 
    {
        var listTreeNode = component.find("treenode");
                
        if(listTreeNode)
        {
            for(var j=0;j<listTreeNode.length;j++)
            {
                var treeNodeItem = listTreeNode[j];
                if(treeNodeItem.getElement().className == 'selectedtreenode') {
                    $A.util.toggleClass(treeNodeItem, 'selectedtreenode');
                }
                $A.util.addClass(treeNodeItem, 'treenode');
            }
        }
        
    	event.target.setAttribute("class", "selectedtreenode");
    },
    dragComponent : function(component, event, helper) 
    {
        var componentTypeAndId = event.target.id;
        var arraySplit = componentTypeAndId.split('~');
        
        var componentType = arraySplit[0];
        var componentRecordId = arraySplit[1];
        var componentDeveloperName = arraySplit[2];
        var compIconName = arraySplit[3];
        var dropEntityComponent = new Object();
        dropEntityComponent.Id = componentRecordId;
        dropEntityComponent.Type='Component';
        dropEntityComponent.ComponentType = componentType;
        dropEntityComponent.developerName = componentDeveloperName;
        dropEntityComponent.compIconName = compIconName;
        
        event.dataTransfer.setData("dropEntity", JSON.stringify(dropEntityComponent));
    },
    dragendComponent : function(component, event, helper) 
    {
        var listTreeNode = component.find("treenode");
        //alert(event.getSource());
                
        if(listTreeNode)
        {
            for(var j=0;j<listTreeNode.length;j++)
            {
                var treeNodeItem = listTreeNode[j];
                if(treeNodeItem.getElement().className == 'selectedtreenode') {
                    $A.util.toggleClass(treeNodeItem, 'selectedtreenode');
                }
                $A.util.addClass(treeNodeItem, 'treenode');
            }
        }
        
    	event.target.setAttribute("class", "selectedtreenode");
    },
    onClickComponent : function(component, event, helper) 
    {
        var selectedComponentTypeAndId = event.target.id;
        //var arraySplit = componentTypeAndId.split('~');
        
        //alert(component);
        //var selectedComponent = event.target.id;
        //alert(selectedComponent);
        //var componentTypeAndId = event.target.id;
        //event.target.setAttribute("style", "color:red; border: 1px solid blue;")
    },
    onFormStepChangeEventHandler : function(component, event, helper){
        var currentStepId = event.getParam("currentStepId");
        //alert(currentStepId);
        component.set("v.currentStepId", currentStepId);
    },
    builderRefreshEventHandler : function(component, event, helper){
        //alert('Inside Builder Tree Refresh');
        component.set("v.mdFormWrapper", null);
        helper.doInitHelper(component, event);    
    },
    onComponentMenuClick: function(component, event, helper){
        var menuItemAndTypeAndId = event.getParam("value");
        var arraySplit = menuItemAndTypeAndId.split('~');
        var menuItem = arraySplit[0];
        var componentType = arraySplit[1];
        var componentRecordId = arraySplit[2];
        
        if(menuItem == 'WIZARD')
        {
            $A.createComponent("c:CMS_ModalComponent", {
                "recordId": componentRecordId,
                "componentType" : componentType
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
    onFormMenuClick: function(component, event, helper){
        var menuItemAndId = event.getParam("value");
        var arraySplit = menuItemAndId.split('~');
        var menuItem = arraySplit[0];
        var formRecordId = arraySplit[1];
        
        if(menuItem == 'ADDFORMSTEP')
        {
            $A.createComponent("c:CMS_ModalFormStep", {
                "parentFormId": formRecordId
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
        else if(menuItem == 'WIZARD')
        {
            $A.createComponent("c:CMS_ModalForm", {
                "recordId": formRecordId
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
    onStepMenuClick: function(component, event, helper){
        var menuItemAndId = event.getParam("value");
        var arraySplit = menuItemAndId.split('~');
        var menuItem = arraySplit[0];
        var formStepRecordId = arraySplit[1];
        
        if(menuItem == 'WIZARD')
        {
            $A.createComponent("c:CMS_ModalFormStep", {
                "recordId": formStepRecordId
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
})