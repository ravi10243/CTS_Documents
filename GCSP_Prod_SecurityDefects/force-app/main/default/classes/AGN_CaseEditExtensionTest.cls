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
private class AGN_CaseEditExtensionTest {

    static testMethod void myUnitTest() {
    	
    	Account a = new Account(LastName = 'test', FirstName = 'doctor');
    	a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();    	
    	insert a;
    	
    	Product_vod__c p = new Product_vod__c ( name ='test product' ,Product_Type_vod__c='Order' ,Country_Code__c = 'BR');        
        insert p;
        
        SAP_Product_List_AGN__c spd = new SAP_Product_List_AGN__c (name = 'test SAP' , Product_AGN__c=p.id ,Active_AGN__c =true,Approval_Level_Required_AGN__c= 'National Sales Manager' );
        insert spd;
        
        Case c = new Case();
        insert c;
    	
    	string recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Request - Sales Order').getRecordTypeId();
    	test.startTest();
        
        PageReference pageRef = Page.AGN_CaseSalesOrder;
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('def_account_id', a.Id);
        System.currentPageReference().getParameters().put('caseService', 'Order');
        System.currentPageReference().getParameters().put('caseStaticCategory', 'Sale');
        System.currentPageReference().getParameters().put('caseReason', 'Campaign');
        System.currentPageReference().getParameters().put('recordType', recordTypeId);
        System.currentPageReference().getParameters().put('def_parent_id', c.Id);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new Case());
        AGN_CaseEditExtension ctrl = new AGN_CaseEditExtension(new ApexPages.Standardcontroller(new Case()));
        
        ctrl.productLineItems.add(new Case_Product_List_AGN__c(SAP_Product_List_AGN__c =spd.id, Product_AGN__c=p.id));
        AGN_CaseCommentWrapper cm = new AGN_CaseCommentWrapper();
        cm.comment.CommentBody = 'test';
        cm.type = 'First Contract';        
        ctrl.caseComments.add(cm);
        ctrl.internalComments = 'test comments';
        
        ctrl.saveRecord();
        
        system.assertEquals([select count() from Case where ParentId =: c.Id], 1);
        
        
    }
}