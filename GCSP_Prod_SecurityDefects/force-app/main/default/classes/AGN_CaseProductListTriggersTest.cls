@isTest private without sharing class AGN_CaseProductListTriggersTest {

    @isTest private static void searchManagersTest()
    
    {
    
           /*create test data for District and National manager in Case */
        
       Profile pr = [SELECT Id FROM Profile WHERE Name='Standard User']; 
       
       list<User> luser =new List<User>();
       
      
       
       for(integer i=0 ;i <2 ;i++)
       
       {
            User dm =new User();   
                        
            dm.Alias = i+'st';
            dm.Email=i+'standarduser@testorg.com';
            dm.EmailEncodingKey=i+'UTF-8';
            dm.LastName=i+'Testing';
            dm.LanguageLocaleKey='en_US';
            dm.LocaleSidKey='en_US';
            dm.ProfileId = pr.Id;
            dm.TimeZoneSidKey='America/Los_Angeles';
            dm.UserName=i+'@testallargen.com';
            dm.EmailEncodingKey ='ISO-8859-1';
            
            luser.add(dm);
           
       
       
       }
       
       insert luser;
       luser[0].managerid =luser[1].id;
       
       update luser;
       User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = pr.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testallagen.com');
       
       
       u.managerId =luser[0].id;
              
       insert u;
       
       
        /* Create test data for product catalog */
      User adminU = [Select id, name, email from User where id=: UserInfo.getUserId()];
      System.RunAs (adminU )  {
      List<User> luser1 = [ select id from user];
      system.debug('*********'+luser1); 
        Product_vod__c p = new Product_vod__c ( name ='test product' ,Product_Type_vod__c='Order' ,Country_Code__c = 'BR');
        
        insert p;
        
        /*create test data for SAP product List */
        List<SAP_Product_List_AGN__c> splist =new List<SAP_Product_List_AGN__c>();
       
        SAP_Product_List_AGN__c spd = new SAP_Product_List_AGN__c (name = 'test SAP' , Product_AGN__c=p.id ,Active_AGN__c =true,Approval_Level_Required_AGN__c= 'National Sales Manager' );
        SAP_Product_List_AGN__c spn = new SAP_Product_List_AGN__c (name = 'test SAP' , Product_AGN__c=p.id ,Active_AGN__c =true,Approval_Level_Required_AGN__c= 'District Manager' );
        
        splist.add(spd);
        splist.add(spn);
        
        insert splist;
        

        
        
        /* create test case data */
        
     
            Case c =new Case ();
            c.recordtypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Request - Sales Order').getRecordTypeId();
            c.reason ='Campaign';
            c.type ='Sale';
            c.Service_AGN__c='Order';
            c.Sales_Rep_Requester_AGN__c = u.id;
        
            insert c;
      
        
         /*create test data for case product list */
        List<Case_Product_List_AGN__c> listcpl =new List<Case_Product_List_AGN__c>();
             
        
        
      for(integer i=0 ;i<10;i++)
       
       { 
        Case_Product_List_AGN__c cpn = new Case_Product_List_AGN__c (SAP_Product_List_AGN__c =spn.id, Product_AGN__c=p.id, CurrencyIsoCode='USD',Case_AGN__c = c.id );
        listcpl.add(cpn);
        
        
       } 
       
              
            Case c1 =new Case ();
            c1.recordtypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Request - Sales Order').getRecordTypeId();
            c1.reason ='Campaign';
            c1.type ='Sale';
            c1.Service_AGN__c='Order';
            c1.Sales_Rep_Requester_AGN__c = u.id;
        
            insert c1;
          
       
        for(integer i=10 ;i<20 ;i++)
       
       { 
        Case_Product_List_AGN__c cpd = new Case_Product_List_AGN__c (SAP_Product_List_AGN__c =spd.id, Product_AGN__c=p.id, CurrencyIsoCode='USD',Case_AGN__c = c1.id );
        listcpl.add(cpd);
        
       }
        
     
      

        Test.startTest();
        insert listcpl;
       
        Test.stopTest();
      
        set<ID> cplID  = new set<ID>();
        
        for(Case_Product_List_AGN__c  cp : listcpl)
        
        {
            cplID.add(cp.Case_AGN__c);
        }
        
              
        List<Case> lcase = [select Approver_AGN__c,National_Manager_AGN__c,District_Manager_AGN__c from Case where id in :cplID];
        system.debug('Case list::'  + lcase );
        
      
         
          system.assertEquals(lcase[0].Approver_AGN__c,'DM');
          system.assertEquals(lcase[0].District_Manager_AGN__c,u.ManagerId);
          system.assertEquals(lcase[0].National_Manager_AGN__c,u.Manager.ManagerId);
          
          system.assertEquals(lcase[1].Approver_AGN__c,'NM');
          system.assertEquals(lcase[1].District_Manager_AGN__c,u.ManagerId);
          system.assertEquals(lcase[1].National_Manager_AGN__c,u.Manager.ManagerId);
    
        
        
    }
    
    }

}