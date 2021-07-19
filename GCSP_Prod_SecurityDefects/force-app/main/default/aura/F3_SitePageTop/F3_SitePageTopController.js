({
	getApplication : function(component, event, helper) {
		
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
        var lexAppId = parametermap['appId'];
        var getApplication = component.get("c.getApplicationById");
        getApplication.setParams({
            appId : lexAppId
        });
        //component.set("v.applicationId",component.get("v.recordId")); 
        getApplication.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.application",response.getReturnValue());                
            }
        });
        $A.enqueueAction(getApplication);
    }
})