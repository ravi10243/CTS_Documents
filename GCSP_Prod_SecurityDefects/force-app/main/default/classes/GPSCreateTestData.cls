@isTest
public without sharing class GPSCreateTestData {

    public static List<user> createUsers(Id managerId) {
        Id profileId = Userinfo.getProfileId();
        List<User> lstUser= new List<User>();
        for(Integer i = 0; i < 5; i++) {
            User user = new User(
                Alias             = 'standt' + i,
                Email             = 'Manager' + i + '@testorg.com',
                EmailEncodingKey  = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LastName          = 'LastName' + i,
                LocaleSidKey      = 'en_US',
                ManagerId         = managerId,
                ProfileId         = profileId,
                TimeZoneSidKey    = 'America/Los_Angeles',
                UserName          = 'LineManager' + i + '@testorg.com'
            );

            lstUser.add(user);
        }

        insert lstUser;

        Id gpsSalesRepPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'GPS_Assessment_Tool_Sales_Rep'].Id;
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        for(User user : lstUser) {
            PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
                AssigneeId      = user.Id,
                PermissionSetId = gpsSalesRepPermissionSet
            );
            permissionSetAssignments.add(permissionSetAssignment);
        }
        insert permissionSetAssignments;

        return lstUser;
    }

    public static List<Account> createAccounts() {
        RecordType hospitalRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Hospital_vod'];
        List<Account> lstAccount = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            Account acc = new Account(
                Name         = 'Name' + i,
                RecordTypeId = hospitalRecordType.Id,
                Target__c    = true
            );
            lstAccount.add(acc);
        }

        insert lstAccount;
        return lstAccount;
    }

    public static List<Account> createCustomers(List<Account> primaryAccounts) {
        List<Account> lstCustomer = new List<Account>();
        
        //GPS Assessment: End: Create Customer test records
        RecordType hcpRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Professional_vod'];
        
        for(Account account : primaryAccounts) {
            for(Integer i = 0; i < 5; i++) {
                Account acc = new Account(
                    FirstName             = 'Name' + i,
                    LastName              = 'Person Account',
                    RecordTypeId = hcpRecordType.Id,			//GPS Assessment
                    Primary_Parent_vod__c = account.Id,
                    Target__c             = true
                );
                lstCustomer.add(acc);
            }
        }

        insert lstCustomer;
        return lstCustomer;
    }

    public static GPS_Assessment__c createAssessment() {
        return createAssessment(true);
    }

    public static GPS_Assessment__c createAssessment(Boolean insertRecord) {
        GPS_Assessment__c assessment = new GPS_Assessment__c(
            Assessment_Type_AGN__c = 'Accounts',
            Name                   = 'Assessment1'
        );

        if(insertRecord) insert assessment;
        return assessment;
    }

    public static List<Account_GPS_Assessment__c> createAccountAssessments(List<User> lstUser, List<Account> lstAcc, GPS_Assessment__c assessment)   {
        List<Account_GPS_Assessment__c> lstAcctAss = new List<Account_GPS_Assessment__c>();
        for(User objUser : lstUser) {
            for(Account acc : lstAcc) {
                Account_GPS_Assessment__c  assessmentAccount = new Account_GPS_Assessment__c(
                    Account_AGN__c        = acc.Id,
                    GPS_Assessment_AGN__c = assessment.Id,
                    OwnerId               = objUser.Id
                );
                lstAcctAss.add(assessmentAccount);
            }
        }
        insert lstAcctAss;
        return lstAcctAss;
    }

    public static Account_Customer_GPS_Assessment_AGN__c createAccountCustomerAssessment(Id ownerId, Id assessmentAccountId, Id customerId) {
        return createAccountCustomerAssessment(ownerId, assessmentAccountId, customerId, true);
    }

    public static Account_Customer_GPS_Assessment_AGN__c createAccountCustomerAssessment(Id ownerId, Id assessmentAccountId, Id customerId, Boolean insertRecord) {
        Account_Customer_GPS_Assessment_AGN__c accountCustomerAssessment = new Account_Customer_GPS_Assessment_AGN__c(
            Account_GPS_Assessment_AGN__c = assessmentAccountId,
            Customer_AGN__c               = customerId,
            Customer_Contribution_AGN__c  = 50,
            OwnerId                       = ownerId
        );
        if(insertRecord) insert accountCustomerAssessment;
        return accountCustomerAssessment;
    }

    public static List<Product_vod__c> createProducts() {
        List<Product_vod__c> lstProd= new List<Product_vod__c>();
        for(Integer i=0; i < 5; i++) {
            Product_vod__c prod = new Product_vod__c(
                Name = 'Product' + i
            );
            lstProd.add(prod);
        }
        insert lstProd;
        return lstProd;
    }

    public static List<Product_Metrics_vod__c> createProductMetrics(List<Product_vod__c> lstProd, List<Account> lstAcc) {
        List<Product_Metrics_vod__c> lstProductMetrics= new List<Product_Metrics_vod__c>();
        for(Product_vod__c prod : lstProd) {
            for(Account acc : lstAcc) {
                Product_Metrics_vod__c prodMet = new Product_Metrics_vod__c(
                    Account_vod__c      = acc.Id,
                    Detail_Group_vod__c = prod.Id
                );
                lstProductMetrics.add(prodMet);
            }
        }
        insert lstProductMetrics;
        return lstProductMetrics;
    }

    public static List<My_Setup_Products_vod__c> createMySetupProducts(List<Product_vod__c> lstProd,User user) {
        List<My_Setup_Products_vod__c> lstMysetup= new List<My_Setup_Products_vod__c>();
        for(Integer i = 0; i < lstProd.size(); i++) {
            Product_vod__c objProd = lstProd[i];

            My_Setup_Products_vod__c SetupProd = new My_Setup_Products_vod__c(
                Name           = 'SetupProduct ' + i,
                OwnerId        = user.Id,
                Product_vod__c = objProd.Id
            );
            lstMysetup.add(SetupProd);
        }

        insert lstMysetup;
        return lstMysetup;
    }

    public static List<GPS_Assessment_Product_AGN__c> createAssessmentProducts(List<Product_vod__c> lstProd, GPS_Assessment__c assessment) {
        return createAssessmentProducts(lstProd, assessment, true);
    }

    public static List<GPS_Assessment_Product_AGN__c> createAssessmentProducts(List<Product_vod__c> lstProd, GPS_Assessment__c assessment, Boolean upsertRecords) {
        List<GPS_Assessment_Product_AGN__c> lstAssProd= new List<GPS_Assessment_Product_AGN__c>();
        for(Product_vod__c objProd : lstProd) {
            GPS_Assessment_Product_AGN__c objAssProd = new GPS_Assessment_Product_AGN__c(
                GPS_Assessment_AGN__c = assessment.Id,
                Product_AGN__c        = objProd.Id,
                Unique_Id_AGN__c      = '' + assessment.Id + objProd.Id
            );
            lstAssProd.add(objAssProd);
        }

        if(upsertRecords) upsert lstAssProd Unique_Id_AGN__c;
        return lstAssProd;
    }

}