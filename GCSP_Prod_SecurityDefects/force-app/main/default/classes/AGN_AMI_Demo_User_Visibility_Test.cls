@isTest
public class AGN_AMI_Demo_User_Visibility_Test {
    public void AGN_AMI_Demo_User_Visibility_Test(){
    }
    public static User dataCreation()
    {
        User u;
        Account acc;
        Account acc1;
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];        
        System.runAs (AdminUser) {
            Id meetingRecordId =  Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AMI_Meeting_Record_Type_AGN).getRecordTypeId();
            Id recordtypeid = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get('Portal Attendee').getRecordTypeId();
            // Id attendeeRecordId = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_Attendee_Record_Type_AGN).getRecordTypeId();
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;
            Id recordId1 = [Select Id from RecordType where Name = 'Hospital_vod' Limit 1].Id;
            acc1 = new Account(Name = 'Test', Country_code__c = 'GB', Country_vod__c = counVod.Id,RecordTypeId = recordId1);
            insert acc1;
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test',Primary_Parent_vod__c=acc1.id,Country_code__c = 'GB',AGN_AMI_Enabled__c = true, Country_vod__c = counVod.Id, PersonBirthdate = date.parse('12/10/2015'), RecordTypeId = recordId);
            insert acc;
            
            contact conRecord=new contact();
            conRecord.Accountid=acc1.id;
            conrecord.lastname='TestCon1114';
            insert conRecord;
            AccountContactRelation acr = new AccountContactRelation(); 
            acr.Accountid = acc.id;
            acr.Contactid = conRecord.id;
            insert acr;
            Medical_Event_vod__c medEvent = new Medical_Event_vod__c(Name = 'AMI Event',RecordTypeId = meetingRecordId,
                                                                     AMI_Event_Type_AGN__c = 'Public',
                                                                     AMI_Event_Status_AGN__c = 'Live',
                                                                     Start_time_vod__c = DATETIME.now(),
                                                                     End_time_vod__c = DATETIME.now().adddays(1));
            insert medEvent;
             //medEventId = medEvent.id;
             /*   AccountContactRelation  acrList= [Select AccountId, ContactId
            from AccountContactRelation 
            where ContactId =:conRecord.id and  IsDirect = false
            and Account.AGN_AMI_Enabled__c = true 
            limit 1];*/
            
            Event_Attendee_vod__c eventAtt = new Event_Attendee_vod__c(Account_vod__c = acr.AccountId,
                                                                       Medical_Event_vod__c = medEvent.Id,
                                                                       Status_vod__c='Accepted',RecordTypeId = recordtypeid );
            
            insert eventAtt;
            ApexPages.Currentpage().getParameters().put('clickedEvent', medEvent.Id);
            Id ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', firstname='Demo', lastname='Testing', languagelocalekey='en_GB', 
                         localesidkey='en_GB', profileid = profileId, 
                         timezonesidkey='Europe/London', username='standarduser@allergan.example.com', Country_Code__c=medEvent.Country_Code__c,
                         contactId = ConId);
            Insert u;
            
        }
        
        return u;
    }
    @isTest
    public static void AddDemo_uservisiblity()
    {
        Test.startTest();
        User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            List<Id> idsSet = new List<Id>();
            
            AGN_AMI_Demo_User_Visibility.addDemoUsertoEvent(idsSet);
        }
        Test.stopTest();
        
    }
}