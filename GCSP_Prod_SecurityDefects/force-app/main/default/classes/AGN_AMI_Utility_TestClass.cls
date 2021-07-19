@isTest
public class AGN_AMI_Utility_TestClass 
{
    static Account acc;
    static Case caseRecord;
    static Allergan_Customer_Registration_AGN__c acr;
    static Allergan_Customer_Address_AGN__c aca;
    public static void dataCreation()
    {
        User u;
        AMI_SPecality_AGN__c spcl;
        Country_vod__c counVod;
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs (AdminUser) {
            counVod = new Country_vod__c(AGN_Country_Name__c = 'United Kingdom', Country_Name_vod__c = 'United Kingdom', Alpha_2_Code_vod__c = 'GB', Name = 'GB');
            insert counVod;
            
            spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id,Allergan_Speciality_Name_AGN__c = 'Aesthetic Medicine');
            insert spcl;
            Specialty_AGN__c allerganSpec = new Specialty_AGN__c(name='Aesthetic Medicine', External_ID_AGN__c = '12345');
            insert allerganSpec;
            Id recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', firstname = 'Account', PersonEmail = 'account.test@example.com',
                              Country_code__c = 'GB', Country_vod__c =counVod.Id, RecordTypeId = recordId,
                              Language_vod__c = 'en_US');
            insert acc;
            
            AMI_User_Settings_AGN__c AUS = new AMI_User_Settings_AGN__c(Name = 'GB', User_Locale__c='en_GB',
                                                                        CR_Record_Owner__c='amiadmingb@allergan.com',
                                                                        Username_Suffix__c='ami', User_Profile__c = 'AMI Customer Community', 
                                                                        User_Language__c = 'en_GB', User_Timezone__c = 'Europe/London');
            insert AUS;
            
            Id caseRecordTypId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Support_Request_AMI_Customer_Registration_AGN' LIMIT 1][0].Id;
            Id regRecordTypId =[SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'New_AMI_AGN'][0].Id; 
            Id addRecordTypId =[SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New_AMI_AGN'][0].Id;
            caseRecord = new Case(Status = 'New', Origin = 'Web', RecordTypeId =caseRecordTypId,Country_Code_AGN__c='GB');
            insert caseRecord;
            acr = new Allergan_Customer_Registration_AGN__c(Case_AGN__c= caseRecord.Id, Online_Registration_AGN__c=false,Country_Code_AGN__c='GB',
                                                            Country_AGN__c=counVod.Id, AMI_Registration_AGN__c=true,Use_Existing_Account_AGN__c= True,
                                                            Account_AGN__c=null, RecordTypeId=regRecordTypId,Specialty_1_AGN__c=allerganSpec.id,
                                                            Last_Name_AGN__c='test', first_Name_AGN__c = 'Account',Email_AGN__c = 'account.test@example.com', 
                                                            Language_AGN__c='en_US');
            insert acr;    
            aca = new Allergan_Customer_Address_AGN__c(Country_Lookup_AGN__c=counVod.Id ,Sold_To_AGN__c = true, Country_AGN__c=counVod.Id,Company_Name_AGN__c='world',Parent_AGN__c=acr.id,RecordTypeId=addRecordTypId);
            insert aca;
        }
    }
    @isTest
    public static void testHomeController()
    {
        Test.startTest();
        dataCreation();
        
        //AGN_AMI_Utility_class.enableAMIUser(acc.Id);
        AGN_AMI_Utility_class.checkDuplicate('Test','Account','account.test@example.com');
        AGN_AMI_Utility_class.saveProcessedRecord(caseRecord.Id,acr.Id,'account.test@example.com');
        AGN_AMI_Utility_class.rejectRecord(caseRecord.Id,acr.Id);
        
        Test.stopTest();
    }
}