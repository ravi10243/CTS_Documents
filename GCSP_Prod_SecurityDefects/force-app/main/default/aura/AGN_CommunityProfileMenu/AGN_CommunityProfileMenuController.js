({
	init : function(component, event, helper) {
        
        var action = component.get("c.getUserDetail");
	    
    	action.setCallback(this, function(actionResult) {
        component.set("v.userDetail", actionResult.getReturnValue());           
        });
        $A.enqueueAction(action);	
        helper.getOAMMenuEnabled(component, event);
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
       /* var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/"
        });
        urlEvent.fire(); */
        var baseUrl = $A.get("$Label.c.CommunityBaseURL");
        window.location.replace(baseUrl);

    },
    

    logout : function(component, event, helper) {
        var baseUrl = $A.get("$Label.c.CommunityBaseURL");
        
       	//window.location.replace("https://d17-allergan.cs88.force.com/allergancustomer/servlet/networks/switch?startURL=%2Fsecur%2Flogout.jsp?retUrl");
       	window.location.replace( baseUrl + "/AGN_CustomerPortalLogout");
    },
    gotoICLPage : function (component, event, helper) {        
        var urlEvent = $A.get("e.force:navigateToURL");
        var jsoncust = JSON.parse(JSON.stringify(component.get("v.customerAcc")));
        var jsonprim = JSON.parse(JSON.stringify(jsoncust["Primary_Parent_vod__r"]));
        if(jsonprim["Registered_For_Clinic_Locator_AGN__c"]){
            urlEvent.setParams({
                "url": "/agn-icl-message"
            });
        }else{
            urlEvent.setParams({
                "url": "/registerationicl"
            });
        }
        
        urlEvent.fire();
    }
    
    
})