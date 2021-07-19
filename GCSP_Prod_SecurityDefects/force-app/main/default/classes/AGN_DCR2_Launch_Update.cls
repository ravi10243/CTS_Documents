// AGN_DCR2_Launch_Update //

public without sharing class AGN_DCR2_Launch_Update {
    
    // ======== Public Variables ======== //
    public string PramAccId;
    

// ================================================================ //
        
    public AGN_DCR2_Launch_Update() {
        system.debug('== [AGN_DCR2_Launch_Update].[Constructor] ==');
        PramAccId = ApexPages.currentPage().getParameters().get('accid');            // ID of Account Invoking the DCR Request
    }
    
    
// ================================================================ //
    
    public PageReference LaunchDcrUpdatePage() {
        system.debug('== [AGN_DCR2_Launch_Update].[LaunchDcrUpdatePage] ==');
        
        boolean allowedDcr = false;

        DCR_Config_Settings_AGN__c dcrSetting = DCR_Config_Settings_AGN__c.getOrgDefaults();
        User LoggedInUser = [SELECT Country_Code__c,Cluster_User_AGN__c,MA_Medical_Affairs_AGN__c FROM User WHERE Id = :UserInfo.getUserId()];
                system.debug('== [Query:LoggedInUser] =='+LoggedInUser);
        
        // ======== Launching Old DCR if Enhanced DCR is not deployed to the Market ======== //
        if(!(dcrSetting.DCR_Deployed_CountryCodes__c).contains(LoggedInUser.Country_Code__c)) {
            return new PageReference('/apex/AGN_DCR_Admin').setRedirect(true);
        }

        string accRecordType = 
                [SELECT RecordType.Name FROM Account WHERE id = :PramAccId].RecordType.Name;
                system.debug('== [Query:accRecordType] =='+accRecordType);

        List<DCR_Configuration_Settings_AGN__c> dcrConfigSetting = AGN_DCR2_Utilities.fetchDCRConfigSettings(UserInfo.getUserId());
        
        if(accRecordType == 'Professional_vod')
            if(dcrConfigSetting[0].HCP_Update_Allowed_AGN__c == true)
                allowedDcr = true;
        if(accRecordType != 'Professional_vod')
            if(dcrConfigSetting[0].HCO_Update_Allowed_AGN__c == true)
                allowedDcr = true;

        if(allowedDcr)
            return CreateUpdateDcr(LoggedInUser.Country_Code__c);
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.AGN_DCR2_Creation_Not_Allowed_for_This_Type));
            // == 'You are not allowed to create this type of DCR.'
            return null;
        }
    }

    public PageReference CreateUpdateDcr(string userCountryCode) {
        system.debug('== [AGN_DCR2_Launch_Update].[CreateUpdateDcr].PramAccId =='+PramAccId);
        
        string recordType;
        Id recordTypeId;
        
        
        
    // ======== CREATION OF DCR_ACCOUNT ========= //
        system.debug('== [AGN_DCR2_Launch_Update].[CreateUpdateDcr].[CREATION OF DCR_ACCOUNT] ==');

        List<DCR_Account_AGN__c> dcr = new List<DCR_Account_AGN__c>();
        List<Account> acc = 
                [SELECT Id,RecordType.Name,Name,AGN_DCR_Ref__c,FirstName,Middle_vod__c,LastName,Avocis_placed_AGN__c,Consent_to_Contact_AGN__c,
                    Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,Do_not_send_Mail__c,
                    Do_not_Visit_AGN__c,KOL_vod__c,NS_Headache_Target_Centre_AGN__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Target__c,
                    Sales_Credit_Limit_AGN__c,Avocis_date_AGN__c,PersonBirthdate,PersonEmail,Email_Internal_AGN__c,Partner_Email_AGN__c,
                    Description,Primary_Parent_vod__c,Specialty_Allergan_1_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Sub_Specialty_Allergan_AGN__c,
                    Departments__c,Patients_AGN__c,Beds__c,Fax,Fax_Internal_AGN__c,PersonMobilePhone,Phone,Phone_Internal_AGN__c,Status_AGN__c,
                    Type_AGN__c,Customer_Consent_AGN__c,Default_Order_Type_vod__c,Gender_vod__c,IS_Rank_AGN__c,IS_Type_AGN__c,Language_vod__c,
                    No_Orders_vod__c,Position_at_Primary_Institution_AGN__c,Salutation,Workplace_AGN__c,Influential_profile_AGN__c,Order_Type_vod__c,
                    Calling_Name_AGN__c,Education_Speciality_AGN__c,External_ID_vod__c,Graduation_School_AGN__c,Institution_Site_AGN__c,
                    Other_Name_AGN__c,Address_AGN__c,Partner_Emp_Code_AGN__c,Partner_Rep_Name_AGN__c,Partner_Team_Name_AGN__c,Country_vod__c,
                    Country_Code__c,Graduation_Year_AGN__c,Organization_Registration_Reference_AGN__c,Physician_Registration_Reference_AGN__c,
                    Other_title_information_AGN__c,Account_Group_vod__c,Account_Group_AGN__c,Distribution_ID_AGN__c,Website,Consent_to_Phone_AGN__c,
                    External_ID2_AGN__c,External_ID4_AGN__c,Additional_Specialties_AGN__c,Target_AGN__c,ParentId,Customer_Managed_AGN__c
                    FROM Account WHERE Id = :PramAccId];
                system.debug('== [Query:acc] =='+acc);
                
        //======GCSP:30May17 : added the if else if this account is beig managed by customer registered via customer portal======//
        if(acc[0].Customer_Managed_AGN__c== true){

            string managedBy = (String)AGN_GCSP_Settings__c.getValues(acc[0].Country_Code__c).get('Account_Managed_By__c') ;
            if(managedBy == 'Self'){
                recordType = (acc[0].RecordType.Name == 'Professional_vod'  ?  'HCP_Update_' : 'HCO_Update_');
                recordType += 'Company_Managed_AGN';
                recordTypeId  = [SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Account_AGN__c' AND DeveloperName = :recordType].id;
                        system.debug('== [Query:recordTypeId] =='+recordTypeId);

            }
            else if(managedBy == 'Data'){
                recordType = (acc[0].RecordType.Name == 'Professional_vod'  ?  'HCP_Update_' : 'HCO_Update_');
                recordType += 'Data_Provider_Managed_AGN';
                recordTypeId  = [SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Account_AGN__c' AND DeveloperName = :recordType].id;
                        system.debug('== [Query:recordTypeId] =='+recordTypeId);

            }
        }
        else{
        
            recordType = (acc[0].RecordType.Name == 'Professional_vod'  ?  'HCP_Update_' : 'HCO_Update_');
            recordType += ((acc[0].External_ID_vod__c == null || userCountryCode=='CA'|| userCountryCode=='JP'|| userCountryCode=='KR')  ?  'Company_Managed_AGN' : 'Data_Provider_Managed_AGN');
            recordTypeId  = [SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Account_AGN__c' AND DeveloperName = :recordType].id;
                    system.debug('== [Query:recordTypeId] =='+recordTypeId);
        }

        // ======== DCR_Account Value Stamping ======== //
        dcr.add(new DCR_Account_AGN__c());
        dcr[0].RecordTypeId = recordTypeId;
        dcr[0].Request_Status_AGN__c = 'Processing';
        dcr[0].Account_Type_AGN__c = acc[0].RecordType.Name;
        AGN_DCR2_Utilities.CopyAccountDetail(acc[0],dcr[0],true,acc[0].RecordType.Name == 'Professional_vod');
        
        // ======== DCR_Account Record Insert ======== //
        try {
            system.debug('== [DML:insert dcr] =='+dcr);
            insert dcr;
            system.debug('== [DML:insert dcr].success ==');
        } catch (System.DmlException e) {
            string errStr = '[AGN_DCR2_Launch_Update].[CreateUpdateDcr].[Creation of DCR_Account] == DmlException:' + e.getDmlMessage(0);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.AGN_DCR2_Contact_Administrator_Error_Message +' '+ errStr));
            // == 'An error has occurred. Please contact the Administrator with the following message: ...'
            return null;
        }
        system.debug('== [AGN_DCR2_Launch_Update].[CreateUpdateDcr].[Creation of DCR_Account] == dcr.id='+dcr[0].id);

    // -------- CREATION OF DCR_ACCOUNT -------- //



    // ======== CREATION OF DCR_AFFILIATION ======== //
        system.debug('== [AGN_DCR2_Launch_Update].[CreateUpdateDcr].[CREATION OF DCR_AFFILIATION] ==');
        
        List<DCR_Affiliation_AGN__c> dcrAff = new List<DCR_Affiliation_AGN__c>();
        List<Child_Account_vod__c> accAff = new List<Child_Account_vod__c>();

        if(recordType.contains('HCP')) {
            system.debug('== [AGN_DCR2_Launch_Update].[CreateUpdateDcr].[CREATION OF DCR_AFFILIATION].[for HCP] ==');
            accAff= [SELECT Id,OK_Role__c,Work_Status_AGN__c,Parent_Account_vod__c,Child_Account_vod__c,
                        Child_Account_vod__r.Primary_Parent_vod__c ,Customer_Managed_AGN__c
                        FROM Child_Account_vod__c WHERE Child_Account_vod__c  = :PramAccId];
                    system.debug('== [Query:accAff] =='+accAff);
            
            // ======== DCR_Affiliation Value Stamping ======== //
            String vRecTypeID=[SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Affiliation_AGN__c' AND DeveloperName = 'HCP_to_ACC_Affiliation'].id;
            String portalRecTypeID=[SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Affiliation_AGN__c' AND DeveloperName = 'HCP_to_Portal_ACC_Affiliation'].id;
            for(Child_Account_vod__c aAff : accAff) {
                DCR_Affiliation_AGN__c dAff = new DCR_Affiliation_AGN__c();
                
                //======GCSP:30May17 : added the if else if this account is beig managed by customer registered via customer portal======//
                if(aAff.Customer_Managed_AGN__c == true){
                    dAff.RecordTypeId = portalRecTypeID;
                    system.debug('== [Query:dAff.RecordTypeId] =='+dAff.RecordTypeId);
                }
                else{
                    dAff.RecordTypeId = vRecTypeID;
                            system.debug('== [Query:dAff.RecordTypeId] =='+dAff.RecordTypeId);
                }
                dAff.Parent_DCR_AGN__c = dcr[0].id;
                dAff.Tgt_Account_AGN__c = aAff.Child_Account_vod__c;
                dAff.Affiliated_Account_AGN__c = aAff.Parent_Account_vod__c;
                dAff.Target_Affiliation_AGN__c = aAff.id;
                if(aAff.Child_Account_vod__r.Primary_Parent_vod__c == aAff.Parent_Account_vod__c)
                    dAff.Primary_AGN__c = 'Yes';
                else
                    dAff.Primary_AGN__c = 'No';
                dAff.Is_Changed_AGN__c = false;
                AGN_DCR2_Utilities.CopyAffiliationDetail(aAff,dAff,true);
                dcrAff.add(dAff);
            }
        }
        else // if(recordType.contains('HCO')) 
        {
            system.debug('== [AGN_DCR2_Launch_Update].[CreateUpdateDcr].[CREATION OF DCR_AFFILIATION].[for HCO] ==');
            accAff= [SELECT Id,OK_Role__c,Work_Status_AGN__c,Parent_Account_vod__c,Child_Account_vod__c,
                        Child_Account_vod__r.Primary_Parent_vod__c ,Customer_Managed_AGN__c
                        FROM Child_Account_vod__c WHERE Parent_Account_vod__c  = :PramAccId];
                    system.debug('== [Query:accAff] =='+accAff);

            // ======== DCR_Affiliation Value Stamping ======== //
            String vRecTypeID=[SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Affiliation_AGN__c' AND DeveloperName = 'HCO_to_ACC_Affiliation'].id;
            String portalRecTypeID = [SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Affiliation_AGN__c' AND DeveloperName = 'HCO_to_Portal_ACC_Affiliation'].id;
            for(Child_Account_vod__c aAff : accAff) {
                DCR_Affiliation_AGN__c dAff = new DCR_Affiliation_AGN__c();
                //======GCSP:30May17 : added the if else if this account is beig managed by customer registered via customer portal======//
                if(aAff.Customer_Managed_AGN__c==true){
                    dAff.RecordTypeId = portalRecTypeID;
                            system.debug('== [Query:dAff.RecordTypeId] =='+dAff.RecordTypeId);
                }
                else{
                    dAff.RecordTypeId = vRecTypeID;
                            system.debug('== [Query:RecordTypeId] =='+RecordTypeId);
                }
                dAff.Parent_DCR_AGN__c = dcr[0].id;
                dAff.Tgt_Account_AGN__c = aAff.Parent_Account_vod__c;
                dAff.Affiliated_Account_AGN__c = aAff.Child_Account_vod__c;
                dAff.Target_Affiliation_AGN__c = aAff.id;
                dAff.Primary_AGN__c = 'No';
                dAff.Is_Changed_AGN__c = false;
                AGN_DCR2_Utilities.CopyAffiliationDetail(aAff,dAff,true);
                dcrAff.add(dAff);
            }
        }

        // ======== DCR_Affiliation Record Insert ======== //
        try {
            system.debug('== [DML:insert dcrAff] =='+dcrAff);
            insert dcrAff;
            system.debug('== [DML:insert dcrAff].success ==');
        } catch (System.DmlException e) {
            string errStr = '[AGN_DCR2_Launch_Update].[CreateUpdateDcr].[Creation of DCR_Affiliation] == DmlException:' + e.getDmlMessage(0);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.AGN_DCR2_Contact_Administrator_Error_Message +' '+ errStr));
            // == 'An error has occurred. Please contact the Administrator with the following message: ...'
            return null;
        }
        
    // -------- CREATION OF DCR_AFFILIATION -------- //



    // ======== CREATION OF DCR_ADDRESS ======== //
        system.debug('== [AGN_DCR2_Launch_Update].[CreateUpdateDcr].[CREATION OF DCR_ADDRESS] ==');

        if(acc[0].RecordType.Name != 'Professional_vod') {

            List<DCR_Address_AGN__c> dcrAdd = new List<DCR_Address_AGN__c>();
            List<Address_vod__c> accAdd = 
                    [SELECT Id,Name,Account_vod__c,Address_Line_2_vod__c,Address_Line_3_AGN__c,
                        Brick_vod__c,City_vod__c,Country_vod__c,Phone_vod__c,Primary_vod__c,Address_Type_vod__c,Billing_vod__c,
                        Business_vod__c,Home_vod__c,Mailing_vod__c,Zip_vod__c,Shipping_vod__c,Fax_vod__c,Appt_Required_vod__c,
                        Receptionist_Name_AGN__c,Phone_2_vod__c,Receptionist_Email_AGN__c,State_vod__c,Inactive_vod__c,Customer_Managed_AGN__c
                        FROM Address_vod__c WHERE Account_vod__c = :PramAccId];
                    system.debug('== [Query:accAdd] =='+accAdd);
                
            // ======== DCR_Address Value Stamping ======== //
            String custAddrRecTypeID = [SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Address_AGN__c' AND DeveloperName = 'Customer_Managed_AGN'].id;
            String agnAddrRecTypeID =[SELECT Id FROM RecordType WHERE SobjectType = 'DCR_Address_AGN__c' AND DeveloperName = 'Allergan_Managed_AGN'].id;
            for(Address_vod__c aAdd : accAdd) {
                DCR_Address_AGN__c dAdd = new DCR_Address_AGN__c();
                
                //======GCSP:30May17 : added the if else if this address is beig managed by customer registered via customer portal======//
                if(aAdd.Customer_Managed_AGN__c==true){
                    dAdd.RecordTypeId = custAddrRecTypeID;
                            system.debug('== [Query:dAdd.RecordTypeId] =='+dAdd.RecordTypeId);
                }
                else{
                    dAdd.RecordTypeId = agnAddrRecTypeID;
                            system.debug('== [Query:dAdd.RecordTypeId] =='+dAdd.RecordTypeId);
                }
                dAdd.Parent_DCR_AGN__c = dcr[0].id;
                dAdd.Target_Address_AGN__c = aAdd.id;
                dAdd.Is_Changed_AGN__c = false;
                AGN_DCR2_Utilities.CopyAddressDetail(aAdd,dAdd,true);
                dcrAdd.add(dAdd);
            }

            // ======== DCR_Address Record Insert ======== //
            try {
                system.debug('== [DML:insert dcrAdd] =='+dcrAdd);
                insert dcrAdd;
                system.debug('== [DML:insert dcrAdd].success ==');
            } catch (System.DmlException e) {
                string errStr = '[AGN_DCR2_Launch_Update].[CreateUpdateDcr].[Creation of DCR_Address] == DmlException:' + e.getDmlMessage(0);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.AGN_DCR2_Contact_Administrator_Error_Message +' '+ errStr));
                // == 'An error has occurred. Please contact the Administrator with the following message: ...'
                return null;
            }
        }

    // -------- CREATION OF DCR_ADDRESS -------- //



    // ======== CREATION OF DCR_KEY_INDICATOR ======== //
        system.debug('== [AGN_DCR2_Launch_Update].[CreateUpdateDcr].[CREATION OF DCR_KEY_INDICATOR] ==');

        if(acc[0].RecordType.Name == 'Professional_vod') {

            List<DCR_Key_Indicator_AGN__c> dcrKeyIndcatrs = new List<DCR_Key_Indicator_AGN__c>();
            Map<String,Product_Metrics_vod__c> accKeyIndcatrMap = new Map<String,Product_Metrics_vod__c>();
            List<Product_Metrics_vod__c> prodMetrListAcc = 
                    [SELECT Id,Name,Account_vod__c,Products_vod__c,Detail_Group_vod__c,Adoption_AGN__c,Allergan_Potential_AGN__c,
                        Account_Support_AGN__c,Adoption_IMS_AGN__c,Adoption_Level__c,Advocacy_Profile_AGN__c,Awareness__c,
                        Continuum_Placement_AGN__c,Engagements__c,Fase_AGN__c,Fixed_Consignment_AGN__c,Growth_Potential_AGN__c,
                        Investigator_smb__c,Investigator_Readiness__c,Key_Account_AGN__c,Ophthalmology_Profile_AGN__c,
                        Potential_IMS_AGN__c,Product_Status_AGN__c,Profiling_AGN__c,Ratings_AGN__c,Retina_Profile_AGN__c,
                        Sales_Target_AGN__c,Sector_AGN__c,Customer_Segment_AGN__c,Segment__c,Segment_AGN__c,Segment_IMS_AGN__c,
                        Target_AGN__c
                        FROM Product_Metrics_vod__c WHERE Products_vod__r.No_Metrics_vod__c = false AND Account_vod__c = :PramAccId];
                    system.debug('== [Query:prodMetrListAcc] =='+prodMetrListAcc);

            for(Product_Metrics_vod__c pm : prodMetrListAcc)
                accKeyIndcatrMap.put(pm.Products_vod__c+'-'+pm.Detail_Group_vod__c,pm);
            
            dcrKeyIndcatrs = AGN_DCR2_Utilities.Create_DCR_Key_Indicators(dcr[0]);
            
            // ======== DCR_Key_Indicator Value Stamping ======== //
            for(integer i = 0 ; i < dcrKeyIndcatrs.size() ; i++) {
                string mapKey = dcrKeyIndcatrs[i].Product_AGN__c+'-'+dcrKeyIndcatrs[i].Product_Group_AGN__c;
                if(accKeyIndcatrMap.containsKey(mapKey)) {
                    // dcrKeyIndcatrs[i].Parent_DCR_AGN__c = dcr[0].id;
                    dcrKeyIndcatrs[i].Target_Key_Indicator_AGN__c = accKeyIndcatrMap.get(mapKey).id;
                    AGN_DCR2_Utilities.CopyKeyIndicatorDetail(accKeyIndcatrMap.get(mapKey),dcrKeyIndcatrs[i],true);
                }
            }

            // ======== DCR_Key_Indicator Record Insert ======== //
            try {
                system.debug('== [DML:insert dcrKeyIndcatrs] =='+dcrKeyIndcatrs);
                insert dcrKeyIndcatrs;
                system.debug('== [DML:insert dcrKeyIndcatrs].success ==');
            } catch (System.DmlException e) {
                string errStr = '[AGN_DCR2_Launch_Update].[CreateUpdateDcr].[Creation of DCR_Key_Indicator] == DmlException:' + e.getDmlMessage(0);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.AGN_DCR2_Contact_Administrator_Error_Message +' '+ errStr));
                // == 'An error has occurred. Please contact the Administrator with the following message: ...'
                return null;
            }
        }

    // -------- CREATION OF DCR_KEY_INDICATOR -------- //


        system.debug('== [AGN_DCR2_Launch_Update].[End of CreateUpdateDcr] ==');


        // ======== Redirection to the newly created DCR ======== //
        Schema.DescribeSObjectResult destination = DCR_Account_AGN__c.SObjectType.getDescribe();
        return new PageReference('/'+dcr[0].id).setRedirect(true);
    }
}

// AGN_DCR2_Launch_Update //