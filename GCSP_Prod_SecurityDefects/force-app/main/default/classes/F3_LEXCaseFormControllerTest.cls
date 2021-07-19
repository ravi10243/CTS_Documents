@isTest
public class F3_LEXCaseFormControllerTest {
    
    @testSetup
    public static void testSetup(){
        LEXForm__c lForm = new LEXForm__c();
        Database.insert(lForm);
        
        LEXFormStep__c lFormStep = new LEXFormStep__c(LEXForm__C = lForm.Id);
        Database.insert(lFormStep);
    }
    
	@isTest
    public static void GetLEXFormStepWrapperTest(){
        Id lFormStepId = [SELECT Id FROM LEXFormStep__c][0].Id;
        F3_LEXCaseFormController.GetLEXFormStepWrapper(lFormStepId);
    }
    
    @isTest
    public static void GetLEXFormsForACaseTest(){
        System.assertEquals(0,F3_LEXCaseFormController.GetLEXFormsForACase('invalid string').size());
    }
    @isTest
    public static void GetLEXFormStepsForAFormTest(){
        Id blankId;
        System.assertEquals(0,F3_LEXCaseFormController.GetLEXFormStepsForAForm(blankId).size());
    }
    
    @isTest
    public static void UpdateObjectRecordIDTest(){
        LEXFormStep__c lfs = [SELECT Id,LEXForm__c FROM LEXFormStep__c];
        Id lFormId = lfs.LEXForm__c;
        Id lFormStepId = lfs.Id;
        Id blankId;
        System.AssertEquals(blankId,F3_LEXCaseFormController.UpdateObjectRecordID(lFormId,blankId,lFormStepId,'invalid string').FormObjectRecordId__c);
    }
    
    @isTest
    public static void GetPreviousStepContextTest(){
        try{
        LEXFormStep__c lfs = [SELECT Id,LEXForm__c FROM LEXFormStep__c];
        Id lFormId = lfs.LEXForm__c;
        Id lFormStepId = lfs.Id;
        Id blankId;
        F3_LEXCaseFormController.GetPreviouStepContext(lFormStepId,blankId);
        }catch(System.ListException e){
            
        }
    }
    @isTest
    public static void GetNextStepContextTest(){
        try{
        LEXFormStep__c lfs = [SELECT Id,LEXForm__c FROM LEXFormStep__c];
        Id lFormId = lfs.LEXForm__c;
        Id lFormStepId = lfs.Id;
        Id blankId;
        F3_LEXCaseFormController.GetNextStepContext(lFormStepId,blankId);
        }catch(System.ListException e){
            
        }
    }
}