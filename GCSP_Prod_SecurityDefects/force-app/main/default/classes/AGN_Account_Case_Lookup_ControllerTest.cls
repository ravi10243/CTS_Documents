@isTest private without sharing class AGN_Account_Case_Lookup_ControllerTest {

    @isTest private static void searchTest()
    {
        PageReference pageRef = Page.AGN_Custom_lookup;
        Test.setCurrentPage(pageRef);
      
       
       /* Create test Business Account */
       List<Account> lbAcc =new List<Account>();
       for(integer i=0 ;i<10;i++)
       {
           Account busAcc = new Account(name = 'test bus Acc'+i );
           lbAcc.add(busAcc); 
        }  
        
        insert  lbAcc;
        
       
       /* Create Person Account */
        List<Account> lpAcc =new List<Account>();
        RecordType recordType = [ select Id, Name, DeveloperName from RecordType where SObjectType = 'Account' and IsPersonType = true and name='Professional_vod' limit 1 ];
       for(integer i=0 ;i<10 ;i++)
       {
           Account perAcc = new Account(lastname = 'test per Acc'+i ,RecordTypeId = recordType.id);
           lpAcc.add(perAcc);
           
       }   
       
       insert  lpAcc;
       
       /*Creating Relationship */
       List<Child_Account_vod__c> lstChild =new List<Child_Account_vod__c>();
      for(integer i=0;i<10;i++) 
      {
          
               Child_Account_vod__c chld =new Child_Account_vod__c();
               chld.Child_Account_vod__c = lpAcc[i].id;
               chld.Parent_Account_vod__c = lbAcc[i].id;
               lstChild.add(chld);
          
      }  
      
      insert   lstChild; 
       
      
            AGN_Account_Case_Lookup_Controller ca =new AGN_Account_Case_Lookup_Controller ();
            ca.searchPersonAccount = lstChild[0].Child_Account_vod__c;
            ca.searchBusinessAccount = lstChild[0].Parent_Account_vod__c;
            ca.pageName ='AGN_Custom_lookup'; 
            ca.searchString ='test';   
        
            ca.search();
            List<Account> lbAccount=ca.results;
            
            system.assertEquals(lstChild[0].Parent_Account_vod__c,lbAccount[0].id);
        
       
            AGN_Account_Case_Lookup_Controller ca2 =new AGN_Account_Case_Lookup_Controller ();
            ca2.searchPersonAccount = null;
            ca2.pageName ='AGN_Custom_lookup';  
            ca2.searchBusinessAccount =lstChild[0].Parent_Account_vod__c;
            ca2.searchString ='test'; 
            ca2.search();
            List<Account> lpAccount =ca2.results;
                
            system.assertEquals(lstChild[0].Child_Account_vod__c,lpAccount[0].id);     
            
            ca2.getFormTag();
            ca2.getTextBox();  
         
            
    
            
        
        
         
    }
    
    
 }