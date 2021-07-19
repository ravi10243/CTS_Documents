/*-------------------------------------------------------------------------------------------------------
* @author         Namrata Kundu
* @createdBy      
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        
* @testClass     
* @Class Name    Batch_To_Validate_with_DP_AGN
* --------------------------------------------------------------------------------------------------------
* @description -  
*/
public class Batch_To_Validate_with_DP_AGN implements Database.Batchable<SObject>, Database.Stateful  {

    static DCR_Validate_To_DP_AGN__c dcrConstants;

    public Database.QueryLocator start(Database.BatchableContext context) {
         return Database.getQueryLocator([SELECT Country_vod__c,Country_Code__c,Country_Name_AGN__c,Id,Name FROM Account WHERE 
                                          Ready_For_DCR_AGN__c  = TRUE AND Sent_to_DP_AGN__c = FALSE AND
                                          External_ID_vod__c = null AND Account.Country_vod__r.Data_Provider_Managed_AGN__c = true
                                          AND Account.Country_vod__r.DCR_To_IQVIA_AGN__c = true]);
    }
    
    public void execute(Database.BatchableContext context, List<Account> scope){  
        system.debug('## Inside Batch_To_Validate_with_DP_AGN.execute()'+scope);
        string accCountryId;
        string accCountryName;
        List<Data_Change_Request_vod__c> dcrList = new List<Data_Change_Request_vod__c>();
        List<Account> accountListToUpdate = new List<Account>();
        List<Data_Change_Request_Line_vod__c> dcrLineList = new List<Data_Change_Request_Line_vod__c>();
        List<DCR_Configuration_Settings_AGN__c> dcrAdminSettingList =[SELECT Company_Managed_AGN__c,Country_Code_AGN__c,Data_Provider_Managed_AGN__c,Local_Approver_AGN__c,MDM_Managed_AGN__c,Provisional_Contact_Required_AGN__c,Secondary_Approver_AGN__c FROM DCR_Configuration_Settings_AGN__c WHERE Profile_AGN__c = 'System Administrator'];
        ID dcrRecordType = [select Id from RecordType where sObjectType = 'Data_Change_Request_vod__c' and Name = 'Account_vod' LIMIT 1].Id;
        for(Account acc: scope){  
            
        Data_Change_Request_vod__c dcr = new Data_Change_Request_vod__c();
        Account accountToUpdate = new Account();
        dcrConstants = DCR_Validate_To_DP_AGN__c.getInstance();
        dcr.RecordTypeId = dcrRecordType;
        dcr.Type_vod__c = dcrConstants.Type__c;
        dcr.Date_Time_vod__c = System.now();
        dcr.Country_AGN__c = acc.Country_vod__c;
        dcr.Country_Code_AGN__c = acc.Country_Code__c; 
        dcr.Status_vod__c = dcrConstants.Status__c;
        dcr.DCR_Status_AGN__c = dcrConstants.DCR_Status__c;   
        dcr.Account_vod__c = acc.Id;
        dcr.Account_Validation_DCR_AGN__c = TRUE;
        dcr.OwnerId = UserInfo.getUserId();
        dcr.Notes_vod__c = dcrConstants.DCR_Notes__c;
        dcr.DCR_Settings_Applied_AGN__c = TRUE;
        
        for(DCR_Configuration_Settings_AGN__c dcrAdminSetting : dcrAdminSettingList){
           if(acc.Country_Code__c == dcrAdminSetting.Country_Code_AGN__c){
              dcr.Data_Provider_Managed_AGN__c = dcrAdminSetting.Data_Provider_Managed_AGN__c;
              dcr.Company_Managed_AGN__c = dcrAdminSetting.Company_Managed_AGN__c;
              dcr.MDM_Managed_AGN__c = dcrAdminSetting.MDM_Managed_AGN__c;
              dcr.Provisional_Contact_Required_AGN__c = dcrAdminSetting.Provisional_Contact_Required_AGN__c;
              dcr.DCR_Approver_AGN__c = dcrAdminSetting.Local_Approver_AGN__c;
              dcr.Secondary_Approver_AGN__c = dcrAdminSetting.Secondary_Approver_AGN__c;
              dcr.Created_from_GCSP_AGN__c = TRUE;
                
            }    
        }
        accountToUpdate.ID = acc.Id;
        accountToUpdate.Sent_to_DP_AGN__c =TRUE;
        dcrList.add(dcr);
        accountListToUpdate.add(accountToUpdate);
        
        }
        Savepoint sp = Database.setSavepoint();        
        system.debug('## Inside Batch_To_Validate_with_DP_AGN.execute(). Before Insert dcrList: ' + dcrList);        
       
        try{
            insert dcrList;
        }catch(System.Exception e){
            system.debug('## Exception encountered while inserting DCR. Exception: ' + e);
            Database.rollback(sp);
        }
        system.debug('## Inside Batch_To_Validate_with_DP_AGN.execute(). After Insert dcrList: ' + dcrList); 
        
        
        for(Data_Change_Request_vod__c dcrRecord :dcrList){
            
        	accCountryId = dcrRecord.Country_AGN__c;
        	accCountryName = dcrRecord.Country_Code_AGN__c; 
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
            Data_Change_Request_Line_vod__c dcrLine = new Data_Change_Request_Line_vod__c(Data_Change_Request_vod__c = dcrRecord.Id, Field_API_Name_vod__c = 'Country_vod__c', Field_Name_vod__c = fieldMap.get('Country_vod__c').getDescribe().getLabel(), New_Value_vod__c = accCountryId, New_Localized_Value_vod__c = accCountryName);
            dcrLineList.add(dcrLine);
        }
        
        sp = Database.setSavepoint(); 
        system.debug('## Inside Batch_To_Validate_with_DP_AGN.execute(). Before Insert dcrLineList: ' + dcrLineList);        
        try{ 
				insert dcrLineList;                
        }           
        catch(System.Exception e){
            system.debug('@@ Exception encountered while inserting DCR Line. Exception: ' + e);
            Database.rollback(sp);         
        }
        system.debug('## Inside Batch_To_Validate_with_DP_AGN.execute(). After Insert dcrLineList: ' + dcrLineList); 
        
        try{
            if(Schema.sObjectType.Account.fields.Sent_to_DP_AGN__c.isUpdateable() && Account.sObjectType.getDescribe().isUpdateable()){
                 update accountListToUpdate;
            }  
        }catch(System.Exception e){
            system.debug('@@ Exception encountered while updating Sent to DP in Account. Exception: ' + e);
            Database.rollback(sp);
        }
    }
    
    public void finish(Database.BatchableContext context) {
    }

}