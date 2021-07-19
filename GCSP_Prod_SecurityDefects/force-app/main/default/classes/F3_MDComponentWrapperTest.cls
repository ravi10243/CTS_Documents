@isTest
public class F3_MDComponentWrapperTest {
	public static MDComponent__c newComponent;
    @isTest
   public static void TestSetup(){
        MDForm__c newMDForm = new MDForm__c(Name = 'TestForm',URLKey__c = 'www.testURLKey.invalid');
        Database.insert(newMDForm);
        MDLocalisedForm__c newLocalForm = new MDLocalisedForm__c(MDForm__c = newMDForm.Id, Language__c = 'enGB');
        Database.insert(newLocalForm);
        
        MDFormStep__c newFormStep = new MDFormStep__c(MDForm__c = newMDForm.Id);
        Database.insert(newFormStep);
        Id formStepId = newFormStep.Id;
        
        
        newComponent = new MDComponent__c(IsActive__c = TRUE, MDFormStep__c = formStepId,ComponentType__c='test');
        Database.insert(newComponent);
        MDLocalisedComponent__c newLocalComponent = new MDLocalisedComponent__c(MDComponent__c = newComponent.Id,Language__c = 'enGB');
        Database.insert(newLocalComponent);
    }
    
    @isTest 
    public static void F3_MDComponentWrapperTest(){
        F3_MDComponentWrapper F3_MDComponentWrapperInst1=new F3_MDComponentWrapper();
        F3_MDComponentWrapper F3_MDComponentWrapperInst=new F3_MDComponentWrapper(newComponent);
        F3_MDComponentWrapperInst.PageElementId='a0R4J000001ICLmUAO' ;
        F3_MDComponentWrapperInst.CurrentLanguageCode='Test' ;
        F3_MDComponentWrapperInst.DeveloperName='Test';
        F3_MDComponentWrapperInst.PortalLabel='Test';
        F3_MDComponentWrapperInst.QuickHelpText='Test';
        F3_MDComponentWrapperInst.ContainerHtmlText='Test';
		F3_MDComponentWrapperInst.ContainerRichText='Test';
        F3_MDComponentWrapperInst.PageElement=newComponent;
        F3_MDComponentWrapperInst.DefaultValue='Test';
        F3_MDComponentWrapperInst.OnChangeViewState='Test';
        F3_MDComponentWrapperInst.IsHidden=TRUE;
        F3_MDComponentWrapperInst.ReadOnly=TRUE;
       
        string abc=F3_MDComponentWrapperInst.ElementType;
        Test.startTest();
        
        Test.stopTest();
        
         
    }
}