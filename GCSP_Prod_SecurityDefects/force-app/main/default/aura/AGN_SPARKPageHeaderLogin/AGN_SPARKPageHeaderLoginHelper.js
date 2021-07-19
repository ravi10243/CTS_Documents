({
	getUserType : function(component) {
		var action = component.get("c.userType");       
        action.setCallback(this, function(a) {
            var info = a.getReturnValue();
            component.set("v.userType",info);
            //document.body.style.overflow="hidden";
        });
		$A.enqueueAction(action);
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
    
    navigateToPage : function(pageName) {
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
      		"url": "/"+pageName,
      		
   		});
    	urlEvent.fire();
    },
    
    hideMobileMenu : function() {        	
            if($(window).width()<765){
                $(".icon_close").css("display","none");
                $(".wrapper").css("position","relative");
                $(".icon").css("display","block");
                $(".top_nav").css("display","none");
                $(".top_nav").removeClass("popup-overlay");
                
                
            }
        
        $("#MenuItem").css("display","none");
        $("#MenuItem").removeClass("popup-overlay");
	}
    
})