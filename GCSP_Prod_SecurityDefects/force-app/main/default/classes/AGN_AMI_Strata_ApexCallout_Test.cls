@isTest
public class AGN_AMI_Strata_ApexCallout_Test {
    static list<Medical_Event_vod__c> Meeting;
    public static User dataCreation() {
        User user;
        Country_vod__c counVod;
        Account acc;
        AMI_Strata_Integration_credentials__c  strataCredential;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (AdminUser) {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'GB', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod; 
            Id meetingRecordId =  Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AMI_Meeting_Record_Type_AGN).getRecordTypeId();
            Id recordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional').getRecordTypeId();  
            Id attendeeRecordId = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_Attendee_Record_Type_AGN).getRecordTypeId(); 
            datetime mydate = system.now();
            Meeting = new List<Medical_Event_vod__c>();
            Medical_Event_vod__c medEvnt= new Medical_Event_vod__c();
            medEvnt.Name = 'AMI Test Strata Event 111';
            medEvnt.Start_Time_vod__c = mydate;
            medEvnt.End_Time_vod__c = mydate+0.2;
            medEvnt.Description_vod__c ='Test Med 1';
            medEvnt.AMI_Event_Delivery_Type_AGN__c = 'Live Stream';
            medEvnt.Geographic_Region_AGN__c = 'Local';
            medEvnt.Meeting_Type_Picklist_AGN__c = 'AMI Event & Customer Journey';
            medEvnt.AMI_Event_Status_AGN__c = 'Live';
            medEvnt.RecordTypeId = meetingRecordId;   
            medEvnt.AMI_Event_Type_AGN__c = 'Public';
            medEvnt.Strata_Webcast_Id__c = '661';   
            medEvnt.Strata_Presentation_Id__c = '701';
            medEvnt.Is_Strata_Event__c=true;
            Meeting.add(medEvnt);
            insert Meeting;
            acc = new Account(lastname = 'Test',AGN_AMI_ENABLED__C=true, Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId,Consent_to_Meeting_AGN__c= True);
            insert acc;
            Event_Attendee_vod__c eventAtt = new Event_Attendee_vod__c(Account_vod__c = acc.Id,
                                                                       Medical_Event_vod__c = Meeting[0].Id,
                                                                       Status_vod__c='Accepted',RecordTypeId = attendeeRecordId);
            insert eventAtt;
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            
            user = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                            localesidkey='en_GB', profileid = profileId, 
                            timezonesidkey='Europe/London', Country_code__c = 'GB', username='standarduser@allergan.example.com',
                            contactId = ConId);
            Insert user; 
            
            strataCredential = new AMI_Strata_Integration_credentials__c(Name='Groovygecko', API_Endpoint__c ='https://groovygecko-api.eckoenterprise-staging.net/api/admin/webcasts/webCastId/presentations/presentationId/statistics/attendees?required=veevaId&with=survey.feedback&return=veevaId,survey.rating',Authentication_Token__c='182ae4c2-ec48-46c7-a01a-6cf2551385bc');
            
            Insert strataCredential;  
            
        }
        return user; 
    }
    @isTest
    public static void TestStrataApexCallout() {
                
        User TestUser=dataCreation();  
             
        System.runAs(TestUser) {
            ApexPages.Currentpage().getParameters().put('eventId', Meeting[0].Id);
            ApexPages.Currentpage().getParameters().put('request', 'register'); 
            Test.startTest();
             Test.setMock(HttpCalloutMock.class, new AGN_AMI_Strata_MockHttpResponseGenerator());
             //AGN_AMI_Strata_ApexCallout.groovyGeckoApexcallout(Meeting);
             AGN_AMI_Strata_ApexCallout.getAttendeeRatings(Meeting[0].Id,Meeting[0].Strata_Webcast_Id__c,Meeting[0].Strata_Presentation_Id__c);
          Test.stopTest();
        }
        
    }
    @isTest
    public static void TestStrataApexCalloutQueue() {
              
        User TestUser=dataCreation();  
             
        System.runAs(TestUser) {
            ApexPages.Currentpage().getParameters().put('eventId', Meeting[0].Id);
            ApexPages.Currentpage().getParameters().put('request', 'register');
            Test.startTest();   
             Test.setMock(HttpCalloutMock.class, new AGN_AMI_Strata_MockHttpResponseGenerator());
              AGN_AMI_Strata_ApexCallout.groovyGeckoApexcallout(Meeting);
             Test.stopTest();
             //AGN_AMI_Strata_ApexCallout.getAttendeeRatings(Meeting[0].Id,Meeting[0].Strata_Webcast_Id__c,Meeting[0].Strata_Presentation_Id__c);
        }
        
    }
}