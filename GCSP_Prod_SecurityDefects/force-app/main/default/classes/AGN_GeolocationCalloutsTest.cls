@isTest
public class AGN_GeolocationCalloutsTest {
    
    @isTest
    public static void testTrigger() {
        Account acct = new Account(Name = 'CoolNet Test Account');
        insert acct;
        
        AGN_Settings__c testCustomSettings = new AGN_Settings__c();
        testCustomSettings.GooglePrivateKey_AGN__c = 'a3--l2CjL5iGR6tOOnQrMOM5Ics=';
        testCustomSettings.GoogleClientID_AGN__c = 'gme-allerganinc';
        insert testCustomSettings;
        
        Locator_Listing_AGN__c locator = new Locator_Listing_AGN__c(Account_AGN__c = acct.Id,Street_AGN__c = '1851 Grant Avenue',City_AGN__c = 'Winnipeg',State_Providence_Region_AGN__c = 'Manitoba',Zip_Code_AGN__c = 'R3N 1Z2', Country_AGN__c = 'Canada', Physician_Name_AGN__c = 'Test Physician 1, Test Physician 2');
        
        Test.startTest();
        insert locator;
        Test.stopTest();
        
        locator = [SELECT GeoLocation_AGN__Latitude__s,GeoLocation_AGN__Longitude__s FROM Locator_Listing_AGN__c WHERE Id = :locator.Id];
        System.assertEquals(49,locator.GeoLocation_AGN__Latitude__s);
        System.assertEquals(-97,locator.GeoLocation_AGN__Longitude__s);
    }
}