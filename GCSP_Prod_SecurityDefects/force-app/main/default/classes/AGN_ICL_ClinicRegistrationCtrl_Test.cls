@isTest
public class AGN_ICL_ClinicRegistrationCtrl_Test {
    
    static testmethod void method1(){
        
        insert new AGN_ICL_Settings__c(Name='GB',User_Language_Locale_AGN__c='en_US',User_Locale_Id_AGN__c='en_GB',User_Timezone_Id_AGN__c='Europe/London'); 
insert new AGN_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(), GooglePrivateKey_AGN__c='a3--l2CjL5iGR6tOOnQrMOM5Ics=',GoogleClientID_AGN__c='gme-allerganinc'); 
insert new AGN_ICL_Portal_Settings__c(SetupOwnerId=UserInfo.getOrganizationId(),Default_Recovery_Question_AGN__c ='What is your name?',Default_Recovery_Answer_AGN__c='Test Abc',Okta_Group_Id_AGN__c='00gjx8x58iH0hTOva0h7',Encryption_Private_Key_AGN__c='S3xpzk/vntPtllFFFQFASCPnbwPhE6UGVLtuUljC7Jg=',Password_Activation_Token_Valid_till_AGN__c=Decimal.valueOf('48'),ICL_Username_Suffix_AGN__c='agn_icl',ICL_Community_Portal_Base_URL_AGN__c='https://test.force.com',ICL_Community_Portal_Suffix_AGN__c='/testicl',From_Email_Address_AGN__c='Tan@x.com');
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 =new User(Alias = 'xyz', Email='xyz.pqr@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='pqr', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='xyz.pqr@testorg.com.int',Country_Code__c='GB');
        insert u1;
        
        Country_vod__c c1=new Country_vod__c();
        c1.Country_Name_vod__c='GB';
        c1.First_Level_Clinic_Approver_AGN__c=u1.Id;
        insert c1;
        
         
        

        
        Account a1 =new Account();
        a1.Name='Test_a1';
        a1.Status_AGN__c = 'Pending Validation';
        a1.Customer_Managed_AGN__c = True;
        a1.Country_vod__c = c1.id;
        a1.Registered_For_Clinic_Locator_AGN__c = True;
        
        a1.Country_Code__c = c1.Alpha_2_Code_vod__c;
        //a.Sub_Type_AGN__c = 'Dayclinic';
        a1.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;
        insert a1;
        
        
        Locator_Listing_AGN__c l1= new Locator_Listing_AGN__c();
        l1.Name='Test_Listing';
        l1.Account_AGN__c=a1.Id;
        l1.Registered_For_Clinic_Locator_AGN__c=True;
        l1.Active_AGN__c= False;
        l1.First_Level_Clinic_Approver_AGN__c=c1.First_Level_Clinic_Approver_AGN__c;
        l1.Email_AGN__c='xyz@testorg.com';
        insert l1;
        
        
        a1.Email_Internal_AGN__c=l1.Email_AGN__c;
        update a1;
        
        Account a2=new Account();
        a2.Name='Test_a2';
        //a2.Primary_Parent_vod__c=a1.Id;
        insert a2;
               
        
        //String x=(String)a1.Id;
       
        Test.startTest();
        AGN_ICL_ClinicRegistrationController.addclinicRecord(a1,l1,c1);
        Data_Change_Request_vod__c dcr=new Data_Change_Request_vod__c(Account_vod__c=a1.Id);
        insert dcr;
        AGN_ICL_ClinicRegistrationController.createLocatorListingData(a1,a2,l1,c1);
        AGN_ICL_ClinicRegistrationController.SendWelcomeEmailtoClinicAdmin(a2);
        String DCR_Note='Test_DCR';
        AGN_ICL_ClinicRegistrationController.createDCR(String.valueOf(a1.Id),DCR_Note);
        AGN_ICL_ClinicRegistrationController.fetchPicklistValues('Locator_Listing_AGN__c','Approval_Status__c',true);
        
        Test.stopTest();
        
     }

}