@isTest
public class AGN_OAMCustomerRegStep1ControllerTest {
    
	 public static testmethod void registrationMethodTest(){     
        
        user u = AGN_CustReg_TestUtilityClass.createUser();         
        
        system.runAs(u){         
            list<Customer_Type_Configuration_AGN__c> configlist = AGN_CustReg_TestUtilityClass.createCustTupeConfig();
            
            OAM_User_Settings__c oamUser = AGN_CustReg_TestUtilityClass.createOAMUser();            
            AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();
            
            Specialty_Allergan_AGN__c spe = AGN_CustReg_TestUtilityClass.createSpecialty_Allergan();
            Country_vod__c country = AGN_CustReg_TestUtilityClass.createCountry();
            
            Account BussinessAcc =  AGN_CustReg_TestUtilityClass.createBussinessAccount(spe, country);
            system.assert(BussinessAcc != null, 'Bussiness account is required for Person Account creation');
            
            Account personAcc =  AGN_CustReg_TestUtilityClass.createPersonAccount(BussinessAcc);     
            system.assert(PersonAcc != null, 'person account is required for User creation');          
         
            
             list<Allergan_Consent_Footer_Info__c> conFooterList = new list<Allergan_Consent_Footer_Info__c>();
            
            Allergan_Consent_Footer_Info__c conFooter = AGN_CustReg_TestUtilityClass.createConsentFooter();            
            	conFooterList.add(conFooter);
            
            user user = AGN_CustReg_TestUtilityClass.createCommunityUser();          
            
            Form_Of_Payment_AGN__c fop = AGN_CustReg_TestUtilityClass.createFormOfPayment();
            Payment_Term_AGN__c  pt = AGN_CustReg_TestUtilityClass.createPaymentTerm(fop);
            Allergan_Customer_Payment_AGN__c payment = AGN_CustReg_TestUtilityClass.createCustPayments(PersonAcc,fop,pt);
            
            //Child_Account_vod__c childAcc = AGN_CustReg_TestUtilityClass.createChildAccount(BussinessAcc);          
            Address_vod__c add = AGN_CustReg_TestUtilityClass.createAddress(BussinessAcc);
            
            Entitlement ent =  AGN_CustReg_TestUtilityClass.createEntitlement(PersonAcc);            
            Case_Configuration_AGN__c caseconfig = AGN_CustReg_TestUtilityClass.createCaseConfig(ent,PersonAcc);
            
            Case c = AGN_CustReg_TestUtilityClass.createCase(ent);
            
            Allergan_Customer_Registration_AGN__c cr1 = AGN_CustReg_TestUtilityClass.createCustReg(PersonAcc, c, fop, pt, false);
            Allergan_Customer_Registration_AGN__c cr = AGN_CustReg_TestUtilityClass.createCustReg(PersonAcc, c, fop, pt, true);
            
            list<Allergan_Customer_Address_AGN__c> lstcra = new list<Allergan_Customer_Address_AGN__c>(); 
            list<Allergan_Customer_Address_AGN__c> lstcraNew = new list<Allergan_Customer_Address_AGN__c>();
            Allergan_Customer_Address_AGN__c cra = AGN_CustReg_TestUtilityClass.createCustRegAdd(cr,false); 
            lstcraNew.add(cra);
            Allergan_Customer_Address_AGN__c cra1 = AGN_CustReg_TestUtilityClass.createCustRegAdd(cr,true);
            lstcra.add(cra1);
            Attachment att = AGN_CustReg_TestUtilityClass.createAttachment(cr);      
            
            List<AGN_Community_Layout_Setting__mdt> metadaLayOut= [SELECT SObject_Name_AGN__c,
                                                                   Field_Name_AGN__c,
                                                                   Sort_Order_AGN__c,
                                                                   Field_Label_AGN__c,
                                                                   Required_AGN__c,
                                                                   Section_Header_AGN__c,
                                                                   Section_Header_Label_AGN__c,
                                                                   Customer_Groups_AGN__c,
                                                                   Field_Regex_AGN__c,
                                                                   Step_No_AGN__c
                                                                   FROM AGN_Community_Layout_Setting__mdt 
                                                                   WHERE Country_AGN__c = 'DE'];
            
            AGN_Community_Layout_Setting__mdt[] metadataList = [SELECT SObject_Name_AGN__c,
                                                                Field_Name_AGN__c,
                                                                Sort_Order_AGN__c,
                                                                Field_Label_AGN__c,
                                                                Required_AGN__c,
                                                                Section_Header_AGN__c,
                                                                Section_Header_Label_AGN__c,
                                                                Customer_Groups_AGN__c,
                                                                Field_Regex_AGN__c,
                                                                Step_No_AGN__c
                                                                FROM AGN_Community_Layout_Setting__mdt 
                                                                WHERE Country_AGN__c = 'DE'];
            
            system.assertEquals(metadataList, metadaLayOut);     
            
            Test.startTest();  
            
            Test.setMock(HttpCalloutMock.class, new AGN_OktaUtilsMock());
            AGN_OAMCustomerRegStep1Controller.createOktaUserSendLink(cr1,PersonAcc);
           
            AGN_OAMCustomerRegStep1Controller.getLayout('DE','4','Clinic','Public or Private Clinic', configlist);             
            system.assertEquals(false,  AGN_OAMCustomerRegStep1Controller.isDuplicateUser(user.Email));  
            AGN_OAMCustomerRegStep1Controller.fetchFooterConsents(user.Country_Code__c);
            
             AGN_OAMCustomerRegStep1Controller.createAccount(cr);
            try{
                AGN_OAMCustomerRegStep1Controller.createCommunityUser(PersonAcc.Id); //user.AccountId
            }catch(Exception e){} 
            
             AGN_OAMCustomerRegStep1Controller.createNewCustomerRegistration(cr1,cra,configlist,PersonAcc);          
            
             AGN_OAMCustomerRegStep1Controller.inactivateUser(user.Id);
             AGN_OAMCustomerRegStep1Controller.getCummunityURL();
             AGN_OAMCustomerRegStep1Controller.getAD_OktaSSOUrl();
             system.assertEquals(false, AGN_OAMCustomerRegStep1Controller.isRegistrationCompleted());           
            
            Test.stopTest();  
        }
        
    }
}