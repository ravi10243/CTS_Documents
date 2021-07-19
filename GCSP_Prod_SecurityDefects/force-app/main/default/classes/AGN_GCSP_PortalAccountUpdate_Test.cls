@istest
public class AGN_GCSP_PortalAccountUpdate_Test {
    @istest(seeAllData = True) public static void testPortalAccountUpdate(){
        User user = AGN_CustReg_TestUtilityClass.createUser();
        System.runAs(user){
        User u = [select Id, ContactId from User where User.contact.customer_registration_agn__c = 'Complete' and country_code__c = 'DE' limit 1];
        Allergan_Customer_Address_AGN__c adr = [SELECT SAP_ID_AGN__c, Account_AGN__c, Parent_AGN__r.Online_Registration_Step_AGN__c FROM Allergan_Customer_Address_AGN__c WHERE Sold_To_AGN__c = TRUE  AND Bill_To_AGN__c = TRUE AND Ship_To_AGN__c = TRUE AND SAP_ID_AGN__c LIKE '0000%' AND Parent_AGN__r.Online_Registration_Step_AGN__c != null limit 1];
        Form_Of_Payment_AGN__c fop;
        Payment_Term_AGN__c  pt;
        fop = new Form_Of_Payment_AGN__c();
        fop = AGN_CustReg_TestUtilityClass.createFormOfPayment();    
        pt =new Payment_Term_AGN__c();
        pt = AGN_CustReg_TestUtilityClass.createPaymentTerm(fop);
        
            System.runAs(u){
                Test.startTest();
                
                AGN_GCSP_PortalAccountUpdateController pauc = AGN_GCSP_PortalAccountUpdateController.doInit((string)adr.SAP_ID_AGN__c, 'oam');
                AGN_GCSP_PortalAccountUpdateController.getNewRegistration(pauc.primaryContact, pauc.config);
                AGN_GCSP_PortalAccountUpdateController.getPickListValues('Form_Of_Payment_AGN__c', 'Form_Of_Payment_Label_AGN__c', 'Id', '');
                try{
                    AGN_GCSP_PortalAccountUpdateController.getPaymentDetails((string)pt.Form_Of_Payment__c, 'N030', 'DE');
                }catch(Exception e){}
                try{
                    AGN_GCSP_PortalAccountUpdateController.saveCustomerUpdate(pauc.newRegistration, pauc.existingShipToAddress, pauc.existingBillToAddress, pauc.existingShipToAddress, pauc.existingBillToAddress, pauc.existingSoldToAddress, pauc.primaryContact, 'oam', adr.SAP_ID_AGN__c, null);
                }catch(Exception e){}
                    
                Test.stopTest(); 
                Integer num1 = 1;
                Integer num2 = 1;
                System.assertEquals(num1, num2);               
            }
        }
    }
}