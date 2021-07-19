public class AGN_DCR_Defects_Handling {
    
    List<Data_Change_Request_vod__c> primary_parent_defected_DCR_lst = new List<Data_Change_Request_vod__c>();
    List<Data_Change_Request_vod__c> SAP_defected_DCR_lst = new List<Data_Change_Request_vod__c>();
    List<Data_Change_Request_vod__c> total_defected_DCR_list = new List<Data_Change_Request_vod__c>();
    
    public void get_Defected_DCR_Line(List<Data_Change_Request_Line_vod__c> dcr_line_lst){
    	
        List<Data_Change_Request_vod__c> final_defected_DCR_list = new List<Data_Change_Request_vod__c>();
        primary_parent_defected_DCR_lst = set_primary_parent_defected_DCR(dcr_line_lst);
        SAP_defected_DCR_lst = set_SAP_defected_DCR(dcr_line_lst);
        total_defected_DCR_list.addAll(primary_parent_defected_DCR_lst);
        total_defected_DCR_list.addAll(SAP_defected_DCR_lst);
        system.debug('##total_defected_DCR_list : '+ total_defected_DCR_list);
        
        for(Data_Change_Request_vod__c dcr : total_defected_DCR_list){
        	Boolean duplicate = false;
            for(Data_Change_Request_vod__c dcr_final : final_defected_DCR_list){
                if(dcr.Id == dcr_final.Id){
                    duplicate = true;
                    break;
                }
            }
            if(!duplicate) final_defected_DCR_list.add(dcr);
        }
        system.debug('##final_defected_DCR_list : '+ final_defected_DCR_list);
        
        if(final_defected_DCR_list.size() > 0) update_defected_DCR_list(final_defected_DCR_list);
    }
    public List<Data_Change_Request_vod__c> set_primary_parent_defected_DCR(List<Data_Change_Request_Line_vod__c> dcr_line_lst){
        system.debug('## set_primary_parent_defected_DCR method -> dcr_line_lst : '+ dcr_line_lst);
        List<Account> account_lst = new List<Account>();
        List<Data_Change_Request_Line_vod__c> temp_dcr_line_lst = new List<Data_Change_Request_Line_vod__c>();
        List<Data_Change_Request_vod__c> dcr_lst = new List<Data_Change_Request_vod__c>();
        Set<Id> dcr_id_set = new set<Id>(); 
        List<Id> primary_parent_id = new List<Id>();
        for(Data_Change_Request_Line_vod__c dcr_line : dcr_line_lst){
            if(dcr_line.Field_API_Name_vod__c=='Primary_Parent_vod__c'){
                primary_parent_id.add(dcr_line.New_Value_vod__c);
                temp_dcr_line_lst.add(dcr_line);
            }
        }
        system.debug('##primary_parent_id : '+ primary_parent_id);
        system.debug('##temp_dcr_line_lst : '+ temp_dcr_line_lst);
        if(primary_parent_id.size() > 0){
            account_lst = [select Id,ispersonaccount from Account where id in: primary_parent_id and ispersonaccount =: true];
            system.debug('##account_lst : '+ account_lst);
            
            if(account_lst.size() > 0){
                for(Account acc : account_lst){
                    for(Data_Change_Request_Line_vod__c dcr_line : temp_dcr_line_lst){
                        if(dcr_line.New_Value_vod__c == acc.Id){
                            dcr_id_set.add(dcr_line.Data_Change_Request_vod__c);
                        }
                    }
                }
                system.debug('##dcr_id_set : '+ dcr_id_set);
                
                dcr_lst = [select Id,DCR_Status_AGN__c,Status_vod__c,Published_to_Interface_AGN__c,Data_Provider_Managed_AGN__c,
                           Data_Provider_Comment_AGN__c,Approver_Comment_AGN__c,Company_Managed_AGN__c,DCR_Defect_Reason_AGN__c 
                           from Data_Change_Request_vod__c where Id in: dcr_id_set];
                system.debug('##dcr_lst : '+ dcr_lst);
                
                for(Data_Change_Request_vod__c dcr : dcr_lst){
                    dcr.DCR_Defect_Reason_AGN__c = 'Parent Account is HCP';
                }
            }
        }
        system.debug('##outside IF updated_dcr_lst : '+ dcr_lst);
        return dcr_lst ;
    }
    
    public List<Data_Change_Request_vod__c> set_SAP_defected_DCR(List<Data_Change_Request_Line_vod__c> dcr_line_lst){
        system.debug('##set_SAP_defected_DCR method -> dcr_line_lst : '+ dcr_line_lst);
        List<Account> account_lst = new List<Account>();
        List<Data_Change_Request_Line_vod__c> temp_dcr_line_lst = new List<Data_Change_Request_Line_vod__c>();
        List<Data_Change_Request_vod__c> dcr_lst = new List<Data_Change_Request_vod__c>();
        List<String> SAP_id = new List<String>();
        Set<Id> dcr_id_set = new set<Id>(); 
        for(Data_Change_Request_Line_vod__c dcr_line : dcr_line_lst){
            if(dcr_line.Field_API_Name_vod__c=='External_ID2_AGN__c'){
                SAP_id.add(dcr_line.New_Value_vod__c);
                temp_dcr_line_lst.add(dcr_line);
            }
        }
        system.debug('##SAP_id : '+ SAP_id);
        system.debug('##temp_dcr_line_lst : '+ temp_dcr_line_lst);
        
        if(SAP_id.size() > 0){
            account_lst = [select Id,External_ID2_AGN__c from Account where External_ID2_AGN__c in: SAP_id];
            system.debug('##account_lst : '+ account_lst);
            for(Account acc : account_lst){
                for(Data_Change_Request_Line_vod__c dcr_line : temp_dcr_line_lst){
                    if(dcr_line.New_Value_vod__c == acc.External_ID2_AGN__c){
                        dcr_id_set.add(dcr_line.Data_Change_Request_vod__c);
                    }
                }
            }
            system.debug('##dcr_id_set : '+ dcr_id_set);
            
            dcr_lst = [select Id,DCR_Status_AGN__c,Status_vod__c,Published_to_Interface_AGN__c,Data_Provider_Managed_AGN__c,
                       Data_Provider_Comment_AGN__c,Approver_Comment_AGN__c,Company_Managed_AGN__c,DCR_Defect_Reason_AGN__c 
                       from Data_Change_Request_vod__c where Id in: dcr_id_set];
            system.debug('##dcr_lst : '+ dcr_lst);
            
            for(Data_Change_Request_vod__c dcr : dcr_lst){
                dcr.DCR_Defect_Reason_AGN__c = 'Duplicate SAP Id';
            }
        }
        
        system.debug('##outside IF updated_dcr_lst : '+ dcr_lst);
        return dcr_lst;
    }
    
    public void update_defected_DCR_list(List<Data_Change_Request_vod__c> final_DCRs){
        update final_DCRs;
        system.debug('##update_defected_DCR_list method : '+ final_DCRs);
    }
}