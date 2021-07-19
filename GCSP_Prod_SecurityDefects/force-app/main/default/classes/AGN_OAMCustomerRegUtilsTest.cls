@isTest
public class AGN_OAMCustomerRegUtilsTest{ 
    public static testmethod void registrationMethodTest(){     
        
        User u = new User();		
        Profile sp = [SELECT Id, Name FROM Profile WHERE Name='AGN GCSP Profile' LIMIT 1];
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
            acc.FirstName ='TestFirst';
            acc.LastName = 'LastTest';
            acc.PersonEmail = 'finalEmail@ema.kl';
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
        
        contact con = [SELECT Id, LastName FROM Contact WHERE Id=:customerAccount.PersonContactId];//new Contact(lastname='dhgdjg', AccountId=customerAccount.id);
       
        
        customerUser = new User();
        
        Profile p =[SELECT ID, Name FROM Profile where Name='Allergan Customer Community' limit 1];
        
        system.debug('@@@@@@profile p --->'+P);
        
        customerUser.Email = customerAccount.PersonEmail;
        customerUser.Phone =customerAccount.Phone;
        customerUser.FirstName = 'Firstname';
        customerUser.LastName = 'LastName';
        customerUser.Alias = 'newuser';
        customerUser.LanguageLocaleKey = 'de';
        customerUser.EmailEncodingKey = 'UTF-8';
        customerUser.LocalesIdKey = 'de';
        customerUser.TimezonesIdKey = 'Europe/London';
        customerUser.ProfileId =p.id;
        customerUser.Username = customerAccount.PersonEmail;
        customerUser.Username = customerAccount.PersonEmail;
        customerUser.CommunityNickname='filname';
        customerUser.ContactId = con.id;//customerAccount.PersonContactId;
        customerUser.Country_Code__c = 'DE';
        customerUser.Division = customerAccount.Customer_Sub_Category_AGN__c;
       // customerUser.IsPortalEnabled = true;
        // customerUser.FederationIdentifier = customerAccount.PersonEmail.toLowercase(); //SSO Mapping
        
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
        Allergan_Customer_Registration_AGN__c cr1;
        Allergan_Customer_Registration_AGN__c acr;
        list<Allergan_Customer_Address_AGN__c> lstcra = new list<Allergan_Customer_Address_AGN__c>(); 
        list<Allergan_Customer_Address_AGN__c> lstcraNew = new list<Allergan_Customer_Address_AGN__c>(); 
        Allergan_Customer_Address_AGN__c cra1;
        Attachment att;
        List<AGN_Community_Layout_Setting__mdt> metadaLayOut;
        OAM_User_Settings__c oamUser;
        AGN_GCSP_Settings__c gcspSettings;        
      
        system.runAs(u){  
            configlist =new list<Customer_Type_Configuration_AGN__c>();
            configlist = AGN_CustReg_TestUtilityClass.createCustTupeConfig();
            
            oamUser = new OAM_User_Settings__c();
            oamUser = AGN_CustReg_TestUtilityClass.createOAMUser(); 
            
            gcspSettings = new AGN_GCSP_Settings__c();
            gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();
            
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
            
            acr = new Allergan_Customer_Registration_AGN__c(Case_AGN__c = c.Id, Country_Code_AGN__c = 'DE',Customer_Category_AGN__c = 'Clinic', Customer_Group_AGN__c = 'CL', Customer_Sub_Category_AGN__c = 'Public or Private Clinic',Email_AGN__c = customerAccount.PersonEmail,
                                                            Account_AGN__c=customerAccount.id,First_Name_AGN__c = 'test', Form_of_Payment_AGN__c = fop.id, Gender_AGN__c = 'M', Last_Name_AGN__c = 'Test',Online_Registration_AGN__c = true,SAP_Country_Code_AGN__c='DE',
                                                            Payment_Term_AGN__c = pt.id, Phone_AGN__c = customerAccount.Phone,RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id, 
                                                            Salutation_AGN__c = 'Mr.',Tax_Exempted_AGN__c = 'Yes');
            
            cr1 = new Allergan_Customer_Registration_AGN__c();
            cr1 = AGN_CustReg_TestUtilityClass.createCustReg(customerAccount, c, fop, pt, false);
            
            Allergan_Customer_Address_AGN__c cra = new Allergan_Customer_Address_AGN__c();
            cra = AGN_CustReg_TestUtilityClass.createCustRegAdd(cr,true);
            lstcra.add(cra);
            system.debug('@@@Cr-->'+lstcra);           
            
            cra1 = new Allergan_Customer_Address_AGN__c();
            cra1 = AGN_CustReg_TestUtilityClass.createCustRegAdd(cr,false);
            
            att = new Attachment();
            att = AGN_CustReg_TestUtilityClass.createAttachment(cr);      
            
            metadaLayOut = new List<AGN_Community_Layout_Setting__mdt>();
            metadaLayOut= [SELECT SObject_Name_AGN__c,
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
            
            Test.setMock(HttpCalloutMock.class, new AGN_OktaUtilsMock());
            AGN_OAMCustomerRegUtils.createOktaUserSendLink(acr,customerAccount);     
            
            
            AGN_OAMCustomerRegUtils.checkForDuplicateCustomer(customerUser.Email);
            system.assertEquals(false,  AGN_OAMCustomerRegUtils.checkForDuplicateCustomer(customerUser.Email));            
            
            AGN_OAMCustomerRegUtils.mapCustomerType(configlist, lstcra[0], cr); // Private Method
            
            AGN_OAMCustomerRegUtils.createAccount(cr);        
            
            
            AGN_OAMCustomerRegUtils.SendExpiryLinkChangePassword(cr,customerAccount);
            AGN_OAMCustomerRegUtils.updateOktaUserIdInAccount(customerAccount.Id, '', '');  
            AGN_OAMCustomerRegUtils.updateOktaUserIdInAccount(customerAccount, '', '');
            AGN_OAMCustomerRegUtils.SendMailForgotRecoveryQA(customerUser, '');               
            
            //AGN_OAMCustomerRegUtils.forgotRecoveryQA(customerUser);
            
            AGN_OAMCustomerRegUtils.isRegistrationCompleted();            
            system.assertEquals(false, AGN_OAMCustomerRegUtils.isRegistrationCompleted());
            
            AGN_OAMCustomerRegUtils.isRegistrationCompleted(customerUser.id);
            system.assertEquals(false, AGN_OAMCustomerRegUtils.isRegistrationCompleted(customerUser.id));
            
            AGN_OAMCustomerRegUtils.getFooterConsents(customerUser.Country_Code__c);
            system.assertEquals(conFooterList, AGN_OAMCustomerRegUtils.getFooterConsents(customerUser.Country_Code__c));
            
            AGN_OAMCustomerRegUtils.updateAddressDetails(lstcra);
            system.assertEquals(true, AGN_OAMCustomerRegUtils.updateAddressDetails(lstcra));            
            
            
            AGN_OAMCustomerRegUtils.upsertCustomerDetails(cr, lstcra[0], spe.Translated_Value_AGN__c);
            AGN_OAMCustomerRegUtils.upsertAddressDetails(lstcra[0], lstcraNew, lstcraNew, lstcraNew, lstcraNew);
            AGN_OAMCustomerRegUtils.finishCustomerRegistration_finalStep(cr, lstcra[0], fop.Form_Of_Payment_Label_AGN__c, pt.SAP_Payment_Term_Code_AGN__c);
            
            AGN_OAMCustomerRegUtils.isSameAddress(cra1,lstcra[0]);
            AGN_OAMCustomerRegUtils.setEntitlement('Support Request - Customer Update','New','DE');
            AGN_OAMCustomerRegUtils.getLayoutCountrySetting('DE','2','Clinic', 'Public or Private Clinic', configlist);
            AGN_OAMCustomerRegUtils.deleteAddress(lstcra[0]);
            
            AGN_OAMCustomerRegUtils.findMatchingRows(metadaLayOut,'CL'); // Private Method (    @TestVisible)
            AGN_OAMCustomerRegUtils.groupByField('Section_Header_AGN__c',metadaLayOut); // Private Method            
            
            Test.stopTest();
            try{
                AGN_OAMCustomerRegUtils.createCommunityUser(customerAccount.Id);
            }catch(Exception e){}
             
            AGN_OAMCustomerRegUtils.createNewCustomerRegistration(cr1,cra1,configlist,customerAccount);
            AGN_OAMCustomerRegUtils.inactivateUser(customerUser.Id); 
        }
        
    }
    
}