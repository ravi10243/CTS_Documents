({
    loadPageSettings : function(component) {
       
		var action = component.get("c.getPageSettings");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
                var result = response.getReturnValue();
                if(!$A.util.isEmpty(result)){
                    component.set("v.AGNSPARKImages", result.images);
                    this.setCategories(component,result.categories);
                }
                console.log('result', result);
            	//component.set("v.AGNSPARKImages", response.getReturnValue());
                }
            });
        $A.enqueueAction(action);
	},
    
    toggleMobileButtonSelecters : function (component){
        if($A.util.hasClass(component.find("catagoryBtnIcon"), "plus")){
            $A.util.removeClass(component.find("catagoryBtnIcon"), "glyphicon-plus plus");
            $A.util.addClass(component.find("catagoryBtnIcon"), "glyphicon-minus minus");
        }else{
            $A.util.removeClass(component.find("catagoryBtnIcon"), "glyphicon-minus minus");
            $A.util.addClass(component.find("catagoryBtnIcon"), "glyphicon-plus plus");
            
        }
        $A.util.toggleClass(component.find("catagoryOptions"), "showVmenu");
    },    
    setCategories : function (component,categoriesMap){
        var custs = [];
        for(var key in categoriesMap){
            custs.push({value:categoriesMap[key], key:key});
        }
        component.set("v.mainCategories",custs);
    },
    setCategoryTitle: function (component, category){
        var cateroryTitle = "";
        switch(category){
            case "All": cateroryTitle = "Training Providers"; break;
            case "Digital_Training": cateroryTitle = "Digital <br/>Training Providers"; break;
            case "Faculty": cateroryTitle = "Faculty Providers"; break;
            case "Training_Provider": cateroryTitle = "Training Providers"; break;
        }
        component.set("v.catagoryTitle", cateroryTitle);
    },
    showCommunitySpinner: function(component){
        
        $A.util.removeClass(component.find("siteSpinner"), "hideEl");
    	//document.querySelector('.siteforceSpinnerManager.siteforcePanelsContainer').classList.remove('hideEl');
	},
    hideCommunitySpinner: function(component){
        $A.util.addClass(component.find("siteSpinner"), "hideEl");

        //document.querySelector('.siteforceSpinnerManager.siteforcePanelsContainer').classList.add('hideEl');
    },
    
})