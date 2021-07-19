/**************************************************************************************************************************
@ Class:  AGN_AMI_DigitalTalks_Controller_Test
@ Version: 1.0
@ Author:  Sujan Guha (sujan.guha@cognizant.com)
@ Purpose: Test Class for AGN_AMI_DigitalTalks_Controller
***************************************************************************************************************************/
@isTest
public class AGN_AMI_DigitalTalks_Controller_Test {
    /**********************************************************************************************************************
    @ Method:         testDigiTalksDetailController
    @ Version:        1.0
    @ Author:         Sujan Guha (sujan.guha@cognizant.com)
    @ Purpose:        TEST CASES: Redirect Method takes to desired url,  
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 11.08.2020 / Sujan Guha / Created the test method.
    ***********************************************************************************************************************/     
    @isTest
    public static void testDigiTalksController(){
    
        //Test Data
        User comUser =AGN_AMI_TestData_Factory.createCommunityUser('u1');
        
        Account accountRecord; //=AGN_AMI_TestData_Factory.createAccountNew();
       	Country_vod__c contr=[SELECT Id FROM Country_vod__c WHERE Name = 'GB']; 
        Account accRecord;
        Contact conRecord;
        String userLanguage;
       	String userCountryName; 
        String clickedAction;
        //String meetingRecordTypeId1 = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AGN_AMI_Digital_Talks_Record_Type).getRecordTypeId();
        Medical_Event_vod__c meetingRecord=AGN_AMI_TestData_Factory.createDigitalEvent('AMI Digital Talks');
        List<Meeting_Speaker_AGN__c> speakerList;
        //Meeting_Speaker_AGN__c meetSpeaker;
        //meetSpeaker=AGN_AMI_TestData_Factory.createMeetingSpeaker(meetingRecord,contr);
        //speakerList.add(meetSpeaker);
        
        list<AGN_AMI_Meeting_Details_Wrapper> digiTalksmeetings;
   		List<AGN_AMI_Meeting_Details_Wrapper> fullMeetings;
        List<Medical_Event_vod__c> digiEvents=AGN_AMI_TestData_Factory.createDigitalMeetings('AMI Digital Talks',3);
        //Profile: AMI Community User
        System.runAs(comUser){
           Test.startTest();
            //STEP 1: Launch console page
            PageReference pageRef=page.AGN_AMI_DigitalTalks_Page;
            Test.setCurrentPage(pageRef);
            
            AGN_AMI_DigitalTalks_Controller digitalTalksController=new AGN_AMI_DigitalTalks_Controller();
            digitalTalksController.clickedEvent=meetingRecord.Id;
            ApexPages.Currentpage().getParameters().put('clickedEvent', meetingRecord.Id);
            ApexPages.Currentpage().getParameters().put('request','play');
            digitalTalksController.redirectToEvent();
            digitalTalksController.searchString = 'Event';
            digitalTalksController.searchEvents();
            digitalTalksController.searchStart = Datetime.now().format('dd/MM/YYYY');
            digitalTalksController.searchEnd = (Datetime.now().adddays(2)).format('dd/MM/YYYY');
            digitalTalksController.searchEvents();
            
            
            
		}
		Test.stopTest();
		
        
        
    }

}