({
	closeComponentModal : function(component, event, helper) {
        helper.invokeRefreshBuilder(component,event,helper);
		component.destroy();
	},
    moveNext : function(component,event,helper){
        try {
            var currentProgressStage = component.get("v.currentProgressStage");
            //alert('*****1currentProgressStage****'+currentProgressStage);
            if(currentProgressStage == "component"){
                var componetDetailChild = component.find("componetDetailChild");
                var isSaveSucessful = componetDetailChild.saveComponentData(false);
                if(isSaveSucessful)
                {
                    component.set("v.currentProgressStage", "finish");
                } else {
                    component.set("v.hasError", true);
                }
                
            }
            else if(currentProgressStage == "finish")
            {
                helper.invokeRefreshBuilder(component,event,helper);
                component.destroy();
            }
        } catch (err) {
            console.log(err);
        }

    },
    moveBack : function(component,event,helper){
        var currentProgressStage = component.get("v.currentProgressStage");
        
        if(currentProgressStage == "finish")
        {
            component.set("v.currentProgressStage", "translatedPicklist");
        }
        //Added By Mona start 
        else if(currentProgressStage == "translatedPicklist")
        {
            var componentPicklist = component.find("componentPicklist");
            var isSaveSucessful = componentPicklist.saveComponentData(false);
            if(isSaveSucessful)
            	component.set("v.currentProgressStage", "branding");
            else
                component.set("v.hasError", true);
        }
        //Added By Mona end 
        
        else if(currentProgressStage == "branding")
        {
            var componetBranding = component.find("componetBranding");
            var isSaveSucessful = componetBranding.saveComponentData(false);
            
            if(isSaveSucessful)
            {
                component.set("v.currentProgressStage", "component");
            } else {
                component.set("v.hasError", true);
            }
        }
        else if(currentProgressStage == "component")
        {
            //component.set("v.currentProgressStage", "finish");
        }
    }
    
})