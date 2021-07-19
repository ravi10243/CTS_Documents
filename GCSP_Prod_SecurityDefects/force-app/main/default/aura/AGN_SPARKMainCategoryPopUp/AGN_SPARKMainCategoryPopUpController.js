({
	/*setMainCategory : function(component, event, helper) {
        
		helper.setCategoryPopUp(component, event);
	}, */
    selCategory : function(component, event, helper) { 

		helper.selectedCategory(component, event);
	}, 
      
    doInit : function(component, event, helper) {
        helper.setCategory(component, event);
        //helper.getPageImages(component, event, helper);
    }
})