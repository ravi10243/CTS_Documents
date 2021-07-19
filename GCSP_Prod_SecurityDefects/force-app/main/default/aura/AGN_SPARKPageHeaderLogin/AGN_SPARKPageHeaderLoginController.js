({
	doInit : function(component, event, helper) {
       //document.getElementById("headeranim").style.display = "none";
        
        helper.getUserType(component);
        helper.getPageImages(component);
        
	},
    
    loginPage: function(component, event, helper){
        window.location.href =  'login/' ; 
    },
    
    homePage : function(component, event, helper){
        helper.navigateToPage('');
    },
    
    knowledgePage: function(component, event, helper){
        var KnowledgehubPage = component.get("v.KnowledgehubPage");
        console.log('KnowledgehubPage', KnowledgehubPage);
        helper.navigateToPage(KnowledgehubPage+'?articleCategory=Getting_Started_Clinical');
        helper.hideMobileMenu();
    },    
    trainingPage: function(component, event, helper){
        var training = component.get("v.training");
        helper.navigateToPage(training);
        helper.hideMobileMenu();
    },
    contactUsPage: function(component, event, helper){
        var contactUs = component.get("v.contact");
        contactUs = 'contactus'
        helper.navigateToPage(contactUs);
        helper.hideMobileMenu();
    },
    
    
    logoutPage:function(component, event, helper){
     
        
	// paste your login page link here, where you want to come back
       //window.location.href=returnUrl?retUrl=/www.google.com;   
      //window.location.href =  'login/' ;
      window.location.replace("/secur/logout.jsp");
      //window.location.replace("/Spark/secur/logout.jsp?retUrl=https://sprkcrdv-allergancommunityeu.cs101.force.com/Spark/s/login/");
       /* var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/secur/logout.jsp?retUrl=/",
            "isredirect": true,
        });
        urlEvent.fire();         
        */
    },
    
    clickRegister :function(component, event,helper) {
        document.body.style.overflow="hidden";
        console.log("entering the controller header register");
        var appEvent = $A.get("e.c:AGN_SPARK_RegisterEvent");
        appEvent.fire();
        helper.hideMobileMenu();
        console.log("end of controller of header register");
    },
    
})