@isTest
private class AGN_OnlineConsent_ControllerTest{
    
    @TestSetup
    static void setup()
    {
        Individual consentRecord = new Individual(LastName = 'xyz');
            insert consentRecord;
     
       Account acc = new Account();
           acc.name = 'updaterecord';
           acc.Consent_UniqueRef_AGN__c ='';      
       insert acc;
        
       Account acc1 = new Account();
           acc1.name = 'updaterecord';
           acc1.Consent_UniqueRef_AGN__c ='';      
       insert acc1;
       
       Country_vod__c CVC = new Country_vod__c();
           CVC.Name = 'FR';
           CVC.CurrencyIsoCode = 'EUR';
       insert CVC;    
               
            
       AGN_GCSP_Settings__c AGS = new AGN_GCSP_Settings__c();
       AGS.Name = 'GB';
       AGS.Account_Managed_By__c = 'Data';
       AGS.reCaptcha_End_Point__c = 'https://www.google.com/recaptcha/api/siteverify';
       insert AGS;
       
       
       AGN_OnlineConsent_Languages__c AOL = new AGN_OnlineConsent_Languages__c();
       AOL.Name= 'French';
       AOL.Language_Name__c= 'fr';
       insert AOL; 
       
    }

     @isTest
    static void AGNOnlineConsentControllerTest() {   
           
       AGN_OnlineConsent_Controller AOC = new AGN_OnlineConsent_Controller();
       AOC.ApplyCode();
       AOC.getLanguages();
       AOC.Cancel();       AOC.SaveAndContinueUniqueCode();
       AOC.retrieveContentHeaderData();
       AOC.FinalSave();
       AOC.getlanguageSelectOption();
        AOC.setlanguageSelectOption('abc');
       AOC.primaryEmail = 'test@cognizant.com';
       AOC.doVerify();
       AOC.cookieLang();
        Individual consentRecord = [Select Id from Individual limit 1];
       AOC.updateIndividualRecord(consentRecord.Id);
        Account acc =[Select Id from Account limit 1];
       AOC.updateIndividualRecord(acc.Id);
    }
    
     @isTest
    static void AGNOnlineConsentControllerTest2() {
       AGN_OnlineConsent_Controller AOC = new AGN_OnlineConsent_Controller();
       AOC.ApplyCode();
       AOC.getLanguages();
       AOC.Cancel();
       AOC.SaveAndContinueUniqueCode();
       AOC.retrieveContentHeaderData();
       AOC.FinalSave();
       AOC.primaryEmail = 'test@cogn';
       AOC.doVerify();
         Individual consentRecord = [Select Id from Individual limit 1];
       AOC.updateIndividualRecord(consentRecord.Id);
         Account acc =[Select Id from Account limit 1];
       AOC.updateIndividualRecord(acc.Id);
    }
  
       @isTest
    static void AGNOnlineConsentControllerTest3() {
       Account acc =[Select Id,Consent_UniqueRef_AGN__c from Account limit 1];
          acc.Consent_UniqueRef_AGN__c ='abc';
          acc.Country_vod__c =[Select Id from Country_vod__c limit 1].Id;  
         
          update acc;
       AGN_OnlineConsent_Controller AOC = new AGN_OnlineConsent_Controller();
          AOC.uniqueCode ='abc';
       AOC.ApplyCode();
       AOC.getLanguages();
       AOC.Cancel();
       AOC.SaveAndContinueUniqueCode();
       AOC.retrieveContentHeaderData();
       AOC.FinalSave();
       AOC.primaryEmail = 'test@cognizant.com';
       AOC.doVerify();
    }
       @isTest
    static void AGNOnlineConsentControllerTest4() {
       Account acc =[Select Id,Consent_UniqueRef_AGN__c from Account limit 1];
        
          acc.Consent_UniqueRef_AGN__c ='vvvv';
           
          update acc;
       AGN_OnlineConsent_Controller AOC = new AGN_OnlineConsent_Controller();
          AOC.uniqueCode ='vvvv';
       AOC.ApplyCode();
       AOC.getLanguages();
       AOC.Cancel();
       AOC.SaveAndContinueUniqueCode();
       AOC.retrieveContentHeaderData();
       AOC.FinalSave();
       AOC.primaryEmail = 'test@cognizant.com';
       AOC.doVerify(); 
   }
   
    @isTest
    static void AGNOnlineConsentControllerTest5() {   
           
       AGN_OnlineConsent_Controller AOC = new AGN_OnlineConsent_Controller();
       AOC.ApplyCode();
       AOC.getLanguages();
       AOC.Cancel();       
       AOC.SaveAndContinueUniqueCode();
       AOC.retrieveContentHeaderData();
       AOC.FinalSave();
       AOC.getlanguageSelectOption();
        AOC.setlanguageSelectOption('abc');
       AOC.primaryEmail = 'test@cognizant.com';
       AOC.additionalEmail = 'test1@cognizant.com';
       AOC.doVerify();
       AOC.cookieLang();
        Individual consentRecord = [Select Id from Individual limit 1];
        AOC.prodServPrimaryEmailConsent = true;
        AOC.prodServAdditionalEmailConsent = true;
        AOC.prodServPhoneConsent = true;
        AOC.transFinancialConsent = true;
        AOC.allerganEventPrimaryEmailConsent = true;
        AOC.allerganEventAdditionalEmailConsent = true;
        AOC.nonAllerganEventPrimaryEmailConsent = true;
        AOC.nonAllerganEventAdditionalEmailConsent = true;
       AOC.updateIndividualRecord(consentRecord.Id);
        Account acc =[Select Id from Account limit 1];
       AOC.updateIndividualRecord(acc.Id);
    }
}