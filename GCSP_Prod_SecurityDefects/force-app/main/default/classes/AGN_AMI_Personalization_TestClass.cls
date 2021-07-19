@isTest
public class AGN_AMI_Personalization_TestClass 
{
	public static User dataCreation()
    {
        User u;
        Account acc;
        AMI_SPecality_AGN__c spcl;
        
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (AdminUser) {
            //counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'GB', Alpha_2_Code_vod__c = 'GB', Name = 'GB', CurrencyIsoCode = 'USD');
            //insert counVod;
            counVod = [Select Id from Country_vod__c where Alpha_2_Code_vod__c = 'GB' limit 1];
            spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id);
            insert spcl;
            
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c = counVod.Id, RecordTypeId = recordId);
            insert acc;
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_GB', 
                         localesidkey='en_GB', profileid = profileId, 
                         timezonesidkey='Europe/London', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert u;
            
            
            
        }
        
        return u;
    }
    
    @isTest(SeeAllData=true)
    public static void testHomeController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
           	AGN_AMI_Personalization_Controller APC = new AGN_AMI_Personalization_Controller(); 
            PageReference homePageSkipped1 = APC.goToHome();
            APC.resultString = '';
            List<AMI_Personalization_Answers_AGN__c> ansList = [Select Id from AMI_Personalization_Answers_AGN__c];
            for(AMI_Personalization_Answers_AGN__c ans : ansList)
            {
                APC.resultString = APC.resultString + ans.Id + ';';
            }
            PageReference homePageProcessed1 = APC.processOption();
            //System.assertEquals(new PageReference(System.Label.AGN_AMI_Home_Page),homePageProcessed);
            PageReference homePageSkipped2 = APC.goToHome();
            //System.assertEquals(new PageReference(System.Label.AGN_AMI_Home_Page),homePageSkipped);
            AGN_AMI_Personalization_Controller APC2 = new AGN_AMI_Personalization_Controller(); 
            APC2.resultString = ansList[0].Id + ';' + ansList[1].Id;
            PageReference homePageProcessed2 = APC2.processOption();
            APC2.resultString = ';';
            PageReference homePageProcessed3 = APC2.processOption();
        }   
        Test.stopTest();
    }
}