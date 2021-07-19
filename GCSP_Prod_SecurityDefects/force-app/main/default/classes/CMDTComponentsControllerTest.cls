@isTest
public class CMDTComponentsControllerTest {
    @isTest public static void test_GetComponentsInDesigner(){
        MDForm__c mdform = new MDForm__c(ObjectAPIName__c = 'Account',URLKey__c= 'test');
        
        insert mdForm;
        
        CMDTComponentsController.GetComponentsInDesignerWrapper(mdForm.Id);
    }
}