@isTest
private class AccountGPSAssessmentTest {

    @testSetup
    static void testSetup() {
        GPSCreateTestData.createAssessment();
        List<Account> accounts = GPSCreateTestData.createAccounts();
        GPSCreateTestData.createCustomers(accounts);
    }

    @isTest
    static void setAccountAssessmentUniqueId() {
        GPS_Assessment__c assessment = [SELECT Id FROM GPS_Assessment__c LIMIT 1];
        List<Account> accounts = [SELECT Id FROM Account LIMIT 5];
        List<User> users = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        List<Account_GPS_Assessment__c> accountAssessments = GPSCreateTestData.createAccountAssessments(users, accounts, assessment);

        Test.startTest();

        accountAssessments = [SELECT Id, Account_AGN__c, GPS_Assessment_AGN__c, OwnerId, Unique_Id_AGN__c FROM Account_GPS_Assessment__c WHERE Id IN :accountAssessments];
        for(Account_GPS_Assessment__c accountAssessment : accountAssessments) {
            String expectedUniqueId = '' + accountAssessment.Account_AGN__c + accountAssessment.GPS_Assessment_AGN__c + accountAssessment.OwnerId;
            System.assertEquals(expectedUniqueId, accountAssessment.Unique_ID_AGN__c);
        }

        Test.stopTest();
    }

    @isTest
    static void createAccountCustomerAssessments() {
        GPS_Assessment__c assessment = [SELECT Id, Assessment_Type_AGN__c FROM GPS_Assessment__c WHERE Assessment_Type_AGN__c = 'Accounts' LIMIT 1];
        List<User> users = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<Account> accounts = [SELECT Id FROM Account WHERE IsPersonAccount = false LIMIT 5];
        List<Account> customers = [SELECT Id FROM Account WHERE IsPersonAccount = true AND Primary_Parent_vod__c IN :accounts LIMIT 5];

        Test.startTest();

        // Verify account-customer assessments are automatically created when account-assessments are created
        List<Account_GPS_Assessment__c> accountAssessments = GPSCreateTestData.createAccountAssessments(users, accounts, assessment);
        List<Account_Customer_GPS_Assessment_AGN__c> accountCustomerAssessments = [
            SELECT Id
            FROM Account_Customer_GPS_Assessment_AGN__c
            WHERE Customer_AGN__c IN :customers
        ];
        System.assert(accountCustomerAssessments.isEmpty() == false);

        Test.stopTest();
    }

}