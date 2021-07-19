({	
    doInit : function(component, event, helper) {
        helper.loadPageSettings(component);             
    },
    getArticlesBySelectedGp: function(component, event, helper) {
        
        var btn = event.target;
        component.set("v.catagorylabel", btn.getAttribute('data-label'));
        component.set("v.selectedCatagory", btn.getAttribute('data-name'));
        helper.setCategoryTitle(component, btn.getAttribute('data-name'));
        
    },
    getArticlesBySelectedGpMobile: function(component, event, helper) {
        
        var btn = event.target;        
        component.set("v.catagorylabel", btn.getAttribute('data-label'));
        component.set("v.selectedCatagory", btn.getAttribute('data-name')); 
        helper.setCategoryTitle(component, btn.getAttribute('data-name'));
        helper.toggleMobileButtonSelecters(component);
    },
    showAllCategories : function(component, event, helper) {
        component.set("v.selectedCatagory",'All');
        helper.setCategoryTitle(component, "All");
    },
    showAllCategoriesMobile : function(component, event, helper) {
        component.set("v.selectedCatagory",'All');
        helper.setCategoryTitle(component, "All");
        helper.toggleMobileButtonSelecters(component);
    },
    showHideCatagoryPanelForMobile: function(component, event, helper) {
        helper.toggleMobileButtonSelecters(component);        
    },
    
})