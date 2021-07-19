global class AGN_DCRAccount_Clone
{        

   
    webservice static String cloneAct(Id recId) 
    //public String cloneAct()
    {
        // -- Firstly, set up
        Map<Id, Id> mapOld_NewDCR = new Map<Id, Id>();
        DCR_Account_AGN__c nr = new DCR_Account_AGN__c();
        List<Id> oldDCR_IdList = new List<Id>();
        oldDCR_IdList.add(recId);
        String result = 'notCloned';
        
        //String recId = ApexPages.currentPage().getParameters().get('id');
        SavePoint sp = Database.setSavePoint();
        try {
        DCR_Account_AGN__c er = [SELECT Account_Group_AGN__c,Account_Name_AGN__c,Account_Status_AGN__c,Account_Type_AGN__c,Additional_Specialties_AGN__c,
                            Address_Whanin_AGN__c,Affiliation_Record_Count_AGN__c,Allergan_Account_Group_AGN__c,Avocis_date_AGN__c,Avocis_placed_AGN__c,
                            Beds_AGN__c,Calling_Name_AGN__c,Consent_to_Contact_AGN__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,
                            Consent_to_Phone_AGN__c,Country_AGN__c,Country_Code_AGN__c,Customer_Consent_AGN__c,
                            Default_Order_Type_AGN__c,Departments_AGN__c,Description_AGN__c,Distribution_ID_AGN__c,Do_not_Phone_Call_AGN__c,
                            Do_not_send_Fax_AGN__c,Do_not_send_Mail_AGN__c,Do_not_Visit_AGN__c,Education_Speciality_AGN__c,Email_Internal_AGN__c,External_ID2_AGN__c,
                            External_ID4_AGN__c,External_ID_AGN__c,Fax_AGN__c,Fax_Internal_AGN__c,FirstName_AGN__c,Gender_AGN__c,Graduation_School_AGN__c,Graduation_Year_AGN__c,
                            Influential_profile_AGN__c,Institution_Site_AGN__c,IS_Rank_AGN__c,
                            IS_Type_AGN__c,KOL_AGN__c,Language_AGN__c,LastName_AGN__c,MiddleName_AGN__c,
                            No_Orders_AGN__c,NS_Headache_Target_Centre_AGN__c,Order_Type_AGN__c,Organization_Registration_Reference_AGN__c,
                            Other_Name_AGN__c,Other_title_information_AGN__c,Parent_Account_AGN__c,Parent_DCR_AGN__c,Partner_Email_AGN__c,
                            Partner_Emp_Code_AGN__c,Partner_Rep_Name_AGN__c,Partner_Team_Name_AGN__c,Patients_AGN__c,PersonBirthdate_AGN__c,PersonEmail_AGN__c,PersonMobilePhone_AGN__c,
                            Phone_AGN__c,Phone_Internal_AGN__c,Physician_Registration_Reference_AGN__c,Position_at_Primary_Institution_AGN__c,Primary_Address_AGN__c,
                            Primary_Address_Count_AGN__c,Primary_Parent_AGN__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Prompt_for_Revision_AGN__c,RecordTypeId,
                            Sales_Credit_Limit_AGN__c,Salutation_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Specialty_Allergan_1_AGN__c,Sub_Specialty_Allergan_AGN__c,
                            Target_Account_AGN__c,Target_AGN__c,Target_Whanin_AGN__c,Type_AGN__c,Website_AGN__c,Workplace_AGN__c 
                            FROM DCR_Account_AGN__c Where Id = : recId];
                            
                            
                            
          nr = er.clone();
          
          nr.Request_Status_AGN__c = 'Processing';
          nr.Cloned_Parent_AGN__c = recId;
          
          insert nr;   //cloned parent DCR created  
          result = nr.Id;
          mapOld_NewDCR.put(recId, nr.Id); //Map<OldId, NewId>
          
          //Creation of Child DCRs affiliated to the parent DCR
          List<DCR_Account_AGN__c> DCR_ChildList = new List<DCR_Account_AGN__c>();
          List<DCR_Account_AGN__c> newDCR_ChildList = new List<DCR_Account_AGN__c>();
          
          DCR_ChildList = [SELECT Account_Group_AGN__c,Account_Name_AGN__c,Account_Status_AGN__c,Account_Type_AGN__c,Additional_Specialties_AGN__c,
                            Address_Whanin_AGN__c,Affiliation_Record_Count_AGN__c,Allergan_Account_Group_AGN__c,Avocis_date_AGN__c,Avocis_placed_AGN__c,
                            Beds_AGN__c,Calling_Name_AGN__c,Consent_to_Contact_AGN__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,
                            Consent_to_Phone_AGN__c,Country_AGN__c,Country_Code_AGN__c,Customer_Consent_AGN__c,
                            Default_Order_Type_AGN__c,Departments_AGN__c,Description_AGN__c,Distribution_ID_AGN__c,Do_not_Phone_Call_AGN__c,
                            Do_not_send_Fax_AGN__c,Do_not_send_Mail_AGN__c,Do_not_Visit_AGN__c,Education_Speciality_AGN__c,Email_Internal_AGN__c,External_ID2_AGN__c,
                            External_ID4_AGN__c,External_ID_AGN__c,Fax_AGN__c,Fax_Internal_AGN__c,FirstName_AGN__c,Gender_AGN__c,Graduation_School_AGN__c,Graduation_Year_AGN__c,
                            Influential_profile_AGN__c,Institution_Site_AGN__c,IS_Rank_AGN__c,
                            IS_Type_AGN__c,KOL_AGN__c,Language_AGN__c,LastName_AGN__c,MiddleName_AGN__c,
                            No_Orders_AGN__c,NS_Headache_Target_Centre_AGN__c,Order_Type_AGN__c,Organization_Registration_Reference_AGN__c,
                            Other_Name_AGN__c,Other_title_information_AGN__c,Parent_Account_AGN__c,Partner_Email_AGN__c,
                            Partner_Emp_Code_AGN__c,Partner_Rep_Name_AGN__c,Partner_Team_Name_AGN__c,Patients_AGN__c,PersonBirthdate_AGN__c,PersonEmail_AGN__c,PersonMobilePhone_AGN__c,
                            Phone_AGN__c,Phone_Internal_AGN__c,Physician_Registration_Reference_AGN__c,Position_at_Primary_Institution_AGN__c,Primary_Address_AGN__c,
                            Primary_Address_Count_AGN__c,Primary_Parent_AGN__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Prompt_for_Revision_AGN__c,RecordTypeId,
                            Sales_Credit_Limit_AGN__c,Salutation_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Specialty_Allergan_1_AGN__c,Sub_Specialty_Allergan_AGN__c,
                            Target_Account_AGN__c,Target_AGN__c,Target_Whanin_AGN__c,Type_AGN__c,Website_AGN__c,Workplace_AGN__c 
                            FROM DCR_Account_AGN__c Where Parent_DCR_AGN__c = : recId];
                            
           if(DCR_ChildList.size()!= 0)
           {
               
               DCR_Account_AGN__c ncr;
               
               for (DCR_Account_AGN__c ecr : DCR_ChildList)
               {
                   ncr = ecr.clone();
                   ncr.Request_Status_AGN__c = 'Processing';
                   ncr.Parent_DCR_AGN__c = nr.Id;
                   ncr.Cloned_Parent_AGN__c = ecr.Id;
                   
                   newDCR_ChildList.add(ncr);
                   oldDCR_IdList.add(ecr.Id);
               }
          
               insert newDCR_ChildList; //child DCRs created if any 
               //system.debug('New set of child DCRs...'+newDCR_ChildList.size());
           }
          
          //Entire list of DCRs created
          List<DCR_Account_AGN__c> newDCR_List = new List<DCR_Account_AGN__c>();
          newDCR_List.add(nr);
          newDCR_List.addall(newDCR_ChildList);
          
           for (DCR_Account_AGN__c loopDCR : newDCR_List)
          {
              mapOld_NewDCR.put(loopDCR.Cloned_Parent_AGN__c, loopDCR.Id); 
          }
          
          
          /////////////////Creation of DCR address records//////////////////
          List<DCR_Address_AGN__c> oldDCR_Address = new List<DCR_Address_AGN__c>();
          List<DCR_Address_AGN__c> newDCR_Address = new List<DCR_Address_AGN__c>();         
                         
          oldDCR_Address = [SELECT Address_Line_1_AGN__c,Address_Line_2_AGN__c,Address_Line_3_AGN__c,Address_Type_AGN__c,Appt_Required_AGN__c,
                       Billing_AGN__c,Brick_AGN__c,Business_AGN__c, City_AGN__c,Country_AGN__c, Fax_AGN__c,Home_AGN__c, Inactive_AGN__c, 
                       Is_Changed_AGN__c, Mailing_AGN__c, Parent_DCR_AGN__c,Phone_2_AGN__c,Phone_AGN__c,Primary_AGN__c,Receptionist_Email_AGN__c,
                       Receptionist_Name_AGN__c,Shipping_AGN__c,State_AGN__c, Target_Address_AGN__c,Tgt_Account_AGN__c,Zip_AGN__c 
                       FROM DCR_Address_AGN__c where Parent_DCR_AGN__c in :oldDCR_IdList];
                       
          DCR_Address_AGN__c naddr; 
          if (oldDCR_Address.size()!= 0)
           {
               for (DCR_Address_AGN__c dcrAddr : oldDCR_Address)
               {
                   naddr = dcrAddr.clone();
                   naddr.Parent_DCR_AGN__c = mapOld_NewDCR.get(naddr.Parent_DCR_AGN__c);
                   
                   newDCR_Address.add(naddr);
               }
               
               insert newDCR_Address;    
           }
           
           
          /////////////////Creation of DCR Key Indicator records///////////////////
          List<DCR_Key_Indicator_AGN__c> oldDCR_KeyInd = new List<DCR_Key_Indicator_AGN__c>();
          List<DCR_Key_Indicator_AGN__c> newDCR_KeyInd = new List<DCR_Key_Indicator_AGN__c>();         
                         
          oldDCR_KeyInd = [SELECT Account_Support_AGN__c,Adoption_AGN__c,Adoption_IMS_AGN__c,Adoption_Level_AGN__c,Advocacy_Profile_AGN__c,
                  Allergan_Potential_AGN__c,Awareness_AGN__c, Continuum_Placement_AGN__c, Customer_Segment_AGN__c,Delete_Record_AGN__c,
                  Engagements_AGN__c,Fase_AGN__c,Fixed_Consignment_AGN__c,Growth_Potential_AGN__c, Investigator_AGN__c,Investigator_Readiness_AGN__c,
                  Is_Changed_AGN__c,Key_Account_AGN__c, Ophthalmology_Profile_AGN__c,Parent_DCR_AGN__c,Potential_AGN__c,Potential_IMS_AGN__c,
                  Product_AGN__c,Product_Group_AGN__c,Product_Status_AGN__c,Profiling_AGN__c,Ratings_AGN__c,Retina_Profile_AGN__c,Sales_Target_AGN__c,
                  Sector_AGN__c,Segment1_AGN__c,Segment_AGN__c,Segment_IMS_AGN__c, Target_AGN__c,Target_Key_Indicator_AGN__c,Tgt_Account_AGN__c 
                  FROM DCR_Key_Indicator_AGN__c WHERE Parent_DCR_AGN__c in :oldDCR_IdList];
                       
          DCR_Key_Indicator_AGN__c nkeyIn; 
          if (oldDCR_KeyInd.size()!= 0)
           {
               for (DCR_Key_Indicator_AGN__c dcrnkeyIn : oldDCR_KeyInd)
               {
                   nkeyIn = dcrnkeyIn.clone();
                   nkeyIn.Parent_DCR_AGN__c = mapOld_NewDCR.get(nkeyIn.Parent_DCR_AGN__c);
                   
                   newDCR_KeyInd.add(nkeyIn);
               }
               
               insert newDCR_KeyInd;    
           }
           
           
          ////////////////////////Creating DCR to Account affiliations///////////////////////
          Map<Id,RecordType> mapAffRecordTp = new Map<Id,RecordType>([SELECT Id, Name FROM RecordType WHERE SobjectType = 'DCR_Affiliation_AGN__c']);
          List<DCR_Affiliation_AGN__c> oldDCR_Aff = new List<DCR_Affiliation_AGN__c>();
          List<DCR_Affiliation_AGN__c> newDCR_Aff = new List<DCR_Affiliation_AGN__c>();
                   
          Map<Id,DCR_Affiliation_AGN__c> mapdcrAff = new Map<Id,DCR_Affiliation_AGN__c>(); //Map from Old Aff Id to new aff record for Account to DCR aff
          
          
          
          oldDCR_Aff = [SELECT Affiliated_Account_AGN__c, Affiliated_DCR_Account_AGN__c, Delete_Record_AGN__c, Is_Changed_AGN__c, 
                  OK_Role_AGN__c,Parent_DCR_AGN__c, Primary_AGN__c,RecordTypeId,Relation_AGN__c,Relation_Type_AGN__c, Target_Affiliation_AGN__c,
                  Tgt_Account_AGN__c, Work_Status_AGN__c FROM DCR_Affiliation_AGN__c 
                  WHERE Parent_DCR_AGN__c in :oldDCR_IdList];
                  
          if (oldDCR_Aff.size()!= 0)
           {
               for (DCR_Affiliation_AGN__c dcrAff : oldDCR_Aff)
               {
                   DCR_Affiliation_AGN__c nAff = new DCR_Affiliation_AGN__c();
                   if (mapAffRecordTp.get(dcrAff.RecordTypeId).Name.contains('Account')) //Account to Account Affiliation
                   {
                       nAff= dcrAff.clone();
                       nAff.Parent_DCR_AGN__c = mapOld_NewDCR.get(dcrAff.Parent_DCR_AGN__c);
                       nAff.Unique_Account_Key_AGN__c = nAff.Parent_DCR_AGN__c+'.'+dcrAff.Affiliated_Account_AGN__c;
                       newDCR_Aff.add(nAff);
                   }
                  
                  else {                                //DCR to Account Affiliation
 
                       nAff= dcrAff.clone();
                       nAff.Parent_DCR_AGN__c = mapOld_NewDCR.get(nAff.Parent_DCR_AGN__c);
                       nAff.Affiliated_DCR_Account_AGN__c = mapOld_NewDCR.get(dcrAff.Affiliated_DCR_Account_AGN__c);
                       newDCR_Aff.add(nAff);
                       
                   }           
                   
               }
               
               insert newDCR_Aff;  
               
           }
          }
          catch(Exception e) {
              Database.rollback(sp);
              result = 'notCloned';
              //nr.addError('Error occurred. Please contact your administrator.');
          }
                    
          //return new PageReference('/'+nr.Id); 
          //String url = System.URL.getSalesforceBaseUrl().toExternalForm();
          //url = url+'/'+nr.Id;
          
          //return nr.Id;
          return result;
        }
                
 }