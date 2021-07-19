({ 
    doInit : function(component, event, helper) {
    var url = window.location.href;
        console.log("url>>>>", url);
        var containsUrl = url.includes("ForgotPassword");
        console.log("containsUrl>>>>", containsUrl);
        if(containsUrl == true){
           component.set("v.register", false);
           component.set("v.login", true);
        }else{
            component.set("v.register", true);
           component.set("v.login", false);
        }
        
    },
    
    handleClick : function (cmp, event, helper) {
        alert("You clicked: " + event.getSource().get("v.label"));
    },
     handleSelect: function (cmp, event, helper) {
        // This will contain the string of the "value" attribute of the selected
        // lightning:menuItem
        var selectedMenuItemValue = event.getParam("value");
        alert("Menu item selected with value: " + selectedMenuItemValue);
    },
    
    /*loginComponent: function(component, event, helpler){
        console.log("Entering the component");
        //Create component dynamically
        $A.createComponent(
            "c:AGN_Spark_LoginForm",
            {
                
            },
             function(newcomponent, status, errorMessage){
                if (status === "SUCCESS") {
                    var divCmp = component.find("testdiv");  
                    divCmp.set("v.body", []);
                    var body = divCmp.get("v.body");
                    body.push(newcomponent);
                    divCmp.set("v.body", body);
                }
            }
        );
    },*/
     homePageDirect :function(component, event, helpler){
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
      		"url": "/"
      		
   		});
    	urlEvent.fire();
    },
     showHomePage : function(component, event, helper) {
    	var homeUrl = window.location.href;
        homeUrl = homeUrl.slice(0, homeUrl.indexOf('login/'));
        window.location.href = homeUrl;
     },
    
    clickRegister :function(component, event) {
        document.body.style.overflow="hidden";
        console.log("entering the controller header register");
        var appEvent = $A.get("e.c:AGN_SPARK_RegisterEvent");
        appEvent.fire();
        console.log("end of controller of header register");
    },
    
    clickLogin :function(component, event) {
        window.location.reload();
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/"
        });
        urlEvent.fire();
    },
})