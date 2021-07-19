@isTest
public class AGN_ICL_SendLocatorListingDataTest {
    
    @testSetup static void setupLocatorListingData() {
        //RestRequest req = new RestRequest();
        //req.params.put('lat', 'my_region');
        //req.params.put('log', 'my_segment');
        //req.params.put('dist', '10');
        //req.params.put('reqsite', 'Coolsculpting');
        //req.params.put('country', 'GB');
        
        //insert new AGN_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), GooglePrivateKey_AGN__c='a3--l2CjL5iGR6tOOnQrMOM5Ics=',GoogleClientID_AGN__c='gme-allerganinc');
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
        System.RunAs(u1)
        {
        insert new AGN_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), GooglePrivateKey_AGN__c='a3--l2CjL5iGR6tOOnQrMOM5Ics=',GoogleClientID_AGN__c='gme-allerganinc');
        country.name = 'GB';
        //country.First_Level_Clinic_Approver_AGN__c = u.id;
        country.Alpha_2_Code_vod__c = 'GB';
        country.Country_Name_vod__c = 'United Kingdom';
        country.Data_Provider_Managed_AGN__c = true;
        insert country;
        }
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
        
        //System.RunAs(u1)
        //{
            
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
            
            Account practacc = new Account();
            
            practacc.Salutation ='Mr.';
            practacc.PersonEmail = 'testicl@allergan.com';
            practacc.FirstName = 'Test';
            practacc.LastName = 'Clinic Admin';
            practacc.Phone = '946262226';
            practacc.Primary_Parent_vod__c = clinic.Id;
            practacc.Status_AGN__c = 'Pending Validation';
            practacc.Customer_Managed_AGN__c = true;
            practacc.Registered_For_Clinic_Locator_AGN__c = true;
            practacc.Country_vod__c = country.Id;
            practacc.Country_Code__c = 'GB';
            practacc.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id;//Schema.SObjectType.Account.getRecordTypeInfosByName().get('Professional_vod').getRecordTypeId();
            insert practacc;
            
            Locator_Listing_AGN__c loc = new Locator_Listing_AGN__c();
            loc.Name='Test LOC';
            loc.Account_AGN__c= clinic.Id;
            //loc.Account_AGN__r.name= 
            loc.Account_ID_AGN__c= 'dfkj233434df';
            loc.Active_AGN__c= true;
            loc.Ask_Question_Email_AGN__c= 'dffhd@gmail.com';
            loc.BD_Participant_AGN__c= true;
            loc.Brand_AGN__c= 'CoolSculpting';
            loc.City_AGN__c= 'Kolkata';
            loc.Clinic_Admin_AGN__c= clinicadmin.Id;
            loc.Country_Code_AGN__c = country.id;
            loc.Clinic_Admin_Email_AGN__c= 'dffhd@gmail.com';
            loc.Clinical_Investigator_AGN__c= true;
            loc.Clinic_Experience_AGN__c= Decimal.valueOf('3');
            loc.VIP_AGN__c= true;
            loc.Clinic_Image_AGN__c= 'www.aws.com';
            loc.Clinic_Experience_Site_AGN__c= 'PersonalTouch';
            //loc.Clinic_Status_AGN__c= 
            loc.Consent_AGN__c= true;
            loc.Country_AGN__c= 'India';
            //loc.Country_Shadow_AGN__c=
            loc.Email_AGN__c= 'dffhd@gmail.com';
            loc.Enquiriy_Email_AGN__c= 'dffhd@gmail.com';
            loc.Friday_Close_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Friday_Open_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            //loc.GeoLocation_AGN__c=
            loc.GeoLocation_AGN__latitude__s= Decimal.valueOf('22.5726460000');
            loc.GeoLocation_AGN__longitude__s= Decimal.valueOf('88.3638950000');
            loc.Google_Url_AGN__c= 'www.google.com';
            loc.Monday_Close_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Monday_Open_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Offer_Evenings_AGN__c= true;
            loc.Open_Evenings_Email_AGN__c= 'dffhd@gmail.com';
            loc.Phone_Number_AGN__c= '95632321';
            loc.Picture_Available_AGN__c= true;
            loc.Registered_For_Clinic_Locator_AGN__c= true;
            loc.Request_Call_Email_AGN__c= 'dffhd@gmail.com';
            loc.Saturday_Close_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Saturday_Open_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.State_Providence_Region_AGN__c= 'West Bengal';
            loc.Street_AGN__c= 'ABC Road';
            loc.Sunday_Close_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Sunday_Open_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Testimonial_Available_AGN__c= true;
            loc.Thursday_Close_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Thursday_Open_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Tuesday_Close_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Tuesday_Open_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Website_AGN__c= 'www.google.com';
            loc.Wednesday_Close_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Wednesday_Open_Hours_AGN__c= Time.newInstance(1, 12, 30, 2);
            loc.Zip_Code_AGN__c= '700102';
            
            insert loc;
            
            Practitioner_Listing_AGN__c pract = new Practitioner_Listing_AGN__c();
            
            pract.Brand_AGN__c = 'CoolSculpting';
            pract.Clinic_AGN__c = clinic.id;
            pract.Consent_AGN__c = true;
            pract.Consent_Check_AGN__c= true;
            pract.Email_AGN__c = 'abctest@gmail.com';
            pract.First_Name_AGN__c = 'Practitioner';
            pract.Last_Name_AGN__c = 'Test';
            PRACT.Gender_AGN__c = 'Male';
            pract.Language_AGN__c = 'English';
            pract.Locator_Listing_AGN__c= loc.id;
            pract.Practitioner_AGN__c = practacc.id;
            pract.Practitioner_Image_AGN__c = 'www.aws.com';
            pract.Practitioner_Image_Available_AGN__c = true;
            pract.Qualification_AGN__c = 'MBBS';
            pract.Salutation_AGN__c = 'Mr.';
            pract.Status_AGN__c = 'Active';
            pract.Type_AGN__c = 'Beautician';
            pract.Type_Of_Physician_AGN__c = 'abc';
            pract.Years_of_Experience_AGN__c = Decimal.valueOf('8');

                insert pract;
        //}
    }
    
    static testMethod void testMethodForgetListofLocations(){
        
        RestRequest req = new RestRequest();
        req.params.put('lat', '22.581337');
        req.params.put('log', '88.443898');
        req.params.put('dist', '-1');
        req.params.put('reqsite', 'CoolSculpting');
        req.params.put('country', 'GB');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        
        AGN_ICL_SendLocatorListingData.getListofLocations();
    }
}