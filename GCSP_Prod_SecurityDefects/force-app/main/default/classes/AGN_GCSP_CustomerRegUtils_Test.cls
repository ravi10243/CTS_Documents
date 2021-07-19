@isTest
public class AGN_GCSP_CustomerRegUtils_Test{
    public static testmethod void customerRegUtilsTest(){
        
        user u = AGN_GCSP_CustReg_TestUtilityClass.createUser();         
        
        system.runAs(u){         
            list<Customer_Type_Configuration_AGN__c> configlist = AGN_GCSP_CustReg_TestUtilityClass.createCustTupeConfig();
            
            OAM_User_Settings__c oamUser = AGN_GCSP_CustReg_TestUtilityClass.createOAMUser();
            //list<Profile> p=[SELECT id FROM profile WHERE Name = 'Allergan Customer Community Login DE' LIMIT 1];
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
            
            user comm_user = AGN_GCSP_CustReg_TestUtilityClass.createCommunityUser();          
            
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
            //Allergan_Customer_Registration_AGN__c cr2 = AGN_GCSP_CustReg_TestUtilityClass.createCustReg(PersonAcc, c, fop, pt, true);
            
            list<Allergan_Customer_Address_AGN__c> lstcra = new list<Allergan_Customer_Address_AGN__c>(); 
            list<Allergan_Customer_Address_AGN__c> lstcraNew = new list<Allergan_Customer_Address_AGN__c>();
            Allergan_Customer_Address_AGN__c cra = AGN_GCSP_CustReg_TestUtilityClass.createCustRegAdd(cr,false); 
            lstcraNew.add(cra);
            Allergan_Customer_Address_AGN__c cra1 = AGN_GCSP_CustReg_TestUtilityClass.createCustRegAdd(cr,true);
            lstcra.add(cra1);
            //Allergan_Customer_Address_AGN__c cra2 = AGN_GCSP_CustReg_TestUtilityClass.createCustRegAdd(cr2,true);
            Attachment att = AGN_GCSP_CustReg_TestUtilityClass.createAttachment(cr);    
            
            string countryid=[select id,AGN_Country_Name__c from Country_vod__c where AGN_Country_Name__c='Germany' limit 1].id;
            
            Allergan_Customer_Address_AGN__c soldto1 = new Allergan_Customer_Address_AGN__c(
                Additional_Comments_AGN__c = 'Comments',Address_Line_1_AGN__c = 'address', Address_Line_2_AGN__c = 'address two', Bank_Account_Number_AGN__c = '5638756',Bank_Name_AGN__c = 'HSBC',
                City_AGN__c = 'city', Company_Name_AGN__c = 'Company', Country_AGN__c = 'Germany',Country_Lookup_AGN__c=countryid, Customer_Group_AGN__c = 'cl',Department_Name_AGN__c = 'dep name', Distribution_ID_AGN__c = '53678',Email_AGN__c = 'te@gf.kl', Fax_AGN__c = '34567',
                Phone_AGN__c = '3053647',SAP_SalesText_AGN__c = 'SText1',SAP_Search_Term_1_AGN__c ='sSearchtrerm1', Sort_Code_AGN__c = '123345', Street_Name_AGN__c = 'Street name', Sub_Type_AGN__c = 'Public or Private Clinic', SWIFT_BIC_AGN__c = 'sdf', Tax_Classification_AGN__c = '0',
                Type_AGN__c ='Clinic', VAT_Number_AGN__c = '2344', Zip_AGN__c = '34345',House_Number_AGN__c='50b' );
            Allergan_Customer_Contact_AGN__c acrCon = AGN_GCSP_CustReg_TestUtilityClass.createCustContact(cr,true);
            
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
            
            
            AGN_GCSP_CustomerRegUtils.checkForDuplicateCustomer(comm_user.Username, 'DE');
            AGN_GCSP_CustomerRegUtils.getLayoutCountrySetting('DE','1','Clinic','Public or Private Clinic',configlist,'oam');
            List<Customer_Type_Configuration_AGN__c> ctc = new List<Customer_Type_Configuration_AGN__c>();
            try{
                AGN_GCSP_CustomerRegUtils.getLayoutCountrySetting('DE','1','Clinic','Public or Private Clinic',ctc,'oam');
            }catch(Exception e){}
            try{
                AGN_GCSP_CustomerRegUtils.getLayoutCountrySettingUpdateReg('DE','1','Clinic','Public or Private Clinic',configlist,'oam');
            }catch(Exception e){}
               
            System.runAs(comm_user){
                
                Account a = AGN_GCSP_CustomerRegUtils.createAccount(cra1, cr, 'DE');
                
                Contact con = AGN_GCSP_CustomerRegUtils.createContact(cr, a, 'DE');
                
                AGN_GCSP_CustomerRegUtils.createCommunityUser(con.Id, 'DE', 'de');
                
                AGN_GCSP_CustomerRegUtils.generateRandomString(16);
                AGN_GCSP_CustomerRegUtils.createNewCustomerRegistration(cr, soldto1, configList, con, 'de');
                AGN_GCSP_CustomerRegUtils.createNewCustomerRegistrationCS(cr, soldto1, configList, con, c, acrCon, 'de');
                
            }    
            
            AGN_GCSP_CustomerRegUtils.getCustomerGroup('DE', 'Clinic', 'Public or Private Clinic');
            try{
                AGN_GCSP_CustomerRegUtils.getCustomerGroup('DEA', 'Clinic', 'Public or Private Clinic'); // exception Test
            }catch(Exception e){}
            AGN_GCSP_CustomerRegUtils.getCountry(); 
            
            Test.stopTest();
        }
    }
    
}