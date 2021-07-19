@isTest
public class AGN_DeactivationHCPHelperTest {

	@testSetup static void setup() {

	}

	@isTest static void needAnonymiseTest() {
		// account with one recent call
		Account a = new Account();
		a.LastName = 'a test 1';
		insert a;

		Call2_vod__c c = new Call2_vod__c();
		c.Call_Datetime_vod__c = System.Now().addMonths(-3);
		c.Account_vod__c = a.Id;
		insert c;

		System.assertEquals(true, new AGN_DeactivationHCPHelper(a.Id).needAnonymise());

		// account with one recent call and one not recent call
		Call2_vod__c c2 = new Call2_vod__c();
		c2.Call_Datetime_vod__c = System.Now().addMonths(-23);
		c2.Account_vod__c = a.Id;
		insert c2;

		System.assertEquals(true, new AGN_DeactivationHCPHelper(a.Id).needAnonymise());

		// account without recent calls
		delete c;
		System.assertEquals(false, new AGN_DeactivationHCPHelper(a.Id).needAnonymise());

	}

	@isTest static void isTheOnlyChildTest() {
		// account without parent
		Account a = new Account();
		a.LastName = 'a test 1';
		insert a;

		System.assertEquals(true, new AGN_DeactivationHCPHelper(a.Id).isTheOnlyChild());

		// account with one parent. Parent has only one child.
		Account aParent = new Account();
		aParent.Name = 'a parent test 1';
		Id businessAccountRT = [select Id from RecordType where DeveloperName = 'Provisional_Business_Account_AGN' AND SobjectType = 'Account' limit 1].Id;

		aParent.RecordTypeId = businessAccountRT;
		insert aParent;

		a.Primary_Parent_vod__c = aParent.Id;
		update a;

		System.assertEquals(true, new AGN_DeactivationHCPHelper(a.Id).isTheOnlyChild());

		// account with one parent. Parent has more than child.
		Account a2 = new Account();
		a2.LastName = 'a test 2';
		a2.Primary_Parent_vod__c = aParent.Id;
		insert a2;

		System.assertEquals(false, new AGN_DeactivationHCPHelper(a.Id).isTheOnlyChild());
	}

	@isTest static void needDataRetentionTest() {
		// account without anything
		Account a = new Account();
		a.LastName = 'a test 1';
		insert a;
		System.assertEquals(false, new AGN_DeactivationHCPHelper(a.Id).needDataRetention());

		// account with one call sample
		Call2_vod__c c = new Call2_vod__c();
		c.Call_Datetime_vod__c = System.Now().addMonths(-3);
		c.Account_vod__c = a.Id;
		insert c;

		Call2_Sample_vod__c cs = new Call2_Sample_vod__c();
		cs.Call2_vod__c = c.Id;
		DateTime dT = System.Now().addMonths(-3);
		cs.Call_Date_vod__c = date.newinstance(dT.year(), dT.month(), dT.day());
		cs.Product_vod__c = 'a006E000002bk89';
		insert cs;

		System.assertEquals(true, new AGN_DeactivationHCPHelper(a.Id).needDataRetention());

	}

}