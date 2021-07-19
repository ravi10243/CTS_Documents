({	
    /*
     * Common Method to Navigate a page
     */
    navigateToPage : function(pageName) {
       
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
      		"url": "/"+pageName,
      		
   		});
    	urlEvent.fire();
    },
    
    /*
     * Method to get page images urls
     */
    getPageImages : function(component) {
       
		var action = component.get("c.getImages");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
            	component.set("v.AGNSPARKImage", response.getReturnValue());
           		
                }
            });
        $A.enqueueAction(action);
	},
    
    /*
     * Method to get login user details
     */
    getUserData : function(component){
    	var action = component.get("c.getUserDetails");
		action.setCallback(this, function(response) {
            var state = response.getState();
            var userType = response.getReturnValue();
            console.log('userType.acrDetails>>>',userType.acrDetails);
            if(state == 'SUCCESS' && !$A.util.isEmpty(userType)){
                component.set("v.compltProfile", userType.acrDetails);
            	component.set("v.loginUser", userType.logIn);
            	component.set("v.userType", userType.isLogined);
            }else{
                console.log('Error');
            }
            
		});
        $A.enqueueAction(action);  
    
	}
})