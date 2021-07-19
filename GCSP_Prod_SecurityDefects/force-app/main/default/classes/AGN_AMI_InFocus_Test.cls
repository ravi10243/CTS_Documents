@isTest
public class AGN_AMI_InFocus_Test 
{
    static AMI_InFocus_AGN__c inFocus1;
	public static User dataCreation()
    {
        User u;
        Account acc;
        AMI_SPecality_AGN__c spcl;
        
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (AdminUser) {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;
            
            spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id);
            insert spcl;
            
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId);
            insert acc;
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', Country_code__c = 'GB',
                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_GB', 
                         localesidkey='en_GB', profileid = profileId, 
                         timezonesidkey='Europe/London', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert u;
        }
        inFocus1 = new AMI_InFocus_AGN__c(Name_AGN__c = 'Test Video',Active_AGN__c = true, Country_AGN__c = counVod.Id);
        insert inFocus1;
        system.debug([Select Id, Name_AGN__c, Description_AGN__c, AMI_Image_URL_AGN__c, Video_URL_AGN__c 
                       from AMI_InFocus_AGN__c
                       where Country_AGN__r.Name = 'GB' and Active_AGN__c = true]);
        return u;
    }
    
    @isTest
    public static void testInFocus()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            AGN_AMI_InFocus_Controller controller = new AGN_AMI_InFocus_Controller();
            controller.clickedVideo = inFocus1.Id;
            controller.changeVideo();
        }
        Test.stopTest();
    }
}