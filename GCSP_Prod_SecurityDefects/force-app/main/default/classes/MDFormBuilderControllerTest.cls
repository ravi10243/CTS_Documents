@isTest
public class MDFormBuilderControllerTest {

     @testSetup
    public static void TestSetup(){
    	MDComponent__c mdComp = new MDComponent__c();
        MDForm__c newMDForm = new MDForm__c(Name = 'TestForm',URLKey__c = 'www.testURLKey.invalid',ObjectAPIName__c = 'Account',
                                            PropertiesJSON__c='[{"PropertyValue":false,"PropertyLabel":"Show Language Selector","PropertyKey":"ShowLanguageSelector"}]' );
        Database.insert(newMDForm);
        MDLocalisedForm__c newLocalForm = new MDLocalisedForm__c(MDForm__c = newMDForm.Id, Language__c = 'enUS');
        Database.insert(newLocalForm);
        
        MDFormStep__c newFormStep = new MDFormStep__c(MDForm__c = newMDForm.Id);
        Database.insert(newFormStep);
        Id formStepId = newFormStep.Id;        
        
        MDComponent__c newComponent = new MDComponent__c(IsActive__c = TRUE, DataFieldAPIName__c = 'Industry',MDFormStep__c = formStepId, ConfigJSON__c = '',ComponentType__c='test');
        Database.insert(newComponent);
        MDLocalisedComponent__c newLocalComponent = new MDLocalisedComponent__c(MDComponent__c = newComponent.Id,Language__c = 'enGB');
        Database.insert(newLocalComponent); 
    }
    @isTest
    public static void test_GetMDFormProperties(){
       Test.startTest();
        List<MDForm__c> listForm = 	[SELECT Id FROM MDForm__c where Name = 'TestForm'];
        MDFormBuilderController.GetMDFormProperties(listForm[0].Id);
       Test.stopTest();
    }
    @isTest
    public static void test_SaveMDFormProperties(){
       Test.startTest();
        List<MDForm__c> listForm = 	[SELECT Id FROM MDForm__c where Name = 'TestForm'];
        MDFormPropertyWrapper test1= new MDFormPropertyWrapper();
        test1.PropertyKey='ShowLanguageSelector';
        test1.PropertyLabel='Show Language Selector';
        test1.PropertyValue=false;
        List<MDFormPropertyWrapper> listProperties= new  List<MDFormPropertyWrapper>();
        listProperties.add(test1); 
        MDFormBuilderController.SaveMDFormProperties(listProperties,listForm[0].Id);
       Test.stopTest();
    }  
     @isTest
    public static void test_GetLocalisedMDFormRecords(){
       Test.startTest();
        List<MDForm__c> listForm = 	[SELECT Id FROM MDForm__c where Name = 'TestForm'];
        MDFormBuilderController.GetLocalisedMDFormRecords(listForm[0].Id);
       Test.stopTest();
    }
     @isTest
    public static void test_GetMDFormBranding(){
       Test.startTest(); 
        List<MDForm__c> listForm = [SELECT Id FROM MDForm__c where Name = 'TestForm'];
        MDFormBuilderController.GetMDFormBranding(listForm[0].Id);
       Test.stopTest();
    }
     @isTest
    public static void test_GetMDComponentBranding(){
       Test.startTest(); 
        list<MDComponent__c> newComponent = [SELECT Id FROM MDComponent__c];
        MDFormBuilderController.GetMDComponentBranding(newComponent[0].Id);
       Test.stopTest();
    }
     @isTest
    public static void test_SaveMDFormBranding(){
       Test.startTest(); 
        List<MDForm__c> listForm = [SELECT Id FROM MDForm__c where Name = 'TestForm'];
        
        MDCSSPropertyWrapper text3= new MDCSSPropertyWrapper('ShowLanguageSelector','false'); 
        MDCSSPropertyWrapper text4= new MDCSSPropertyWrapper();
        text4.PropertyKey='ShowLanguageSelector';
        text4.PropertyType='Show Language Selector';
        text4.PropertyValue='false';
        text4.ScreenLabel='Font';
        
        MDCSSElementPropertyWrapper test2= new MDCSSElementPropertyWrapper();
        test2.ElementKey='abc';
        test2.ScreenLabel='Font';
        test2.ListProperty= new list<MDCSSPropertyWrapper>();
        test2.ListProperty.add(text4);
        
        
        MDCSSFormAreaWrapper test1= new MDCSSFormAreaWrapper();
        test1.ScreenLabel='Font';
        test1.ListElement= new list<MDCSSElementPropertyWrapper>();
        test1.ListElement.add(test2);
        
        List<MDCSSFormAreaWrapper> listProperties= new List<MDCSSFormAreaWrapper>();
        listProperties.add(test1); 
        
        MDFormBuilderController.SaveMDFormBranding(listProperties,listForm[0].Id);
       Test.stopTest();
    }
     @isTest
    public static void test_SaveMDComponentBranding(){
       Test.startTest(); 
        list<MDComponent__c> newComponent = [SELECT Id FROM MDComponent__c];
        
        MDCSSPropertyWrapper text3= new MDCSSPropertyWrapper('ShowLanguageSelector','false'); 
        MDCSSPropertyWrapper text4= new MDCSSPropertyWrapper();
        text4.PropertyKey='ShowLanguageSelector';
        text4.PropertyType='Show Language Selector';
        text4.PropertyValue='false';
        text4.ScreenLabel='Font';
        
        MDCSSElementPropertyWrapper test2= new MDCSSElementPropertyWrapper();
        test2.ElementKey='abc';
        test2.ScreenLabel='Font';
        test2.ListProperty= new list<MDCSSPropertyWrapper>();
        test2.ListProperty.add(text4);
        
        
        MDCSSFormAreaWrapper test1= new MDCSSFormAreaWrapper();
        test1.ScreenLabel='Font';
        test1.ListElement= new list<MDCSSElementPropertyWrapper>();
        test1.ListElement.add(test2);
               
        MDFormBuilderController.SaveMDComponentBranding(test1,newComponent[0].Id);
        MDFormBuilderController.GetListOfSObject();
       Test.stopTest();
    }
     @isTest
    public static void test_GetMDFormWrapper(){
       Test.startTest();
        List<MDForm__c> listForm = 	[SELECT Id FROM MDForm__c where Name = 'TestForm'];
        MDFormBuilderController.GetMDFormWrapper(listForm[0].Id);
       Test.stopTest();
    }
    
