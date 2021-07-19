@isTest
	public class AGN_ICL_FooterController_Test {
@istest
    static void testfooter(){
          Test.Starttest();
       
        AGN_ICL_Language_Settings__c ail=new AGN_ICL_Language_Settings__c();
        ail.Name='English';
        ail.Language_Code_AGN__c='en_US';
        insert ail;
        
       
         AGN_ICL_FooterController aif=new AGN_ICL_FooterController();
         aif.value='';
          Test.StopTest();      
        
    }
}