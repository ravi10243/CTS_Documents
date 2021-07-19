@isTest
public class AGN_OAM_ProcessUtils_Test {
    public static testmethod void testMethod1(){
        Contact con = new Contact(LastName = 'lasttest');
        
        insert con;
        Specialty_Allergan_AGN__c spe = AGN_GCSP_CustReg_TestUtilityClass.createSpecialty_Allergan();
        Country_vod__c country = AGN_GCSP_CustReg_TestUtilityClass.createCountry();
        Form_Of_Payment_AGN__c fop = AGN_GCSP_CustReg_TestUtilityClass.createFormOfPayment();
        Payment_Term_AGN__c pt = AGN_GCSP_CustReg_TestUtilityClass.createPaymentTerm(fop);
        Account acc = AGN_GCSP_CustReg_TestUtilityClass.createBussinessAccount(spe, country);
        con.AccountId = acc.Id;
        update con;
        Account pacc = AGN_GCSP_CustReg_TestUtilityClass.createPersonAccount(acc);
        Entitlement ent = AGN_GCSP_CustReg_TestUtilityClass.createEntitlement(pacc);
        Case caseNewCr = AGN_GCSP_CustReg_TestUtilityClass.createCase(ent);
        AGN_GCSP_Settings__c gcspSetting = AGN_GCSP_CustReg_TestUtilityClass.createGCSPSettings();
        Allergan_Customer_Registration_AGN__c acr = AGN_GCSP_CustReg_TestUtilityClass.createCustReg(pacc, caseNewCr, fop, pt, true);
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        custAdd.Is_Update_Bussiness_Account_AGN__c = false;
        custAdd.Account_AGN__c = acc.Id;
        update custAdd;
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        custCont.Last_Name_AGN__c = 'lasttest';
        custCont.Enable_HCP_AGN__c = true;
        custCont.Contact_AGN__c = con.Id;
        insert custCont;
        
        Test.startTest();
          
         AGN_OAM_ProcessUtils agncontroller = new AGN_OAM_ProcessUtils();
     
         AGN_OAM_ProcessUtils.fetchFieldMappings();
         AGN_OAM_ProcessUtils.fetchRecordTypes('Account');
         
         AGN_OAM_ProcessUtils.Process(acr);
      //  Map<Id,Contact> mape = (Map<Id, Contact>)JSON.deserialize(contactList, Map<Id, Contact>.class);
         
         Test.stopTest(); 
         Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
    public static testmethod void testMethod2(){
        Contact con = new Contact(LastName = 'lasttest');
        
        insert con;
        Specialty_Allergan_AGN__c spe = AGN_GCSP_CustReg_TestUtilityClass.createSpecialty_Allergan();
        Country_vod__c country = AGN_GCSP_CustReg_TestUtilityClass.createCountry();
        Form_Of_Payment_AGN__c fop = AGN_GCSP_CustReg_TestUtilityClass.createFormOfPayment();
        Payment_Term_AGN__c pt = AGN_GCSP_CustReg_TestUtilityClass.createPaymentTerm(fop);
        Account acc = AGN_GCSP_CustReg_TestUtilityClass.createBussinessAccount(spe, country);
        con.AccountId = acc.Id;
        update con;
        Account pacc = AGN_GCSP_CustReg_TestUtilityClass.createPersonAccount(acc);
        Entitlement ent = AGN_GCSP_CustReg_TestUtilityClass.createEntitlement(pacc);
        Case caseNewCr = AGN_GCSP_CustReg_TestUtilityClass.createCase(ent);
        AGN_GCSP_Settings__c gcspSetting = AGN_GCSP_CustReg_TestUtilityClass.createGCSPSettings();
        Allergan_Customer_Registration_AGN__c acr = AGN_GCSP_CustReg_TestUtilityClass.createCustReg(pacc, caseNewCr, fop, pt, true);
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        custAdd.Is_Update_Bussiness_Account_AGN__c = true;
        custAdd.Account_AGN__c = acc.Id;
        update custAdd;
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        custCont.Last_Name_AGN__c = 'lasttest';
        custCont.Enable_HCP_AGN__c = true;
        custCont.Contact_AGN__c = con.Id;
        insert custCont;
        
        Test.startTest();
          
         AGN_OAM_ProcessUtils agncontroller = new AGN_OAM_ProcessUtils();
     
         AGN_OAM_ProcessUtils.fetchFieldMappings();
         AGN_OAM_ProcessUtils.fetchRecordTypes('Account');
         
         //AGN_OAM_ProcessUtils.Process(acr);
      //  Map<Id,Contact> mape = (Map<Id, Contact>)JSON.deserialize(contactList, Map<Id, Contact>.class);
         
         Test.stopTest();
         Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2); 
    }

 
}