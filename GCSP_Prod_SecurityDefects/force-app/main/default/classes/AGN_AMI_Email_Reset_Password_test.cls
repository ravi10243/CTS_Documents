@isTest
public class AGN_AMI_Email_Reset_Password_test {

    public void AGN_AMI_Email_Reset_Password_test(){
        
    }
    
    public static User dataCreation()
    {
        User u;
        Account acc;  
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];        
        System.runAs (AdminUser) {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Name = 'GB');
            insert counVod;
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId);
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
    public static void testEmailResetPasswordController(){
        Test.startTest();
        User TestUser=dataCreation();   
        PageReference myVfPage = Page.AGN_AMI_Email_Reset_Password_Page;
        Test.setCurrentPage(myVfPage);            
		ApexPages.currentPage().getParameters().put('UserId',TestUser.Id);
        ApexPages.currentPage().getParameters().put('country','GB');
        ApexPages.currentPage().getParameters().put('lang','en_GB');                   
        AGN_AMI_Email_Reset_Password_Controller resetPassCon = new AGN_AMI_Email_Reset_Password_Controller();        
        resetPassCon.changePassword();
        resetPassCon.countryRedirect();
        Test.stopTest();        
    }
}