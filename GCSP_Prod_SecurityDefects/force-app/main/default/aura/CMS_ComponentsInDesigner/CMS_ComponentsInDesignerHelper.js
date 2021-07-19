({
    doInitHelper : function(component, event) 
    {
        var recordId = component.get("v.recordId");
        
        if(!recordId)
        {
            var pageParameterMap = helper.pageParameterReader(component, event, helper);            
        	recordId  = pageParameterMap['recordId'];    
        }
        
        if(recordId)
        {
            component.set("v.recordId",recordId);
            
            var actionWrapper = component.get("c.GetComponentsInDesignerWrapper");
            actionWrapper.setParams({
                mdFormId : component.get("v.recordId")
            });
            actionWrapper.setCallback(this, function(response){
                var state = response.getState();
                //alert(state);
                if(state === "SUCCESS") 
                {
                    try
                    {
                        var componentsInDesignerWrapper = response.getReturnValue();                        
                        component.set("v.componentsInDesignerWrapper", componentsInDesignerWrapper);
                        
                        //alert(componentsInDesignerWrapper.ListComponentType.length);
                        //alert(componentsInDesignerWrapper.ListObjectField.length);
                        //alert(componentsInDesignerWrapper.ListFormSteps.length);
                        
                        if(componentsInDesignerWrapper)
                        {
                            component.set("v.listComponentTypes", componentsInDesignerWrapper.ListComponentType);
                            component.set("v.listObjectField", componentsInDesignerWrapper.ListObjectField);
                            component.set("v.listFormSteps", componentsInDesignerWrapper.ListFormSteps);
                            component.set("v.originalListComponentTypes", componentsInDesignerWrapper.ListComponentType);
        					component.set("v.originalListObjectField", componentsInDesignerWrapper.ListObjectField);
                        }
                    }
                    catch(err)
                    {
                        alert('CMDTComponentsController - CMS_ComponentsInDesigner - doInit - Error :: ' + err);
                    }
                }
            });
            $A.enqueueAction(actionWrapper); 
        }
    },
    
    pageParameterReader : function(component, event, helper) 
    {
        var parametermap = {};
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        
        for (var i = 0; i < sURLVariables.length; i++) 
        {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.    
            parametermap[sParameterName[0]]=sParameterName[1];
        }	
        
        return parametermap;
    }
})