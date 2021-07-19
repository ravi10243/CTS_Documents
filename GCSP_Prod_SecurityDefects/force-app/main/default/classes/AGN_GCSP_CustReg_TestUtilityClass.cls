@isTest
public class AGN_GCSP_CustReg_TestUtilityClass {

      /** 
* ******************************************************
* This method is test data for create GCSP CommonSettings
* ******************************************************
*/
    
    public static AGN_GCSP_Common_Setting_AGN__mdt createCommonSettingsMethod(){
        return [Select Account_Activation_Page_Name_AGN__c,
                Community_Base_URL_AGN__c,
                Community_Suffix_AGN__c,
                Encrypt_Decrypt_Private_Key_AGN__c,
                Manage_Password_Page_Name_AGN__c,
                OAM_Step1_Registration_Page_AGN__c,
                OAM_Step2_Registration_Page_AGN__c,
                OAM_Step3_Registration_Page_AGN__c,
                OAM_Step4_Registration_Page_AGN__c,
                OAM_Step5_Registration_Page_AGN__c,
                OAM_User_Profile_AGN__c,
                Okta_API_Key_AGN__c,
                Okta_Base_URL_AGN__c,
                Okta_Redirect_URL_AGN__c,
                UsernameSuffix_AGN__c,
                GoogleCapcha_AGN__c
                from AGN_GCSP_Common_Setting_AGN__mdt
                where DeveloperName = 'COMMON'];
    }
    
    /** 
* ******************************************************
* This method is test data for create User
* ******************************************************
*/
    
    public static User createUser()
    {
        User u = [SELECT ID,Country_Code__c,UserName,UserRoleId,AccountId,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,Email,Alias,ProfileId,Profile.Name FROM User WHERE ID = :userinfo.getUserId()];
         u.Country_Code__c = 'DE';
        
        update u;
        /* if(u == null){
            Profile p =[SELECT Id, name FROM Profile limit 1];
                
            UserRole urole = new UserRole(Name='CEOS',OpportunityAccessForAccountOwner='Edit');
            insert urole;
            User sysadmn = new User(Alias = 'agn', Email='susr@testsandorg.com', 
                                    EmailEncodingKey='UTF-8', LastName='Testings', LanguageLocaleKey='de', 
                                    LocaleSidKey='de', ProfileId = p.Id, UserRoleId = urole.Id,
                                    TimeZoneSidKey='America/Los_Angeles', UserName='susr@testsandorg.com',Country_Code__c='DE',Position_AGN__c='QA');
            
            insert sysadmn;  
           // u= [SELECT ID,Country_Code__c,UserName,ContactId,AccountId,TimeZoneSidKey,LocaleSidKey,LanguageLocaleKey,Email,Alias,ProfileId,Profile.Name FROM User WHERE ID = :sysadmn.Id];
       // }
        
        return sysadmn; */
        return u;
    }
    
    /** 
* ******************************************************
* This method is test data for create OAM_User_Settings__c
* ******************************************************
*/
    
    public static OAM_User_Settings__c createOAMUser() 
    {                                        
        user sysadmn = createUser();
        
        OAM_User_Settings__c oamSettings = new OAM_User_Settings__c();
        
        oamSettings.User_Language__c = 'de';
        oamSettings.User_Locale__c ='de';
        oamSettings.Name = sysadmn.Country_Code__c;
        oamSettings.User_Profile__c = sysadmn.profile.Name;
        oamSettings.User_Timezone__c =sysadmn.TimeZoneSidKey;
        oamSettings.Username_Suffix__c = sysadmn.Alias; 
     
        insert oamSettings;

        return oamSettings;
    }
    
    /** 
* ******************************************************
* This method is test data for create AGN_GCSP_Settings__c
* ******************************************************
*/
    
