@isTest
public class MDFormControllerTest {
    @isTest
    public static void GetMDFormsTest(){
        Test.startTest();
        MDForm__c newMDForm = new MDForm__c(Name = 'TestForm',URLKey__c = 'www.testURLKey.invalid');
        Database.insert(newMDForm);
      	System.assertEquals('TestForm', MDFormController.GetMDForms()[0].Name);
        Test.stopTest();
    }
    
    @isTest
    public static void getMdFormRecordTypeTest(){
        Test.startTest();
        RecordType recordType = [SELECT Id, DeveloperName FROM RecordType][0];
        Id newId;
        System.assertNotEquals(newId, MDFormController.getMdFormRecordTypeId(recordType.DeveloperName));
        Test.stopTest();
    }
}