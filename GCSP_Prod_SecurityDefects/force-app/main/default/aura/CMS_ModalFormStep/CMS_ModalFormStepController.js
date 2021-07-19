({
	closeComponentModal : function(component, event, helper) {
        //alert('Close - Before');
        helper.invokeRefreshBuilder(component,event,helper);
        helper.invokeRefreshComponentsBar(component,event,helper);
		//alert('Close - After');
        component.destroy();
	},
    moveNext : function(component,event,helper){
        
        
        
        //alert("next");
        var currentProgressStage = component.get("v.currentProgressStage");
        if(currentProgressStage == "step"){
            //console.log(component.find("stepDetailChild1").find("newStepForm").submit());
            var stepDetailChild = component.find("stepDetailChild");
            var isSaveSucessful = stepDetailChild.saveComponentData(false);
            //console.log("Save successful?:" + isSaveSucessful);
            if(isSaveSucessful)
            {
             	component.set("v.currentProgressStage", "finish");
            }
            
            
        } 
        else if(currentProgressStage == "finish")
        {
            //alert('Finish - Before');
            helper.invokeRefreshBuilder(component,event,helper);
            helper.invokeRefreshComponentsBar(component,event,helper);
            //alert('Finish - After');
            component.destroy();
        } 
    },
    moveBack : function(component,event,helper){
        var currentProgressStage = component.get("v.currentProgressStage");
        
        if(currentProgressStage == "finish")
        {
            component.set("v.currentProgressStage", "step");
        }
        else if(currentProgressStage == "step")
        {
            //component.set("v.currentProgressStage", "finish");
        }
    }
})