@isTest
public class AGN_ICLRegistrationPageControllerTest{

 @isTest
     static void  getCommunityURLTest()
    {
    System.Test.startTest();
        //AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        List<String> commURL = new List<String>();
        //commURL.add((String)portalSetting.ICL_Community_Portal_Base_URL_AGN__c);
        //commURL.add((String)portalSetting.ICL_Community_Portal_Suffix_AGN__c);
        commURL=AGN_ICLRegistrationPageController.getCommunityURL();
        System.assertEquals(2, commURL.size());
        System.assertNotEquals(null, commURL);
    System.Test.stopTest();
    }
     @isTest
     static void getBrandPicklistValuesTest()
    {
    System.Test.startTest();
         List<String> brandValues = new List<String>();
      brandValues = AGN_ICLRegistrationPageController.getBrandPicklistValues();
      System.assertNotEquals(null,brandValues);
      System.assertEquals(2, brandValues.size());
      System.assertEquals('CoolSculpting', brandValues[0]);
      System.assertEquals('Juvederm', brandValues[1]);
     System.Test.stopTest();
} 

@isTest(SeeAllData = true)
    //public Static Account CreateClinicAccount(Account clinic,Locator_Listing_AGN__c loc)
    Static void CreateClinicAccountTest()
    {
    Country_vod__c Country_code = [select id,name,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =:'GB' limit 1];
    
    Account acc = new Account();
        acc.Name = 'Test';
        acc.Status_AGN__c = 'Pending Validation';
        acc.Customer_Managed_AGN__c = True;
        acc.Country_vod__c ='a3L5E000000VqGJUA0';
        acc.Registered_For_Clinic_Locator_AGN__c = True;
        acc.Email_Internal_AGN__c = 'test@gmail.com';
        acc.Country_Code__c = 'GB';
        acc.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;
        insert acc;
     
      Locator_Listing_AGN__c locList = new Locator_Listing_AGN__c();
      locList.Name= 'acc.Name';
      locList.Account_AGN__c = acc.Id;
      //locList.Country_Code_AGN__c ='a3L5E000000VqGJUA0';
      locList.Country_Code_AGN__c ='a3L5E000000VqGJUA0';
      locList.User_Language_AGN__c='en_US';
      locList.Clinic_Admin_AGN__c=acc.Id;
      locList.Street_AGN__c='Saltlake';
      locList.City_AGN__c = 'Kolkata';
      locList.Country_AGN__c = 'IN';
      locList.Zip_Code_AGN__c = '755023';
      insert locList;
    
        
        Address_vod__c ad = new Address_vod__c();
        ad.Account_vod__c = acc.Id;
        ad.Name = locList.Street_AGN__c;
        ad.City_vod__c = locList.City_AGN__c;
        ad.Country_vod__c = locList.Country_AGN__c;
        ad.Country_Code__c = 'GB';
        ad.Zip_vod__c = locList.Zip_Code_AGN__c;
        ad.Primary_vod__c = True;
        insert ad;
   
       
    System.Test.startTest();
       // Account acc1 = AGN_ICL_ClinicRegistrationController.addclinicRecord(acc,locList,Country_code);
       Account acc1 = AGN_ICLRegistrationPageController.CreateClinicAccount(acc,locList);
        
         System.assertNotEquals(null,acc1.Id);
   System.Test.stopTest();
}

 @isTest(SeeAllData=true)
    static void getCountryWiseFieldsTest(){
    System.Test.startTest();
    
        List<AGN_ICL_Layout_Field__mdt> fieldList = new List<AGN_ICL_Layout_Field__mdt>();
        String CountryCode = [Select id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c  from User where id =:UserInfo.getUserId()][0].Country_Code__c;
        System.debug('Country code'+CountryCode);
        fieldList = [Select id,Section_Header__c,Field_Regex_AGN__c,Field_for_AGN__c,Field_API_Name_AGN__c,Field_Sobject_API_Name_AGN__c,Field_Label_AGN__c,Field_Of_HCP_or_HCA_AGN__c,Field_Sort_Order_AGN__c,Field_Type_AGN__c,IsPicklist_AGN__c,Required_AGN__c,Country_Code_AGN__c from AGN_ICL_Layout_Field__mdt WHERE Field_Of_HCP_or_HCA_AGN__c = 'SignUp' and Country_Code_AGN__c =:CountryCode order by Field_Sort_Order_AGN__c];
         AGN_ICLRegistrationPageController.getCountryWiseFields('GB');
        System.assertNotEquals(null,fieldList );
         
    System.Test.stopTest();
}

