({
    /*
     * Function to get categories list from apex controller 
     */
    getAllCategoriesList : function(component, mainCatName) {
        var action = component.get("c.getAllCategories");
        action.setCallback(this,function(actionResult){
            if(component.isValid() && actionResult.getState() == "SUCCESS"){
                var result = JSON.parse(actionResult.getReturnValue());
                //alert('Result is: '+mainCatName);
                if(mainCatName != ''){
                    component.set("v.mainCategory", mainCatName);
                    this.setArticlesCategories(component,result, mainCatName);
                }else{
                    component.set("v.mainCategory", result);
                    this.setArticlesCategories(component, result, '');
                }
                
                
                
            }
            
        })  
        $A.enqueueAction(action);
    },
    
    /*
     * Function to do article seach with apex controller 
     */
    doArticleSearch : function(component, event){
       
        
        var mainSearch = component.get("v.mainSearch");
        var n = mainSearch.trim().length;
        if(n > 2){          
         component.set("v.subSearch","");
         component.set("v.articleCategoeryType",'all');
         this.resetPagination(component);
         this.getArticleCount(component, event, mainSearch);
         this.getArticlesData(component, event, mainSearch, true, false);
         
        }
    },
    
    /*
     * Function to do article seach from sidebar with apex controller 
     */    
    doArticleSidebarSearch: function (component, event){
        this.resetPagination(component);
        var subSearch = component.get("v.subSearch");
        var n = subSearch.trim().length;
        if(n > 2){
         this.getArticleCount(component, event, subSearch);
         this.getArticlesData(component, event, subSearch, false, false);
        }
    },
    
    /*
     * Function to fetch article from apex controller 
     */ 
    fetchArticlesForBtn: function(component, event){
        component.set("v.articleSubTypeSelected",'');
        component.set("v.mainSearch","");
        component.set("v.subSearch","");
        jQuery('#kh_filter_box').show();
        jQuery('#kh_search_box').show();
        var categoeryname = event.currentTarget.getAttribute('data-id');
        //alert(categoeryname);
        this.selectArticleTab(component, event,categoeryname);
        component.set("v.mainCategoryName", categoeryname);
        component.set("v.articleCategoeryType",categoeryname);
        this.resetPagination(component);
        this.resetIntialLoad(component);
        this.setSubCategoeryType(component, event,categoeryname);
        this.createZincCode(component);
        this.getArticleCount(component, event , '');
        
        this.getArticlesData(component, event, '', false, false);
        
         
       
    },
    
    /*
     * Function to fetch article from apex controller 
     */ 
    fetchArticlesForBtnOnload: function(component, event, catname){
        
        var categoeryname = catname;
        component.set("v.articleSubTypeSelected",categoeryname);
        component.set("v.mainSearch","");
        component.set("v.subSearch","");
        
        
        
        component.set("v.mainCategoryName", categoeryname);
        component.set("v.articleCategoeryType",categoeryname);
        this.resetPagination(component);
        this.resetIntialLoad(component);
        this.setSubCategoeryType(component, event,categoeryname);
        this.createZincCode(component);
        this.getArticleCount(component, event , '');
        
        this.getArticlesData(component, event, '', false, false);
        this.selectArticleTab(component, event,categoeryname);
         
       
    },
    
    /*
     * Function to select the article Tab 
     */ 
    selectArticleTab: function(component, event, categoeryname){
        //alert(categoeryname);
        component.set("v.mainCategoryName", categoeryname);
        if((categoeryname == 'Getting_Started_Clinical') || (categoeryname == 'Clinical') ){
            jQuery('#clinical').css('display','block');
            jQuery('#Clinical').addClass('active');
            jQuery('#Business,#Product,#Video').removeClass('active');
            jQuery('#span_cat_name').html('Clinical');
            jQuery('#business,#product,#video').hide();
            
        }
        else if((categoeryname == 'Getting_Started_Business') || (categoeryname == 'Business')){
            jQuery('#business').css('display','block');
            jQuery('#span_cat_name').html('Business');
            jQuery('#clinical,#product,#video').hide();
            jQuery('#Business').addClass('active');
            jQuery('#Clinical,#Product,#Video').removeClass('active');
        }
        else if((categoeryname == 'Getting_Started_Product') || (categoeryname == 'Product')){
            jQuery('#span_cat_name').html('Product');
            jQuery('#product').css('display','block');
            jQuery('#clinical,#business,#video').hide();
            jQuery('#Product').addClass('active');
            jQuery('#Clinical,#Business,#Video').removeClass('active');
        }
        else{
            jQuery('#span_cat_name').html('Video');
            jQuery('#video').css('display','block');
            jQuery('#clinical,#business,#product').hide();
            jQuery('#Video').addClass('active');
            jQuery('#Clinical,#Business,#Product').removeClass('active');
            
        }
        
    },
    
    /*
     * Function to fetch article from apex controller by subcategory
     */     
    fetchArticlesSubCategory: function(component, event){
        var categoeryname = event.currentTarget.getAttribute('data-id');
        component.set("v.subSearch","");
        component.set("v.mainSearch","");
        component.set("v.articleCategoeryType",categoeryname);
        component.set("v.articleSubTypeSelected",categoeryname);
        this.resetPagination(component);
        this.getArticleCount(component, event, '');
        this.getArticlesData(component, event, '', false, false);
    },
    
    /*
     * Function to do apex transaction to fech articles
     */
    getArticlesData : function(component, event, searchText, isMain, isMobile) {
       
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var articleCategory = '';
        var i;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            
            if (sParameterName[0] === 'articleCategory') { //lets say you are looking for param name - firstName
                articleCategory=sParameterName[1];               
            }
        }
        
        if(articleCategory != ''){
            var articleCategoeryType = articleCategory;
        }else{
            var articleCategoeryType = component.get("v.articleCategoeryType");
        }
        
        
        
        
        
       var limit = component.get("v.pageLimit");
       var pageoffset = component.get("v.pageCurrentNumber"); //Need to change
       var action = component.get("c.getArticlesList");
       action.setParams({
            "dataLimit" : limit,
            "pageNumber" :(pageoffset-1)*limit,
            "articleType": articleCategoeryType,
            "searchText": searchText.trim(),
        });
        
        this.showCommunitySpinner(component);
        action.setCallback(this,function(a){
            
            if(a.getState() == "SUCCESS"){
                var result = a.getReturnValue(); 
               
                if($A.util.isEmpty(result.articleResult)==true){
                    component.set("v.showNoResultComponent",true);
                    
                }else{
                    if(isMobile){
                        this.appendListData(component, result);
                        $A.util.removeClass(component.find("mobileLess"), "slds-hide");
                    }else{
                        component.set("v.articleDataList",result);
                    }                    
                    component.set("v.showNoResultComponent",false);
                    component.set("v.pageLimit", result.pageLimit);
                    component.set("v.showListPage", true);
                    if(isMain){
                        component.set("v.articleType","");
                     	component.set("v.articleSubTypeSelected",'');                    
                     	component.set("v.mainCategoryName",'');
                    }
                     
                }
            }
             this.hideCommunitySpinner(component);
        });
        $A.enqueueAction(action);
    },
    
    /*
    * Function to append article list if its a mobile pagination 
    */
    appendListData : function(component, result){
    	var currentData = component.get("v.articleDataList");
        if($A.util.isEmpty(currentData)){
            component.set("v.articleDataList", result);
        }else {
            currentData.articleResult = currentData.articleResult.concat(result.articleResult);
            component.set("v.articleDataList", currentData);
        }
	},
    
    /*
    * Function to get total acticles count from apex
    */
    getArticleCount: function(component, event, searchText) {
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var articleCategory = '';
        var i;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            
            if (sParameterName[0] === 'articleCategory') { //lets say you are looking for param name - firstName
                articleCategory=sParameterName[1];               
            }
        }
        
        if(articleCategory != ''){
            var articleCategoeryType = articleCategory;
        }else{
            var articleCategoeryType = component.get("v.articleCategoeryType");
        }
        
        

        var action = component.get("c.getArticlesCount");
        //alert(articleCategoeryType);
        action.setParams({
            "articleType": articleCategoeryType,
            "searchText": searchText.trim(),
        });
        action.setCallback(this,function(a){
            
            if(a.getState() == "SUCCESS"){
                var result = a.getReturnValue();
                //alert(result);
                component.set("v.articleCount",result);
                
                var Limit = component.get("v.pageLimit");
                
                var maxPages =    result/Limit;
                var i = parseInt(maxPages);
                if(maxPages>i){
                    i =  i+1;
                }
                component.set("v.totalPages",i);
                component.set("v.articleCount",result);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    /*
    * Function to set and group the category list
    */
    setArticlesCategories: function(component, mainCategory, mainCatName) {
        var categoryGroup = component.get("v.categoryGroupName");
        var categoryList ;
        var i;
        var selMainCat;
        var realCategoryData;
        for(i in mainCategory){
            var main = mainCategory[i];
            
            categoryList = main.topCategories;
            
            
            var s;
            for (s in categoryList){
                var mainCat = categoryList[s].childCategories; 
                
                var k;
               
                
                
                for (k in mainCat){
                    var mainCatdata = mainCat[k]; 
                    //alert('mainCatdata.name: '+mainCatdata.name +categoryGroup);
                    if(mainCatdata.name == categoryGroup){
                        realCategoryData =  mainCatdata.childCategories;
                        
                        /*if(mainCatName!='' && realCategoryData[s].name == mainCatName){
                            selMainCat = mainCatName;
                        }*/
                    }
                    
                }
            }
            
        }
        //alert('realCategoryData.length '+realCategoryData[0].name+realCategoryData[1].name);
        
        if(realCategoryData.length > 0){
            if(mainCatName){
                component.set("v.mainCategoryName", mainCatName);
            }else{
                component.set("v.mainCategoryName", realCategoryData[0].name);
            }
            
        	component.set("v.mainrealCategory", realCategoryData);
        	component.set("v.articleSubType",realCategoryData[0].childCategories);
         }
        
       
    },
    
    /*
    * Function to assign subcategory type
    */
    setSubCategoeryType: function(component, event,categoeryname) {
        var setSub =  component.get("v.mainrealCategory");
        var i;
        for(i in setSub){
            var setSubcat = setSub[i];
            if(setSubcat.name==categoeryname){
                component.set("v.articleSubType",setSubcat.childCategories);   
            }
        }
    },
    
    /*
    * Function to fetch page banner image 
    */
    getBackgroundImage: function(component,categoeryname) {
        
        var action = component.get("c.getImageURL"); 
        
        action.setParams({
            "pageName" : 'Articlepage'  
        });
        
        action.setCallback(this,function(a){
            var state =  a.getState();
            if(state="SUCCESS"){
                var result = a.getReturnValue();
                component.set("v.backGroundImageURLs",result);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    /*
    * Function to fetch articles based on selected category
    */
    settingMainCategory: function(component, event) {
        
        var message = event.getParam("selectedMainCategory");
        component.set("v.articleCategoeryType", message);
        component.set("v.categoryGroupName", message);
        this.setArticlesCategories(component,  component.get("v.mainCategory"));
        this.createZincCode(component);
        this.getArticleCount(component, event,'');
        this.getArticlesData(component, event, '', false, false);
        
    },
    
    /*
    * Function to get the article id from URL
    */
    getUrlQueryPram : function (key) {
        var query = location.search.substr(1);
        var value = '';
        query.split("&").forEach(function(part) {
            var item = part.split("=");
            if(item[0] == key){
                value = decodeURIComponent(item[1]);
            }
        });
        return value;
    },
    
     
    /*
    * Function set page diaplay based on url params
    */
    setIntialLoad: function(component){
        var idParam = this.getUrlQueryPram('id');
        var articleCategoryParam = this.getUrlQueryPram('articleCategory');
        //alert(articleCategoryParam);
        component.set("v.articleId", idParam);
        if(idParam == ''){
            component.set("v.firstload", true);
        }else {
            component.set("v.showListPage", false);
            $A.util.removeClass(component.find("showMobile"), "mobile-wrapper");

            return false;
        }
        return true;
    },
    
    /*
    * Function reset page diaplay
    */
    resetIntialLoad: function(component){
        component.set("v.articleId", '');
    },
    
    /*
    * Function reset pagination
    */
    resetPagination: function(component){
         component.set("v.pageNumber",1);
         component.set("v.pageCurrentNumber",1);
    },
   
    /*
    * Function set scroll view
    */
    scrolPageToView: function(){
        var elmnt = document.getElementById("known-content");
	   	elmnt.scrollIntoView();
    },
    
    /*
    * Function to show page loader
    */
    showCommunitySpinner: function(component){       
        $A.util.removeClass(component.find("siteSpinner"), "hideEl");        
	},
    
    /*
    * Function to hide page loader
    */
    hideCommunitySpinner: function(component){
        $A.util.addClass(component.find("siteSpinner"), "hideEl");
    },
    
    /*
    * Function to change the mobile category button view
    */
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
    
    /*
    * Function to create zinc componet in UI
    */
    createZincCode : function(component){
        var showListPage = component.get("v.showListPage");
        if(showListPage){
            var attr = { pageName : 'Knowledge_'+component.get("v.mainCategoryName") };
            this.createComponent(component, 'c:AGN_SPARK_ZincCode', attr, 'zincCode');
        }
    },
    
    /*
    * Common function to create lightning component in UI
    */
    createComponent : function(component, cmbName, attributes, targetCmp){
        $A.createComponent(
            cmbName,
            attributes,
            function(newCmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = [];
                    body.push(newCmp);
                    component.find(targetCmp).set("v.body", body);
                }else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
    
    /*
    * Function to change the mobile hot topic button view
    */
    toggleMobileButtonHotTopic : function (component){
        if($A.util.hasClass(component.find("hotTopicBtnIcon"), "plus")){
            $A.util.removeClass(component.find("hotTopicBtnIcon"), "glyphicon-plus plus");
            $A.util.addClass(component.find("hotTopicBtnIcon"), "glyphicon-minus minus");
        }else{
            $A.util.removeClass(component.find("hotTopicBtnIcon"), "glyphicon-minus minus");
            $A.util.addClass(component.find("hotTopicBtnIcon"), "glyphicon-plus plus");
            
        }
        $A.util.toggleClass(component.find("hotTopicOptions"), "showVmenu");
    },
})