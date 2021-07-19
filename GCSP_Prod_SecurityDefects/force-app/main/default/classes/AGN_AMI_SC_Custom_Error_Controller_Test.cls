@isTest
public class AGN_AMI_SC_Custom_Error_Controller_Test { 
  @isTest
    public static void testCustom_Error_Controller()
    {
        Test.startTest();     
            AGN_AMI_SC_Custom_Error_Controller errorController = new AGN_AMI_SC_Custom_Error_Controller(); 
            System.assertNotEquals(null, errorController);
           PageReference testpr4 = errorController.yourPageLevelAction();
        Test.stopTest();
    }
}