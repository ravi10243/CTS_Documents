/* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant   
* @modifiedBy     Preeti Achary   
* @createdBy      Preeti Achary   
* @version        1.0
* @created        Nov14'2019
* @modified       April 26'2020 - Added a new method to generate default email.
* @testClass            
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            
* YYYY-MM-DD      
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class AGN_GDPR_Utility {
 /************************************************************************************************************************************
    @ author:          Cognizant  
    @ method:          getRecTypeIdByDevName 
    @ returns:         Id
    @ params:          String objectName, String developerName
    @ @description:    [All Markets]Method to fetch RecordType By developerName for a given object.
    @ @changeHistory:  Preeti Achary- Created the method
 ************************************************************************************************************************************/    
    public static Id getRecTypeIdByDevName(String ObjectName, String developerName) {
        Schema.DescribeSObjectResult objTypesDesc = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String,Schema.RecordTypeInfo>  rtMapByName  = objTypesDesc.getRecordTypeInfosByDeveloperName();
        Id recTypeId;
        if(!rtMapByName.isEmpty() && String.isNotBlank(developerName) && rtMapByName.containsKey(developerName)){
            recTypeId = rtMapByName.get(developerName).getRecordTypeId();
        }
        return recTypeId;
    }   
    /************************************************************************************************************************************
    @ author:          Cognizant  
    @ method:          getDataRecordExternalId 
    @ returns:         String
    @ params:          List<Data_Record_AGN__c> dataRecordList
    @ @description:    [All Markets]Method to create and fetch DataRecord's ExternalId
    @ @changeHistory:  Preeti Achary- Created the method
    ************************************************************************************************************************************/
    public static String getDataRecordExternalId(Data_Record_AGN__c dataRec) {
        String externalIdStr = '';     
        //create and fetch DataRecord's ExternalId
        externalIdStr = String.isNotBlank(String.valueOf(dataRec.RecordTypeId))? (externalIdStr + String.valueOf(dataRec.RecordTypeId)) : externalIdStr;
        externalIdStr = String.isNotBlank(String.valueOf(dataRec.Asset_Register_AGN__c))? (externalIdStr + String.valueOf(dataRec.Asset_Register_AGN__c)) : externalIdStr;
        externalIdStr = String.isNotBlank(String.valueOf(dataRec.Data_Subject_Type_AGN__c))? (externalIdStr + String.valueOf(dataRec.Data_Subject_Type_AGN__c)) : externalIdStr;
        externalIdStr = String.isNotBlank(String.valueOf(dataRec.Source_of_Personal_Data_AGN__c))? (externalIdStr + String.valueOf(dataRec.Source_of_Personal_Data_AGN__c)) : externalIdStr;
        externalIdStr = String.isNotBlank(String.valueOf(dataRec.Business_purpose_AGN__c))? (externalIdStr + String.valueOf(dataRec.Business_purpose_AGN__c)) : externalIdStr;
        externalIdStr = String.isNotBlank(String.valueOf(dataRec.Data_Subject_Age_Group_AGN__c))? (externalIdStr+ String.valueOf(dataRec.Data_Subject_Age_Group_AGN__c)) :externalIdStr;
        externalIdStr = String.isNotBlank(String.valueOf(dataRec.Asset_Vendor_AGN__c))? (externalIdStr+ String.valueOf(dataRec.Asset_Vendor_AGN__c)) :externalIdStr;
        return externalIdStr; 
    }
    /************************************************************************************************************************************
    @ author:          Cognizant  
    @ method:          getCurrentUserProfileName 
    @ returns:         String
    @ params:          void
    @ @description:    [All Markets] - Fetch current User's profile Name
    @ @changeHistory:  Preeti Achary - Created the method
    ************************************************************************************************************************************/
    public static String getCurrentUserProfileName() {
        Id profileId = userinfo.getProfileId();
        //Fetch current User's profile Name. User profile is mandatory so query will alwyas give one profile.
        return([Select Id,Name from Profile where Id=:profileId].Name);
    }
    /****************************************************************************************************
    @ author:          Cognizant  
    @ method:          getGenericEmailMessage 
    @ returns:         Messaging.SingleEmailMessage
    @ params:          List<String> toEmailAddressList, String subjectStr, Id userId
    @ @description:    [All Markets] - Create a generic default email address that can be used for both GDPR and CCPA and for other purposes (wherever required)
    @ @changeHistory:  April26'2020 -Preeti Achary - Created the method
    ****************************************************************************************************/
    public static Messaging.SingleEmailMessage getGenericEmailMessage(List<String> toEmailAddressList, String subjectStr, Id userId){
        Messaging.SingleEmailMessage message;
        if(toEmailAddressList != null && !toEmailAddressList.isEmpty() && String.isNotBlank(subjectStr) && userId != null){
            message = new Messaging.SingleEmailMessage();
            message.setSaveAsActivity(false);
            message.setSubject(subjectStr);
            message.setTargetObjectId(userId);
            message.setToAddresses(toEmailAddressList);
        }
        return message;
    }
}