     @isTest
    public static void test_GetLocalisedMDFormStepRecords(){
       Test.startTest();
        list<MDFormStep__c> newStep = [SELECT Id FROM MDFormStep__c];
        MDFormBuilderController.GetLocalisedMDFormStepRecords(newStep[0].Id);
       Test.stopTest();
    }
     @isTest
    public static void test_GetLocalisedMDStepComponentRecords(){
       Test.startTest();
        list<MDLocalisedComponent__c> newComponent = [SELECT Id FROM MDLocalisedComponent__c];
        MDFormBuilderController.GetLocalisedMDStepComponentRecords(newComponent[0].Id);
       Test.stopTest();
    }
     @isTest
    public static void test_GetSitePageWrapper(){
       Test.startTest();
        List<MDForm__c> listForm = 	[SELECT Id FROM MDForm__c where Name = 'TestForm'];
        list<MDFormStep__c> newStep = [SELECT Id FROM MDFormStep__c];
        MDFormBuilderController.GetSitePageWrapper(listForm[0].id,newStep[0].Id);
       Test.stopTest();
    }
     @isTest
    public static void test_GetFirstStepId(){
       Test.startTest();
        list<MDFormStep__c> newStep = [SELECT Id FROM MDFormStep__c];
        MDFormBuilderController.GetFirstStepId(newStep[0].Id);
       Test.stopTest();
    }
    
     @isTest
    public static void test_GetChildObjectOneConfig(){
       Test.startTest();
        list<MDComponent__c> newComponent = [SELECT Id FROM MDComponent__c];
        MDFormBuilderController.GetChildObjectOneConfig(newComponent[0].Id);
       Test.stopTest();
    }
     @isTest
    public static void test_GetComponentConfigJSON(){
       Test.startTest();
        list<MDComponent__c> newComponent = [SELECT Id FROM MDComponent__c];
        MDFormBuilderController.GetComponentConfigJSON(newComponent[0].Id);
        MDFormBuilderController.GetLocalisedComponentConfigJSON(newComponent[0].Id);
       Test.stopTest();
    }
     @isTest
    public static void test_SaveLocalisedComponentConfigJSON(){
       Test.startTest();
        list<MDLocalisedComponent__c> newComponent = [SELECT Id FROM MDLocalisedComponent__c];
        MDFormBuilderController.SaveLocalisedComponentConfigJSON(newComponent[0].Id,'testJson');
       Test.stopTest();
    }
    
     @isTest
    public static void test_SaveChildObjectOneConfig(){
       Test.startTest();
        list<MDComponent__c> newComponent = [SELECT Id FROM MDComponent__c];
        MDFormBuilderController.SaveChildObjectOneConfig('testJson',newComponent[0].Id);
       Test.stopTest();
    }    
     @isTest
    public static void test_GetLocalisedPicklistValues(){
       Test.startTest();
        list<MDLocalisedComponent__c> newComponent = [SELECT Id FROM MDLocalisedComponent__c];
        MDFormBuilderController.GetLocalisedPicklistValues(newComponent[0].Id);
       Test.stopTest();
    }
}