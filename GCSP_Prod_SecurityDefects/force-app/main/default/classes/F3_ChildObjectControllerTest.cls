@isTest
public class F3_ChildObjectControllerTest {

    @testSetup
    public static void TestSetup(){
    	MDComponent__c mdComp = new MDComponent__c();
        MDForm__c newMDForm = new MDForm__c(Name = 'TestForm',URLKey__c = 'www.testURLKey.invalid');
        Database.insert(newMDForm);
        MDLocalisedForm__c newLocalForm = new MDLocalisedForm__c(MDForm__c = newMDForm.Id, Language__c = 'enUS');
        Database.insert(newLocalForm);
        
        MDFormStep__c newFormStep = new MDFormStep__c(MDForm__c = newMDForm.Id);
        Database.insert(newFormStep);
        Id formStepId = newFormStep.Id;   
        
               
        MDComponent__c newComponent = new MDComponent__c(IsActive__c = TRUE, MDFormStep__c = formStepId, ConfigJSON__c = '');
        Database.insert(newComponent);
        MDLocalisedComponent__c newLocalComponent = new MDLocalisedComponent__c(MDComponent__c = newComponent.Id,Language__c = 'enGB');
        Database.insert(newLocalComponent);    
        
        Account acc= new Account(Name = 'TestAcc');
        Database.insert(acc); 
        
        Contact con= new Contact(LastName = 'LName');
        con.Cognizant_Id__c = Decimal.valueOf('12345');
        con.AccountId = acc.Id;
        Database.insert(con); 
       
    
    }
    @isTest
    public static void test_GetComponentConfigJSON(){
       Test.startTest();
        List<MDComponent__c> listComponents = 	[SELECT Id,
                                                 MDFormStep__c,
                                                 (SELECT Id,
                                                  Language__c              		
                                                  FROM MD_Localised_Components__r
                                                  WHERE Language__c = 'enUS')
                                                 FROM MDComponent__c];
        F3_ChildObjectController.GetComponentConfigJSON(listComponents[0].Id, 'enUS');
       Test.stopTest();
    }

@isTest
    public static void test_GetChildRecordId(){
       Test.startTest();

       	List<Account> acc = [select id, name from Account where name = 'TestAcc']; 
        F3_ChildObjectController.GetChildRecordId('Contact',acc[0].Id, 'AccountId');
       Test.stopTest();
    }
}