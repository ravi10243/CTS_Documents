@isTest
public class AGN_CaseToOneTrackHandlerBatchTest {
    
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
                                Description = 'Description', Type='Delivery', ownerId = UserInfo.getUserId(),OTI_Batch_Status_CoolS_AGN__c = 'Scheduled'
                               );
        
        insert caseObj;
        
        Case_Attributes_for_CoolSculpting_AGN__c caseAttribute = new Case_Attributes_for_CoolSculpting_AGN__c(
            Case_CoolS_AGN__c = caseObj.Id, 
            Serial_Number_CoolS_AGN__c = '111111',
            Aware_Date_CoolS_AGN__c = System.today(),
            Event_Date_CoolS_AGN__c = System.today());
        
        insert caseAttribute;
    }
    
    public static testmethod void AGN_CaseUpdateOneTrackTest(){
 
        Test.startTest();
        //String status='Scheduled';
         String query = 'Select id from Case where OTI_Batch_Status_CoolS_AGN__c=\'Scheduled\'';
        AGN_CaseToOneTrackHandlerBatch caseBatch= new AGN_CaseToOneTrackHandlerBatch(query);
        Database.executeBatch(caseBatch);
        Test.stopTest();
        System.assertEquals(1, [select count() from Case]);
    }     
}