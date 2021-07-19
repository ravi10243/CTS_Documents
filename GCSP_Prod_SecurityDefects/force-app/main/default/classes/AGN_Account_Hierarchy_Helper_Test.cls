/****************************************************************************************************************
@ Class:          AGN_Account_Hierarchy_Helper_Test 
@ Version:        1
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        Test Class for AGN_Account_Hierarchy_Helper
-----------------------------------------------------------------------------------------------------------------
@ Change history: 25.03.2021 / Ayush Basak / Created the class.
****************************************************************************************************************/
@isTest
public class AGN_Account_Hierarchy_Helper_Test {
    
	private static List<Id> targetTree;
    private static String targetId;
    private static String parentId;
    private static List<Id> grandparentTree;
    private static String grandparentId;
    private static List<Id> grandchildTree;
    private static String grandchildId;
    private static String soldToId;
    private static String shipToId;
    
    // Data setup for Account Hierarchy
    // Data inserted in Account and SAP Attributes.
    private static void hierarchySetup() {
 		Account grandparent = new Account(Name = 'Grand Parent');
        insert grandparent;
        Account parent = new Account(Name = 'Parent', Primary_Parent_vod__c = grandparent.Id);
        insert parent;
        Account target = new Account(Name = 'Parent', Primary_Parent_vod__c = Parent.Id);
        insert target;
        Account child = new Account(Name = 'Parent', Primary_Parent_vod__c = target.Id);
        insert child;
        Account grandchild = new Account(Name = 'Parent', Primary_Parent_vod__c = child.Id);
        insert grandchild;
        targetTree = new List<Id>{parent.Id, grandparent.Id};
        targetId = target.Id;
        parentId = parent.Id;
        grandparentTree = new List<Id>{};
        grandparentId = grandparent.Id;
        grandchildTree = new List<Id>{child.Id, target.Id, parent.Id, grandparent.Id};
        grandchildId = grandchild.Id;
        
        Customer_Detail_AGN__c soldTo = new Customer_Detail_AGN__c(Name = 'Sold To', 
                                                                   External_ID_AGN__c = '1', 
                                                                   Parent_Account_AGN__c = grandparent.Id, 
                                                                   SAP_Sold_To_AGN__c = true);
        insert soldTo;
        soldToId = soldTo.Id;
        Customer_Detail_AGN__c shipTo = new Customer_Detail_AGN__c(Name = 'Ship To', 
                                                                   External_ID_AGN__c = '2', 
                                                                   Parent_Account_AGN__c = parent.Id, 
                                                                   Parent_Sold_To_AGN__c = soldTo.Id, 
                                                                   SAP_Ship_To_AGN__c = true);
        insert shipTo;
        shipToId = shipTo.Id;
	}
    
    
    // Executing onload method for AccountHierarchy for a 5 level hierarchy
    // at level 1, 3 and 5
    @isTest 
    private static void testHeirarchyLoadLeve1() {
        hierarchySetup();
        Test.startTest();
        List<Id> actualGrandchildTree = AGN_Account_Hierarchy_Helper.getAccountTree(grandchildId); 
        System.assertEquals(grandchildTree, actualGrandchildTree);
        Test.stopTest();
   	}
    @isTest 
    private static void testHeirarchyLoadLeve3() {
        hierarchySetup();
        Test.startTest();
        List<Id> actualtargetTree = AGN_Account_Hierarchy_Helper.getAccountTree(targetId);
        system.assertEquals(targetTree, actualtargetTree);
        Test.stopTest();
   	}
    @isTest 
    private static void testHeirarchyLoadLeve5() {        
        hierarchySetup();
        Test.startTest();
        List<Id> actualGrandparentTree = AGN_Account_Hierarchy_Helper.getAccountTree(grandparentId);
        System.assertEquals(grandparentTree, actualGrandparentTree);
        Test.stopTest();
   	}
    
    // Executing metadata fetch 
    @isTest 
    private static void testTableConfigLoad() {
        Test.startTest();
        List<Account_Hierarchy_Configuration_AGN__mdt> expectedList = [SELECT Id 
                                                                       FROM Account_Hierarchy_Configuration_AGN__mdt 
                                                                       WHERE Active_AGN__c = true];
        List<Account_Hierarchy_Configuration_AGN__mdt> actualConfigList = AGN_Account_Hierarchy_Helper.getTableConfigs();
        System.assertEquals(expectedList.size(), actualConfigList.size());
        Test.stopTest();
   	}
    
    
    // Executing node fetch and load
    @isTest 
    private static void testNodeLoad() {
        hierarchySetup();
        Test.startTest();
        String hierarchyString = targetTree.toString();
        AGN_Account_Hierarchy_Helper.AccountHierarchyNode actualNode 
            = AGN_Account_Hierarchy_Helper.getNodeDetail(grandparentId, hierarchyString);
        System.assertEquals(grandparentId, actualNode.account.Id);
        System.assertEquals(new List<Id>{parentId}, actualNode.children);
        Test.stopTest();
   	}
    
    // Executing datatable information fetch
    @isTest 
    private static void testAccountDatatableLoad() {
        hierarchySetup();
        Test.startTest();
        List<sObject> actualDatalist = AGN_Account_Hierarchy_Helper.getDataList(grandparentId, 'Account');
        System.assertEquals(1, actualDatalist.size());
       	System.assertEquals(grandparentId, actualDatalist[0].get('Id'));
        Test.stopTest();
   	}
    @isTest 
    private static void testCustomerDetailDatatableLoad() {
        hierarchySetup();
        Test.startTest();
        List<sObject> actualDatalist = AGN_Account_Hierarchy_Helper.getDataList(grandparentId, 'Customer_Detail_AGN__c');
        System.assertEquals(2, actualDatalist.size());
        System.assertEquals(soldToId, actualDatalist[0].get('Id'));
        System.assertEquals(shipToId, actualDatalist[1].get('Id'));
        Test.stopTest();
   	}
}