@isTest
public class F3_LocalisedPicklistControllerTest {
	@testSetup
    public static void testSetup(){
        
        MDForm__c newMDForm = new MDForm__c(Name = 'TestForm',URLKey__c = 'www.testURLKey.invalid');
        Database.insert(newMDForm);
        
        MDFormStep__c newFormStep = new MDFormStep__c(MDForm__c = newMDForm.Id);
        Database.insert(newFormStep);
        Id formStepId = newFormStep.Id;
        
        MDComponent__c newComponent = new MDComponent__c(MDFormStep__c = formStepId);
        Database.insert(newComponent);
        
        
        List<MDLocalisedPicklistVal> listLocalisedPicklistVals = new List<MDLocalisedPicklistVal>();
        MDLocalisedPicklistVal val = new MDLocalisedPicklistVal();
        val.Include = true;
        val.OptionLabel = 'TestO';
        val.OptionValue = 'TestV';
        val.TranslatedLabel = 'TestT';
        listLocalisedPicklistVals.add(val);
        val = new MDLocalisedPicklistVal();
        val.Include = true;
        val.OptionLabel = 'TestO2';
        val.OptionValue = 'TestV2';
        val.TranslatedLabel = 'TestT2';
        listLocalisedPicklistVals.add(val);
        val = new MDLocalisedPicklistVal();
        val.Include = false;
        val.OptionLabel = 'TestO3';
        val.OptionValue = 'TestV3';
        val.TranslatedLabel = 'TestT3';
        listLocalisedPicklistVals.add(val);
        
        
        MDLocalisedComponent__c newLocalComponent = new MDLocalisedComponent__c(MDComponent__c=newComponent.Id,Language__c='enGB',ConfigJSON__c=System.JSON.serialize(listLocalisedPicklistVals));
        Database.insert(newLocalComponent);
    }
    @isTest
    public static void GetPicklistValTest(){
        Test.startTest();
        Id compId=[SELECT Id FROM MDComponent__c][0].Id;
        String langCode = 'enGB';
        System.assertEquals(2, F3_LocalisedPicklistController.GetPicklistVal(compId,langCode).size());
        Test.stopTest();
    }
    @isTest
    public static void GetPicklistOptTest(){
        Test.startTest();
        Id compId=[SELECT Id FROM MDComponent__c][0].Id;
        String langCode = 'enGB';
        System.assertEquals(2, F3_LocalisedPicklistController.GetPicklistOptions(compId,langCode).size());
        Test.stopTest();
    }
}