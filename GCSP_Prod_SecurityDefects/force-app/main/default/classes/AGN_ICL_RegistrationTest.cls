@isTest
public class AGN_ICL_RegistrationTest 
{
    @istest
    static void test()
    {
        Test.Starttest();
        
       AGN_ICL_Country_Settings__c aic=new AGN_ICL_Country_Settings__c ();
            aic.Name='India';
            aic.Country_AGN__c='BR';
            aic.Default_Language_AGN__c='French';
            aic.Language_AGN__c='fr';
            aic.Multi_Language_AGN__c='English,French,German';
            aic.Redirect_URL_AGN__c='https://gcldev-allergancommunitycore.cs84.force.com/gcldevallergan';
            insert aic;
            
        AGN_ICL_Language_Settings__c ail=new AGN_ICL_Language_Settings__c();
            ail.Name='English';
            ail.Language_Code_AGN__c='en_US';
            insert ail;
              
            PageReference pageRef = Page.AGN_ICL_Registration;
            pageRef.getParameters().put('lang', String.valueOf(aic.Default_Language_AGN__c));
             pageRef.getParameters().put('country', String.valueOf(aic.Country_AGN__c));
             pageRef.getParameters().put('ref', String.valueOf(ail.Name));
             
            
            Test.setCurrentPage(pageRef);
            AGN_ICL_Registration obj= new AGN_ICL_Registration();
            obj.language();
            obj.changedlanguage();
            obj.change();
            obj.submit();
        
        Test.StopTest();      
    }

}