    public static AGN_GCSP_Settings__c createGCSPSettings()
    {
        user sysadmn = createUser();
        
        Group gp = [SELECT ID, DeveloperName FROM Group WHERE DeveloperName = 'AGN_EMEA_MDM' LIMIT 1];
        
        AGN_GCSP_Settings__c gcspSettings = new AGN_GCSP_Settings__c();
        
        gcspSettings.Name = sysadmn.Country_Code__c;
        gcspSettings.Account_Managed_By__c = 'Data';
        gcspSettings.Activation_Token_Valid_Till_AGN__c = 24;
        gcspSettings.Community_Base_URL_AGN__c = 'https://gcspeudev-allergancommunityeu.cs84.force.com';
        gcspSettings.Community_Suffix_AGN__c = '/customerDE';
        gcspSettings.CR_Record_Owner__c = sysadmn.Id;
        gcspSettings.CR_User_Profile__c = sysadmn.profile.Name;
        gcspSettings.CR_UserName_Suffix__c = sysadmn.Alias; 
        gcspSettings.Enable_Automated_New_DCR__c = false;
        gcspSettings.Enable_Bill_To__c = true;
        gcspSettings.Enable_HCO_Affiliation__c = true;
        gcspSettings.Enable_Logs__c = true;
        gcspSettings.Encrypt_Decrypt_Private_Key_AGN__c = 'X7M3JVxaKxhwacwmTt6y9whYaCDc9aDG2ycgh0HMQe0=';
        gcspSettings.HCP_to_HCO__c = false;
        gcspSettings.Okta_API_Key_AGN__c = '00TVJwhQClrppPb1T-rzH7fqMEcvQ3hKpXlmndVo2P';
        gcspSettings.Okta_Base_URL_AGN__c = 'https://allergandev.okta.com';
        gcspSettings.Okta_OAuth2_Issuer_AGN__c = 'https://allergandev.okta.com/oauth2/default';
        gcspSettings.Okta_Redirect_URL_AGN__c = 'https://allergandev.okta.com/home/salesforce_portal/0oa1ejfqjexdoPawW1d8/1339';
        gcspSettings.Okta_SF_Community_Group_Id_AGN__c = gp.id;
        gcspSettings.Online_Account_Management__c = false;
        gcspSettings.ProductApprovalCheck__c = 'text';
        gcspSettings.reCaptcha_End_Point__c = 'https://www.google.com/recaptcha/api/siteverify';
        gcspSettings.reCaptcha_Secret__c = '6LduHyUUAAAAAPL0cgsayyaVLj3vps0GEjYXpy3W';
        gcspSettings.reCaptcha_Site_Key__c = '6LduHyUUAAAAAGe2hRmimfQ3W1GF7ajmDT_1suD0';
        gcspSettings.Registration_Step1_Page__c = 'AGN_CustomerRegistration';
        gcspSettings.Registration_Step2_Page__c = '/s/agncustomerregistration2';
        gcspSettings.SendtoSAP_Password__c = 'Connect1';
        gcspSettings.SendtoSAP_Post_Request_URL__c = 'https://devgatewayerp.allergan.com/sap/bc/zvcreatecust';
        gcspSettings.SendtoSAP_Username__c = 'WEBSFC_CPIC';
        gcspSettings.SoldToShipToCheck__c = false;
        gcspSettings.ZipFetchAddress__c = true;
        gcspSettings.Number_Of_BillTo_Allowed_AGN__c = 3;
        gcspSettings.Number_Of_ShipTo_Allowed_AGN__c = 3;
        
        
        insert gcspSettings;
        
        return gcspSettings;
    }
    
    
    /** 
* ******************************************************
* This method is test data for create Specialty_Allergan
* ******************************************************
*/
    public static Specialty_Allergan_AGN__c createSpecialty_Allergan()
    {
        
        Specialty_Allergan_AGN__c spe = new Specialty_Allergan_AGN__c();        
        spe.Active_AGN__c =true;
        spe.Country_code_AGN__c = 'DE';
        spe.English_Value_AGN__c = 'Ophthalmology';
        spe.Name = 'Ophthalmology';
        spe.External_ID_AGN__c = '3455657';
        spe.Translated_Value_AGN__c='Ophthalmologie';
        
        insert spe;
        
        return spe;
    }
    
