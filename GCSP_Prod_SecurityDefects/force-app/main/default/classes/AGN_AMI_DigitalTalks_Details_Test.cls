/**************************************************************************************************************************
@ Class:  AGN_AMI_DigitalTalks_Details_Test
@ Version: 1.0
@ Author:  Sujan Guha (sujan.guha@cognizant.com)
@ Purpose: Test Class for AGN_AMI_DigitalTalks_Details_Controller
***************************************************************************************************************************/
@isTest
public class AGN_AMI_DigitalTalks_Details_Test {

    /**********************************************************************************************************************
    @ Method:         testDigiTalksDetailController
    @ Version:        1.0
    @ Author:         Sujan Guha (sujan.guha@cognizant.com)
    @ Purpose:        TEST CASES: Redirect Method takes to desired url,  
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 11.08.2020 / Sujan Guha / Created the test method.
    ***********************************************************************************************************************/ 
    
    @isTest
    public static void testDigiTalksDetailController(){
        
        //Test Data
        User comUser =AGN_AMI_TestData_Factory.createCommunityUser('u1');
       	Country_vod__c contr=[SELECT Id FROM Country_vod__c WHERE Name = 'GB']; 
        Account accountRecord;
        Contact contactRecord;
        String userCountryName;
        String userLanguage;
        List<AGN_AMI_Meeting_Doc__c> agnAMIMeetingDocList=new List<AGN_AMI_Meeting_Doc__c>();
        List<Meeting_Speaker_AGN__c> speakerList=new List<Meeting_Speaker_AGN__c>();
		Meeting_Speaker_AGN__c meetSpeaker;
        
        //String meetingRecordTypeId  = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AGN_AMI_Digital_Talks_Record_Type).getRecordTypeId();
        Medical_Event_vod__c meetingRecord=AGN_AMI_TestData_Factory.createDigitalEvent('AMI Digital Talks');
        meetSpeaker=AGN_AMI_TestData_Factory.createMeetingSpeaker(meetingRecord,contr);
        speakerList.add(meetSpeaker);
        Id recordId=meetingRecord.Id;
        AGN_AMI_Meeting_Doc__c meetDoc=AGN_AMI_TestData_Factory.createMeetingDoc(meetingRecord);
        agnAMIMeetingDocList.add(meetDoc);
        
        

        //Profile: AMI Community User
        System.runAs(comUser){
            Test.startTest();
			
            //STEP 1: Launch console page
            PageReference pageRef=page.AGN_AMI_DigitalTalks_Detail_Page;
            Test.setCurrentPage(pageRef);
            ApexPages.Currentpage().getParameters().put('eventId', meetingRecord.Id);
            ApexPages.Currentpage().getParameters().put('request', 'view');
            AGN_AMI_DigitalTalks_Details_Controller digitalTalksDetailController=new AGN_AMI_DigitalTalks_Details_Controller();

            digitalTalksDetailController.changeSelectFaculty();
            
            ApexPages.Currentpage().getParameters().put('eventId', meetingRecord.Id);
            ApexPages.Currentpage().getParameters().put('request', 'play');
            AGN_AMI_DigitalTalks_Details_Controller digitalTalksDetailController2=new AGN_AMI_DigitalTalks_Details_Controller();
           
        }
        Test.stopTest();
        
    }  
}