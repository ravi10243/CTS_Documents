@isTest
public class CaseTriggerTest {
	
    @isTest public static void test_CaseInsert(){
        MDForm__c mdform = new MDForm__c(ObjectAPIName__c = 'Account',URLKey__c= 'test');
        
        insert mdForm;
       	
        MDApplication__c mdApp = new MDApplication__c(MetadataDeveloperName__c='Test name');
        insert mdApp;
        
        MDAppFormMap__c mdAppForm = new MDAppFormMap__c(MDApplication__c = mdApp.Id,MDForm__c = mdForm.id);
        insert mdAppForm;
        
        Case c = new Case(MetadataDeveloperName__c='Test name');
        insert c;
    }
}