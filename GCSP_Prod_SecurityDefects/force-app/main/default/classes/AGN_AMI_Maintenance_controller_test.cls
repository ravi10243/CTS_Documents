@isTest
public class AGN_AMI_Maintenance_controller_test {
    
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
	@isTest
    public static void testMaintenanceController(){
        Test.startTest();
        User TestUser=dataCreation();        
        System.runAs(TestUser) { 
           System.currentPageReference().getParameters().put('country', 'GB');
           System.currentPageReference().getParameters().put('lang', 'en_US');
           AGN_AMI_Maintenance_controller MaintenanceController = new AGN_AMI_Maintenance_controller(); 
           System.assertNotEquals(null, MaintenanceController);
        }
        Test.stopTest();
	}
}