@isTest
public class AGNRolevalidate_test {
      public static testmethod void AGNRolevalidate_test()
    {
        Test.Starttest();
        
        Asset_Register_AGN__c a= new Asset_Register_AGN__c ();
            a.Name='Veeva CRM';
            a.Asset_Status_AGN__c ='Draft';
            a.Business_Owner_GDPR_AGN__c=UserInfo.getUserId();
            Insert a;
        
        Asset_Contact_AGN__c ac=new Asset_Contact_AGN__c();
            ac.Email_AGN__c='abc@xyz.com';
            Insert ac;
        
          List<Linked_Asset_Contact_AGN__c> listlac= new List<Linked_Asset_Contact_AGN__c>();
       
              
       Linked_Asset_Contact_AGN__c lac;
        
        lac= new Linked_Asset_Contact_AGN__c();                        
          lac.Filing_System_AGN__c=a.Id;
          lac.Contacts_AGN__c=ac.Id;
          lac.Role_AGN__c='Business Owner';
        Insert lac;
        
        lac= new Linked_Asset_Contact_AGN__c();                        
          lac.Filing_System_AGN__c=a.Id;
          lac.Contacts_AGN__c=ac.Id;
          lac.Role_AGN__c='IT Owner';
        Insert lac;
           
       
        
        Test.StopTest();      
    }

}