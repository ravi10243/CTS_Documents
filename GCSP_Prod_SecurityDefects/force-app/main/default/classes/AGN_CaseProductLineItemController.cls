/*
Type Name: AGN_CaseProductLineItemController
Reason: Controller class for Case product line item VF component.
28-07-2016 - SG - Initial Version
Change Log:
Release 10 | Requirement 1242 (For cases Donation and Replacement more products should be available):
Modified By : Suman Banerjee 
Change Description: Added condition check to filter out the request which are comming from AGN_CaseSampleOrder page.
Change Location: serach by '@R10:1242'
*/
public with sharing class AGN_CaseProductLineItemController {    
    
    public string searchString {get;set;}
    public list<AGN_ProductWrapper> productList {get;set;}
    public list<Case_Product_List_AGN__c> orderLineItems {get;set;}    
    private set<Id> uniqueProducts {get;set;}
    public integer deleteRowNumber {get;set;}
    AGN_ProductWrapper.SetConWrapper obj;
    
    public boolean showSearch {get;set;}
    public boolean showPriceList {get;set;}    
    public string orderOrSample {get;set;}
    
    public AGN_CaseProductLineItemController(){
        
        uniqueProducts = new set<Id>();
        orderLineItems = new list<Case_Product_List_AGN__c>();
        productList = new list<AGN_ProductWrapper>();
        showSearch = false;     
    }
    
    public PageReference addProducts(){
        showSearch = true;
        obj = new AGN_ProductWrapper.SetConWrapper(productList);
        return null;
    }        
        
    public void searchProducts(){        
        
        list<AGN_ProductWrapper> prodList = new list<AGN_ProductWrapper>();
        
        //@R10:1242(for details see change log above)
             
        set<String> excludedProductType = new Set<String>{'Detail','Detail Group'};  
        string productQuery;
        if (orderOrSample== 'all')         
            productQuery = 'select Id, Name, Description_vod__c, Business_Unit_AGN__c from Product_vod__c where Name like: search and Product_Type_vod__c NOT IN :excludedProductType and  Parent_Product_vod__c IN : productIds';
        else 
            productQuery = 'select Id, Name, Description_vod__c, Business_Unit_AGN__c from Product_vod__c where Name like: search and Product_Type_vod__c =: orderOrSample and Parent_Product_vod__c IN : productIds';
        
        set<Id> productIds = new set<Id>();        
        string search = '%' + searchString + '%';        
        //get detail group
        for (My_Setup_Products_vod__c setUp : [select Product_vod__c from My_Setup_Products_vod__c where OwnerId =: UserInfo.getUserId()])
            productIds.add(setUp.Product_vod__c);
        //get detail    
        for (Product_Group_vod__c grp : [select Product_vod__c from Product_Group_vod__c where Product_Catalog_vod__c IN : productIds])
            productIds.add(grp.Product_vod__c);                 
        //get product
        for (Product_vod__c p : DataBase.query(productQuery)){
            if (!uniqueProducts.contains(p.Id)){
                AGN_ProductWrapper pw = new AGN_ProductWrapper(p);
                prodList.add(pw);
            }                
        }
        
        obj = new AGN_ProductWrapper.SetConWrapper(prodList);
        next();                           
    }
    
    public Boolean hasNext {
        get {
            return obj.hasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return obj.hasPrevious();
        }
        set;
    }
    
    public void next() {
        productList = obj.next();
    }
    
    public void previous() {
        productList = obj.previous();
    }
    
    public void addSelectedProducts(){
        
        for(AGN_ProductWrapper pw : obj.innerList){
            if (pw.selected){
                uniqueProducts.add(pw.product.Id);
                orderLineItems.add(new Case_Product_List_AGN__c(Product_AGN__c = pw.product.Id));
            }
        }
        
        showSearch = false;
        productList = new list<AGN_ProductWrapper>();
                
    }
    
    public void deleteRow(){
        uniqueProducts.remove(orderLineItems[deleteRowNumber-1].Product_AGN__c);        
        orderLineItems.remove(deleteRowNumber-1);
    }

}