@isTest
public class AGN_UpdatePractitionerlisting_test {

      static testMethod void test(){
          Test.Starttest();
       
        Account acc=new Account();
        acc.LastName='test';
          insert acc;
        
       Practitioner_Listing_AGN__c pl=new Practitioner_Listing_AGN__c();
        pl.Practitioner_AGN__c=acc.Id;
        insert pl;
        
       AGN_UpdatePractitionerlisting.updaterecord(New Account[]{acc});
          Test.StopTest();      
        
    }

}