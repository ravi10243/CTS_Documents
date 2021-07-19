@isTest
public class MDFormTest {

    @isTest
    public static void MDFormStepCreatedTest() {
        MDForm__c form = new MDForm__c(
        	name = 'Test Name',
            URLKey__c = 'TestURL',
            Type__c = 'Data Capture - Success'
        );   
        Test.startTest();
        insert form;
       /* MDFormStep__c formStep = new MDFormStep__c(
            MDForm__c = form.Id,
            DeveloperName__c = 'Step 1',
            type__c = 'Success',
            StepOrder__c = 1,
            isActive__c = true
        );
        insert formStep; */
        List<MDFormStep__c> formSteps = [SELECT id, name FROM MDFormStep__c];

        System.assert(formSteps.size() == 2);
        Test.stopTest();
    }
    
}