@isTest
public class AGN_Brandprotectionattachmenttest
{
    @istest
    static void AGN_Brandprotectionattachmenttest()
    {
        Test.Starttest();
        
                   
               User u= new User ();
               u.lastname='test';
               u.profileid='00e1o0000017RTo';
               u.division='Legal';
               u.Username='abcqwerty@gmail.com';
                u.Email='abc@gmail.com'; 
        		u.Alias='ali';
                 u.TimeZoneSidKey='Europe/London';
                 u.LocaleSidKey='en_GB';
                 u.EmailEncodingKey='ISO-8859-1';
                  u.LanguageLocaleKey='en_US';
               Insert u;
        
        Allergan_Incident_AGN__c ai=new Allergan_Incident_AGN__c();
        ai.BrandCountry_AGN__c='a3L6E000000kiqV';
        ai.Status_AGN__c='Open';
        Insert ai;
        
        Apexpages.StandardController sc = new Apexpages.standardController(ai);
 
        AGN_Brandprotectionattachment abpa=new AGN_Brandprotectionattachment(sc);
       
                   
        Test.StopTest();      
    }

}