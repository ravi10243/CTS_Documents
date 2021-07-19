/*Test class of AGN_SPARK_ResetPasswordController
*/
@isTest
public class AGN_SPARK_ResetPasswordControllerTest {
    public static testmethod void internalChangePassword(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testsampleadmin@gmail.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testsampleadmin@gmail.com');
        insert u;
        System.runAs(u) {
            
        }
        Test.startTest();
        //Test.setCurrentPageReference(new PageReference(System.Label.AGN_AMI_Reset_Password_Internal_Page));
        AGN_SPARK_ResetPasswordController reset=new AGN_SPARK_ResetPasswordController();
        reset.verifyNewPassword='test@123';
        reset.pageName='page';
        reset.verifyUser='testsampleadmin@gmail.com';
        reset.newPassword='test@123';
        reset.internalChangePassword();
        system.assertEquals(reset.verifyNewPassword, 'test@123');
        System.assertNotEquals(null, reset);
        Test.stopTest();
    }
}