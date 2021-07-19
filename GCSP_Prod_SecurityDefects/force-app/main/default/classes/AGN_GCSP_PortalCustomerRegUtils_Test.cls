@isTest
public class AGN_GCSP_PortalCustomerRegUtils_Test {
        @isTest//(seeAlldata=true)
        public static void PortalcustomerRegUtilsTest(){
            
    
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
            
            cr.Country_Code_AGN__c = 'DE';
            Allergan_Customer_Contact_AGN__c cca =  AGN_GCSP_CustReg_TestUtilityClass.createCustContact(cr,true);
            
            list<Allergan_Customer_Address_AGN__c> lstcra = new list<Allergan_Customer_Address_AGN__c>(); 
            list<Allergan_Customer_Address_AGN__c> lstcraNew = new list<Allergan_Customer_Address_AGN__c>();
            list<Allergan_Customer_Address_AGN__c> BilltoList1 = new list<Allergan_Customer_Address_AGN__c>(); 
                 
            list<Allergan_Customer_Address_AGN__c> BilltoList2 = new list<Allergan_Customer_Address_AGN__c>();
            list<Allergan_Customer_Address_AGN__c> ShiptoList1 = new list<Allergan_Customer_Address_AGN__c>(); 
            list<Allergan_Customer_Address_AGN__c> ShiptoList2 = new list<Allergan_Customer_Address_AGN__c>(); 
                 
            Allergan_Customer_Address_AGN__c cra = AGN_GCSP_CustReg_TestUtilityClass.createCustRegAdd(cr,true); 
            lstcraNew.add(cra);
            Allergan_Customer_Address_AGN__c cra1 = AGN_GCSP_CustReg_TestUtilityClass.createCustRegAdd(cr,true);
                cra1.Company_Name_AGN__c='abcCorp';
                 //cra1.Country_Lookup_AGN__c='DE';
                //cra1.Country_Code_AGN__c='DE';
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
                 
                 
                 
                 lstcra.add(cra1);
            //lstcra.add(cra2);   
           // insert lstcra;    
                
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
                
        //User uInfo = [SELECT Email,Country_Code__c from User where Id =: UserInfo.getUserId() limit 1];
        
                //User cu = [select Id,Email,Country_Code__c, ContactId from User where User.contact.customer_registration_agn__c = 'Complete' and country_code__c = 'DE' limit 1];
              
                Test.startTest();                
               
                    AGN_GCSP_PortalCustomerRegUtils.checkForDuplicateCustomer((string)u.Email,(string)u.Country_Code__c);
               
                
                    AGN_GCSP_PortalCustomerRegUtils.fetchAddress((string)u.Country_Code__c,(string)u.Email);
                
                            //    try{
                    AGN_GCSP_PortalCustomerRegUtils.getCustomerRegDetails();
               // } catch(exception e){}
                //try{
                  AGN_GCSP_PortalCustomerRegUtils.getCustomerRegDetailsCS(c.id);
               // } catch(exception e){}
                           //     try{
                 AGN_GCSP_PortalCustomerRegUtils.fetchCountryList((string)u.Country_Code__c,'oam');
               // } catch(exception e){}
                
               // try{
                   AGN_GCSP_PortalCustomerRegUtils.customerTypeConfig((string)u.Country_Code__c,'oam');
               // } catch(exception e){}
                          //      try{
                   AGN_GCSP_PortalCustomerRegUtils.provinceList((string)u.Country_Code__c);
               // } catch(exception e){}
               //  try{
                   AGN_GCSP_PortalCustomerRegUtils.getCustomerAddressDetails((string)cr.id);
               // } catch(exception e){}
               // try{
                   AGN_GCSP_PortalCustomerRegUtils.getcustomerContactDetails((string)cr.Id);
               // } catch(exception e){}
                
                Allergan_Customer_Registration_AGN__c customer;
                list<Allergan_Customer_Address_AGN__c> addList ;
                // try{
                   AGN_GCSP_PortalCustomerRegUtils.createContactAddAffiliations(cr,lstcra);//918
              //  } catch(exception e){}
                               
                //try{
                  AGN_GCSP_PortalCustomerRegUtils.FetchObjectDetails((string)cr.Id);
                //} catch(exception e){}
                
               // try{
                   AGN_GCSP_PortalCustomerRegUtils.getCaseDetails(c.id);
               // } catch(exception e){}
                
               // try{
                   AGN_GCSP_PortalCustomerRegUtils.setEntitlement((string)caseconfig.Case_Record_Type__c, (string)caseconfig.Static_Category_AGN__c, (string)caseconfig.Country_Code_AGN__c);
               // } catch(exception e){}
               // try{
                   AGN_GCSP_PortalCustomerRegUtils.getSpecialityDetails((string)c.country_code_AGN__c);
               // } catch(exception e){}
               // try{
                   AGN_GCSP_PortalCustomerRegUtils.getFieldMetadata(metadaLayOut[0].SObject_Name_AGN__c,
                                                                    metadaLayOut[0].Country_AGN__c,                                                                    
                                                                    Integer.valueof(metadaLayOut[0].Step_No_AGN__c),
                                                                   metadaLayOut[0].Customer_Groups_AGN__c,
                                                                   metadaLayOut[0].Registration_Source_AGN__c);
               // } catch(exception e){}
                AGN_GCSP_PortalCustomerRegUtils.upsertCustomerDetails(cr, soldto1, spe.Translated_Value_AGN__c, 'next', '2', 'oam');
               //System.assertEquals(i, j);
               
                         //  try{
                AGN_GCSP_PortalCustomerRegUtils.upsertRegistrationDetails(soldto1, BilltoList1, ShiptoList1, BilltoList2, ShiptoList2, cr, 'next', '2'); // exception Test
                //System.assertEquals(i, j);
            //}catch(Exception e){}
                           // try{
                AGN_GCSP_PortalCustomerRegUtils.upsertCustomerDetails(cr, soldto1, spe.Translated_Value_AGN__c, 'next', '2', 'oam'); // exception Test
                //System.assertEquals(i, j);
            //}catch(Exception e){}
                           // try{
                //AGN_GCSP_PortalCustomerRegUtils.saveChunk(null, null, null , 'a', 'b', 'c', 'd'); // exception test
                //System.assertEquals(i, j);
            //}catch(Exception e){}
                        //  try{
            //  AGN_GCSP_PortalCustomerRegUtils.deleteFile(null);
                //System.assertEquals(i, j);
            //}catch(Exception e){}
                         //   try{
            //AGN_GCSP_PortalCustomerRegUtils.FetchObjectDetails((string)cr.Id);
                //System.assertEquals(i, j);
            //}catch(Exception e){}
                         //   try{
                //\\AGN_GCSP_PortalCustomerRegUtils.upsertAllAddressDetails(soldto1, BilltoList1, ShiptoList1, BilltoList2, ShiptoList2, cr, '2', 'save', 'oam'); // exception test
               // System.assertEquals(i, j);
           // }catch (Exception e){}
               // try{
           //AGN_GCSP_PortalCustomerRegUtils.upsertRegistrationDetails(soldto1, BilltoList1, ShiptoList1, BilltoList2, ShiptoList2, cr,'save','4'); // exception test
               // System.assertEquals(i, j);
           // }catch (Exception e){}
                
                               // try{
         AGN_GCSP_PortalCustomerRegUtils.upsertAddressDetails(soldto1, BilltoList1, ShiptoList1, BilltoList2, ShiptoList2); // exception test
               // System.assertEquals(i, j);
          //  }catch (Exception e){}
                    

                                        //    try{
                //AGN_GCSP_PortalCustomerRegUtils.getDependentAttachments(cr.id,'2'); // exception test
               // System.assertEquals(i, j);
           // }catch (Exception e){}
                                                         //   try{
            //  AGN_GCSP_PortalCustomerRegUtils.getDependentAttachments(cr.id,'cs'); // exception test
               // System.assertEquals(i, j);
          //  }catch (Exception e){}
                
                           // try{
                //AGN_GCSP_PortalCustomerRegUtils.customerTypeConfig(null,'oam'); // exception Test
                //System.assertEquals(i, j);
            //}catch(Exception e){}
                          //  try{
                //AGN_GCSP_PortalCustomerRegUtils.getCustomerAddressDetails(soldto1.id);
            //}catch(Exception e){}
                
                                           // try{
                AGN_GCSP_PortalCustomerRegUtils.getCustomerAddressDetailsTemp(soldto1.Parent_AGN__c);
            //}catch(Exception e){}
                                                           // try{
            AGN_GCSP_PortalCustomerRegUtils.getPicklistOptions('Form_Of_Payment_AGN__c', 'Form_Of_Payment_Label_AGN__c');
            //}catch(Exception e){}
                                                                           // try{
                AGN_GCSP_PortalCustomerRegUtils.deleteAddress(soldto1);
            //}catch(Exception e){}
                
                   //   try{
                AGN_GCSP_PortalCustomerRegUtils.forgotRecoveryQA(user,True,(string)user.Country_Code__c);
            //}catch(Exception e){}
                  // try{
            //  AGN_GCSP_PortalCustomerRegUtils.saveTheFile(att.id, att.parentId, att.Name, 'UTF-8', 
                                                   //         att.ContentType, att.Description);
            //}catch(Exception e){}
                //try{  
         //   AGN_GCSP_PortalCustomerRegUtils.getDocument('Comment Solid');
               // }catch(Exception e){}
                
               //try{
            //AGN_GCSP_PortalCustomerRegUtils.finishCustomerRegistration_finalStep(soldto1, BilltoList1, ShiptoList1, BilltoList2, ShiptoList2,c,c.Country_Code_AGN__c);
            //}catch(Exception e){}
                
           // try{
        //  AGN_GCSP_PortalCustomerRegUtils.getFooterConsents('DE');
            //}catch(Exception e){}
                
                
                
                
            //System.assertEquals(i, j);
            //getFooterConsents
                
                //finishCustomerRegistration_finalStep
                //forgotRecoveryQA
                //saveTheFile(String attachmentId, Id parentId, String fileName, String base64Data, String contentType, String description)
                //deleteAddress
               // getCustomerAddressDetailsTemp
               // getPicklistOptions
                
                
                Test.stopTest();
                 
             }
            
            
            }

}
}