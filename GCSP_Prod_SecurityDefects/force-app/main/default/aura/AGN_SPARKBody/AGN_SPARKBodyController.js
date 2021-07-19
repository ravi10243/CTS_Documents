({
    /*
     * Method to fetch initial page data 
     */
	doInit : function(component, event, helper) {
                
       // helper.getPageImages(component);
        helper.getUserData(component);
        
        
        
        
        
        
        
           
    },
    
    /*
     * Method to Navigate for Knowledge page
     */
    knowledgePage: function(component, event, helper){ 
        var KnowledgehubPage = component.get("v.KnowledgehubPage");
                //alert(KnowledgehubPage);
                //alert(component);
       // var appEvent = $A.get("e.c:AGN_SPARK_NavigateToArticle");
        //appEvent.setParams({ "articleCategory" : 'Getting_Started_Business' });
       // appEvent.fire();
        var idx = event.target.id;
        //alert(idx);
        helper.navigateToPage(KnowledgehubPage+'?articleCategory='+idx);
       
       // fireNavigateToArticle(component, event, KnowledgehubPage);
    }, 
    
    /*fireNavigateToArticle : function(component, event, KnowledgehubPage) {
         alert('hi');
        var appEvent = $A.get("e.c:AGN_SPARK_NavigateToArticle");
        appEvent.setParams({ "articleType" : 'Getting_Started_Business' });
        appEvent.fire();
    },*/
    
    /*
     * Method triggering event to show registration page
     */    
    fireRegisterEvent : function(component, event) {
        document.body.style.overflow="hidden";
        var appEvent = $A.get("e.c:AGN_SPARK_RegisterEvent");
        appEvent.fire();
    },
    
    /*
     * Method to hide the myprofile initial update form
     */ 
    closeAction: function(component, event, helper) {
        component.set('v.compltProfile.AGN_SPARK_Update_my_Profile__c', true);
    },
    
	/*
     * Method for initialising scripts
     */
    scriptsLoaded : function(component, event, helper) {
		/*jQuery.noConflict();
        jQuery(document).mouseup(function (e){
            var container= jQuery('.footer_popup');
            if (!container.is(e.target)&& container.has(e.target).length === 0) {
                container.hide();
            }
        });
        jQuery(".footer .privacy-statement").on('click', function() {
            jQuery('.condition-text').hide();
            jQuery('.footer_popup').show();
            jQuery('.privacy-text').show();
                    
    	});
    
    	jQuery(".footer .condition-use").on('click', function() {
            jQuery('.privacy-text').hide();
            jQuery('.footer_popup').show();
            jQuery('.condition-text').show();
                    
    	});*/
        
        
        
        
        
        
	},
    
    /*
     * Method to Navigate for login page
     */
    loginPage: function(component, event, helper){
        window.location.href =  'login/' ; 
    },
    
    /*
     * Method to for loging out
     */
    logoutPage:function(component, event, helper){
       window.location.replace("/Spark/secur/logout.jsp");
    },
    
    trainingPage:function(component, event, helper){
       helper.navigateToPage('training');
    },
    
    trainingProviders:function(component, event, helper){
       //helper.navigateToPage('training-providers');
       helper.navigateToPage('training');
    },
})