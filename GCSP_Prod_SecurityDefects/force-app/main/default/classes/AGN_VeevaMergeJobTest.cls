@isTest
private class AGN_VeevaMergeJobTest {

    static TestMethod void setup(){
        List<Account> accounts = new List<Account>();
        List<MERGE_PARENT_AGN__C> mergeRecordList = new List<MERGE_PARENT_AGN__C>();
        Case newcase = new Case(OwnerId='0053O000002KVApQAO');
        List<Allergan_Customer_Registration_AGN__c> registration = new List<Allergan_Customer_Registration_AGN__c>();
      List<Allergan_Customer_Address_AGN__c> addresses = new List<Allergan_Customer_Address_AGN__c>();
        for(Integer i=0;i<20;i++){
           accounts.add(new Account(name='testAcc '+i,Country_Code__c='GB'));
        }
        for(Integer i=0;i<10;i++){
            registration.add(new Allergan_Customer_Registration_AGN__c(Process_AGN__c = true,Case_AGN__c='5003O000006qVRPQA2'));
        }
        insert accounts;
        insert registration;
        for(Integer i=0;i<10;i++){
            addresses.add(new Allergan_Customer_Address_AGN__c(Parent_AGN__c = registration[i].id,Account_AGN__c = accounts[i].id,Initial_Account_AGN__c = accounts[i+10].id));  
        }
        
     //   insert accounts;
     //   insert registration;
        insert addresses;
        
    
    
        Test.startTest();
        AGN_VeevaMergeJob b1 = new AGN_VeevaMergeJob();
        Database.QueryLocator ql = b1.start(null);
        b1.execute(null,addresses);
		

        Id batchId = database.executeBatch(b1);
        Test.stopTest();
        
        System.assertEquals(10, [select count() from MERGE_PARENT_AGN__C]);
        
	}
}