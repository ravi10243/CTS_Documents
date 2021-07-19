@isTest
private class AGN_OnlineConsent_CookieControllerTest{
    
    @TestSetup
    static void setup()
    {
       List<Allergan_Consent_Cookie_Info__c> ACCIlist = new List<Allergan_Consent_Cookie_Info__c>();
       Allergan_Consent_Cookie_Info__c ACCI = new Allergan_Consent_Cookie_Info__c();
       ACCI.CurrencyIsoCode = 'EUR';
       ACCIlist.add(ACCI );
       insert ACCIlist; 
    }

     @isTest
    static void AGNOnlineConsentCookieControllerTest() {  
         List<Allergan_Consent_Cookie_Info__c> ACClist = new List<Allergan_Consent_Cookie_Info__c>();
         StringCarrier s = new StringCarrier();
         s.value='abc';
         AGN_OnlineConsent_CookieController AOCCC = new AGN_OnlineConsent_CookieController();
         AOCCC.Slanguage = s;
         AOCCC.getCookieMesg = 'abc';
         string abc = AOCCC.getCookieMesg;
         AOCCC.NextPage();
       }
        
}