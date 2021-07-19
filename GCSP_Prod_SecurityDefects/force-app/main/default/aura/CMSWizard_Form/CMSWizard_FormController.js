({
    doInit : function(component, event, helper) {
        console.log('record id form wizard---' + component.get("v.recordId"));
    },
    
    doOpenStep: function(component, event, helper) {
        //console.log('step---' + event.target.value);
    },
    
    moveNext : function(component,event,helper){
		// control the next button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
        //alert(getCurrentStep);
        
        console.log('form next--' + getCurrentStep);
        // call child component method
        
        if(getCurrentStep == "start"){
            component.set("v.currentStep", "form");
        } else if(getCurrentStep == "form"){
            var formDetailChild = component.find("formDetailChild");
            //alert(formDetailChild);   
            var isSaveSucessful = formDetailChild.saveComponentData(false);
            component.set("v.hasError",!isSaveSucessful);
            if(isSaveSucessful){
                component.set("v.currentStep", "properties");
            }
        }
        else if(getCurrentStep == "properties"){
            var formPropertyChild = component.find("formPropertyChild");
            //alert(formPropertyChild);   
            var isSaveSucessful = formPropertyChild.saveComponentData(false);
            component.set("v.hasError",!isSaveSucessful);
            if(isSaveSucessful){
            	component.set("v.currentStep", "languages");
            }
        }
        else if(getCurrentStep == "languages"){
            var formLangChild = component.find("formLangChild");
            //alert(formLangChild);   
            var isSaveSucessful = formLangChild.saveComponentData(false);
            component.set("v.hasError",!isSaveSucessful);
            if(isSaveSucessful){
            	component.set("v.currentStep", "branding");
            }
        }
        else if(getCurrentStep == "branding"){
            var formBrandChild = component.find("formBrandChild");
			//alert(formBrandChild);   
            var isSaveSucessful = formBrandChild.saveComponentData(false);  
            component.set("v.hasError",!isSaveSucessful);
            if(isSaveSucessful){
            	component.set("v.currentStep", "finish");
            }
        } else if (getCurrentStep == "finish"){
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    
    moveBack : function(component,event,helper){
        // control the back button based on 'currentStep' attribute value    
        var getCurrentStep = component.get("v.currentStep");
        //alert(getCurrentStep);
        if(getCurrentStep == "finish"){
            component.set("v.currentStep", "branding");
        } else if(getCurrentStep == "branding")
        {
         	var formBrandChild = component.find("formBrandChild");
            //alert(formBrandChild);   
            var isSaveSucessful = formBrandChild.saveComponentData(false);  
            component.set("v.hasError",!isSaveSucessful);
            if(isSaveSucessful){
            	component.set("v.currentStep", "languages");
            }
        }
        else if(getCurrentStep == "languages")
        {
            var formLangChild = component.find("formLangChild");
            //alert(formLangChild);   
            var isSaveSucessful = formLangChild.saveComponentData(false);
            component.set("v.hasError",!isSaveSucessful);
            if(isSaveSucessful){
            	component.set("v.currentStep", "properties");
            }
        }
        else if(getCurrentStep == "properties")
        {
            var formPropertyChild = component.find("formPropertyChild");
            //alert(formPropertyChild);   
            var isSaveSucessful = formPropertyChild.saveComponentData(false);
            component.set("v.hasError",!isSaveSucessful);
            if(isSaveSucessful){
            	component.set("v.currentStep", "form");
            }
        }
        else if(getCurrentStep == "form")
        {
            var formDetailChild = component.find("formDetailChild");
            //alert(formDetailChild);   
            var isSaveSucessful = formDetailChild.saveComponentData(false);
            component.set("v.hasError",!isSaveSucessful);
            if(isSaveSucessful){
            	component.set("v.currentStep", "start");
            	component.set("v.showWizard",false);
            }
        }
    },
    
    launch : function(component,event,helper){
        component.set("v.showWizard",true);
        component.set("v.currentStep", "form");
    },
    
})