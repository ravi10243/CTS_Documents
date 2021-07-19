@isTest
public class GPSDataImportTest {

    @isTest
    public static void dataImport()  {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'AGN Management Sales - Salesforce'];

        User lineManagerUser = new User(
            Alias             = 'standt',
            Email             = 'Manager@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName          = 'LastName',
            LocaleSidKey      = 'en_US',
            ProfileId         =  profile.Id,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = 'LineManager@testorg.com'
        );

        insert lineManagerUser;

        //GPS Assessment: Start
        User lineManagerUser2 = new User(
            Alias             = 'standt2',
            Email             = 'Manager2@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName          = 'LastName',
            LocaleSidKey      = 'en_US',
            ProfileId         =  profile.Id,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = 'LineManager2@testorg.com'
        );

        insert lineManagerUser2;
        //GPS Assessment: End
        
        System.runAs(lineManagerUser) {
            GPS_Assessment__c objAss = GPSCreateTestData.createAssessment();

            List<Product_vod__c> lstProd = GPSCreateTestData.createProducts();

            Test.startTest();

            List<My_Setup_Products_vod__c> lstMysetup = GPSCreateTestData.createMySetupProducts(lstProd, lineManagerUser);

            List<GPS_Assessment_Product_AGN__c> lstAssProd = GPSCreateTestData.createAssessmentProducts(lstProd, objAss);

            List<Account> lstAccount = GPSCreateTestData.createAccounts();

            List<Account_GPS_Assessment__c> lstAccAss = new List<Account_GPS_Assessment__c>();

            for(Account objAcc : lstAccount) {
                for(My_Setup_Products_vod__c obj : lstMysetup) {
                    Account_GPS_Assessment__c objAccAss = new Account_GPS_Assessment__c(
                        Account_AGN__c        = objAcc.Id,
                        GPS_Assessment_AGN__c = objAss.Id,
                        OwnerId               = obj.OwnerId
                    );
                    lstAccAss.add(objAccAss);
                }
            }

            //GPS Assessment: Start
            
            Account_GPS_Assessment__c objAccAss = new Account_GPS_Assessment__c(
                        Account_AGN__c        = lstAccount[0].Id,
                        GPS_Assessment_AGN__c = objAss.Id,
                        OwnerId               = lineManagerUser2.Id
                    );
            lstAccAss.add(objAccAss);
            
            
            List<Account> lstCust = GPSCreateTestData.createCustomers(lstAccount);
            List<Territory2Model> terr2 = [SELECT Id,Name FROM Territory2Model LIMIT 1];
            List<Territory2Type> terrtype = [SELECT Id FROM Territory2Type LIMIT 1];
            Account_Territory_Loader_vod__c atl = new Account_Territory_Loader_vod__c(
                Account_vod__c = lstCust[0].Id,
            	Territory_vod__c = 'GB-PS-SC-NS-01-05');
            insert atl;
            Territory2 terr = new Territory2(Name = 'GB-PS-SC-NS-01-05',Territory2ModelId= terr2[0].Id,DeveloperName='AN01',Territory2TypeId= terrtype[0].Id);
            insert terr;
            UserTerritory2Association uterr = new UserTerritory2Association(UserId = lineManagerUser.Id, Territory2Id = terr.Id);
            //insert uterr;
            System.debug('DataImportTestUserTerr: '+uterr);
            //GPS Assessment: End
            
            GPSDataImport obj = new GPSDataImport(lstAccAss, objAss.Id);
            DataBase.executeBatch(obj);

            Test.stopTest();
        }
    }



}