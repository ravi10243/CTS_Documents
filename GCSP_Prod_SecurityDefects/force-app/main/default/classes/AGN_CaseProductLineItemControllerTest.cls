/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AGN_CaseProductLineItemControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Product_vod__c pg = new Product_vod__c ( name ='test product detail grp' ,Product_Type_vod__c='Detail Group' ,Country_Code__c = 'BR');        
        insert pg;
        
        Product_vod__c pd = new Product_vod__c ( name ='test product detail' ,Product_Type_vod__c='Detail' ,Country_Code__c = 'BR');        
        insert pd;
        
        list<Product_vod__c> prods = new list<Product_vod__c>();
        
        for (integer i=0;i<10;i++){
        	Product_vod__c po = new Product_vod__c ( name ='test product' + i ,Product_Type_vod__c='Order', Parent_Product_vod__c = pd.Id, Country_Code__c = 'BR');
        	prods.add(po);        	
        }        
        insert prods;
        
        My_Setup_Products_vod__c setup = new My_Setup_Products_vod__c(Product_vod__c = pg.Id, OwnerId = UserInfo.getUserId());
        insert setup;
        
        Product_Group_vod__c grp = new Product_Group_vod__c(Product_vod__c = pd.Id, Product_Catalog_vod__c = pg.Id);
        insert grp;
        
        test.startTest();
        AGN_CaseProductLineItemController ctrl = new AGN_CaseProductLineItemController();
        ctrl.orderOrSample = 'Order';
        ctrl.addProducts();
        ctrl.searchString = 'test';
        ctrl.searchProducts();
        ctrl.next();
        ctrl.previous();
        ctrl.productList[1].selected = true;
        ctrl.addSelectedProducts();
        
        system.assertEquals(ctrl.orderLineItems.size(), 1);
        
        
    }
}