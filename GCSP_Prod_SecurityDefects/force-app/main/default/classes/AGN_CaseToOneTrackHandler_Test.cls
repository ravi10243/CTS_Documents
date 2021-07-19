@isTest
public class AGN_CaseToOneTrackHandler_Test {
    
    @isTest
    public static void testCaseUpdate(){
        
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Account account = new Account(name = 'Test Account');
        insert account;
        
        Address_vod__c address = new Address_vod__c(Primary_vod__c = TRUE, Address_line_2_vod__C = 'bavs', City_vod__c ='nbvxc', 
                                                    State_vod__c='fjksd', Country_vod__c='jksas', Zip_vod__c='700054',
                                                    Account_vod__c= account.Id, Account_AGN__c=account.Id);
        insert address;
        
        Contact contact = new Contact(firstname='test', lastname='test', phone='9876543210', AccountId = account.Id);
        insert contact;
        
        Case cs = new Case(PR_ID_Trackwise_AGN__c ='INT-100001', Account= account , ContactId = contact.Id, Origin = 'Email', Subject = 'test subject', 
                                Description = 'Description', Type='Delivery', ownerId = UserInfo.getUserId()
                               );
        
        insert cs;
        
        Test.startTest();
        System.runAs(AdminUser){ 
            
            Map<Id,Case> oldCaseMap = new Map<Id,Case>();
            oldCaseMap.put(cs.id,cs);
            
            List<Case>  csUpdateList = new List<Case>();
            Case c = [Select Id,OwnerId,Type,Description,Aware_Date_CoolS_AGN__c,Event_Date_CoolS_AGN__c,Reported_Serial_Number_CoolS_AGN__c,Origin,Subject,PR_ID_Trackwise_AGN__c,
                      Memo_CoolS_AGN__c,Account_Name_CoolS_AGN__c,SAP_Call_ID_CoolS_AGN__c,Case_Owner_CoolS_AGN__c,SAP_Account_Id_CoolS_AGN__c,ContactPhone,ContactEmail,AccountId,
                      State_CoolS_AGN__c,Postal_Code_CoolS_AGN__c,Street_CoolS_AGN__c,City_CoolS_AGN__c,Country_CoolS_AGN__c from Case where Id =: cs.id];
            c.Subject = 'Test';
            csUpdateList.add(c);  
            Update  csUpdateList;
            
            AGN_CaseToOneTrackHandler execute = new AGN_CaseToOneTrackHandler();
            execute.executeCaseToOneTrackHandler(csUpdateList,oldCaseMap);
            execute.addressFieldsToCase(csUpdateList,oldCaseMap);
            
            Case cas = [Select Id,OwnerId,Type,Description,Aware_Date_CoolS_AGN__c,Event_Date_CoolS_AGN__c,Reported_Serial_Number_CoolS_AGN__c,Origin,Subject,PR_ID_Trackwise_AGN__c,
                      Memo_CoolS_AGN__c,Account_Name_CoolS_AGN__c,SAP_Call_ID_CoolS_AGN__c,Case_Owner_CoolS_AGN__c,SAP_Account_Id_CoolS_AGN__c,ContactPhone,ContactEmail,AccountId,
                      State_CoolS_AGN__c,Postal_Code_CoolS_AGN__c,Street_CoolS_AGN__c,City_CoolS_AGN__c,Country_CoolS_AGN__c from Case where Id =: cs.id];
            System.assertEquals(cas.Subject,'Test');
        }
        Test.stopTest();
    }
}