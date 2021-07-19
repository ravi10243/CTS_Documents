({
	isBrandingSupported : function(component) {
        try {
            const componentType = component.get("v.componentType");
            component.set(
                "v.isBrandingSupported", 
                componentType == "SectionHeader" ||
                componentType == "InlineHelp"
            );
        } catch(err) {
            console.log(err);
        }
    }
})