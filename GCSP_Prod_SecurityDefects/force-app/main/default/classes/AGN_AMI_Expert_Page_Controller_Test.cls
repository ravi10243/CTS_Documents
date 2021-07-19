@isTest
public class AGN_AMI_Expert_Page_Controller_Test {
   
    public static User dataCreation()
    {
        User User;
        Account acc; 
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];        
        System.runAs (AdminUser) {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'UK', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId);
            insert acc;
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            User = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_GB', 
                         localesidkey='en_GB', profileid = profileId, 
                         timezonesidkey='Europe/London', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert User;
            
        }
        
        return User;
    }
    
    @isTest
    public static void testExpertController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            
         
            Test.setCurrentPageReference(new PageReference(System.Label.AGN_AMI_Expert_Page));  
            
            AGN_AMI_Expert_Page_Controller expertController = new AGN_AMI_Expert_Page_Controller(); 
            
            System.assertNotEquals(null, expertController);
        }
        Test.stopTest();
    }
}