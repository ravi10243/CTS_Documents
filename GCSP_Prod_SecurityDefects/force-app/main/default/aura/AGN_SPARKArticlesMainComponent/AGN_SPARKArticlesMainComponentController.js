({
    /*
     * Function to fetch details for initial page load
     */ 
	doInit : function(component, event, helper) {   
        
    	var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;
		var redirectFromHome = false;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            
            if (sParameterName[0] === 'articleCategory') { //lets say you are looking for param name - firstName
                var articleCategory=sParameterName[1];
                redirectFromHome = true;
                //alert('Outside doc ready');
                //helper.fetchArticlesForBtnOnload(component, event, articleCategory);
                jQuery( document ).ready(function() {
                    //alert('Inside doc ready');
                    helper.selectArticleTab(component, event, articleCategory);
                    
                });
                 
               
            }
        }
        
        
        
        
        
        helper.getBackgroundImage(component);
	    
        var isListPage = helper.setIntialLoad(component);
        if(isListPage){
            helper.getArticleCount(component, event, '');
        	helper.getArticlesData(component, event, '', false, false); 
        }    
        helper.hideCommunitySpinner(component);
        
        if(redirectFromHome ==true){
            helper.getAllCategoriesList(component, articleCategory);
            component.set("v.articleCategoeryType", articleCategory);
            component.set("v.mainCategoryName", articleCategory);
        }else{
            helper.getAllCategoriesList(component,articleCategory);
        }
    	
    
    },
    
    selectArticleTab: function(component, event, helper) {
        var args = event.getParam("arguments");
        var categoryType = "Getting_Started_" + args.categoryType;
        helper.selectArticleTab(component, event,categoryType);
        component.set("v.mainCategoryName", categoryType);
    },
    
    /*handleArticleCategorySelection : function(cmp, event) {
        var articleType = event.getParam("articleCategory");
 		//alert('fireApplicationEvent'+articleType);
        // set the handler attributes based on event data
        cmp.set("v.articleCategoeryType", articleType);

    },*/   
	/*
     * Function to set main category from popup selection
     */
    setMainCategoryFromPopUp : function(component, event, helper){
       
       helper.resetPagination(component);
       helper.resetIntialLoad(component);
       helper.settingMainCategory(component, event, helper);
       $A.util.removeClass(component.find("showMobile"), "mobile-wrapper");
       helper.scrolPageToView();
    },
    
    /*
     * Function fetch to based on selected category - Desktop
     */
    getCatArticles: function(component, event, helper){
        helper.fetchArticlesForBtn(component, event);
    },
    
    /*
     * Function fetch to based on selected category - Mobile
     */
    getCatArticlesMobile: function(component, event, helper){
       /* helper.fetchArticlesForBtn(component, event);
		$A.util.toggleClass(component.find("catagoryOptions"), "showVmenu");
		$A.util.removeClass(component.find("catagoryBtnIcon"), "glyphicon-minus minus");
        $A.util.addClass(component.find("catagoryBtnIcon"), "glyphicon-plus plus");*/
        
        
        // New code implemented for back button
       
        
        var articleId = event.currentTarget.getAttribute("data-Id");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
         	"url" : '/knowledge-hub?articleCategory='+articleId,
        });
        urlEvent.fire();
    },
    
     /*
     * Function to do a serch on enter key in main search
     */
    keyCheckMain : function(component, event, helper){
       // alert(event.which);
        if (event.which == 13){
            helper.resetIntialLoad(component);
            helper.doArticleSearch(component, event);
        }
        
        if(component.get("v.mainSearch").length <	 1){
            component.set("v.showNoResultComponent", false);
        }    
    },
    
     /*
     * Function to do a serch on enter key in sidebar search
     */
    keyCheckSidebar : function(component, event, helper){
        if (event.which == 13){
            component.set("v.mainSearch","");
            helper.doArticleSidebarSearch(component, event);
        }    
    },
    
    /*
     * Function to display selected articles from list  
     */
    imgArticle: function(component, event){
        jQuery('#kh_filter_box').hide();
        jQuery('#kh_search_box').hide();
        var id = event.currentTarget.getAttribute('data-Id');        
        component.set("v.articleId",id);        
        component.set("v.showListPage", false);
        
        var articleId = event.currentTarget.getAttribute("data-Id");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
         	"url" : '/knowledge-hub?id='+articleId+'#browseText',
        });
        urlEvent.fire();
       
    },
    
    
    /*
     * Function to do article main search   
     */
    articleMainSearch: function(component, event, helper){
        helper.resetIntialLoad(component);
        helper.doArticleSearch(component, event);
    },
    
     /*
     * Function to fetch articles by subcategory   - desktop
     */
    getArticlesSubCategory: function(component, event, helper){
        helper.fetchArticlesSubCategory(component, event);
    },
    
     /*
     * Function to fetch articles by subcategory   - Mobile
     */
    getArticlesSubCategoryMobile: function(component, event, helper){
        helper.fetchArticlesSubCategory(component, event);
        jQuery('#kh_filter_box').show();
        jQuery('#kh_search_box').show();
        $A.util.removeClass(component.find("hotTopicBtnIcon"), "glyphicon-minus minus");
        $A.util.addClass(component.find("hotTopicBtnIcon"), "glyphicon-plus plus");
        $A.util.toggleClass(component.find("hotTopicOptions"), "showVmenu");
    },
    
    /*
     * Function to do article sidebar search   
     */
    articleSideSearch: function(component, event, helper){
        component.set("v.mainSearch","");
        helper.doArticleSidebarSearch(component, event);
        
    },
    
    /*
     * Function to check empty search   
     */
    checkForNull: function(component, event){
        var value =  event.getSource().get('v.value');
        if(value == '' ){
            component.set("v.showNoResultComponent",false);
        }
    },
    
    /*
     * Function to fetch previous page items  
     */
    pageNationBack: function(component, event, helper){
       var pageNumber = component.get("v.pageNumber");
       var pageCurrentNumber = component.get("v.pageCurrentNumber");
       
        if(pageCurrentNumber == pageNumber)
        {	component.set("v.pageNumber",pageNumber-1);
            component.set("v.pageCurrentNumber",pageCurrentNumber-1);
        }else{
            component.set("v.pageCurrentNumber",pageCurrentNumber-1);
        }
        
        var mainSearch = component.get("v.mainSearch").trim();
        var searchText = (mainSearch.length > 0 )? mainSearch : component.get("v.subSearch");
       helper.getArticlesData(component, event, searchText, false, false); 
    
    },
    
    /*
     * Function to fetch next page items  
     */
    pageNationFwrd: function(component, event, helper){
      var pageNumber = component.get("v.pageNumber");
      var pageCurrentNumber = component.get("v.pageCurrentNumber");
        if(pageCurrentNumber == pageNumber+4)
        {	component.set("v.pageNumber",pageNumber+1);
            component.set("v.pageCurrentNumber",pageCurrentNumber+1);
        }else{
            component.set("v.pageCurrentNumber",pageCurrentNumber+1);
        }
      var mainSearch = component.get("v.mainSearch").trim();
      var searchText = (mainSearch.length > 0 )? mainSearch : component.get("v.subSearch");
      helper.getArticlesData(component, event, searchText, false, false);
    
    },
    
     /*
     * Function to fetch page items by page number
     */
    fetchPageList: function(component, event, helper){
        
        var pageNumber = event.currentTarget.getAttribute('data-page');
        
        component.set("v.pageCurrentNumber",parseInt(pageNumber));    
        var mainSearch = component.get("v.mainSearch").trim();
        var searchText = (mainSearch.length > 0 )? mainSearch : component.get("v.subSearch");
       // helper.getArticlesData(component, event, '', false, false);
        helper.getArticlesData(component, event, searchText, false, false); 
    },
    
     /*
     * Function to fetch page items for mobile next button
     */    
    fetchMoreListMobile : function(component, event, helper){
      var pageCurrentNumber = component.get("v.pageCurrentNumber");
      component.set("v.pageCurrentNumber", pageCurrentNumber+1);
      var mainSearch = component.get("v.mainSearch").trim();
      var searchText = (mainSearch.length > 0 )? mainSearch : component.get("v.subSearch");
      helper.getArticlesData(component, event, searchText, false, true);
    },
    
     /*
     * Function to fetch page items for mobile less button
     */
    showLessListMobile : function(component){
        var articleData = component.get("v.articleDataList");
        var articleList = articleData.articleResult.slice(0, articleData.pageLimit);
        articleData.articleResult = articleList;
        component.set("v.articleDataList", articleData);       
        $A.util.addClass(component.find("mobileLess"), "slds-hide");
    },
    
     /*
     * Function to hide & show mobile select category button
     */
    showHideCatagoryPanelForMobile: function(component, event, helper) {
        helper.toggleMobileButtonSelecters(component);        
    },
    
    /*
     * Function to hide & show mobile hot topics button
     */
    showHideHotTopicForMobile: function(component, event, helper) {
        helper.toggleMobileButtonHotTopic(component);
    }, 
})