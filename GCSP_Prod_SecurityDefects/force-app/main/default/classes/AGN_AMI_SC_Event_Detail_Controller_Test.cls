@isTest
public class AGN_AMI_SC_Event_Detail_Controller_Test { 
    Static ID medID1; 
    Static ID medID2;
    public static  User dataCreation() { 
        User user;
        Country_vod__c counVod;
        Account acc; 
        AMI_Faculty_AGN__c faculty;
        string userLanguage;
        string userCountryName;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (AdminUser) {
            
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'GB', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;   
            Id meetingRecordId =  Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AMI_Meeting_Record_Type_AGN).getRecordTypeId();
            Id recordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();	
            Id attendeeRecordId = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_Attendee_Record_Type_AGN).getRecordTypeId(); 
            datetime mydate = system.now();
            List<Medical_Event_vod__c> medEventList = new List<Medical_Event_vod__c>();
            Medical_Event_vod__c medEvnt= new Medical_Event_vod__c();
            medEvnt.Name = 'AMI Test Event 111';
            medEvnt.Start_Time_vod__c = mydate;
            medEvnt.End_Time_vod__c = mydate+0.2;
            medEvnt.Description_vod__c ='Test Med 1';
            medEvnt.AMI_Event_Delivery_Type_AGN__c = 'Live Stream';
            medEvnt.Geographic_Region_AGN__c = 'Local';
            medEvnt.Meeting_Type_Picklist_AGN__c = 'AMI Medical Education';
            medEvnt.AMI_Event_Status_AGN__c = 'Live';
            medEvnt.RecordTypeId = meetingRecordId;   
            medEvnt.AMI_Event_Type_AGN__c = 'Public';
            medEventList.add(medEvnt);
            
            Medical_Event_vod__c medEvnt2= new Medical_Event_vod__c();
            medEvnt2.Name = 'AMI Test Event 111';
            medEvnt2.Start_Time_vod__c = mydate;
            medEvnt2.End_Time_vod__c = mydate+0.2;
            medEvnt2.Description_vod__c ='Test Med 1';
            medEvnt2.AMI_Event_Delivery_Type_AGN__c = 'Live Stream';
            medEvnt2.Geographic_Region_AGN__c = 'Local';
            medEvnt2.Meeting_Type_Picklist_AGN__c = 'AMI Medical Education';
            medEvnt2.AMI_Event_Status_AGN__c = 'Recorded';
            medEvnt2.RecordTypeId = meetingRecordId;   
            medEvnt2.AMI_Event_Type_AGN__c = 'Public';
            medEventList.add(medEvnt2);
            insert medEventList;
            
            medID1 = medEventList[0].Id;
            medID2 = medEventList[1].Id;
            
            AMI_User_Settings_AGN__c AUS = new AMI_User_Settings_AGN__c(Name = 'GB', User_Locale__c='en_GB',
                                                                        CR_Record_Owner__c='amiadmingb@allergan.com',
                                                                        Username_Suffix__c='ami', User_Profile__c = 'AMI Customer Community', 
                                                                        User_Language__c = 'en_GB', User_Timezone__c = 'Europe/London');
            insert AUS;
            
            acc = new Account(lastname = 'Test',AGN_AMI_ENABLED__C=true, Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId,Consent_to_Meeting_AGN__c= True);
            insert acc;
            faculty = new AMI_Faculty_AGN__c(Name_AGN__c ='Dr. A Kaz', Country_AGN__c = 'UK', Country_LKP_AGN__c = counVod.id);
            insert faculty;
            Meeting_Speaker_AGN__c meetSpeak = new Meeting_Speaker_AGN__c(Meeting_AGN__c = medID1,
                                                                          AMI_Primary_Speaker_AGN__c = True, AMI_Faculty_AGN__c = faculty.id);
            insert meetSpeak; 
            
            List<Event_Attendee_vod__c> lstEvAtt = new List<Event_Attendee_vod__c>();
            
            Event_Attendee_vod__c eventAtt = new Event_Attendee_vod__c(Account_vod__c = acc.Id,
                                                                       Medical_Event_vod__c = medID1,
                                                                       Status_vod__c='Accepted',RecordTypeId = attendeeRecordId,AGN_AMI_Business_Unit__c='Specialty Care');
            system.debug('eventAtt>>>>>' + eventAtt);
            lstEvAtt.add(eventAtt);
            Event_Attendee_vod__c eventAtt2 = new Event_Attendee_vod__c(Account_vod__c = acc.Id,
                                                                       Medical_Event_vod__c = medID2,
                                                                       Status_vod__c='Accepted',RecordTypeId = attendeeRecordId);
            system.debug('eventAtt2>>>>>' + eventAtt2);
            lstEvAtt.add(eventAtt2);
            Insert lstEvAtt;
            
            Country_vod__c cou  = new Country_vod__c( Name = 'GB');
            Insert cou;
            AMI_Event_Agenda_AGN__c agnd = new AMI_Event_Agenda_AGN__c( Name_AGN__c = 'Test Agenda',
                          Description_AGN__c = 'Test Descrpition',
                          End_Time_AGN__c = datetime.newInstance(2019, 9, 15, 12, 30, 0),
                          Start_Time_AGN__c =datetime.newInstance(2019, 9, 14, 12, 30, 0),
                          Day_of_Activity_AGN__c = 1,
                          Meeting_AGN__c = medID1,
                          Active_AGN__c = TRUE, 
                          Country_AGN__c = cou.Id,                                             
                          Language_AGN__c = 'en_US');
            system.debug('agnd>>>>>' + agnd);
            Insert agnd;
           
            
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            
            user = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                            localesidkey='en_GB', profileid = profileId, 
                            timezonesidkey='Europe/London', Country_code__c = 'GB', username='standarduser@allergan.example.com',
                            contactId = ConId);
            Insert user; 
        }
        return user;
    }
    
    @isTest
    public static void testEventDetailsPageController() {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser) {
            ApexPages.Currentpage().getParameters().put('eventId', medID1);
            ApexPages.Currentpage().getParameters().put('request', 'register');
            AGN_AMI_SC_Event_Detail_Controller EventDetailController = new AGN_AMI_SC_Event_Detail_Controller();
            EventDetailController.changeSelectFaculty();
            EventDetailController.saveStreaming();
            EventDetailController.markAttendance();
            ApexPages.Currentpage().getParameters().put('eventId', medID2);
            ApexPages.Currentpage().getParameters().put('request', 'play');
            //AgendaWrapper wrp = new AgendaWrapper(agnd);
        }
        Test.stopTest();
    }
}