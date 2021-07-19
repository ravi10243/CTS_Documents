({
    
    handleCustomerTypeChange : function(component, event, helper) {
        var selected = event.getSource().get("v.value");
        if(selected != undefined && selected != null && selected != ''){  
            component.set("v.selectedCustomerTypeVal" , selected);
            helper.fetchCustomerSubType(component, event , selected);
        }else{
            component.set("v.picklistSubTypeOptions", []);
        }
    },
    handleCustomerSubTypeChange : function(component, event, helper) {          
        var selectedVal = event.getSource().get("v.value");
        console.log("CustomerSubType selectedVal>>>>>>>>>>>>>>>>>>>>>>>"+selectedVal);
        var selectedCustomerType = component.get("v.selectedCustomerTypeVal");
        if(selectedCustomerType && selectedVal){
            helper.getCustomerGroupData(selectedCustomerType , selectedVal , component);
        }
    }
})