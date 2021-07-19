({	
    doInit : function(component, event, helper) {
        var InitialselectedCatogry = '' ; 
        var catagoryValue= component.get("v.selectedCatagory");
        if(catagoryValue!= null){
            console.log('childAttr  from parent',catagoryValue);   
            helper.resetPagination(component);        
            helper.getAllArticles(component, event, catagoryValue);
        }
        
    },
    
    getClick : function(component, event, helper) { 
        if(!confirm($A.get("$Label.c.AGN_SPARK_Leave_Allergan_Site"))){
            event.preventDefault();
       		event.stopPropagation();
            return;
        }
       helper.logViewStat(component, event);
    },
    
    onChildAttributeChange : function (component, event, helper) {

        var InitialselectedCatogry = event.getParam("value");
        helper.resetPagination(component);        
        helper.getAllArticles(component, event, InitialselectedCatogry);
    },
    loadMore: function(component, event, helper) {       
        
        component.set("v.device",'Mob');
        var pageNo = component.get("v.pageCurrentNumber")+1; 
        var totalPages = component.get("v.totalPages");
        if(pageNo <= totalPages ){
            component.set("v.pageCurrentNumber",pageNo); 
            var selectedCatogry = component.get("v.selectedCatagory");
            helper.getAllArticles(component, event, selectedCatogry);  
            $A.util.addClass(component.find("load_less"), "showVmenu");
        }
        if(totalPages <= pageNo ){
            $A.util.addClass(component.find("load_more"), "hide");
        } 
        
    },
    loadLess: function(component, event, helper) {  
        helper.showCommunitySpinner(component);
        var pageNo = component.get("v.pageCurrentNumber");
        var items = component.get("v.trainingProvidersArticles");
        var limit =  component.get("v.articleEndNumber");

        if(items.length > 0){
            items.splice(0, limit) ;
            component.set("v.pageCurrentNumber", pageNo-1);
            component.set("v.trainingProvidersArticles", items);
            $A.util.removeClass(component.find("load_more"), "hide");
            $A.util.removeClass(component.find("load_less"), "showVmenu");
        }
       
        helper.hideCommunitySpinner(component);
        //helper.scrollToArticleList();
    },
    getArticlesBySelectedGp: function(component, event, helper) {
        
        var selectedCatogry = event.target;
        
        component.set("v.selectedCatagory",selectedCatogry.id);
        helper.resetPagination(component);
        
        helper.getAllArticles(component, event, selectedCatogry.id);
        //helper.toggleBtnSelection(component, event, helper,selectedCatogry);
        
    },
    
    getArticlesBySelectedGpMobile: function(component, event, helper) {
        
        var selectedCatogry = event.target;
        
        component.set("v.selectedCatagory",selectedCatogry.id);
        //helper.getArticleCount(component, event);        
        helper.getAllArticles(component, event, helper,selectedCatogry.id);
        helper.toggleMobileButtonSelecters(component);
    },
    
    pageNationBack: function(component, event, helper){
        var pageNumber = component.get("v.pageNumber");
        var pageCurrentNumber = component.get("v.pageCurrentNumber");
        
        if(pageCurrentNumber == pageNumber)
        {	component.set("v.pageNumber",pageNumber-1);
         component.set("v.pageCurrentNumber",pageCurrentNumber-1);
        }else{
            component.set("v.pageCurrentNumber",pageCurrentNumber-1);
        }
        var selectedCatogry = component.get("v.selectedCatagory");
        
        helper.getAllArticles(component, event, selectedCatogry); 
        helper.scrollToArticleList(component);
    },
    pageNationFwrd: function(component, event, helper){
        var pageNumber = component.get("v.pageNumber");
        var pageCurrentNumber = component.get("v.pageCurrentNumber");
        if(pageCurrentNumber == pageNumber+4)
        {	component.set("v.pageNumber",pageNumber+1);
         component.set("v.pageCurrentNumber",pageCurrentNumber+1);
        }else{
            component.set("v.pageCurrentNumber",pageCurrentNumber+1);
        }
        var selectedCatogry = component.get("v.selectedCatagory");
        helper.getAllArticles(component, event, selectedCatogry);
        helper.scrollToArticleList(component);
    },
    pageValue: function(component, event, helper){
        var pageNumber = parseInt(event.currentTarget.getAttribute('data-page'));
        var pageId =event.currentTarget.getAttribute('data-id');
        if(pageNumber != component.get("v.pageCurrentNumber")){
            component.set("v.pageCurrentNumber",pageNumber); 
            var selectedCatogry = component.get("v.selectedCatagory");
            helper.getAllArticles(component, event, selectedCatogry);
            helper.scrollToArticleList(component);
        }
        
    }
})