/****************************************************************************************************************
@ Class:          AGN_Duplicate_Checker 
@ Version:        1
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        Helper class to agn_duplicateListing component. Performs onload setup and button click support
-----------------------------------------------------------------------------------------------------------------
@ Change history: 28.12.2020 / Ayush Basak / Created the class.
****************************************************************************************************************/
public with sharing class AGN_Duplicate_Checker {
    
    /************************************************************************************************************
    @ method:           getDuplicates 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          AuraEnabled method, used to setup the list of duplicate records on component load. 
                        Invokes AGN_Reltio_Service_Class to fetch the list of duplicate records from Reltio DB
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 28.12.2020 / Ayush Basak / Created the method
    ************************************************************************************************************/
    @AuraEnabled
    public static List<AGN_Reltio_Entity_Wrapper_Class> getDuplicates(Id crAddressId){
        List<AGN_Reltio_Entity_Wrapper_Class> duplicateList = new List<AGN_Reltio_Entity_Wrapper_Class>();
        String query = '';
        try {
            String type = crAddressId.getsObjectType().getDescribe().getName();
            // Fetching list of fields in API query building
            List<Reltio_Filter_Condition_AGN__mdt> conditions = [SELECT Field_Name_AGN__c 
                                                                    FROM Reltio_Filter_Condition_AGN__mdt 
                                                                    WHERE sObject_AGN__c =: type
                                                                    WITH SECURITY_ENFORCED];
            // Building dynamic query with field list from custom setting for the object in consideration
            query = 'SELECT Id,';
            for (Reltio_Filter_Condition_AGN__mdt condition : conditions) {
                // To avoid same field from being added multiple times in the query
                if(query.contains(condition.Field_Name_AGN__c)) {
                    continue;
                }
                // toLabel() added for picklist fields to get label instead of API value
                if(Schema.getGlobalDescribe().get(type).getDescribe()
                        .fields.getMap().get(condition.Field_Name_AGN__c).getDescribe().getType() 
                        == Schema.DisplayType.Picklist) {
                    query = query + 'toLabel(' + condition.Field_Name_AGN__c + '),';
                }
                else {
                    query = query + condition.Field_Name_AGN__c + ',';
                }
            }
            query = query.substring(0,query.length()-1);
            query = query + ' FROM ' + type + ' where Id =: crAddressId WITH SECURITY_ENFORCED';
            sObject record = Database.query(String.escapeSingleQuotes(query));
            duplicateList = AGN_Reltio_Service_Class.getHCOs(record, type);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString() + query);
        }
        return duplicateList;
    }
}