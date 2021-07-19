({
    doInit : function(component, event, helper) {
        console.log('record id form wizard moadl form controller---' + component.get("v.recordId") + ' ' + component.get("v.mdRecordTypeName"));
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
            if(isSaveSucessful){
                component.set("v.currentStep", "finish");
            }
        }
        else if(getCurrentStep == "object")
        {
            var formObjectChild = component.find("formObjectChild");
            //alert(formObjectChild);   
            var isSaveSucessful = formObjectChild.saveComponentData(false);
            if(isSaveSucessful){
                component.set("v.currentStep", "properties");
            }
        }
        else if(getCurrentStep == "properties"){
            var formPropertyChild = component.find("formPropertyChild");
            //alert(formPropertyChild);   
            var isSaveSucessful = formPropertyChild.saveComponentData(false);
            
            component.set("v.currentStep", "finish");
        }
        else if(getCurrentStep == "languages"){
            var formLangChild = component.find("formLangChild");
            //alert(formLangChild);   
            var isSaveSucessful = formLangChild.saveComponentData(false);
            
            component.set("v.currentStep", "branding");
        }
        else if(getCurrentStep == "branding"){
            var formBrandChild = component.find("formBrandChild");
			//alert(formBrandChild);   
            var isSaveSucessful = formBrandChild.saveComponentData(false);  
            
            component.set("v.currentStep", "finish");
        } else if (getCurrentStep == "finish"){
            //close Quick action component
            //component.set("v.hasError",true);
            //$A.get("e.force:closeQuickAction").fire();
            
            // TODO: place redirection URL if anything required
            let comp = component.find("formDetailChild");
        
        
			component.destroy();
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
            
            component.set("v.currentStep", "languages");
        }
        else if(getCurrentStep == "languages")
        {
            var formLangChild = component.find("formLangChild");
            //alert(formLangChild);   
            var isSaveSucessful = formLangChild.saveComponentData(false);
            
            component.set("v.currentStep", "properties");
        }
        else if(getCurrentStep == "properties")
        {
            var formPropertyChild = component.find("formPropertyChild");
            //alert(formPropertyChild);   
            var isSaveSucessful = formPropertyChild.saveComponentData(false);
            
            component.set("v.currentStep", "object");
        }
        else if(getCurrentStep == "object")
        {
            var formObjectChild = component.find("formObjectChild");
            //alert(formObjectChild);   
            var isSaveSucessful = formObjectChild.saveComponentData(false);
            if(isSaveSucessful){
                component.set("v.currentStep", "form");
            }
        }
        else if(getCurrentStep == "form")
        {
            var formDetailChild = component.find("formDetailChild");
            //alert(formDetailChild); 
            
            var isSaveSucessful = formDetailChild.saveComponentData(false);
            if(isSaveSucessful){
                component.set("v.currentStep", "start");
                component.set("v.showWizard",false);
            }
        }
    },
    closeComponentModal : function(component, event, helper) {
        let comp = component.find("formDetailChild");
		component.destroy();
	},
})