@isTest
public class AGN_AMI_SC_All_Event_Controller_Test 
{
    Static Id medEventId;
    public static User dataCreation()
    {  
        User u;
        Account acc;
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (AdminUser)
        {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'France', Country_Name_vod__c = 'France', Alpha_2_Code_vod__c = 'FR', Name = 'FR');
            insert counVod;
            
            Id meetingRecordId =  Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AMI_Meeting_Record_Type_AGN).getRecordTypeId();
            Id attendeeRecordId = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_Attendee_Record_Type_AGN).getRecordTypeId();
            Id recordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();
            
            acc = new Account(Status_AGN__c = 'Active',lastname = 'Test',AGN_AMI_ENABLED__C=true, Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId,Consent_to_Meeting_AGN__c= True);
            insert acc;
            
            AMI_User_Settings_AGN__c AUS = new AMI_User_Settings_AGN__c(Name = 'FR', User_Locale__c='fr_FR',
                                                                        CR_Record_Owner__c='amiadmingb@allergan.com',
                                                                        Username_Suffix__c='ami', User_Profile__c = 'AMI Customer Community', 
                                                                        User_Language__c = 'fr_FR', User_Timezone__c = 'Europe/London');
            insert AUS;
            
            Country_vod__c cou = new Country_vod__c  (name = 'FR');
            Insert cou;
            Medical_Event_vod__c medEvent = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = DATETIME.now(),
                                                                    End_time_vod__c = DATETIME.now().adddays(1),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = cou.id
                                                                    );
            insert medEvent;
            
            medEventId = medEvent.id;
            
            
            Event_Attendee_vod__c eventAtt = new Event_Attendee_vod__c(Account_vod__c = acc.Id,
                                                                       Medical_Event_vod__c = medEvent.Id,
                                                                       Status_vod__c='Accepted',RecordTypeId = attendeeRecordId);
            insert eventAtt;
            ApexPages.Currentpage().getParameters().put('clickedEvent', medEvent.Id);
            
            AMI_Faculty_AGN__c fac = new AMI_Faculty_AGN__c(Name_AGN__c = 'Test Faculty');
            Insert fac;
            
            Meeting_Speaker_AGN__c meetSpeak = new Meeting_Speaker_AGN__c(Meeting_AGN__c = medEvent.id, AMI_Faculty_AGN__c = fac.Id,
                                                                          AMI_Primary_Speaker_AGN__c = True);
            insert meetSpeak;
            
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                         localesidkey='fr_FR', profileid = profileId, 
                         timezonesidkey='Europe/London', Country_code__c = 'FR', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert u;
            
            AGN_Meeting_Setting__c settings = AGN_Meeting_Setting__c.getOrgDefaults();
            settings.Case_Creation_CountryCode_AGN__c= 'FR';
            /*settings.Case_Creation_Recordtype__c= ;
            settings.Case_Creation_CaseType_AGN__c= ;
            settings.Case_Creation_CaseReason_AGN__c= ;
            settings.Case_Creation_ServiceName_AGN__c= ;
            settings.AG_Support_Recordtype_AGN__c= ;*/
            upsert settings AGN_Meeting_Setting__c.Id;
        }
        return u;
    }
    @isTest
    public static void testAllLiveEventPageController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            AGN_AMI_SC_All_Event_Controller allEventPageController = new AGN_AMI_SC_All_Event_Controller();
            allEventPageController.redirectToEvent();
            allEventPageController.searchString = 'AMI Event';
             allEventPageController.searchStart = Datetime.now().format('dd/MM/YYYY');
            allEventPageController.searchEnd = (Datetime.now().adddays(2)).format('dd/MM/YYYY');
            allEventPageController.searchPast = 'false';
            allEventPageController.searchEvents();
            allEventPageController.clickedEvent = medEventId;
            allEventPageController.deregister();
        }
    }
    @isTest
    public static void testAllEventPageController()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            AGN_AMI_SC_All_Event_Controller allEventPageController = new AGN_AMI_SC_All_Event_Controller();
            allEventPageController.redirectToEvent();
            //allEventPageController.searchString = 'AMI Event';
            allEventPageController.searchStart = Datetime.now().format('dd/MM/YYYY');
            allEventPageController.searchEnd = (Datetime.now().adddays(2)).format('dd/MM/YYYY');
            allEventPageController.searchPast = 'false';
            allEventPageController.searchEvents();
            allEventPageController.clickedEvent = medEventId;
            allEventPageController.deregister();
        }
    }
}