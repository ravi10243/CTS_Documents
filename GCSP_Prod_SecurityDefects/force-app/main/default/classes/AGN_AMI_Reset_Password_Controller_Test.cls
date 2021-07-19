@isTest
public class AGN_AMI_Reset_Password_Controller_Test {
    
 @isTest
    public static void testResetPasswordController()
    {
        Test.startTest();
        Test.setCurrentPageReference(new PageReference(System.Label.AGN_AMI_Reset_Password_Internal_Page)); 
        AGN_AMI_Reset_Password_Controller resetPassCon = new AGN_AMI_Reset_Password_Controller();
        System.assertNotEquals(null, resetPassCon);
        resetPassCon.internalChangePassword();
        Test.stopTest();
    }
}