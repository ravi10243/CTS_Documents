@isTest
public class F3_SitePageControllerTest {
    //public static ID formStepId;
    @testSetup
    public static void TestSetup(){
        MDForm__c newMDForm = new MDForm__c(Name = 'TestForm',URLKey__c = 'www.testURLKey.invalid');
        Database.insert(newMDForm);
        MDLocalisedForm__c newLocalForm = new MDLocalisedForm__c(MDForm__c = newMDForm.Id, Language__c = 'enGB');
        Database.insert(newLocalForm);
        
        MDFormStep__c newFormStep = new MDFormStep__c(MDForm__c = newMDForm.Id);
        Database.insert(newFormStep);
        Id formStepId = newFormStep.Id;
        
        
        MDComponent__c newComponent = new MDComponent__c(IsActive__c = TRUE, MDFormStep__c = formStepId);
        Database.insert(newComponent);
        MDLocalisedComponent__c newLocalComponent = new MDLocalisedComponent__c(MDComponent__c = newComponent.Id,Language__c = 'enGB');
        Database.insert(newLocalComponent);
    }
        @isTest
    public static void getPreviousStepIdTest(){
        Test.startTest();
        List<MDComponent__c> listComponents = 	[SELECT Id,
                                                 MDFormStep__c,
                                                 (SELECT Id,
                                                  Language__c              		
                                                  FROM MD_Localised_Components__r
                                                  WHERE Language__c = 'enGB')
                                                 FROM MDComponent__c];
        Id mdFormStepID = listComponents[0].MDFormStep__c;
        System.assertNotEquals(null,F3_SitePageController.GetPreviousStepId(mdFormStepID));
        Test.stopTest();
    }
    @isTest
    public static void getNextStepIdTest(){
        Test.startTest();
        List<MDComponent__c> listComponents = 	[SELECT Id,
                                                 MDFormStep__c,
                                                 (SELECT Id,
                                                  Language__c              		
                                                  FROM MD_Localised_Components__r
                                                  WHERE Language__c = 'enGB')
                                                 FROM MDComponent__c];
        Id mdFormStepID = listComponents[0].MDFormStep__c;

        System.assertNotEquals(null,F3_SitePageController.GetNextStepId(mdFormStepID));
        Test.stopTest();
    }
    
    
    @isTest
    public static void GetLocalisedPageURLKeyTest(){
        Test.startTest();
        Id mdFormID = [SELECT Id FROM MDForm__c][0].Id;


        List<MDComponent__c> listComponents = 	[SELECT Id,
                                               	MDFormStep__c,
                                               		(SELECT Id,
                                                	Language__c              		
                                                	FROM MD_Localised_Components__r
                                                	WHERE Language__c = 'enGB')
                                             	FROM MDComponent__c];
        
        Id mdFormStepID = listComponents[0].MDFormStep__c;
        F3_MDSitePageWrapper resultWrapper = F3_SitePageController.GetLocalisedPage('www.testURLKey.invalid','enGB',(String)mdFormStepID);
        System.assertNotEquals(null,resultWrapper,'Null returned');
        Test.stopTest();
    }
    @isTest
    public static void GetLocalisedPageIdTest(){
        Test.startTest();

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
    @isTest
    public static void testLEXSOQLMethod(){
        Test.startTest();
        LEXApplication__c newLEXApplication = new LEXApplication__c(Name='TestApplication');
        Database.insert(newLEXApplication);
        System.assertEquals('TestApplication',F3_SitePageController.getApplicationById(newLEXApplication.Id).Name);
        Test.stopTest();
    }

}