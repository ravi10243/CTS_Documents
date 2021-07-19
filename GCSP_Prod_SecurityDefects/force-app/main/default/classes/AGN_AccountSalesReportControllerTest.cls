/*********************************************************************** 
   
    * Created Date: 24 August 2016
    * Purpose: Created as a part of LATAM Phase 2
    * Test Class for AGN_AccountSalesReportController
    
************************************************************************/


@isTest(SeeAllData=false)
public with sharing class AGN_AccountSalesReportControllerTest {
    Public static Account objAccount;
    public static Product_vod__c obj2;
    
        static testMethod void testUpdateChartTable() {
            
            createData();
            test.StartTest();          
            ApexPages.currentPage().getParameters().put('ID', objAccount.Id);
        
            ApexPages.standardController controller=new ApexPages.standardController(objAccount);
            AGN_AccountSalesReportController obj = new AGN_AccountSalesReportController (controller);
            obj.UpdateChartTable();
            obj.SelectedBU='Eye Care';
            obj.ChangeBU();
            obj.SelectedTherapeuticArea='Therapeutic Area 1';
            obj.ChangeTherapeuticArea();
            obj.SelectedDetail=obj2.id;
            obj.ChangeProductDetail();
            obj.SelectedListSubType='Order1';
            obj.ChangeSubtype();
            test.StopTest();      
            
            System.assertnotEquals(obj, null);
        }

        static testMethod void testGraphBarColors() {
            
            createData();
            
            test.StartTest();           
                ApexPages.currentPage().getParameters().put('ID', objAccount.Id);
            
                ApexPages.standardController controller=new ApexPages.standardController(objAccount);
                AGN_AccountSalesReportController obj = new AGN_AccountSalesReportController (controller);
                String test1=obj.GraphBarColors;
                test1=obj.GraphBarLegends;
                test1=obj.GraphYAxisTitle;
                test1=obj.ProductLine;
                test1=obj.GraphLineFields;
                test1=obj.getShortMonth(1);
                test1=obj.getShortMonth(2);
                test1=obj.getShortMonth(3);
                test1=obj.getShortMonth(4);
                test1=obj.getShortMonth(5);
                test1=obj.getShortMonth(6);
                test1=obj.getShortMonth(7);
                test1=obj.getShortMonth(8);
                test1=obj.getShortMonth(9);
                test1=obj.getShortMonth(10);
                test1=obj.getShortMonth(11);
                test1=obj.getShortMonth(12);
                PageReference pg=obj.ChangeAccount();
                
                String[] a4=obj.GraphRollupFields;
                a4=obj.MonthNames;
                double a1=obj.GraphYAxisMaximum;
                
                integer a2=obj.GraphYAxisSteps;
                test1=obj.GraphBarFields;
                test1=obj.GraphLineFields;
                Boolean a3=obj.IsGenericAccount;
                a3=obj.IsGenericAccount;
                a3=obj.HasAccount;
                Account a6=obj.InputAccount;
                a3=obj.PrincipalAccRollup;
                a3=obj.PrincipalAccountOnly;
                test1=obj.PrincipalAccountName;
                
                obj.DataPresentation='1';
                
                test1=obj.FillersProductNameValue;
            
            test.StopTest();   
            
            System.assertnotEquals(obj, null);
        }


        static void createData() {
            
            objAccount=new Account();
            objAccount.Name='Test';
            
            insert objAccount ;
            
            List<User> lstUsr= [SELECT Country_Code__c FROM User WHERE Id = : UserInfo.getUserId()];
            
            Product_vod__c obj1=new Product_vod__c();
            obj1.Name='DG';
            obj1.Product_Type_vod__c='Detail Group';
            obj1.Therapeutic_Area_AGN__c='Therapeutic Area 1';
            obj1.Business_Unit_AGN__c='Eye Care';
            obj1.Country_Code__c=lstUsr[0].Country_Code__c ;
            insert obj1;
            
            obj2=new Product_vod__c();
            obj2.Name='DP';
            obj2.Product_Type_vod__c='Detail';
            obj2.Therapeutic_Area_AGN__c='Therapeutic Area 1';
            obj2.Business_Unit_AGN__c='Eye Care';
            obj2.Country_Code__c=lstUsr[0].Country_Code__c;
            insert obj2;
            
            Product_Group_vod__c obj3=new Product_Group_vod__c();
            obj3.Name='Test';
            obj3.Product_vod__c=obj2.id;
            obj3.Product_Catalog_vod__c=obj1.id;
            
            insert obj3;
            
            Product_vod__c obj4=new Product_vod__c();
            obj4.Name='Order1';
            obj4.Product_Type_vod__c='Order';
            obj4.Therapeutic_Area_AGN__c='Therapeutic Area 1';
            obj4.Business_Unit_AGN__c='Eye Care';
            obj4.Country_Code__c=lstUsr[0].Country_Code__c;
            obj4.Parent_Product_vod__c=obj2.id;
            
            insert obj4;
            
            Product_vod__c obj5=new Product_vod__c();
            obj5.Name='Sample1';
            obj5.Product_Type_vod__c='Sample';
            obj5.Therapeutic_Area_AGN__c='Therapeutic Area 1';
            obj5.Business_Unit_AGN__c='Eye Care';
            obj5.Country_Code__c=lstUsr[0].Country_Code__c;
            obj5.Parent_Product_vod__c=obj2.id;
            insert obj5;
            
            SAP_Invoice_AGN__c invoice=new SAP_Invoice_AGN__c();
            
            invoice.Invoice_Date_AGN__c=Date.Today();
            invoice.Invoice_Number_AGN__c='1';
            invoice.Sold_to_Account_AGN__c=objAccount.id;
            invoice.Country_Code_AGN__c=lstUsr[0].Country_Code__c;
            
            insert invoice;
            
            
            SAP_Customer_Order_AGN__c order=new SAP_Customer_Order_AGN__c ();
            
            order.SAP_Invoice_AGN__c =invoice.id;
            order.Account_AGN__c=objAccount.id;
            order.Material_AGN__c=obj5.id;
            order.REASON_DES_AGN__c='GRSALES';
            order.Country_Code_AGN__c=lstUsr[0].Country_Code__c;
            order.Net_Price_AGN__c=10;
            order.Quantity_AGN__c=10;
            
            insert order;
            
            
            
            SAP_Invoice_AGN__c invoice1=new SAP_Invoice_AGN__c();
            
            invoice1.Invoice_Date_AGN__c=Date.Today().addyears(-1);
            invoice1.Invoice_Number_AGN__c='1';
            invoice1.Sold_to_Account_AGN__c=objAccount.id;
            invoice1.Country_Code_AGN__c=lstUsr[0].Country_Code__c;
            
            insert invoice1;
            
            
            SAP_Customer_Order_AGN__c order1=new SAP_Customer_Order_AGN__c ();
            
            order1.SAP_Invoice_AGN__c =invoice1.id;
            order1.Account_AGN__c=objAccount.id;
            order1.Material_AGN__c=obj5.id;
            order1.REASON_DES_AGN__c='GRSALES';
            order1.Country_Code_AGN__c=lstUsr[0].Country_Code__c;
            order1.Net_Price_AGN__c=10;
            order1.Quantity_AGN__c=10;
            
            insert order1;
            
            
            
            SAP_Invoice_AGN__c invoice3=new SAP_Invoice_AGN__c();
            
            invoice3.Invoice_Date_AGN__c=Date.Today().addyears(21);
            invoice3.Invoice_Number_AGN__c='1';
            invoice3.Sold_to_Account_AGN__c=objAccount.id;
            invoice3.Country_Code_AGN__c=lstUsr[0].Country_Code__c;
            
            insert invoice3;
            
            
            SAP_Customer_Order_AGN__c order2=new SAP_Customer_Order_AGN__c ();
            
            order2.SAP_Invoice_AGN__c =invoice3.id;
            order2.Account_AGN__c=objAccount.id;
            order2.Material_AGN__c=obj5.id;
            order2.REASON_DES_AGN__c='GRSALES';
            order2.Country_Code_AGN__c=lstUsr[0].Country_Code__c;
            order2.Net_Price_AGN__c=10;
            order2.Quantity_AGN__c=10;
            
            insert order2;
        }

}