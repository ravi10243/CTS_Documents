({    
    getAllArticles : function(component, event, selectedCatogry) {
        //alert('test');
        var Limit = component.get("v.articleEndNumber");
        var device = component.get("v.device");

        var pageoffset = component.get("v.pageCurrentNumber");
        var action = component.get("c.getAllTrainingArticles");
        action.setParams({           
            "selectedCatagory": selectedCatogry,
            "dataLimit" : Limit,
            "pageNumber" :(pageoffset-1)*Limit
        });
        this.showCommunitySpinner(component);
        action.setCallback(this, function(response) {            
            
            var state = response.getState(); 
            if (state === "SUCCESS") { 

                if(response.getReturnValue() != null){ 
                    if(device == 'Mob'){
                        var OldValues = component.get("v.trainingProvidersArticles");
                        var fullList =   OldValues.concat(response.getReturnValue().trainingProviders) ; 
                        component.set("v.trainingProvidersArticles",fullList );
                    }
                    else{
                    	component.set("v.trainingProvidersArticles",response.getReturnValue().trainingProviders );
                    }
                    
                    var totalCount = response.getReturnValue().totalCount ;
                    component.set("v.articleCount",totalCount);
                    var Limit = response.getReturnValue().dataLimit;
                    var maxPages =    totalCount/Limit;

                    var i = parseInt(maxPages);
                    if(maxPages>i){
                        i =  i+1;
                    }
                    component.set("v.totalPages", i);
                    component.set("v.articleEndNumber", Limit);
                    this.hideCommunitySpinner(component);
                    
                    return;
                }
            }
            component.set("v.pageMessage", $A.get("$Label.c.AGN_SPARK_No_Items_Found"));
           	this.hideCommunitySpinner(component);

        }); 
        $A.enqueueAction(action);
    },
    
    logViewStat: function(component,event){
        var btn = event.target;
        var action = component.get("c.getViews");
        action.setParams({           
            "articleId": btn.getAttribute('data-id')
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
            	console.log('Status'+response.getReturnValue());
            }
            });
        
        $A.enqueueAction(action);
    },
    
    resetPagination : function (component){
        component.set("v.articleEndNumber", 0);
        component.set("v.pageCurrentNumber", 1);
    },
    scrollToArticleList: function(component){
    	var element = document.getElementById(component.get("v.selectedCatagory"));
       // var element = component.find("list-top").getElement();
		element.scrollIntoView(true);
	},
    getPageImages : function(component) {
       
		var action = component.get("c.getImages");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state ==='SUCCESS'){
            	component.set("v.AGNSPARKImages", response.getReturnValue());
                }
            });
        $A.enqueueAction(action);
	},
    showCommunitySpinner: function(component){
        
        $A.util.removeClass(component.find("siteSpinner"), "hideEl");

	},
    hideCommunitySpinner: function(component){
        $A.util.addClass(component.find("siteSpinner"), "hideEl");

    },
    
})