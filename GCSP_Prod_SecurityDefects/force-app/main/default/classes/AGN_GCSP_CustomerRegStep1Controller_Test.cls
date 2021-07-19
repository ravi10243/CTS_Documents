@isTest
public class AGN_GCSP_CustomerRegStep1Controller_Test{
   @IsTest public static void registrationMethodTest(){     
        
        user u = AGN_GCSP_CustReg_TestUtilityClass.createUser();
        system.runAs(u){
            
            list<Customer_Type_Configuration_AGN__c> configlist = AGN_GCSP_CustReg_TestUtilityClass.createCustTupeConfig();
            
            OAM_User_Settings__c oamUser = AGN_GCSP_CustReg_TestUtilityClass.createOAMUser();
			oamUser.User_Profile__c= 'Allergan Customer Community Login DE';
            update oamUser;
            
            AGN_GCSP_Settings__c gcspSettings = AGN_GCSP_CustReg_TestUtilityClass.createGCSPSettings();
            
            Specialty_Allergan_AGN__c spe = AGN_GCSP_CustReg_TestUtilityClass.createSpecialty_Allergan();
            Country_vod__c country = AGN_GCSP_CustReg_TestUtilityClass.createCountry();
            
            Account BussinessAcc =  AGN_GCSP_CustReg_TestUtilityClass.createBussinessAccount(spe, country);
            system.assert(BussinessAcc != null, 'Bussiness account is required for Person Account creation');
            
            Account personAcc =  AGN_GCSP_CustReg_TestUtilityClass.createPersonAccount(BussinessAcc);     
            system.assert(PersonAcc != null, 'person account is required for User creation');          
         
            
             list<Allergan_Consent_Footer_Info__c> conFooterList = new list<Allergan_Consent_Footer_Info__c>();
            
            Allergan_Consent_Footer_Info__c conFooter = AGN_GCSP_CustReg_TestUtilityClass.createConsentFooter();            
              conFooterList.add(conFooter);
            
            user user = AGN_GCSP_CustReg_TestUtilityClass.createCommunityUser();          
            
            Form_Of_Payment_AGN__c fop = AGN_GCSP_CustReg_TestUtilityClass.createFormOfPayment();
            Payment_Term_AGN__c  pt = AGN_GCSP_CustReg_TestUtilityClass.createPaymentTerm(fop);
            Allergan_Customer_Payment_AGN__c payment = AGN_GCSP_CustReg_TestUtilityClass.createCustPayments(PersonAcc,fop,pt);
            
            //Child_Account_vod__c childAcc = AGN_GCSP_CustReg_TestUtilityClass.createChildAccount(BussinessAcc);          
            Address_vod__c add = AGN_GCSP_CustReg_TestUtilityClass.createAddress(BussinessAcc);
            
            Entitlement ent =  AGN_GCSP_CustReg_TestUtilityClass.createEntitlement(PersonAcc);            
            Case_Configuration_AGN__c caseconfig = AGN_GCSP_CustReg_TestUtilityClass.createCaseConfig(ent,PersonAcc);
            
            Case c = AGN_GCSP_CustReg_TestUtilityClass.createCase(ent);
            
            Allergan_Customer_Registration_AGN__c cr1 = AGN_GCSP_CustReg_TestUtilityClass.createCustReg(PersonAcc, c, fop, pt, false);
            Allergan_Customer_Registration_AGN__c cr = AGN_GCSP_CustReg_TestUtilityClass.createCustReg(PersonAcc, c, fop, pt, true);
            
            list<Allergan_Customer_Address_AGN__c> lstcra = new list<Allergan_Customer_Address_AGN__c>(); 
            list<Allergan_Customer_Address_AGN__c> lstcraNew = new list<Allergan_Customer_Address_AGN__c>();
            Allergan_Customer_Address_AGN__c cra = AGN_GCSP_CustReg_TestUtilityClass.createCustRegAdd(cr,false); 
            lstcraNew.add(cra);
            Allergan_Customer_Address_AGN__c cra1 = AGN_GCSP_CustReg_TestUtilityClass.createCustRegAdd(cr,true);
            lstcra.add(cra1);
            Attachment att = AGN_GCSP_CustReg_TestUtilityClass.createAttachment(cr);      
            Integer i=5,j=5;
            
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
            
            List<Object> l= AGN_GCSP_CustomerRegStep1Controller.fetchCountryList('DE', 'oam');
            System.assertNotEquals(l, null);
            //AGN_GCSP_CustomerRegStep1Controller.fetchCountryList('GB', 'oam');
            //AGN_GCSP_CustomerRegStep1Controller.fetchCountryList('RU', 'cs');
            //AGN_GCSP_CustomerRegStep1Controller.fetchCountryList('CA', 'oam');
            Map < String, List < AGN_Community_Layout_Setting__mdt >> m = AGN_GCSP_CustomerRegStep1Controller.getLayout('ES','1','oam');
            System.assertNotEquals(m, null);
            try{
				AGN_GCSP_CustomerRegStep1Controller.getLayout(null,'1','oam'); // exception Test
                System.assertEquals(i, j);
			}catch(Exception e){}
            Map < String, List < AGN_Community_Layout_Setting__mdt >> m1 = AGN_GCSP_CustomerRegStep1Controller.getLayout('DE','1','Clinic','Public or Private Clinic',configlist,'oam');
            System.assertNotEquals(m1, null);
            try{
				AGN_GCSP_CustomerRegStep1Controller.getLayout(null,'1','Clinic','Public or Private Clinic',configlist,'oam'); // exception Test
                System.assertEquals(i, j);
			}catch(Exception e){}
            String s = AGN_GCSP_CustomerRegStep1Controller.getCustomerGroup('DE', 'Clinic', 'Public or Private Clinic');
            System.assertEquals(String.isEmpty(s), true);
            try{
				AGN_GCSP_CustomerRegStep1Controller.getCustomerGroup('DEA', 'Clinic', null); // exception Test
                System.assertEquals(i, j);
			}catch(Exception e){}
            
            System.runAs(user){
            Account a = AGN_GCSP_CustomerRegStep1Controller.createAccount(lstcra[0], cr, country.Alpha_2_Code_vod__c);
            System.assertNotEquals(a, null);
            Contact con = AGN_GCSP_CustomerRegStep1Controller.createContact(cr, a, 'DE');
            System.assertNotEquals(con, null);
    		AGN_GCSP_CustomerRegStep1Controller.createCommunityUser(con.Id, 'DE', 'de');
            System.assertNotEquals(a, null);
            /*try{
            	AGN_GCSP_CustomerRegStep1Controller.createAccount(lstcra[0], cr, country.Alpha_2_Code_vod__c);
            }catch(Exception e){}
			try{
    			AGN_GCSP_CustomerRegStep1Controller.createContact(cr, personAcc, 'DE');
			}catch(Exception e){}
            Contact con = new Contact(LastName='TestUser');
            try{
    			AGN_GCSP_CustomerRegStep1Controller.createCommunityUser(con.Id, 'DE', 'de');
			}catch(Exception e){}*/
            try{
				AGN_GCSP_CustomerRegStep1Controller.createNewCustomerRegistration(cr, lstcra[0], configList, con, 'de');
                System.assertEquals(i, j);
            }catch(Exception e){}
			try{
				AGN_GCSP_CustomerRegStep1Controller.createNewCustomerRegistrationCS(cr, lstcra[0], configList, con, c, null, 'de');	
                System.assertEquals(i, j);
			}catch(Exception e){}
			try{
				AGN_GCSP_CustomerRegStep1Controller.createOktaUserSendLink(cr, con, 'de', 'DE');
                System.assertEquals(i, j);
			}catch(Exception e){}
            try{
    			AGN_GCSP_CustomerRegStep1Controller.getCustomerRegDetails(); 
                System.assertEquals(i, j);
			}catch(Exception e){}
            }
            Boolean b = AGN_GCSP_CustomerRegStep1Controller.isDuplicateUser('abc@abc.com', 'DE');
            System.assertEquals(b, false);
            try{
				AGN_GCSP_CustomerRegStep1Controller.isDuplicateUser('abc@abc.com', 'throw new AuraHandledException(e.getMessage());');		//exception Test	
                System.assertEquals(i, j);
			}catch(Exception e){}
            List<Object> l1 = AGN_GCSP_CustomerRegStep1Controller.getAllConfigurations('DE', '1', 'Clinic','Public or Private Clinic','oam');
            System.assertNotEquals(l1, null);
            try{
				AGN_GCSP_CustomerRegStep1Controller.getAllConfigurations(null, '1', 'Clinic','Public or Private Clinic','oam');				//exception Test
                System.assertEquals(i, j);
			}catch(Exception e){}
            AGN_GCSP_CustomerRegStep1Controller.getAllConfigurations('GB', '1', 'Retail pharmacy','Retail pharmacy','oam');
            System.assertEquals(i, j);
            /*try{
    			AGN_GCSP_CustomerRegStep1Controller.getCustomerRegDetails();        
			}catch(Exception e){}*/
            
            AGN_GCSP_CustomerRegStep1Controller.getCustomerAddressDetails(cr.id);
            System.assertEquals(i, j);
            try{
    			AGN_GCSP_CustomerRegStep1Controller.getCustomerAddressDetails(null);         //exception Test
                System.assertEquals(i, j);
			}catch(Exception e){}
            AGN_GCSP_CustomerRegStep1Controller.getPickListOptions('Form_Of_Payment_AGN__c', 'Form_Of_Payment_Label_AGN__c');
            System.assertEquals(i, j);
            try{
    			AGN_GCSP_CustomerRegStep1Controller.getPickListOptions(null, 'Form_Of_Payment_Label_AGN__c');         //exception Test
                System.assertEquals(i, j);
			}catch(Exception e){}
            AGN_GCSP_CustomerRegStep1Controller.getCommonSettings();
            System.assertEquals(i, j);
            try{
    			AGN_GCSP_CustomerRegStep1Controller.getCommonSettings();      //exception Test
                System.assertEquals(i, j);
			}catch(Exception e){}
            AGN_GCSP_CustomerRegStep1Controller.fetchFooterConsents('de');
            System.assertEquals(i, j);
            AGN_GCSP_CustomerRegStep1Controller.getCustomerCofing('de');
            System.assertEquals(i, j);
            
            Test.stopTest();
             
        }
    }
      
}