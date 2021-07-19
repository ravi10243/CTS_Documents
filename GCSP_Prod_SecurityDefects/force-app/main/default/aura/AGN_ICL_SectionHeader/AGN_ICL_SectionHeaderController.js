({
	doInit : function(component, event, helper) {
		var labelReference = $A.getReference("$Label.c." + component.get("v.SectionHeaderCustomLabel"));
        component.set("v.SectionHeaderValue" , labelReference);
	}
})