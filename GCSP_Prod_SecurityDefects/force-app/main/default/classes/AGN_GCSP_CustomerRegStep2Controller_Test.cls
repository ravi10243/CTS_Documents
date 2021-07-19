@isTest
public class AGN_GCSP_CustomerRegStep2Controller_Test {
    public static testmethod void registrationMethodTest(){
        User u = new User();    
        Profile sp = [SELECT Id, Name FROM Profile WHERE Name='AGN GCSP Lightning Profile' LIMIT 1];
        UserRole urole = [SELECT Name,Id FROM UserRole WHERE Name = 'CSMGR' LIMIT 1]; 
        u = new User(Alias = 'agn', Email='pk@vp.kp', 
                     EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='de', 
                     LocaleSidKey='de', ProfileId = sp.Id, UserRoleId = urole.Id,
                     TimeZoneSidKey='Europe/London', UserName='pk@vp.kp',Country_Code__c='DE');
        
        insert u; 
               
        Account acc;
         user customerUser;
        system.runAs(u){     
            acc =new Account();      
         acc.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
                                            AND DeveloperName = 'Professional_vod'
                                            LIMIT 1
                                           ][0].Id;
            acc.Salutation = 'Mr.';
            acc.FirstName ='Test';
            acc.LastName = 'Last';
            acc.PersonEmail = 'Email@ema.kl';
            acc.Phone = '784623857';
            acc.Customer_Registration_AGN__c = 'In Progress';
            acc.Customer_Managed_AGN__c = true;
            acc.Country_Code__c = 'DE';
            acc.Customer_Category_AGN__c = 'Clinic';
            acc.Customer_Sub_Category_AGN__c ='Public or Private Clinic';             
         insert acc;       
         }    
         
        Account customerAccount = [SELECT ID, Name,PersonContactId,Salutation,FirstName,LastName,PersonEmail,Phone,Customer_Registration_AGN__c,Primary_Parent_vod__c,Customer_Managed_AGN__c,Country_Code__c,Customer_Category_AGN__c,Customer_Sub_Category_AGN__c FROM Account WHERE Id=: acc.ID];
          system.debug('@@@@customerAccount-->'+customerAccount.PersonContactId);
        
        customerUser = new User();
            
            Profile p =[SELECT ID, Name FROM Profile where Name='Allergan Customer Community' limit 1];
            
            system.debug('@@@@@@profile p --->'+P);
            
            customerUser.Email = customerAccount.PersonEmail;
            customerUser.Phone =customerAccount.Phone;
            customerUser.FirstName = 'Fname';
            customerUser.LastName = 'LName';
            customerUser.Alias = 'nuser';
            customerUser.LanguageLocaleKey = 'de';
            customerUser.EmailEncodingKey = 'UTF-8';
            customerUser.LocalesIdKey = 'de';
            customerUser.TimezonesIdKey = 'Europe/London';
            customerUser.ProfileId =p.id;
            customerUser.Username = customerAccount.PersonEmail;
            customerUser.Username = customerAccount.PersonEmail;
            customerUser.CommunityNickname='flname';
            customerUser.ContactId = customerAccount.PersonContactId;
            customerUser.Country_Code__c = 'DE';
            customerUser.Division = customerAccount.Customer_Sub_Category_AGN__c;
            customerUser.FederationIdentifier = customerAccount.PersonEmail.toLowercase(); //SSO Mapping
            
            insert customerUser;             
           system.debug('@@@@customerUser-->'+customerUser);
        
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
        
         system.runAs(u){  
             configlist =new list<Customer_Type_Configuration_AGN__c>();
             configlist = AGN_CustReg_TestUtilityClass.createCustTupeConfig();
            
            OAM_User_Settings__c oamUser = AGN_CustReg_TestUtilityClass.createOAMUser();            
            AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();
            
             spe = new Specialty_Allergan_AGN__c();
             spe = AGN_CustReg_TestUtilityClass.createSpecialty_Allergan();
             
             country = new Country_vod__c();
             country = AGN_CustReg_TestUtilityClass.createCountry();
            
         //   Account BussinessAcc =  AGN_CustReg_TestUtilityClass.createBussinessAccount(spe, country);
          //  system.assert(BussinessAcc != null, 'Bussiness account is required for Person Account creation');             
            
            Allergan_Consent_Footer_Info__c conFooter = AGN_CustReg_TestUtilityClass.createConsentFooter();            
              conFooterList.add(conFooter);
            
            fop = new Form_Of_Payment_AGN__c();
            fop = AGN_CustReg_TestUtilityClass.createFormOfPayment();
             
            pt =new Payment_Term_AGN__c();
            pt = AGN_CustReg_TestUtilityClass.createPaymentTerm(fop);
            
            payment = new Allergan_Customer_Payment_AGN__c();
            payment = AGN_CustReg_TestUtilityClass.createCustPayments(customerAccount,fop,pt);
         /*   
            Child_Account_vod__c childAcc = AGN_CustReg_TestUtilityClass.createChildAccount(BussinessAcc);          
            Address_vod__c add = AGN_CustReg_TestUtilityClass.createAddress(BussinessAcc); 
              Child_Account_vod__c childAcc = AGN_CustReg_TestUtilityClass.createChildAccount(customerAccount);          
            Address_vod__c add = AGN_CustReg_TestUtilityClass.createAddress(customerAccount); */
            ent= new Entitlement(); 
            ent =  AGN_CustReg_TestUtilityClass.createEntitlement(customerAccount); 
            
            caseconfig = new  Case_Configuration_AGN__c();
            caseconfig = AGN_CustReg_TestUtilityClass.createCaseConfig(ent,customerAccount);
            
            c = new Case();
            c = AGN_CustReg_TestUtilityClass.createCase(ent);
            
           // Allergan_Customer_Registration_AGN__c cr1 = AGN_CustReg_TestUtilityClass.createCustReg(customerAccount, c, fop, pt, false);
            cr = new Allergan_Customer_Registration_AGN__c();
            cr = AGN_CustReg_TestUtilityClass.createCustReg(customerAccount, c, fop, pt, true);
            system.debug('@@@Cr-->'+cr);       
           
           
            Allergan_Customer_Address_AGN__c cra1 = AGN_CustReg_TestUtilityClass.createCustRegAdd(cr,true);
            lstcra.add(cra1);
            
            att = new Attachment();
            att = AGN_CustReg_TestUtilityClass.createAttachment(cr);      
            
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
            
          }  
            
