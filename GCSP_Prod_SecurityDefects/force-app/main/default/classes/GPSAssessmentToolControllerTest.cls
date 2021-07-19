@isTest
private class GPSAssessmentToolControllerTest {

    @testSetup
    static void testSetup() {
        User otherUser = [SELECT Id FROM User WHERE IsActive = true AND Id != :UserInfo.getUserId() LIMIT 1];
        System.runAs(otherUser) {
            upsert new AGN_Country_Code_List__c(
                Country_Code_List__c = '-',
                Name                 = 'Test'
            );
        }
        List<AGN_Country_Code_List__c> countryCodeListzz = AGN_Country_Code_List__c.getAll().values();
        string cntryCodeListStr = countryCodeListzz[0].Country_Code_List__c;

        List<Account> accounts = GPSCreateTestData.createAccounts();
        List<Account> customers = GPSCreateTestData.createCustomers(accounts);

        List<Product_vod__c> products = GPSCreateTestData.createProducts();
        GPS_Assessment__c assessment = GPSCreateTestData.createAssessment();
        List<GPS_Assessment_Product_AGN__c> assessmentProducts = GPSCreateTestData.createAssessmentProducts(products, assessment);
    }

    @isTest
    static void GPSAssessmentToolControllerTestMethods() {
        Profile p = [SELECT Id FROM Profile WHERE Name='AGN Management Sales - Salesforce'];

        User manager = new User(
            Alias             = 'standt',
            Email             = 'Manager@testorg.com',
            LanguageLocaleKey = 'en_US',
            LastName          = 'LastName',
            ProfileId         = p.Id,
            UserName          = 'LineManager@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            LocaleSidKey      = 'en_US',
            TimeZoneSidKey    = 'America/Los_Angeles'
        );
        insert manager;

        List<User> lstUser = GPSCreateTestData.createUsers(manager.Id);
        //User salesRep = [SELECT Id FROM User WHERE IsActive = true AND Id IN (SELECT UserId FROM UserTerritory) LIMIT 1];
        User salesRep = lstUser[0];

        System.runas(salesRep) {
            upsert new AGN_Country_Code_List__c(
                Country_Code_List__c = '-',
                Name                 = 'Test'
            );
            List<Product_vod__c> products = [SELECT Id FROM Product_vod__c];
            List<Account> accounts = [SELECT Id, Name, Primary_Parent_vod__c FROM Account WHERE IsPersonAccount = false];
            List<Account> customers = [SELECT Id, Name, Primary_Parent_vod__c FROM Account WHERE IsPersonAccount = true];
            //GPSCreateTestData.createProductMetrics(products, accounts);
            //GPSCreateTestData.createProductMetrics(products, customers);

            GPS_Assessment__c objAss = GPSCreateTestData.createAssessment();

            List<Product_vod__c> lstProd = GPSCreateTestData.createProducts();

            List<My_Setup_Products_vod__c> lstMysetup = GPSCreateTestData.createMySetupProducts(lstProd,salesRep);

            List<GPS_Assessment_Product_AGN__c> lstAssProd = GPSCreateTestData.createAssessmentProducts(lstProd,objAss);

            List<Account> lstAccount = GPSCreateTestData.createAccounts();

            //List<Product_Metrics_vod__c> lstProdMetrics = GPSCreateTestData.createProductMetrics(lstProd,lstAccount);

            List<Account_GPS_Assessment__c> lstAcctAss = GPSCreateTestData.createAccountAssessments(lstUser,lstAccount,objAss);

            Id customerId = [SELECT Id FROM Account LIMIT 1].Id;
            Account_Customer_GPS_Assessment_AGN__c objAcctCust = GPSCreateTestData.createAccountCustomerAssessment(lstAcctAss[0].OwnerId, lstAcctAss[0].Id, customerId);

            Test.startTest();

            String fileData = 'ACCOUNTID,USERID,\n';
            String strAccId = '';
            List<Id> lstAccId = new List<Id>();
            for(Account objAcc : lstAccount) {
                lstAccId.add(objAcc.Id);
                fileData = fileData + objAcc.Id + ',' + salesRep.Id + ',\n';
                if(objAcc!=null) strAccId = strAccId + objAcc.Id + ',';
            }
            GPSAssessmentToolController.AccountCustomerAssessmentWrapper wrap = GPSAssessmentToolController.getAssessmentAccountCustomerRecords(lstAcctAss[0].Id, lstAcctAss[0].OwnerId);
            GPSAssessmentToolController.upsertAccountCustomerAssessment(JSON.serialize(wrap));
//System.debug('lstAcctAss');
//System.assert(false, JSON.serialize(lstAcctAss));
            //GPSAssessmentToolController.getCustomerRecords(lstAcctAss[0].Id);

            GPSAssessmentToolController.createAccountCustomerRecord(salesRep.Id,lstAcctAss[0].Id, lstAccId);

            List<GPSAssessmentToolController.wrapperClass> lstWrapper = GPSAssessmentToolController.getDirectReports(manager.Id, 1, 2);
            GPSAssessmentToolController.getTotal(salesRep.Id);

            GPSAssessmentToolController.getProductCatalog(objAss.Id,'123');

            List<Id> lstProdId=new List<Id>();
            for(Product_vod__c objProd : lstProd) {
                lstProdId.add(objProd.Id);
            }
            GPSAssessmentToolController.createAssessmentProducts(objAss.Id,lstProdId);


            GPSAssessmentToolController.createAccountAssessmentRecordsForAccountIds(objAss.Id,salesRep.Id,lstAccId);

            List<Id> lstUserId=new List<Id>();
            lstUserId.add(salesRep.Id);
            GPSAssessmentToolController.createAccountAssessmentRecordsForUserIds(objAss.Id,lstUserId);

            Blob Data = Blob.valueOf(fileData);
            String encodedData=EncodingUtil.base64Encode(Data);
            String urlEncodedData= EncodingUtil.urlEncode(encodedData,'UTF-8');
            GPSAssessmentToolController.createAccountAssessmentRecordsForBulkUpload(objAss.Id,'',urlEncodedData,'','');

            GPSAssessmentToolController.getCurrentUser();

            GPSAssessmentToolController.getUsersToAdd(objAss.Id);

            GPSAssessmentToolController.getGPSSettings();

            List<GPS_Assessment__c> lstGPSAss=new List<GPS_Assessment__c>();
            // lstGPSAss=GPSAssessmentToolController.getGPSAssessments();

            // GPSAssessmentToolController.getAccountsToAdd(objAss.Id,'123',salesRep.Id);
            //List<Account_GPS_Assessment__c> lstAcctAss1=new List<Account_GPS_Assessment__c>();
            //lstAcctAss1.add(lstAcctAss);
            // GPSAssessmentToolController.saveAccountGPSAssessments(lstAcctAss1);
            GPSAssessmentToolController.deleteAccountGPSAssessment(lstAcctAss[0].Id);
            lstAcctAss=[select Id from Account_GPS_Assessment__c];

            delete lstAcctAss;


            GPSAssessmentToolController.createAccountAssessments(objAss.Id,strAccId.trim());

            GPSAssessmentToolController.getGPSAssessment(objAss.Id);
            GPSAssessmentToolController.getGPSAssessments('Name', 1, 10, true);

            GPSAssessmentToolController.getAccountsToAdd(objAss.Id,'123', salesRep.Id, true);

            // GPSAssessmentToolController.getGPSAssessmentProductIds(objAss.Id);

            GPSAssessmentToolController.getGPSAssessmentProducts(objAss.Id);

            GPSAssessmentToolController.getGPSAssessmentsForListView(salesRep.Id, 'Name', 1, 50, true);

            /*
            GPSAssessmentToolController.getAccountGPSAssessments(objAss.Id, UserInfo.getUserId(), false, null, 1, 25, true);
            GPSAssessmentToolController.getAccountGPSAssessments(objAss.Id,salesRep.Id, null, 'Name', 1, 25, true);
			*/
            GPSAssessmentToolController.getAccountGPSAssessmentStatsByOwner(objAss.Id, 'Owner.Name', 1, 10, true);

            //GPS Assessment: Start
            List<Account_GPS_Assessment__c> lstAccAssmnt = GPSAssessmentToolController.getAccountGPSAssessments(objAss.Id, UserInfo.getUserId(), false, null, 1, 25, true,'');
            GPSAssessmentToolController.saveAccountGPSAssessments(lstAccAssmnt, false, null, 1, 25, true,'');
            GPSAssessmentToolController.getCustomerRecords(lstAccAssmnt[0].Id);
            List<String> buPlValues = GPSAssessmentToolController.getPiklistValues();
            GPSAssessmentToolController.saveGPSAssessment(objAss, buPlValues);
            GPSAssessmentToolController.fetchAccount('');
            lstAccAssmnt[0].Stakeholder_AGN__c = true;
            update lstAccAssmnt[0];
            objAss.Display_KOL_Capture_AGN__c = true;
            update objAss;
            GPSAssessmentToolController.exportGPSAssessment(objAss.Id);
            objAss.Assessment_Type_AGN__c = 'Customers';
            update objAss;
            GPSAssessmentToolController.exportGPSAssessment(objAss.Id);
			//GPS Assessment: End
            
            //  List<Account_GPS_Assessment__c> lstAcctAss=new List<Account_GPS_Assessment__c>();
            lstAcctAss=[select Id from Account_GPS_Assessment__c];
            delete lstAcctAss;

            lstAcctAss = GPSCreateTestData.createAccountAssessments(lstUser,lstAccount,objAss);

            GPSAssessmentToolController.cloneGPSAssessment(objAss.Id);

            GPSAssessmentToolController.deleteGPSAssessmentProduct(lstAssProd[0].Id);
            Test.stopTest();
        }

    }

