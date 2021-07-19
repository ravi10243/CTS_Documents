({
	splitJSON : function(component){
        //var fieldJson = JSON.parse(component.get("v.currentSitePage.FormJsonCss"));
        if(component.get("v.currentSitePage.FormJsonCss") != undefined && component.get("v.currentSitePage.FormJsonCss") != null){
            var fieldJson = JSON.parse(component.get("v.currentSitePage.FormJsonCss"));
           
            fieldJson.forEach(function(element) {
                if(element.ComponentKey == "SitePageHeader")
                {
                    component.set("v.headerJSON",element["ListElement"]);
                }               
            });
        
        fieldJson.forEach(function(element) {
            if(element.ComponentKey == "SitePageHeader")
            {
                component.set("v.headerJSON",element["ListElement"]);
            }               
        });
        }
    },
    
    doInitHelper : function(component, event) {
        var mdFormId  = component.get("v.formId");
        var stepId  = component.get("v.stepId");
       	
        //alert(mdFormId);
        //alert(stepId);
        
        if(mdFormId)
        {
            var actionPage = component.get("c.GetSitePageWrapper");
            actionPage.setParams({
                mdFormId : mdFormId,
                selectedStepId : stepId
            });
            actionPage.setCallback(this, function(response){
                var state = response.getState();
                
                //alert(state);
                
                if(state === "SUCCESS") 
                {
                    //alert(JSON.stringify(response.getReturnValue()));
                    component.set("v.currentSitePage", response.getReturnValue());
                    var pageProperty;
                    var pagePropertyKey;
                    var pagePropertyValue;
                    var PageFormPropertiesJSON = response.getReturnValue().PageFormPropertiesJSON;
                    if(PageFormPropertiesJSON)
                    
                    for(pageProperty in PageFormPropertiesJSON){
                        pagePropertyKey = PageFormPropertiesJSON[pageProperty].PropertyKey;
                        pagePropertyValue = PageFormPropertiesJSON[pageProperty].PropertyValue;
                        if(pagePropertyKey == 'ShowPageTop'){
                            component.set("v.showPageTop", pagePropertyValue);
                        }
                        if(pagePropertyKey == 'ShowPageHeader'){
                            component.set("v.showPageHeader", pagePropertyValue);
                        }
                        if(pagePropertyKey == 'ShowPageFooter'){
                            component.set("v.showPageFooter", pagePropertyValue);
                        }
                        if(pagePropertyKey == 'ShowPageBottom'){
                            component.set("v.showPageBottom", pagePropertyValue);
                        }
                        if(pagePropertyKey == 'ShowLanguageSelector'){
                            component.set("v.showLanguageSelector", pagePropertyValue);
                        }
                    }

                    this.splitJSON(component);
                }
            });
            $A.enqueueAction(actionPage);            
        }
    }
    
})