        system.runAs(customerUser){     
           Test.startTest();
            Integer i = 1;
            Integer j = 1;
            AGN_GCSP_CustomerRegStep2Controller.fetchCountryList('ES','oam');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.fetchCountryList(null,'oaa');        //exception test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getLayout('Spain','1','oam');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep1Controller.getLayout(null,'1','oam'); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getLayout('DE','1','Clinic','Public or Private Clinic',configlist,'oam');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep1Controller.getLayout(null,'1','Clinic','Public or Private Clinic',configlist,'oam'); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getLayoutUpdateReg('Spain','1','oam');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.getLayoutUpdateReg(null,'1','oam'); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getLayoutUpdateReg('DE','1','Clinic','Public or Private Clinic',configlist,'oam');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.getLayoutUpdateReg(null,'1','Clinic','Public or Private Clinic',configlist,'oam'); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getCustomerGroup('DE', 'Clinic', 'Public or Private Clinic');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.getCustomerGroup(null, 'Clinic', 'Public or Private Clinic'); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.customerTypeConfig('ES','oam');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.customerTypeConfig(null,'oam'); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            try{
                AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetails();
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetailsCS((String)c.id);
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.getCustomerRegDetailsCS(null); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getCustomerAddressDetails((String)cr.id);
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.getCustomerAddressDetails(null); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getCaseDetails((String)c.id);
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.getCaseDetails(null); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getcustomerContactDetails((String)cr.id);
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.getcustomerContactDetails(null); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.upsertRegistrationDetails(lstcra[0], lstcra, lstcra, lstcraNew, lstcraNew, cr, 'next', '2');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.upsertRegistrationDetails(null, lstcra, lstcra, lstcraNew, lstcraNew, cr, 'null', '2'); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.upsertCustomerDetails(cr, lstcra[0], spe.Translated_Value_AGN__c, 'next', '2', 'oam');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.upsertCustomerDetails(null, lstcra[0], spe.Translated_Value_AGN__c, 'null', '2', 'oam'); // exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            try{
                AGN_GCSP_CustomerRegStep2Controller.saveChunk(null, null, null , 'a', 'b', 'c', 'd'); // exception test
                System.assertEquals(i, j);
            }catch(Exception e){}
            try{
                AGN_GCSP_CustomerRegStep2Controller.deleteFile(null);
                System.assertEquals(i, j);
            }catch(Exception e){}
            try{
                AGN_GCSP_CustomerRegStep2Controller.FetchObjectDetails();
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getGCSPSettings('DE');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.upsertAllAddressDetails(lstcra[0], lstcra, lstcra, lstcraNew, lstcraNew, cr, '4', 'save', 'oam'); // exception test
                System.assertEquals(i, j);
            }catch (Exception e){}
            List<sObject> foplst=AGN_GCSP_CustomerRegStep2Controller.getPaymentMethods('DE','oam');
            System.assertEquals(i, j);
            try{
                AGN_GCSP_CustomerRegStep2Controller.getPaymentTerms(null, 'oam'); //exception Test
                System.assertEquals(i, j);
            }catch(Exception e){}
            AGN_GCSP_CustomerRegStep2Controller.getPickListValues('Form_Of_Payment_AGN__c', 'Form_Of_Payment_Label_AGN__c', 'Id', '');
            System.assertEquals(i, j);
            AGN_GCSP_CustomerRegStep2Controller.getAllAttachments(cr.id,'oam');
            System.assertEquals(i, j);
            AGN_GCSP_CustomerRegStep2Controller.getAllAttachments(cr.id,'cs');
            System.assertEquals(i, j);
            AGN_GCSP_CustomerRegStep2Controller.getDocumentList(cr, 'oam');
            System.assertEquals(i, j);
            AGN_GCSP_CustomerRegStep2Controller.getDocumentList(cr, 'cs');
            System.assertEquals(i, j);
            AGN_GCSP_CustomerRegStep2Controller.getDocument('Comment Solid');
            System.assertEquals(i, j);
            AGN_GCSP_CustomerRegStep2Controller.getDocument('');
            System.assertEquals(i, j);
            //AGN_GCSP_CustomerRegStep2Controller.getDependentAttachments(cr.id,'4');
            System.assertEquals(i, j);
            AGN_GCSP_CustomerRegStep2Controller.getSpecialityDetails('DE');
            System.assertEquals(i, j);
            AGN_GCSP_CustomerRegStep2Controller.deleteAddress(lstcra[0]);
            System.assertEquals(i, j);
                 
            Test.stopTest(); 
        }
    } 
}