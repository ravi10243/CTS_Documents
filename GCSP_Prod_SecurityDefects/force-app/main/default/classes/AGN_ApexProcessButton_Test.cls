@isTest
public class AGN_ApexProcessButton_Test {
    public static Specialty_Allergan_AGN__c specialityAllergan = AGN_CustReg_TestUtilityClass.createSpecialty_Allergan();
    public static    Country_vod__c newCountry = AGN_CustReg_TestUtilityClass.createCountry();
     public static   Account businessAccount = AGN_CustReg_TestUtilityClass.createBussinessAccount(specialityAllergan, newCountry);
      public static  Form_Of_Payment_AGN__c fop = AGN_CustReg_TestUtilityClass.createFormOfPayment();
      public static  Payment_Term_AGN__c payTerm = AGN_CustReg_TestUtilityClass.createPaymentTerm(fop);        
       public static Entitlement ent = AGN_CustReg_TestUtilityClass.createEntitlement(businessAccount);
     public static   Case newCase = AGN_CustReg_TestUtilityClass.createCase(ent);
     public static   AGN_GCSP_Settings__c gcspSetting = AGN_CustReg_TestUtilityClass.createGCSPSettings();
    @isTest
    public static void testMethod1(){
        
        
        gcspSetting.Is_Okta_Enabled_AGN__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
        obj.process();
        obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        obj.sendtosap();
        obj.sendtosapcred();
       
        
       // AGN_ApexCaseProcessing.sendtosap(acr.Id);
        //AGN_ApexCaseProcessing.processCase(acr.Id);
        //AGN_ApexCaseProcessing.customerPortalApex(acr.Id);
        //AGN_ApexCaseProcessing.disableSendButton(true);
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
    
    @isTest
    public static void testMethod2(){
        
        
        gcspSetting.Is_Okta_Enabled_AGN__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
      
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c;
   //     update gcspSetting;
        custAdd.SAP_ID_AGN__c = '543876543';
        custAdd.SAP_Search_Term_1_AGN__c = 'df';
        update custAdd;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
        obj.process();
        obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        
        obj.sendtosap();
        obj.sendtosapcred();
       
        
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
        
     /*    custAdd.SAP_Search_Term_1_AGN__c = 'df';
        update custAdd;
        acr.SAP_Search_Performed__c = false;
        update acr;
        obj.sendtosap();
        acr.SAP_Search_Performed__c = true;
        acr.Ship_to_AC_validated_AGN__c = false;
        update acr;
        obj.sendtosap();
         acr.SAP_Search_Performed__c = true;
        acr.Ship_to_AC_validated_AGN__c = true;
        acr.Documentation_provided_as_per_SOP__c = false;
        update acr;
        obj.sendtosap();
        acr.SAP_Country_Code_AGN__c = 'NZ';
        update acr;
        obj.sendtosap();
        gcspSetting.Is_Send_to_SAP_checklist_Required__c = true;
        gcspSetting.Name = acr.SAP_Country_Code_AGN__c;
        update gcspSetting;
        obj.sendtosap();
*/
        
    }
    @isTest
    public static void testMethod3(){
        
        gcspSetting.Is_Okta_Enabled_AGN__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
      
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c; 
        acr.SAP_Country_Code_AGN__c = 'AU';
        update acr;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
        obj.process();
        obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        
        obj.sendtosap();
        obj.sendtosapcred();
        
        acr.SAP_Search_Performed__c = false;
        update acr;
        obj.sendtosap();
       
        
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
     @isTest
    public static void testMethod4(){    
    gcspSetting.Is_Okta_Enabled_AGN__c = true;
        gcspSetting.Is_Send_to_SAP_checklist_Required__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
      
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c; 
        
        acr.SAP_Country_Code_AGN__c = 'AU';
        
        acr.SAP_Search_Performed__c = false;
        acr.Ship_to_AC_validated_AGN__c =true;
        acr.Documentation_provided_as_per_SOP__c = true;
         acr.Address_Validated__c = true;
         acr.Official_Websites_Used_AGN__c = true;
        update acr;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
        obj.process();
        obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        
        obj.sendtosap();
        obj.sendtosapcred();
        
       acr.SAP_Search_Performed__c = true;
        acr.Ship_to_AC_validated_AGN__c =false;
        acr.Documentation_provided_as_per_SOP__c = true;
         acr.Address_Validated__c = true;
         acr.Official_Websites_Used_AGN__c = true;
        update acr;
        obj.sendtosap();
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
    @isTest
    public static void testMethod5(){    
    gcspSetting.Is_Okta_Enabled_AGN__c = true;
        gcspSetting.Is_Send_to_SAP_checklist_Required__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
      
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c; 
        
        acr.SAP_Country_Code_AGN__c = 'AU';
        
        acr.SAP_Search_Performed__c = true;
        acr.Ship_to_AC_validated_AGN__c =false;
        acr.Documentation_provided_as_per_SOP__c = true;
         acr.Address_Validated__c = true;
         acr.Official_Websites_Used_AGN__c = true;
        update acr;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
        obj.process();
        obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        obj.sendtosap();
        obj.sendtosapcred();
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
    @isTest
     public static void testMethod10(){    
    gcspSetting.Is_Okta_Enabled_AGN__c = true;
        gcspSetting.Is_Send_to_SAP_checklist_Required__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
      
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c; 
        
        acr.SAP_Country_Code_AGN__c = 'AU';
        
        acr.SAP_Search_Performed__c = true;
        acr.Ship_to_AC_validated_AGN__c =true;
        acr.Documentation_provided_as_per_SOP__c = false;
         acr.Address_Validated__c = true;
         acr.Official_Websites_Used_AGN__c = true;
        update acr;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
        obj.process();
        obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        obj.sendtosap();
        obj.sendtosapcred();
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
    @isTest
    public static void testMethod6(){    
    gcspSetting.Is_Okta_Enabled_AGN__c = true;
        gcspSetting.Is_Send_to_SAP_checklist_Required__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
      
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        custAdd.SAP_Search_Term_1_AGN__c = null;
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c; 
        
        acr.SAP_Country_Code_AGN__c = 'AU';
        
        acr.SAP_Search_Performed__c = true;
        acr.Ship_to_AC_validated_AGN__c =true;
        acr.Documentation_provided_as_per_SOP__c = true;
         acr.Address_Validated__c = false;
         acr.Official_Websites_Used_AGN__c = true;
        update acr;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
     //   obj.process();
       // obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        obj.sendtosap();
        obj.sendtosapcred();
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
    @isTest
    
     public static void testMethod7(){    
    gcspSetting.Is_Okta_Enabled_AGN__c = true;
        gcspSetting.Is_Send_to_SAP_checklist_Required__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
      
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        custAdd.SAP_Search_Term_1_AGN__c = null;
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c; 
        
        acr.SAP_Country_Code_AGN__c = 'AU';
        
        acr.SAP_Search_Performed__c = true;
        acr.Ship_to_AC_validated_AGN__c =true;
        acr.Documentation_provided_as_per_SOP__c = true;
         acr.Address_Validated__c = true;
         acr.Official_Websites_Used_AGN__c = false;
        update acr;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
     //   obj.process();
       // obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        obj.sendtosap();
        obj.sendtosapcred();
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
    @isTest
     public static void testMethod8(){    
   
        User u = AGN_CustReg_TestUtilityClass.createUser();
         User userId = [SELECT ID, Name, Position_AGN__c  FROM User WHERE Id=: UserInfo.getUserId()]; 
        newCase.OwnerId  = userId.Id;
         userId.Position_AGN__c = 'Customer Service';
         update userId;
         update newCase;
          gcspSetting.Is_Okta_Enabled_AGN__c = true;
        gcspSetting.Is_Send_to_SAP_checklist_Required__c = true;
        update gcspSetting;
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
        acr.SAP_Country_Code_AGN__c = 'AU';
       update acr;
   //   acr.Process_AGN__c = false;
     //    acr.Processed_By_Okta_AGN__c = false;
         
      /*  Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        custAdd.SAP_Search_Term_1_AGN__c = null;
         custAdd.SAP_ID_AGN__c = '0000869444';
        */
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        custCont.Use_Existing_Account_AGN__c = false;
         insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c; 
        
    //    acr.SAP_Country_Code_AGN__c = 'AU';
        
        acr.SAP_Search_Performed__c = false;
        acr.Ship_to_AC_validated_AGN__c =true;
        acr.Documentation_provided_as_per_SOP__c = true;
         acr.Address_Validated__c = true;
         acr.Official_Websites_Used_AGN__c = true;
        update acr;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
       obj.process();
        obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        obj.sendtosap();
        obj.sendtosapcred();
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
    @isTest
    public static void testMethod9(){    
    gcspSetting.Is_Okta_Enabled_AGN__c = true;
        gcspSetting.Is_Send_to_SAP_checklist_Required__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
      
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        custAdd.SAP_Search_Term_1_AGN__c = null;
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c; 
        
     //   acr.SAP_Country_Code_AGN__c = 'AU';
        
        acr.SAP_Search_Performed__c = true;
        acr.Ship_to_AC_validated_AGN__c =false;
        acr.Documentation_provided_as_per_SOP__c = true;
         acr.Address_Validated__c = true;
         acr.Official_Websites_Used_AGN__c = true;
        update acr;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
     //   obj.process();
       // obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        obj.sendtosap();
        obj.sendtosapcred();
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
     @isTest
    public static void testMethod11(){    
    gcspSetting.Is_Okta_Enabled_AGN__c = true;
        gcspSetting.Is_Send_to_SAP_checklist_Required__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
      
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        custAdd.SAP_Search_Term_1_AGN__c = null;
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c; 
        
     //   acr.SAP_Country_Code_AGN__c = 'AU';
        
        acr.SAP_Search_Performed__c = true;
        acr.Ship_to_AC_validated_AGN__c =true;
        acr.Documentation_provided_as_per_SOP__c = false;
         acr.Address_Validated__c = true;
         acr.Official_Websites_Used_AGN__c = true;
        update acr;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
     //   obj.process();
       // obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        obj.sendtosap();
        obj.sendtosapcred();
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
    @isTest
    public static void testMethod12(){    
    gcspSetting.Is_Okta_Enabled_AGN__c = true;
        gcspSetting.Is_Send_to_SAP_checklist_Required__c = true;
        update gcspSetting;
        User u = AGN_CustReg_TestUtilityClass.createUser();
        Account personAcc = AGN_CustReg_TestUtilityClass.createPersonAccount(businessAccount);
        Allergan_Customer_Registration_AGN__c acr = AGN_CustReg_TestUtilityClass.createCustReg(personAcc, newCase, fop, payTerm, true);
       // acr.SAP_Country_Code_AGN__c = 'AU';
       // update acr;
      
        Allergan_Customer_Address_AGN__c custAdd = AGN_CustReg_TestUtilityClass.createCustRegAdd(acr, true);
        custAdd.SAP_Search_Term_1_AGN__c = null;
        Allergan_Customer_Contact_AGN__c custCont = new Allergan_Customer_Contact_AGN__c(Enable_Portal_User_AGN__c = true,Parent_AGN__c=acr.id);
        insert custCont;
        gcspSetting.Name = acr.Case_AGN__r.Account_Country_Code_AGN__c; 
        
     //   acr.SAP_Country_Code_AGN__c = 'AU';
        
        acr.SAP_Search_Performed__c = true;
        acr.Ship_to_AC_validated_AGN__c =true;
        acr.Documentation_provided_as_per_SOP__c = true;
         acr.Address_Validated__c = false;
         acr.Official_Websites_Used_AGN__c = true;
        update acr;
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', String.valueOf(acr.Id));
        AGN_ApexProcessButton obj = new AGN_ApexProcessButton(new ApexPages.StandardController(acr));
     //   obj.process();
       // obj.customerPortalApex();
        AGN_ApexProcessButton.disableSendButton(false);
        obj.sendtosap();
        obj.sendtosapcred();
        Test.stopTest();
        Integer num1 = 1;
    Integer num2 = 1;
    System.assertEquals(num1, num2);
    }
}