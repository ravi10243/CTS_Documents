@isTest
public class AGN_CallToOneTrack_Test {
    
    @testSetup
    static void setup() {
        
        Account account = new Account(name = 'Test Account');
        insert account;
        
        Address_vod__c address = new Address_vod__c(Primary_vod__c = TRUE, Address_line_2_vod__C = 'bavs', City_vod__c ='nbvxc', 
                                                    State_vod__c='fjksd', Country_vod__c='jksas', Zip_vod__c='700054',
                                                    Account_vod__c= account.Id, Account_AGN__c=account.Id);
        insert address;
        
        Contact contact = new Contact(firstname='test', lastname='test', phone='9876543210', AccountId = account.Id);
        insert contact;
        
        Case caseObj = new Case(Account= account , ContactId = contact.Id, Origin = 'Email', Subject = 'test subject', 
                                Description = 'Description', Type='Delivery', ownerId = UserInfo.getUserId()
                               );
        
        insert caseObj;
        
        Case_Attributes_for_CoolSculpting_AGN__c caseAttribute = new Case_Attributes_for_CoolSculpting_AGN__c(
            Case_CoolS_AGN__c = caseObj.Id, 
            Serial_Number_CoolS_AGN__c = '111111',
            Aware_Date_CoolS_AGN__c = System.today(),
            Event_Date_CoolS_AGN__c = System.today());
        
        insert caseAttribute;
        
    }
    
    static testmethod void testSubmitCaseToOneTrackForCaseCreation() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('10', '','Already exist',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(Label.Trackwise_case_already_exists_AGN, result);
        Test.stopTest();
    }
    
    static testmethod void testSubmitCaseToOneTrackForCaseCreationWithPrId() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('0', '123','Successful',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(Label.Trackwise_PrId_Success_Message_AGN, result);
        Test.stopTest();
    }
        
    static testmethod void testSubmitCaseToOneTrackForCaseCreationFailedAuthUsername() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('100', '123','wrong username',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(Label.Trackwise_Failed_WS_Authentication_UserName_AGN, result);
        Test.stopTest();
    }
    static testmethod void testSubmitCaseToOneTrackForCaseCreationFailedAuthPassword() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('101', '123','wrong password',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(Label.Trackwise_Failed_WS_Authentication_Password_AGN, result);
        Test.stopTest();
    }
    static testmethod void testSubmitCaseToOneTrackForCaseCreationWithNoInputField()
    {
        Case newCaseWithNoInputField = new Case();
        insert newCaseWithNoInputField;
        Case_Attributes_for_CoolSculpting_AGN__c caseatt = new Case_Attributes_for_CoolSculpting_AGN__c(Case_CoolS_AGN__c = newCaseWithNoInputField.id);
        insert caseatt;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('102', '123','NoInputField',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(newCaseWithNoInputField.id, false);
        System.assertEquals(Label.AGN_OT_No_Input_Fields, result);
        Test.stopTest();
    }
    static testmethod void testSubmitCaseToOneTrackForCaseCreationCaseNumberEmpty() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('111', '123','Case number empty',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(Label.Trackwise_Casenumber_empty_AGN, result);
        Test.stopTest();
    }
      static testmethod void testSubmitCaseToOneTrackForCaseCreationSAPAccountIDEmpty() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('112', '123','SAP_AccountID empty',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(Label.Trackwise_sapAccountId_empty_AGN, result);
        Test.stopTest();
    }
    static testmethod void testSubmitCaseToOneTrackForCaseCreationSourceIDEmpty() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('113', '123','SourceId empty',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(Label.Trackwise_sourceId_empty_AGN, result);
        Test.stopTest();
    }
     static testmethod void testSubmitCaseToOneTrackForCaseCreationInvalidSourceID() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('114', '123','Invalid sourceId',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(Label.Trackwise_Invalid_Source_ID_AGN, result);
        Test.stopTest();
    }
    
    static testmethod void testSubmitCaseToOneTrackForCaseCreationIntakeIdNotReturned()
    {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('118', '123','IntakeId not returned',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(Label.AGN_OT_Intake_Not_Returned_Resubmit, result);
        Test.stopTest();
    }
    
    static testmethod void testSubmitCaseToOneTrackForCaseCreationWithSystemError() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('200', '123','unknown exception',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(Label.Trackwise_Custom_Exception_AGN, result);
        Test.stopTest();
    }
    
    static testmethod void testSubmitCaseToOneTrackForCaseCreationWithDiffReturnCode() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('207', '123','Not known',false));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, false);
        System.assertEquals(null, result);
        Test.stopTest();
    }
    
    static testmethod void testSubmitCaseToOneTrackForCaseModificationWithEmptyAwareDate()
    {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        selectedCase.Subject='test subject1';
        selectedCase.Aware_Date_CoolS_AGN__c=Null;
        update selectedCase;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('119', '123','Aware Date cannot be empty',true));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, true);
    System.assertEquals(Label.AGN_OT_AwareDate_Empty, result);
    Test.stopTest(); 

    }
    
    static testmethod void testSubmitCaseToOneTrackForCaseModificationWithoutIntakeId()
    {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        selectedCase.Subject='test subject1';
        update selectedCase;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('121', '123','IntakeId cannot be blank',true));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, true);
    System.assertEquals(Label.AGN_OT_IntakeId_Empty, result);
    Test.stopTest();        
    }
    
    static testmethod void testSubmitCaseToOneTrackForCaseModificationWithWrongIntakeId()
    {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        selectedCase.Subject='test subject1';
        selectedCase.PR_ID_Trackwise_AGN__c='0000000';
        update selectedCase;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OneTrackHttpCalloutMock('122', '123','Intake Id doesn’t exist in OneTrack',true));
        String result = AGN_CallToOneTrack.submitCaseToOneTrack(selectedCase.id, true);
    System.assertEquals(Label.AGN_OT_IntakeId_Not_Exist, result);
    Test.stopTest(); 
    }
}