({
    init : function(component, event, helper) {
        
        var action = component.get("c.getUserDetail");
        
        action.setCallback(this, function(actionResult) {
            component.set("v.userDetail", actionResult.getReturnValue());
            if(component.get("v.userDetail.Account.Customer_Registration_AGN__c") ==='Complete' || component.get("v.userDetail.Contact.Customer_Registration_AGN__c") ==='Complete'){
            	component.set("v.isRegistrationCompleted", true);    
            }
            else{
                component.set("v.isRegistrationCompleted", false);
            }
        });
        $A.enqueueAction(action);
        
        helper.getADOktaSSOUrl(component, event);
        helper.getCommunityURL(component, event);
    },
    
    scriptsLoaded : function(component, event, helper) {
        
        jQuery.noConflict();
        
        jQuery(".dropdown .title").click(function () {
            jQuery(this).parent().toggleClass("closed");
        });       
        
        jQuery(".dropdown li").click(function () {            
            jQuery(this).parent().parent().toggleClass("closed");
        });
        
        console.log('javaScript files loaded successful'); 
    },
    
    gotoHome : function (component, event, helper) {        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();
    },
    
    gotoAD : function (component, event, helper) {        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": component.get("v.adOktaSSOUrl"),
            "target": "_blank"
        });
        urlEvent.fire();
    },
    
    logout : function(component, event, helper) {
        
        //var baseUrl = $A.get("$Label.c.CommunityBaseURL");
        var baseUrl;
        if(component.get("v.communitySuffix") === "/" || component.get("v.communitySuffix") === ""){
            baseUrl = component.get("v.communityBaseURL");
        }
        else{
        	baseUrl = component.get("v.communityBaseURL") + component.get("v.communitySuffix");
        }
        window.location.replace( baseUrl + "/AGN_CustomerPortalLogout_v2");
    } 
})