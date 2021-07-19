({
	doInit : function(component, event, helper){
        //component.find("namefield").set("v.value", "new value to set");
        var elementWrapper = component.get("v.elementWrapper");
        
        if(formfield)
        {
            var formFieldDeveloperName = elementWrapper.DeveloperName;
            var controlValue = elementWrapper.DefaultValue;
            
            var inputControl = component.find("elementHidden");
            inputControl.set("v.value", controlValue);
        }
    }
})