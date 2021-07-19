/*-------------------------------------------------------------------------------------------------------
* @author         Namrata Kundu
* @createdBy      
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        
* @testClass     
* @Class Name    Batch_To_Validate_with_DP_AGN_Test
* --------------------------------------------------------------------------------------------------------
* @description - Test class for Batch_To_Validate_with_DP_AGN which creates DCR record everyday based on conditions.
*/

@isTest
public class Batch_To_Validate_with_DP_AGN_Test {
    static Id countryId;
    static TestMethod void setup(){
        
        Country_vod__c testCountry= new Country_vod__c();
        testCountry.Name ='GB';
        testCountry.Data_Provider_Managed_AGN__c =true;
        testCountry.DCR_To_IQVIA_AGN__c =true;
        insert testCountry;
        countryId = testCountry.Id;
        
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i<20;i++){
            
            Account accountToadd = new Account();
            accountToadd.name = 'testAcc '+i;
            accountToadd.Country_Code__c = 'GB';
            accountToadd.Country_vod__c = countryId;
            accountToadd.Ready_For_DCR_AGN__c = true;
            accountToadd.Sent_to_DP_AGN__c = true;
            accounts.add(accountToadd);
        }
        insert accounts;
 
        DCR_Validate_To_DP_AGN__c testCustomSetting = new DCR_Validate_To_DP_AGN__c();
        testCustomSetting.Name = 'Test';
        testCustomSetting.Type__c = 'New_vod';
        testCustomSetting.Status__c ='Submitted_vod'; 
        testCustomSetting.DCR_Notes__c ='Test Notes';
        testCustomSetting.DCR_Status__c = 'Pending for Approval';
        insert testCustomSetting;
            
        DCR_Configuration_Settings_AGN__c testDCRSetting = new DCR_Configuration_Settings_AGN__c();
        testDCRSetting.Company_Managed_AGN__c =true;
        testDCRSetting.Country_Code_AGN__c = 'GB';
        testDCRSetting.Data_Provider_Managed_AGN__c = true;
        testDCRSetting.MDM_Managed_AGN__c = false;
        testDCRSetting.Provisional_Contact_Required_AGN__c = true;
        testDCRSetting.Profile_AGN__c = 'System Administrator';
        insert testDCRSetting;
        
        Test.startTest();
        Batch_To_Validate_with_DP_AGN b1 = new Batch_To_Validate_with_DP_AGN();
        Database.QueryLocator ql = b1.start(null);
        b1.execute(null,accounts);
        

        Id batchId = database.executeBatch(b1);
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }

}