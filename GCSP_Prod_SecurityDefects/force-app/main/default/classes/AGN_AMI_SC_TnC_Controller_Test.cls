@isTest
public class AGN_AMI_SC_TnC_Controller_Test { 
    
    public void AGN_AMI_SC_TnC_Controller_Test(){
        
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
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c = counVod.Id, RecordTypeId = recordId);
            insert acc;
            AMI_User_Settings_AGN__c AUS = new AMI_User_Settings_AGN__c(Name = 'GB', User_Locale__c='en_GB',
                                                                        CR_Record_Owner__c='amiadmingb@allergan.com',
                                                                        Username_Suffix__c='ami', User_Profile__c = 'AMI SC Customer Community', 
                                                                        User_Language__c = 'en_GB', User_Timezone__c = 'Europe/London');
            insert AUS;
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI SC Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', firstname='Demo', lastname='Testing', languagelocalekey='en_GB', 
                         localesidkey='en_GB', profileid = profileId, 
                         timezonesidkey='Europe/London', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert u;
        }
       
        return u;
    }
    
    @isTest
    public static void tncController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {           
            AGN_AMI_SC_TnC_Controller tncController = new AGN_AMI_SC_TnC_Controller(); 
            System.assertNotEquals(null, tncController);
        }
        Test.stopTest();
    }
}