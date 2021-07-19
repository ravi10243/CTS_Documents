({
    doInit : function(component, event, helper) {
        component.set("v.addNewMode",false);
        helper.doInitHelper(component, event) ;
    },
    OnAddNewFieldConfig: function(component, event, helper) {
        component.set("v.addNewMode",true);
        
        var newFieldConfig = new Object();
        component.set("v.newFieldConfig",newFieldConfig);
    },
    OnCancelAddNew: function(component, event, helper) {
        component.set("v.addNewMode",false);
        component.set("v.newFieldConfig",null);
    },
    OnSaveAddNew: function(component, event, helper) {
        //component.set("v.addNewMode",true);
        var newFieldConfig = component.get("v.newFieldConfig");
        
        if(newFieldConfig)
        {
            var listFieldConfig = component.get("v.listFieldConfig");
            if(!listFieldConfig)
            {
                listFieldConfig = [];
            }
            listFieldConfig.push(newFieldConfig);
            //alert(listFieldConfig);
            
            component.set("v.listFieldConfig", listFieldConfig);
        }
        component.set("v.newFieldConfig",null);
        component.set("v.addNewMode",false);
    },
    OnSaveObjectsAndFields: function(component, event, helper) {
        var mdChildObjectOneConfig = component.get("v.mdChildObjectOneConfig");
        if(mdChildObjectOneConfig)
        {
            //alert(mdChildObjectOneConfig.ChildObjectAPIName);
            //alert(mdChildObjectOneConfig.RelationshipFieldAPIName);
            
            var listFieldConfig = component.get("v.listFieldConfig");
            //alert(listFieldConfig.length);
            //alert(listFieldConfig[0].DeveloperName);
            
            mdChildObjectOneConfig.ListFieldConfig = listFieldConfig;
            component.set("v.mdChildObjectOneConfig", mdChildObjectOneConfig);
            
            //alert(JSON.stringify(mdChildObjectOneConfig));
            
            //alert(mdChildObjectOneConfig);
            //alert(JSON.parse(mdChildObjectOneConfig));
            helper.doSaveHelper(component, helper, mdChildObjectOneConfig) ;
       }
    },
    deleteField : function(component, event, helper) {
        component.set(
            "v.listFieldConfig", 
            component.get("v.listFieldConfig").filter((component) => component.DeveloperName != event.target.id)
        );
    }
})