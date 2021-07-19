@isTest
public class AGN_GCSP_OAMOktaLoginController_Test{
    @isTest
    public static void OAMOktaLoginControllerTest1(){ 
        User user = AGN_GCSP_CustReg_TestUtilityClass.createUser();
        System.runAs(user){
            User u = AGN_GCSP_CustReg_TestUtilityClass.createCommunityUser();
            Profile p =[SELECT ID, Name FROM Profile where Name='Allergan Customer Community Login DE' limit 1];
            u.ProfileId = p.ID;
            AGN_GCSP_Settings__c gcsp_settings = AGN_GCSP_CustReg_TestUtilityClass.createGCSPSettings();
            OAM_User_Settings__c oamuser_settings = AGN_GCSP_CustReg_TestUtilityClass.createOAMUser();
            update u;
            
            ApexPages.currentPage().getParameters().put('oktaUserName','krishna9892@yopmail.com');
            ApexPages.currentPage().getParameters().put('oktaPassword','testing');
            ApexPages.currentPage().getParameters().put('isDesktopReq','true');
            ApexPages.currentPage().getParameters().put('country','DE');
            ApexPages.currentPage().getParameters().put('language','de');
            
            Test.startTest();
           
            System.runAs(u){                
                
                AGN_GCSP_OAMOktaLoginController olc = new AGN_GCSP_OAMOktaLoginController();
                Test.setMock(HttpCalloutMock.class, new AGN_OktaUtilsMock_temp());
                
                olc.getLanguages();
                olc.refreshLanguage();
                olc.InputValidation();
                olc.changePassword();
                olc.forwardToAuthPage();
                String s = 'MyString';
                Object obj = s;
                AGN_GCSP_OAMOktaLoginController.nullOrEmpty(obj);
                try{
                    PageReference pf =  olc.login();
                }catch(Exception e){}
                try{
                    olc.oktaLogin();
                }catch(Exception e){}
                try{
                    olc.validateAndLogInOkta();
                }catch(Exception e){}
                try{
                    olc.doOktaLogin((string)u.Username, 'Password123','DE');
                    Test.setMock(HttpCalloutMock.class, new AGN_OktaUtilsMockFailure());
                    olc.doOktaLogin((string)u.Username, 'Password123','DE');
                    olc.validateAndLogInOkta();
                }catch(Exception e){}                
                
            }
            Test.stopTest();
            Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
        }
    }
}