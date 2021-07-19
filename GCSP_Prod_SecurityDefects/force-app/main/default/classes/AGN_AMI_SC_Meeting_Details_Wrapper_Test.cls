@isTest
public class AGN_AMI_SC_Meeting_Details_Wrapper_Test {
    @isTest
    public static void testMeetingDetails(){
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
                Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI SC Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', Username='standarduser@allergan.example.com',
                              emailencodingkey='UTF-8', lastname='Testing', LanguageLocaleKey='en_US', 
                              localesidkey='en_GB', profileid = profileId, Country_code__c = 'GB', IsActive=true,
                              timezonesidkey='Europe/London',
                              contactId = ConId);
            Insert u;
        	
            Id meetingRecordId =  Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AMI_Meeting_Record_Type_AGN).getRecordTypeId();
            
           
            List<Medical_Event_vod__c> medEventLst = new List<Medical_Event_vod__c>();
            
            Medical_Event_vod__c medEvent1 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 01, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 01, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
            medEventLst.add(medEvent1);
            
            Medical_Event_vod__c medEvent2 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 02, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 02, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
            medEventLst.add(medEvent2);
            Medical_Event_vod__c medEvent3 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 03, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 03, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
             medEventLst.add(medEvent3);
            Medical_Event_vod__c medEvent4 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 04, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 04, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
             medEventLst.add(medEvent4);
            Medical_Event_vod__c medEvent5 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 05, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 05, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
            insert medEvent5;
            
            Medical_Event_vod__c medEvent6 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 06, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 06, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
            medEventLst.add(medEvent6);
           Medical_Event_vod__c medEvent7 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 07, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 07, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
             medEventLst.add(medEvent7);
            Medical_Event_vod__c medEvent8 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 08, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 08, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
            insert medEvent8;
            Medical_Event_vod__c medEvent9 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 09, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 09, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
             medEventLst.add(medEvent9);
            
            Medical_Event_vod__c medEvent10 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 10, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 10, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
             medEventLst.add(medEvent10);
            Medical_Event_vod__c medEvent11 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 11, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 11, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
             medEventLst.add(medEvent11);
            Medical_Event_vod__c medEvent12 = new Medical_Event_vod__c(Name = 'AMI Event', RecordTypeId = meetingRecordId,
                                                                    AMI_Event_Type_AGN__c = 'Public',
                                                                    AMI_Event_Status_AGN__c = 'Live',
                                                                    Start_time_vod__c = datetime.newInstance(2019, 12, 15, 12, 30, 0),
                                                                    End_time_vod__c = datetime.newInstance(2019, 12, 16, 12, 30, 0),
                                                                    AGN_AMI_Business_Unit__c = 'Specialty Care',
                                                                    Country_AGN__c = counVod.id,
                                                                    SPC_Approver_AGN__c = u.id
                                                                    );
            
            
			 medEventLst.add(medEvent12);
            Insert medEventLst;
            
            Test.startTest();
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet1 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent1, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet2 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent2, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet3 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent3, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet4 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent4, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet5 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent5, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet6 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent6, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet7 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent7, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet8 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent8, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet9 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent9, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet10 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent10, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet11 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent11, true, 'Test Faculty');
            AGN_AMI_SC_Meeting_Details_Wrapper meetingDet12 = new AGN_AMI_SC_Meeting_Details_Wrapper(medEvent12, true, 'Test Faculty');
            Test.stopTest();
        }
        //etingDet.AGN_AMI_SC_Meeting_Details_Wrapper( mdEve, true, 'Test Faculty');
        
      
   		
    }
	
}