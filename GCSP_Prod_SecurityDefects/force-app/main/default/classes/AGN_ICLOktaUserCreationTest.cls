@isTest
public class AGN_ICLOktaUserCreationTest {

    
    @testSetup static void setup() {
        
        insert new AGN_ICL_Settings__c(Name='GB',User_Language_Locale_AGN__c='en_US',User_Locale_Id_AGN__c='en_GB',User_Timezone_Id_AGN__c='Europe/London');
        insert new AGN_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), GooglePrivateKey_AGN__c='a3--l2CjL5iGR6tOOnQrMOM5Ics=',GoogleClientID_AGN__c='gme-allerganinc');
        insert new AGN_ICL_Portal_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(),Default_Recovery_Question_AGN__c ='What is your name?',Default_Recovery_Answer_AGN__c='Test Abc',Okta_Group_Id_AGN__c='00gjx8x58iH0hTOva0h7',Encryption_Private_Key_AGN__c='S3xpzk/vntPtllFFFQFASCPnbwPhE6UGVLtuUljC7Jg=',Password_Activation_Token_Valid_till_AGN__c=Decimal.valueOf('48'),ICL_Username_Suffix_AGN__c='agn_icl',ICL_Community_Portal_Base_URL_AGN__c='https://test.force.com',ICL_Community_Portal_Suffix_AGN__c='/testicl',From_Email_Address_AGN__c='Tan@x.com');
        //EmailTemplate e = new EmailTemplate (developerName = 'ICL_Registration_Welcome_en_US', FolderId='dhdfddfdf', TemplateType= 'custom', Name = 'ICL Registration Welcome_en_US');
        EmailTemplate e = new EmailTemplate (developerName = 'ICL_Registration_Welcome_en_US', FolderId='00l5E000000QLZEQA4', TemplateType= 'custom', Name = 'ICL Registration Welcome_en_US');
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'AGN Local Admin - Salesforce' limit 1];
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg11.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_GB', ProfileId = p1.Id, 
            TimeZoneSidKey='Europe/London', UserName='standarduser@testorg11.com');
        
        Country_vod__c country = new Country_vod__c();
        country.name = 'GB';
        country.First_Level_Clinic_Approver_AGN__c = u.id;
        country.Alpha_2_Code_vod__c = 'GB';
        country.Country_Name_vod__c = 'United Kingdom';
        country.Data_Provider_Managed_AGN__c = true;
        insert country;
        
        Account clinic = new Account();
        clinic.Email_Internal_AGN__c = 'testiclclinic@allergan.com';
        clinic.Name = 'Test Clinic';
        clinic.Status_AGN__c = 'Pending Validation';
        clinic.Customer_Managed_AGN__c = true;
        clinic.Registered_For_Clinic_Locator_AGN__c = true;
        clinic.Country_vod__c = country.Id;
        clinic.Country_Code__c = 'GB';
        clinic.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;//Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization_vod').getRecordTypeId();
        insert clinic;
        
        System.debug('Clinic Id: '+clinic.id);
        System.RunAs(u1)
        {
            
        Account clinicadmin = new Account();
       
        clinicadmin.Salutation ='Mr.';
        clinicadmin.PersonEmail = 'testicl@allergan.com';
        clinicadmin.FirstName = 'Test';
        clinicadmin.LastName = 'Clinic Admin';
        clinicadmin.Phone = '946262226';
        clinicadmin.Primary_Parent_vod__c = clinic.Id;
        clinicadmin.Status_AGN__c = 'Pending Validation';
        clinicadmin.Customer_Managed_AGN__c = true;
        clinicadmin.Registered_For_Clinic_Locator_AGN__c = true;
        clinicadmin.Country_vod__c = country.Id;
        clinicadmin.Country_Code__c = 'GB';
        clinicadmin.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id;//Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional_vod').getRecordTypeId();
        insert clinicadmin;
        
       
        
        Locator_Listing_AGN__c loc = new Locator_Listing_AGN__c();
        loc.Name = 'Test LOC';
        loc.Active_AGN__c = true;
        loc.Clinic_Admin_AGN__c = clinicadmin.Id;
        loc.Account_AGN__c = clinic.Id;
        loc.Street_AGN__c = 'ABC Road';
        loc.City_AGN__c = 'Kolkata';
        loc.Country_AGN__c = 'India';
        loc.Zip_Code_AGN__c = '700102';
        loc.User_Language_AGN__c = 'en_US';
        insert loc;
        
        insert e;           
        }
    }
     
    static testMethod void testcreateClinicAdminUser() {
        
        Locator_Listing_AGN__c loc = [Select id,name,Active_AGN__c,Clinic_Admin_AGN__c,Account_AGN__c,User_Language_AGN__c from Locator_Listing_AGN__c limit 1];
        Account acc = [Select id,name,Salutation,FirstName,LastName,PersonEmail,Phone,Primary_Parent_vod__c,Country_Code__c from Account WHERE ID=:loc.Clinic_Admin_AGN__c];
        String accdata = JSON.serialize(acc);
        String clinic_Id = loc.Account_AGN__c;
        String locid = loc.Id;
        String Userlang = loc.User_Language_AGN__c;
        String contact_id = AGN_ICLOktaUserCreation.CreateContact(acc,clinic_Id);
        
        AGN_ICLOktaUserCreation.createClinicAdminUser(accdata,clinic_Id,contact_id,locid,Userlang);
        
    }
    @isTest
    static  void testcreateOktaUser() { 
      
        AGN_ICL_Portal_Settings__c portalSetting = new AGN_ICL_Portal_Settings__c();
        portalSetting.Default_Recovery_Question_AGN__c = 'Mother\'s Maiden Name ?';
        portalSetting.Default_Recovery_Answer_AGN__c = 'Maa';
        portalSetting.Okta_Group_Id_AGN__c = 'oktagroup';
        //insert portalSetting;
        
        
        AGN_ICL_Settings__c iclSettings = new AGN_ICL_Settings__c();
        iclSettings.Name = 'GB';
        iclSettings.ICL_Community_Portal_Suffix_AGN__c = '/gcldevallergan';
        iclSettings.ICL_Username_Suffix_AGN__c ='agn_icl';
        iclSettings.Name  = 'GB'; 
        iclSettings.Okta_API_Key_AGN__c ='00GKfAXqjhiOVxIT3C-wbB1et2AWFoX1TEX3b6XgbV';
        iclSettings.Okta_Base_URL_AGN__c ='https://dev-147363.oktapreview.com';
        //iclSettings.OKTA_Group_Id_AGN__c = 
        iclSettings.Okta_Redirect_URL_AGN__c = 'https://dev-147363.oktapreview.com/home/salesforce_portal/0oajm0rz10ADXNPaY0h7/671';
        iclSettings.User_Language_Locale_AGN__c = 'en_US';
        iclSettings.User_Locale_Id_AGN__c = 'en_GB';
        iclSettings.User_Timezone_Id_AGN__c ='Europe/London'; 
        insert iclSettings;
               
        Locator_Listing_AGN__c loc = [Select id,name,Active_AGN__c,Clinic_Admin_AGN__c,Account_AGN__c,User_Language_AGN__c from Locator_Listing_AGN__c WHERE Name = 'Test LOC' lIMIT 1];
        
        Account acc = [Select id,name,Salutation,FirstName,LastName,PersonEmail,Phone,Primary_Parent_vod__c,Country_Code__c from Account WHERE ID=:loc.Clinic_Admin_AGN__c];
       
        User usr = [SELECT Id,Name,LocaleSidKey,EmailEncodingKey,LastName,LanguageLocaleKey,TimeZoneSidKey From User where UserName='standarduser@testorg11.com'];
      
        String accdata = JSON.serialize(acc);
        String clinic_Id = loc.Account_AGN__c;
        String locid = loc.Id;
        String Userlang = loc.User_Language_AGN__c;
        String acc_Data = '{"ID":"'+acc.Id+'","Name":"'+acc.Name+'","FirstName":"'+acc.FirstName+'","LastName":"'+acc.LastName+'","PersonEmail":"'+acc.PersonEmail+'","Phone":"'+acc.Phone+'","Primary_Parent_vod__c":"'+acc.Primary_Parent_vod__c+'","Country_Code__c":"'+acc.Country_Code__c+'"}';
        
        String reqBody = '{"profile": {'+'"firstName": "'+acc.FirstName +'","lastName": "'+acc.LastName+'","email": "'+acc.PersonEmail.toLowercase()+'","login": "'+acc.PersonEmail.toLowercase()+'","countryCode": "'+acc.Country_Code__c+'"},"credentials": {"recovery_question": {"question": "'+portalSetting.Default_Recovery_Question_AGN__c+'","answer": "'+portalSetting.Default_Recovery_Answer_AGN__c+'"}},'+'"groupIds": "' +portalSetting.Okta_Group_Id_AGN__c + '"}';              
           
        AGN_ICLOktaUserCreation.CreateOKTAUser(accdata,locid,Userlang);
        //AGN_ICLOktaUserCreation.CreateOKTAUser(reqBody,locid,Userlang);
        //AGN_ICLOktaUserCreation.CreateOKTAUser(acc_Data,locid,Userlang);
       
    }
}