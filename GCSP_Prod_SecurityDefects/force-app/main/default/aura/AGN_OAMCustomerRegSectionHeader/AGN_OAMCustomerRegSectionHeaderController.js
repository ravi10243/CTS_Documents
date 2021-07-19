({
	doInit : function(component, event, helper) {
		var labelReference = $A.getReference("$Label.c." + component.get("v.sectionHeaderLabel"));
        component.set("v.sectionHeader" , labelReference);
	}
})