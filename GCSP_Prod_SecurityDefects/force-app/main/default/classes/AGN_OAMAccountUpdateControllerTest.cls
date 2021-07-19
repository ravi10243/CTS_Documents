@isTest
public class AGN_OAMAccountUpdateControllerTest {
	 public static testmethod void CustPortalTest(){ 
        
        user u = AGN_CustReg_TestUtilityClass.createUser();
        
        System.runAs(u){
            OAM_User_Settings__c oamUser = AGN_CustReg_TestUtilityClass.createOAMUser();
            
            AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();
            
            list<Customer_Type_Configuration_AGN__c> configlist = AGN_CustReg_TestUtilityClass.createCustTupeConfig();
           
            System.Assert(!configlist.isEmpty(), 'create AGN_CustReg_TestUtilityClass.createCustTupeConfig FAIL: CustTupeConfiguration was not inserted properly!');
            
            Specialty_Allergan_AGN__c spe = AGN_CustReg_TestUtilityClass.createSpecialty_Allergan();
            Country_vod__c country = AGN_CustReg_TestUtilityClass.createCountry();
            
            Account BussinessAcc =  AGN_CustReg_TestUtilityClass.createBussinessAccount(spe, country);
            
            System.assert(BussinessAcc != Null, 'Create AGN_CustReg_TestUtilityClass.createBussinessAccount  Fail :  Bussiness Account was not inserted properly');
            
            Account bussinessAccount = new Account( RecordTypeId =  [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Pharmacy_vod' LIMIT 1][0].Id,Country_vod__c  = country.Id, External_ID2_AGN__c = '213145',Customer_Category_AGN__c = 'Clinic', 
                                                   Customer_Sub_Category_AGN__c = 'Public or Private Clinic', Calling_Name_AGN__c = 'call name', Country_Code__c = 'DE',SAP_Customer_Group_AGN__c = 'CL',SAP_Search_Term_1_AGN__c = 'Enrku',SAP_Country_Code_AGN__c = 'DE',SAP_Tax_Classification_AGN__c = '9',
                                                   SAP_Sold_To_AGN__c=true,Phone = '4565576',Specialty_Allergan_1_AGN__c = spe.Id,name='testAcc');
            
            insert bussinessAccount; 
            
            system.assertEquals('testAcc', bussinessAccount.Name);
            
            Account PersonAcc =  AGN_CustReg_TestUtilityClass.createPersonAccount(BussinessAcc);
            
            list<Child_Account_vod__c> childAccList = new list<Child_Account_vod__c>();
            
           
            Child_Account_vod__c child1 = new Child_Account_vod__c(Parent_Account_vod__c = bussinessAccount.Id, Child_Account_vod__c = BussinessAcc.ID, 
                                                                   Sold_To_AGN__c= false, Ship_To_AGN__c=false, 
                                                                   Bill_To_AGN__c=true,Customer_Managed_AGN__c =true);
             Child_Account_vod__c child2 = new Child_Account_vod__c(Parent_Account_vod__c = BussinessAcc.Id, Child_Account_vod__c = PersonAcc.ID, 
                                                                   Sold_To_AGN__c= true, Ship_To_AGN__c=false, 
                                                                   Bill_To_AGN__c=false,Customer_Managed_AGN__c =true);
            
            
             
             childAccList.add(child1);
             childAccList.add(child2); 
            
             Database.upsert(childAccList,false); 
            
            Address_vod__c add = AGN_CustReg_TestUtilityClass.createAddress(BussinessAcc);
            Address_vod__c add1 = new Address_vod__c();  
            Entitlement ent =  AGN_CustReg_TestUtilityClass.createEntitlement(PersonAcc);     
            
            Case_Configuration_AGN__c caseconfig = AGN_CustReg_TestUtilityClass.createCaseConfig(ent,PersonAcc);
            
            System.assertEquals(ent.Id, caseconfig.Entitlement_AGN__c);
            
            Case c = AGN_CustReg_TestUtilityClass.createCase(ent);
            Form_Of_Payment_AGN__c fop = AGN_CustReg_TestUtilityClass.createFormOfPayment();
            Payment_Term_AGN__c  pt = AGN_CustReg_TestUtilityClass.createPaymentTerm(fop);
            
             System.Assert(fop != null, 'create AGN_CustReg_TestUtilityClass.createFormOfPayment  FAIL: Form of payment was not inserted properly!');
            
            Allergan_Customer_Registration_AGN__c cr = AGN_CustReg_TestUtilityClass.createCustReg(PersonAcc, c, fop, pt, false);
            
              System.Assert(cr != null, 'create AGN_CustReg_TestUtilityClass.createCustReg FAIL: AllergnaCustomerRegistration was not inserted properly!');
            
            Allergan_Customer_Registration_AGN__c cr1 = AGN_CustReg_TestUtilityClass.createCustReg(PersonAcc, c, fop, pt, true);
            
			 system.assertNotEquals(cr, cr1) ;   
            
            Allergan_Customer_Address_AGN__c cra = AGN_CustReg_TestUtilityClass.createCustRegAdd(cr1,false);
            
            Allergan_Customer_Address_AGN__c cra1 = AGN_CustReg_TestUtilityClass.createCustRegAdd(cr1,true);
            
            Allergan_Customer_Address_AGN__c cra2 = new Allergan_Customer_Address_AGN__c(Bill_To_AGN__c=false); 
            
           Attachment att = AGN_CustReg_TestUtilityClass.createAttachment(cr1);
            
             system.debug('@@@@@@@@@Acc-->'+BussinessAcc.id);
           Allergan_Customer_Payment_AGN__c payment = new Allergan_Customer_Payment_AGN__c();
            //Account_AGN__c= , Bank_Name_AGN__c='HSBC', Bank_Account_Number_AGN__c='473685738', IBAN_AGN__c = 'DE236463445656', Sort_Code_AGN__c='3478', 
                                                                                        //SWIFT_BIC_AGN__c='4576',Form_Of_Payment_AGN__c= fop.id, Payment_Term_AGN__c=pt.id);
            payment.Account_AGN__c = BussinessAcc.Id;
            payment.Bank_Name_AGN__c= 'HSBC';
            payment.Bank_Account_Number_AGN__c = '27458273';
            payment.Sort_Code_AGN__c = '72345';
            payment.SWIFT_BIC_AGN__c = '68342783424';
            payment.Form_Of_Payment_AGN__c = fop.id;
            payment.Payment_Term_AGN__c = pt.id;
        
           insert payment;         
            
           Allergan_Customer_Payment_AGN__c custpayment = [SELECT Form_Of_Payment_AGN__c, Payment_Term_AGN__c FROM Allergan_Customer_Payment_AGN__c WHERE Account_AGN__c =: BussinessAcc.id LIMIT 1];
         
            string parserCra = JSON.serialize(cra2);
            string parserCr = JSON.serialize(cr);
            String body = EncodingUtil.base64Encode(Blob.valueOf('Unit Test Attachment Body'));
        test.starttest();   
            
            AGN_OAMAccountUpdateController cusObjclass = new AGN_OAMAccountUpdateController();
           // AGN_OAMAccountUpdateController.getLayout('DE','2');
           // AGN_OAMAccountUpdateController.getLayout('DE','3','Clinic','Public or Private Clinic');
            AGN_OAMAccountUpdateController.doInit(add.id,'SoldTo');    
            AGN_OAMAccountUpdateController.getNewAddress(add1.id,'ShipTo');
            AGN_OAMAccountUpdateController.getLayout('DE','4','Clinic','Public or Private Clinic', configlist);
            AGN_OAMAccountUpdateController.SelectOption coption = new AGN_OAMAccountUpdateController.SelectOption('-- None--', 'none');
            AGN_OAMAccountUpdateController.SelectOption coptions = new AGN_OAMAccountUpdateController.SelectOption('-- None--', 'none',false);
            AGN_OAMAccountUpdateController.savetestFile();
            AGN_OAMAccountUpdateController.saveFile(c.Id, 'FileName', body, 'application/msword');
            AGN_OAMAccountUpdateController.saveCustomerUpdate(parserCra, parserCr,'New');            
            
        test.stopTest();
        }     
   }     
}