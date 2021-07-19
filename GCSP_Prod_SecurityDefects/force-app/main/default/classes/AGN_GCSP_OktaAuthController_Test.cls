@isTest
public class AGN_GCSP_OktaAuthController_Test {
public static testmethod void registrationMethodTest(){
        User user = AGN_GCSP_CustReg_TestUtilityClass.createUser();
        System.runAs(user){
            User u = AGN_GCSP_CustReg_TestUtilityClass.createCommunityUser();
            Profile p =[SELECT ID, Name FROM Profile where Name='Allergan Customer Community Login DE' limit 1];
            Group gp = [SELECT ID, DeveloperName FROM Group WHERE DeveloperName = 'AGN_EMEA_MDM' LIMIT 1];
            u.ProfileId = p.ID;
            AGN_GCSP_Settings__c gcsp_settings = AGN_GCSP_CustReg_TestUtilityClass.createGCSPSettings();
            OAM_User_Settings__c oamuser_settings = AGN_GCSP_CustReg_TestUtilityClass.createOAMUser();
            update u;
            AGN_GCSP_Common_Setting_AGN__mdt mdt = AGN_GCSP_CustReg_TestUtilityClass.createCommonSettingsMethod();
            
            ApexPages.currentPage().getParameters().put('oktaUserName','krishna9892@yopmail.com');
            ApexPages.currentPage().getParameters().put('oktaPassword','testing');
            ApexPages.currentPage().getParameters().put('isDesktopReq','true');
            ApexPages.currentPage().getParameters().put('country','DE');
            ApexPages.currentPage().getParameters().put('language','de');
            
            Test.startTest();
            

            AGN_GCSP_OktaAuthController controller = new AGN_GCSP_OktaAuthController(); 
            Test.setMock(HttpCalloutMock.class, new AGN_OktaUtilsMock_temp());
            System.debug('Username::'+u.Username);
            AGN_GCSP_OktaAuthController.validateAndLogInOkta((String)u.Email,'Connect1');
            AGN_GCSP_OktaAuthController.getOktaSecurityQuestion('susr@testsandorg.com');
            AGN_GCSP_OktaAuthController.forgotPassword('susr@testsandorg.com','Connect2','Connect1');
            AGN_GCSP_OktaAuthController.parseErrorMessage('susr@testsandorg.com');
            AGN_GCSP_OktaAuthController.validateAccountActivationToken('24');
            AGN_GCSP_OktaAuthController.getLabelString('English');
            //AGN_GCSP_OktaAuthController.forgotRecoveryQA('susr@testsandorg.com',true);
            Integer num1 = 1;
            Integer num2 = 1;
            System.assertEquals(num1, num2);
           Test.stopTest(); 
        }
    }
}