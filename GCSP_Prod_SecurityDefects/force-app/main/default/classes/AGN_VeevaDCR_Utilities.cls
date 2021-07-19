public without sharing class AGN_VeevaDCR_Utilities {
    
    static string accCountryId;
    static string accCountryName;
    static DCR_Config_Settings_AGN__c dcrSettings;
    static string dcrNotes;
    
    public static String createAccountDCR(Account acc, String caseNumber, String countryId){
        
        system.debug('## Inside AGN_VeevaDCR_Utilities.createAccountDCR()');
        
        Data_Change_Request_vod__c dcr = new Data_Change_Request_vod__c();
        List<Data_Change_Request_Line_vod__c> dcrLineList = new List<Data_Change_Request_Line_vod__c>();
        accCountryId = countryId;
        accCountryName = [select NAME from Country_vod__c where Id = :accCountryId].NAME;
        dcrSettings = DCR_Config_Settings_AGN__c.getInstance();
        system.debug('## Inside AGN_VeevaDCR_Utilities.createAccountDCR(). accCountryId: ' + accCountryId + '    accCountryName: ' + accCountryName);
        
        dcr.RecordTypeId = [select Id from RecordType where sObjectType = 'Data_Change_Request_vod__c' and Name = 'Account_vod' LIMIT 1].Id;
        dcr.Type_vod__c = 'New_vod';
        dcr.Date_Time_vod__c = System.now();
        dcr.Status_vod__c = 'Submitted_vod';
        dcr.DCR_Status_AGN__c = 'Pending for Approval';   
        dcr.Account_vod__c = acc.Id;
        
        /* R14: Following lines were added/modified to meet the requirement PMO # 1797 */
        if(caseNumber == 'ValidateDCR'){
            dcr.Account_Validation_DCR_AGN__c = TRUE;
            dcr.OwnerId = UserInfo.getUserId();
            dcr.Notes_vod__c = dcrNotes;
        }else{
            dcr.Notes_vod__c = Label.AGN_Created_from_GCSP + caseNumber;
            dcr.Created_from_GCSP_AGN__c = TRUE;
            dcr.OwnerId = dcrSettings.Integration_User_ID_AGN__c;    
        }
        
        Savepoint sp = Database.setSavepoint();
        
        /* **********End of R14 changes********** */
        
        system.debug('## Inside AGN_VeevaDCR_Utilities.createAccountDCR(). Before Insert dcr: ' + dcr);        
       
        try{
            insert dcr;
        }catch(System.Exception e){
            system.debug('@@ Exception encountered while inserting DCR. Exception: ' + e);
            Database.rollback(sp);
            return 'Error';
        }
        
        system.debug('## Inside AGN_VeevaDCR_Utilities.createAccountDCR(). After Insert dcr: ' + dcr); 
        
        
        try{
            /* R14: Following lines were added/modified to meet the requirement PMO # 1797 */
            if(caseNumber == 'ValidateDCR'){
                Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap();
                Data_Change_Request_Line_vod__c dcrLine = new Data_Change_Request_Line_vod__c(Data_Change_Request_vod__c = dcr.Id, Field_API_Name_vod__c = 'Country_vod__c', Field_Name_vod__c = fieldMap.get('Country_vod__c').getDescribe().getLabel(), New_Value_vod__c = accCountryId, New_Localized_Value_vod__c = accCountryName);
				insert dcrLine;                
            }else{
                dcrLineList = getDCRLines(acc, dcr.Id);
                insert dcrLineList;
            }           
        }catch(System.Exception e){
            system.debug('@@ Exception encountered while inserting DCR Line. Exception: ' + e);
            Database.rollback(sp);
            return 'Error';            
        }
        /* **********End of R14 changes********** */
        
        return dcr.Id;
        
    }
    
    public static void createAddressDCR(Address_vod__c addr, String acctDCRId, String caseNumber){
        
        system.debug('## Inside AGN_VeevaDCR_Utilities.createAddressDCR()');
        
        Data_Change_Request_vod__c dcr = new Data_Change_Request_vod__c();
        List<Data_Change_Request_Line_vod__c> dcrLineList = new List<Data_Change_Request_Line_vod__c>();   
        dcrSettings = DCR_Config_Settings_AGN__c.getInstance();
        
        dcr.RecordTypeId = [select Id from RecordType where sObjectType = 'Data_Change_Request_vod__c' and Name = 'Address_vod' LIMIT 1].Id;
        dcr.Type_vod__c = 'New_vod';
        dcr.Date_Time_vod__c = System.now();
        dcr.Status_vod__c = 'Submitted_vod';
        dcr.DCR_Status_AGN__c = 'Pending for Approval';   
        dcr.Address_vod__c = addr.Id;        
        dcr.Account_vod__c = addr.Account_vod__c;
        dcr.Parent_Data_Change_Request_vod__c = acctDCRId;
        dcr.Notes_vod__c = Label.AGN_Created_from_GCSP + caseNumber;
        dcr.Created_from_GCSP_AGN__c = TRUE;
        dcr.OwnerId = dcrSettings.Integration_User_ID_AGN__c;        
        
        insert dcr;
        system.debug('## Inside AGN_VeevaDCR_Utilities.createAddressDCR(). After Insert dcr: ' + dcr); 
        
        dcrLineList = getDCRLines(addr, dcr.Id);
        insert dcrLineList;        
        
    }
    
    static List<Data_Change_Request_Line_vod__c> getDCRLines(SObject sObjectName, String dcrId){
        
        system.debug('## Inside AGN_VeevaDCR_Utilities.getDCRLines(). sObjectName: ' + sObjectName);
        
        List<Data_Change_Request_Line_vod__c> dcrLineList = new List<Data_Change_Request_Line_vod__c>();
        Data_Change_Request_Line_vod__c dcrLine;
        
        String objectName = String.valueOf(sObjectName.getSObjectType());
        
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        String lookUpObjName;
        String fieldValue;
        
        for(String fieldName : fieldMap.keySet()){
            dcrLine = new Data_Change_Request_Line_vod__c();
            if(fieldName == 'CurrencyIsoCode' || fieldName == 'OwnerId' || fieldName == 'CreatedById' || fieldName == 'LastModifiedById' || 
               fieldName == 'CreatedDate' || fieldName == 'LastModifiedByDate' || fieldName == 'Id' || fieldName == 'IsDeleted' || 
               fieldName == 'IsLocked' || fieldName == 'LastActivityDate ' || fieldName == 'LastViewedDate ' ||fieldName == 'MayEdit' || 
               fieldName == 'SystemModstamp' || fieldName == 'masterrecordid' || fieldMap.get(fieldName).getDescribe().isCalculated() == TRUE){                   
                   continue;            
               }else{
                   system.debug('## Inside AGN_VeevaDCR_Utilities.getDCRLines(). fieldName: ' + fieldName + '    fieldValue: ' + fieldValue);                   
                   fieldValue = String.valueOf(sObjectName.get(fieldName));
                   if(fieldName == 'Country_vod__c' && (fieldValue == null || fieldValue == '')){
                       dcrLine.Field_API_Name_vod__c = fieldName;
                       dcrLine.Field_Name_vod__c = fieldMap.get(fieldName).getDescribe().getLabel();
                       dcrLine.New_Value_vod__c = accCountryId;
                       dcrLine.New_Localized_Value_vod__c = accCountryName;
                       dcrLine.Data_Change_Request_vod__c = dcrId;
                       dcrLineList.add(dcrLine);
                       continue;
                   }else if(fieldValue != null && fieldValue != ''){
                       if(fieldMap.get(fieldName).getDescribe().getType().name() == 'MultiPicklist'){
                           continue;
                       }else{                    
                           dcrLine.Field_API_Name_vod__c = fieldName;
                           dcrLine.Field_Name_vod__c = fieldMap.get(fieldName).getDescribe().getLabel();
                           dcrLine.New_Value_vod__c = fieldValue;
                           system.debug('@@ dcrLine.Field_API_Name_vod__c: ' + dcrLine.Field_API_Name_vod__c + '   dcrLine.Field_Name_vod__c: ' + dcrLine.Field_Name_vod__c + '   dcrLine.New_Value_vod__c: ' + dcrLine.New_Value_vod__c);
                           if(fieldMap.get(fieldName).getDescribe().getType().name() == 'Picklist'){
                               dcrLine.New_Localized_Value_vod__c = getLocalizedValue(objectName, String.valueOf(sObjectName.get('Id')), fieldName, 'Picklist');
                           }else if(fieldMap.get(fieldName).getDescribe().getType().name() == 'REFERENCE'){
                               for(Schema.SObjectType sObj : fieldMap.get(fieldName).getDescribe().getReferenceTo()){
                                   lookUpObjName = sObj.getDescribe().getName();
                                   dcrLine.New_Localized_Value_vod__c = getLocalizedValue(lookUpObjName, String.valueOf(sObjectName.get(fieldName)), fieldName, 'REFERENCE');
                               }
                           }else{
                               dcrLine.New_Localized_Value_vod__c = fieldValue;
                           }
                       }
                       dcrLine.Data_Change_Request_vod__c = dcrId;
                       system.debug('@@ dcrLine.New_Localized_Value_vod__c: ' + dcrLine.New_Localized_Value_vod__c + '   dcrLine.New_Localized_Value_vod__c: ' + dcrLine.New_Localized_Value_vod__c);
                       dcrLineList.add(dcrLine);
                   }                             
               }
        }
        return dcrLineList;        
    }
    
    static String getLocalizedValue(String objectName, String recordId, String fieldName, string fieldType){        
        
        system.debug('## Inside AGN_VeevaDCR_Utilities.getLocalizedValue(). objectName: ' + objectName + '    recordId: ' + recordId + '    fieldName: ' + fieldName + '     fieldType: ' + fieldType);
        
        String query;
        String localizedValue;
        sObject sObj;
        if(fieldType == 'Picklist'){
            query = 'SELECT toLabel(\'' + String.escapeSingleQuotes(fieldName) + '\') from \'' + String.escapeSingleQuotes(objectName) + '\' where Id = \'' + String.escapeSingleQuotes(recordId) + '\' LIMIT 1'; //cc_AD
            sObj = Database.query(query);
            localizedValue = (String)sObj.get(fieldName); 
        }
        if(fieldType == 'REFERENCE'){
            query = 'SELECT NAME from \'' + String.escapeSingleQuotes(objectName) + '\' where Id = \'' + String.escapeSingleQuotes(recordId) + '\' LIMIT 1'; //cc_AD
            system.debug('## Inside AGN_VeevaDCR_Utilities.getLocalizedValue(). query: ' + query);
            sObj = Database.query(query);
            localizedValue = (String)sObj.get('NAME'); 
        }
        system.debug('## Inside AGN_VeevaDCR_Utilities.getLocalizedValue(). query: ' + query + '      localizedValue: ' + localizedValue);
        return localizedValue;
    }

    public static Boolean convertToBoolean(String value){
		return Boolean.valueOf(value);        
    }
    
    public static Integer convertToInteger(String value){
		return Integer.valueOf(value);        
    }    
    
    public static Double convertToDouble(String value){
		return Double.valueOf(value);        
    }
    
    public static Date convertToDate(String value){
		return Date.valueOf(value);        
    }
    
    public static DateTime convertToDateTime(String value){
		String[] dateTimeList = value.split('T');
        string formattedDateTime = dateTimeList.get(0) + ' ' + (dateTimeList.get(1)).left(8);        
        return DateTime.valueOf(formattedDateTime);        
    }    
    
    public static String getFieldType(string objectName, string fieldAPIName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        Schema.DisplayType fieldType = fieldMap.get(fieldAPIName).getDescribe().getType();
        return String.valueOf(fieldType);
    }

	public static String createAccountDCR(Account acc, String caseNumber, String countryId, String notes){
        dcrNotes = notes;
        string dcrId = AGN_VeevaDCR_Utilities.createAccountDCR(acc, 'ValidateDCR', countryId);
        return dcrId;
    }    
    
        /*
    @future
    public static void deleteDCRs(String jDcrList){
    system.debug('## Inside deleteDCRs()');        
    List<Data_Change_Request_vod__c> dcrList = (List<Data_Change_Request_vod__c>)JSON.deserialize(jDcrList, List<Data_Change_Request_vod__c>.class);
    system.debug('## Inside deleteDCRs(). dcrList: ' + dcrList);
    delete dcrList;
    system.debug('## Inside deleteDCRs(). After Delete.');        
    }
    */
    
    
}