/*
    02/09/15    SB @ IC    00110773
*/
@isTest
public class AGN_CoolNetLoginControllerTest 
{
    
    @isTest
    public static void testController() {
        User u = [SELECT Username FROM User WHERE IsActive = true LIMIT 1];
        
        Test.startTest();
        
        AGN_CoolNetLoginController control = new AGN_CoolNetLoginController();
                        
        control.login();
        System.assertEquals('You must enter both a username and password.',control.error);
        
        control.username = 'testtesttest';
        control.password = 'password';
        control.login();
        System.assertEquals('The username you entered is invalid. Your username should be the email address you registered with.',control.error);
        
        control.username = u.Username;
        control.login();
        System.assertEquals('Your login attempt has failed. The password may be incorrect, or your location or login time may be restricted. Please contact the administrator at your company for help.',control.error);
        control.login();
        
        control.supportCase.SuppliedName = 'Tester';
        control.supportCase.SuppliedCompany = 'Test Co';
        control.supportCase.SuppliedPhone = '2813308004';
        control.submitCase();
        
        control.forgotPassword();
        control.submitUsername();
        Test.stopTest();
    }
    
     @isTest
    public static void testController1() {
        User u = [SELECT Username FROM User WHERE IsActive = true LIMIT 1];
        
        Test.startTest();
        PageReference PageRef = Page.AGN_CoolNetLogin;
        Test.setCurrentPage(PageRef);
        ApexPages.currentPage().getParameters().put('redirect', 'NewValue');
        ApexPages.currentPage().getParameters().put('startURL', 'theValue');
        
        AGN_CoolNetLoginController control = new AGN_CoolNetLoginController();
                        
        control.login();
        System.assertEquals('You must enter both a username and password.',control.error);
        
        control.username = 'testtesttest';
        control.password = 'password';
        control.login();
        System.assertEquals('The username you entered is invalid. Your username should be the email address you registered with.',control.error);
        
        control.username = u.Username;
        control.login();
        System.assertEquals('Your login attempt has failed. The password may be incorrect, or your location or login time may be restricted. Please contact the administrator at your company for help.',control.error);
        control.login();
        
        control.supportCase.SuppliedName = 'Tester';
        control.supportCase.SuppliedCompany = 'Test Co';
        control.supportCase.SuppliedPhone = '2813308004';
        control.submitCase();
        
        control.forgotPassword();
        control.submitUsername();
        Test.stopTest();
    }
}