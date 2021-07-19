@isTest
public class AGN_ICL_RegFormInputFieldControllerTest {

   @isTest
   public static void testGetPicklistValues(){
   
       Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
       User usr = new User(Alias = 'ICLUsr',Email='testuser@allergan.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='testICLuser@allergan.com.icl');
       
       System.runAs(usr){
       String SObjectAPIName = 'Account';
       String FieldAPIName = 'Salutation';
       System.Test.startTest(); 
       List<AGN_ICL_TestRegFormInputFieldController.PicklistWrapper> piclistval =  AGN_ICL_TestRegFormInputFieldController.getPicklistValues(SObjectAPIName,FieldAPIName);
       //System.assertEquals(null, piclistval);
       System.assertNotEquals(null, piclistval);
       AGN_ICL_TestRegFormInputFieldController.PicklistWrapper wrapper = new AGN_ICL_TestRegFormInputFieldController.PicklistWrapper();
       //wrapper.label = '';
       //wrapper.value = '';
      // wrapper.isDefaultValue = false;
      }
    }
}