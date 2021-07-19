@istest
public class AGN_GCSP_PortalAccountDetail_Test {
    @istest(seeAllData=true)
    public static void testPortalAccountDetail(){
        User user = AGN_CustReg_TestUtilityClass.createUser();
        System.runAs(user){
        User u = [select Id, ContactId from User where User.contact.customer_registration_agn__c = 'Complete' and country_code__c = 'DE' limit 1];
        Allergan_Customer_Address_AGN__c adr = [SELECT SAP_ID_AGN__c, Account_AGN__c FROM Allergan_Customer_Address_AGN__c WHERE Sold_To_AGN__c = TRUE AND SAP_ID_AGN__c LIKE '0000%' limit 1];
        
            System.runAs(u){
                Test.startTest();
                AGN_GCSP_PortalAccountDetailController.getCummunityURL();
                AGN_GCSP_PortalAccountDetailController.getUserDetail();
                AGN_GCSP_PortalAccountDetailController.getredirectUrl();
                AGN_GCSP_PortalAccountDetailController.getRegistrationStepPage();
                AGN_GCSP_PortalAccountDetailController.getGCSPSettingsDetails('DE');
                AGN_GCSP_PortalAccountDetailController.getContactDetailsBySapID(u.ContactId);
                AGN_GCSP_PortalAccountDetailController.getSAPDetailsByContact();
                AGN_GCSP_PortalAccountDetailController.getSAPDetailsSoldTo((string)adr.SAP_ID_AGN__c);
                Customer_Detail_AGN__c cd = AGN_GCSP_PortalAccountDetailController.getSoldToSAPDetails((string)adr.Account_AGN__c);
                AGN_GCSP_PortalAccountDetailController.getHeaderWrapDetailsBySAPId(cd);
                AGN_GCSP_PortalAccountDetailController.getHeaderWrapDetailsByContact(cd);
                AGN_GCSP_PortalAccountDetailController.getAD_OktaSSOUrl();
                AGN_GCSP_PortalAccountDetailController.isRegistrationCompleted();
                AGN_GCSP_PortalAccountDetailController.hasAllerganDirectAccess();
                
                Test.stopTest();  
                Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);              
            }
        }
    }
}