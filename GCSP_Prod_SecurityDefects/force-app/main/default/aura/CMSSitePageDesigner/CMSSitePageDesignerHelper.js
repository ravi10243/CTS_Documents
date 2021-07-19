({
	pageParameterReader : function(component, event, helper) 
    {
        var parametermap = {};
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        //alert(sPageURL);
        
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        
        for (var i = 0; i < sURLVariables.length; i++) 
        {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.    
            parametermap[sParameterName[0]]=sParameterName[1];
        }	
      
        return parametermap;
    },
    createBuilder : function(component) {
        $A.createComponent(
            "c:CMS_BuilderInDesigner",
            {
                "currentUserViewMode": component.get("v.currentUserViewMode"),
                "recordId":  component.get("v.recordId")
            },
            function(CMS_BuilderInDesigner, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.builder");
                    body.push(CMS_BuilderInDesigner);
                    component.set("v.builder", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                    else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                        // Show error message
                    }
            }
        );
    },
    refreshBuilder : function(component, helper) {
        component.set("v.builder", []);
        helper.createBuilder(component);
    }
})