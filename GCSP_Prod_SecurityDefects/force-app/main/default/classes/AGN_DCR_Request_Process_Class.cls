// AGN_DCR_Request_Process_Class
//20 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team

public without sharing class AGN_DCR_Request_Process_Class{
    
    //Custom Labels
    static String HCO = 'HCO';
    static String HCP = 'HCP';
    
    //Map to store Account's record type Name and Id.
    public static Map<string,string> loadAccountRecordType(){
        Map <string,string> accRTMap = new Map <string,string>();
    list<RecordType> rtype=[select id,Name from RecordType where sobjectType = 'Account'];
        for (RecordType rt : rtype)
        {
            accRTMap.put(rt.Name,rt.Id);
        } 
        return accRTMap;
    }
    
    // Update Account status based on DCR Approval/ Rejection.
    public static void updateExistingAccountStatus(DCR_AGN__c cr,String AccountStatus){
        system.debug('===== Inside [updateExistingAccountStatus] =====');
        Account acc = new Account();
        list<Account> acclist = new list<Account>();
        if (cr.Request_Entity_AGN__c == HCO)
        {
            for (Account ac :[select id,Status_AGN__c,Consent_to_Contact_AGN__c,Do_not_Visit_AGN__c from Account where Id =: cr.P_Business_Account_Id_AGN__c] )
            {
                acclist.add(ac);
            }
            if(acclist.size() > 0)
            {
                for (Account a : acclist)
                {
                    acc.Id=a.Id;
                    acc.Status_AGN__c = AccountStatus;
                    if (AccountStatus == 'Inactive'){
                        acc.Consent_to_Contact_AGN__c = false;
                        acc.Do_not_Visit_AGN__c = true;
                    }
                }               
                update acc;
            } 
        }
        else //(cr.Request_Entity_AGN__c == 'HCP')
        {
            for (Account ac :[select id,Status_AGN__c,Consent_to_Contact_AGN__c,Do_not_Visit_AGN__c  from Account where Id =: cr.P_Person_Account_Id_AGN__c] )
            {
                acclist.add(ac);
            }
            if(acclist.size() > 0)
            {
                for (Account a : acclist)
                {
                    acc.Id = a.Id;
                    acc.Status_AGN__c = AccountStatus;
                     if (AccountStatus == 'Inactive'){
                        acc.Consent_to_Contact_AGN__c = false;
                        acc.Do_not_Visit_AGN__c = true;
                    }
                }
                update acc;
            }
        }
        //R006 - New code for Aligning an Account to DCR requesters' terirritory
        //using Immediate territory alignment code once DCR request is 'Accepted'.
        if (acc.Id != null){
            if (AccountStatus == 'Accepted' && cr.TAAF_AGN__c == true){
                createImmediateTerritoryAlignment(cr.Id,acc.Id);
            }
        }
    }
    // Create New Provisional Account.
    public static void createNewProvisionalAccount(DCR_AGN__c cr,String AccountStatus){
        system.debug('===== Inside [createNewProvisionalAccount] =====');
        Account acc = new Account();
        DCR_AGN__c newDCR = new DCR_AGN__c();
        String accClusterCode;
                 DCR_AGN__c dcr=[select name, id, ownerid,Owner_AGN__c,Country_Code_AGN__c,CreatedById from DCR_AGN__c where id=:cr.id];
          //User dcrOwner = [select Id, Name, ProfileId, ManagerId, DCR_Self_Approved__c, Country_Code__c, MA_Medical_Affairs_AGN__c, DCR_Approver_AGN__c FROM User WHERE Id = :cr.OwnerId Limit 1];
        Map<string,string> accRTMap = loadAccountRecordType();
        if (cr.Request_Entity_AGN__c ==HCP)
        {
            acc.Salutation = cr.Salutation_AGN__c;
            acc.RecordTypeId = accRTMap.get(cr.Account_Type_AGN__c);
            //acc.Primary_Parent_vod__c = cr.Account_AGN__c;
            acc.FirstName= cr.FirstName_AGN__c;
            acc.LastName= cr.Last_Name_AGN__c;
            acc.Middle_vod__c = cr.Middle_Name_AGN__c;
            acc.Type_AGN__c = cr.Type_AGN__c ;
            acc.Privacy_AGN__c = cr.Privacy_AGN__c ;
            acc.Privacy_law_status_AGN__c = cr.Privacy_law_status_AGN__c ;
            acc.Gender_vod__c = cr.Gender_AGN__c ;
            acc.Specialty_1_AGN__c = cr.Specialty_1_AGN__c ;
            acc.Education_Speciality_AGN__c = cr.Education_Speciality_AGN__c ;
            acc.Specialty_2_AGN__c = cr.Specialty_2_AGN__c ;
            acc.Specialty_Allergan_1_AGN__c = cr.Specialty_Allergan_1_AGN__c ;
            acc.Sub_Specialty_Allergan_AGN__c = cr.Sub_Specialty_Allergan_AGN__c ;
            acc.Additional_Specialties_AGN__c = cr.Additional_Specialties_AGN__c ;
            // Manoj REQ 1026 R008.1
            User loggedinUser = [SELECT Cluster_User_AGN__c FROM user WHERE id = :dcr.CreatedById];
            if(loggedinUser.Cluster_User_AGN__c) {
                accClusterCode = [Select Cluster_Country_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =: dcr.Country_Code_AGN__c].Cluster_Country_AGN__c ;
                acc.Country_Code__c = accClusterCode;
            }
            else
            {
                 acc.Country_Code__c = dcr.Country_Code_AGN__c;
            }
            // END : Manoj REQ 1026 R008.1
            acc.Country_vod__c = [select Id from Country_vod__c where Alpha_2_Code_vod__c = :cr.Country_Code_AGN__c].Id;
            acc.PersonEmail = cr.Email_AGN__c ;
            acc.Consent_to_Email_AGN__c = cr.Consent_to_Email_AGN__c ;
            acc.Fax = cr.Fax_AGN__c ;
            acc.PersonEmail = cr.Email_AGN__c;
            acc.Consent_to_Mail_AGN__c = cr.Consent_to_Mail_AGN__c ;
            acc.PersonMobilePhone = cr.Mobile_AGN__c ;
            acc.Consent_to_Phone_AGN__c = cr.Consent_to_Phone_AGN__c ;
            acc.Workplace_AGN__c = cr.Workplace_AGN__c ;
            acc.KOL_vod__c = cr.KOL_AGN__c ;
            acc.Do_not_Phone_Call_AGN__c = cr.Do_not_Phone_Call_AGN__c ;
            acc.Do_not_send_Fax_AGN__c = cr.Do_not_send_Fax_AGN__c ;
            acc.Do_not_send_Mail__c = cr.Do_not_send_Mail_AGN__c ;
            acc.Other_title_information_AGN__c = cr.JobTitle_AGN__c ;
            acc.AGN_DCR_Ref__c = dcr.Name;
            //R003
            acc.Status_AGN__c = AccountStatus;
            acc.Target__c = cr.Target_AGN__c;
            acc.Language_vod__c = cr.Language_AGN__c;
            acc.Do_not_Visit_AGN__c = true;
            acc.Consent_to_Contact_AGN__c = cr.Consent_to_Contact_AGN__c;
            //R005
            acc.PersonBirthdate = cr.PersonBirthdate_AGN__c;
            acc.Graduation_School_AGN__c = cr.Graduation_School_AGN__c;
            acc.Graduation_Year_AGN__c = cr.Graduation_Year_AGN__c;
            acc.Phone_Internal_AGN__c = cr.Phone_Internal_AGN__c;
            acc.Email_Internal_AGN__c = cr.Email_Internal_AGN__c;
            acc.Fax_Internal_AGN__c = cr.Fax_Internal_AGN__c;
            acc.Calling_Name_AGN__c = cr.Calling_Name_AGN__c;
            acc.Other_Name_AGN__c = cr.Other_Name_AGN__c;
            acc.Description = cr.Description_AGN__c;
            acc.NS_Headache_Target_Centre_AGN__c = cr.NS_Headache_Target_Centre_AGN__c;
            //R006
            acc.No_Orders_vod__c = cr.No_Orders_AGN__c;
            acc.Order_Type_vod__c = cr.Order_Type_AGN__c;
            acc.Default_Order_Type_vod__c = cr.Default_Order_Type_AGN__c;
            //R007
            acc.Distribution_ID_AGN__c = cr.Distribution_ID_AGN__c;
            acc.External_ID2_AGN__c = cr.DCR_External_ID2_AGN__c;
            acc.External_ID4_AGN__c =  cr.DCR_External_ID4_AGN__c;
            acc.Physician_Registration_Reference_AGN__c = cr.Physician_Registration_Reference_AGN__c;                      
            //R007.1
            acc.Website = cr.Website_AGN__c;
            //R008
            acc.Influential_profile_AGN__c = cr.Influential_profile_AGN__c;
             //<--------------Modified by Manoj Paul For Release 008 Requirement# 918 : Added field to the query. Mapping of Newly Added fields into DRC to Account--------->
            acc.Avocis_date_AGN__c = cr.Avocis_date_AGN__c;
            acc.Avocis_placed_AGN__c = cr.Avocis_placed_AGN__c ; 
            acc.Owner_AGN__c = dcr.Owner_AGN__c; 
            acc.Customer_Consent_AGN__c = cr.Customer_Consent_AGN__c;
            acc.Position_at_Primary_Institution_AGN__c = cr.Position_at_Primary_Institution_AGN__c;
            //R008.1
            acc.Phone = cr.Account_Phone_AGN__c;
           
             //<--------------End of Modification-------------------------------->
        }
        else //(cr.Request_Entity_AGN__c == 'HCO')
        {
            acc.RecordTypeId = accRTMap.get(cr.Account_Type_AGN__c);
            acc.Name = cr.Account_Name_AGN__c;
            acc.Type_AGN__c = cr.Type_AGN__c ;
            //acc.Primary_Parent_vod__c = cr.Primary_Business_Accnt_AGN__c;
            acc.Privacy_AGN__c = cr.Privacy_AGN__c ;
            acc.Privacy_law_status_AGN__c = cr.Privacy_law_status_AGN__c ;
            acc.Specialty_1_AGN__c = cr.Specialty_1_AGN__c ;
            acc.Education_Speciality_AGN__c = cr.Education_Speciality_AGN__c ;
            acc.Specialty_2_AGN__c = cr.Specialty_2_AGN__c ;
            acc.Specialty_Allergan_1_AGN__c = cr.Specialty_Allergan_1_AGN__c ;
            acc.Sub_Specialty_Allergan_AGN__c = cr.Sub_Specialty_Allergan_AGN__c ;
            acc.Additional_Specialties_AGN__c = cr.Additional_Specialties_AGN__c ;
            // Manoj REQ 1026 R008.1
            User loggedinUser = [SELECT Cluster_User_AGN__c FROM user WHERE id = :dcr.CreatedById];
            if(loggedinUser.Cluster_User_AGN__c) {
                accClusterCode= [Select Cluster_Country_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =: cr.Country_Code_AGN__c].Cluster_Country_AGN__c ;
                acc.Country_Code__c = accClusterCode;
            }
            else
            {
                 acc.Country_Code__c = cr.Country_Code_AGN__c;
            }
            // END : Manoj REQ 1026 R008.1
            acc.Country_vod__c = [select Id from Country_vod__c where Alpha_2_Code_vod__c = :cr.Country_Code_AGN__c].Id;
            acc.PersonEmail = cr.Email_AGN__c ;
            acc.Fax = cr.Fax_AGN__c ;
            acc.Website = cr.Website_AGN__c;
            acc.Phone = cr.Account_Phone_AGN__c;
            acc.Consent_to_Email_AGN__c = cr.Consent_to_Email_AGN__c ;
            acc.Consent_to_Mail_AGN__c = cr.Consent_to_Mail_AGN__c ;
            acc.PersonMobilePhone = cr.Mobile_AGN__c ;
            acc.Consent_to_Phone_AGN__c = cr.Consent_to_Phone_AGN__c ;
            acc.Workplace_AGN__c = cr.Workplace_AGN__c;
            acc.Do_not_Phone_Call_AGN__c = cr.Do_not_Phone_Call_AGN__c ;
            acc.Do_not_send_Fax_AGN__c = cr.Do_not_send_Fax_AGN__c ;
            acc.Other_title_information_AGN__c = cr.JobTitle_AGN__c ;
            acc.Do_not_send_Mail__c = cr.Do_not_send_Mail_AGN__c ;
            acc.Beds__c = cr.Beds_AGN__c;
            acc.Departments__c =cr.Departments_AGN__c;
            acc.AGN_DCR_Ref__c = dcr.Name; 
            //R003
            acc.Status_AGN__c = AccountStatus;
            acc.Target__c = cr.Target_AGN__c;
            acc.Language_vod__c = cr.Language_AGN__c;
            acc.Do_not_Visit_AGN__c = true; 
            acc.Consent_to_Contact_AGN__c = cr.Consent_to_Contact_AGN__c;            
            //R005
            acc.Patients_AGN__c = cr.Patients_AGN__c;
            acc.Account_Group_vod__c = cr.Account_Group_AGN__c;
            acc.Institution_Site_AGN__c = cr.Institution_Site_AGN__c;
            acc.Phone_Internal_AGN__c = cr.Phone_Internal_AGN__c;
            acc.Email_Internal_AGN__c = cr.Email_Internal_AGN__c;
            acc.Fax_Internal_AGN__c = cr.Fax_Internal_AGN__c;
            acc.Calling_Name_AGN__c = cr.Calling_Name_AGN__c;
            acc.Other_Name_AGN__c = cr.Other_Name_AGN__c;
            acc.Description = cr.Description_AGN__c;
            acc.NS_Headache_Target_Centre_AGN__c = cr.NS_Headache_Target_Centre_AGN__c;
            //R007
            acc.Distribution_ID_AGN__c = cr.Distribution_ID_AGN__c;
            acc.External_ID2_AGN__c = cr.DCR_External_ID2_AGN__c;
            acc.External_ID4_AGN__c =  cr.DCR_External_ID4_AGN__c;
            acc.Physician_Registration_Reference_AGN__c = cr.Physician_Registration_Reference_AGN__c;   
            //R007.1
            acc.Organization_Registration_Reference_AGN__c = cr.Organization_Registration_Reference_AGN__c;
            acc.Account_Group_AGN__c = cr.Allergan_Account_Group_AGN__c;
            
            //Release 008 Requirement# 918 : Mapping of Newly Added fields 
            acc.Address_AGN__c = cr.Address_Whanin_AGN__c;
            acc.Avocis_date_AGN__c = cr.Avocis_date_AGN__c;
            acc.Avocis_placed_AGN__c = cr.Avocis_placed_AGN__c ; 
            acc.IS_Rank_AGN__c = cr.IS_Rank_AGN__c; 
            acc.IS_Type_AGN__c = cr.IS_Type_AGN__c; 
            acc.Owner_AGN__c = dcr.Owner_AGN__c; 
            acc.Partner_Email_AGN__c = cr.Partner_Email_AGN__c; 
            acc.Partner_Emp_Code_AGN__c = cr.Partner_Emp_Code_AGN__c; 
            acc.Partner_Rep_Name_AGN__c = cr.Partner_Rep_Name_AGN__c; 
            acc.Partner_Team_Name_AGN__c = cr.Partner_Team_Name_AGN__c; 
            acc.Sales_Credit_Limit_AGN__c = cr.Sales_Credit_Limit_AGN__c; 
            acc.Target_AGN__c = cr.Target_Whanin_AGN__c ;
            //--------------End of Modification--------------------------------
        }
        system.debug('===== [createNewProvisionalAccount] Before Account Insert ===== acc ==>> ' + acc);

        //R008.1 - Duplicate Ext ID
        Database.SaveResult sr;
        String err_msg = null;
        try{
             sr = Database.insert(acc);
        }
        catch(System.Exception exp){
            // check if error is due to Duplicate ID       
            if (exp.getMessage().contains('DUPLICATE_VALUE')){
                if (exp.getMessage().contains('External_ID4'))
                    err_msg = System.Label.DCR_Duplicate_ID_4;
                    //'EXCEPTION: Account creation failed. DUPLICATE VALUE on External ID4.'
                else if (exp.getMessage().contains('External_ID2'))
                    err_msg = System.Label.DCR_Duplicate_ID_2;
                    //'EXCEPTION: Account creation failed. DUPLICATE VALUE on External ID2.'
            }
            else{
                err_msg = System.Label.DCR_Account_Creation_Error + exp.getMessage();
                //'EXCEPTION: Error during Account creation.'
            }   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, err_msg));    
            
            // stamp CR status back to Submitted in case of Account creation failure.
            try{
                newDCR.Id = cr.Id;
                newDCR.Request_Status_AGN__c ='Submitted';
                newDCR.Error_Log_AGN__c = err_msg;
                system.debug('===== Account creation failed ====='+sr);
                update newDCR;
            }
            catch(Exception ex){
                 system.debug('EXCEPTION during update DCR status on Account creation failure: '+ ex );
            }
        }
        //R008.1 - Duplicate Ext ID

        if(sr != null) 
        {
            system.debug('===== [createNewProvisionalAccount] Account Insert Success ===== sr ==>> ' + sr);
            //Start - DCR reverse stamping
            newDCR.Id = cr.Id;
            if (cr.Request_Entity_AGN__c == HCO)
            { 
                newDCR.P_Business_Account_Id_AGN__c = sr.Id;
            }
            else
            {
                newDCR.P_Person_Account_Id_AGN__c = sr.Id;
            } 
            update newDCR;
            //End - DCR reverse stamping
            //Call Method - Create Address for new Account Inserted
            //Fixed - R008.1
            if(cr.Request_Type_AGN__c == 'Change' && cr.Address_AGN__c != null)
                createORupdateAddress(cr,sr.Id);
            if(cr.Request_Type_AGN__c == 'Add' && cr.Request_Entity_AGN__c == HCO)
                createORupdateAddress(cr,sr.Id);
            //END ::Fixed - R008.1
            // Call Method - Create Child Account for new HCP Account Inserted
            if(cr.Request_Entity_AGN__c == HCP && cr.Request_Type_AGN__c == 'Add' && cr.Account_AGN__c != null){
                createChildAccountHCP(cr);
            }
            // Call Method - Create Child Account for new HCO Account Inserted
            if(cr.Request_Entity_AGN__c == HCO && cr.Request_Type_AGN__c == 'Add' && cr.Primary_Business_Accnt_AGN__c != null){
                createChildAccountHCO(cr);
            }
            //Call Method - Territory Alignment for new  Account Inserted
            DCR_AGN__c checkTAAF = [Select TAAF_AGN__c,ITA_AGN__c from DCR_AGN__c where id =: cr.Id];
            if (checkTAAF.ITA_AGN__c == true || checkTAAF.TAAF_AGN__c == true){
                createImmediateTerritoryAlignment(cr.Id,sr.Id);
            }
            // Create Product Metrics Data
            insertProductMetrics(cr.Id,sr.Id);
        }
        /*else{
             try{
                newDCR.Id = cr.Id;
                newDCR.Request_Status_AGN__c ='Submitted';
                newDCR.Error_Log_AGN__c = err_msg;
                system.debug('===== Account creation failed ====='+sr);
                update newDCR;
            }
            catch(Exception ex){
                 system.debug('EXCEPTION during update DCR status on Account creation failure: '+ ex );
            }
        }*/
    }

    public static void createNewProvisionalAccountCDCR(DCR_AGN__c cr,String AccountStatus)
    { 
    List<DCR_AGN__c> cDCRrec = [SELECT Accepted_AGN__c,Account_AGN__c,Account_Country_AGN__c,Account_Group_AGN__c,Account_Name_AGN__c,Account_Phone_AGN__c,
            Account_Status_AGN__c,Account_Type_AGN__c,Additional_Specialties_AGN__c,Address_AGN__c,Address_Fax_AGN__c,Address_Line_1_AGN__c,Address_Line_2_AGN__c,
            Address_Line_3_AGN__c,Address_Status__c,Address_Type_AGN__c,Adoption_AGN__c,Adoption_IMS_AGN__c,Affiliated_Account_Sub_Type__c,Affiliated_Account_Type_AGN__c,
            Approved_By_AGN__c,Approver_Comment_AGN__c,Appt_Required_AGN__c,Auto_Approved_AGN__c,Beds_AGN__c,Billing_AGN__c,Brick_AGN__c,Business_AGN__c,Calling_Name_AGN__c,
            City_AGN__c,Consent_to_Contact_AGN__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,Consent_to_Phone_AGN__c,Contact_AGN__c,Country_AGN__c,Country_Code_AGN__c,
            CreatedById,CreatedDate,CurrencyIsoCode,DCR_Approver_AGN__c,DCR_External_ID2_AGN__c,DCR_External_ID4_AGN__c,DCR_External_ID_AGN__c,Default_Order_Type_AGN__c,
            Delete_Affiliation_AGN__c,Departments_AGN__c,Description_AGN__c,Detail_Group_AGN__c,Division_AGN__c,Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,
            Do_not_send_Mail_AGN__c,Do_not_Visit_AGN__c,Education_Speciality_AGN__c,Email_AGN__c,Email_Internal_AGN__c,Employee_AGN__c,Fax_AGN__c,Fax_Internal_AGN__c,
            FirstName_AGN__c,Gender_AGN__c,Graduation_School_AGN__c,Graduation_Year_AGN__c,Has_Product_Metrics__c,HCO_HCP_Name_AGN__c,Home_AGN__c,Id,Institution_Site_AGN__c,
            IsDeleted,IsLocked,Is_Reviewed_AGN__c,ITA_AGN__c,JobTitle_AGN__c,KOL_AGN__c,Language_AGN__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,
            LastViewedDate,Last_Name_AGN__c,Mailing_AGN__c,MayEdit,Medical_Affairs_AGN__c,Middle_Name_AGN__c,Migrated_to_DP_AGN__c,Mobile_AGN__c,Name,No_Orders_AGN__c,
            NS_Headache_Target_Centre_AGN__c,Order_Type_AGN__c,Other_Name_AGN__c,OwnerId,Patients_AGN__c,PersonBirthdate_AGN__c,Person_Title_AGN__c,Phone_2_AGN__c,
            Phone_AGN__c,Phone_Internal_AGN__c,Physician_Registration_Reference_AGN__c,Potential_AGN__c,Potential_IMS_AGN__c,Parent_DCR_ID_AGN__c,Primary_Affiliation_AGN__c,
            Primary_Business_Accnt_AGN__c,Primary_Business_Account_AGN__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Provisional_Contact_AGN__c,P_Account_Address_Id__c,
            P_Business_Account_Id_AGN__c,P_Child_Account_Id_AGN__c,P_Person_Account_Id_AGN__c,Receptionist_Email_AGN__c,Receptionist_Name_AGN__c,RecordTypeId,
            Requestor_Comment_AGN__c,Request_Entity_AGN__c,Request_Reason_AGN__c,Request_Status_AGN__c,Request_Type_AGN__c,Resp_ArrivedDate__c,Role_AGN__c,Salutation_AGN__c,
            Segment_AGN__c,Segment_IMS_AGN__c,Shipping_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Specialty_Allergan_1_AGN__c,State_AGN__c,Sub_Specialty_Allergan_AGN__c,
            SystemModstamp,TAAF_AGN__c,Target_AGN__c,Type_AGN__c,Type_of_Update_AGN__c,Website_AGN__c,Workplace_AGN__c,Work_Status_AGN__c,Zip_AGN__c,Address_Whanin_AGN__c,
            Avocis_date_AGN__c,Avocis_placed_AGN__c,IS_Rank_AGN__c,IS_Type_AGN__c,Owner_AGN__c,Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,Partner_Rep_Name_AGN__c,
            Partner_Team_Name_AGN__c,Sales_Credit_Limit_AGN__c,Target_Whanin_AGN__c,Customer_Consent_AGN__c,Position_at_Primary_Institution_AGN__c,Is_Child_DCR_AGN__c,
            Organization_Registration_Reference_AGN__c,Influential_profile_AGN__c,Distribution_ID_AGN__c,
            Error_Log_AGN__c 
            FROM DCR_AGN__c where id =:cr.Id];
         
        if(cDCRrec.size() > 0)
        {
            list<DCR_AGN__c>  parentdcr= new list<DCR_AGN__c>([select id,P_Business_Account_Id_AGN__c,Request_Status_AGN__c from DCR_AGN__c where id=:cDCRrec[0].Parent_DCR_ID_AGN__c]); 
            String pid=''; 
            String accClusterCode;
            pid=[select Id from Country_vod__c where Alpha_2_Code_vod__c = :cDCRrec[0].Country_Code_AGN__c].Id;
            Map<string,string> accRTMap = loadAccountRecordType();
            List<Account> accProvHCP = new List<Account>();
            List<Account> accProvHCO = new List<Account>();
            for(DCR_AGN__c dcr : cDCRrec)
            {
                if (dcr.Request_Entity_AGN__c == HCP && dcr.Request_Type_AGN__c == 'Add')
                {
                    Account accP = new Account();
                    accP.Salutation = dcr.Salutation_AGN__c;
                    accP.Status_AGN__c = AccountStatus;
                    system.debug('4-------accRTMap.get(dcr.Account_Type_AGN__c)--->'+dcr.Account_Type_AGN__c);
                    accP.RecordTypeId = accRTMap.get(dcr.Account_Type_AGN__c);
                    //if(dcr.Auto_Approved_AGN__c == false)
                      // accP.Primary_Parent_vod__c = dcr.Account_AGN__c;
                    accP.FirstName= dcr.FirstName_AGN__c;
                    accP.LastName= dcr.Last_Name_AGN__c;
                    accP.AGN_DCR_Ref__c = dcr.Name;
                    // accP.TAAF_AGN__c=dcr.TAAF_AGN__c;
                    accP.Middle_vod__c = dcr.Middle_Name_AGN__c;
                    accP.Type_AGN__c = dcr.Type_AGN__c ;
                    accP.Privacy_AGN__c = dcr.Privacy_AGN__c ;
                    accP.Privacy_law_status_AGN__c = dcr.Privacy_law_status_AGN__c ;
                    accP.Gender_vod__c = dcr.Gender_AGN__c ;
                    accP.Specialty_1_AGN__c = dcr.Specialty_1_AGN__c ;
                    accP.Education_Speciality_AGN__c = dcr.Education_Speciality_AGN__c ;
                    accP.Specialty_2_AGN__c = dcr.Specialty_2_AGN__c ;
                    accP.Specialty_Allergan_1_AGN__c = dcr.Specialty_Allergan_1_AGN__c ;
                    accP.Sub_Specialty_Allergan_AGN__c = dcr.Sub_Specialty_Allergan_AGN__c ;
                    accP.Additional_Specialties_AGN__c = dcr.Additional_Specialties_AGN__c ;
                    //accP.Country_Code__c = dcr.Country_Code_AGN__c;
                    // Manoj REQ 1026 R008.1
                    User loggedinUser = [SELECT Cluster_User_AGN__c FROM user WHERE id = :dcr.CreatedById];
                    if(loggedinUser.Cluster_User_AGN__c) {
                        accClusterCode = [Select Cluster_Country_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =: dcr.Country_Code_AGN__c].Cluster_Country_AGN__c ;
                        accP.Country_Code__c = accClusterCode;
                    }
                    else
                    {
                         accP.Country_Code__c = dcr.Country_Code_AGN__c;
                    }
                    // END : Manoj REQ 1026 R008.1
                    accP.Country_vod__c = pid;
                    accP.PersonEmail = dcr.Email_AGN__c ;
                    accP.Consent_to_Email_AGN__c = dcr.Consent_to_Email_AGN__c ;
                    accP.Fax = dcr.Fax_AGN__c ;
                    accP.PersonEmail = dcr.Email_AGN__c;
                    accP.Consent_to_Mail_AGN__c = dcr.Consent_to_Mail_AGN__c ;
                    accP.PersonMobilePhone = dcr.Mobile_AGN__c ;
                    accP.Consent_to_Phone_AGN__c = dcr.Consent_to_Phone_AGN__c ;
                    accP.Workplace_AGN__c = dcr.Workplace_AGN__c ;
                    accP.KOL_vod__c = dcr.KOL_AGN__c ;
                    accP.Do_not_Phone_Call_AGN__c = dcr.Do_not_Phone_Call_AGN__c ;
                    accP.Do_not_send_Fax_AGN__c = dcr.Do_not_send_Fax_AGN__c ;
                    accP.Do_not_send_Mail__c = dcr.Do_not_send_Mail_AGN__c ;
                    accP.Other_title_information_AGN__c = dcr.JobTitle_AGN__c ;
                    accP.AGN_DCR_Ref__c = dcr.Name;
                    //R003
                   
                    accP.Target__c = dcr.Target_AGN__c;
                    accP.Language_vod__c = dcr.Language_AGN__c;
                    accP.Do_not_Visit_AGN__c = true;
                    accP.Consent_to_Contact_AGN__c = dcr.Consent_to_Contact_AGN__c;
                    //R005
                    accP.PersonBirthdate = dcr.PersonBirthdate_AGN__c;
                    accP.Graduation_School_AGN__c = dcr.Graduation_School_AGN__c;
                    accP.Graduation_Year_AGN__c = dcr.Graduation_Year_AGN__c;
                    accP.Phone_Internal_AGN__c = dcr.Phone_Internal_AGN__c;
                    accP.Email_Internal_AGN__c = dcr.Email_Internal_AGN__c;
                    accP.Fax_Internal_AGN__c = dcr.Fax_Internal_AGN__c;
                    accP.Calling_Name_AGN__c = dcr.Calling_Name_AGN__c;
                    accP.Other_Name_AGN__c = dcr.Other_Name_AGN__c;
                    accP.Description = dcr.Description_AGN__c;
                    accP.NS_Headache_Target_Centre_AGN__c = dcr.NS_Headache_Target_Centre_AGN__c;
                    //R006
                    accP.No_Orders_vod__c = dcr.No_Orders_AGN__c;
                    accP.Order_Type_vod__c = dcr.Order_Type_AGN__c;
                    accP.Default_Order_Type_vod__c = dcr.Default_Order_Type_AGN__c;
                    //R007
                    accP.Distribution_ID_AGN__c = dcr.Distribution_ID_AGN__c;
                    accP.External_ID2_AGN__c = dcr.DCR_External_ID2_AGN__c;
                    accP.External_ID4_AGN__c =  dcr.DCR_External_ID4_AGN__c;
                    accP.Physician_Registration_Reference_AGN__c = dcr.Physician_Registration_Reference_AGN__c;
                    //r008
                    accP.Avocis_date_AGN__c=dcr.Avocis_date_AGN__c;
                    accP.Avocis_placed_AGN__c =  dcr.Avocis_placed_AGN__c;
                    accP.Owner_AGN__c= dcr.Owner_AGN__c;
                    accP.Customer_Consent_AGN__c=dcr.Customer_Consent_AGN__c; 
                    accP.Position_at_Primary_Institution_AGN__c=dcr.Position_at_Primary_Institution_AGN__c;
                    accP.Influential_profile_AGN__c=dcr.Influential_profile_AGN__c;
                    accP.Website = dcr.Website_AGN__c;
                    //end_r008
                    accProvHCP.add(accP);           
                    //R008.1 - Duplicate Ext ID
                    Database.SaveResult sr2;
                    try{
                         sr2 = Database.insert(accProvHCP[0]);
                    }
                    catch(System.Exception exp){
                        // check if error is due to Duplicate ID
                        String err_msg = null;
                        if (exp.getMessage().contains('DUPLICATE_VALUE')){
                            if (exp.getMessage().contains('External_ID4'))
                                err_msg = System.Label.DCR_Duplicate_ID_4;
                                //'EXCEPTION: Account creation failed. DUPLICATE VALUE on External ID4.'
                            else if (exp.getMessage().contains('External_ID2'))
                                err_msg = System.Label.DCR_Duplicate_ID_2;
                                //'EXCEPTION: Account creation failed. DUPLICATE VALUE on External ID2.'
                        }
                        else{
                            err_msg = System.Label.DCR_Account_Creation_Error + exp.getMessage();
                            //'EXCEPTION: Error during Account creation.'
                        }   
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, err_msg));    
                        
                        // stamp CR status back to Submitted in case of Account creation failure.
                        try{
                            dcr.Request_Status_AGN__c ='Submitted';
                            dcr.Error_Log_AGN__c = err_msg;
                            system.debug('===== Account creation failed ====='+sr2);
                            update dcr;
                        }
                        catch(Exception ex){
                             system.debug('EXCEPTION during update DCR status on Account creation failure: '+ ex );
                        }
                    }
                    //R008.1 - Duplicate Ext ID
                    if(sr2 != null) 
                    {
                        //Start - DCR reverse stamping
                        dcr.P_Person_Account_Id_AGN__c = sr2.Id;
                        update dcr;
                        //End - DCR reverse stamping
                        createChildAff(dcr); 
                        insertProductMetrics(dcr.Id,sr2.Id); 
                        if (dcr.ITA_AGN__c == true || dcr.TAAF_AGN__c == true)
                        {    
                            createImmediateTerritoryAlignmentCDCR(dcr.Id,sr2.Id);
                        }
                     }
                }
            
                
                if (dcr.Request_Entity_AGN__c == 'HCO' && dcr.Request_Type_AGN__c == 'Add')
                { 
                    Account accP = new Account();
                    accP.RecordTypeId = accRTMap.get(dcr.Account_Type_AGN__c);
                    accP.Name = dcr.Account_Name_AGN__c;
                    accP.Status_AGN__c = AccountStatus;
                    accP.AGN_DCR_Ref__c = dcr.Name;
                    if(dcr.Auto_Approved_AGN__c == false)
                       accP.Primary_Parent_vod__c = dcr.Account_AGN__c;
                    accP.Type_AGN__c = dcr.Type_AGN__c ;
                    //accP.Primary_Parent_vod__c = dcr.Primary_Business_Accnt_AGN__c;
                    accP.Privacy_AGN__c = dcr.Privacy_AGN__c ;
                    accP.Privacy_law_status_AGN__c = dcr.Privacy_law_status_AGN__c ;
                    accP.Specialty_1_AGN__c = dcr.Specialty_1_AGN__c ;
                    accP.Education_Speciality_AGN__c = dcr.Education_Speciality_AGN__c ;
                    accP.Specialty_2_AGN__c = dcr.Specialty_2_AGN__c ;
                    accP.Specialty_Allergan_1_AGN__c = dcr.Specialty_Allergan_1_AGN__c ;
                    accP.Sub_Specialty_Allergan_AGN__c = dcr.Sub_Specialty_Allergan_AGN__c ;
                    accP.Additional_Specialties_AGN__c = dcr.Additional_Specialties_AGN__c ;
                    //accP.Country_Code__c = dcr.Country_Code_AGN__c;
                    // Manoj REQ 1026 R008.1
                    User loggedinUser = [SELECT Cluster_User_AGN__c FROM user WHERE id = :dcr.CreatedById];
                    if(loggedinUser.Cluster_User_AGN__c) {
                        accClusterCode = [Select Cluster_Country_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =: dcr.Country_Code_AGN__c].Cluster_Country_AGN__c ;
                        accP.Country_Code__c = accClusterCode;
                    }
                    else
                    {
                         accP.Country_Code__c = dcr.Country_Code_AGN__c;
                    }
                    // END : Manoj REQ 1026 R008.1
                    accP.Country_vod__c = pid;
                    accP.PersonEmail = dcr.Email_AGN__c ;
                    accP.Fax = dcr.Fax_AGN__c ;
                    accP.Website = dcr.Website_AGN__c;
                    accP.Phone = dcr.Account_Phone_AGN__c;
                    accP.Consent_to_Email_AGN__c = dcr.Consent_to_Email_AGN__c ;
                    accP.Consent_to_Mail_AGN__c = dcr.Consent_to_Mail_AGN__c ;
                    accP.PersonMobilePhone = dcr.Mobile_AGN__c ;
                    accP.Consent_to_Phone_AGN__c = dcr.Consent_to_Phone_AGN__c ;
                    accP.Workplace_AGN__c = dcr.Workplace_AGN__c;
                    accP.Do_not_Phone_Call_AGN__c = dcr.Do_not_Phone_Call_AGN__c ;
                    accP.Do_not_send_Fax_AGN__c = dcr.Do_not_send_Fax_AGN__c ;
                    accP.Other_title_information_AGN__c = dcr.JobTitle_AGN__c ;
                    accP.Do_not_send_Mail__c = dcr.Do_not_send_Mail_AGN__c ;
                    accP.Beds__c = dcr.Beds_AGN__c;
                    accP.Departments__c =dcr.Departments_AGN__c;
                    accP.AGN_DCR_Ref__c = dcr.Name; 
                    accP.Organization_Registration_Reference_AGN__c = dcr.Organization_Registration_Reference_AGN__c; 
                    //R003
                    accP.Status_AGN__c = AccountStatus;
                    accP.Target__c = dcr.Target_AGN__c;
                    accP.Language_vod__c = dcr.Language_AGN__c;
                    accP.Do_not_Visit_AGN__c = true; 
                    accP.Consent_to_Contact_AGN__c = dcr.Consent_to_Contact_AGN__c;             
                    //R005
                    accP.Patients_AGN__c = dcr.Patients_AGN__c;
                    accP.Account_Group_vod__c = dcr.Account_Group_AGN__c;
                    accP.Institution_Site_AGN__c = dcr.Institution_Site_AGN__c;
                    accP.Phone_Internal_AGN__c = dcr.Phone_Internal_AGN__c;
                    accP.Email_Internal_AGN__c = dcr.Email_Internal_AGN__c;
                    accP.Fax_Internal_AGN__c = dcr.Fax_Internal_AGN__c;
                    accP.Calling_Name_AGN__c = dcr.Calling_Name_AGN__c;
                    accP.Other_Name_AGN__c = dcr.Other_Name_AGN__c;
                    accP.Description = dcr.Description_AGN__c;
                    accP.NS_Headache_Target_Centre_AGN__c = dcr.NS_Headache_Target_Centre_AGN__c;
                    //R007
                    //accP.External_ID_vod__c = dcr.DCR_External_ID1_AGN__c;
                    accP.External_ID2_AGN__c = dcr.DCR_External_ID2_AGN__c;
                    accP.External_ID4_AGN__c =  dcr.DCR_External_ID4_AGN__c;
                    accP.Physician_Registration_Reference_AGN__c = dcr.Physician_Registration_Reference_AGN__c; 
                    //r008
                    accP.Address_AGN__c=dcr.Address_Whanin_AGN__c;
                    accP.Avocis_date_AGN__c=dcr.Avocis_date_AGN__c;
                    accP.Avocis_placed_AGN__c =  dcr.Avocis_placed_AGN__c;
                    accP.IS_Rank_AGN__c=dcr.IS_Rank_AGN__c ;
                    accP.IS_Type_AGN__c= dcr.IS_Type_AGN__c ;
                    accP.Owner_AGN__c= dcr.Owner_AGN__c;
                    accP.Partner_Email_AGN__c= dcr.Partner_Email_AGN__c ;
                    accP.Partner_Emp_Code_AGN__c=  dcr.Partner_Emp_Code_AGN__c;
                    accP.Partner_Rep_Name_AGN__c= dcr.Partner_Rep_Name_AGN__c;
                    accP.Partner_Team_Name_AGN__c= dcr.Partner_Team_Name_AGN__c ;
                    accP.Sales_Credit_Limit_AGN__c=  dcr.Sales_Credit_Limit_AGN__c ;
                    accP.Target_AGN__c=dcr.Target_Whanin_AGN__c ;  
                    //end_r008
                    accP.Distribution_ID_AGN__c=dcr.Distribution_ID_AGN__c ; 
                    accProvHCO.add(accP);
                    //R008.1 - Duplicate Ext ID
                    Database.SaveResult sr1;
                    try{
                         sr1 = Database.insert(accProvHCO[0]);
                    }
                    catch(System.Exception exp){
                        // check if error is due to Duplicate ID
                        String err_msg = null;
                        if (exp.getMessage().contains('DUPLICATE_VALUE')){
                            if (exp.getMessage().contains('External_ID4'))
                                err_msg = System.Label.DCR_Duplicate_ID_4;
                                //'EXCEPTION: Account creation failed. DUPLICATE VALUE on External ID4.'
                            else if (exp.getMessage().contains('External_ID2'))
                                err_msg = System.Label.DCR_Duplicate_ID_2;
                                //'EXCEPTION: Account creation failed. DUPLICATE VALUE on External ID2.'
                        }
                        else{
                            err_msg = System.Label.DCR_Account_Creation_Error + exp.getMessage();
                            //'EXCEPTION: Error during Account creation.'
                        }   
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, err_msg));    
                        
                        // stamp CR status back to Submitted in case of Account creation failure.
                        try{
                            dcr.Request_Status_AGN__c ='Submitted';
                            dcr.Error_Log_AGN__c = err_msg;
                            system.debug('===== Account creation failed ====='+sr1);
                            update dcr;
                        }
                        catch(Exception ex){
                             system.debug('EXCEPTION during update DCR status on Account creation failure: '+ ex );
                        }
                    }
                    //R008.1 - Duplicate Ext ID
                    if(sr1 != null) 
                    {
                        Address_vod__c addr = new Address_vod__c();
                        addr.Account_vod__c = sr1.Id;
                        addr.address_type_vod__c=dcr.Address_Type_AGN__c;
                        addr.Address_line_2_vod__c=dcr.Address_Line_2_AGN__c;
                        addr.Address_Line_3_AGN__c=dcr.Address_Line_3_AGN__c;
                        addr.Name=dcr.Address_Line_1_AGN__c;
                        addr.Billing_vod__c=dcr.Billing_AGN__c;
                        addr.Brick_vod__c=dcr.Brick_AGN__c;
                        addr.Business_vod__c=dcr.Business_AGN__c;
                        addr.City_vod__c=dcr.City_AGN__c;
                        addr.Home_vod__c=dcr.Home_AGN__c;
                        addr.Country_vod__c=dcr.Country_AGN__c;
                        addr.Shipping_vod__c=dcr.Shipping_AGN__c; 
                        addr.Mailing_vod__c=dcr.Mailing_AGN__c;
                        addr.State_vod__c=dcr.State_AGN__c;
                        addr.Fax_vod__c=dcr.Address_Fax_AGN__c;
                        addr.Appt_Required_vod__c=dcr.Appt_Required_AGN__c;
                        addr.Receptionist_Name_AGN__c=dcr.Receptionist_Name_AGN__c;
                        addr.Receptionist_Email_AGN__c=dcr.Receptionist_Email_AGN__c;
                        addr.Phone_vod__c=dcr.Phone_AGN__c;
                        addr.Phone_2_vod__c=dcr.Phone_2_AGN__c;
                        addr.Zip_vod__c=dcr.Zip_AGN__c;
                        addr.Primary_vod__c = true;
                        //insert addr;
                        Database.SaveResult srAdd = Database.insert(addr);
                        if(srAdd.isSuccess())
                        {
                            //Start - DCR reverse stamping
                            dcr.P_Business_Account_Id_AGN__c = sr1.Id;
                            dcr.P_Account_Address_Id__c = srAdd.Id;
                            update dcr;
                            //End - DCR reverse stamping
                        }
                        createChildAff(dcr); 
                        if (dcr.ITA_AGN__c == true || dcr.TAAF_AGN__c == true)
                        {
                            createImmediateTerritoryAlignmentCDCR(dcr.Id,sr1.Id);
                        }
                    }
                }
            
            
              
                //existing HCP
                if (dcr.Request_Entity_AGN__c == HCP && dcr.Request_Type_AGN__c == 'Change')
                {
                    //list<DCR_AGN__c> parentdcr= new list<DCR_AGN__c>([select id,P_Business_Account_Id_AGN__c,Request_Status_AGN__c from DCR_AGN__c where id=:dcr.Parent_DCR_ID_AGN__c]); 
                    Child_Account_vod__c cRec1 = new Child_Account_vod__c();
                    cRec1.Parent_Account_vod__c =parentdcr[0].P_Business_Account_Id_AGN__c;
                    cRec1.Child_Account_vod__c = dcr.Contact_AGN__c;
                    Database.SaveResult sr3 = Database.insert(cRec1);
                    if(sr3.isSuccess()) 
                    {
                        DCR_AGN__c cdcr=[select id,Request_Status_AGN__c from DCR_AGN__c where id=:dcr.Id] ;
                        cdcr.P_Child_Account_Id_AGN__c=sr3.id;
                        update cdcr;
                    }
                }
                
                //existing hco
                if (dcr.Request_Entity_AGN__c == HCO && dcr.Request_Type_AGN__c == 'Change')
                {
                    system.debug('going to create child aff for exhco');
                   // list<DCR_AGN__c> parentdcr= new list<DCR_AGN__c>([select name,id,P_Business_Account_Id_AGN__c,Request_Status_AGN__c from DCR_AGN__c where id=:dcr.Parent_DCR_ID_AGN__c]);
                   // system.debug('value of parentdcr '+parentdcr);
                    Child_Account_vod__c cRec2 = new Child_Account_vod__c();
                    cRec2.Parent_Account_vod__c =parentdcr[0].P_Business_Account_Id_AGN__c;
                    cRec2.Child_Account_vod__c = dcr.Account_AGN__c;
                    system.debug('value of cRec2 '+cRec2);
                    Database.SaveResult sr4 = Database.insert(cRec2);
                    if(sr4.isSuccess()) 
                    {
                        DCR_AGN__c cdcr=[select id,Request_Status_AGN__c from DCR_AGN__c where id=:dcr.Id] ;
                        cdcr.P_Child_Account_Id_AGN__c=sr4.id;
                        update cdcr;
                    }
                }        
            }
        }      
    }
    
    // Update Existing Account based on DCR Request Type = 'Change'
    public static void updateExistingAccount(DCR_AGN__c cr,String AccountStatus, Integer identifier){
        system.debug('===== Inside [updateExistingAccount] =====');
        DCR_AGN__c newDCR = new DCR_AGN__c();
        Map<string,string> accRTMap = loadAccountRecordType();
        List<Account> acclist = new List<Account>();
        Account acc = null;
        String accClusterCode;

    DCR_AGN__c dcr = [SELECT Accepted_AGN__c,Account_AGN__c,Account_Country_AGN__c,Account_Group_AGN__c,Account_Name_AGN__c,Account_Phone_AGN__c,
            Account_Status_AGN__c,Account_Type_AGN__c,Additional_Specialties_AGN__c,Address_AGN__c,Address_Fax_AGN__c,Address_Line_1_AGN__c,Address_Line_2_AGN__c,
            Address_Line_3_AGN__c,Address_Status__c,Address_Type_AGN__c,Adoption_AGN__c,Adoption_IMS_AGN__c,Affiliated_Account_Sub_Type__c,Affiliated_Account_Type_AGN__c,
            Approved_By_AGN__c,Approver_Comment_AGN__c,Appt_Required_AGN__c,Auto_Approved_AGN__c,Beds_AGN__c,Billing_AGN__c,Brick_AGN__c,Business_AGN__c,Calling_Name_AGN__c,
            City_AGN__c,Consent_to_Contact_AGN__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,Consent_to_Phone_AGN__c,Contact_AGN__c,Country_AGN__c,Country_Code_AGN__c,
            CreatedById,CreatedDate,CurrencyIsoCode,DCR_Approver_AGN__c,DCR_External_ID2_AGN__c,DCR_External_ID4_AGN__c,DCR_External_ID_AGN__c,Default_Order_Type_AGN__c,
            Delete_Affiliation_AGN__c,Departments_AGN__c,Description_AGN__c,Detail_Group_AGN__c,Division_AGN__c,Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,
            Do_not_send_Mail_AGN__c,Do_not_Visit_AGN__c,Education_Speciality_AGN__c,Email_AGN__c,Email_Internal_AGN__c,Employee_AGN__c,Fax_AGN__c,Fax_Internal_AGN__c,
            FirstName_AGN__c,Gender_AGN__c,Graduation_School_AGN__c,Graduation_Year_AGN__c,Has_Product_Metrics__c,HCO_HCP_Name_AGN__c,Home_AGN__c,Id,Institution_Site_AGN__c,
            IsDeleted,IsLocked,Is_Reviewed_AGN__c,ITA_AGN__c,JobTitle_AGN__c,KOL_AGN__c,Language_AGN__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastReferencedDate,
            LastViewedDate,Last_Name_AGN__c,Mailing_AGN__c,MayEdit,Medical_Affairs_AGN__c,Middle_Name_AGN__c,Migrated_to_DP_AGN__c,Mobile_AGN__c,Name,No_Orders_AGN__c,
            NS_Headache_Target_Centre_AGN__c,Order_Type_AGN__c,Other_Name_AGN__c,OwnerId,Patients_AGN__c,PersonBirthdate_AGN__c,Person_Title_AGN__c,Phone_2_AGN__c,
            Phone_AGN__c,Phone_Internal_AGN__c,Physician_Registration_Reference_AGN__c,Potential_AGN__c,Potential_IMS_AGN__c,Parent_DCR_ID_AGN__c,Primary_Affiliation_AGN__c,
            Primary_Business_Accnt_AGN__c,Primary_Business_Account_AGN__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Provisional_Contact_AGN__c,P_Account_Address_Id__c,
            P_Business_Account_Id_AGN__c,P_Child_Account_Id_AGN__c,P_Person_Account_Id_AGN__c,Receptionist_Email_AGN__c,Receptionist_Name_AGN__c,RecordTypeId,
            Requestor_Comment_AGN__c,Request_Entity_AGN__c,Request_Reason_AGN__c,Request_Status_AGN__c,Request_Type_AGN__c,Resp_ArrivedDate__c,Role_AGN__c,Salutation_AGN__c,
            Segment_AGN__c,Segment_IMS_AGN__c,Shipping_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Specialty_Allergan_1_AGN__c,State_AGN__c,Sub_Specialty_Allergan_AGN__c,
            SystemModstamp,TAAF_AGN__c,Target_AGN__c,Type_AGN__c,Type_of_Update_AGN__c,Website_AGN__c,Workplace_AGN__c,Work_Status_AGN__c,Zip_AGN__c,Address_Whanin_AGN__c,
            Avocis_date_AGN__c,Avocis_placed_AGN__c,IS_Rank_AGN__c,IS_Type_AGN__c,Owner_AGN__c,Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,Partner_Rep_Name_AGN__c,
            Partner_Team_Name_AGN__c,Sales_Credit_Limit_AGN__c,Target_Whanin_AGN__c,Customer_Consent_AGN__c,Position_at_Primary_Institution_AGN__c,Is_Child_DCR_AGN__c,
            Organization_Registration_Reference_AGN__c,Influential_profile_AGN__c,Distribution_ID_AGN__c,Allergan_Account_Group_AGN__c,
            Error_Log_AGN__c
            FROM DCR_AGN__c where id =:cr.Id];

        // for Accept/Reject
        system.debug('===== Before [identifier == 1] =====');
        if (identifier == 1){
            if (dcr.Request_Entity_AGN__c == HCO)
            {
                for (Account ac : [select Id,Name, Primary_Parent_vod__c,Country_Code__c, Country_vod__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Education_Speciality_AGN__c,
                                   PersonEmail,Fax,PersonMobilePhone,Status_AGN__c,Do_not_Visit_AGN__c,Language_vod__c,Target__c,Workplace_AGN__c,Consent_to_Email_AGN__c,
                                   Consent_to_Mail_AGN__c,Consent_to_Phone_AGN__c,Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,Do_not_send_Mail__c,Type_AGN__c,
                                   Specialty_1_AGN__c,Specialty_2_AGN__c,Specialty_Allergan_1_AGN__c,Sub_Specialty_Allergan_AGN__c, Additional_Specialties_AGN__c,
                                   AGN_DCR_Ref__c, Requested_from_DCR_AGN__c,Consent_to_Contact_AGN__c,Patients_AGN__c,Account_Group_vod__c,Institution_Site_AGN__c,
                                   Phone_Internal_AGN__c,Email_Internal_AGN__c,Fax_Internal_AGN__c,Calling_Name_AGN__c,Other_Name_AGN__c,Description,
                                   NS_Headache_Target_Centre_AGN__c,Organization_Registration_Reference_AGN__c,Account_Group_AGN__c,Website,Address_AGN__c,
                                   Avocis_date_AGN__c,Avocis_placed_AGN__c,Customer_Consent_AGN__c,IS_Rank_AGN__c,IS_Type_AGN__c,Owner_AGN__c,Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,
                                   Partner_Rep_Name_AGN__c,Partner_Team_Name_AGN__c,Position_at_Primary_Institution_AGN__c,Sales_Credit_Limit_AGN__c,Target_AGN__c
                                   from Account where id =:dcr.Account_AGN__c limit 1])
                {                  
                    acclist.add(ac);
                }
                
            }
            else
            {
                for (Account ac : [select Id,Country_Code__c, Country_vod__c,Primary_Parent_vod__c, FirstName,Middle_vod__c,LastName,Salutation, Gender_vod__c,Status_AGN__c,
                                   Do_not_Visit_AGN__c, Language_vod__c, Target__c,Consent_to_Contact_AGN__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Education_Speciality_AGN__c,
                                   PersonEmail, Fax,  PersonMobilePhone,Workplace_AGN__c, KOL_vod__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,Consent_to_Phone_AGN__c,
                                   Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,Do_not_send_Mail__c,Type_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Specialty_Allergan_1_AGN__c,
                                   Sub_Specialty_Allergan_AGN__c, Additional_Specialties_AGN__c, AGN_DCR_Ref__c, Requested_from_DCR_AGN__c,PersonBirthdate,Graduation_School_AGN__c,
                                   Graduation_Year_AGN__c,Other_title_information_AGN__c,Phone_Internal_AGN__c,Email_Internal_AGN__c,Fax_Internal_AGN__c,Calling_Name_AGN__c,
                                   Other_Name_AGN__c,Description,NS_Headache_Target_Centre_AGN__c,Distribution_ID_AGN__c,External_ID2_AGN__c,External_ID4_AGN__c,
                                   Physician_Registration_Reference_AGN__c,Website,Address_AGN__c,Avocis_date_AGN__c,Avocis_placed_AGN__c,Customer_Consent_AGN__c,IS_Rank_AGN__c,
                                   IS_Type_AGN__c,Owner_AGN__c,Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,Partner_Rep_Name_AGN__c,Partner_Team_Name_AGN__c,
                                   Position_at_Primary_Institution_AGN__c,Sales_Credit_Limit_AGN__c,Target_AGN__c
                                   from Account where id =:dcr.Contact_AGN__c limit 1])
                    
                {
                    acclist.add(ac);
                }
            } 
        }
        // for send back for revision
        system.debug('===== Before [identifier == 2] =====');
        if (identifier == 2){
            if (dcr.Request_Entity_AGN__c == HCO)
            {
                system.debug('===== Inside [identifier = 2][HCO] =====');
                for (Account ac : [select Id,Name, Primary_Parent_vod__c,Country_Code__c, Country_vod__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Education_Speciality_AGN__c,
                                   PersonEmail,Fax,PersonMobilePhone,Status_AGN__c,Do_not_Visit_AGN__c,Language_vod__c,Target__c,Workplace_AGN__c,Consent_to_Email_AGN__c,
                                   Consent_to_Mail_AGN__c,Consent_to_Phone_AGN__c,Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,Do_not_send_Mail__c,Type_AGN__c,
                                   Specialty_1_AGN__c,Specialty_2_AGN__c,Specialty_Allergan_1_AGN__c,Sub_Specialty_Allergan_AGN__c, Additional_Specialties_AGN__c,
                                   AGN_DCR_Ref__c, Requested_from_DCR_AGN__c,Consent_to_Contact_AGN__c,Patients_AGN__c,Account_Group_vod__c,Institution_Site_AGN__c,
                                   Phone_Internal_AGN__c,Email_Internal_AGN__c,Fax_Internal_AGN__c,Calling_Name_AGN__c,Other_Name_AGN__c,Description,
                                   NS_Headache_Target_Centre_AGN__c,Organization_Registration_Reference_AGN__c,Account_Group_AGN__c,Website,Address_AGN__c,
                                   Avocis_date_AGN__c,Avocis_placed_AGN__c,Customer_Consent_AGN__c,IS_Rank_AGN__c,IS_Type_AGN__c,Owner_AGN__c,Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,
                                   Partner_Rep_Name_AGN__c,Partner_Team_Name_AGN__c,Position_at_Primary_Institution_AGN__c,Sales_Credit_Limit_AGN__c,Target_AGN__c
                                   from Account where id =:dcr.P_Business_Account_Id_AGN__c limit 1])
                {                  
                    acclist.add(ac);
                }         
            }
            else
            {
                system.debug('===== Inside [identifier = 2][HCP] =====');
                for (Account ac : [select Id,Country_Code__c, Country_vod__c,Primary_Parent_vod__c, FirstName,Middle_vod__c,LastName,Salutation, Gender_vod__c,Status_AGN__c,
                                   Do_not_Visit_AGN__c, Language_vod__c, Target__c,Consent_to_Contact_AGN__c,Privacy_AGN__c,Privacy_law_status_AGN__c,Education_Speciality_AGN__c,
                                   PersonEmail, Fax,  PersonMobilePhone,Workplace_AGN__c, KOL_vod__c,Consent_to_Email_AGN__c,Consent_to_Mail_AGN__c,Consent_to_Phone_AGN__c,
                                   Do_not_Phone_Call_AGN__c,Do_not_send_Fax_AGN__c,Do_not_send_Mail__c,Type_AGN__c,Specialty_1_AGN__c,Specialty_2_AGN__c,Specialty_Allergan_1_AGN__c,
                                   Sub_Specialty_Allergan_AGN__c, Additional_Specialties_AGN__c, AGN_DCR_Ref__c, Requested_from_DCR_AGN__c,PersonBirthdate,Graduation_School_AGN__c,
                                   Graduation_Year_AGN__c,Other_title_information_AGN__c,Phone_Internal_AGN__c,Email_Internal_AGN__c,Fax_Internal_AGN__c,Calling_Name_AGN__c,Other_Name_AGN__c,
                                   Description,NS_Headache_Target_Centre_AGN__c,Distribution_ID_AGN__c,External_ID2_AGN__c,External_ID4_AGN__c,Physician_Registration_Reference_AGN__c,Website,Address_AGN__c,
                                   Avocis_date_AGN__c,Avocis_placed_AGN__c,Customer_Consent_AGN__c,IS_Rank_AGN__c,IS_Type_AGN__c,Owner_AGN__c,Partner_Email_AGN__c,Partner_Emp_Code_AGN__c,
                                   Partner_Rep_Name_AGN__c,Partner_Team_Name_AGN__c,Position_at_Primary_Institution_AGN__c,Sales_Credit_Limit_AGN__c,Target_AGN__c
                                   from Account where id =:dcr.P_Person_Account_Id_AGN__c limit 1])
                    
                {
                    acclist.add(ac);
                }
            } 
        }
        system.debug('===== After [identifier = 2] ===== acclist ==>>' + acclist);
        if (dcr.Request_Entity_AGN__c == HCO)
        {  
            acc = acclist[0];
            acc.Name = dcr.Account_Name_AGN__c; 
            acc.Type_AGN__c = dcr.Type_AGN__c ;
            acc.Privacy_AGN__c = dcr.Privacy_AGN__c;
            //acc.Middle_vod__c = dcr.Middle_Name_AGN__c;
            acc.Privacy_law_status_AGN__c = dcr.Privacy_law_status_AGN__c;
            acc.Primary_Parent_vod__c = dcr.Primary_Business_Accnt_AGN__c;
            //acc.Gender_vod__c = dcr.Gender_AGN__c ;
            acc.Specialty_1_AGN__c = dcr.Specialty_1_AGN__c ;
            acc.Education_Speciality_AGN__c = dcr.Education_Speciality_AGN__c ;
            acc.Specialty_2_AGN__c = dcr.Specialty_2_AGN__c ;
            acc.Specialty_Allergan_1_AGN__c = dcr.Specialty_Allergan_1_AGN__c ;
            acc.Sub_Specialty_Allergan_AGN__c = dcr.Sub_Specialty_Allergan_AGN__c ;
            acc.Additional_Specialties_AGN__c = dcr.Additional_Specialties_AGN__c ;
            acc.Fax = dcr.Fax_AGN__c;
            acc.Website = dcr.Website_AGN__c ;
            acc.Phone = dcr.Account_Phone_AGN__c;
            acc.Consent_to_Email_AGN__c = dcr.Consent_to_Email_AGN__c ;    
            acc.Consent_to_Mail_AGN__c = dcr.Consent_to_Mail_AGN__c ;
            acc.Consent_to_Phone_AGN__c = dcr.Consent_to_Phone_AGN__c ;
            acc.Workplace_AGN__c = dcr.Workplace_AGN__c ;
            acc.Do_not_Phone_Call_AGN__c = dcr.Do_not_Phone_Call_AGN__c ;
            acc.Do_not_send_Fax_AGN__c = dcr.Do_not_send_Fax_AGN__c ;
            acc.Do_not_send_Mail__c    = dcr.Do_not_send_Mail_AGN__c ; 
            acc.Beds__c    = dcr.Beds_AGN__c ; 
            acc.Other_title_information_AGN__c = dcr.JobTitle_AGN__c ;
            //acc.AGN_DCR_Ref__c = dcr.Name;
            acc.Requested_from_DCR_AGN__c = TRUE;
            //R003
            if (identifier == 2)
                acc.Status_AGN__c = AccountStatus;
            else
                acc.Status_AGN__c = dcr.Account_Status_AGN__c;
            acc.Target__c = dcr.Target_AGN__c;
            acc.Language_vod__c = dcr.Language_AGN__c;
            if (AccountStatus == 'Inactive'){
                system.debug('1------------------>'+AccountStatus);
                acc.Consent_to_Contact_AGN__c = false;
                acc.Do_not_Visit_AGN__c = true;
            }
            else{
                system.debug('2------------------>'+AccountStatus);
                acc.Do_not_Visit_AGN__c = dcr.Do_not_Visit_AGN__c; 
                acc.Consent_to_Contact_AGN__c = dcr.Consent_to_Contact_AGN__c;
            }
            //R005
            acc.Patients_AGN__c = dcr.Patients_AGN__c;
            acc.Account_Group_vod__c = dcr.Account_Group_AGN__c;
            acc.Institution_Site_AGN__c = dcr.Institution_Site_AGN__c;
            acc.Phone_Internal_AGN__c = dcr.Phone_Internal_AGN__c;
            acc.Email_Internal_AGN__c = dcr.Email_Internal_AGN__c;
            acc.Fax_Internal_AGN__c = dcr.Fax_Internal_AGN__c;
            acc.Calling_Name_AGN__c = dcr.Calling_Name_AGN__c;
            acc.Other_Name_AGN__c = dcr.Other_Name_AGN__c;
            acc.Description = dcr.Description_AGN__c;
            acc.NS_Headache_Target_Centre_AGN__c = dcr.NS_Headache_Target_Centre_AGN__c;
            //R007
            // Manoj REQ 1026 R008.1
            User loggedinUser = [SELECT Cluster_User_AGN__c FROM user WHERE id = :dcr.CreatedById];
            if(loggedinUser.Cluster_User_AGN__c) {
                accClusterCode = [Select Cluster_Country_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =: dcr.Country_Code_AGN__c].Cluster_Country_AGN__c ;
                acc.Country_Code__c = accClusterCode;
            }
            else
            {
                 acc.Country_Code__c = dcr.Country_Code_AGN__c;
            }
            // END : Manoj REQ 1026 R008.1
            acc.Country_vod__c = [select Id from Country_vod__c where Alpha_2_Code_vod__c = :dcr.Country_Code_AGN__c].Id;
            acc.Distribution_ID_AGN__c = dcr.Distribution_ID_AGN__c;
            acc.External_ID2_AGN__c = dcr.DCR_External_ID2_AGN__c;
            acc.External_ID4_AGN__c =  dcr.DCR_External_ID4_AGN__c;
            acc.Physician_Registration_Reference_AGN__c = dcr.Physician_Registration_Reference_AGN__c;
            //R007.1
            acc.Organization_Registration_Reference_AGN__c = dcr.Organization_Registration_Reference_AGN__c;
            acc.Account_Group_AGN__c = dcr.Allergan_Account_Group_AGN__c;
              //<--------------Modified by Manoj Paul For Release 008 Requirement# 918 : Added field to the query. Mapping of Newly Added fields into DRC to Account--------->
            acc.Address_AGN__c = dcr.Address_Whanin_AGN__c;
            acc.Avocis_date_AGN__c = dcr.Avocis_date_AGN__c;
            acc.Avocis_placed_AGN__c = dcr.Avocis_placed_AGN__c ; 
            acc.IS_Rank_AGN__c = dcr.IS_Rank_AGN__c; 
            acc.IS_Type_AGN__c = dcr.IS_Type_AGN__c; 
            acc.Owner_AGN__c = dcr.Owner_AGN__c; 
            acc.Partner_Email_AGN__c = dcr.Partner_Email_AGN__c; 
            acc.Partner_Emp_Code_AGN__c = dcr.Partner_Emp_Code_AGN__c; 
            acc.Partner_Rep_Name_AGN__c = dcr.Partner_Rep_Name_AGN__c; 
            acc.Partner_Team_Name_AGN__c = dcr.Partner_Team_Name_AGN__c; 
            acc.Sales_Credit_Limit_AGN__c = dcr.Sales_Credit_Limit_AGN__c; 
            acc.Target_AGN__c = dcr.Target_Whanin_AGN__c ;
             //<--------------End of Modification-------------------------------->
        }
        else
        {
            acc = acclist[0];
            acc.Salutation = dcr.Salutation_AGN__c;
            acc.FirstName= dcr.FirstName_AGN__c ;
            acc.LastName= dcr.Last_Name_AGN__c;
            acc.Type_AGN__c = dcr.Type_AGN__c ;
            acc.Privacy_AGN__c = dcr.Privacy_AGN__c ;
            acc.Privacy_law_status_AGN__c = dcr.Privacy_law_status_AGN__c;
            acc.Middle_vod__c = dcr.Middle_Name_AGN__c ;
            acc.Gender_vod__c = dcr.Gender_AGN__c ;
            acc.Specialty_1_AGN__c = dcr.Specialty_1_AGN__c ;
            acc.Education_Speciality_AGN__c = dcr.Education_Speciality_AGN__c ;
            acc.Specialty_2_AGN__c = dcr.Specialty_2_AGN__c ;
            acc.Specialty_Allergan_1_AGN__c = dcr.Specialty_Allergan_1_AGN__c ;
            acc.Sub_Specialty_Allergan_AGN__c = dcr.Sub_Specialty_Allergan_AGN__c ;
            acc.Additional_Specialties_AGN__c = dcr.Additional_Specialties_AGN__c ;
            acc.PersonEmail = dcr.Email_AGN__c ;
            acc.Fax = dcr.Fax_AGN__c;
            acc.Consent_to_Email_AGN__c = dcr.Consent_to_Email_AGN__c ;  
            acc.Consent_to_Mail_AGN__c = dcr.Consent_to_Mail_AGN__c ;
            acc.Consent_to_Phone_AGN__c = dcr.Consent_to_Phone_AGN__c ;
            acc.PersonMobilePhone = dcr.Mobile_AGN__c ;
            acc.Workplace_AGN__c = dcr.Workplace_AGN__c ;
            acc.KOL_vod__c = dcr.KOL_AGN__c ;
            acc.Do_not_Phone_Call_AGN__c = dcr.Do_not_Phone_Call_AGN__c ;
            acc.Do_not_send_Fax_AGN__c = dcr.Do_not_send_Fax_AGN__c ;
            acc.Do_not_send_Mail__c    = dcr.Do_not_send_Mail_AGN__c ;
            acc.Other_title_information_AGN__c = dcr.JobTitle_AGN__c;
            // acc.AGN_DCR_Ref__c = dcr.Name;
            acc.Requested_from_DCR_AGN__c = TRUE;
              //<--------------Modified by Manoj Paul For Release 008 Requirement# 918 : Added field to the query. Mapping of Newly Added fields into DRC to Account--------->
            acc.Avocis_date_AGN__c = dcr.Avocis_date_AGN__c;
            acc.Avocis_placed_AGN__c = dcr.Avocis_placed_AGN__c ; 
            acc.Owner_AGN__c = dcr.Owner_AGN__c; 
            acc.Customer_Consent_AGN__c = dcr.Customer_Consent_AGN__c;
            acc.Position_at_Primary_Institution_AGN__c = dcr.Position_at_Primary_Institution_AGN__c;
             //<--------------End of Modification-------------------------------->
            //R003
            if (identifier == 2)
                acc.Status_AGN__c = AccountStatus;
            else
                acc.Status_AGN__c = dcr.Account_Status_AGN__c;
            acc.Target__c = dcr.Target_AGN__c;
            acc.Language_vod__c = dcr.Language_AGN__c;
            if (AccountStatus == 'Inactive'){
                acc.Consent_to_Contact_AGN__c = false;
                acc.Do_not_Visit_AGN__c = true;
            }
            else{
                acc.Do_not_Visit_AGN__c = dcr.Do_not_Visit_AGN__c; 
                acc.Consent_to_Contact_AGN__c = dcr.Consent_to_Contact_AGN__c;
            }
           //R005
            acc.PersonBirthdate = dcr.PersonBirthdate_AGN__c;
            acc.Graduation_School_AGN__c = dcr.Graduation_School_AGN__c;
            acc.Graduation_Year_AGN__c = dcr.Graduation_Year_AGN__c;
            acc.Phone_Internal_AGN__c = dcr.Phone_Internal_AGN__c;
            acc.Email_Internal_AGN__c = dcr.Email_Internal_AGN__c;
            acc.Fax_Internal_AGN__c = dcr.Fax_Internal_AGN__c;
            acc.Calling_Name_AGN__c = dcr.Calling_Name_AGN__c;
            acc.Other_Name_AGN__c = dcr.Other_Name_AGN__c;
            acc.Description = dcr.Description_AGN__c;
            acc.NS_Headache_Target_Centre_AGN__c = dcr.NS_Headache_Target_Centre_AGN__c;
            //R006
            acc.No_Orders_vod__c = dcr.No_Orders_AGN__c;
            acc.Order_Type_vod__c = dcr.Order_Type_AGN__c;
            acc.Default_Order_Type_vod__c = dcr.Default_Order_Type_AGN__c;
            //R007
            // Manoj REQ 1026 R008.1
            User loggedinUser = [SELECT Cluster_User_AGN__c FROM user WHERE id = :dcr.CreatedById];
            if(loggedinUser.Cluster_User_AGN__c) {
                accClusterCode = [Select Cluster_Country_AGN__c from Country_vod__c where Alpha_2_Code_vod__c =: dcr.Country_Code_AGN__c].Cluster_Country_AGN__c ;
                acc.Country_Code__c = accClusterCode;
            }
            else
            {
                 acc.Country_Code__c = dcr.Country_Code_AGN__c;
            }
            // END : Manoj REQ 1026 R008.1
            acc.Country_vod__c = [select Id from Country_vod__c where Alpha_2_Code_vod__c = :dcr.Country_Code_AGN__c].Id;
            acc.Distribution_ID_AGN__c = dcr.Distribution_ID_AGN__c;
            acc.External_ID2_AGN__c = dcr.DCR_External_ID2_AGN__c;
            acc.External_ID4_AGN__c =  dcr.DCR_External_ID4_AGN__c;
            acc.Physician_Registration_Reference_AGN__c = dcr.Physician_Registration_Reference_AGN__c;
            //R007.1
            acc.Website = dcr.Website_AGN__c;
            //R008
            acc.Influential_profile_AGN__c = dcr.Influential_profile_AGN__c;
              //<--------------Modified by Manoj Paul For Release 008 Requirement# 918 : Added field to the query. Mapping of Newly Added fields into DRC to Account--------->
             acc.Avocis_date_AGN__c = dcr.Avocis_date_AGN__c;
            acc.Avocis_placed_AGN__c = dcr.Avocis_placed_AGN__c ; 
            acc.Owner_AGN__c = dcr.Owner_AGN__c; 
            acc.Customer_Consent_AGN__c = dcr.Customer_Consent_AGN__c;
            acc.Position_at_Primary_Institution_AGN__c = dcr.Position_at_Primary_Institution_AGN__c;
             //<--------------End of Modification-------------------------------->
            //R008.1
            acc.Phone = cr.Account_Phone_AGN__c;
        }
        //R008.1 - Duplicate Ext ID
        Database.SaveResult sr;
        try{
             sr = Database.update(acc);
        }
        catch(System.Exception exp){
            // check if error is due to Duplicate ID
            String err_msg = null;
            if (exp.getMessage().contains('DUPLICATE_VALUE')){
                if (exp.getMessage().contains('External_ID4'))
                    err_msg = System.Label.DCR_Duplicate_ID_4;
                    //'EXCEPTION: Account creation failed. DUPLICATE VALUE on External ID4.'
                else if (exp.getMessage().contains('External_ID2'))
                    err_msg = System.Label.DCR_Duplicate_ID_2;
                    //'EXCEPTION: Account creation failed. DUPLICATE VALUE on External ID2.'
            }
            else{
                err_msg = System.Label.DCR_Account_Creation_Error + exp.getMessage();
                //'EXCEPTION: Error during Account creation.'
            }   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, err_msg));    
            
            // stamp CR status back to Submitted in case of Account creation failure.
            try{
                newDCR.Id = cr.Id;
                newDCR.Request_Status_AGN__c ='Submitted';
                newDCR.Error_Log_AGN__c = err_msg;
                system.debug('===== Account creation failed ====='+sr);
                update newDCR;
            }
            catch(Exception ex){
                 system.debug('EXCEPTION during update DCR status on Account creation failure: '+ ex );
            }
        }
        //R008.1 - Duplicate Ext ID
        if(sr != null) 
        {
            //Start - DCR reverse stamping
            newDCR.Id = dcr.Id;
            if (dcr.Request_Entity_AGN__c == HCO)
            { 
                newDCR.P_Business_Account_Id_AGN__c = sr.Id;
            }
            else
            {
                newDCR.P_Person_Account_Id_AGN__c = sr.Id;
            }
            update newDCR;
            //End - DCR reverse stamping
            
            Account accntToUpdate = [select Id, Requested_from_DCR_AGN__c from Account where Id = :sr.Id LIMIT 1];
            if(accntToUpdate != null && accntToUpdate.Requested_from_DCR_AGN__c == True){
                accntToUpdate.Requested_from_DCR_AGN__c = False;
                update accntToUpdate;
            }
            
            //Create Address for HCO Account only.
            if (dcr.Request_Entity_AGN__c == HCO)
            { 
                createORupdateAddress(cr,sr.Id);
            }
            
            //Create Affiliation for HCP if both Person and Business Account Id is present in DCR
            if (dcr.Request_Entity_AGN__c == HCP && dcr.Request_Type_AGN__c == 'Change' && dcr.Account_AGN__c != null)
            {
                addChildAccountHCP(cr);
            }
            //Create OR update Affiliation for HCO if both Business Account and Primary Business Account Id is present in DCR
            if (dcr.Request_Entity_AGN__c == HCO && dcr.Request_Type_AGN__c == 'Change' && dcr.Primary_Business_Accnt_AGN__c != null)
            {
                addChildAccountHCO(cr);
            }
            // Create OR Update Product Metrics Data
            updateProductMetrics(cr,sr.Id);
        }
    }
    
    // Gets the DCR request owner's territory and aligns the newly created Account's in that territory
     //public static void createImmediateTerritoryAlignment(DCR_AGN__c cr, Id acId)
    @future
    public static void createImmediateTerritoryAlignment(Id crId, Id acId)
    {
        system.debug('====================================== Inside [createImmediateTerritoryAlignment]===================================');
        String terrString = ';';
        // Get the territory for the Owner of DCR.
        DCR_AGN__c cr;
        
        List<Id> utIds = new List<Id>();
        List <Account_Territory_Loader_vod__c> atlList;
        
        //if(cr.Auto_Approved_AGN__c == true)
            cr = [select OwnerId,Request_Entity_AGN__c,Request_Type_AGN__c,Is_Child_DCR_AGN__c from  DCR_AGN__c where id =: crId];
        //else
         //   cr = cr;
            
            
        system.debug('value of cr.OwnerId'+cr.OwnerId );
        //system.debug('value of cr.CreatedById'+cr.CreatedById );
        
        //changes for TM 1.0 to TM 2.0 Migration - Start
            for (UserTerritory2Association ut :[select Territory2Id from UserTerritory2Association where UserId = :cr.OwnerId AND Territory2.Territory2Model.State ='Active']) 
        {
            utIds.add(ut.Territory2Id);
        }
        // Get the name of the Territory
        List<String> userTerrNames = new List<String>();          
        for (Territory2 t : [SELECT Name FROM Territory2 WHERE ID IN :utIds]) 
        {
            userTerrNames.add(t.Name);
            terrString += t.Name +';';
        }
        //changes for TM 1.0 to TM 2.0 Migration - End
        
        List <id> accId = new List <id>();
        for (Account ac : [select Id, Name from Account where Id =:acId limit 1])
        {
            accId.add(ac.id);
        }
        if (accId.size() > 0)
        {
            atlList = [select Id, Territory_vod__c,Territory_To_Add_vod__c,External_ID_vod__c
                       from Account_Territory_Loader_vod__c where Account_vod__c = :accId limit 1];
        }
        Account_Territory_Loader_vod__c atl;
        //If ATL does not exists for that account
        Database.SaveResult atlSR;
        if (atlList.size() == 0)
        {
            atl = new Account_Territory_Loader_vod__c(Account_vod__c = accId[0] ,External_ID_vod__c =accId[0] ,Territory_To_Add_vod__c =terrString );
            atlSR = Database.insert(atl);
            system.debug('value of atl that is created is '+atl);
            system.debug('value of atl that is created is '+atl.Territory_vod__c);
        }
        //if exists
        else
        {
            atl = atlList[0] ;            
            //set new ATL territory
            atl.Territory_To_Add_vod__c = terrString ;
            update (atl) ;
        }
        
        // R7 - TSF creation   
        createTSF(crId,acId,userTerrNames);
        // Create TSF for Primary Parent of HCP 
        if (cr.Request_Entity_AGN__c == 'HCP'){
            
            List <Account> pacclList = [SELECT Id, Primary_Parent_vod__c from Account 
                                        WHERE id = :acId 
                                        AND IsPersonAccount=true 
                                        AND Primary_Parent_vod__c != null 
                                        LIMIT 1];
            Account pacc;
            Id paccId;
            if (!pacclList.isEmpty())
            {
                pacc = pacclList [0];
                paccId = pacc.Primary_Parent_vod__c;
            }
            if(cr.Is_Child_DCR_AGN__c==false)
            {
            downloadToIrepforHCA(crId,paccId,userterrnames);
            }
        }
        //Insert into GAS Alignment history
        system.debug ('1--------account----->'+acId+'2-----terrString--->'+terrString+'3-----atlSR--->'+atlSR);
        if(atlSR.isSuccess())
        {  
            createGasAlignmentHistory(acId,atlSR.id,terrString);
        }
    }
    
    @future
    public static void createImmediateTerritoryAlignmentCDCR(Id crId, Id acId)
    {
        system.debug('====================================== Inside [createImmediateTerritoryAlignmentCDCR]===================================');
        String terrString = ';';
        // Get the territory for the Owner of DCR.
        DCR_AGN__c cr;
        
        List<Id> utIds = new List<Id>();
        List <Account_Territory_Loader_vod__c> atlList;
        
        //if(cr.Auto_Approved_AGN__c == true)
            cr = [select OwnerId,Request_Entity_AGN__c,Request_Type_AGN__c,Is_Child_DCR_AGN__c from  DCR_AGN__c where id =: crId];
        //else
         //   cr = cr;
            
            
        system.debug('value of cr.OwnerId'+cr.OwnerId );
        //system.debug('value of cr.CreatedById'+cr.CreatedById );
        
        //changes for TM 1.0 to TM 2.0 Migration - Start
        for (UserTerritory2Association ut :[select Territory2Id from UserTerritory2Association where UserId = :cr.OwnerId AND Territory2.Territory2Model.State ='Active']) 
        {
            utIds.add(ut.Territory2Id);
        }
        // Get the name of the Territory
        List<String> userTerrNames = new List<String>();          
        for (Territory2 t : [SELECT Name FROM Territory2 WHERE ID IN :utIds]) 
        {
            userTerrNames.add(t.Name);
            terrString += t.Name +';';
        }
        //changes for TM 1.0 to TM 2.0 Migration - End
        
        List <id> accId = new List <id>();
        for (Account ac : [select Id, Name from Account where Id =:acId limit 1])
        {
            accId.add(ac.id);
        }
        if (accId.size() > 0)
        {
            atlList = [select Id, Territory_vod__c,Territory_To_Add_vod__c,External_ID_vod__c
                       from Account_Territory_Loader_vod__c where Account_vod__c = :accId limit 1];
        }
        Account_Territory_Loader_vod__c atl;
        //If ATL does not exists for that account
        Database.SaveResult atlSR;
        if (atlList.size() == 0)
        {
            atl = new Account_Territory_Loader_vod__c(Account_vod__c = accId[0] ,External_ID_vod__c =accId[0] ,Territory_To_Add_vod__c =terrString );
            atlSR = Database.insert(atl);
            system.debug('value of atl that is created is '+atl);
            system.debug('value of atl that is created is '+atl.Territory_vod__c);
        }
        //if exists
        else
        {
            atl = atlList[0] ;            
            //set new ATL territory
            atl.Territory_To_Add_vod__c = terrString ;
            update (atl) ;
        }
        
        // R7 - TSF creation   
        createTSF(crId,acId,userTerrNames);
        // Create TSF for Primary Parent of HCP 
        if (cr.Request_Entity_AGN__c == 'HCP'){
            
            List <Account> pacclList = [SELECT Id, Primary_Parent_vod__c from Account 
                                        WHERE id = :acId 
                                        AND IsPersonAccount=true 
                                        AND Primary_Parent_vod__c != null 
                                        LIMIT 1];
            Account pacc;
            Id paccId;
            if (!pacclList.isEmpty())
            {
                pacc = pacclList [0];
                paccId = pacc.Primary_Parent_vod__c;
            }
            if(cr.Is_Child_DCR_AGN__c==false)
            {
            downloadToIrepforHCA(crId,paccId,userterrnames);
            }
        }
        //Insert into GAS Alignment history
        system.debug ('1--------account----->'+acId+'2-----terrString--->'+terrString+'3-----atlSR--->'+atlSR);
        if(atlSR.isSuccess())
        {  
            createGasAlignmentHistory(acId,atlSR.id,terrString);
        }
    }
    public static void createChildAff(DCR_AGN__c cdcr)
    {
        system.debug('value of child aff '+cdcr);
        system.debug('value of child aff cdcr.Parent_DCR_ID_AGN__c '+cdcr.Parent_DCR_ID_AGN__c);
        list<DCR_AGN__c>  parentdcr= new list<DCR_AGN__c>([select id,P_Business_Account_Id_AGN__c,Request_Status_AGN__c from DCR_AGN__c where id=:cdcr.Parent_DCR_ID_AGN__c]); 
        system.debug('value of parentdcr '+parentdcr[0].P_Business_Account_Id_AGN__c) ;
        Child_Account_vod__c cRec = new Child_Account_vod__c();
        cRec.Parent_Account_vod__c =parentdcr[0].P_Business_Account_Id_AGN__c;
        if (cdcr.Request_Entity_AGN__c == HCO && cdcr.Request_Type_AGN__c == 'Add')
        {
            cRec.Child_Account_vod__c = cdcr.P_Business_Account_Id_AGN__c;
        }
        if (cdcr.Request_Entity_AGN__c == HCP && cdcr.Request_Type_AGN__c == 'Add')
        {
            cRec.Child_Account_vod__c = cdcr.P_Person_Account_Id_AGN__c;
        }
        system.debug('value of cRec.Child_Account_vod__c  '+cRec.Child_Account_vod__c);
        system.debug('cRec.Parent_Account_vod__c  '+cRec.Parent_Account_vod__c);
        Database.SaveResult sr = Database.insert(cRec);
        if(sr.isSuccess()) 
        {
            //DCR_AGN__c ucdcr=[select id,Request_Status_AGN__c from DCR_AGN__c where id=:cdcr.Id] ;
            cdcr.P_Child_Account_Id_AGN__c=sr.id;
            update cdcr;
        }
    }

  public static void createTSF(Id crId, Id accId, List<String> userterrnames){
      system.debug('value of child dcr'+crId);
        system.debug('===== Inside [createTSF] =====');
        List<TSF_vod__c> upsTSFlist = new List<TSF_vod__c>();
        for (Integer i = 0; i < userterrnames.size(); i++){
            TSF_vod__c tsf = new TSF_vod__c();
            tsf.account_vod__c = accId;
            tsf.territory_vod__c = userterrnames[i]; 
            tsf.name = userterrnames[i];
            tsf.External_Id_vod__c = accId+'__'+userterrnames[i];
            tsf.Target_Manager_SMB__c = true;
            upsTSFlist.add(tsf);  
        }
        upsert upsTSFlist External_Id_vod__c;
        system.debug('===== [createTSF] upserted upsTSFlist ==>> ' + upsTSFlist);
    }
    public static void createGasAlignmentHistory(Id acId,Id atlId,String terrString){
        system.debug('===== Inside [createGasAlignmentHistory] =====');
        GAS_Alignment_History_vts__c history = new GAS_Alignment_History_vts__c();
        //track that Account to be aligned
        history.Account__c = acId;
        history.New_Territory__c = terrString;
        //track ATL and old territory string
        history.Account_Territory_Loader__c = atlId;
        //history.Old_Territory__c = atl.Territory_vod__c;
        system.debug('value of history '+history);
        insert history;
    }
    public static void downloadToIrepforHCA(Id crId, Id paccId, List<String> userTerrNames){
        system.debug('===== Inside [downloadToIrepforHCA] =====');  
        createTSF(crId,paccId,userTerrNames);          
    }
    //***************************HCO child account*************************
    //****************Called for Request type = Change*********************
    
    public static void addChildAccountHCO(DCR_AGN__c cr){
        system.debug('===== Inside [addChildAccountHCO] =====');
        Child_Account_vod__c ca;
        DCR_AGN__c newDCR = new DCR_AGN__c();
        
        list<Child_Account_vod__c> caList = new list<Child_Account_vod__c>([SELECT Name,OK_Role__c,Parent_Account_vod__c,Work_Status_AGN__c,
                                                                            Child_Account_vod__c,Copy_Address_vod__c,Network_Primary_vod__c
                                                                            FROM Child_Account_vod__c
                                                                            WHERE Child_Account_vod__c = :cr.Account_AGN__c
                                                                            AND Parent_Account_vod__c = :cr.Primary_Business_Accnt_AGN__c limit 1]);
        
        if(caList.size()==0){
            ca = new Child_Account_vod__c(Child_Account_vod__c = cr.Account_AGN__c,
                                          Parent_Account_vod__c = cr.Primary_Business_Accnt_AGN__c,
                                          OK_Role__c = cr.Role_AGN__c,
                                          Work_Status_AGN__c = cr.Work_Status_AGN__c,
                                          Copy_Address_vod__c = false,
                                          Network_Primary_vod__c = true
                                         );
            insert ca;
            //BEGIN - DCR - Reverse Stamp
            if(ca.Id != null){
                newDCR.Id = cr.Id;
                newDCR.P_Child_Account_Id_AGN__c = ca.Id;
                update newDCR;
            }else{
                system.debug('===== [addChildAccountHCO][caList.size() = 0][ca.Id = null] Child Account not created - HCO =====');
            } 
            //END - DCR - Reverse Stamp           
        }else{
            ca = caList[0];
            ca.OK_Role__c = cr.Role_AGN__c;
            ca.Work_Status_AGN__c = cr.Work_Status_AGN__c;
            update ca;
            system.debug('===== [addChildAccountHCO][caList.size() != 0] Existing Child Account ==>>' + caList);
        }     
    }
    //****************************HCO child account************************
    //************Called for Request type = Change*************************
    public static void addChildAccountHCP(DCR_AGN__c cr){
        system.debug('===== Inside [addChildAccountHCP] =====');
        Child_Account_vod__c ca;
        DCR_AGN__c newDCR = new DCR_AGN__c();
        boolean primaryAffiliation;  
        list<Child_Account_vod__c> caList = new list<Child_Account_vod__c>([SELECT Name,OK_Role__c,Parent_Account_vod__c,Work_Status_AGN__c,
                                                                            Child_Account_vod__c,Copy_Address_vod__c,Network_Primary_vod__c
                                                                            FROM Child_Account_vod__c
                                                                            WHERE Child_Account_vod__c = :cr.Contact_AGN__c
                                                                            AND Parent_Account_vod__c = :cr.Account_AGN__c limit 1]);
        primaryAffiliation = cr.Primary_Affiliation_AGN__c == 'Yes' ? true : false;
        if(caList.size()==0){
            //primaryAffiliation = cr.Primary_Affiliation_AGN__c == 'Yes' ? true : false;
            ca = new Child_Account_vod__c();
            ca.Child_Account_vod__c = cr.Contact_AGN__c;
            ca.Parent_Account_vod__c = cr.Account_AGN__c;
            ca.OK_Role__c = cr.Role_AGN__c;
            ca.Work_Status_AGN__c = cr.Work_Status_AGN__c;
            ca.Copy_Address_vod__c = true;
            ca.Network_Primary_vod__c = primaryAffiliation;
            insert ca;
            //BEGIN - DCR - Reverse Stamp
            if(ca.Id != null){
                newDCR.Id = cr.Id;
                newDCR.P_Child_Account_Id_AGN__c = ca.Id;
                update newDCR;
                //R008 - Copy Address for Child
                //if (primaryAffiliation)
                   // copyAddressforHCP(ca);
            }else{
                system.debug('===== Child Account not created =====');
            } //END - DCR - Reverse Stamp           
        }else{
            ca = caList[0];
            ca.OK_Role__c = cr.Role_AGN__c;
            ca.Work_Status_AGN__c = cr.Work_Status_AGN__c;
            ca.Network_Primary_vod__c = primaryAffiliation;
            update ca;
            if (primaryAffiliation)
               //copyAddressforHCP(ca);
            system.debug('===== Child Account already exists ==>>'+caList);
        }
    }
    //*** Called from Trigger - Request Type = change blocks
    public static void createChildAccountHCO(DCR_AGN__c cr){
        //One HCO can be tagged to one Parent i.e. only one Primary_Business_Accnt_AGN__c, 
        //so before inserting a CA record with HCO as a child 
        //delete all other CA record using the method - deleteHCOChildAccount(cr); 
        
        system.debug('===== Inside [createChildAccountHCO] =====');
        Child_Account_vod__c ca;
        DCR_AGN__c newDCR = new DCR_AGN__c();
        DCR_AGN__c crInScope = [select P_Business_Account_Id_AGN__c,Primary_Business_Accnt_AGN__c from DCR_AGN__c where Id = :cr.Id];
        boolean primaryAffiliation; 
        
        list<Child_Account_vod__c> caList = new list<Child_Account_vod__c>([SELECT Name,OK_Role__c,Parent_Account_vod__c,Work_Status_AGN__c,
                                                                            Child_Account_vod__c,Copy_Address_vod__c,Network_Primary_vod__c
                                                                            FROM Child_Account_vod__c
                                                                            WHERE Child_Account_vod__c = :crInScope.P_Business_Account_Id_AGN__c
                                                                            AND Parent_Account_vod__c = :crInScope.Primary_Business_Accnt_AGN__c limit 1]);
        
        list<Child_Account_vod__c> caList2 = new list<Child_Account_vod__c>([SELECT Name,OK_Role__c,Parent_Account_vod__c,Work_Status_AGN__c,
                                                                             Child_Account_vod__c,Copy_Address_vod__c,Network_Primary_vod__c
                                                                             FROM Child_Account_vod__c
                                                                             WHERE Child_Account_vod__c = :crInScope.P_Business_Account_Id_AGN__c
                                                                             AND Primary_vod__c = 'Yes'
                                                                            ]);
        
        if(caList.size() == 0){
            if (caList2.size() > 0){
                deleteHCOChildAccount(caList2);
            }
            system.debug('===== Inside [createChildAccountHCO] ===== caList.size ==>>:' + caList.size());
            ca = new Child_Account_vod__c(Child_Account_vod__c = crInScope.P_Business_Account_Id_AGN__c,
                                          Parent_Account_vod__c = crInScope.Primary_Business_Accnt_AGN__c,
                                          OK_Role__c = cr.Role_AGN__c,
                                          Work_Status_AGN__c = cr.Work_Status_AGN__c,
                                          Copy_Address_vod__c = false,
                                          Network_Primary_vod__c = true); 
            Database.SaveResult sr = Database.insert(ca);
            if(sr.isSuccess()) {
                newDCR.Id = cr.Id;
                newDCR.P_Child_Account_Id_AGN__c = ca.Id;
                update newDCR;
               
            }
            else{
                system.debug('===== [createChildAccountHCO] Child Account NOT created - HCO ===== sr ==>>' + sr);
            }
        }   
    }
 
    public static void deleteHCOChildAccount(list<Child_Account_vod__c> cacclist){
        system.debug('===== Inside [deleteHCOChildAccount] =====');
        list<Child_Account_vod__c> delCAlist = new list<Child_Account_vod__c>();
        for (Child_Account_vod__c ca : cacclist)
        {
            delCAlist.add(ca);
            system.debug('===== deleting ..........'+ca);
        }
        delete delCAlist;
    }
    //*************************HCP child account********************
    
    public static void createChildAccountHCP(DCR_AGN__c cr){
        system.debug('===== Inside [createChildAccountHCP] =====');
        Child_Account_vod__c ca;
        DCR_AGN__c newDCR = new DCR_AGN__c();
        DCR_AGN__c crInScope = [select P_Person_Account_Id_AGN__c,Contact_AGN__c,Account_AGN__c from DCR_AGN__c where Id = :cr.Id];
        boolean primaryAffiliation; 
        
        list<Child_Account_vod__c> caList = [SELECT Name,OK_Role__c,Parent_Account_vod__c,Work_Status_AGN__c,
                                             Child_Account_vod__c,Copy_Address_vod__c,Network_Primary_vod__c
                                             FROM Child_Account_vod__c
                                             WHERE Child_Account_vod__c = :crInScope.P_Person_Account_Id_AGN__c
                                             AND Parent_Account_vod__c = :crInScope.Account_AGN__c limit 1];
        
        if(caList.size() == 0){
            primaryAffiliation = cr.Primary_Affiliation_AGN__c == 'Yes' ? true : false;
            ca = new Child_Account_vod__c(Child_Account_vod__c = crInScope.P_Person_Account_Id_AGN__c,
                                          Parent_Account_vod__c = crInScope.Account_AGN__c,
                                          OK_Role__c = cr.Role_AGN__c,
                                          Work_Status_AGN__c = cr.Work_Status_AGN__c,
                                          Copy_Address_vod__c = true,
                                          Network_Primary_vod__c = primaryAffiliation
                                         );
            insert ca;
            //Start - DCR reverse stamping
            if(ca.Id != null){
                newDCR.Id = cr.Id;
                newDCR.P_Child_Account_Id_AGN__c = ca.Id;
                update newDCR;
                //R008 - Copy Address for Child
                //copyAddressforHCP(ca);
            }
            //END - DCR reverse stamping
            else{
                system.debug('===== [createChildAccountHCP][caList.size() = 0][ca.Id = null] Child Account not created =====');
            }            
        }else{
            system.debug('===== [createChildAccountHCP][caList.size() != 0] Existing Child Account ===== caList ==>>' + caList);
        }     
        
    }
    //*********************R008 - COPY ADDRESS FROM PARENT (HCO) ACCOUNT*************************
    public static void copyAddressforHCP(Child_Account_vod__c ca){
        system.debug('===== Inside [copyAddressforHCP] ====='+ca);

        list <Address_vod__c>  insAddrlist = new list <Address_vod__c>();
        list <Address_vod__c>  updAddrlist = new list <Address_vod__c>();
        
        //Call remove Address before Inserting
        //removeAddressFromCopyAddress(ca);
        
        String sAddrSelctField = 'Id,Name,Account_vod__c,External_ID_vod__c,Controlling_Address_vod__c, Address_line_2_vod__c,Address_Line_3_AGN__c,'
                                +'State_vod__c,City_vod__c,Zip_vod__c, Brick_vod__c,Country_Code__c,Country_vod__c,address_type_vod__c,Primary_vod__c,Receptionist_Email_AGN__c,'
                                +'Receptionist_Name_AGN__c,Business_vod__c,Mailing_vod__c,Shipping_vod__c,Billing_vod__c,Home_vod__c,Phone_vod__c,Phone_2_vod__c,Fax_vod__c,'
                                +'Appt_Required_vod__c,Requested_from_DCR_AGN__c,Address_status_vod__c,Controlled_Address_vod__c';
            
        String selAddrStmt = 'Select ' + sAddrSelctField + ' From Address_vod__c Where Account_vod__c In (\'' + ca.Parent_Account_vod__c + '\')';
        List<Address_vod__c> addressObjects = new List<Address_vod__c>();
        addressObjects = Database.query(selAddrStmt);
        
        if (addressObjects.size() > 0){
          system.debug('===== Inside [addressObjects] ====='+addressObjects);
             for (Address_vod__c pAddr : addressObjects)
             {
                 Address_vod__c cAddr = new Address_vod__c();
                 cAddr.Account_vod__c = ca.Child_Account_vod__c; 
                 cAddr.Name = pAddr.Name;
                 cAddr.Address_line_2_vod__c = pAddr.Address_line_2_vod__c;
                 cAddr.City_vod__c = pAddr.City_vod__c; 
                 cAddr.Address_type_vod__c = pAddr.Address_type_vod__c;
                 cAddr.Zip_vod__c = pAddr.Zip_vod__c;
                 cAddr.Brick_vod__c  = pAddr.Brick_vod__c; 
                 cAddr.Receptionist_Email_AGN__c = pAddr.Receptionist_Email_AGN__c; 
                 cAddr.Receptionist_Name_AGN__c = pAddr.Receptionist_Name_AGN__c;
                 cAddr.Appt_Required_vod__c = pAddr.Appt_Required_vod__c; 
                 cAddr.Mailing_vod__c = pAddr.Mailing_vod__c; 
                 cAddr.Shipping_vod__c = pAddr.Shipping_vod__c;
                 cAddr.Billing_vod__c = pAddr.Billing_vod__c; 
                 cAddr.Home_vod__c = pAddr.Home_vod__c;
                 cAddr.Business_vod__c = pAddr.Business_vod__c;
                 cAddr.Phone_vod__c = pAddr.Phone_vod__c;
                 cAddr.Fax_vod__c = pAddr.Fax_vod__c;
                 cAddr.Phone_2_vod__c = pAddr.Phone_2_vod__c; 
                 cAddr.Country_vod__c = pAddr.Country_vod__c; 
                 cAddr.Country_Code__c = pAddr.Country_Code__c;
                 cAddr.Address_Line_3_AGN__c = pAddr.Address_Line_3_AGN__c;
                 cAddr.State_vod__c = pAddr.State_vod__c;
                 cAddr.Primary_vod__c = pAddr.Primary_vod__c;
                 cAddr.Address_status_vod__c = pAddr.Address_status_vod__c;
                 cAddr.Primary_vod__c = pAddr.Primary_vod__c;
                 cAddr.Address_status_vod__c = pAddr.Address_status_vod__c;
                 cAddr.Controlled_Address_vod__c = pAddr.Controlled_Address_vod__c;
                 cAddr.Controlling_Address_vod__c = pAddr.Id;
                 insAddrlist.add(cAddr);
             }
              system.debug('===== Inside [insAddrlist] ====='+insAddrlist);
             insert insAddrlist;
        }
        else{
            System.debug('No address found for HCO');
        }
       
        /* Defualt fields to select from address.
String sAddrSelctField = 'Name,Country_vod__c,Account_vod__c,External_ID_vod__c,Controlling_Address_vod__c';

Set <String> uniqueFields = new Set<String>(); 
//uniqueFields.add('Id');
uniqueFields.add('Name');
uniqueFields.add('Country_vod__c');
//uniqueFields.add('RecordTypeId');
//uniqueFields.add('RecordType.DeveloperName');
uniqueFields.add('Account_vod__c');
uniqueFields.add('External_ID_vod__c');

Message_vod__c msgCat = [Select Name, Text_vod__c from Message_vod__c 
Where Name like 'ACCT_HIER_ADDR_COPY_FIELDS' 
and Active_vod__c = true];

if (msgCat.Text_vod__c != null) {          
String[] arrFields =  msgCat.Text_vod__c.split(',');
for (String fieldname : arrFields) {
if (uniqueFields.contains(fieldname) == false)
sAddrSelctField += ',' + fieldname;
uniqueFields.add(fieldname);
}
}
List<Address_vod__c> addressObjects;
if (ca.Parent_Account_vod__c != null){
String selAddrStmt = 'Select ' + sAddrSelctField + ' From Address_vod__c' + 
' Where Account_vod__c In (\'' + ca.Parent_Account_vod__c + '\')';
addressObjects = Database.query(selAddrStmt);
}
String addressKey = 'ACCT_HIER_ADDR_COPY_FIELDS';


if (addressObjects.size() != 0)
{
for (Address_vod__c addr : addressObjects)
{  
extId = addr.Account_vod__c + '_' + addr.Controlling_Address_vod__c;   
//addr.Account_vod__c = ca.Child_Account_vod__c;
addr.put('Account_vod__c', ca.Child_Account_vod__c);
addr.put('External_Id_vod__c',extId);  
addr.put('Controlling_Address_vod__c', addr.Id);
addr.put('Controlled_Address_vod__c', true);
//addr.put('RecordTypeId',recId);

if (uniqueFields != null) {
for (String fieldName : uniqueFields) {
if ('Id'.equals(fieldName))
continue;
if ('RecordTypeId'.equals(fieldName))
continue;  
if ('RecordType.DeveloperName'.equals(fieldName))
continue;

Object fieldVal = addr.get(fieldName);
if (fieldVal == null)
{
continue;
}
if (fieldVal instanceOf String)
{
addr.put(fieldName, (String) fieldVal);
}
else
{
addr.put(fieldName, fieldVal);
}
}
insAddrlist.add(addr);
}
}

}   
upsert insAddrlist External_Id_vod__c;*/
    }
    //**********************END - COPY ADDRESS FROM PARENT (HCO) ACCOUNT********************
    
    public static void removeAffiliation(DCR_AGN__c cr){
        system.debug('===== Inside [removeAffiliation] =====');
        List <DCR_AGN__c> remAffiliationlist = new List <DCR_AGN__c> ();
        List<Child_Account_vod__c> caList ;
        list <Child_Account_vod__c>  remCAlist = new list <Child_Account_vod__c>();
        //****************************HCP Affiliation removal****************************
        if (cr.Request_Entity_AGN__c == HCP){
            if (cr.Contact_AGN__c != null && cr.Account_AGN__c != null){
                caList = new list  <Child_Account_vod__c>([SELECT Name,OK_Role__c,Work_Status_AGN__c,Parent_Account_vod__c,Child_Account_vod__c
                                                           FROM Child_Account_vod__c
                                                           WHERE Child_Account_vod__c = :cr.Contact_AGN__c
                                                           AND Parent_Account_vod__c = :cr.Account_AGN__c
                                                          ]);
            }
        }
        //****************************HCO Affiliation removal****************************
        else{
            if (cr.Primary_Business_Accnt_AGN__c != null){
                caList = new list <Child_Account_vod__c> ([SELECT Name,OK_Role__c,Work_Status_AGN__c,Parent_Account_vod__c,Child_Account_vod__c
                                                           FROM Child_Account_vod__c
                                                           WHERE Child_Account_vod__c = :cr.Account_AGN__c
                                                           AND Parent_Account_vod__c = :cr.Primary_Business_Accnt_AGN__c
                                                          ]);
            }
        }
        if (caList.size() != 0)
        {
            for (Child_Account_vod__c ca : caList)
            {
                remCAlist.add(ca);
            }
            delete remCAlist;
        }
    }

    public static void removeAffilitaionifRejected(DCR_AGN__c cr) {
        system.debug('=============== Inside [removeAffilitaionifRejected] =====');
       
        list<Child_Account_vod__c> cRecEx= new list<Child_Account_vod__c>([select id from Child_Account_vod__c where id =:cr.P_Child_Account_Id_AGN__c]);
       
        if (cRecEx.size()>0)
        {
            delete cRecEx[0];
        }
    }


    //1**********************ADDRESS DELETION FROM DCR*****************************
    
    public static void removeAddress(DCR_AGN__c cr){
        system.debug('===== Inside [removeAddress] =====');
        List <DCR_AGN__c> remAddresslist = new List <DCR_AGN__c> ();
        List<Address_vod__c> addrList ;
        list <Address_vod__c>  delAddrlist = new list <Address_vod__c>();
        
        if (cr.Address_AGN__c != null)
        {
            addrList = new list  <Address_vod__c>([SELECT Id
                                                  FROM Address_vod__c
                                                  WHERE Id = :cr.Address_AGN__c
                                                 ]);
        }

        if (addrList.size() != 0)
        {
            for (Address_vod__c addr : addrList)
            {
                delAddrlist.add(addr);
            }
            delete delAddrlist;
        }
    }
    // ************************END - Delete Address*********************
    //2**********************ADDRESS DELETION FROM DCR*****************************
    
    public static void removeAddressFromCopyAddress(Child_Account_vod__c ca){
        system.debug('===== Inside [removeAddress] =====');
        List <DCR_AGN__c> remAddresslist = new List <DCR_AGN__c> ();
        List<Address_vod__c> addrList ;
        list <Address_vod__c>  delAddrlist = new list <Address_vod__c>();
        
        if (ca.Child_Account_vod__c != null)
        {
            addrList = new list  <Address_vod__c>([SELECT Id
                                                  FROM Address_vod__c
                                                  WHERE Account_vod__c = :ca.Child_Account_vod__c
                                                  //AND Controlled_Address_vod__c = true 
                                                  AND Controlling_Address_vod__c  != :ca.Parent_Account_vod__c
                                                 ]);
        }
        if (addrList.size() != 0)
        {
            for (Address_vod__c addr : addrList)
            {
                delAddrlist.add(addr);
            }
            delete delAddrlist;
        }
    }
    // ************************END - Delete Address*********************
    
    //*********************BEGIN - ADDRESS CREATE OR UPDATE ******************************
    public static void createORupdateAddress(DCR_AGN__c cr,Id accId){
        system.debug('===== Inside [createORupdateAddress] =====');
        DCR_AGN__c newDCR = new DCR_AGN__c();
        Address_vod__c addr = new Address_vod__c();
        list <Address_vod__c> adList = new list<Address_vod__c>();
        for (Address_vod__c adrs : [select Id, Name,Account_vod__c, Address_line_2_vod__c,Address_Line_3_AGN__c,State_vod__c,City_vod__c,Zip_vod__c, Brick_vod__c,
                                    Country_Code__c,Country_vod__c,address_type_vod__c,Primary_vod__c,Receptionist_Email_AGN__c,Receptionist_Name_AGN__c,
                                    Business_vod__c,Mailing_vod__c,Shipping_vod__c,Billing_vod__c,Home_vod__c,Phone_vod__c,Phone_2_vod__c,Fax_vod__c,
                                    Appt_Required_vod__c,Requested_from_DCR_AGN__c,Address_status_vod__c
                                    FROM Address_vod__c WHERE id =:cr.Address_AGN__c])
        {         
            adList.add(adrs);
        }
        
        //Create new address if cr.Address_AGN__c is null
        if (adList.isEmpty() || adList.size() == 0)
        {
            addr.Account_vod__c = accId;
            addr.Name = cr.Address_Line_1_AGN__c;
            addr.Address_line_2_vod__c = cr.Address_Line_2_AGN__c;
            addr.City_vod__c = cr.City_AGN__c;
            addr.address_type_vod__c=cr.Address_Type_AGN__c;
            addr.Zip_vod__c = cr.Zip_AGN__c;
            addr.Brick_vod__c = cr.Brick_AGN__c;
            addr.Receptionist_Email_AGN__c = cr.Receptionist_Email_AGN__c;
            addr.Receptionist_Name_AGN__c = cr.Receptionist_Name_AGN__c;
            addr.Appt_Required_vod__c = cr.Appt_Required_AGN__c;
            addr.Mailing_vod__c = cr.Mailing_AGN__c;
            addr.Shipping_vod__c = cr.Shipping_AGN__c;
            addr.Billing_vod__c = cr.Billing_AGN__c;
            addr.Home_vod__c = cr.Home_AGN__c;
            addr.Business_vod__c = cr.Business_AGN__c;
            addr.Phone_vod__c = cr.Phone_AGN__c;
            addr.Fax_vod__c = cr.Address_Fax_AGN__c;
            addr.Phone_2_vod__c = cr.Phone_2_AGN__c;
            addr.Country_vod__c = cr.Country_AGN__c;
            addr.Country_Code__c = cr.Country_Code_AGN__c;
            //R005
            addr.Address_Line_3_AGN__c = cr.Address_Line_3_AGN__c;
            addr.State_vod__c = cr.State_AGN__c;
            
            if (cr.Request_Type_AGN__c == 'Add')
                addr.Primary_vod__c = true;
            else
                addr.Primary_vod__c = cr.Primary_Address_AGN__c == 'Yes'? true: false;
            addr.Address_status_vod__c = 'Active';
            //insert addr;
            Database.SaveResult sr= Database.insert(addr);
            if(sr.isSuccess())
            {
                //Start - DCR reverse stamping
                newDCR.Id = cr.Id;
                newDCR.P_Account_Address_Id__c = sr.Id;
                update newDCR;
                //End - DCR reverse stamping
            }
        }
        else
        {
            addr = adList[0];
            addr.Name = cr.Address_Line_1_AGN__c;
            addr.Address_line_2_vod__c = cr.Address_Line_2_AGN__c;
            addr.City_vod__c = cr.City_AGN__c;
            addr.Zip_vod__c = cr.Zip_AGN__c ;
            addr.address_type_vod__c=cr.Address_Type_AGN__c;
            addr.Brick_vod__c = cr.Brick_AGN__c;
            addr.Receptionist_Email_AGN__c = cr.Receptionist_Email_AGN__c;
            addr.Receptionist_Name_AGN__c = cr.Receptionist_Name_AGN__c;
            addr.Appt_Required_vod__c = cr.Appt_Required_AGN__c;
            addr.Business_vod__c = cr.Billing_AGN__c;
            addr.Mailing_vod__c = cr.Mailing_AGN__c;
            addr.Shipping_vod__c = cr.Shipping_AGN__c;
            addr.Billing_vod__c = cr.Billing_AGN__c;
            addr.Home_vod__c = cr.Home_AGN__c;
            addr.Business_vod__c = cr.Business_AGN__c;
            addr.Phone_vod__c = cr.Phone_AGN__c;
            addr.Phone_2_vod__c = cr.Phone_2_AGN__c;
            addr.Fax_vod__c = cr.Address_Fax_AGN__c;
            addr.Country_vod__c = cr.Country_AGN__c;
            addr.Country_Code__c = cr.Country_Code_AGN__c;
            addr.Requested_from_DCR_AGN__c = TRUE;
            addr.Address_status_vod__c = 'Active';
            //R005
            addr.Address_Line_3_AGN__c = cr.Address_Line_3_AGN__c;
            addr.State_vod__c = cr.State_AGN__c;
            //R008
            addr.Primary_vod__c = cr.Primary_Address_AGN__c == 'Yes'? true: false;
            Database.SaveResult sr= Database.update(addr);
            if(sr.isSuccess())
            {
                Address_vod__c addrToUpdate = [select Id, Requested_from_DCR_AGN__c from Address_vod__c where Id = :sr.Id LIMIT 1];
                if(addrToUpdate != null && addrToUpdate.Requested_from_DCR_AGN__c == True){
                    addrToUpdate.Requested_from_DCR_AGN__c = False;
                    update addrToUpdate;
                }
            } 
        }
    }
    //***************************END - ADDRESS CREATE OR UPDATE **************************
    @future
    public static void insertProductMetrics(Id crId,Id acc) {
        system.debug('===== Inside [insertProductMetrics] =====');
        
        List<DCR_Product_Metrics_AGN__c> pulledDCRProductMetrics = [SELECT 
                                                                    Product_AGN__c,Product_Metrics_Reference__c,Adoption_AGN__c,Adoption_IMS_AGN__c,Potential_AGN__c,Potential_IMS_AGN__c,Segment_AGN__c,Segment_IMS_AGN__c,
                                                                    Target_AGN__c,Sector_AGN__c,Fase_AGN__c,Ratings_AGN__c,Advocacy_Profile_AGN__c,Investigator_Readiness_AGN__c,Customer_Segment_AGN__c,Sales_Target_AGN__c,
                                                                    Investigator_AGN__c,Profiling_AGN__c,Retina_Profile_AGN__c,Product_Status_AGN__c,Growth_Potential_AGN__c,Awareness_AGN__c,Adoption_Level_AGN__c,Engagements_AGN__c,
                                                                    Account_Support_AGN__c,Fixed_Consignment_AGN__c,Key_Account_AGN__c,Ophthalmology_Profile_AGN__c,Segment1_AGN__c,Detail_Group_AGN__c,Continuum_Placement_AGN__c
                                                                    FROM DCR_Product_Metrics_AGN__c WHERE DCR_AGN__c = :crId];
        system.debug('===== [insertProductMetrics] cr.id ==>>' + crId);
        system.debug('===== [insertProductMetrics] pulledDCRProductMetrics ==>>' + pulledDCRProductMetrics);
        List<Product_Metrics_vod__c> pushProductMetrics = new List<Product_Metrics_vod__c>();
        for(DCR_Product_Metrics_AGN__c dcr_pm: pulledDCRProductMetrics) {
            Product_Metrics_vod__c acc_pm = new Product_Metrics_vod__c();
            acc_pm.Account_vod__c = acc;
            acc_pm.Products_vod__c = dcr_pm.Product_AGN__c;
            acc_pm.Detail_Group_vod__c = dcr_pm.Detail_Group_AGN__c;
            acc_pm.Adoption_AGN__c = dcr_pm.Adoption_AGN__c;
            acc_pm.Adoption_IMS_AGN__c = dcr_pm.Adoption_IMS_AGN__c;
            acc_pm.Allergan_Potential_AGN__c = dcr_pm.Potential_AGN__c;
            acc_pm.Potential_IMS_AGN__c = dcr_pm.Potential_IMS_AGN__c;
            acc_pm.Segment_AGN__c = dcr_pm.Segment_AGN__c;
            acc_pm.Segment_IMS_AGN__c = dcr_pm.Segment_IMS_AGN__c;
            acc_pm.Target_AGN__c = dcr_pm.Target_AGN__c;
            //R005
            acc_pm.Sector_AGN__c = dcr_pm.Sector_AGN__c;
            acc_pm.Fase_AGN__c = dcr_pm.Fase_AGN__c;
            acc_pm.Ratings_AGN__c = dcr_pm.Ratings_AGN__c;
            acc_pm.Advocacy_Profile_AGN__c = dcr_pm.Advocacy_Profile_AGN__c;
            acc_pm.Investigator_Readiness__c = dcr_pm.Investigator_Readiness_AGN__c;
            acc_pm.Customer_Segment_AGN__c = dcr_pm.Customer_Segment_AGN__c;
            acc_pm.Sales_Target_AGN__c = dcr_pm.Sales_Target_AGN__c;
            //R007
            acc_pm.Investigator_smb__c = dcr_pm.Investigator_AGN__c;
            acc_pm.Profiling_AGN__c = dcr_pm.Profiling_AGN__c;
            acc_pm.Retina_Profile_AGN__c = dcr_pm.Retina_Profile_AGN__c;
            acc_pm.Product_Status_AGN__c = dcr_pm.Product_Status_AGN__c;
            acc_pm.Growth_Potential_AGN__c = dcr_pm.Growth_Potential_AGN__c;
            acc_pm.Awareness__c = dcr_pm.Awareness_AGN__c;
            acc_pm.Adoption_Level__c = dcr_pm.Adoption_Level_AGN__c;
            acc_pm.Engagements__c = dcr_pm.Engagements_AGN__c;
            acc_pm.Account_Support_AGN__c = dcr_pm.Account_Support_AGN__c;
            acc_pm.Fixed_Consignment_AGN__c = dcr_pm.Fixed_Consignment_AGN__c;
            acc_pm.Key_Account_AGN__c = dcr_pm.Key_Account_AGN__c;
            acc_pm.Ophthalmology_Profile_AGN__c = dcr_pm.Ophthalmology_Profile_AGN__c;
            acc_pm.Segment__c = dcr_pm.Segment1_AGN__c;
            //R007.1
            acc_pm.Continuum_Placement_AGN__c = dcr_pm.Continuum_Placement_AGN__c;
            
            pushProductMetrics.add(acc_pm);
        }
        insert pushProductMetrics;
    }
    
    public static void updateProductMetrics(DCR_AGN__c cr,Id acc) {
        system.debug('===== Inside [updateProductMetrics] =====');
        
        List<DCR_Product_Metrics_AGN__c> pulledDCRProductMetrics = [SELECT Product_AGN__c,Detail_Group_AGN__c,Product_Metrics_Reference__c,Adoption_AGN__c,Adoption_IMS_AGN__c,
                                                                    Potential_AGN__c,Potential_IMS_AGN__c,Segment_AGN__c,Segment_IMS_AGN__c,Target_AGN__c,Sector_AGN__c,Fase_AGN__c,Ratings_AGN__c,Advocacy_Profile_AGN__c,
                                                                    Investigator_Readiness_AGN__c,Customer_Segment_AGN__c,Sales_Target_AGN__c,Investigator_AGN__c,Profiling_AGN__c,Retina_Profile_AGN__c,Product_Status_AGN__c,
                                                                    Growth_Potential_AGN__c,Awareness_AGN__c,Adoption_Level_AGN__c,Engagements_AGN__c,Account_Support_AGN__c,Fixed_Consignment_AGN__c,Key_Account_AGN__c,
                                                                    Ophthalmology_Profile_AGN__c,Segment1_AGN__c,Continuum_Placement_AGN__c
                                                                    FROM DCR_Product_Metrics_AGN__c WHERE DCR_AGN__c = :cr.id];
        
        List<Product_Metrics_vod__c> insProductMetrics = new List<Product_Metrics_vod__c>();
        List<Product_Metrics_vod__c> updProductMetrics = [SELECT Products_vod__c,Products_vod__r.Product_Type_vod__c,Account_vod__c,Adoption_AGN__c,Adoption_IMS_AGN__c,
                                                          Allergan_Potential_AGN__c,Potential_IMS_AGN__c,Segment_AGN__c,Segment_IMS_AGN__c,Target_AGN__c,Sector_AGN__c,Fase_AGN__c,Ratings_AGN__c,Advocacy_Profile_AGN__c,
                                                          Investigator_Readiness__c,Customer_Segment_AGN__c,Sales_Target_AGN__c,Investigator_smb__c,Profiling_AGN__c,Retina_Profile_AGN__c,Product_Status_AGN__c,
                                                          Growth_Potential_AGN__c,Awareness__c,Adoption_Level__c,Engagements__c,Account_Support_AGN__c,Fixed_Consignment_AGN__c,Key_Account_AGN__c,
                                                          Ophthalmology_Profile_AGN__c,Segment__c,Continuum_Placement_AGN__c
                                                          FROM Product_Metrics_vod__c WHERE Account_vod__c = :acc];
        List<Product_Metrics_vod__c> delProductMetricsMarker = [SELECT Products_vod__c,Products_vod__r.Product_Type_vod__c,Account_vod__c,Adoption_AGN__c,Adoption_IMS_AGN__c,
                                                                Allergan_Potential_AGN__c,Potential_IMS_AGN__c,Segment_AGN__c,Segment_IMS_AGN__c,Target_AGN__c,Sector_AGN__c,Fase_AGN__c,Ratings_AGN__c,Advocacy_Profile_AGN__c,
                                                                Investigator_Readiness__c,Customer_Segment_AGN__c,Sales_Target_AGN__c,Investigator_smb__c,Profiling_AGN__c,Retina_Profile_AGN__c,Product_Status_AGN__c,
                                                                Growth_Potential_AGN__c,Awareness__c,Adoption_Level__c,Engagements__c,Account_Support_AGN__c,Fixed_Consignment_AGN__c,Key_Account_AGN__c,
                                                                Ophthalmology_Profile_AGN__c,Segment__c,Continuum_Placement_AGN__c
                                                                FROM Product_Metrics_vod__c WHERE Account_vod__c = :acc];
        
        List<Product_Metrics_vod__c> delProductMetrics = new List<Product_Metrics_vod__c>();      
        List<Product_vod__c> productGroup = new List<Product_vod__c>(); 
        List<Id> pulledDCRProductId = new List<Id>();
        Set<Id> updProductId = new Set<Id>();
        Set<Id> productGroupId = new Set<Id>();
        
        integer idxDcr = 0;
        
        // Looping through all DCR Product Metrics records under currnet DCR (to update the existing Product Metrics records)
        for(DCR_Product_Metrics_AGN__c dcr_pm : pulledDCRProductMetrics) {
            pulledDCRProductId.add(dcr_pm.Product_AGN__c);      // Will be used later to query the products of type 'Detail Group' from DB
            integer idxDelPM = 0;
            
            // Looping through all Product Metrics records under currnet Account (to update the records with 'Detail' type of Products)
            for(Product_Metrics_vod__c acc_pm : updProductMetrics) {
                if(acc_pm.Products_vod__c == dcr_pm.Product_AGN__c) {
                    
                    // Copying the DCR Product Metrics record data into the existing Product Metrics record instance to be updated into DB
                    acc_pm.Adoption_AGN__c = dcr_pm.Adoption_AGN__c;
                    acc_pm.Adoption_IMS_AGN__c = dcr_pm.Adoption_IMS_AGN__c;
                    acc_pm.Allergan_Potential_AGN__c = dcr_pm.Potential_AGN__c;
                    acc_pm.Potential_IMS_AGN__c = dcr_pm.Potential_IMS_AGN__c;
                    acc_pm.Segment_AGN__c = dcr_pm.Segment_AGN__c;
                    acc_pm.Segment_IMS_AGN__c = dcr_pm.Segment_IMS_AGN__c;
                    acc_pm.Target_AGN__c = dcr_pm.Target_AGN__c;
                    //R005
                    acc_pm.Sector_AGN__c = dcr_pm.Sector_AGN__c;
                    acc_pm.Fase_AGN__c = dcr_pm.Fase_AGN__c;
                    acc_pm.Ratings_AGN__c = dcr_pm.Ratings_AGN__c;
                    acc_pm.Advocacy_Profile_AGN__c = dcr_pm.Advocacy_Profile_AGN__c;
                    acc_pm.Investigator_Readiness__c = dcr_pm.Investigator_Readiness_AGN__c;
                    acc_pm.Customer_Segment_AGN__c = dcr_pm.Customer_Segment_AGN__c;
                    acc_pm.Sales_Target_AGN__c = dcr_pm.Sales_Target_AGN__c;
                    //R007
                    acc_pm.Investigator_smb__c = dcr_pm.Investigator_AGN__c;
                    acc_pm.Profiling_AGN__c = dcr_pm.Profiling_AGN__c;
                    acc_pm.Retina_Profile_AGN__c = dcr_pm.Retina_Profile_AGN__c;
                    acc_pm.Product_Status_AGN__c = dcr_pm.Product_Status_AGN__c;
                    acc_pm.Growth_Potential_AGN__c = dcr_pm.Growth_Potential_AGN__c;
                    acc_pm.Awareness__c = dcr_pm.Awareness_AGN__c;
                    acc_pm.Adoption_Level__c = dcr_pm.Adoption_Level_AGN__c;
                    acc_pm.Engagements__c = dcr_pm.Engagements_AGN__c;
                    acc_pm.Account_Support_AGN__c = dcr_pm.Account_Support_AGN__c;
                    acc_pm.Fixed_Consignment_AGN__c = dcr_pm.Fixed_Consignment_AGN__c;
                    acc_pm.Key_Account_AGN__c = dcr_pm.Key_Account_AGN__c;
                    acc_pm.Ophthalmology_Profile_AGN__c = dcr_pm.Ophthalmology_Profile_AGN__c;
                    acc_pm.Segment__c = dcr_pm.Segment1_AGN__c;
                    //R007.1
                    acc_pm.Continuum_Placement_AGN__c = dcr_pm.Continuum_Placement_AGN__c;
                    
                    // Marking records which are not to be deleted from Product_Metrics_vod__c
                    delProductMetricsMarker[idxDelPM].Products_vod__c = null;
                    
                    // Marking records of DCR_Product_Metrics_vod__c that are not to be inserted into Product_Metrics_vod__c
                    pulledDCRProductMetrics[idxDcr].Product_AGN__c = null;
                }
                idxDelPM++;
            }
            idxDcr++;
        }
        
        // Looping through all DCR Product Metrics records under currnet DCR (to create the non-existing Product Metrics records)
        for(DCR_Product_Metrics_AGN__c dcr_pm : pulledDCRProductMetrics) {
            if(dcr_pm.Product_AGN__c != null) {
                Product_Metrics_vod__c acc_pm = new Product_Metrics_vod__c();
                // Copying the DCR Product Metrics record data into the newly create Product Metrics instance to be inserted into DB
                acc_pm.Account_vod__c = acc;
                acc_pm.Products_vod__c = dcr_pm.Product_AGN__c;
                acc_pm.Detail_Group_vod__c = dcr_pm.Detail_Group_AGN__c;
                acc_pm.Adoption_AGN__c = dcr_pm.Adoption_AGN__c;
                acc_pm.Adoption_IMS_AGN__c = dcr_pm.Adoption_IMS_AGN__c;
                acc_pm.Allergan_Potential_AGN__c = dcr_pm.Potential_AGN__c;
                acc_pm.Potential_IMS_AGN__c = dcr_pm.Potential_IMS_AGN__c;
                acc_pm.Segment_AGN__c = dcr_pm.Segment_AGN__c;
                acc_pm.Segment_IMS_AGN__c = dcr_pm.Segment_IMS_AGN__c;
                acc_pm.Target_AGN__c = dcr_pm.Target_AGN__c;
                //R005
                acc_pm.Sector_AGN__c = dcr_pm.Sector_AGN__c;
                acc_pm.Fase_AGN__c = dcr_pm.Fase_AGN__c;
                acc_pm.Ratings_AGN__c = dcr_pm.Ratings_AGN__c;
                acc_pm.Advocacy_Profile_AGN__c = dcr_pm.Advocacy_Profile_AGN__c;
                acc_pm.Investigator_Readiness__c = dcr_pm.Investigator_Readiness_AGN__c;
                acc_pm.Customer_Segment_AGN__c = dcr_pm.Customer_Segment_AGN__c;
                acc_pm.Sales_Target_AGN__c = dcr_pm.Sales_Target_AGN__c;
                //R007
                acc_pm.Investigator_smb__c = dcr_pm.Investigator_AGN__c;
                acc_pm.Profiling_AGN__c = dcr_pm.Profiling_AGN__c;
                acc_pm.Retina_Profile_AGN__c = dcr_pm.Retina_Profile_AGN__c;
                acc_pm.Product_Status_AGN__c = dcr_pm.Product_Status_AGN__c;
                acc_pm.Growth_Potential_AGN__c = dcr_pm.Growth_Potential_AGN__c;
                acc_pm.Awareness__c = dcr_pm.Awareness_AGN__c;
                acc_pm.Adoption_Level__c = dcr_pm.Adoption_Level_AGN__c;
                acc_pm.Engagements__c = dcr_pm.Engagements_AGN__c;
                acc_pm.Account_Support_AGN__c = dcr_pm.Account_Support_AGN__c;
                acc_pm.Fixed_Consignment_AGN__c = dcr_pm.Fixed_Consignment_AGN__c;
                acc_pm.Key_Account_AGN__c = dcr_pm.Key_Account_AGN__c;
                acc_pm.Ophthalmology_Profile_AGN__c = dcr_pm.Ophthalmology_Profile_AGN__c;
                acc_pm.Segment__c = dcr_pm.Segment1_AGN__c;         
                insProductMetrics.add(acc_pm);
                //R007.1
                acc_pm.Continuum_Placement_AGN__c = dcr_pm.Continuum_Placement_AGN__c;
            }
        }
        
        // Getting the Products of type 'Detail Group' from DB
        productGroup = [SELECT Id,Name FROM Product_vod__c WHERE Id IN (SELECT Product_Catalog_vod__c FROM Product_Group_vod__c WHERE Product_vod__c IN :pulledDCRProductId)];
        for(Product_vod__c pg: productGroup) {
            productGroupId.add(pg.id);
        }
        
        // Consolidating the Product Metrics records to be deleted using delProductMetricsMarker
        for(Product_Metrics_vod__c acc_pm : delProductMetricsMarker) {
            if(acc_pm.Products_vod__c != null && acc_pm.Products_vod__r.Product_Type_vod__c != 'Detail Group') {
                delProductMetrics.add(acc_pm);
            }
        }
        
        // Looping through all Product Metrics records under currnet Account (add the unnecessary records with Product of type 'Detail Group' to the Product Metrics delete list)
        for(Product_Metrics_vod__c acc_pm : updProductMetrics) {
            if(!(productGroupId.contains(acc_pm.Products_vod__c)) && acc_pm.Products_vod__r.Product_Type_vod__c == 'Detail Group') {
                delProductMetrics.add(acc_pm);
            }
            updProductId.add(acc_pm.Products_vod__c);
        }
        
        // Looping through the queried Detail Group records and add to Product Metrics insert list if not exists
        for(Product_vod__c pg : productGroup) {
            if(!(updProductId.contains(pg.id))) {
                Product_Metrics_vod__c acc_pm = new Product_Metrics_vod__c();
                // Setting the data for the newly create Product Metrics instance to be inserted into DB
                acc_pm.Account_vod__c = acc;
                acc_pm.Products_vod__c = pg.id;
                insProductMetrics.add(acc_pm);
            }
        } 
        insert insProductMetrics;
        update updProductMetrics;
        delete delProductMetrics;
    }
}