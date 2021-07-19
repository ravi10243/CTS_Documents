@isTest
public class AGN_AMI_SC_External_Password_Test {
    
    public void AGN_AMI_SC_External_Password_Test()
    {
        
    }
    
    public static User dataCreation()
    {
        User u;
        Account acc;     
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];        
        System.runAs (AdminUser) {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId, AGN_AMI_Enabled__c = true);
            insert acc;
            //Contact con = new Contact( Lastname = 'Test', accountId = acc.Id, Is_AMI_Contact_AGN__c= true);
            Id ConId = [Select PersonContactId, Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Contact con = [SELECT Id,Is_AMI_Contact_AGN__c FROM Contact WHERE id = :ConId];
            con.Is_AMI_Contact_AGN__c = true;
            Update con;
            Id profileId = [Select Id from Profile where Name = 'AMI SC Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', Username='standarduser@allergan.example.com',
                         emailencodingkey='UTF-8', lastname='Testing', LanguageLocaleKey='en_US', 
                         localesidkey='en_GB', profileid = profileId, Country_code__c = 'GB', IsActive=true,
                         timezonesidkey='Europe/London',
                         contactId = ConId);
            Insert u;
        }
        
        return u;
    }
    
    @isTest
    public static void testExternalPassController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {   
            PageReference myVfPage = Page.AGN_AMI_SC_Forget_Password;
       		myVfPage.getParameters().put('param','AGN_AMI_SC_Forget_Password');
   			Test.setCurrentPage(myVfPage); 
            System.currentPageReference().getParameters().put('lang', 'en_GB');
            AGN_AMI_SC_External_Password_Controller externalPassController = new AGN_AMI_SC_External_Password_Controller(); 
            externalPassController.email = 'standarduser@allergan.example.com';
            externalPassController.forgotPassword();
            PageReference testpr2 = externalPassController.changePassword();
        }
        Test.stopTest();
    }
}