@isTest
public class AGN_AMI_Add_Attendee_Test 
{
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
            acc = new Account(lastname = 'Test',AGN_AMI_ENABLED__C=true, Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId);
            insert acc;
            
            AMI_HCP_Profile_AGN__c hp = new AMI_HCP_Profile_AGN__c(Account_AGN__c=acc.Id,AMI_Education_AGN__c='1');
            insert hp;
            
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
    public static void testAddAttendee()
    {
        Test.startTest();
        User TestUser=dataCreation();
        
        System.runAs(TestUser)
        {           
            Medical_event_vod__c me = new Medical_event_vod__c(Name='Test Event', 
                                                               Start_Time_vod__c=Datetime.now(), 
                                                               End_Time_vod__c=Datetime.now().addDays(1),
                                                               Status_AGN__c='Planned');
            insert me;
            ApexPages.StandardController sc = new ApexPages.StandardController(me);
            Test.setCurrentPageReference(new PageReference('/apex/AGN_AMI_Add_Attendee_Page')); 
            system.debug(me.Id);
            System.currentPageReference().getParameters().put('Id',me.Id);
            AGN_AMI_Add_Attendee_controller addAttendeeController = new AGN_AMI_Add_Attendee_controller(sc);
            addAttendeeController.getItems();
            addAttendeeController.educationjourney = '1';
            addAttendeeController.proceed();
            addAttendeeController.cancel();
            AGN_AMI_Add_Attendee_controller.wrapperlist wl = addAttendeeController.myoriginal[0];
            wl.selected = true;
            addAttendeeController.myoriginal[0] = wl;
            addAttendeeController.addtoevent();
                        
        }
        Test.stopTest();
    }
}