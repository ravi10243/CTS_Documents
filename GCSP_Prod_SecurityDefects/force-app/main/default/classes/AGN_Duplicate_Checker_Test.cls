/****************************************************************************************************************
@ Class:          AGN_Duplicate_Checker_Test 
@ Version:        1
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        Test Class for AGN_Duplicate_Checker, AGN_Reltio_Service_Class 
				  and AGN_Reltio_Entity_Wrapper_Class
-----------------------------------------------------------------------------------------------------------------
@ Change history: 26.03.2021 / Ayush Basak / Created the class.
****************************************************************************************************************/
@isTest
public class AGN_Duplicate_Checker_Test {
    private static Id acaId;
    private static void dataSetup2() {
        Account customerAccount =new Account();      
        customerAccount.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
                                        AND DeveloperName = 'Professional_vod'
                                        LIMIT 1
                                       ][0].Id;
        customerAccount.Salutation = 'Mr.';
        customerAccount.FirstName ='Test';
        customerAccount.LastName = 'Last';
        customerAccount.PersonEmail = 'Email@ema.kl';
        customerAccount.Phone = '784623857';
        customerAccount.Customer_Registration_AGN__c = 'In Progress';
        customerAccount.Customer_Managed_AGN__c = true;
        customerAccount.Country_Code__c = 'GB';
        customerAccount.Customer_Category_AGN__c = 'Clinic';
        customerAccount.Customer_Sub_Category_AGN__c ='Public or Private Clinic';             
        insert customerAccount; 
        
        list<Customer_Type_Configuration_AGN__c> configlist;
        Specialty_Allergan_AGN__c spe;
        Country_vod__c country;
        list<Allergan_Consent_Footer_Info__c> conFooterList = new list<Allergan_Consent_Footer_Info__c>();
        Form_Of_Payment_AGN__c fop;
        Payment_Term_AGN__c  pt;
        Allergan_Customer_Payment_AGN__c payment;
        Entitlement ent;
        Case_Configuration_AGN__c caseconfig;
        Case c;
        Allergan_Customer_Registration_AGN__c cr;
        list<Allergan_Customer_Address_AGN__c> lstcra = new list<Allergan_Customer_Address_AGN__c>(); 
        list<Allergan_Customer_Address_AGN__c> lstcraNew = new list<Allergan_Customer_Address_AGN__c>(); 
        Attachment att;
        
        configlist =new list<Customer_Type_Configuration_AGN__c>();
        configlist = AGN_CustReg_TestUtilityClass.createCustTupeConfig();
        
        OAM_User_Settings__c oamUser = AGN_CustReg_TestUtilityClass.createOAMUser();            
        AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();
        
        spe = new Specialty_Allergan_AGN__c();
        spe = AGN_CustReg_TestUtilityClass.createSpecialty_Allergan();
        
        country = new Country_vod__c();
        country = AGN_CustReg_TestUtilityClass.createCountry();
        
        Allergan_Consent_Footer_Info__c conFooter = AGN_CustReg_TestUtilityClass.createConsentFooter();            
        conFooterList.add(conFooter);
        
        fop = new Form_Of_Payment_AGN__c();
        fop = AGN_CustReg_TestUtilityClass.createFormOfPayment();
        
        pt =new Payment_Term_AGN__c();
        pt = AGN_CustReg_TestUtilityClass.createPaymentTerm(fop);
        
        payment = new Allergan_Customer_Payment_AGN__c();
        payment = AGN_CustReg_TestUtilityClass.createCustPayments(customerAccount,fop,pt); 
        
        caseconfig = new  Case_Configuration_AGN__c();
        caseconfig = AGN_CustReg_TestUtilityClass.createCaseConfig(ent,customerAccount);
        
        c = new Case();
        c = AGN_CustReg_TestUtilityClass.createCase(ent);
        
        cr = new Allergan_Customer_Registration_AGN__c();
        cr = AGN_CustReg_TestUtilityClass.createCustReg(customerAccount, c, fop, pt, true);
        system.debug('@@@Cr-->'+cr);       
        
        
        Allergan_Customer_Address_AGN__c cra1 = AGN_CustReg_TestUtilityClass.createCustRegAdd(cr,true);
        lstcra.add(cra1);
        