    @isTest
    static void getGPSAssessmentsTotalCount() {
        Integer actualCount = [SELECT COUNT() FROM GPS_Assessment__c];
        System.assertEquals(actualCount, GPSAssessmentToolController.getGPSAssessmentsTotalCount());
    }

    @isTest
    static void getAccountGPSAssessmentStatsByOwnerTotalCount() {
        GPS_Assessment__c assessment = [SELECT Id FROM GPS_Assessment__c LIMIT 1];
        List<Account> accounts = [SELECT Id FROM Account WHERE IsPersonAccount = false];
        GPSCreateTestData.createAccountAssessments(new List<User>{new User(Id = UserInfo.getUserId())}, accounts, assessment);

        AggregateResult result = [SELECT COUNT_DISTINCT(OwnerId) cnt FROM Account_GPS_Assessment__c WHERE GPS_Assessment_AGN__c = :assessment.Id];
        Integer actualCount = (Integer)result.get('cnt');

        System.assertEquals(actualCount, GPSAssessmentToolController.getAccountGPSAssessmentStatsByOwnerTotalCount(assessment.Id));
    }

    @isTest
    static void getCurrentUser() {
        User returnedUser = GPSAssessmentToolController.getCurrentUser();
        System.assertEquals(UserInfo.getUserId(), returnedUser.Id);
    }

