/*Test class of AGN_Spark_ForgotPasswordController
 */
@IsTest
public class AGN_Spark_ForgotPasswordControllerTest {
    public static testmethod void forgotPassword(){
        string user='testforgot@gmail.com';
        string EmailUrl='http;//test/salesforce/csipage';
        Test.startTest();
        AGN_Spark_ForgotPasswordController controller = new AGN_Spark_ForgotPasswordController();
        AGN_Spark_ForgotPasswordController.forgotPassword(user,EmailUrl);
        system.assertNotEquals(controller, null);
        Test.stopTest();
    }
     public static testmethod void forgotPasswordnegtive(){
        string user='';
        string EmailUrl='';
        Test.startTest();
        AGN_Spark_ForgotPasswordController.forgotPassword(user,EmailUrl);
        Test.stopTest();
    }
    public static testmethod void setExperienceId(){
        string expid='hl373736';
        Test.startTest();
        AGN_Spark_ForgotPasswordController forgotcontrl = new AGN_Spark_ForgotPasswordController();
        AGN_Spark_ForgotPasswordController.setExperienceId(expid);
        system.assertNotEquals(forgotcontrl, null);
        Test.stopTest();
    }
}