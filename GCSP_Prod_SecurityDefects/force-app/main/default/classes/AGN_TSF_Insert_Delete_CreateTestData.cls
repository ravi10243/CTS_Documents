@isTest
public without sharing class AGN_TSF_Insert_Delete_CreateTestData {
    
    
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

    public static List<Account> createHCPAccount(List<Account> primaryAccounts) {
        List<Account> lstHCP = new List<Account>();
        
        RecordType hcpRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Professional_vod'];
        
        for(Account account : primaryAccounts) {
            for(Integer i = 0; i < 5; i++) {
                Account acc = new Account(
                    FirstName             = 'Name' + i,
                    LastName              = 'Person Account',
                    RecordTypeId = hcpRecordType.Id,	
                    Primary_Parent_vod__c = account.Id,
                    Target__c             = true
                );
                lstHCP.add(acc);
            }
        }

        insert lstHCP;
        return lstHCP;
    }


}