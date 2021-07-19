@isTest
public class AGN_TSF_Insert_Delete_Test {

    @isTest
    static void setup() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'SMB Primary Care Sales - Platform'];

        User salesRepsUser = new User(
            Alias             = 'standt',
            Email             = 'resps@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName          = 'LastName',
            LocaleSidKey      = 'en_US',
            ProfileId         =  profile.Id,
            TimeZoneSidKey    = 'America/Los_Angeles',
            UserName          = 'SalesRepsUser@testorg.com'
        );
        
         insert salesRepsUser;
         System.runAs(salesRepsUser) {
      
         AGN_Offline_Account_Load__mdt acTL = [SELECT AGN_Country_Code__c FROM AGN_Offline_Account_Load__mdt];
         RecordType hospitalRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Hospital_vod'];
          
         Test.startTest(); 
         List<Account> lstAccount = AGN_TSF_Insert_Delete_CreateTestData.createAccounts(); 
         List<Account> lstHCP = AGN_TSF_Insert_Delete_CreateTestData.createHCPAccount(lstAccount);
         List<Territory2Model> terr2 = [SELECT Id,Name FROM Territory2Model LIMIT 1];
         List<Territory2Type> terrtype = [SELECT Id FROM Territory2Type LIMIT 1];
          
         Territory2 terr = new Territory2(Name = 'GB-PS-SC-NS-01-05',Country_Code_AGN__c=acTL.AGN_Country_Code__c ,Territory2ModelId= terr2[0].Id,DeveloperName='AN01',Territory2TypeId= terrtype[0].Id);
            insert terr;
          
         Territory2 terrtsf = new Territory2(Name = 'GB-PS-ECSC-GT-02-06',Country_Code_AGN__c=acTL.AGN_Country_Code__c,Territory2ModelId= terr2[0].Id,DeveloperName='AN02',Territory2TypeId= terrtype[0].Id);
            insert terrtsf;
          
         Account_Territory_Loader_vod__c atl = new Account_Territory_Loader_vod__c(
           Account_vod__c = lstHCP[0].Id,
           Territory_vod__c = 'GB-PS-SC-NS-01-05');
           insert atl;
         
          
        TSF_vod__c tsf = new TSF_vod__c(Account_vod__c=lstHCP[0].Id,Target_Manager_SMB__c=True,
                                       Territory_vod__c='GB-PS-ECSC-GT-02-06',Name='GB-PS-ECSC-GT-02-06');
        insert tsf;

        AGN_TSF_Insert uca = new AGN_TSF_Insert();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
    }
   }
}