({
	setCategory : function(component, event) {
	    var action = component.get("c.getArticleTypes");      
        action.setCallback(this, function(response){
        var state = response.getState(); 
            if(state == 'SUCCESS') {
                var catList = response.getReturnValue();
                console.log('catList', catList);
            	component.set("v.mainCategory",catList);
            } 
        });
        $A.enqueueAction(action);  
        
	},
    selectedCategory :function(component, event) {
        var isPopUp = component.get("v.isPopUp"); 
        if(isPopUp){
         component.set("v.showPop",false); 
        }
        
      /*  var tar=event.currentTarget;
        console.log(tar);
        var tarvalue=tar.dataset.catName;*/
        var tar = event.currentTarget.getAttribute('data-catName');
       
        var evt = component.getEvent("passSelectedCategoryToMain");
        
        evt.setParams({
          "selectedMainCategory" :  tar
         });     
        evt.fire();  
        
    }
})