  @isTest(SeeAllData=true)
    public Static void createClinicAdminPersonAccountTest(){
     Country_vod__c Country_code = [select id,name,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =:'GB' limit 1];
       
     Account acc= new Account();
      acc.Name= 'Allergan Hospital';
      acc.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;
      acc.Country_Code__c = 'GB';
      acc.Country_vod__c ='a3L5E000000VqGJUA0';
      insert acc;
       Data_Change_Request_vod__c dcr = new Data_Change_Request_vod__c();
       dcr.Country_Code_AGN__c = 'GB';
       dcr.Account_vod__c = acc.Id;
       insert dcr;
      Locator_Listing_AGN__c locList = new Locator_Listing_AGN__c();
      locList.Name= 'acc.Name';
      locList.Account_AGN__c = acc.Id;
      //locList.Country_Code_AGN__c ='a3L5E000000VqGJUA0';
      locList.Country_Code_AGN__c =Country_code.Id;
      locList.User_Language_AGN__c='en_US';
      locList.Clinic_Admin_AGN__c=acc.Id;
      locList.DCR_Reference_Number_AGN__c=acc.Name;
      locList.DCR_Reference_Number_AGN__c=[SELECT Name FROM Data_Change_Request_vod__c WHERE Account_vod__c=:acc.Id LIMIT 1].Name;
      insert locList;
        
        //String Country_code = 'a3L5E000000VqGJUA0';
        Account clinicAdminAcc = new Account();
        clinicAdminAcc.Salutation = 'Mr.';
        clinicAdminAcc.FirstName = 'TestUser';
        clinicAdminAcc.LastName = 'Clinic';
        clinicAdminAcc.PersonEmail = 'TestUser@gmail.com';
        clinicAdminAcc.Customer_Managed_AGN__c = True;
        clinicAdminAcc.Registered_For_Clinic_Locator_AGN__c = True;
       // clinicAdminAcc.Primary_Parent_vod__c = clinic_detail.id;
        clinicAdminAcc.Status_AGN__c = 'Pending Validation';
        clinicAdminAcc.Country_vod__c = Country_code.Id;
        clinicAdminAcc.Country_Code__c = 'GB';
        clinicAdminAcc.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id;
        insert clinicAdminAcc;
        //String DcrIdAdmin = AGN_ICL_ClinicRegistrationController.createDCR(clinicAdminAcc.id,'Approve');
        String clinicAdminId = AGN_ICLRegistrationPageController.createClinicAdminPersonAccount(clinicAdminAcc,acc,locList);
       /**public Static String createClinicAdminPersonAccount(Account Clinic_Admin_details,Account clinic_detail,Locator_Listing_AGN__c loc)
    {
        Country_vod__c Country_code = [select id,name,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Alpha_2_Code_vod__c,Cluster_Country_AGN__c,Country_Name_vod__c,Data_Provider_Managed_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =:Clinic_Admin_details.Country_Code__c limit 1];
        Account clinicAdminAcc = new Account();
        clinicAdminAcc.Salutation = Clinic_Admin_details.Salutation;
        clinicAdminAcc.FirstName = Clinic_Admin_details.FirstName;
        clinicAdminAcc.LastName = Clinic_Admin_details.LastName;
        clinicAdminAcc.PersonEmail = Clinic_Admin_details.PersonEmail;
        clinicAdminAcc.Customer_Managed_AGN__c = True;
        clinicAdminAcc.Registered_For_Clinic_Locator_AGN__c = True;
       // clinicAdminAcc.Primary_Parent_vod__c = clinic_detail.id;
        clinicAdminAcc.Status_AGN__c = 'Pending Validation';
        clinicAdminAcc.Country_vod__c = Country_code.id;//clinic_detail.Country_vod__c;
        clinicAdminAcc.Country_Code__c = Clinic_Admin_details.Country_Code__c;//'GB'; //Country Code to be given dynamically
        clinicAdminAcc.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id;
        System.debug('Clinic Admin Details' +clinicAdminAcc);
        System.debug('Clinic Details '+clinic_detail);
        insert clinicAdminAcc;
        System.debug('Clinic Admin Id' +clinicAdminAcc.id);
        String DcrIdAdmin = AGN_ICL_ClinicRegistrationController.createDCR(clinicAdminAcc.id,'Approve');
        System.debug('DCR Id Clinic Admin'+DcrIdAdmin);
        
        AGN_ICL_ClinicRegistrationController.createLocatorListingData(clinic_detail,clinicAdminAcc,loc,Country_code);
        //clinicAdminAcc = [select Id, Name, PersonContactId, FirstName,Country_Code__c, LastName, PersonEmail, Phone,Customer_Category_AGN__c,Customer_Sub_Category_AGN__c from Account where Id =: clinicAdminAcc.Id limit 1];
        //createClinicAdminUser(Json.serialize(clinicAdminAcc));
        
        return clinicAdminAcc.id;
    }*/
    
    
        System.assertNotEquals(null,clinicAdminId);
       // System.assertEquals('Approve',clinicAdminAcc.Status_AGN__c);
    }
    
    @isTest
    public static void IsDuplicateEmailTest(){
    Account acc = new Account(Name = 'Allergan Medical');
      insert acc;
      AGN_Settings__c settings = new AGN_Settings__c();
      settings.GooglePrivateKey_AGN__c='a3--l2CjL5iGR6tOOnQrMOM5Ics=';
      settings.GoogleClientID_AGN__c='gme-allerganinc';   
      insert settings;   
      Locator_Listing_AGN__c locList = new Locator_Listing_AGN__c();
      locList.Name= 'acc.Name';
      locList.Account_AGN__c = acc.Id;
      locList.Country_Code_AGN__c ='a3L5E000000VqGJUA0';
      //locList.Country_Code_AGN__c =Country_code.Id;
      locList.User_Language_AGN__c='en_US';
      locList.Clinic_Admin_AGN__c=acc.Id;
      locList.Clinic_Admin_Email_AGN__c ='TestUser@gmail.com';
      locList.GeoLocation_AGN__Latitude__s =51.5764305;
      locList.GeoLocation_AGN__Longitude__s =88.2704815;
      
      insert locList;
      String clinicAdminEmail =locList.Clinic_Admin_Email_AGN__c;
      Boolean isDuplicate = AGN_ICLRegistrationPageController.IsDuplicateEmail(clinicAdminEmail);
      System.assertEquals(true,isDuplicate);
    }
}