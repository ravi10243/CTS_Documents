@isTest
public class AGN_ICLOktaForgotPwdController_Test {

@isTest(SeeAllData=true)
public static void test_AGN_ICLOktaForgotPwdController(){
 Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
 User usr = new User(Alias = 'ICLUsr',Email='testuser@allergan.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='testICLuser@allergan.com.icl');
       
     System.runAs(usr){
      Account acc= new Account();
      acc.Name= 'Allergan Hospital';
      acc.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;
      acc.Country_Code__c = 'GB';
      acc.Country_vod__c ='a3L5E000000VqGJUA0';
      insert acc;
     
      Locator_Listing_AGN__c locList = new Locator_Listing_AGN__c();
      locList.Name= 'acc.Name';
      locList.Account_AGN__c = acc.Id;
      locList.Country_Code_AGN__c ='a3L5E000000VqGJUA0';
      locList.User_Language_AGN__c='en_US';
      locList.Clinic_Admin_AGN__c=acc.Id;
      locList.Street_AGN__c='Saltlake';
      locList.City_AGN__c = 'Kolkata';
      locList.Country_AGN__c = 'IN';
      locList.Zip_Code_AGN__c = '755023';
      locList.GeoLocation_AGN__Latitude__s =51.5764305;
      locList.GeoLocation_AGN__Longitude__s =88.2704815;
      insert locList;
      
      usr.Locator_Listing_Id_AGN__c =locList.Id;
      update usr;
      
    String userLanguage ='en_US';
    String USERNAME_SUFFIX ='ICL';
    
    String oktausername ='testuser@allergan.com';
    String sfusername ='testuser@allergan.com';
    Boolean renderPW =false;
    String Loginlink ='https://iclhcp--gcldev.my.salesforce.com/AGN_ICL_Registration?country=GB &lang=en_US';
     AGN_ICL_Portal_Settings__c ICLAuth = new AGN_ICL_Portal_Settings__c();
        ICLAuth.Okta_Base_URL_AGN__c = 'https://dev-147363.oktapreview.com';
        ICLAuth.Okta_OAuth2_Issuer_AGN__c ='https://dev-147363.oktapreview.com/oauth2/default';
        ICLAuth.Okta_Redirect_URL_AGN__c = 'https://dev-147363.oktapreview.com/home/salesforce_portal/0oajm0rz10ADXNPaY0h7/671';
        ICLAuth.ICL_Username_Suffix_AGN__c ='/gcldevallergan';
        ICLAuth.Encryption_Private_Key_AGN__c = 'S3xpzk/vntPtllFFFQFASCPnbwPhE6UGVLtuUljC7Jg=';
        ICLAuth.Password_Activation_Token_Valid_till_AGN__c = 48;
        //insert ICLAuth;
        String dataToEncrypt ='AES256';
        String encryptedData='Allergan';
        
        String privateKey = AGN_Settings__c.getOrgDefaults().GooglePrivateKey_AGN__c.replace('-','+').replace('_','/');
        String clientId = AGN_Settings__c.getOrgDefaults().GoogleClientID_AGN__c;
        PageReference pageRef = new PageReference('https://iclhcp--gcldev.my.salesforce.com?country=GB & lang =en_US');
        AGN_ICLOktaForgotPwdController ctlr=  new AGN_ICLOktaForgotPwdController();
        ctlr.updatePwdRecovery();
        ctlr.sendPasswordChangeLink(usr);
     }
   
   }   
   
 }