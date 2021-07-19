@isTest
public class F3_MDFormStepWrapperTest {
    public static MDComponent__c newComponent;
    public static MDFormStep__c newFormStep;
    public static LIst<F3_MDComponentWrapper> F3_MDComponentWrapperList;
    @isTest
    public static void setUpTestData(){
        MDForm__c newMDForm = new MDForm__c(Name = 'TestForm',URLKey__c = 'www.testURLKey.invalid');
        insert newMDForm;
        MDLocalisedForm__c newLocalForm = new MDLocalisedForm__c(MDForm__c = newMDForm.Id, Language__c = 'enGB');
        Database.insert(newLocalForm);
        
        newFormStep = new MDFormStep__c(MDForm__c = newMDForm.Id);
        insert newFormStep;
        Id formStepId = newFormStep.Id;
        
        
        newComponent = new MDComponent__c(IsActive__c = TRUE, MDFormStep__c = formStepId,ComponentType__c='test');
        Database.insert(newComponent);
        MDLocalisedComponent__c newLocalComponent = new MDLocalisedComponent__c(MDComponent__c = newComponent.Id,Language__c = 'enGB');
        Database.insert(newLocalComponent);
    }
    
    @isTest 
    public static void F3_MDFormStepWrapperTest(){
        setUpTestData();
        F3_MDFormStepWrapper F3_MDFormStepWrapperinst1=new F3_MDFormStepWrapper();
        F3_MDFormStepWrapper F3_MDFormStepWrapperinst2=new F3_MDFormStepWrapper(newFormStep);
        F3_MDFormStepWrapperinst2.PageFormStepId='abc';
        F3_MDFormStepWrapperinst2.Description='descrip';
        F3_MDFormStepWrapperinst2.ShortName='name';
        F3_MDFormStepWrapperinst2.PortalLabel='label';
        F3_MDFormStepWrapperinst2.StepType='type';
        F3_MDFormStepWrapperinst2.SaveButtonLabel='button Label';
        F3_MDFormStepWrapperinst2.SaveNextButtonLabel='saveButton';
        F3_MDFormStepWrapperinst2.SavePreviousButtonLabel='pButton';
       // F3_MDFormStepWrapperinst2.PageFormStep=newFormStep;
        
        
        Test.startTest();
        
        F3_MDComponentWrapper F3_MDComponentWrapperins=new F3_MDComponentWrapper();
        F3_MDComponentWrapperList=new List<F3_MDComponentWrapper>();
        F3_MDComponentWrapperList.add(F3_MDComponentWrapperins);
        
        F3_MDFormStepWrapper F3_MDFormStepWrapperinst3=new F3_MDFormStepWrapper(newFormStep,F3_MDComponentWrapperList);
        
         Id mdFormID = [SELECT Id FROM MDForm__c][0].Id;

        List<MDComponent__c> listComponents = 	[SELECT Id,
                                               	MDFormStep__c,
                                               		(SELECT Id,
                                                	Language__c              		
                                                	FROM MD_Localised_Components__r
                                                	WHERE Language__c = 'enGB')
                                             	FROM MDComponent__c];
        Id mdFormStepID = listComponents[0].MDFormStep__c;
        
        
        
        F3_MDSitePageWrapper resultWrapper = F3_SitePageController.GetLocalisedPage(mdFormID,'enGB',mdFormStepID);
        System.assertNotEquals(null,resultWrapper,'Null returned');
        Test.stopTest();
        
        
    }
}