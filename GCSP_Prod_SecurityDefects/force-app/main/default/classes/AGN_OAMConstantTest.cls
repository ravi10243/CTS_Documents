@isTest
public class AGN_OAMConstantTest {
    
    public static testmethod void CustPortalTest(){ 
        
        user u = AGN_CustReg_TestUtilityClass.createUser();
        
        System.runAs(u){
            OAM_User_Settings__c oamUser = AGN_CustReg_TestUtilityClass.createOAMUser();
            System.Assert(oamUser != null, 'create OAM_User_Settings_UnitTest.testCreating OAM_UserSettings FAIL: OAM_UserSettings was not inserted properly!');
            AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();
            System.Assert(gcspSettings != null, 'AGN_GCSP_Settings_UnitTest.testCreating AGN_GCSP_Settings FAIL: AGN_GCSP_Settings was not inserted properly!');
        }
        
        test.starttest();             
        
        AGN_OAMConstant cc = new AGN_OAMConstant();            
        string DEFAULT_OKTA_RECOVERY_QUETIONS = AGN_OAMConstant.DEFAULT_OKTA_RECOVERY_QUETION;
        string DEFAULT_OKTA_RECOVERY_ANSWERS = AGN_OAMConstant.DEFAULT_OKTA_RECOVERY_ANSWER;
        string USERCOUNTRYCODE = AGN_OAMConstant.USERCOUNTRYCODE; 
        string USERLANGUAGE = AGN_OAMConstant.USERLANGUAGE;
        string USERLOCAL= AGN_OAMConstant.USERLOCAL;  
        
        AGN_GoogleCAPTCHAv2Controller agncontroller = new AGN_GoogleCAPTCHAv2Controller();
        agncontroller.getCaptchaKey();
        
        test.stopTest();
            
   }
    
}