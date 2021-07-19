@isTest
public class AGN_AMI_CustomerRegistrationUtils_Test {
    static Allergan_Customer_Registration_AGN__c aaCRAC;
    static Allergan_Customer_Registration_AGN__c aaCRAC1;
    static Allergan_Customer_Address_AGN__c acaac;
    static Allergan_Customer_Address_AGN__c acaac1;
    static Address_vod__c addVod;
    public static User uInfo{get{return [SELECT Id,Name,Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];}} 
    public static final String RECORD_OWNER = (String)AMI_User_Settings_AGN__c.getValues(uInfo.Country_Code__c).get('CR_Record_Owner__c');
    static AGN_CR_CountryRegionMapping__mdt regionValue = [SELECT RegionCode__c, Country_Code__c FROM AGN_CR_CountryRegionMapping__mdt LIMIT 1];
    static String OWNER_ID = [SELECT ID FROM User where Username =: RECORD_OWNER LIMIT 1].Id;
    static Country_vod__c counVod = [SELECT Id, Name FROM Country_vod__c Where Name = 'GB'];
   public static User dataCreation()
    {
        User u;
        Account acc;
        AMI_SPecality_AGN__c spcl;
        
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Id ConId;
        Id recordId;
        System.runAs (AdminUser) {
                     
            spcl = new AMI_SPecality_AGN__c(Country_AGN__c = counVod.Id);
            insert spcl;
            
            recordId = [Select Id from RecordType where Name = 'Professional_vod' Limit 1].Id;
            acc = new Account(lastname = 'Test', Country_code__c = 'GB', Country_vod__c ='a3L5E000000Aupb', AMI_Specialty_AGN__c = spcl.id, RecordTypeId = recordId);
            insert acc;
            ConId = [Select PersonContactId,Id from Account where id =: acc.Id Limit 1].PersonContactId;
            Id profileId = [Select Id from Profile where Name = 'AMI Customer Community' Limit 1].Id;
            u = new User(alias = 'standt', email='standarduser@allergan.example.com', 
                         emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_GB', 
                         localesidkey='en_GB', profileid = profileId, 
                         timezonesidkey='Europe/London', Country_code__c = 'GB', username='standarduser@allergan.example.com',
                         contactId = ConId);
            Insert u;
        }
        Case caseObj = new Case(ContactId = ConId, AccountId = acc.Id, Status = 'New', Origin = 'Email');
        insert caseObj;
        caseObj = [select id, casenumber from case where id = : caseObj.id];
        aaCRAC = new Allergan_Customer_Registration_AGN__c(Case_AGN__c= caseObj.Id, Salutation_AGN__c='Mr.', First_Name_AGN__c = 'Tarasankar', Last_Name_AGN__c = 'Panda', Email_AGN__c = 'tarasankar.panda@cognizant.com',
                                                          Phone_AGN__c='9073926242', Country_Code_AGN__c='GB', OwnerId = OWNER_ID);
        insert aaCRAC;
        
        acaac = new Allergan_Customer_Address_AGN__c(Country_Lookup_AGN__c=counVod.Id, Parent_AGN__c = aaCRAC.Id);
        insert acaac;
        
        aaCRAC1 = new Allergan_Customer_Registration_AGN__c(Case_AGN__c= caseObj.Id,Salutation_AGN__c='Mr.', First_Name_AGN__c = 'Tarasankar', Last_Name_AGN__c = 'Panda',
                                                           Email_AGN__c = 'tarasankar.panda@cognizant.com',
                                                          Phone_AGN__c='9073926242', Country_Code_AGN__c='GB', OwnerId = OWNER_ID);
        
        acaac1 = new Allergan_Customer_Address_AGN__c(Country_Lookup_AGN__c=counVod.Id , Parent_AGN__c = aaCRAC1.Id);
        
        addVod= new Address_vod__c(Account_vod__c=acc.Id, Country_vod__c=counVod.Id);
        insert addVod;
       return u;
    }
    @isTest(SeeAllData=true)
    public static void testCustomerRegisPageController()
    {
        Test.startTest();
       User TestUser=dataCreation();
        System.runAs(TestUser)
        {
            
            
    //    List<Customer_Type_Configuration_AMI_AGN__c> configList = new List<Customer_Type_Configuration_AMI_AGN__c>();
    //    Customer_Type_Configuration_AMI_AGN__c cust= new Customer_Type_Configuration_AMI_AGN__c(Account_Record_Type_AGN__c = 'Hospital_vod', Customer_Country_AGN__c=counVod.Id);
    //    Customer_Type_Configuration_AMI_AGN__c cust1= new Customer_Type_Configuration_AMI_AGN__c(Account_Record_Type_AGN__c = 'Practice_vod', Customer_Country_AGN__c=counVod.Id);
    //    Customer_Type_Configuration_AMI_AGN__c cust2= new Customer_Type_Configuration_AMI_AGN__c(Account_Record_Type_AGN__c = 'Wholesaler_vod', Customer_Country_AGN__c=counVod.Id);
    //    Customer_Type_Configuration_AMI_AGN__c cust3= new Customer_Type_Configuration_AMI_AGN__c(Account_Record_Type_AGN__c = 'Pharmacy_vod', Customer_Country_AGN__c=counVod.Id);
    //    configList.add(cust);
    //    configList.add(cust1);
    //    configList.add(cust2);
    //    configList.add(cust3);
                 
    //        AGN_AMI_CustomerRegistrationUtils agnAMICustomerRegisUtils = new AGN_AMI_CustomerRegistrationUtils(); 
    //        AGN_AMI_CustomerRegistrationUtils.createNewCustomerRegistration(aaCRAC1, acaac1, configList);
    //        AGN_AMI_CustomerRegistrationUtils.generateChangeList(acaac, addVod);
    //        AGN_AMI_CustomerRegistrationUtils.checkForDuplicateCustomer(aaCRAC1.Email_AGN__c);                
    //        AGN_AMI_CustomerRegistrationUtils.getCountries();
    //        AGN_AMI_CustomerRegistrationUtils.getCountryDetailsByCountryCode(counVod.Name);
    //        AGN_AMI_CustomerRegistrationUtils.getCountryDetailsById(counVod.Id);
    //        AGN_AMI_CustomerRegistrationUtils.setCustomerSpecialty(aaCRAC1, configList);
    //        AGN_AMI_CustomerRegistrationUtils.getRegions(counVod.Name);
           // AGN_AMI_CustomerRegistrationUtils.getAddressDetail(addVod.Address_line_2_vod__c);  
    //        AGN_AMI_CustomerRegistrationUtils.getRegionNamebyCode(regionValue.RegionCode__c, regionValue.Country_Code__c);
           // AGN_AMI_CustomerRegistrationUtils.setEntitlement('', '', counVod.Name);
      //      AGN_AMI_CustomerRegistrationUtils.setCustomerSpecialty(aaCRAC1, configList);
        }
        Test.stopTest();
    }
}