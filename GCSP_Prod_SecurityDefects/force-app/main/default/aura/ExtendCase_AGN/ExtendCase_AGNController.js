({
    doInit : function(component, event, helper) {
        helper.doInitHelper(component,event);  
    },
    extendCase : function(component, event, helper) {
       helper.extendCase(component,event); 
    },    
    cancel: function(component, event, helper) 
    {
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire() ;       
    }
})