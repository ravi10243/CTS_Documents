({
	scriptsLoaded : function(component, event, helper) {
        
        helper.initScriptLoad(component, event);
        jQuery.noConflict();
        // var user = this.getCookie("cookieAckg");
      	jQuery(document).ready(function(){
            
            jQuery('#Hamburger_Menu').click(function(e){
                e.stopPropagation();
            if(jQuery('#Hamburger_Menu').hasClass('active_menu')){
                jQuery('#MenuItem').css('display','none');
                jQuery('.OpenMenu').css('display','block');
                jQuery('.CloseMenu').css('display','none');
                jQuery('#Hamburger_Menu').removeClass('active_menu');
            }
            else{
                jQuery('#MenuItem').css('display','block');
                 jQuery('.OpenMenu').css('display','none');
                jQuery('.CloseMenu').css('display','block');
                jQuery('#Hamburger_Menu').addClass('active_menu');
            }
            
            });
            
            
            
            jQuery(document).click(function(e){
                 jQuery('#MenuItem').css('display','none');
                jQuery('.OpenMenu').css('display','block');
                jQuery('.CloseMenu').css('display','none');
                jQuery('#Hamburger_Menu').removeClass('active_menu');
            }) 
       
        
			jQuery('#footerContainerDiv').css('display','block');         
            //alert('inside doinit');
            var name = "cookieAckg=";
            var user = "";
            //alert('inside cookieAckg');
            if(document.cookie){
                var ca = document.cookie.split(';');
                for(var i = 0; i < ca.length; i++) {
                    var c = ca[i];
                   // alert(c);
                    while (c.charAt(0) == ' ') {
                        c = c.substring(1);
                    }
                    if (c.indexOf(name) == 0) {
                        user = c.substring(name.length, c.length);
                    }
                }
                
            }
            
            
            
            if (user != "") {
                console.log("Welcome again " + user);
            } else {
                console.log("Welcome not again " + user);
               // document.getElementById("hidden_cookie_content").style.display = "block";
                if(jQuery('#hidden_cookie_content')){
                    jQuery('#hidden_cookie_content').css('display','block');
                }
                 
                
            }
        });
        
        
        //Suman
        var serverAction = component.get("c.isSiteUnderMaintenance");
        serverAction.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            //alert('Status is'+response.getReturnValue());
            if (state === "SUCCESS") {
                component.set("v.isSiteUnderMaintenance", response.getReturnValue()); 
            }
        });
        $A.enqueueAction(serverAction);
        //Suman
        
	},
    doInit : function(component, event, helper) {
        jQuery.noConflict();
        jQuery(document).ready(function(){
            
            
            jQuery('#footerContainerDiv').css('display','block'); 
            
            
        });
        
        
        
	},
})