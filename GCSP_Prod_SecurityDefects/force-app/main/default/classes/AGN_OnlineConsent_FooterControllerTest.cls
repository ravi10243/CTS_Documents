@isTest
private class AGN_OnlineConsent_FooterControllerTest{
    
    @TestSetup
    static void setup()
    {
       List<Allergan_Consent_Footer_Info__c> ACFIlist = new List<Allergan_Consent_Footer_Info__c>();
       Allergan_Consent_Footer_Info__c ACFI = new Allergan_Consent_Footer_Info__c();
       ACFI.Name = 'Privacy Statement'; 
       ACFI.CurrencyIsoCode = 'EUR';
       ACFIlist.add(ACFI);
       insert ACFIlist; 
    }

     @isTest
    static void AGNOnlineConsentFooterControllerTest() {   
         List<Allergan_Consent_Footer_Info__c>  acList = [Select Id from Allergan_Consent_Footer_Info__c];
         StringCarrier s = new StringCarrier();
         s.value='abc';
       AGN_OnlineConsent_FooterController  AOCF = new AGN_OnlineConsent_FooterController();
        AOCF.value = 'test';
        AOCF.Slanguage = s;
        AOCF.footerList = acList;
        List<Allergan_Consent_Footer_Info__c> abbc = AOCF.footerList;
    }
    
      @isTest
    static void AGNOnlineConsentFooterControllerTest2() {   
         List<Allergan_Consent_Footer_Info__c>  acList = [Select Id from Allergan_Consent_Footer_Info__c];
        
       AGN_OnlineConsent_FooterController  AOCF = new AGN_OnlineConsent_FooterController();
        AOCF.value = 'test';
        
        AOCF.footerList = acList;
        List<Allergan_Consent_Footer_Info__c> abbc = AOCF.footerList;
    }
    
    
}