    @isTest
    static void getUsersToAdd() {
        GPS_Assessment__c assessment = [SELECT Id FROM GPS_Assessment__c LIMIT 1];
        // First verify that there are not any users returned before we have setup the necessary data
        List<User> initialReturnedUsers = GPSAssessmentToolController.getUsersToAdd(assessment.Id);
        System.assertEquals(0, initialReturnedUsers.size());

        List<Product_vod__c> products = [SELECT Id FROM Product_vod__c];

        Profile p = [SELECT Id FROM Profile WHERE Name='AGN Management Sales - Salesforce'];

        User manager = new User(
            Alias             = 'standt',
            Email             = 'Manager@testorg.com',
            LanguageLocaleKey = 'en_US',
            LastName          = 'LastName',
            ProfileId         = p.Id,
            UserName          = 'LineManager@testorg.com',
            EmailEncodingKey  = 'UTF-8',
            LocaleSidKey      = 'en_US',
            TimeZoneSidKey    = 'America/Los_Angeles'
        );
        insert manager;

        List<User> lstUser = GPSCreateTestData.createUsers(manager.Id);
        User salesRep = lstUser[0];

        System.runas(salesRep) {
            List<User> returnedUsers = GPSAssessmentToolController.getUsersToAdd(assessment.Id);
        }
    }

    @isTest
    static void deleteAccountCustomerGPSAssessment() {
        GPS_Assessment__c assessment = [SELECT Id FROM GPS_Assessment__c LIMIT 1];
        Account customer = [SELECT Id, Primary_Parent_vod__c FROM Account WHERE IsPersonAccount = true LIMIT 1];
        Account account = [SELECT Id, OwnerId FROM Account WHERE Id = :customer.Primary_Parent_vod__c];

        GPSCreateTestData.createAccountAssessments(new List<User>{new User(Id=UserInfo.getUserId())}, new List<Account>{account}, assessment);
        Account_Customer_GPS_Assessment_AGN__c accountCustomerAssessment = [SELECT Id FROM Account_Customer_GPS_Assessment_AGN__c LIMIT 1];

        Test.startTest();

        GPSAssessmentToolController.deleteAccountCustomerGPSAssessment(accountCustomerAssessment.Id);
        accountCustomerAssessment = [SELECT Id, IsDeleted FROM Account_Customer_GPS_Assessment_AGN__c WHERE Id = :accountCustomerAssessment.Id ALL ROWS];
        System.assert(accountCustomerAssessment.IsDeleted);

        Test.stopTest();
    }

}