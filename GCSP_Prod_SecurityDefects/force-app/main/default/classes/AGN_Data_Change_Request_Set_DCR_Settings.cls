public class AGN_Data_Change_Request_Set_DCR_Settings {
    
    @InvocableMethod
    public static void setDCRSettings(List<Data_Change_Request_vod__c> dcrList){
        
        system.debug('## Enter setDCRSettings() dcrList: '+dcrList);
        List<DCR_Configuration_Settings_AGN__c> dcrConfigSettingsList = new List<DCR_Configuration_Settings_AGN__c>();
        Map<ID,String> countryMap = new Map<ID,String>();
        Map<ID,String> rTypeMap = new Map<ID,String>();
        Map<ID,List<DCR_Configuration_Settings_AGN__c>> dcrConfigSettingsMap = new Map<ID,List<DCR_Configuration_Settings_AGN__c>>();
        List<Data_Change_Request_vod__c> dcrToUpdate = new List<Data_Change_Request_vod__c>();
        Data_Change_Request_vod__c parentDCR = new Data_Change_Request_vod__c();
        Map<ID,Data_Change_Request_vod__c> childDCRMap = new Map<ID,Data_Change_Request_vod__c>();
        String pAccId;
        String cAccId;
        String accExtId;
        String childAccExtId;
        
        try{
            for(Country_vod__c country : [select ID, Alpha_2_Code_vod__c, Cluster_Country_AGN__c from Country_vod__c]){
                //system.debug('## inside Country Map FOR Loop country.ID: '+ country.ID + '          country.Alpha_2_Code_vod__c: '+country.Alpha_2_Code_vod__c+'          country.Cluster_Country_AGN__c: '+country.Cluster_Country_AGN__c);
                if(country.Alpha_2_Code_vod__c != null && country.Alpha_2_Code_vod__c != ''){
                    /*if(country.Cluster_Country_AGN__c != null && country.Cluster_Country_AGN__c != ''){
                        countryMap.put(country.ID, country.Cluster_Country_AGN__c);
                    }else{
                        countryMap.put(country.ID, country.Alpha_2_Code_vod__c);
                    }*/  
                    countryMap.put(country.ID, country.Alpha_2_Code_vod__c);
                }
                
            }
            system.debug('## after Country Map countryMap: '+countryMap);
            for(RecordType rType : [select Id, Name from RecordType where SObjectType = 'Data_Change_Request_vod__c']){            
                rTypeMap.put(rType.Id, rType.Name);            
            }            
            
            for(Data_Change_Request_vod__c dcr : dcrList){                
                dcrConfigSettingsList = new List<DCR_Configuration_Settings_AGN__c>();
                if(dcr.Parent_Data_Change_Request_vod__c != null){
                    system.debug('## IS NOT PARENT: '+dcr);
                    parentDCR = [select ID, Data_Provider_Managed_AGN__c, DCR_Approver_AGN__c, Company_Managed_AGN__c, Country_AGN__c, DCR_Status_AGN__c, Country_Code_AGN__c,
                                 Provisional_Contact_Required_AGN__c, Secondary_Approver_AGN__c, MDM_Managed_AGN__c, Account_vod__c, Account_vod__r.IsPersonAccount 
                                 from Data_Change_Request_vod__c 
                                 where ID = :dcr.Parent_Data_Change_Request_vod__c 
                                 LIMIT 1 
                                ];
                    childDCRMap.put(dcr.ID, parentDCR);
                }else{
                    system.debug('## IS PARENT: '+dcr);
                    dcrConfigSettingsList = AGN_DCR2_Utilities.FetchDCRConfigSettings(dcr.CreatedById,countryMap.get(dcr.Country_AGN__c));
                    if(dcrConfigSettingsList != null || dcrConfigSettingsList.size() > 0){
                        dcrConfigSettingsMap.put(dcr.Id, dcrConfigSettingsList);
                    }
                }
                
            }
            
            if(dcrConfigSettingsMap.size()>0){
                
                for(Data_Change_Request_vod__c dcr : [select ID, Data_Provider_Managed_AGN__c, DCR_Approver_AGN__c, Company_Managed_AGN__c,MDM_Managed_AGN__c, 
                                                      Country_AGN__c, DCR_Settings_Applied_AGN__c, Error_vod__c, Provisional_Contact_Required_AGN__c, Country_Code_AGN__c,
                                                      RecordTypeId, Type_vod__c, Account_vod__c, Address_vod__c, Child_Account_vod__c, 
                                                      Secondary_Approver_AGN__c,Reps_Selected_Self_Manged_AGN__c
                                                      from Data_Change_Request_vod__c
                                                      where ID in :dcrConfigSettingsMap.keySet()
                                                     ])
                {
                    if((dcrConfigSettingsMap.get(dcr.ID)).size() > 0 ){
                       
                        for(DCR_Configuration_Settings_AGN__c dcrSettings : dcrConfigSettingsMap.get(dcr.ID)){
                            //Start DCR Update 2019 
                            if(dcr.Reps_Selected_Self_Manged_AGN__c== TRUE){
                            dcr.Data_Provider_Managed_AGN__c = FALSE;
                            dcr.Company_Managed_AGN__c = TRUE;   
                            }else{
                            dcr.Data_Provider_Managed_AGN__c = dcrSettings.Data_Provider_Managed_AGN__c;
                            dcr.Company_Managed_AGN__c = dcrSettings.Company_Managed_AGN__c;
                            }
                            //END
                            dcr.DCR_Approver_AGN__c = dcrSettings.Local_Approver_AGN__c;
                            dcr.Provisional_Contact_Required_AGN__c = dcrSettings.Provisional_Contact_Required_AGN__c;
                            dcr.Secondary_Approver_AGN__c = dcrSettings.Secondary_Approver_AGN__c;
                            dcr.MDM_Managed_AGN__c = dcrSettings.MDM_Managed_AGN__c;
                            dcr.Country_Code_AGN__c = countryMap.get(dcr.Country_AGN__c);
                            dcr.DCR_Settings_Applied_AGN__c = true;
                        }
                        
                    }
                    if(rTypeMap.get(dcr.RecordTypeId) == 'Account_vod' && dcr.Type_vod__c == 'Edit_vod'){
                        accExtId = [select External_ID_vod__c from Account where Id = :dcr.Account_vod__c LIMIT 1].External_ID_vod__c;
                        if(accExtId != null){
                            dcr.Data_Provider_Managed_AGN__c = TRUE;
                            dcr.Company_Managed_AGN__c = FALSE;                            
                        }else{
                            dcr.Data_Provider_Managed_AGN__c = FALSE;
                            dcr.Company_Managed_AGN__c = TRUE;                             
                        }
                    }
                    if(rTypeMap.get(dcr.RecordTypeId) == 'Address_vod'){
                        if(dcr.Type_vod__c == 'Edit_vod' || dcr.Type_vod__c == 'Delete_vod'){
                        	accExtId = [select Account_vod__r.External_ID_vod__c from Address_vod__c where Id = :dcr.Address_vod__c LIMIT 1].Account_vod__r.External_ID_vod__c;
                        }else if(dcr.Type_vod__c == 'New_vod'){
                            pAccId = [select New_Value_vod__c from Data_Change_Request_Line_vod__c where Data_Change_Request_vod__c = :dcr.Id AND Field_API_Name_vod__c = 'Account_vod__c' LIMIT 1].New_Value_vod__c;
                            accExtId = [select External_ID_vod__c from Account where Id = :pAccId LIMIT 1].External_ID_vod__c;
                        }
                        if(accExtId != null){
                            dcr.Data_Provider_Managed_AGN__c = TRUE;
                            dcr.Company_Managed_AGN__c = FALSE;                            
                        }else{
                            dcr.Data_Provider_Managed_AGN__c = FALSE;
                            dcr.Company_Managed_AGN__c = TRUE;                             
                        }
                    }
                    if(rTypeMap.get(dcr.RecordTypeId) == 'Child_Account_vod'){
                        if(dcr.Type_vod__c == 'Edit_vod' || dcr.Type_vod__c == 'Delete_vod'){
                        	accExtId = [select Parent_Account_vod__r.External_ID_vod__c from Child_Account_vod__c where Id = :dcr.Child_Account_vod__c LIMIT 1].Parent_Account_vod__r.External_ID_vod__c;
                        	childAccExtId = [select Child_Account_vod__r.External_ID_vod__c from Child_Account_vod__c where Id = :dcr.Child_Account_vod__c LIMIT 1].Child_Account_vod__r.External_ID_vod__c;                            
                        }else if(dcr.Type_vod__c == 'New_vod'){
                            pAccId = [select New_Value_vod__c from Data_Change_Request_Line_vod__c where Data_Change_Request_vod__c = :dcr.Id AND Field_API_Name_vod__c = 'Parent_Account_vod__c' LIMIT 1].New_Value_vod__c;
                            cAccId = [select New_Value_vod__c from Data_Change_Request_Line_vod__c where Data_Change_Request_vod__c = :dcr.Id AND Field_API_Name_vod__c = 'Child_Account_vod__c' LIMIT 1].New_Value_vod__c;
                            accExtId = [select External_ID_vod__c from Account where Id = :pAccId LIMIT 1].External_ID_vod__c;
                            childAccExtId = [select External_ID_vod__c from Account where Id = :cAccId LIMIT 1].External_ID_vod__c;
                        }
                        if(accExtId != null && childAccExtId != null){
                            dcr.Data_Provider_Managed_AGN__c = TRUE;
                            dcr.Company_Managed_AGN__c = FALSE;                            
                        }else{
                            dcr.Data_Provider_Managed_AGN__c = FALSE;
                            dcr.Company_Managed_AGN__c = TRUE;                             
                        }
                    }
                    dcrToUpdate.add(dcr);
                }            
            }
            
            if(childDCRMap.size()>0){
                system.debug('## childDCRMap.size() > 0');
                for(Data_Change_Request_vod__c childDCR : [select ID, Data_Provider_Managed_AGN__c, DCR_Approver_AGN__c, Company_Managed_AGN__c, 
                                                           Country_AGN__c, Provisional_Contact_Required_AGN__c, DCR_Settings_Applied_AGN__c,
                                                           Secondary_Approver_AGN__c, MDM_Managed_AGN__c, RecordType.Name, DCR_Status_AGN__c, Country_Code_AGN__c
                                                           from Data_Change_Request_vod__c 
                                                           where ID in :childDCRMap.keySet()
                                                          ])
                {
                    system.debug('## Child DCR ID : ' + childDCR.Id);
                    parentDCR = childDCRMap.get(childDCR.ID);
                    childDCR.Country_Code_AGN__c = parentDCR.Country_Code_AGN__c;
                    childDCR.Country_AGN__c = parentDCR.Country_AGN__c;
                    childDCR.Data_Provider_Managed_AGN__c = parentDCR.Data_Provider_Managed_AGN__c;
                    childDCR.DCR_Approver_AGN__c = parentDCR.DCR_Approver_AGN__c;
                    childDCR.Company_Managed_AGN__c = parentDCR.Company_Managed_AGN__c;
                    if(childDCR.RecordType.Name != 'Address_vod' || parentDCR.Account_vod__r.IsPersonAccount == false){
                        childDCR.Provisional_Contact_Required_AGN__c = parentDCR.Provisional_Contact_Required_AGN__c;
                    }
                    childDCR.Secondary_Approver_AGN__c = parentDCR.Secondary_Approver_AGN__c;
                    childDCR.MDM_Managed_AGN__c = parentDCR.MDM_Managed_AGN__c;
                    childDCR.DCR_Status_AGN__c = parentDCR.DCR_Status_AGN__c;
                    childDCR.DCR_Settings_Applied_AGN__c = true;
                    dcrToUpdate.add(childDCR);
                }
            }
            if(dcrToUpdate.size()>0){
                update dcrToUpdate;
            }               
        }catch(System.Exception e){
            for(Data_Change_Request_vod__c dcr : dcrToUpdate){
                if(dcr.Error_vod__c != null || dcr.Error_vod__c != ''){
                    dcr.Error_vod__c = dcr.Error_vod__c + e.getMessage();
                }else{
                    dcr.Error_vod__c = e.getMessage();
                }
            }
            system.debug('## Exception: ' + e + ' ## Cause: ' + e.getCause() + ' ## Type: ' + e.getTypeName() + ' ## Line: ' + e.getLineNumber());            
        }
    }
}