@isTest
private class AccountCustomerGPSAssessmentTest {

    @testSetup
    static void testSetup() {
        GPS_Assessment__c assessment = GPSCreateTestData.createAssessment();
        List<Account> accounts = GPSCreateTestData.createAccounts();

        List<User> users = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<Account_GPS_Assessment__c> accountAssessments = GPSCreateTestData.createAccountAssessments(users, accounts, assessment);

        // Create the customers last so that account-customer assessments are not automatically generated
        GPSCreateTestData.createCustomers(accounts);
    }

    @isTest
    static void setStatisticsOnAccountAssessment() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, (SELECT Id FROM Primary_Parent__r) FROM Account WHERE Id IN (SELECT Account_AGN__c FROM Account_GPS_Assessment__c)]);
        List<Account_GPS_Assessment__c> accountAssessments = [
            SELECT Id, Account_AGN__c, Completed_Acct_Customer_Assessments_AGN__c, Total_Acct_Customer_Assessments_AGN__c, Total_Acct_Customer_Contribution_AGN__c
            FROM Account_GPS_Assessment__c
        ];

        List<Account_Customer_GPS_Assessment_AGN__c> accountCustomerAssessments = new List<Account_Customer_GPS_Assessment_AGN__c>();
        for(Account_GPS_Assessment__c accountAssessment : accountAssessments) {
            System.assertEquals(null, accountAssessment.Completed_Acct_Customer_Assessments_AGN__c);
            System.assertEquals(null, accountAssessment.Total_Acct_Customer_Assessments_AGN__c);
            System.assertEquals(null, accountAssessment.Total_Acct_Customer_Contribution_AGN__c);

            Account account = accountMap.get(accountAssessment.Account_AGN__c);
            for(Account customer : account.Primary_Parent__r) {
                Account_Customer_GPS_Assessment_AGN__c accountCustomerAssessment = GPSCreateTestData.createAccountCustomerAssessment(UserInfo.getUserId(), accountAssessment.Id, customer.Id, false);
                accountCustomerAssessments.add(accountCustomerAssessment);
            }
        }

        Test.startTest();

        // Verify that the account-assessment's statistic fields are updated after account-customer assessments are inserted
        insert accountCustomerAssessments;
        accountAssessments = [
            SELECT Id, Account_AGN__c, Completed_Acct_Customer_Assessments_AGN__c, Total_Acct_Customer_Assessments_AGN__c, Total_Acct_Customer_Contribution_AGN__c
            FROM Account_GPS_Assessment__c
        ];
        for(Account_GPS_Assessment__c accountAssessment : accountAssessments) {
            System.assertNotEquals(null, accountAssessment.Completed_Acct_Customer_Assessments_AGN__c);
            System.assertNotEquals(null, accountAssessment.Total_Acct_Customer_Assessments_AGN__c);
            System.assertNotEquals(null, accountAssessment.Total_Acct_Customer_Contribution_AGN__c);
        }

        Test.stopTest();
    }

}