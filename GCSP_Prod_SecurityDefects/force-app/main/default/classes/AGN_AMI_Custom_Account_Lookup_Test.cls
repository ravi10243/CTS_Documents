@isTest
public class AGN_AMI_Custom_Account_Lookup_Test 
{
    Static String accId;
	public static User dataCreation()
    {
        User u;
        Account acc;
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (AdminUser) 
        {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;
            
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(FirstName='Test', lastname = 'Account', AGN_AMI_ENABLED__C=true, Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId);
            insert acc;
            system.debug(acc.Country_vod__c);
            accId = acc.Id;
            AMI_HCP_Profile_AGN__c hp = new AMI_HCP_Profile_AGN__c(Account_AGN__c=acc.Id,AMI_Education_AGN__c='1');
            insert hp;
            
            AMI_User_Settings_AGN__c AUS = new AMI_User_Settings_AGN__c(Name = 'GB', User_Locale__c='en_GB', 
                                                                        Username_Suffix__c='ami', User_Profile__c = 'AMI Customer Community', 
                                                                        User_Language__c = 'en_GB', User_Timezone__c = 'Europe/London');
            insert AUS;
                
            Id profileId = [Select Id from Profile where Name = 'AGN GCSP Profile' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                         localesidkey='en_GB', profileid = profileId, 
                         timezonesidkey='Europe/London', Country_code__c = 'GB', username='standarduser@allergan.example.com');
            Insert u;
        }
        return u;
    }
    @isTest
    public static void testAccountLookup()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {           
        	AGN_AMI_Custom_Account_Lookup_Controller CAL = new AGN_AMI_Custom_Account_Lookup_Controller();
            CAL.search();
            
            CAL.searchStringFirstName = 'Test';
            CAL.searchStringLastName = 'Account';
            CAL.searchStringEmail = 'test.account@example.com';
            CAL.searchStringMob = '1234567890';
            CAL.searchStringHospital = 'Generic Hospital';
            CAL.searchStringSpecialty = 'Doctor';
            CAL.search();
            
            CAL.Enable();
            CAL.accId = accId;
            CAL.Enable();
        }
        Test.stopTest();
    }
}