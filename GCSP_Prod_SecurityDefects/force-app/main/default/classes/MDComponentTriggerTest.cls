@isTest
public class MDComponentTriggerTest {
	@IsTest
    public static void test_mdComponent(){
        MDForm__c mdForm = new MDForm__c();
        insert mdForm;
        MDFormStep__c mdStep = new MDFormStep__c(MDForm__c=mdForm.Id);
        insert mdStep;
        MDComponent__c mdComponent = new MDComponent__c(MDFormStep__c = mdStep.Id);
        
        insert mdComponent;
    }
}