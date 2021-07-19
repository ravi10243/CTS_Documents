({
	doInit : function(component, event, helper) {
		 var allowToHome = false;
        var urlEvent = $A.get("e.force:navigateToURL");
        if(!allowToHome){
           urlEvent.setParams({
                "url": "/agncustomerregistration2"
            });
            urlEvent.fire();
        }
       
	}
})