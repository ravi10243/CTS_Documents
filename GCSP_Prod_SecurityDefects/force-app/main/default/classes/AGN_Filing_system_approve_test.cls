@isTest
public class AGN_Filing_system_approve_test {
      public static testmethod void AGN_Filing_system_approve_test()
    {
        Test.Starttest();
        
            Asset_Register_AGN__c a= new Asset_Register_AGN__c ();
            a.Name='Veeva CRM';
            a.Asset_Status_AGN__c ='Approved';
            a.Business_Owner_GDPR_AGN__c=UserInfo.getUserId();
            
            a.Application_Status_AGN__c='Active';
            a.Effective_Date_Application_Status_AGN__c=NULL;
            a.RecordTypeId='0121p00000079JtAAI';
            a.Is_Active_AGN__c=false;
            Insert a;
        
            a.IsApproved_AGN__c=True;
        
            Update a;
         System.assertequals(False,a.Validated_Filing_System_AGN__c);
       
        Test.StopTest();  
        
    }

}