        att = new Attachment();
        att = AGN_CustReg_TestUtilityClass.createAttachment(cr);      
    }
    
    private static void dataSetup() {
        
        Account customerAccount = new Account();      
        customerAccount.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
                                        AND DeveloperName = 'Professional_vod'
                                        LIMIT 1
                                       ][0].Id;
        customerAccount.Salutation = 'Mr.';
        customerAccount.FirstName ='Test';
        customerAccount.LastName = 'Last';
        customerAccount.PersonEmail = 'Email@ema.kl';
        customerAccount.Phone = '784623857';
        customerAccount.Customer_Registration_AGN__c = 'In Progress';
        customerAccount.Customer_Managed_AGN__c = true;
        customerAccount.Country_Code__c = 'GB';
        customerAccount.Customer_Category_AGN__c = 'Clinic';
        customerAccount.Customer_Sub_Category_AGN__c ='Public or Private Clinic';             
        insert customerAccount;       
        
        List<Customer_Type_Configuration_AGN__c> configlist = AGN_CustReg_TestUtilityClass.createCustTupeConfig();
        
        Reltio_API_AGN__c reltioSettings = new Reltio_API_AGN__c(SetupOwnerId = UserInfo.getOrganizationId(), 
                                                                 Authentication_URL_AGN__c = 'https://auth.reltio.com/oauth/token', 
                                                                 Authentication_Token_AGN__c = 'cmVsdGlvX3VpOm1ha2l0YQ==', 
                                                                 Tenant_URL_AGN__c = 'https://mpe-01.reltio.com/reltio/api/pWSkjoW3SfQgCPI', 
                                                                 Enpoint_AGN__c = '/entities', 
                                                                 Username_AGN__c = 'soumya.bag', 
                                                                 Password_AGN__c = 'Password1$');
        insert reltioSettings;
        
        AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();
        
        List<Allergan_Consent_Footer_Info__c> conFooterList = new list<Allergan_Consent_Footer_Info__c>();      
        conFooterList.add(AGN_CustReg_TestUtilityClass.createConsentFooter());
        
        Specialty_Allergan_AGN__c spe;
        spe = new Specialty_Allergan_AGN__c();
        spe = AGN_CustReg_TestUtilityClass.createSpecialty_Allergan();
        
        Country_vod__c country;
        country = new Country_vod__c();
        country = AGN_CustReg_TestUtilityClass.createCountry();
        
        Form_Of_Payment_AGN__c fop = AGN_CustReg_TestUtilityClass.createFormOfPayment();
        
        Payment_Term_AGN__c  pt = AGN_CustReg_TestUtilityClass.createPaymentTerm(fop);
        
        Allergan_Customer_Payment_AGN__c payment = AGN_CustReg_TestUtilityClass.createCustPayments(customerAccount,fop,pt); 
        
        Entitlement ent = AGN_CustReg_TestUtilityClass.createEntitlement(customerAccount); 
        
        Case_Configuration_AGN__c caseconfig = AGN_CustReg_TestUtilityClass.createCaseConfig(ent,customerAccount);
        
        Case c = AGN_CustReg_TestUtilityClass.createCase(ent);
        
        Allergan_Customer_Registration_AGN__c cr = AGN_CustReg_TestUtilityClass.createCustReg(customerAccount, c, fop, pt, true);
        
        Allergan_Customer_Address_AGN__c cra1 = AGN_CustReg_TestUtilityClass.createCustRegAdd(cr,true);
        acaId = cra1.Id;
        Attachment att = new Attachment();
        att = AGN_CustReg_TestUtilityClass.createAttachment(cr);      
    }
    
    @isTest
    private static void executeDuplicateChecker() {
        dataSetup(); 
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://auth.reltio.com/oauth/token?username=soumya.bag&password=Password1$&grant_type=password', 'ReltioAuthenticationResponse');
        multimock.setStaticResource('https://mpe-01.reltio.com/reltio/api/pWSkjoW3SfQgCPI/entities?options=ovOnly&max=20&filter=%28equals%28type%2C%27configuration%2FentityTypes%2FHCO%27%29+and+contains%28attributes.Identifiers.Type%2C%27*Veeva*%27%29+and+%28fuzzy%28attributes.Name%2C%27Company%27%29+or+fuzzy%28attributes.Address.AddressLine1%2C%27address%27%29+or+fuzzy%28attributes.Address.Cleansed_AddressLine1%2C%27address%27%29%29+and+fuzzy%28attributes.Address.City%2C%27city%27%29+and+fuzzy%28attributes.Address.Zip.Zip5%2C%2734345%27%29+and+equals%28attributes.Country%2C%27DE%27%29%29&select=attributes.Address.AddressLine1,attributes.activitywith.Name,attributes.Identifiers.ID,attributes.Address.StateProvince,attributes.AllerganSpeacialities.AllerganSpecialty,attributes.Name_with_Primary_Address_AGN__c,attributes.Email.Email,attributes.Address.Zip.Zip5,attributes.Physician_Registration_Reference_AGN__c,attributes.Specialities.Specialty,attributes.Identifiers.Type,attributes.Name,attributes.Country,attributes.Address.City', 'ReltioEntityResponse');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        
        Test.startTest();
        
        List<AGN_Reltio_Entity_Wrapper_Class> duplicateList = AGN_Duplicate_Checker.getDuplicates(acaId);
        // Checking size of returned list
        System.assertEquals(20, duplicateList.size());
        // Checking name is populated
        System.assertEquals('MIDDLESEX HOSPITAL', duplicateList[0].name);
        // Checking Id is populated
        System.assertEquals('0011o00001RD5OkAAL', duplicateList[0].accountId);
        // Checking the data map is populated
        System.assert(duplicateList[0].data.containsKey('Country'));
        System.assertEquals('GB-UK', duplicateList[0].data.get('Country'));
        
        Test.stopTest();
    }
    
}