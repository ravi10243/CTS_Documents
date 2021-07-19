@isTest
public class LEXApplicationTriggerHandlerTest {
    
    public static List<MDAppFormMap__c> MDAppFormMapList;
    public static list<LEXForm__c> lexFormInsert = new list<LEXForm__c>();
    public static MDApplication__c mdApp;
    @testSetup
    public static void setUpTestData(){
        LEXForm__c lForm = new LEXForm__c();
        Database.insert(lForm);
        lexFormInsert.add(lForm);
        
        LEXFormStep__c lFormStep = new LEXFormStep__c(LEXForm__C = lForm.Id);
        Database.insert(lFormStep);
        
        MDForm__c newMDForm = new MDForm__c(Name = 'TestForm',URLKey__c = 'www.testURLKey.invalid');
        Database.insert(newMDForm);
        MDLocalisedForm__c newLocalForm = new MDLocalisedForm__c(MDForm__c = newMDForm.Id, Language__c = 'enGB');
        Database.insert(newLocalForm);
        
        MDFormStep__c newFormStep = new MDFormStep__c(MDForm__c = newMDForm.Id);
        Database.insert(newFormStep);
        Id formStepId = newFormStep.Id;
        
        MDForm__c mdform = new MDForm__c(ObjectAPIName__c = 'Account',URLKey__c= 'test',Name='xyz');
        
        insert mdForm;
        
        mdApp = new MDApplication__c(MetadataDeveloperName__c='Test name');
        insert mdApp;
        
        MDAppFormMap__c mdAppForm = new MDAppFormMap__c(MDApplication__c = mdApp.Id,MDForm__c = mdForm.id);
        insert mdAppForm;
        MDAppFormMapList= new List<MDAppFormMap__c>();
        MDAppFormMapList.add(mdAppForm);
        
        
        
        
        
    }
    @IsTest
    public static void LEXApplicationTriggerHandlerTest(){
        setUpTestData();
        Test.startTest(); 
        LEXApplication__c lexApp1 = new LEXApplication__c(MD_Application__c= mdApp.Id);
        insert lexApp1;
        Test.stopTest();
    }
}