    /** 
* ******************************************************
* This method is test data for create Sub Specialty_Allergan
* ******************************************************
*/
    public static Sub_Specialty_Allergan__c createSubSpecialty_Allergan()
    {
        
     Sub_Specialty_Allergan__c subSpe = new Sub_Specialty_Allergan__c();
        
        subSpe.Active_AGN__c = true;
        subSpe.Code_AGN__c = 'Q002';
        subSpe.Country_code_AGN__c = 'DE';
        subSpe.English_Value_AGN__c = 'Speciality';
        subSpe.External_ID_AGN__c = '3456456';
        subSpe.Name = 'Speciality Name';
        subSpe.Medical_Affairs_AGN__c = 'Yes';
        
        insert subSpe;
        
        return subSpe;
    }
    
    /** 
* ******************************************************
* This method is test data for create Country
* ******************************************************
*/
    public static Country_vod__c createCountry()
    { 
        Country_vod__c country = new Country_vod__c();
        
        country.AGN_Country_Name__c = 'Germany';
        country.Alpha_2_Code_vod__c = 'DE';
        country.Country_Name_vod__c = 'DE';
        country.Name = 'DE';        
        
        insert country;
        
        return country;        
    }
    
    /** 
* ***********************************************************************
* This method is test data for create Bussiness Account
* ***********************************************************************
*/
    
