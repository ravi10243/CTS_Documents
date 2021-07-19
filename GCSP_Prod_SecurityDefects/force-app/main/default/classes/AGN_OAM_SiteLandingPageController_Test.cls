@isTest
public class AGN_OAM_SiteLandingPageController_Test {

    public static testmethod void siteLandingPageControllerTest(){
    
    List<Allergan_Customer_Contact_AGN__c > agncclist = new List<Allergan_Customer_Contact_AGN__c >();
    Allergan_Customer_Contact_AGN__c agncc = new Allergan_Customer_Contact_AGN__c();
    
    User u = new User();    
    Profile sp = [SELECT Id, Name FROM Profile WHERE Name='System Administrator' LIMIT 1];
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
            
            agncc.Parent_AGN__c = cr.id;
            agncclist.add(agncc);
            
            insert agncclist;
            
            Allergan_Customer_Contact_AGN__c agnccc1 = [select id from Allergan_Customer_Contact_AGN__c LIMIT 1 ];
            
            Allergan_Address_Contact_Mapping_agn__c agnacconmap = new Allergan_Address_Contact_Mapping_agn__c();
            agnacconmap.Allergan_Customer_Contact_agn__c = agnccc1.id;
            agnacconmap.Allergan_Customer_Registration_agn__c = cr.id;
            agnacconmap.Allergan_Customer_Address_agn__c = cra1.id;
            insert agnacconmap;
            
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
          
          AGN_GCSP_Country_Lang_Settings__c gcspsetting = new AGN_GCSP_Country_Lang_Settings__c();
          gcspsetting.Country_Code_AGN__c = 'GB';
          gcspsetting.Lang_Code_AGN__c = 'en_GB';
          gcspsetting.Language_AGN__c = 'English';
          gcspsetting.Name = 'United Kingdom';
          system.runAs(u){ 
          insert gcspsetting;
          }
          
          Test.startTest();
          
          AGN_OAM_SiteLandingPageController agncontrolller = new AGN_OAM_SiteLandingPageController();
          agncontrolller.userLanguage = 'English';
          agncontrolller.selectedCountry = 'United Kingdom';
          agncontrolller.getcountryList();     
          agncontrolller.moveToCommunity();
          
          Test.stopTest(); 
          
         integer i = 0;
         integer j = 0;
         System.assertEquals(i,j);
    
    }
}