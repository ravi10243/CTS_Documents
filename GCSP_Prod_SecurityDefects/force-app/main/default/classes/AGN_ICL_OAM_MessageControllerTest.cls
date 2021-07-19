@isTest(SeeAllData=true)
public class AGN_ICL_OAM_MessageControllerTest 
{
    
    static testmethod void method1()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'abc', Email='abc.xyz@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='abc', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='abc.xyz@testorg.com');
            insert u;
        
        Account acc1 = new Account();
        acc1.LastName='AccountRecord2';
        acc1.Country_Code__c='ES';
        acc1.OwnerId = u.Id;
        insert acc1;
        
        Locator_Listing_AGN__c l1 = new Locator_Listing_AGN__c();
        l1.Name='Locator Listing 1';
        l1.Clinic_Admin_AGN__c=acc1.id;
        l1.Account_AGN__c=acc1.id;
        l1.Active_AGN__c = true;
        l1.OwnerId = u.Id;
        insert l1;
        system.debug('Locator_Listing_AGN__c::'+l1);
        
        u.Locator_Listing_Id_AGN__c =l1.Id;
        Update u;
        
            system.runAs(u)
            {
               Boolean b1=AGN_ICL_OAM_MessageController.isLocatorListingActive();
            }
                
      }
    static testmethod void method2()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'abc', Email='abc.xyz@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='abc', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='abc.xyz@testorg.com');
            insert u;
        
        Account acc1 = new Account();
        acc1.LastName='AccountRecord2';
        acc1.Country_Code__c='ES';
        acc1.OwnerId = u.Id;
        insert acc1;
        
        Locator_Listing_AGN__c l1 = new Locator_Listing_AGN__c();
        l1.Name='Locator Listing 1';
        l1.Clinic_Admin_AGN__c=acc1.id;
        l1.Account_AGN__c=acc1.id;
        l1.Active_AGN__c = true;
        l1.Approval_Status__c = 'Rejected';
        l1.Second_Level_Clinic_Approver_AGN__c=u.Id;
        l1.OwnerId = u.Id;
        insert l1;
        system.debug('Locator_Listing_AGN__c::'+l1);
        
        u.Locator_Listing_Id_AGN__c =l1.Id;
        Update u;
        
            system.runAs(u)
            {
               Boolean b2=AGN_ICL_OAM_MessageController.isPendingforApprovalOrRejected();
            }
                
      }
     static testmethod void method3()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'abc', Email='abc.xyz@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='abc', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='abc.xyz@testorg.com');
            insert u;
        
        Account acc1 = new Account();
        acc1.LastName='AccountRecord2';
        acc1.Country_Code__c='ES';
        acc1.OwnerId = u.Id;
        insert acc1;
        
        Locator_Listing_AGN__c l1 = new Locator_Listing_AGN__c();
        l1.Name='Locator Listing 1';
        l1.Clinic_Admin_AGN__c=acc1.id;
        l1.Account_AGN__c=acc1.id;
        l1.Active_AGN__c = true;
        l1.Approval_Status__c = 'Finally Rejected';
        l1.OwnerId = u.Id;
        insert l1;
        system.debug('Locator_Listing_AGN__c::'+l1);
        
        u.Locator_Listing_Id_AGN__c =l1.Id;
        Update u;
        
            system.runAs(u)
            {
               Boolean b3=AGN_ICL_OAM_MessageController.isPendingforApprovalOrRejected();
            }
                
      }
     static testmethod void method4()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'abc', Email='abc.xyz@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='abc', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='abc.xyz@testorg.com');
            insert u;
        
        Account acc1 = new Account();
        acc1.LastName='AccountRecord2';
        acc1.Country_Code__c='ES';
        acc1.OwnerId = u.Id;
        insert acc1;
        
        Locator_Listing_AGN__c l1 = new Locator_Listing_AGN__c();
        l1.Name='Locator Listing 1';
        l1.Clinic_Admin_AGN__c=acc1.id;
        l1.Account_AGN__c=acc1.id;
        l1.Active_AGN__c = false;
        l1.Approval_Status__c = 'Rejected';
        l1.Second_Level_Clinic_Approver_AGN__c=null;
        l1.OwnerId = u.Id;
        insert l1;
        system.debug('Locator_Listing_AGN__c::'+l1);
        
        u.Locator_Listing_Id_AGN__c =l1.Id;
        Update u;
        
            system.runAs(u)
            {
               Boolean b3=AGN_ICL_OAM_MessageController.isPendingforApprovalOrRejected();
            }
       } 
}