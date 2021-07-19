({
	doInit : function(component, event, helper) {
		helper.getLocalisedMDStepComponentRecords(component, helper);
        helper.getListFieldConfig(component, helper);
	},
    onEdit : function(component, event, helper) {
        component.set("v.selectedLocalisedStepComponentId", event.getSource().get("v.value"));
        component.set("v.listLocalisedFieldConfig", []);
        helper.getLocalisedComponentConfigJSON(component, helper);
    },
    saveConfig : function(component, event, helper) {
    	helper.saveLocalisedComponentConfigJSON(component, helper);
    }
})