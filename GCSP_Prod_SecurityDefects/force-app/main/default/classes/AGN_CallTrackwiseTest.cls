@isTest
public class AGN_CallTrackwiseTest {

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
    
    static testmethod void testCreateCaseTrackwise() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrackwiseHttpCalloutMock('10', ''));
        String result = AGN_CallTrackwise.createCaseTrackwise(selectedCase.id);
        System.assertEquals(Label.Trackwise_case_already_exists_AGN, result);
        
        Test.stopTest();
    }
    
    static testmethod void testCreateCaseTrackwiseWithPrId() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrackwiseHttpCalloutMock('0', '123'));
        String result = AGN_CallTrackwise.createCaseTrackwise(selectedCase.id);
        System.assertEquals(Label.Trackwise_PrId_Success_Message_AGN, result);
        Test.stopTest();
    }
  
    static testmethod void testCreateCaseTrackwiseFailedAuthUsername() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrackwiseHttpCalloutMock('100', '123'));
        String result = AGN_CallTrackwise.createCaseTrackwise(selectedCase.id);
        System.assertEquals(Label.Trackwise_Failed_WS_Authentication_UserName_AGN, result);
        Test.stopTest();
    }
    static testmethod void testCreateCaseTrackwiseFailedAuthPassword() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrackwiseHttpCalloutMock('101', '123'));
        String result = AGN_CallTrackwise.createCaseTrackwise(selectedCase.id);
        System.assertEquals(Label.Trackwise_Failed_WS_Authentication_Password_AGN, result);
        Test.stopTest();
    }
    static testmethod void testCreateCaseTrackwiseCaseNumberEmpty() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrackwiseHttpCalloutMock('111', '123'));
        String result = AGN_CallTrackwise.createCaseTrackwise(selectedCase.id);
        System.assertEquals(Label.Trackwise_Casenumber_empty_AGN, result);
        Test.stopTest();
    }
      static testmethod void testCreateCaseTrackwiseSAPAccountIDEmpty() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrackwiseHttpCalloutMock('112', '123'));
        String result = AGN_CallTrackwise.createCaseTrackwise(selectedCase.id);
        System.assertEquals(Label.Trackwise_sapAccountId_empty_AGN, result);
        Test.stopTest();
    }
    static testmethod void testCreateCaseTrackwiseSourceIDEmpty() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrackwiseHttpCalloutMock('113', '123'));
        String result = AGN_CallTrackwise.createCaseTrackwise(selectedCase.id);
        System.assertEquals(Label.Trackwise_sourceId_empty_AGN, result);
        Test.stopTest();
    }
     static testmethod void testCreateCaseTrackwiseInvalidSourceID() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrackwiseHttpCalloutMock('114', '123'));
        String result = AGN_CallTrackwise.createCaseTrackwise(selectedCase.id);
        System.assertEquals(Label.Trackwise_Invalid_Source_ID_AGN, result);
        Test.stopTest();
    }
    
    static testmethod void testCreateCaseTrackwiseWithSystemErrorReturnCode() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrackwiseHttpCalloutMock('200', '123'));
        String result = AGN_CallTrackwise.createCaseTrackwise(selectedCase.id);
        System.assertEquals(Label.Trackwise_Custom_Exception_AGN, result);
        Test.stopTest();
    }
      
    static testmethod void testCreateCaseTrackwiseWithDiffReturnCode() {
        Case selectedCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TrackwiseHttpCalloutMock('207', '123'));
        String result = AGN_CallTrackwise.createCaseTrackwise(selectedCase.id);
        System.assertEquals(null, result);
        Test.stopTest();
    }
}