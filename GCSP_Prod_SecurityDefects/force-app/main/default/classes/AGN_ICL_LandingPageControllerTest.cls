@isTest(SeeAllData=true)
public class AGN_ICL_LandingPageControllerTest
{
    static testmethod void method1()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'abc', Email='abc.xyz@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='abc', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='abc.xyz@testorg.com',Country_Code__c='GB');
            insert u;
            
            AGN_ICL_LandingPageController obj = new AGN_ICL_LandingPageController();
            PageReference p1 = obj.forwardToCommunityPage();
    }
}