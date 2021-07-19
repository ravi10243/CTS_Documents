@isTest
public class AGN_ICL_SendEmailCtrl_Test {
  @isTest
    //get from getuserinfo.contactid and corrresponding person account id 
   // public static Boolean sendEmailToContactMethod(String emailtocontact)
   static void sendEmailToContactMethod(){
   String contactEmail = 'prasanta.bai@cognizant.com';
   Boolean success ;
   /**Account hco = new Account();
      hco.Name= 'Allergan Hospital';
      hco.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;
      hco.Country_Code__c = 'GB';
      hco.Country_vod__c ='a3L5E000000VqGJUA0';
      insert hco;
      Locator_Listing_AGN__c locList = new Locator_Listing_AGN__c();
      locList.Name= 'hco.Name';
      locList.Account_AGN__c = hco.Id;
      locList.Country_Code_AGN__c ='a3L5E000000VqGJUA0';
      locList.User_Language_AGN__c='en_US';
      locList.Clinic_Admin_AGN__c=hco.Id;
      locList.Street_AGN__c='Saltlake';
      locList.City_AGN__c = 'Kolkata';
      locList.Country_AGN__c = 'IN';
      locList.Zip_Code_AGN__c = '755023';
      insert locList;**/
  
   Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
   //User usr = new User(AccountId =hco.Id,Locator_Listing_Id_AGN__c = locList.Id,Alias = 'ICLUsr',Email='testuser@allergan.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='testICLuser@allergan.com.icl');
   User usr = new User(Alias = 'ICLUsr',Email='testuser@allergan.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='testICLuser@allergan.com.icl');
           
  System.runAs(usr){
      System.Test.startTest();   
      Account hco = new Account();
      hco.Name= 'Allergan Hospital';
      hco.RecordTypeId =[SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Organization_vod' LIMIT 1][0].Id;
      hco.Country_Code__c = 'GB';
      hco.Country_vod__c ='a3L5E000000VqGJUA0';
      insert hco;
      
      AGN_Settings__c settings = new AGN_Settings__c();
      settings.GooglePrivateKey_AGN__c='a3--l2CjL5iGR6tOOnQrMOM5Ics=';
      settings.GoogleClientID_AGN__c='gme-allerganinc';   
      insert settings; 
        
      Locator_Listing_AGN__c locList = new Locator_Listing_AGN__c();
      locList.Name= 'hco.Name';
      locList.Account_AGN__c = hco.Id;
      locList.Country_Code_AGN__c ='a3L5E000000VqGJUA0';
      locList.User_Language_AGN__c='en_US';
      locList.Clinic_Admin_AGN__c=hco.Id;
      locList.Clinic_Admin_Email_AGN__c ='TestUser@gmail.com';
      locList.GeoLocation_AGN__Latitude__s =51.5764305;
      locList.GeoLocation_AGN__Longitude__s =88.2704815;
      
      insert locList;
     
      /**Locator_Listing_AGN__c locList = new Locator_Listing_AGN__c();
      locList.Name= 'hco.Name';
      locList.Account_AGN__c = hco.Id;
      locList.Country_Code_AGN__c ='a3L5E000000VqGJUA0';
      locList.User_Language_AGN__c='en_US';
      locList.Clinic_Admin_AGN__c=hco.Id;
      locList.Street_AGN__c='Saltlake';
      locList.City_AGN__c = 'Kolkata';
      locList.Country_AGN__c = 'IN';
      locList.Zip_Code_AGN__c = '755023';
      locList.GeoLocation_AGN__Latitude__s =51.5764305;
      locList.GeoLocation_AGN__Longitude__s =88.2704815;
      insert locList;**/
      
      usr.Locator_Listing_Id_AGN__c =locList.Id;
      update usr;
     
      
       
      List<Practitioner_Listing_AGN__c> practitionerList = new List<Practitioner_Listing_AGN__c>();
      Practitioner_Listing_AGN__c practitioner = new Practitioner_Listing_AGN__c();
      practitioner.Name= 'Test XYZ';
      practitioner.Salutation_AGN__c='Prof.';
      practitioner.First_Name_AGN__c='Test';
      practitioner.Last_Name_AGN__c='XYZ';
      practitioner.Type_AGN__c='Doctor';                       
      practitioner.Gender_AGN__c= 'Male';
      practitioner.Brand_AGN__c = 'CoolSculpting';
      practitioner.Qualification_AGN__c='MBBS';
      practitioner.Email_AGN__c= contactEmail;                        
      practitioner.Years_of_Experience_AGN__c= 7;                       
      practitioner.Type_Of_Physician_AGN__c= 'Hospital Doctor';
      practitioner.Clinic_AGN__c=hco.Id;
      practitioner.Locator_Listing_AGN__c=locList.Id;
      practitioner.Language_AGN__c = 'en_US';
      practitioner.Status_AGN__c = 'Active';
      //insert practitioner;  
      practitionerList.add(practitioner);
      Practitioner_Listing_AGN__c practitioner1 = new Practitioner_Listing_AGN__c();
      practitioner1.Name= 'Test ABC';
      practitioner1.Salutation_AGN__c='Mr.';
      practitioner1.First_Name_AGN__c='Test';
      practitioner1.Last_Name_AGN__c='ABC';
      practitioner1.Type_AGN__c='Doctor';                       
      practitioner1.Gender_AGN__c= 'Male';
      practitioner1.Brand_AGN__c = 'CoolSculpting';
      practitioner1.Qualification_AGN__c='MBBS';
      practitioner1.Email_AGN__c= 'TestABC@gmail.com';                        
      practitioner1.Years_of_Experience_AGN__c= 9;                       
      practitioner1.Type_Of_Physician_AGN__c= 'Hospital Doctor';
      practitioner1.Clinic_AGN__c=hco.Id;
      practitioner1.Locator_Listing_AGN__c=locList.Id;
      practitioner1.Language_AGN__c = 'en_US';
      practitioner1.Status_AGN__c = 'Active';
      //insert practitioner;   
      practitionerList.add(practitioner1);  
      insert practitionerList; 
      
      success = AGN_ICL_SendEmailCtrl.sendEmailToContactMethod(contactEmail);
      System.assertEquals(true,success); 
      success = AGN_ICL_SendEmailCtrl.sendEmailtoPractitioner(practitioner);
      System.assertEquals(true,success);
      System.Test.stopTest(); 
      }
    }
  }