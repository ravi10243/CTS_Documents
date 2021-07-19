@isTest
public class AGN_AMI_SC_HeaderController_Test { 
    static Country_vod__c counVod;
    public static User dataCreation()
    {
        counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
        insert counVod;
        User u;
        Account acc;   
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];        
        System.runAs (AdminUser) {
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c = counVod.Id, RecordTypeId = recordId);
            insert acc;
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', firstname='Demo', lastname='Testing', languagelocalekey='en_GB', 
                         localesidkey='en_GB', profileid = profileId, Country_code__c = 'GB',
                         timezonesidkey='Europe/London', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert u;
        }
        Id currRecordTypeId = [SELECT Id,Name FROM RecordType WHERE SobjectType='AMI_Learning_AGN__c' and DeveloperName ='Curriculum' LIMIT 1].Id;
        AMI_Learning_AGN__c curriuclum = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum', Country_AGN__c = counVod.Id, IsActive_AGN__c = true, Franchise_AGN__c = 'Facial Aesthetics', RecordTypeId = currRecordTypeId);
        AMI_Learning_AGN__c curriuclum1 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum1', Country_AGN__c = counVod.Id, IsActive_AGN__c = true, Franchise_AGN__c = 'Earfold', RecordTypeId = currRecordTypeId);
        AMI_Learning_AGN__c curriuclum2 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum2', Country_AGN__c = counVod.Id, Franchise_AGN__c = 'Business Excellence', RecordTypeId = currRecordTypeId);    
        AMI_Learning_AGN__c curriuclum3 = new AMI_Learning_AGN__c(Name_AGN__c = 'Test Curriculum3', Country_AGN__c = counVod.Id, IsActive_AGN__c = true, Franchise_AGN__c = 'Facial Aesthetics', RecordTypeId = currRecordTypeId);
        insert curriuclum;
        insert curriuclum1;
        insert curriuclum2;
        insert curriuclum3;
        system.debug(curriuclum.id);
        return u;
    }
    
    @isTest
    public static void testHeaderController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {          
            System.currentPageReference().getParameters().put('country', 'GB');     
            System.currentPageReference().getParameters().put('lang', 'en');  
            AGN_AMI_SC_HeaderController headerController = new AGN_AMI_SC_HeaderController(); 
            System.assertNotEquals(null, headerController);
            
            PageReference testpr2 = headerController.searchRedirect();
            PageReference testpr4 = headerController.logoutRedirect();
            headerController.SelSearch = 'Test';
            headerController.selMod = 'Test';
			headerController.searchKey = 'Test';
            headerController.getImageName();
            PageReference testpr3 = headerController.searchRedirect();
             PageReference testpr5 = headerController.logoutRedirect();
        }
        Test.stopTest();
    }
}