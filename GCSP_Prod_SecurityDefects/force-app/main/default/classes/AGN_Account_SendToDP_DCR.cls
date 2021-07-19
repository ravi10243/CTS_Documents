/* Created during Allergan Core Veeva Application Release R14
 * Requirement ID: PMO # 1797
 * Use: Used to send a Self Managed Account to Data Provider for validation and Data Provider ID
 * The method createDCR() is called from the Validate_with_DP_AGN button on Account page
*/


global class AGN_Account_SendToDP_DCR {
    
    webservice static String createDCR(String accId, String DCR_note){
        
        string dcrId;
        Account acc = [select Sent_to_DP_AGN__c,SAP_Customer_Group_AGN__c,Customer_Sub_Category_AGN__c,Customer_Category_AGN__c,QTD_amount_AGN__c,YTD_amount_AGN__c,PYTD_amount_AGN__c,PQTD_amount_AGN__c,PMTD_amount_AGN__c,Monthly_Sales_AGN__c,MTD_amount_AGN__c,Inventory_Monitoring_Type_vod__c,Default_Inventory_Monitoring_Type_vod__c,PDF_Accessible_Count_AGN__c,PersonLeadSource,AccountNumber,AccountSource,Account_Class_vod__c,Account_Group_AGN__c,Account_Group_vod__c,
                       Account_Identifier_vod__c,Account_Search_Business_vod__c,Account_Search_FirstLast_vod__c,
                       Account_Search_LastFirst_vod__c,Account_Strategy_AGN__c,Account_Type__c,ActivityLoc_Code_AGN__c,
                       Additional_Specialties_AGN__c,Additional_Status_AGN__c,Address_AGN__c,AGN_DCR_Ref__c,Agree_to_Participate__c,
                       AHA__c,Alternate_Name_vod__c,AnnualRevenue,Approved_Email_Opt_Type_vod__c,APP_Level_AGN__c,Areas_of_Interest__c,
                       Area_of_Expertise__c,Assignment_Country_AGN__c,ATL_Last_Update_Date_Time_vod__c,Avocis_date_AGN__c,
                       Avocis_placed_AGN__c,Beds__c,BillingAddress,BillingCity,BillingCountry,BillingGeocodeAccuracy,BillingLatitude,
                       BillingLongitude,BillingPostalCode,BillingState,BillingStreet,Business_Consultant_AGN__c,Business_Description__c,
                       Business_Professional_Person_vod__c,Calling_Name_AGN__c,Call_Reminder_vod__c,Career_Status_vod__c,
                       CA_APP_Level_AGN__c,CLM_Opt_Type_vod__c,Color_vod__c,Commercial_Patient_Days_1000__c,Commercial_Premiums_PMPM__c,
                       Condition_treatment__c,Consent_Disclosure_HCO_Payments_AGN__c,Consent_Disclosure_HCP_Payments_AGN__c,
                       Consent_to_Contact_AGN__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,Consent_to_Phone_AGN__c,
                       Contracts_Process__c,Corporate_Account_AGN__c,Country_Code__c,Country_vod__c,CreatedById,CreatedDate,
                       Credentials_vod__c,CurrencyIsoCode,Customer_Consent_AGN__c,Customer_Managed_AGN__c,
                       Customer_Master_Status_vod__c,Customer_Registration_AGN__c,Date_added_to_IS_AGN__c,
                       Default_Order_Type_vod__c,Departments__c,Description,Distribution_ID_AGN__c,DL_City__c,
                       DL_Email__c,DL_Location_Updated__c,DL_Location__c,DL_Location__Latitude__s,DL_Location__Longitude__s,
                       DL_Loc_AGN__c,DL_Loc_Latitude_AGN__c,DL_Loc_Longitude_AGN__c,DL_Mailing_Address__c,DL_Office_Fax__c,
                       DL_Office_Phone__c,DL_Postal_Code__c,DL_Province__c,Do_Not_Call_vod__c,Do_Not_Create_Child_Account_vod__c,
                       Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,Do_not_send_Mail__c,Do_Not_Sync_Sales_Data_vod__c,
                       Do_not_Visit_AGN__c,Education_Speciality_AGN__c,Email_Internal_AGN__c,EM_Assignment_Country_AGN__c,
                       Enable_Restricted_Products_vod__c,Est_No_of_intravitrealInjsByCentreYr_AGN__c,
                       Exclude_from_Zip_to_Terr_Processing_vod__c,External_ID2_AGN__c,External_ID3_AGN__c,
                       External_ID4_AGN__c,External_ID_vod__c,Fax,FaxMaker_Email_AGN__c,Fax_Internal_AGN__c,
                       FirstName,Formatted_Name_vod__c,Furigana_vod__c,Gas_Limit_Search_AGN__c,Gender_vod__c,
                       global_code_CCQS_TRNS_vod__c,Graduation_School_AGN__c,Graduation_Year_AGN__c,
                       Group_Specialty_1_vod__c,Group_Specialty_2_vod__c,hco_status_CCQS_vod__c,hcp_status_CCQS_vod__c,
                       HMO_Market_Shr__c,HMO_POS__c,HMO__c,Hospital_Type_vod__c,Id,ID2_vod__c,ID_vod__c,IMS_Number__c,
                       Industry,Influential_profile_AGN__c,Institution_Site_AGN__c,Interests__c,Intern_Managers_Approval_AGN__c,
                       Investigator_vod__c,IsCustomerPortal,IsDeleted,IsExcludedFromRealign,IsLocked,IsPersonAccount,
                       IS_Rank_AGN__c,IS_Type_AGN__c,KOL_Type__c,KOL_vod__c,Language_vod__c,
                       LastActivityDate,LastModifiedById,LastModifiedDate,LastName,LastReferencedDate,LastViewedDate,
                       Location_Address_AGN__c,Mailing_Address_AGN__c,MasterRecordId,Master_Align_Id_vod__c,MayEdit,
                       MA_Core_OL_AGN__c,MA_OL_Count_AGN__c,MDM_ID_AGN__c,Mederi_Advisor_Score__c,
                       Mederi_Brand_Advocate_Score__c,Mederi_Budget_Decider_Score__c,Mederi_Guideline_Maker_Score__c,
                       Mederi_ID__c,Mederi_Investigator_Score__c,Mederi_Network_Analyzer__c,Mederi_Overall_KOL_Score__c,
                       Mederi_Person_Type__c,Mederi_Profession__c,Mederi_Researcher_Score__c,Medicaid__c,
                       Medical_Affairs_AGN__c,Medical_Expenses_PMPM__c,Medical_Loss_Ratio__c,Medicare__c,ME__c,
                       Middle_vod__c,Mobile_ID_vod__c,Mobile_ID_vod__pc,Mobile_Internal_AGN__c,Model__c,Name,
                       Net_Income_Loss_000__c,No_Orders_vod__c,NPI_vod__c,NS_Headache_Target_Centre_AGN__c,
                       NS_OAB_Target_Centre_AGN__c,NumberOfEmployees,Number_of_Employees_CCQS_vod__c,
                       objective_social_CCQS_TRNS_vod__c,Offerings__c,OK_Account_Class__c,OK_ExternalID__c,Oldest_HCI_ID__c,
                       Oldest_HCP_ID__c,Open_Amount_AGN__c,Order_Type_vod__c,Organization_Registration_Reference_AGN__c,
                       Other_Name_AGN__c,Other_title_information_AGN__c,Outstanding_Amount_AGN__c,Overdue_Amount_AGN__c,
                       OwnerId,Ownership,Owner_AGN__c,ParentId,Parent_AGN__c,Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,
                       Partner_Rep_Name_AGN__c,Partner_Team_Name_AGN__c,Patients_AGN__c,Payer_Id_vod__c,
                       PDRP_Opt_Out_Date_vod__c,PDRP_Opt_Out_vod__c,PersonAssistantName,PersonAssistantPhone,PersonBirthdate,
                       PersonContactId,PersonDepartment,PersonDoNotCall,PersonEmail,PersonEmailBouncedDate,
                       PersonEmailBouncedReason,PersonHasOptedOutOfEmail,PersonHasOptedOutOfFax,PersonHomePhone,
                       PersonLastCURequestDate,PersonLastCUUpdateDate,PersonMailingAddress,PersonMailingCity,
                       PersonMailingCountry,PersonMailingGeocodeAccuracy,PersonMailingLatitude,PersonMailingLongitude,
                       PersonMailingPostalCode,PersonMailingState,PersonMailingStreet,PersonMobilePhone,PersonOtherAddress,
                       PersonOtherCity,PersonOtherCountry,PersonOtherGeocodeAccuracy,PersonOtherLatitude,PersonOtherLongitude,
                       PersonOtherPhone,PersonOtherPostalCode,PersonOtherState,PersonOtherStreet,PersonTitle,Phone,
                       Phone_Internal_AGN__c,Phone_Opt_Out_AGN__c,PhotoUrl,Photo_vod__c,Physician_Registration_Reference_AGN__c,
                       PMPM_Income_Loss_000__c,Position_at_Primary_Institution_AGN__c,PPO_POS__c,PPO__c,
                       Practice_at_Hospital_vod__c,Practice_Near_Hospital_vod__c,Preferred_Name_vod__c,Primary_HCI_ID__c,
                       Primary_HCP_ID__c,Primary_Parent_vod__c,Privacy_AGN__c,Privacy_law_status_AGN__c,
                       professional_title_CCQS_vod__c,Profile_AGN__c,Quintile_AGN__c,Rating,RecordTypeId,Regional_Strategy__c,
                       registration_number_CCQS_TRNS_vod__c,Remaining_Credit_AGN__c,Requested_from_DCR_AGN__c,
                       Restricted_Products_vod__c,Retina_Profile_Centre_AGN__c,rpps_code_CCQS_TRNS_vod__c,
                       Sales_Credit_Limit_AGN__c,Salutation,Sample_Default_vod__c,Segmentations_vod__c,
                       ShippingAddress,ShippingCity,ShippingCountry,ShippingGeocodeAccuracy,ShippingLatitude,ShippingLongitude,
                       ShippingPostalCode,ShippingState,ShippingStreet,Sic,SicDesc,Site,Speaker__c,Speciality_Country_AGN__c,
                       Specialty_1_AGN__c,Specialty_1_vod__c,Specialty_2_AGN__c,Specialty_2_vod__c,Specialty_3_AGN__c,
                       Specialty_Allergan_1_AGN__c,Specialty_Allergan_2_AGN__c,Specific_Visiting_Rules_Available_AGN__c,
                       Spend_Amount__c,Spend_Status_Value_vod__c,Spend_Status_vod__c,Spider_graph__c,Status_AGN__c,
                       Strategic_Account_Y_N_AGN__c,Strategic_Account_Y_N__c,student_semester_CCQS_TRNS_vod__c,
                       student_type_CCQS_TRNS_vod__c,student_year_CCQS_TRNS_vod__c,Sub_Specialty_Allergan_AGN__c,
                       Sub_Type_AGN__c,Suffix_vod__c,SystemModstamp,Target_AGN__c,Target_Level__c,Target__c,Tax_Status__c,
                       Telephone_2_AGN__c,Telephone_Extension_1_AGN__c,Territory_Test_vod__c,Territory_vod__c,TickerSymbol,
                       Top_50_AGN__c,Total_Lives__c,Total_MDs_DOs__c,Total_Pharmacists__c,Total_Physicians_Enrolled__c,
                       Total_Revenue_000__c,Training_Attended_per_Product_AGN__c,Type,Type_AGN__c,Usr_AGN__c,Veeva_Id_AGN__c,
                       Visiting_Rules_Known_AGN__c,Wait_Time__c,Website,Wolters_Klewers_Number__c,
                       Workplace_AGN__c from Account where Id = :accId LIMIT 1];
        
        Savepoint sp = Database.setSavepoint();
        dcrId = AGN_VeevaDCR_Utilities.createAccountDCR(acc,'ValidateDCR',acc.country_vod__c,DCR_note);
        
        if(dcrId == 'Error'){
            Database.rollback(sp);
            return dcrId;
        }
        
        /*Data_Change_Request_vod__c dcr = new Data_Change_Request_vod__c();
        
        //accCountryId = acc.Country_vod__c;
        //accCountryName = [select NAME from Country_vod__c where Id = :accCountryId].NAME;
        DCR_Config_Settings_AGN__c dcrSettings = DCR_Config_Settings_AGN__c.getInstance();
        
        dcr.RecordTypeId = [select Id from RecordType where sObjectType = 'Data_Change_Request_vod__c' and Name = 'Account_vod' LIMIT 1].Id;
        dcr.Type_vod__c = 'New_vod';
        dcr.Date_Time_vod__c = System.now();
        dcr.Status_vod__c = 'Submitted_vod';
        dcr.DCR_Status_AGN__c = 'Pending for Approval';   
        dcr.Account_vod__c = acc.Id;
        dcr.Account_Validation_DCR_AGN__c = TRUE;
        dcr.OwnerId = dcrSettings.Integration_User_ID_AGN__c;
        
        Savepoint sp = Database.setSavepoint();
        
        try{
            insert dcr;
        }catch(System.Exception e){
            system.debug('@@ Exception encountered while inserting DCR. Exception: ' + e);
            Database.rollback(sp);
            return 'Error';
        }
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();

        Data_Change_Request_Line_vod__c dcrLine = new Data_Change_Request_Line_vod__c();
        dcrLine.Data_Change_Request_vod__c = dcr.Id;
        dcrLine.Field_API_Name_vod__c = 'Country_vod__c';
        dcrLine.Field_Name_vod__c = fieldMap.get('Country_vod__c').getDescribe().getLabel();
        dcrLine.New_Value_vod__c = acc.Country_vod__c;
        dcrLine.New_Localized_Value_vod__c = [select NAME from Country_vod__c where Id = :acc.Country_vod__c].NAME;
        
        try{
            insert dcrLine;
        }catch(System.Exception e){
            system.debug('@@ Exception encountered while inserting DCR Line. Exception: ' + e);
            Database.rollback(sp);
            return 'Error';            
        }*/
        
        try{
            if(Schema.sObjectType.Account.fields.Sent_to_DP_AGN__c.isUpdateable()){// swar cc
                acc.Sent_to_DP_AGN__c = TRUE;
            }
            if(Account.sObjectType.getDescribe().isUpdateable()){// swar cc
                update acc;
            }
        }catch(System.Exception e){
            system.debug('@@ Exception encountered while updating Sent to DP in Account. Exception: ' + e);
            Database.rollback(sp);
            return 'Error';
        }
        
        return dcrId;
        
    }
    
}