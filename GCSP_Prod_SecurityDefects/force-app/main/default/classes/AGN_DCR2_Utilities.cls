// AGN_DCR2_Utilities //

public without sharing class AGN_DCR2_Utilities {


// ======== FIELD VALUE COPY : DCR & ACCOUNT ======== //

    public static void CopyAccountDetail(Account acc,DCR_Account_AGN__c dcr,boolean toDcr,boolean ifPersonAccount) {
        
        User usr =  [SELECT Country_Code__c,MA_User_Country_Code_AGN__c,Division,Profile.Name,ManagerId,
                        MA_Medical_Affairs_AGN__c,Cluster_user_AGN__c
                        FROM User WHERE Id = :UserInfo.getUserId()];
                    system.debug('== [Query:usr] =='+usr);
                    String userCountry='';
        if(usr.Cluster_user_AGN__c==true || usr.MA_User_Country_Code_AGN__c=='Yes')
            userCountry=usr.MA_User_Country_Code_AGN__c;
        else
            userCountry=usr.Country_Code__c;
        
        if(toDcr) {
            system.debug('== [AGN_DCR2_Utilities].[CopyAccountDetail to DCR].Account =='+ acc);
            dcr.Target_Account_AGN__c = acc.id;
            dcr.Primary_Parent_AGN__c = acc.Primary_Parent_vod__c;
            dcr.Parent_Account_AGN__c = acc.ParentId;
            dcr.Salutation_AGN__c = acc.Salutation;
            dcr.FirstName_AGN__c = acc.FirstName;
            dcr.MiddleName_AGN__c = acc.Middle_vod__c;
            dcr.LastName_AGN__c = acc.LastName;
            dcr.Account_Name_AGN__c = acc.Name;
            dcr.Avocis_placed_AGN__c = acc.Avocis_placed_AGN__c;
            dcr.Consent_to_Contact_AGN__c = acc.Consent_to_Contact_AGN__c;
            dcr.Consent_to_Email_AGN__c = acc.Consent_to_Email_AGN__c;
            dcr.Consent_to_Mail_AGN__c = acc.Consent_to_Mail_AGN__c;
            dcr.Country_AGN__c = acc.Country_vod__c;
            //dcr.Country_Code_AGN__c = acc.Country_Code__c;
            dcr.Do_not_Phone_Call_AGN__c = acc.Do_not_Phone_Call_AGN__c;
            dcr.Do_not_send_Fax_AGN__c = acc.Do_not_send_Fax_AGN__c;
            dcr.Do_not_send_Mail_AGN__c = acc.Do_not_send_Mail__c;
            dcr.Do_not_Visit_AGN__c = acc.Do_not_Visit_AGN__c;
            dcr.KOL_AGN__c = acc.KOL_vod__c;
            dcr.NS_Headache_Target_Centre_AGN__c = acc.NS_Headache_Target_Centre_AGN__c;
            dcr.Privacy_AGN__c = acc.Privacy_AGN__c;
            dcr.Privacy_law_status_AGN__c = acc.Privacy_law_status_AGN__c;
            dcr.Target_AGN__c = acc.Target__c;
            dcr.Sales_Credit_Limit_AGN__c = acc.Sales_Credit_Limit_AGN__c;
            dcr.Avocis_date_AGN__c = acc.Avocis_date_AGN__c;
            dcr.PersonBirthdate_AGN__c = acc.PersonBirthdate;
            dcr.PersonEmail_AGN__c = acc.PersonEmail;
            dcr.Email_Internal_AGN__c = acc.Email_Internal_AGN__c;
            dcr.Partner_Email_AGN__c = acc.Partner_Email_AGN__c;
            dcr.Description_AGN__c = acc.Description;
            dcr.Specialty_Allergan_1_AGN__c = acc.Specialty_Allergan_1_AGN__c;
            dcr.Specialty_1_AGN__c = acc.Specialty_1_AGN__c;
            dcr.Specialty_2_AGN__c = acc.Specialty_2_AGN__c;
            dcr.Sub_Specialty_Allergan_AGN__c = acc.Sub_Specialty_Allergan_AGN__c;
            dcr.Departments_AGN__c = acc.Departments__c;
            dcr.Patients_AGN__c = acc.Patients_AGN__c;
            dcr.Beds_AGN__c = acc.Beds__c;
            dcr.Fax_AGN__c = acc.Fax;
            dcr.Fax_Internal_AGN__c = acc.Fax_Internal_AGN__c;
            dcr.PersonMobilePhone_AGN__c = acc.PersonMobilePhone;
            dcr.Phone_AGN__c = acc.Phone;
            dcr.Phone_Internal_AGN__c = acc.Phone_Internal_AGN__c;
            dcr.Account_Status_AGN__c = acc.Status_AGN__c;
            if(userCountry=='CN')               
                dcr.Account_Sub_Type_China_AGN__c = acc.Type_AGN__c;
            else
                dcr.Type_AGN__c = acc.Type_AGN__c;
            dcr.Customer_Consent_AGN__c = acc.Customer_Consent_AGN__c;
            dcr.Default_Order_Type_AGN__c = acc.Default_Order_Type_vod__c;
            dcr.Gender_AGN__c = acc.Gender_vod__c;
            dcr.IS_Rank_AGN__c = acc.IS_Rank_AGN__c;
            dcr.IS_Type_AGN__c = acc.IS_Type_AGN__c;
            dcr.Language_AGN__c = acc.Language_vod__c;
            dcr.No_Orders_AGN__c = acc.No_Orders_vod__c;
            dcr.Position_at_Primary_Institution_AGN__c = acc.Position_at_Primary_Institution_AGN__c;
            dcr.Workplace_AGN__c = acc.Workplace_AGN__c;
            dcr.Influential_profile_AGN__c = acc.Influential_profile_AGN__c;
            dcr.Order_Type_AGN__c = acc.Order_Type_vod__c;
            dcr.Calling_Name_AGN__c = acc.Calling_Name_AGN__c;
            dcr.Education_Speciality_AGN__c = acc.Education_Speciality_AGN__c;
            dcr.External_ID_AGN__c = acc.External_ID_vod__c;
            dcr.Graduation_School_AGN__c = acc.Graduation_School_AGN__c;
            dcr.Institution_Site_AGN__c = acc.Institution_Site_AGN__c;
            dcr.Other_Name_AGN__c = acc.Other_Name_AGN__c;
            dcr.Address_Whanin_AGN__c = acc.Address_AGN__c;
            dcr.Partner_Emp_Code_AGN__c = acc.Partner_Emp_Code_AGN__c;
            dcr.Partner_Rep_Name_AGN__c = acc.Partner_Rep_Name_AGN__c;
            dcr.Partner_Team_Name_AGN__c = acc.Partner_Team_Name_AGN__c;
            dcr.Target_Whanin_AGN__c = acc.Target_AGN__c;
            dcr.Graduation_Year_AGN__c = acc.Graduation_Year_AGN__c;
            dcr.Organization_Registration_Reference_AGN__c = acc.Organization_Registration_Reference_AGN__c;
            dcr.Physician_Registration_Reference_AGN__c = acc.Physician_Registration_Reference_AGN__c;
            dcr.Other_title_information_AGN__c = acc.Other_title_information_AGN__c;
            dcr.Account_Group_AGN__c = acc.Account_Group_vod__c;
            dcr.Allergan_Account_Group_AGN__c = acc.Account_Group_AGN__c;
            dcr.Distribution_ID_AGN__c = acc.Distribution_ID_AGN__c;
            dcr.Website_AGN__c = acc.Website;
            dcr.Consent_to_Phone_AGN__c = acc.Consent_to_Phone_AGN__c;
            dcr.External_ID2_AGN__c = acc.External_ID2_AGN__c;
            dcr.External_ID4_AGN__c = acc.External_ID4_AGN__c;
            dcr.Additional_Specialties_AGN__c = acc.Additional_Specialties_AGN__c;
        } else {
            system.debug('== [AGN_DCR2_Utilities].[CopyAccountDetail from DCR].DCR_Account_AGN__c =='+ dcr);
            //acc.id = dcr.Target_Account_AGN__c;
            //acc.Primary_Parent_vod__c = dcr.Primary_Parent_AGN__c;
            acc.ParentId = dcr.Parent_Account_AGN__c;
            if(ifPersonAccount) {
                acc.Salutation = dcr.Salutation_AGN__c;
                acc.FirstName = dcr.FirstName_AGN__c;
                acc.Middle_vod__c = dcr.MiddleName_AGN__c;
                acc.LastName = dcr.LastName_AGN__c;
            } else {
                acc.Name = dcr.Account_Name_AGN__c;
            }
            acc.Avocis_placed_AGN__c = dcr.Avocis_placed_AGN__c;
            acc.Consent_to_Contact_AGN__c = dcr.Consent_to_Contact_AGN__c;
            acc.Consent_to_Email_AGN__c = dcr.Consent_to_Email_AGN__c;
            acc.Consent_to_Mail_AGN__c = dcr.Consent_to_Mail_AGN__c;
            acc.Country_vod__c = dcr.Country_AGN__c;
            acc.Country_Code__c = getCountryCode(dcr.Country_AGN__c);
            acc.Do_not_Phone_Call_AGN__c = dcr.Do_not_Phone_Call_AGN__c;
            acc.Do_not_send_Fax_AGN__c = dcr.Do_not_send_Fax_AGN__c;
            acc.Do_not_send_Mail__c = dcr.Do_not_send_Mail_AGN__c;
            acc.Do_not_Visit_AGN__c = dcr.Do_not_Visit_AGN__c;
            acc.KOL_vod__c = dcr.KOL_AGN__c;
            acc.NS_Headache_Target_Centre_AGN__c = dcr.NS_Headache_Target_Centre_AGN__c;
            acc.Privacy_AGN__c = dcr.Privacy_AGN__c;
            acc.Privacy_law_status_AGN__c = dcr.Privacy_law_status_AGN__c;
            acc.Target__c = dcr.Target_AGN__c;
            acc.Sales_Credit_Limit_AGN__c = dcr.Sales_Credit_Limit_AGN__c;
            acc.Avocis_date_AGN__c = dcr.Avocis_date_AGN__c;
            acc.PersonBirthdate = dcr.PersonBirthdate_AGN__c;
            acc.PersonEmail = dcr.PersonEmail_AGN__c;
            acc.Email_Internal_AGN__c = dcr.Email_Internal_AGN__c;
            acc.Partner_Email_AGN__c = dcr.Partner_Email_AGN__c;
            acc.Description = dcr.Description_AGN__c;
            acc.Specialty_Allergan_1_AGN__c = dcr.Specialty_Allergan_1_AGN__c;
            acc.Specialty_1_AGN__c = dcr.Specialty_1_AGN__c;
            acc.Specialty_2_AGN__c = dcr.Specialty_2_AGN__c;
            acc.Sub_Specialty_Allergan_AGN__c = dcr.Sub_Specialty_Allergan_AGN__c;
            acc.Departments__c = dcr.Departments_AGN__c;
            acc.Patients_AGN__c = dcr.Patients_AGN__c;
            acc.Beds__c = dcr.Beds_AGN__c;
            acc.Fax = dcr.Fax_AGN__c;
            acc.Fax_Internal_AGN__c = dcr.Fax_Internal_AGN__c;
            acc.PersonMobilePhone = dcr.PersonMobilePhone_AGN__c;
            acc.Phone = dcr.Phone_AGN__c;
            acc.Phone_Internal_AGN__c = dcr.Phone_Internal_AGN__c;
            acc.Status_AGN__c = dcr.Account_Status_AGN__c;
            if(userCountry=='CN')
                acc.Type_AGN__c = dcr.Account_Sub_Type_China_AGN__c;
            else
                acc.Type_AGN__c = dcr.Type_AGN__c;          
            acc.Customer_Consent_AGN__c = dcr.Customer_Consent_AGN__c;
            acc.Default_Order_Type_vod__c = dcr.Default_Order_Type_AGN__c;
            acc.Gender_vod__c = dcr.Gender_AGN__c;
            acc.IS_Rank_AGN__c = dcr.IS_Rank_AGN__c;
            acc.IS_Type_AGN__c = dcr.IS_Type_AGN__c;
            acc.Language_vod__c = dcr.Language_AGN__c;
            acc.No_Orders_vod__c = dcr.No_Orders_AGN__c;
            acc.Position_at_Primary_Institution_AGN__c = dcr.Position_at_Primary_Institution_AGN__c;
            acc.Workplace_AGN__c = dcr.Workplace_AGN__c;
            acc.Influential_profile_AGN__c = dcr.Influential_profile_AGN__c;
            acc.Order_Type_vod__c = dcr.Order_Type_AGN__c;
            acc.Calling_Name_AGN__c = dcr.Calling_Name_AGN__c;
            acc.Education_Speciality_AGN__c = dcr.Education_Speciality_AGN__c;
            acc.External_ID_vod__c = dcr.External_ID_AGN__c;
            acc.Graduation_School_AGN__c = dcr.Graduation_School_AGN__c;
            acc.Institution_Site_AGN__c = dcr.Institution_Site_AGN__c;
            acc.Other_Name_AGN__c = dcr.Other_Name_AGN__c;
            acc.Address_AGN__c = dcr.Address_Whanin_AGN__c;
            acc.Partner_Emp_Code_AGN__c = dcr.Partner_Emp_Code_AGN__c;
            acc.Partner_Rep_Name_AGN__c = dcr.Partner_Rep_Name_AGN__c;
            acc.Partner_Team_Name_AGN__c = dcr.Partner_Team_Name_AGN__c;
            acc.Target_AGN__c = dcr.Target_Whanin_AGN__c;
            acc.Graduation_Year_AGN__c = dcr.Graduation_Year_AGN__c;
            acc.Organization_Registration_Reference_AGN__c = dcr.Organization_Registration_Reference_AGN__c;
            acc.Physician_Registration_Reference_AGN__c = dcr.Physician_Registration_Reference_AGN__c;
            acc.Other_title_information_AGN__c = dcr.Other_title_information_AGN__c;
            acc.Account_Group_vod__c = dcr.Account_Group_AGN__c;
            acc.Account_Group_AGN__c = dcr.Allergan_Account_Group_AGN__c;
            acc.Distribution_ID_AGN__c = dcr.Distribution_ID_AGN__c;
            acc.Website = dcr.Website_AGN__c;
            acc.Consent_to_Phone_AGN__c = dcr.Consent_to_Phone_AGN__c;
            acc.External_ID2_AGN__c = dcr.External_ID2_AGN__c;
            acc.External_ID4_AGN__c = dcr.External_ID4_AGN__c;
            acc.Additional_Specialties_AGN__c = dcr.Additional_Specialties_AGN__c;
        }
    }

    static string getCountryCode(string countryCodeId) {
        Country_vod__c countryObj = [SELECT Alpha_2_Code_vod__c,Cluster_Country_AGN__c FROM Country_vod__c WHERE id=:countryCodeId];
                system.debug('== [Query:countryObj] =='+countryObj);
        if(string.isblank(countryObj.Cluster_Country_AGN__c))
            return countryObj.Alpha_2_Code_vod__c;
        else
            return countryObj.Cluster_Country_AGN__c;
    }

    // ================================================================ //
    
    public static void CopyAffiliationDetail(Child_Account_vod__c aAff,DCR_Affiliation_AGN__c dAff,boolean toDcr) {
        if(toDcr) {
            system.debug('== [AGN_DCR2_Utilities].[CopyAffiliationDetail to DCR].Child_Account_vod__c =='+ aAff);
            // dAff.Tgt_Account_AGN__c = aAff.Child_Account_vod__c;
            // dAff.Affiliated_Account_AGN__c = aAff.Parent_Account_vod__c;
            dAff.OK_Role_AGN__c = aAff.OK_Role__c;
            dAff.Work_Status_AGN__c = aAff.Work_Status_AGN__c;
        } else {
            system.debug('== [AGN_DCR2_Utilities].[CopyAffiliationDetail from DCR].DCR_Affiliation_AGN__c =='+ dAff);
            // aAff.Child_Account_vod__c = dAff.Tgt_Account_AGN__c;
            // aAff.Parent_Account_vod__c = dAff.Affiliated_Account_AGN__c;
            aAff.OK_Role__c = dAff.OK_Role_AGN__c;
            aAff.Work_Status_AGN__c = dAff.Work_Status_AGN__c;
        }
    }
    
    // ================================================================ //
    
    public static void CopyAddressDetail(Address_vod__c aAdd,DCR_Address_AGN__c dAdd,boolean toDcr) {
        if(toDcr) {
            system.debug('== [AGN_DCR2_Utilities].[CopyAddressDetail to DCR].Address_vod__c =='+ dAdd);
            dAdd.Tgt_Account_AGN__c = aAdd.Account_vod__c;
            dAdd.Address_Line_1_AGN__c = aAdd.Name;
            dAdd.Address_Line_2_AGN__c = aAdd.Address_line_2_vod__c;
            dAdd.Brick_AGN__c = aAdd.Brick_vod__c;
            dAdd.City_AGN__c = aAdd.City_vod__c;
            dAdd.Country_AGN__c = aAdd.Country_vod__c;
            dAdd.Phone_AGN__c = aAdd.Phone_vod__c;
            dAdd.Address_Line_3_AGN__c = aAdd.Address_line_3_AGN__c;
            dAdd.Address_Type_AGN__c = aAdd.address_type_vod__c;
            dAdd.Billing_AGN__c = aAdd.Billing_vod__c;
            dAdd.Business_AGN__c = aAdd.Business_vod__c;
            dAdd.Home_AGN__c = aAdd.Home_vod__c;
            dAdd.Mailing_AGN__c = aAdd.Mailing_vod__c;
            dAdd.Zip_AGN__c = aAdd.Zip_vod__c;
            dAdd.Shipping_AGN__c = aAdd.Shipping_vod__c;
            dAdd.Fax_AGN__c = aAdd.Fax_vod__c;
            dAdd.Appt_Required_AGN__c = aAdd.Appt_Required_vod__c;
            dAdd.Receptionist_Name_AGN__c = aAdd.Receptionist_Name_AGN__c;
            dAdd.Phone_2_AGN__c = aAdd.Phone_2_vod__c;
            dAdd.Receptionist_Email_AGN__c = aAdd.Receptionist_Email_AGN__c;
            dAdd.State_AGN__c = aAdd.State_vod__c;
            dAdd.Inactive_AGN__c = aAdd.Inactive_vod__c;
            dAdd.Primary_AGN__c = (aAdd.Primary_vod__c==true ? 'Yes' : '');
        } else {
            system.debug('== [AGN_DCR2_Utilities].[CopyAddressDetail from DCR].DCR_Address_AGN__c =='+ aAdd);
            //aAdd.Account_vod__c = dAdd.Tgt_Account_AGN__c;
            aAdd.Name = dAdd.Address_Line_1_AGN__c;
            aAdd.Address_line_2_vod__c = dAdd.Address_Line_2_AGN__c;
            aAdd.Brick_vod__c = dAdd.Brick_AGN__c;
            aAdd.City_vod__c = dAdd.City_AGN__c;
            aAdd.Country_vod__c = dAdd.Country_AGN__c;
            aAdd.Phone_vod__c = dAdd.Phone_AGN__c;
            aAdd.Address_line_3_AGN__c = dAdd.Address_Line_3_AGN__c;
            aAdd.address_type_vod__c = dAdd.Address_Type_AGN__c;
            aAdd.Billing_vod__c = dAdd.Billing_AGN__c;
            aAdd.Business_vod__c = dAdd.Business_AGN__c;
            aAdd.Home_vod__c = dAdd.Home_AGN__c;
            aAdd.Mailing_vod__c = dAdd.Mailing_AGN__c;
            aAdd.Zip_vod__c = dAdd.Zip_AGN__c;
            aAdd.Shipping_vod__c = dAdd.Shipping_AGN__c;
            aAdd.Fax_vod__c = dAdd.Fax_AGN__c;
            aAdd.Appt_Required_vod__c = dAdd.Appt_Required_AGN__c;
            aAdd.Receptionist_Name_AGN__c = dAdd.Receptionist_Name_AGN__c;
            aAdd.Phone_2_vod__c = dAdd.Phone_2_AGN__c;
            aAdd.Receptionist_Email_AGN__c = dAdd.Receptionist_Email_AGN__c;
            aAdd.State_vod__c = dAdd.State_AGN__c;
            aAdd.Inactive_vod__c = dAdd.Inactive_AGN__c;
            aAdd.Primary_vod__c = (dAdd.Primary_AGN__c=='Yes' ? true : false);
        }
    }

    // ================================================================ //
    
    public static void CopyKeyIndicatorDetail(Product_Metrics_vod__c aKey,DCR_Key_Indicator_AGN__c dKey,boolean toDcr) {
        if(toDcr) {
            system.debug('== [AGN_DCR2_Utilities].[CopyKeyIndicatorDetail to DCR].Product_Metrics_vod__c =='+ aKey);
            dKey.Tgt_Account_AGN__c = aKey.Account_vod__c;
            dKey.Product_AGN__c = aKey.Products_vod__c;
            dKey.Product_Group_AGN__c = aKey.Detail_Group_vod__c;
            dKey.Adoption_AGN__c = aKey.Adoption_AGN__c;
            dKey.Allergan_Potential_AGN__c = aKey.Allergan_Potential_AGN__c;
            dKey.Account_Support_AGN__c = aKey.Account_Support_AGN__c;
            dKey.Adoption_IMS_AGN__c = aKey.Adoption_IMS_AGN__c;
            dKey.Adoption_Level_AGN__c = aKey.Adoption_Level__c;
            dKey.Advocacy_Profile_AGN__c = aKey.Advocacy_Profile_AGN__c;
            dKey.Awareness_AGN__c = aKey.Awareness__c;
            dKey.Continuum_Placement_AGN__c = aKey.Continuum_Placement_AGN__c;
            dKey.Engagements_AGN__c = aKey.Engagements__c;
            dKey.Fase_AGN__c = aKey.Fase_AGN__c;
            dKey.Fixed_Consignment_AGN__c = aKey.Fixed_Consignment_AGN__c;
            dKey.Growth_Potential_AGN__c = aKey.Growth_Potential_AGN__c;
            dKey.Investigator_AGN__c = aKey.Investigator_smb__c;
            dKey.Investigator_Readiness_AGN__c = aKey.Investigator_Readiness__c;
            dKey.Key_Account_AGN__c = aKey.Key_Account_AGN__c;
            dKey.Ophthalmology_Profile_AGN__c = aKey.Ophthalmology_Profile_AGN__c;
            dKey.Potential_IMS_AGN__c = aKey.Potential_IMS_AGN__c;
            dKey.Product_Status_AGN__c = aKey.Product_Status_AGN__c;
            dKey.Profiling_AGN__c = aKey.Profiling_AGN__c;
            dKey.Ratings_AGN__c = aKey.Ratings_AGN__c;
            dKey.Retina_Profile_AGN__c = aKey.Retina_Profile_AGN__c;
            dKey.Sales_Target_AGN__c = aKey.Sales_Target_AGN__c;
            dKey.Sector_AGN__c = aKey.Sector_AGN__c;
            dKey.Customer_Segment_AGN__c = aKey.Customer_Segment_AGN__c;
            dKey.Segment1_AGN__c = aKey.Segment__c;
            dKey.Segment_AGN__c = aKey.Segment_AGN__c;
            dKey.Segment_IMS_AGN__c = aKey.Segment_IMS_AGN__c;
            dKey.Target_AGN__c = aKey.Target_AGN__c;
        } else {
            system.debug('== [AGN_DCR2_Utilities].[CopyKeyIndicatorDetail from DCR].DCR_Key_Indicator_AGN__c =='+ dKey);
            //aKey.Account_vod__c = dKey.Tgt_Account_AGN__c;
            aKey.Products_vod__c = dKey.Product_AGN__c;
            aKey.Detail_Group_vod__c = dKey.Product_Group_AGN__c;
            aKey.Adoption_AGN__c = dKey.Adoption_AGN__c;
            aKey.Allergan_Potential_AGN__c = dKey.Allergan_Potential_AGN__c;
            aKey.Account_Support_AGN__c = dKey.Account_Support_AGN__c;
            aKey.Adoption_IMS_AGN__c = dKey.Adoption_IMS_AGN__c;
            aKey.Adoption_Level__c = dKey.Adoption_Level_AGN__c;
            aKey.Advocacy_Profile_AGN__c = dKey.Advocacy_Profile_AGN__c;
            aKey.Awareness__c = dKey.Awareness_AGN__c;
            aKey.Continuum_Placement_AGN__c = dKey.Continuum_Placement_AGN__c;
            aKey.Engagements__c = dKey.Engagements_AGN__c;
            aKey.Fase_AGN__c = dKey.Fase_AGN__c;
            aKey.Fixed_Consignment_AGN__c = dKey.Fixed_Consignment_AGN__c;
            aKey.Growth_Potential_AGN__c = dKey.Growth_Potential_AGN__c;
            aKey.Investigator_smb__c = dKey.Investigator_AGN__c;
            aKey.Investigator_Readiness__c = dKey.Investigator_Readiness_AGN__c;
            aKey.Key_Account_AGN__c = dKey.Key_Account_AGN__c;
            aKey.Ophthalmology_Profile_AGN__c = dKey.Ophthalmology_Profile_AGN__c;
            aKey.Potential_IMS_AGN__c = dKey.Potential_IMS_AGN__c;
            aKey.Product_Status_AGN__c = dKey.Product_Status_AGN__c;
            aKey.Profiling_AGN__c = dKey.Profiling_AGN__c;
            aKey.Ratings_AGN__c = dKey.Ratings_AGN__c;
            aKey.Retina_Profile_AGN__c = dKey.Retina_Profile_AGN__c;
            aKey.Sales_Target_AGN__c = dKey.Sales_Target_AGN__c;
            aKey.Sector_AGN__c = dKey.Sector_AGN__c;
            aKey.Customer_Segment_AGN__c = dKey.Customer_Segment_AGN__c;
            aKey.Segment__c = dKey.Segment1_AGN__c;
            aKey.Segment_AGN__c = dKey.Segment_AGN__c;
            aKey.Segment_IMS_AGN__c = dKey.Segment_IMS_AGN__c;
            aKey.Target_AGN__c = dKey.Target_AGN__c;
        }
    }
    
// -------- FIELD VALUE COPY : DCR & ACCOUNT -------- //



// ======== DCR KEY INDICATOR ======== //

    public static List<DCR_Key_Indicator_AGN__c> Create_DCR_Key_Indicators(DCR_Account_AGN__c dcr) {
        system.debug('== [AGN_DCR2_Utilities].[Create_DCR_Key_Indicators].dcr =='+dcr);

        List<DCR_Key_Indicator_AGN__c> dcrNewKeyIndcatrList = new List<DCR_Key_Indicator_AGN__c>();
        List <string> myProductList = new List <string>();
        List <string> myProductGroupList = new List <string>();
        
        List <My_Setup_Products_vod__c> myAllProducts = 
                    [SELECT Product_vod__c,Product_vod__r.Product_Type_vod__c 
                        FROM My_Setup_Products_vod__c WHERE OwnerId = :UserInfo.getUserId()];
                    system.debug('== [Query:myAllProducts] =='+myAllProducts);
        
        for(My_Setup_Products_vod__c mp : myAllProducts) {
            if(mp.Product_vod__r.Product_Type_vod__c == 'Detail')
                myProductList.add(mp.Product_vod__c);
            else if(mp.Product_vod__r.Product_Type_vod__c == 'Detail Group')
                myProductGroupList.add(mp.Product_vod__c);
        }

        // == Products with Product Grouping == //
        List <Product_Group_vod__c> productGroupings = 
                    [SELECT Product_vod__c,Product_Catalog_vod__c,Product_vod__r.Name,Product_Catalog_vod__r.Name 
                        FROM Product_Group_vod__c 
                        WHERE Product_Catalog_vod__c IN :myProductGroupList
                        AND Product_vod__c IN :myProductList];
                    system.debug('== [Query:productGroupings] =='+productGroupings);

        for(Product_Group_vod__c pgrp : productGroupings) {
            DCR_Key_Indicator_AGN__c dk = new DCR_Key_Indicator_AGN__c();
            dk.Product_AGN__c = pgrp.Product_vod__c;
            dk.Product_Group_AGN__c = pgrp.Product_Catalog_vod__c;
            dk.Parent_DCR_AGN__c = dcr.Id;
            dk.Tgt_Account_AGN__c = dcr.Target_Account_AGN__c;
            dcrNewKeyIndcatrList.add(dk);
        }

        // == Products without Product Grouping == //
        List <My_Setup_Products_vod__c> myProducts = [SELECT Product_vod__c FROM My_Setup_Products_vod__c 
                        WHERE Product_vod__r.Product_Type_vod__c = 'Detail' 
                        AND OwnerId = :UserInfo.getUserId()
                        AND Product_vod__c NOT IN 
                            (SELECT Product_vod__c FROM Product_Group_vod__c 
                            WHERE Product_Catalog_vod__c IN :myProductGroupList
                            AND Product_vod__c IN :myProductList)];
                    system.debug('== [Query:myProducts] =='+myProducts);

        for(My_Setup_Products_vod__c prd : myProducts) {
            DCR_Key_Indicator_AGN__c dk = new DCR_Key_Indicator_AGN__c();
            dk.Product_AGN__c = prd.Product_vod__c;
            //dk.Product_Group_AGN__c = prd.Product_Catalog_vod__c;
            dk.Parent_DCR_AGN__c = dcr.Id;
            dk.Tgt_Account_AGN__c = dcr.Target_Account_AGN__c;
            //dk.Is_Changed_AGN__c = false;    // == commented since field is already default 'false' at object level
            dcrNewKeyIndcatrList.add(dk);
        }

        system.debug('== [AGN_DCR2_Utilities].[Create_DCR_Key_Indicators].Returning:dcrNewKeyIndcatrList=='+dcrNewKeyIndcatrList);
        return dcrNewKeyIndcatrList;
    }
    
// -------- DCR KEY INDICATOR -------- //



// ======== FETCHING APPROPRIATE DCR CONFIG SETTING ======== //
    
    public static List<DCR_Configuration_Settings_AGN__c> FetchDCRConfigSettings(id userId) {
        system.debug('== [AGN_DCR2_Utilities].[FetchDCRConfigSettings].userId =='+userId);
        return FetchDCRConfigSettings(userId,'-');
    }
    
    // ================================================================ //
    
    public static List<DCR_Configuration_Settings_AGN__c> FetchDCRConfigSettings(id userId,string countryCode) {
        system.debug('== [AGN_DCR2_Utilities].[FetchDCRConfigSettings].userId =='+userId + ' ; countryCode =='+countryCode);
        
        User usr =  [SELECT Country_Code__c,MA_User_Country_Code_AGN__c,Division,Profile.Name,ManagerId,
                        MA_Medical_Affairs_AGN__c,Cluster_user_AGN__c
                        FROM User WHERE Id = :userId];
                    system.debug('== [Query:usr] =='+usr);
                        
        if(countryCode == '-')
            if(usr.Cluster_user_AGN__c==true || usr.MA_Medical_Affairs_AGN__c=='Yes')
                countryCode = usr.MA_User_Country_Code_AGN__c;
            else
                countryCode = usr.Country_Code__c;
        
        system.debug('== [AGN_DCR2_Utilities].[FetchDCRConfigSettings].countryCode =='+countryCode+' ; usr.Profile.Name =='+usr.Profile.Name+' ; usr.Division =='+usr.Division);
        List<DCR_Configuration_Settings_AGN__c> dcrConfigSetting = 
                    [SELECT DCR_Type_AGN__c,HCO_Create_Allowed_AGN__c,HCO_Update_Allowed_AGN__c,HCP_Create_Allowed_AGN__c,HCP_Update_Allowed_AGN__c,
                        Company_Managed_AGN__c,Data_Provider_Managed_AGN__c,MDM_Managed_AGN__c,Show_Product_Metrics_AGN__c,Territory_Alignment_After_Approval_AGN__c,
                        Manager_Approved_AGN__c,Local_Admin_Approved_AGN__c,Local_Approver_AGN__c, Provisional_Contact_Required_AGN__c, Secondary_Approver_AGN__c 
                        FROM DCR_Configuration_Settings_AGN__c 
                        WHERE Country_Code_AGN__c = :countryCode 
                        AND Profile_AGN__c = :usr.Profile.Name
                        AND Business_Unit_AGN__c = 'ZZ'];
                    system.debug('== [Query:dcrConfigSetting] =='+dcrConfigSetting);
        
        List<DCR_Configuration_Settings_AGN__c> dcrConfigSettingBU = 
                    [SELECT DCR_Type_AGN__c,HCO_Create_Allowed_AGN__c,HCO_Update_Allowed_AGN__c,HCP_Create_Allowed_AGN__c,HCP_Update_Allowed_AGN__c,
                        Company_Managed_AGN__c,Data_Provider_Managed_AGN__c,MDM_Managed_AGN__c,Show_Product_Metrics_AGN__c,Territory_Alignment_After_Approval_AGN__c,
                        Manager_Approved_AGN__c,Local_Admin_Approved_AGN__c,Local_Approver_AGN__c,Provisional_Contact_Required_AGN__c,Secondary_Approver_AGN__c 
                        FROM DCR_Configuration_Settings_AGN__c 
                        WHERE Country_Code_AGN__c = :countryCode 
                        AND Profile_AGN__c = :usr.Profile.Name
                        AND Business_Unit_AGN__c = :usr.Division];
                    system.debug('== [Query:dcrConfigSettingBU] =='+dcrConfigSettingBU);
        
    
        if(dcrConfigSettingBU.size() > 0) {
            dcrConfigSetting = dcrConfigSettingBU;
        } else if(dcrConfigSetting.size() > 0) {
            // == no action; use the dcrConfigSetting variable == //
        } else {
            return null;             // == No DCR setting found == //
        }
        
        if(dcrConfigSetting[0].Manager_Approved_AGN__c == true)
            dcrConfigSetting[0].Local_Approver_AGN__c = usr.ManagerId;
        system.debug('== [AGN_DCR2_Utilities].[FetchDCRConfigSettings].Returning:dcrConfigSetting=='+dcrConfigSetting);
        return(dcrConfigSetting);
    }

// -------- FETCHING APPROPRIATE DCR CONFIG SETTING -------- //

}

// AGN_DCR2_Utilities //