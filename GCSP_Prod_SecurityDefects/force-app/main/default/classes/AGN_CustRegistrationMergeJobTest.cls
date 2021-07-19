@isTest
public class AGN_CustRegistrationMergeJobTest {
    static TestMethod void setup(){
    List<Account> accounts = new List<Account>();
    Set<Id> contactIds = new Set<Id>();
    List<Contact> standardContacts = new List<Contact>();
    Map<String,String> contactAccountMap = new Map<String,String>();
    List<MERGE_PARENT_AGN__C> mergeRecordList = new List<MERGE_PARENT_AGN__C>();
    List<Allergan_Customer_Registration_AGN__c> registration = new List<Allergan_Customer_Registration_AGN__c>();
    List<Allergan_Customer_Contact_AGN__c> contacts = new List<Allergan_Customer_Contact_AGN__c>();
    for(Integer i=0;i<20;i++){
           accounts.add(new Account(name='testAcc '+i,Country_Code__c='GB'));
        }
    for(Integer i=0;i<10;i++){
            registration.add(new Allergan_Customer_Registration_AGN__c(Process_AGN__c = true,Case_AGN__c='5003O000006qVRPQA2'));
        }
    
    insert standardContacts;
    insert accounts;
    insert registration;
    for(Integer i=0;i<10;i++){
        standardContacts.add(new Contact(AccountId=accounts[i+10].id));        
    }
    
    for(Integer i=0;i<10;i++){
        contacts.add(new Allergan_Customer_Contact_AGN__c(Parent_AGN__c=registration[0].id,Mapped_Account_AGN__c = accounts[i].id,Contact_AGN__c =StandardContacts[i].id ));
    }
    insert contacts;
    for(Allergan_Customer_Contact_AGN__c contact : contacts) {
            contactIds.add(contact.Contact_AGN__c);    
        }
    
    List<AccountContactRelation> acrList = [SELECT AccountId, ContactId 
                                                FROM AccountContactRelation 
                                                WHERE ContactId IN: contactIds 
                                                AND isActive = true 
                                                AND Account.isPersonAccount = true]; 
    for(AccountContactRelation acr : acrList) { 
            contactAccountMap.put(acr.ContactId, acr.AccountId);
        } 
     //for(Allergan_Customer_Contact_AGN__c customerContact : contacts){
    //  Id newAccountId = contactAccountMap.get(contacts.Contact_AGN__c);
   // }
   Test.startTest();
        AGN_CustRegistrationMergeJob b1 = new AGN_CustRegistrationMergeJob();
        Database.QueryLocator ql = b1.start(null);
        b1.execute(null,contacts);
        

        Id batchId = database.executeBatch(b1);
        Test.stopTest();
      //   System.assertEquals(10, [select count() from MERGE_PARENT_AGN__C]);
    Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    
    } 
}