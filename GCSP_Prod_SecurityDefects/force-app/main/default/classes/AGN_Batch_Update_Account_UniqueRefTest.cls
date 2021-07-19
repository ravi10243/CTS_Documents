@isTest
private class AGN_Batch_Update_Account_UniqueRefTest {
	@isTest
    static void testGenerateUniqueRef()
    {
        Account acc = createPersonAccount();
        insert acc;
        
        String query = 'Select Id, Consent_UniqueRef_AGN__c From Account Where Id = \''+acc.Id+'\'';
        
		Test.startTest();
			Id batchId = Database.executeBatch(new AGN_Batch_Update_Account_UniqueRef(query));
        Test.stopTest();
        
        Account account = [Select Id, Consent_UniqueRef_AGN__c From Account Where Id = :acc.Id];
        
        System.assert(account != null);
        System.assertNotEquals(null, account.Consent_UniqueRef_AGN__c);
    }
    
    private static Account createPersonAccount()
    {
        Id accRecId =  [Select Id From Recordtype Where Sobjecttype='Account' and Developername='PersonAccount'].Id;
        Account acc = new Account(LastName = 'Test account', RecordTypeId = accRecId);
        return acc;
    }
    
    public static List<Account> createPersonAccountBulk()
    {
        List<Account> accList = new List<Account>();
        Id accRecId =  [Select Id From Recordtype Where Sobjecttype='Account' and Developername='PersonAccount'].Id;
        for(Integer i=0 ; i<100; i++)
        {
            Account acc = new Account(LastName = 'Test account ' +i , RecordTypeId = accRecId);
            accList.add(acc);
        }
        
        return accList;
    }
    
    @isTest
    static void testGenerateUniqueRefBulk()
    {
        List<String> accountIds = new List<String>();
        List<Account> accList = createPersonAccountBulk();        
        insert accList;
        
        List<Id> accountIdList = new List<Id>();
        for(Account a : accList){
            accountIds.add('\''+a.Id+'\'');    
            accountIdList.add(a.Id);
        }
        
        String accIdStr = '('+String.join(accountIds, ',')+')';                         
        String query = 'Select Id, Consent_UniqueRef_AGN__c From Account Where Id In '+accIdStr;
        
		Test.startTest();
			Id batchId = Database.executeBatch(new AGN_Batch_Update_Account_UniqueRef(query));
        Test.stopTest();
        
        List<Account> results = [Select Id, Consent_UniqueRef_AGN__c From Account Where Id In :accountIdList];
        
        System.assert(results != null);
        System.debug('account count: '+results.size());
        
        for(Account acc : results)
        {
            system.debug('accountId: '+acc.Id+ ' unique code: '+acc.Consent_UniqueRef_AGN__c);
        }
    }
    
    @isTest
    static void testGUID()
    {
        for(Integer i=0; i<100; i++)
        {
            Blob b = Crypto.GenerateAESKey(128);
			String h = EncodingUtil.ConvertTohex(b);
			String guid = h.SubString(0,10);
			//system.debug('&&&&& '+guid+'   ****');
    	}
    }
    
    @isTest
    static void testGenerateUniqueRefSchedule()
    {
        Account acc = createPersonAccount();
        insert acc;
        
        String query = 'Select Id, Consent_UniqueRef_AGN__c From Account Where Id = \''+acc.Id+'\'';
        
		Test.startTest();
			System.schedule('Schedule PIN generation',  '0 5 * * * ?', new AGN_OnlineConsent_ScheduleGenerationPIN()); 
        Test.stopTest();
    }
       
}