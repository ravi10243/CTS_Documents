@isTest
public class AGN_CustomerRegistrationUtils_Test{
    public static testmethod void customerRegUtilsTest(){
            
    
           user u = AGN_CustReg_TestUtilityClass.createUser(); 
            u.Country_Code__c='DE';
            Update u;
            system.runAs(u){ 
            list<Customer_Type_Configuration_AGN__c> configlist = AGN_GCSP_CustReg_TestUtilityClass.createCustTupeConfig();
            
            OAM_User_Settings__c oamUser = AGN_GCSP_CustReg_TestUtilityClass.createOAMUser();            
            AGN_GCSP_Settings__c gcspSettings = AGN_CustReg_TestUtilityClass.createGCSPSettings();
            
            Specialty_Allergan_AGN__c spe = AGN_GCSP_CustReg_TestUtilityClass.createSpecialty_Allergan();
            Country_vod__c country = AGN_CustReg_TestUtilityClass.createCountry();
            
            Account BussinessAcc =  AGN_GCSP_CustReg_TestUtilityClass.createBussinessAccount(spe, country);
             //   BussinessAcc.Name = 'bussiness account';
             //   update BussinessAcc;
            system.assert(BussinessAcc != null, 'Bussiness account is required for Person Account creation');
            
            Account personAcc =  AGN_GCSP_CustReg_TestUtilityClass.createPersonAccount(BussinessAcc);     
            system.assert(PersonAcc != null, 'person account is required for User creation');          
         
            
             list<Allergan_Consent_Footer_Info__c> conFooterList = new list<Allergan_Consent_Footer_Info__c>();
            
            Allergan_Consent_Footer_Info__c conFooter = AGN_GCSP_CustReg_TestUtilityClass.createConsentFooter();            
              conFooterList.add(conFooter);
            
            user user = AGN_GCSP_CustReg_TestUtilityClass.createCommunityUser();  
             system.runAs(u){    
            
            Form_Of_Payment_AGN__c fop = AGN_GCSP_CustReg_TestUtilityClass.createFormOfPayment();
            Payment_Term_AGN__c  pt = AGN_GCSP_CustReg_TestUtilityClass.createPaymentTerm(fop);
            Allergan_Customer_Payment_AGN__c payment = AGN_GCSP_CustReg_TestUtilityClass.createCustPayments(PersonAcc,fop,pt);
            
            //Child_Account_vod__c childAcc = AGN_GCSP_CustReg_TestUtilityClass.createChildAccount(BussinessAcc);          
            Address_vod__c add = AGN_GCSP_CustReg_TestUtilityClass.createAddress(BussinessAcc);
                 add.City_vod__c='abc';
                 add.Zip_vod__c='12395';
                 //add.Phone_AGN__c='1234567890';
                 add.Email_AGN__c='abc@abc.com';
                 add.State_vod__c= 'Ontario';
                 add.Phone_vod__c= '98569566';
                // add.Account_vod__r.Name = ;
               //  add.Email_AGN__c = 'cr@email.com'
                // add.Zip_vod__c = '34375'
                 update add;
                 
            
            Entitlement ent =  AGN_GCSP_CustReg_TestUtilityClass.createEntitlement(PersonAcc);            
            Case_Configuration_AGN__c caseconfig = AGN_GCSP_CustReg_TestUtilityClass.createCaseConfig(ent,PersonAcc);
                 
            
            Case c = AGN_GCSP_CustReg_TestUtilityClass.createCase(ent);
                // c.RecordType.Name = 'abc';
                 //update  c;
                 //Record_Type_Name_AGN__c
                 system.debug('@@@caserecoredtype@@@' + c.RecordType.Name);
                  //c.RecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Support Request - Customer Update' LIMIT 1][0];            
                 //c.RecordType.Name = 'Support Request - Customer Update';
            // update  c;
            Allergan_Customer_Registration_AGN__c cr1 = AGN_GCSP_CustReg_TestUtilityClass.createCustReg(PersonAcc, c, fop, pt, false);
            Allergan_Customer_Registration_AGN__c cr = AGN_GCSP_CustReg_TestUtilityClass.createCustReg(PersonAcc, c, fop, pt, true);
            //Allergan_Customer_Registration_AGN__c cr2 = AGN_GCSP_CustReg_TestUtilityClass.createCustReg(PersonAcc, c, fop, pt, true);
            //cr.Country_Code_AGN__c = 'DE';
            Allergan_Customer_Contact_AGN__c cca =  AGN_GCSP_CustReg_TestUtilityClass.createCustContact(cr,true);
            
            list<Allergan_Customer_Address_AGN__c> lstcra = new list<Allergan_Customer_Address_AGN__c>(); 
            list<Allergan_Customer_Address_AGN__c> lstcraNew = new list<Allergan_Customer_Address_AGN__c>();
            list<Allergan_Customer_Address_AGN__c> BilltoList1 = new list<Allergan_Customer_Address_AGN__c>(); 
                 
            list<Allergan_Customer_Address_AGN__c> BilltoList2 = new list<Allergan_Customer_Address_AGN__c>();
            list<Allergan_Customer_Address_AGN__c> ShiptoList1 = new list<Allergan_Customer_Address_AGN__c>(); 
            list<Allergan_Customer_Address_AGN__c> ShiptoList2 = new list<Allergan_Customer_Address_AGN__c>(); 
                 
            Allergan_Customer_Address_AGN__c cra = AGN_GCSP_CustReg_TestUtilityClass.createCustRegAdd(cr,true); 
             cra.State_AGN__c = 'dsfa';
             cra.SAP_ID_AGN__c = '123123123';
                update cra;
            lstcraNew.add(cra);
            Allergan_Customer_Address_AGN__c cra1 = AGN_GCSP_CustReg_TestUtilityClass.createCustRegAdd(cr,true);
                cra1.Company_Name_AGN__c='abcCorp';
           // Allergan_Customer_Address_AGN__c cra2 = AGN_GCSP_CustReg_TestUtilityClass.createCustRegAdd(cr,true);     
           // lstcra.add(cra2);     
            system.Debug('Countrycodedebug-->' + cra1.Country_Code_AGN__c );
                 string countryid=[select id,AGN_Country_Name__c from Country_vod__c where AGN_Country_Name__c='Germany' limit 1].id;
            
            Allergan_Customer_Address_AGN__c billto1 = new Allergan_Customer_Address_AGN__c(RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id,
                                                                                    Additional_Comments_AGN__c = 'Comments',Address_Line_1_AGN__c = 'address', Address_Line_2_AGN__c = 'address two', Bank_Account_Number_AGN__c = '5638756',Bank_Name_AGN__c = 'HSBC', Bill_To_AGN__c = True,
                                                                                    City_AGN__c = 'city', Are_You_The_Prescribing_Doctor_AGN__c=True, Company_Name_AGN__c = 'Company', Country_AGN__c = 'Germany',Country_Lookup_AGN__c=countryid, Customer_Group_AGN__c = 'cl',Department_Name_AGN__c = 'dep name', Distribution_ID_AGN__c = '53678',Email_AGN__c = 'te@gf.kl', Fax_AGN__c = '34567',
                                                                                    Parent_AGN__c = cr.Id, Phone_AGN__c = '3497647',SAP_SalesText_AGN__c = 'SText1',SAP_Search_Term_1_AGN__c ='sSearchtrerm1', Ship_To_AGN__c = false,Sold_To_AGN__c = false, Sort_Code_AGN__c = '123345', Street_Name_AGN__c = 'Street name', Sub_Type_AGN__c = 'Public or Private Clinic', SWIFT_BIC_AGN__c = 'sdf', Tax_Classification_AGN__c = '0',
                                                                                    Type_AGN__c ='Clinic', VAT_Number_AGN__c = '2344', Zip_AGN__c = '34345',House_Number_AGN__c='50b' );  
           Allergan_Customer_Address_AGN__c billto2 = new Allergan_Customer_Address_AGN__c(RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id,
                                                                                    Additional_Comments_AGN__c = 'Comments',Address_Line_1_AGN__c = 'address', Address_Line_2_AGN__c = 'address two', Bank_Account_Number_AGN__c = '5638756',Bank_Name_AGN__c = 'HSBC', Bill_To_AGN__c = True,
                                                                                    City_AGN__c = 'city', Are_You_The_Prescribing_Doctor_AGN__c=True, Company_Name_AGN__c = 'Company', Country_AGN__c = 'Germany',Country_Lookup_AGN__c=countryid, Customer_Group_AGN__c = 'cl',Department_Name_AGN__c = 'dep name', Distribution_ID_AGN__c = '53678',Email_AGN__c = 'te@gf.kl', Fax_AGN__c = '34567',
                                                                                    Parent_AGN__c = cr.Id, Phone_AGN__c = '3459647',SAP_SalesText_AGN__c = 'Sext1',SAP_Search_Term_1_AGN__c ='sSearchtrerm1', Ship_To_AGN__c = false,Sold_To_AGN__c = false, Sort_Code_AGN__c = '123345', Street_Name_AGN__c = 'Street name', Sub_Type_AGN__c = 'Public or Private Clinic', SWIFT_BIC_AGN__c = 'sdf', Tax_Classification_AGN__c = '0',
                                                                                    Type_AGN__c ='Clinic', VAT_Number_AGN__c = '2344', Zip_AGN__c = '34345',House_Number_AGN__c='50b' );        
            Allergan_Customer_Address_AGN__c shipto1 = new Allergan_Customer_Address_AGN__c(RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id,
                                                                                    Additional_Comments_AGN__c = 'Comments',Address_Line_1_AGN__c = 'address', Address_Line_2_AGN__c = 'address two', Bank_Account_Number_AGN__c = '5638756',Bank_Name_AGN__c = 'HSBC', Bill_To_AGN__c = False,
                                                                                    City_AGN__c = 'city', Are_You_The_Prescribing_Doctor_AGN__c=True, Company_Name_AGN__c = 'Company', Country_AGN__c = 'Germany',Country_Lookup_AGN__c=countryid, Customer_Group_AGN__c = 'cl',Department_Name_AGN__c = 'dep name', Distribution_ID_AGN__c = '53678',Email_AGN__c = 'te@gf.kl', Fax_AGN__c = '34567',
                                                                                    Parent_AGN__c = cr.Id, Phone_AGN__c = '3463647',SAP_SalesText_AGN__c = 'SText1',SAP_Search_Term_1_AGN__c ='sSearchtrerm1', Ship_To_AGN__c = True,Sold_To_AGN__c = false, Sort_Code_AGN__c = '123345', Street_Name_AGN__c = 'Street name', Sub_Type_AGN__c = 'Public or Private Clinic', SWIFT_BIC_AGN__c = 'sdf', Tax_Classification_AGN__c = '0',
                                                                                    Type_AGN__c ='Clinic', VAT_Number_AGN__c = '2344', Zip_AGN__c = '34345',House_Number_AGN__c='50b' );      
            Allergan_Customer_Address_AGN__c shipto2 = new Allergan_Customer_Address_AGN__c(RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id,
                                                                                    Additional_Comments_AGN__c = 'Comments',Address_Line_1_AGN__c = 'address', Address_Line_2_AGN__c = 'address two', Bank_Account_Number_AGN__c = '5638756',Bank_Name_AGN__c = 'HSBC', Bill_To_AGN__c = False,
                                                                                    City_AGN__c = 'city', Are_You_The_Prescribing_Doctor_AGN__c=True, Company_Name_AGN__c = 'Company', Country_AGN__c = 'Germany',Country_Lookup_AGN__c=countryid, Customer_Group_AGN__c = 'cl',Department_Name_AGN__c = 'dep name', Distribution_ID_AGN__c = '53678',Email_AGN__c = 'te@gf.kl', Fax_AGN__c = '34567',
                                                                                    Parent_AGN__c = cr.Id, Phone_AGN__c = '3053647',SAP_SalesText_AGN__c = 'SText1',SAP_Search_Term_1_AGN__c ='sSearchtrerm1', Ship_To_AGN__c = True,Sold_To_AGN__c = false, Sort_Code_AGN__c = '123345', Street_Name_AGN__c = 'Street name', Sub_Type_AGN__c = 'Public or Private Clinic', SWIFT_BIC_AGN__c = 'sdf', Tax_Classification_AGN__c = '0',
                                                                                    Type_AGN__c ='Clinic', VAT_Number_AGN__c = '2344', Zip_AGN__c = '34345',House_Number_AGN__c='50b' ); 
                 
           Allergan_Customer_Address_AGN__c soldto1 = new Allergan_Customer_Address_AGN__c(RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id,
                                                                                    Additional_Comments_AGN__c = 'Comments',Address_Line_1_AGN__c = 'address', Address_Line_2_AGN__c = 'address two', Bank_Account_Number_AGN__c = '5638756',Bank_Name_AGN__c = 'HSBC', Bill_To_AGN__c = False,
                                                                                    City_AGN__c = 'city', Are_You_The_Prescribing_Doctor_AGN__c=True, Company_Name_AGN__c = 'Company', Country_AGN__c = 'Germany',Country_Lookup_AGN__c=countryid, Customer_Group_AGN__c = 'cl',Department_Name_AGN__c = 'dep name', Distribution_ID_AGN__c = '53678',Email_AGN__c = 'te@gf.kl', Fax_AGN__c = '34567',
                                                                                    Parent_AGN__c = cr.Id, Phone_AGN__c = '3053647',SAP_SalesText_AGN__c = 'SText1',SAP_Search_Term_1_AGN__c ='sSearchtrerm1', Ship_To_AGN__c = False,Sold_To_AGN__c = True, Sort_Code_AGN__c = '123345', Street_Name_AGN__c = 'Street name', Sub_Type_AGN__c = 'Public or Private Clinic', SWIFT_BIC_AGN__c = 'sdf', Tax_Classification_AGN__c = '0',
                                                                                   Type_AGN__c ='Clinic', VAT_Number_AGN__c = '2344', Zip_AGN__c = '34345',House_Number_AGN__c='50b' );
                 
           Allergan_Customer_Address_AGN__c soldto2 = new Allergan_Customer_Address_AGN__c(RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id,
                                                                                    Additional_Comments_AGN__c = 'Comments',Address_Line_1_AGN__c = 'address1', Address_Line_2_AGN__c = 'address two', Bank_Account_Number_AGN__c = '5638756',Bank_Name_AGN__c = 'HSBC', Bill_To_AGN__c = False,
                                                                                    City_AGN__c = 'city1', Are_You_The_Prescribing_Doctor_AGN__c=True, Company_Name_AGN__c = 'Company', Country_AGN__c = 'Germany',Country_Lookup_AGN__c=countryid, Customer_Group_AGN__c = 'cl',Department_Name_AGN__c = 'dep name', Distribution_ID_AGN__c = '53678',Email_AGN__c = 'te@gf.kl', Fax_AGN__c = '34567',
                                                                                    Parent_AGN__c = cr.Id, Phone_AGN__c = '3023647',SAP_SalesText_AGN__c = 'SText12',SAP_Search_Term_1_AGN__c ='sSearchtrerm1', Ship_To_AGN__c = False,Sold_To_AGN__c = True, Sort_Code_AGN__c = '123345', Street_Name_AGN__c = 'Street name', Sub_Type_AGN__c = 'Public or Private Clinic', SWIFT_BIC_AGN__c = 'sdf', Tax_Classification_AGN__c = '0',
                                                                                   Type_AGN__c ='Clinic1', VAT_Number_AGN__c = '2044', Zip_AGN__c = '34945',House_Number_AGN__c='50b' );      
                 
          Allergan_Customer_Registration_AGN__c cr2 = new Allergan_Customer_Registration_AGN__c(
                                                                                             Case_AGN__c = c.Id, Country_Code_AGN__c = 'DE',Customer_Category_AGN__c = 'Clinic', Customer_Group_AGN__c = 'CL', Customer_Sub_Category_AGN__c = 'Public or Private Clinic', Distribution_ID_AGN__c = '8934573978',Email_AGN__c = 'dfg@gs.yky', Fax_AGN__c = '78358',
                                                                                             Account_AGN__c=personAcc.id,First_Name_AGN__c = 'test',Online_Registration_Step_AGN__c='2', Form_of_Payment_AGN__c = fop.id, Gender_AGN__c = 'M', Last_Name_AGN__c = 'Test', NIF_CIF_Number_AGN__c = '8989898', Online_Registration_AGN__c = true,SAP_Country_Code_AGN__c='DE',
                                                                                             Payment_Term_AGN__c = pt.id, Phone_AGN__c = '34758358', Physician_Registration_Reference_AGN__c = '45475768', RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Registration_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id, 
                                                                                             Registration_License_Number_AGN__c = '834758', Salutation_AGN__c = 'Mr.',Tax_Exempted_AGN__c = 'Yes', VAT_AGN__c = '45657');
         Allergan_Customer_Address_AGN__c cra2 = new Allergan_Customer_Address_AGN__c(RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Allergan_Customer_Address_AGN__c' AND DeveloperName = 'New' LIMIT 1][0].Id,
                                                                                    Additional_Comments_AGN__c = 'Comme1nts',Address_Line_1_AGN__c = 'address', Address_Line_2_AGN__c = 'address two', Bank_Account_Number_AGN__c = '5638756',Bank_Name_AGN__c = 'HSBC', Bill_To_AGN__c = true,
                                                                                    City_AGN__c = 'city1', Are_You_The_Prescribing_Doctor_AGN__c=True, Company_Name_AGN__c = 'Company', Country_AGN__c = 'Germany',Country_Lookup_AGN__c=countryid, Customer_Group_AGN__c = 'cl',Department_Name_AGN__c = 'dep name', Distribution_ID_AGN__c = '53678',Email_AGN__c = 'te@gf.kl', Fax_AGN__c = '34567',
                                                                                    Parent_AGN__c = cr.Id, Phone_AGN__c = '3459647',SAP_SalesText_AGN__c = 'SText1',SAP_Search_Term_1_AGN__c ='sSearchtrerm1', Ship_To_AGN__c = true,Sold_To_AGN__c = true, Sort_Code_AGN__c = '123345', Street_Name_AGN__c = 'Street name', Sub_Type_AGN__c = 'Public or Private Clinic', SWIFT_BIC_AGN__c = 'sdf', Tax_Classification_AGN__c = '0',
                                                                                    Type_AGN__c ='Clinic2', VAT_Number_AGN__c = '2344', Zip_AGN__c = '34345',House_Number_AGN__c='50b' );
        
   Customer_Detail_AGN__c oldAddress = new Customer_Detail_AGN__c() ;   
                 oldAddress.Name= 'nbf';
                 oldAddress.Department_Name_AGN__c='afds';
                 oldAddress.Address_Line_1_AGN__c='asdfg';
                 oldAddress.Address_Line_2_AGN__c='asdfg';
                 oldAddress.Address_Line_3_AGN__c='qwert';
                 oldAddress.City_AGN__c='rftgh';
                 oldAddress.State_AGN__c='werty';
                 oldAddress.Zip_AGN__c='76567';
                 oldAddress.Phone_AGN__c='1234567890';
                 
                 insert oldAddress;
                 
                 
                 
                 BilltoList1.add(billto1);
          BilltoList2.add(billto2);
           ShiptoList1.add(shipto1);
           ShiptoList2.add(shipto2); 
          lstcra.add(soldto1);      
                 insert BilltoList1;
                 insert BilltoList2;
               insert ShiptoList1;
                insert ShiptoList2; 
                 insert lstcra; 
              //   insert lstcraNew;
                 
                 
            //     lstcra.add(cra1);
           // lstcra.add(cra2);   
           //insert lstcra;    
                
            Attachment att = AGN_GCSP_CustReg_TestUtilityClass.createAttachment(cr);      
            //list<Allergan_Customer_Address_AGN__c> lstcra = new list<Allergan_Customer_Address_AGN__c>();
            
            List<AGN_Community_Layout_Setting__mdt> metadaLayOut= [SELECT SObject_Name_AGN__c,
                                                                   Field_Name_AGN__c,
                                                                   Sort_Order_AGN__c,
                                                                   Field_Label_AGN__c,
                                                                   Required_AGN__c,
                                                                   Section_Header_AGN__c,
                                                                   Section_Header_Label_AGN__c,
                                                                   Customer_Groups_AGN__c,
                                                                   Field_Regex_AGN__c,
                                                                   Step_No_AGN__c,
                                                                   Registration_Source_AGN__c,
                                                                   Country_AGN__c
                                                                   FROM AGN_Community_Layout_Setting__mdt 
                                                                   WHERE (Country_AGN__c = 'DE' OR
                                                                          Country_AGN__c = 'GB' OR Country_AGN__c = 'IE')];
            
            AGN_Community_Layout_Setting__mdt[] metadataList = [SELECT SObject_Name_AGN__c,
                                                                Field_Name_AGN__c,
                                                                Sort_Order_AGN__c,
                                                                Field_Label_AGN__c,
                                                                Required_AGN__c,
                                                                Section_Header_AGN__c,
                                                                Section_Header_Label_AGN__c,
                                                                Customer_Groups_AGN__c,
                                                                Field_Regex_AGN__c,
                                                                Step_No_AGN__c,
                                                                Registration_Source_AGN__c,
                                                                Country_AGN__c
                                                                FROM AGN_Community_Layout_Setting__mdt 
                                                                WHERE (Country_AGN__c = 'DE' OR
                                                                          Country_AGN__c = 'GB' OR Country_AGN__c = 'IE')];
            
            system.assertEquals(metadataList, metadaLayOut); 
         Test.startTest();
         

            //AGN_CustomerRegistrationUtils.createNewCustomerRegistration(cr2,cra2,configlist);

            AGN_CustomerRegistrationUtils.setEntitlement(caseconfig.Case_Record_Type__c,caseconfig.Category_AGN__c,caseconfig.Country_Code_AGN__c);

            AGN_CustomerRegistrationUtils.generateNewChangeList(cra, oldAddress);

         
         Test.stopTest();    
        }
    }
}
}