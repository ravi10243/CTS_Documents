/****************************************************************************************************************
@ Class:          AGN_Check_GCSP_Country_Test 
@ Version:        1
@ Author:         Namrata Kundu
@ Purpose:        This class is a Test class for AGN_Check_GCSP_Country which is created to check if the country 
                  in Opportunity is a GCSP country or not. This class is called from "Create SAP Record" button.
-----------------------------------------------------------------------------------------------------------------
****************************************************************************************************************/

@isTest
public class AGN_Check_GCSP_Country_Test {
    
    private static List<AGN_GCSP_Settings__c> GCSPSettingList = new List<AGN_GCSP_Settings__c>();
    private static String GCSPCountry;
    private static String nonGCSPCountry;
    private static String accountId;
    private static String opportunityId;
    private static void dataSetup() {
        
        AGN_GCSP_Settings__c customSettingValue1 = new AGN_GCSP_Settings__c();
        customSettingValue1.Name='IT';
        customSettingValue1.Account_Managed_By__c ='Data';
        customSettingValue1.Community_Base_URL_AGN__c ='testurl';
        customSettingValue1.Okta_Base_URL_AGN__c = 'testOktaUrl';
        
        AGN_GCSP_Settings__c customSettingValue2 = new AGN_GCSP_Settings__c();
        customSettingValue2.Name='TN';
        customSettingValue2.Account_Managed_By__c ='Data';
        customSettingValue2.Community_Base_URL_AGN__c ='testurl';
        customSettingValue2.Okta_Base_URL_AGN__c = 'testOktaUrl';
        
        GCSPSettingList.add(customSettingValue1);
        GCSPSettingList.add(customSettingValue2);
        insert GCSPSettingList;
        GCSPCountry = 'IT';
        nonGCSPCountry ='TN';
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        accountId = testAccount.ID;
        
        Opportunity testOpportunity = new Opportunity();
        testOpportunity.Name = 'Test Opportunity';
        testOpportunity.StageName ='1st Prospect call';
        testOpportunity.CloseDate = Date.newInstance(2021, 12, 9);
        insert testOpportunity;
        opportunityId = testOpportunity.ID;
     }
    
    @isTest 
    private static void testIsGCSPCountry1() {
        dataSetup();
        Test.startTest();
        Boolean checkGCSPCountry = AGN_Check_GCSP_Country.isGCSPCountry(GCSPSettingList.get(0).Name); 
        System.assertEquals(true, checkGCSPCountry);
        Test.stopTest();
   	}
    
   /* @isTest 
    private static void testIsGCSPCountry2() {
        dataSetup();
        Test.startTest();
        Boolean checkGCSPCountry = AGN_Check_GCSP_Country.isGCSPCountry(GCSPSettingList.get(1).Name); 
        System.assertEquals(false, checkGCSPCountry);
        Test.stopTest();
   	}*/
    
    @isTest 
    private static void testcallFlowMethod() {
        dataSetup();
        Test.startTest();
        String flowURL = AGN_Check_GCSP_Country.callFlowMethod(accountId,GCSPCountry,opportunityId); 
        System.assertEquals(false, String.isBlank(flowURL));
        Test.stopTest();
   	}

}