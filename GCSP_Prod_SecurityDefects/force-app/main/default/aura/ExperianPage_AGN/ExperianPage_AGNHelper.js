({
    doInitHelper : function(component, event, helper){
        var pageParameterMap = helper.pageParameterReader(component, event, helper);
        
        var pageKey  = pageParameterMap['pagekey'];
        var languageCode  = pageParameterMap['lng'];
        component.set("v.applicationId",pageParameterMap['appId']);
        if(pageKey)
        {
            component.set("v.pageKey",pageKey);
            
            if(languageCode)
            {
                component.set("v.langCode",languageCode);
            }
            
            var paramStepId;    
            var paramPageKey = component.get("v.pageKey");
            var paramLangCode = component.get("v.langCode"); 
            
            var actionPage = component.get("c.GetLocalisedPage");
            actionPage.setParams({
                urlKey : paramPageKey,
                langCode : paramLangCode,
                mdpageformstepId : paramStepId
            });
            actionPage.setCallback(this, function(response){
                var state = response.getState();
                
                if(state === "SUCCESS") 
                {
                    //console.log('current site page--' + JSON.stringify(response.getReturnValue()));
                    component.set("v.currentSitePage", response.getReturnValue());
                    //console.log("Returned Value");
                    var pageProperty;
                    var pagePropertyKey;
                    var pagePropertyValue;
                    if(response.getReturnValue() != null && response.getReturnValue() != undefined){
                        var PageFormPropertiesJSON = response.getReturnValue().PageFormPropertiesJSON;
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
                        helper.splitJSON(component);
                    }
                }
            });
            
            $A.enqueueAction(actionPage);
        }
        else
        {
            //alert('hi');
            var paramPageKey = component.get("v.pageKey");
            var paramLangCode = component.get("v.langCode"); 
         	
            var actionPage = component.get("c.GetLocalisedPage");
            actionPage.setParams({
                urlKey : paramPageKey,
                langCode : paramLangCode,
                mdpageformstepId : paramStepId
            });
            actionPage.setCallback(this, function(response){
                var state = response.getState();
                
                if(state === "SUCCESS") 
                {
                    //console.log('current site page--' + JSON.stringify(response.getReturnValue()));
                    component.set("v.currentSitePage", response.getReturnValue());
                    //console.log("Returned Value");
                    var pageProperty;
                    var pagePropertyKey;
                    var pagePropertyValue;
                    if(response.getReturnValue() != null && response.getReturnValue() != undefined){
                        var PageFormPropertiesJSON = response.getReturnValue().PageFormPropertiesJSON;
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
                        helper.splitJSON(component);
                    }
                }
            });
            
            $A.enqueueAction(actionPage);
        }
        
        
    },
    navigateToStep : function(component, event, helper){
        component.set("v.currentSitePage", null);
        //alert('inside navigateToStep');
        
        var paramPageKey = component.get("v.pageKey");
        var paramLangCode = component.get("v.langCode");
        var paramStepId = component.get("v.stepId");
        
        //alert(paramPageKey);
        //alert(paramLangCode);
        //alert(paramStepId);
        
        var actionPage = component.get("c.GetLocalisedPage");
        actionPage.setParams({
            urlKey : paramPageKey,
            langCode : paramLangCode,
            mdpageformstepId : paramStepId
        });
        actionPage.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            if(state === "SUCCESS") 
            {
                //alert(response.getReturnValue());
                
                component.set("v.currentSitePage", response.getReturnValue());
                var pageProperty;
                var pagePropertyKey;
                var pagePropertyValue;
                if(response.getReturnValue() != null && response.getReturnValue() != undefined){
                var PageFormPropertiesJSON = response.getReturnValue().PageFormPropertiesJSON;
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
                    helper.splitJSON(component);
                }
            }
        });
        
        $A.enqueueAction(actionPage); 
    },
    
    pageParameterReader : function(component, event, helper) 
    {
        var parametermap = {};
        //alert(window.location.search.substring(1));
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        //alert('sPageURL' + sPageURL);
        //var sPageURL = window.location.search.substring(1);
        
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        
        //alert(sURLVariables.length);
        
        for (var i = 0; i < sURLVariables.length; i++) 
        {
            //alert(sURLVariables[i]);
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.    
            parametermap[sParameterName[0]]=sParameterName[1];
        }	
        
        //alert(parametermap);
        
        return parametermap;
    },
    splitJSON : function(component){
        if(component.get("v.currentSitePage.FormJsonCss") != null && component.get("v.currentSitePage.FormJsonCss") != undefined){
            var fieldJson = JSON.parse(component.get("v.currentSitePage.FormJsonCss"));
            
            fieldJson.forEach(function(element) {
                
                if(element.ComponentKey == "SitePageHeader"){
                    // set header json to component variable
                    console.log('json element----'+JSON.stringify(element["ListElement"]));
                    component.set("v.headerJSON",element["ListElement"]);
                }               
            });
        }
        //console.log('header--'+JSON.stringify(component.get("v.headerJSON")));
    }
})