    public static Account createBussinessAccount(Specialty_Allergan_AGN__c spe,  Country_vod__c country)
    {
               
        string  AccRecordTypeId =  [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Pharmacy_vod' LIMIT 1][0].Id;
        
        Account bussinessAccount = new Account( RecordTypeId =  [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Pharmacy_vod' LIMIT 1][0].Id,Country_vod__c  = country.Id, External_ID2_AGN__c = '3444535',Customer_Category_AGN__c = 'Clinic', 
                                               Customer_Sub_Category_AGN__c = 'Public or Private Clinic', Calling_Name_AGN__c = 'call name', Country_Code__c = 'DE',SAP_Customer_Group_AGN__c = 'CL',SAP_Search_Term_1_AGN__c = 'etrry',SAP_Country_Code_AGN__c = 'DE',SAP_Tax_Classification_AGN__c = '0',
                                               SAP_Sold_To_AGN__c=true,Phone = '43556577899',Specialty_Allergan_1_AGN__c = spe.Id,name='test');
        
        insert bussinessAccount; 
        
        return bussinessAccount;
        
    }
    
     /** 
* ***********************************************************************
* This method is test data for create Person Account
* ***********************************************************************
*/
    
    
    public static Account createPersonAccount(Account parentAcc)
    {
       
        string  AccRecordTypeId =  [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id;
        
        Account Acc = new Account( RecordTypeId =  [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Professional_vod' LIMIT 1][0].Id,Country_vod__c  = parentAcc.Country_vod__c, Distribution_ID_AGN__c = '238475845',External_ID2_AGN__c = '34535',firstname = 'Test Acc',lastname='lastTest',Status_AGN__c = 'Active',Customer_Category_AGN__c = 'Clinic', 
                                  Customer_Sub_Category_AGN__c = 'Public or Private Clinic', Calling_Name_AGN__c = 'call name', Country_Code__c = 'DE', Fax = '454579',SAP_Customer_Group_AGN__c = 'CL',SAP_Search_Term_1_AGN__c = 'etrry',SAP_Country_Code_AGN__c = 'DE',SAP_Tax_Classification_AGN__c = '0', SAP_VAT_Number_AGN__c = '34545676',Salutation='Mr.',
                                  Gender_vod__c = 'M',Phone = '2345664',PersonEmail='varun34@yopmail.com',Physician_Registration_Reference_AGN__c = '23453',Specialty_Allergan_1_AGN__c = parentAcc.Specialty_Allergan_1_AGN__c, Primary_Parent_vod__c=parentAcc.Id,Parent=parentAcc);
        
        
        insert acc; 
        
        return Acc;
    }
    
     /** 
* ***********************************************************************
* This method is test data for create Child Account
* ***********************************************************************
*/
     public static Child_Account_vod__c createChildAccount(Account bAcc)
     {
              
       Child_Account_vod__c childAcc = new Child_Account_vod__c(Parent_Account_vod__c = bAcc.Id,  
                                                                 Sold_To_AGN__c= true, Ship_To_AGN__c=true, 
                                                                 Bill_To_AGN__c=true,Customer_Managed_AGN__c =true);
         
         insert childAcc;
         
         return childAcc;
     }
    
    
         /** 
* **********************************************
* This method is test data for create Address
* **********************************************
*/
     public static Address_vod__c createAddress(Account bAcc)
     {
       
        Address_vod__c add = new Address_vod__c(Account_vod__c =bAcc.Id, Name = 'Add Name', Address_line_2_vod__c ='Test Address',State_vod__c= 'Ontario', City_vod__c= 'city', Country_vod__c='Germany', 
                                                Phone_vod__c= '98569566', Email_AGN__c = 'cr@email.com', Zip_vod__c = '34375', Customer_Managed_AGN__c =true);
         
         insert add;
         
         return add;
     }
    
  /** 
* ****************************************************************
* This method is test data for create Allergan Customer Payments
* ****************************************************************
*/
     public static Allergan_Customer_Payment_AGN__c createCustPayments(Account pAcc,Form_Of_Payment_AGN__c fop, Payment_Term_AGN__c pt)
     {
        system.debug('fop--->'+fop); 
         system.debug('pt--->'+pt); 
         system.debug('Acc--->'+pAcc); 
        Allergan_Customer_Payment_AGN__c payment = new Allergan_Customer_Payment_AGN__c(Account_AGN__c= pAcc.id, Bank_Name_AGN__c='HSBC', Bank_Account_Number_AGN__c='473685738', IBAN_AGN__c = 'DE236463445656', Sort_Code_AGN__c='3478', 
                                                                                        SWIFT_BIC_AGN__c='4576',Form_Of_Payment_AGN__c= fop.id, Payment_Term_AGN__c=pt.id);
        
        insert payment;         
         System.debug('pay---->'+payment);
         return payment;
     }    
    
    
    /**
* ************************************************************
* This method is test data for create Case object
* ************************************************************
*/
    
    public static Case createCase(Entitlement ent)
    {
        Case caseNewCr = new Case();         
        caseNewCr.Service_AGN__c = 'Customer Registration';
        caseNewCr.Type = 'New';
        caseNewCr.Reason = 'New Customer Address';
        caseNewCr.Priority = 'Medium';
        caseNewCr.Origin = 'Web';
        caseNewCr.Status = 'Approved';           
        caseNewCr.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Support Request - Customer Update' LIMIT 1][0].Id;            
        caseNewCr.Case_Sub_Status_AGN__c='Online Registration - In Progress';
        caseNewCr.country_code_AGN__c = 'DE';
        caseNewCr.EntitlementId = ent.Id;
        
        insert caseNewCr; 
       case caseNewCrid = [SELECT Id,Service_AGN__c,Type,Reason,Priority,Origin,Status,
                            RecordType.Name,Case_Sub_Status_AGN__c,country_code_AGN__c,EntitlementId
                            FROM case WHERE id =: caseNewCr.Id  LIMIT 1];
        return  caseNewCrid;
    } 
    
    /**
* ************************************************************
* This method is test data for create Entitlement object
* ************************************************************
*/
    
    public static Entitlement createEntitlement(Account pacc)
    {
       
        Entitlement ent = new Entitlement();
            ent.AccountId = pacc.id;
            ent.Name = 'AGN DE Customer Registration';
            ent.EndDate = system.today();
            ent.StartDate = system.today();
            ent.IsPerIncident = false; 
            ent.Type = 'Phone Support';
        
        insert ent; 
        
        return  ent;
    } 
    
     /**
* ************************************************************
* This method is test data for create Case Configuration object
* ************************************************************
*/
    
    public static Case_Configuration_AGN__c createCaseConfig(Entitlement ent,Account pacc)
    {
       string countryid=[select id,AGN_Country_Name__c from Country_vod__c where AGN_Country_Name__c='Germany' limit 1].id; 
        Case_Configuration_AGN__c caseconfig = new Case_Configuration_AGN__c();
            caseconfig.Case_Record_Type__c = 'Support Request - Customer Update';
            caseconfig.Active_AGN__c = true;
            caseconfig.Category_AGN__c= 'New';
            caseconfig.Country_Code_AGN__c = 'DE';
            caseconfig.Entitlement_AGN__c = ent.Id;
            caseconfig.Static_Category_AGN__c='New';
        	caseconfig.Country_AGN__c=countryid;
        	
            caseconfig.Service_AGN__c = 'Customer Registration';
            caseconfig.Reason_AGN__c = 'New Customer Registration';
            caseconfig.VF_Page_Name_AGN__c = 'AGN_New_Customer_Registeration_DE';
        
        insert caseconfig; 
        
        return  caseconfig;
    } 
    
    
       /** 
* ******************************************************
* This method is test data for create Form OF Payment
* ******************************************************
*/
    public static Form_Of_Payment_AGN__c createFormOfPayment()
    { 
       Form_Of_Payment_AGN__c fop = new Form_Of_Payment_AGN__c ();
        
        fop.Active_AGN__c= true;
        fop.Country_Code_AGN__c = 'DE';
        fop.Name = 'SEPA Direct Debit';
        fop.Requires_AR_Approval_AGN__c = false;
        fop.SAP_Code_AGN__c ='2F';
        fop.SAP_Country_Code_AGN__c = 'DE';
           
        insert fop;
        
        return fop;        
    }
    
    /** 
* ******************************************************
* This method is test data for create Payment Term
* ******************************************************
*/
    public static Payment_Term_AGN__c createPaymentTerm( Form_Of_Payment_AGN__c fop)        
    { 
      
        Payment_Term_AGN__c  pt = new Payment_Term_AGN__c ();
        
        pt.Form_Of_Payment__c = fop.id;
        pt.Name = 'End of next month';
        pt.SAP_Payment_Term_Code_AGN__c = 'Q001';
         
        insert pt;
        
        return pt;        
    }
    
      /** 
* **************************************************************
* This method is test data for create Customer Registration
* **************************************************************
*/
    public static Allergan_Customer_Registration_AGN__c createCustReg(Account acc, case caseNewCr, Form_Of_Payment_AGN__c fop, Payment_Term_AGN__c pt, boolean doInsert){
      
                   
        Allergan_Customer_Registration_AGN__c cr = new Allergan_Customer_Registration_AGN__c(
                                                                                             Case_AGN__c = caseNewCr.Id, Country_Code_AGN__c = 'DE',Customer_Category_AGN__c = 'Clinic', Customer_Group_AGN__c = 'CL', Customer_Sub_Category_AGN__c = 'Public or Private Clinic', Distribution_ID_AGN__c = '8934573978',Email_AGN__c = 'dfg@gs.yky', Fax_AGN__c = '78358',
                                                                                             Account_AGN__c=acc.id,First_Name_AGN__c = 'test',Online_Registration_Step_AGN__c='2', Form_of_Payment_AGN__c = fop.id, Gender_AGN__c = 'M', Last_Name_AGN__c = 'Test', NIF_CIF_Number_AGN__c = '8989898', Online_Registration_AGN__c = true,SAP_Country_Code_AGN__c='DE',
                                                                                             Payment_Term_AGN__c = pt.id, Phone_AGN__c = '34758358', Physician_Registration_Reference_AGN__c = '45475768', RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id, 
                                                                                             Registration_License_Number_AGN__c = '834758', Salutation_AGN__c = 'Mr.',Tax_Exempted_AGN__c = 'Yes', VAT_AGN__c = '45657');
        
         system.debug('crcase--->'+cr);
        if(doInsert){
        insert cr;
           
        }
        system.debug('crcase after insert--->'+cr);

        return cr;
    } 
    
          /** 
* ******************************************************************
* This method is test data for create Customer Registration Address
* ******************************************************************
*/
    public static Allergan_Customer_Address_AGN__c createCustRegAdd(Allergan_Customer_Registration_AGN__c cr, boolean doInsert){
      
        string countryid=[select id,AGN_Country_Name__c from Country_vod__c where AGN_Country_Name__c='Germany' limit 1].id;     
       Allergan_Customer_Address_AGN__c cra = new Allergan_Customer_Address_AGN__c(RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id,
                                                                                    Additional_Comments_AGN__c = 'Comments',Address_Line_1_AGN__c = 'address', Address_Line_2_AGN__c = 'address two', Bank_Account_Number_AGN__c = '5638756',Bank_Name_AGN__c = 'HSBC', Bill_To_AGN__c = true,
                                                                                    City_AGN__c = 'city', Are_You_The_Prescribing_Doctor_AGN__c=True, Company_Name_AGN__c = 'Company', Country_AGN__c = 'Germany',Country_Lookup_AGN__c=countryid, Customer_Group_AGN__c = 'cl',Department_Name_AGN__c = 'dep name', Distribution_ID_AGN__c = '53678',Email_AGN__c = 'te@gf.kl', Fax_AGN__c = '34567',
                                                                                    Parent_AGN__c = cr.Id, Phone_AGN__c = '3453647',SAP_SalesText_AGN__c = 'SText1',SAP_Search_Term_1_AGN__c ='sSearchtrerm1', Ship_To_AGN__c = true,Sold_To_AGN__c = true, Sort_Code_AGN__c = '123345', Street_Name_AGN__c = 'Street name', Sub_Type_AGN__c = 'Public or Private Clinic', SWIFT_BIC_AGN__c = 'sdf', Tax_Classification_AGN__c = '0',
                                                                                    Type_AGN__c ='Clinic', VAT_Number_AGN__c = '2344', Zip_AGN__c = '34345',House_Number_AGN__c='50b' );
        if(doInsert){ 
        insert cra;
        }
        return cra;
    } 
    
              /** 
  * ******************************************************************
* This method is test data for create Customer contact
* ******************************************************************
*/
    public static Allergan_Customer_Contact_AGN__c createCustContact(Allergan_Customer_Registration_AGN__c cr, boolean doInsert){
      
             
       Allergan_Customer_Contact_AGN__c cca = new Allergan_Customer_Contact_AGN__c(Parent_AGN__c=cr.id,
                                                                                   				Contact_Person_Type_AGN__c='ZI',Email_AGN__c='abc@abc.com',
                                                                                   First_Name_AGN__c=cr.First_Name_AGN__c,Last_Name_AGN__c=cr.Last_Name_AGN__c
                                                                                    );
        if(doInsert){ 
        insert cca;
        }
        return cca;
    } 
    
              /** 
* ******************************************************************             
* ******************************************************************
* This method is test data for create Customer Type Configuration
* ******************************************************************
*/
    public static list<Customer_Type_Configuration_AGN__c> createCustTupeConfig(){
        
       list<Customer_Type_Configuration_AGN__c> configList = new list<Customer_Type_Configuration_AGN__c>();
        Customer_Type_Configuration_AGN__c cTypeConfig  = new Customer_Type_Configuration_AGN__c(Category_AGN__c = 'Clinic', Category_Label_AGN__c ='Klinik' , Country_Code_AGN__c = 'DE', Customer_Group_AGN__c ='CL' , Sub_Category__c = 'Public or Private Clinic',                                                                                                
                                                                                                Customer_Group_Display_Text_AGN__c='display text',Documents_Required_AGN__c='AAF Form (Required); SEPA Mandate Form(if applicable);',Sub_Category_Label_AGN__c='Klinik ohne eigene Apotheke',
                                                                                                Documents_For_Online_Registration_AGN__c='Trainingsbestätigung (bitte hochladen);Approbationsurkunde (bitte hochladen);Arztausweis (bitte hochladen);',Account_Record_Type_AGN__c='Practice_vod',
                                                                                                Applicable_For_Online_Registration_AGN__c=True);
        
        configList.add(cTypeConfig);
        
        insert configList;
        
        return configList;
    }
    
         /** 
* ******************************************************************
* This method is test data for create Attachment
* ******************************************************************
*/
    public static Attachment createAttachment(Sobject obj){
        
      Attachment attach=new Attachment(); 
        attach.Name='Unit Test Attachment'; 
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        attach.body=bodyBlob; 
        attach.parentId=obj.Id; 
        attach.ContentType = 'application/msword'; 
        attach.IsPrivate = false; 
        attach.Description = 'Test'; 
        insert attach;
        
        return attach;
    }
    
      /** 
* ******************************************************************
* This method is test data for create Allergan_Consent_Footer_Info__c
* ******************************************************************
*/
    public static Allergan_Consent_Footer_Info__c createConsentFooter(){
        
      Allergan_Consent_Footer_Info__c footer =new Allergan_Consent_Footer_Info__c(Name='sample footer', Language__c='de', Footer_RichText_c__c='This is simple footer'); 
       
        insert footer;
        
        return footer;
    }
    
       /** 
* ******************************************************************
* This method is test data for create Community user
* ******************************************************************
*/
    public static User createCommunityUser(){
      // Account acc = [Select Id, Name, OwnerId,Owner.UserRole.Id,Owner.UserRole.Name From Account Where Owner.UserRole.Id != null AND RecordType.name = 'Practice_vod' Limit 1]; 
            
       Account acc = new Account ( Name='fname', Country_Code__c='DE', phone='7623434785356', Email_Internal_AGN__c='krishna9892@yopmail.com',Customer_Sub_Category_AGN__c='Public or Private Clinic',Customer_Category_AGN__c ='Clinic');
       insert acc;
           
            Contact con = new Contact ( AccountId = acc.Id, LastName = 'portalTestUser');
            insert con;     
        
            // UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'none' limit 1];
            Profile p =[SELECT ID, Name FROM Profile where Name='Allergan Customer Community' limit 1];
        
        system.debug('@@@@@@profile p --->'+P);
            
            User customerUser = new User();
            customerUser.Email = acc.Email_Internal_AGN__c;
            customerUser.Phone = acc.Phone;
            customerUser.FirstName = 'Fname';
            customerUser.LastName = 'LName';
            customerUser.Alias = 'nuser';
            customerUser.LanguageLocaleKey = 'de';
            customerUser.EmailEncodingKey = 'UTF-8';
            customerUser.LocalesIdKey = 'de';
            customerUser.TimezonesIdKey = 'Europe/London';
            customerUser.ProfileId =p.id;
            customerUser.Username = acc.PersonEmail;
            customerUser.Username = customerUser.Email+'.' + 'agn';
            customerUser.CommunityNickname='flname';
            customerUser.ContactId = con.id;
            customerUser.Country_Code__c = 'DE';
            customerUser.Division = acc.Customer_Sub_Category_AGN__c;
            customerUser.FederationIdentifier = acc.Email_Internal_AGN__c.toLowercase(); //SSO Mapping

            insert customerUser;  
        
        return customerUser;
    }

        /** 
    * ******************************************************************
    * This method is test data for create Community user with OAM status Complete
    * ******************************************************************
    */
    
    public static User createCompleteCommunityUser(){
      // Account acc = [Select Id, Name, OwnerId,Owner.UserRole.Id,Owner.UserRole.Name From Account Where Owner.UserRole.Id != null AND RecordType.name = 'Practice_vod' Limit 1]; 
            
       Account acc = new Account ( Name='fname', Country_Code__c='DE', phone='7623434785356', Email_Internal_AGN__c='krishna9892@yopmail.com',Customer_Sub_Category_AGN__c='Public or Private Clinic',Customer_Category_AGN__c ='Clinic');
       insert acc;
           
            Contact con = new Contact ( AccountId = acc.Id, LastName = 'portalTestUser', Customer_Registration_AGN__c = 'Complete');
            insert con;     
        
            // UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'none' limit 1];
            Profile p =[SELECT ID, Name FROM Profile where Name='Allergan Customer Community Login DE' limit 1];
        
        system.debug('@@@@@@profile p --->'+P);
            
            User customerUser = new User();
            customerUser.Email = acc.Email_Internal_AGN__c;
            customerUser.Phone = acc.Phone;
            customerUser.FirstName = 'Fname';
            customerUser.LastName = 'LName';
            customerUser.Alias = 'nuser';
            customerUser.LanguageLocaleKey = 'de';
            customerUser.EmailEncodingKey = 'UTF-8';
            customerUser.LocalesIdKey = 'de';
            customerUser.TimezonesIdKey = 'Europe/London';
            customerUser.ProfileId =p.id;
            customerUser.Username = acc.PersonEmail;
            customerUser.Username = customerUser.Email+'.' + 'agn';
            customerUser.CommunityNickname='flname';
            customerUser.ContactId = con.id;
            customerUser.Country_Code__c = 'DE';
            customerUser.Division = acc.Customer_Sub_Category_AGN__c;
            customerUser.FederationIdentifier = acc.Email_Internal_AGN__c.toLowercase(); //SSO Mapping

            insert customerUser;  
        
        return customerUser;
    }
    
}