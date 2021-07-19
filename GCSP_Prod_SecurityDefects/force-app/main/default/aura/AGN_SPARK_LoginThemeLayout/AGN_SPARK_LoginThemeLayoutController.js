({
	scriptsLoaded : function(component, event, helper) {
        
        $(document).ready(function(){
            
            
            $('#footerContainerDiv').css('display','block'); 
            
            
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
        
        $(document).ready(function(){
            
            
            $('#footerContainerDiv').css('display','block'); 
            
            
        });
        
	},
})