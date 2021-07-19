/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant
* @Name           GPSAssessmentToolController
* @version        1.0
* @created        03/12/2017
* @modified       07/05/2021  
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes   
   PMO 3408: 1. Business Units multiselect-picklist Assignment, 2. Export
   27 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team
   PMO 3874: Export feature enhanced to process bulk data
*/

public with sharing class GPSAssessmentToolController {
    
    /* Start subclasses */
    public class AccountCustomerAssessmentWrapper {
        @AuraEnabled public List<Account_Customer_GPS_Assessment_AGN__c> accountCustomerAssessments {get;set;}
        @AuraEnabled public Map<Id, Decimal> accountTotals {get;set;}
    }
    
    public class wrapperClass{
        @AuraEnabled public User objUser {get;set;}
        @AuraEnabled public Integer assessmentCount {get;set;}
        @AuraEnabled public Integer gpsAssessmentCount {get;set;}
    }
    
    public class AccountAssessmentWithStatsWrapper {
        @AuraEnabled public GPS_Assessment__c assessment {get;set;}
        @AuraEnabled public Decimal completedAssessmentCount{get;set;}
        @AuraEnabled public Decimal totalAssessmentCount{get;set;}
    }
    /* End subclasses */
    
    @AuraEnabled
    public static User getCurrentUser() {
        return [
            SELECT Id, Name, Email, FirstName, LastName, ProfileId, Profile.Name, UserRoleId, UserRole.Name, DefaultCurrencyISOCode
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
    }
    
    @AuraEnabled
    public static GPS_Assessment_Tool_Settings__c getGPSSettings() {
        return GPS_Assessment_Tool_Settings__c.getInstance();
    }
    
    /* Start shared methods */
    @AuraEnabled
    public static GPS_Assessment__c getGPSAssessment(Id assessmentId) {
        QueryStringGenerator queryStringGenerator = new QueryStringGenerator(assessmentId.getSObjectType());
        
        System.debug('Assessment ID Test: '+assessmentId);
        
        String query = queryStringGenerator.getReadableFieldsQuery() + '\nWHERE Id = :assessmentId';
        List<GPS_Assessment__c> gpsAssessments = new List<GPS_Assessment__c>();
        gpsAssessments = Database.query(query);
        System.debug('GetGPSAssessment Error Test '+query);
        System.debug('GetGPSAssessment Error Test '+gpsAssessments);
        
        return (GPS_Assessment__c)Database.query(query);
    }
    /* End shared methods */
    
    
    /*Release 14 Niladri */     
    @AuraEnabled        
    public static List < Account_GPS_Assessment__c > fetchAccount(String searchKeyWord) {       
        String searchKey = searchKeyWord + '%';     
        List < Account_GPS_Assessment__c > returnList = new List < Account_GPS_Assessment__c > ();      
        List < Account_GPS_Assessment__c > lstOfAccount = [select id, Name,Account_AGN__c, Account_Name_AGN__c, Assessment_Type_AGN__c from Account_GPS_Assessment__c where Name LIKE: searchKey];      
        
        for (Account_GPS_Assessment__c acc: lstOfAccount) {     
            returnList.add(acc);        
        }       
        return returnList;      
    }       
    //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
    //PMO 3408: GPS Assessment: Start: By: RM, AB: Multiselect-Picklist Assignment
    @AuraEnabled
    public static List <String> getPiklistValues() {
        List<String> plValues = new List<String>();
        
        //Get the object type from object GPS Assessment
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('GPS_Assessment__c');
        
        //Describe the sObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        //Get the specific field information from field Business Unit in GPS Assessment object
        Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('Business_Unit_AGN__c').getDescribe();
        
        //Get the picklist field values.
        List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
        
        //Add the picklist values to list.
        if(picklistvalues.size() > 0){
            for(Schema.PicklistEntry plv: picklistvalues) {
                plValues.add(plv.getValue());
            }
        }
        plValues.sort();
        return plValues;
    }
    //PMO 3408: GPS Assessment: End: Multiselect-Picklist Assignment
    
    
    /* Start Business Excellence user methods */
    @AuraEnabled
    public static List<GPS_Assessment__c> getGPSAssessments(String sortField, Decimal pageNumber, Integer recordsPerPage, Boolean sortIsAsc) {
        System.debug('sortField=' + sortField);
        System.debug('pageNumber=' + pageNumber);
        System.debug('recordsPerPage=' + recordsPerPage);
        System.debug('Inside getGPSAssessments');
        
        
        QueryStringGenerator queryStringGenerator = new QueryStringGenerator(Schema.GPS_Assessment__c.SObjectType);
        // Release 14 toLabel(Status_AGN__c)
        //  String query = queryStringGenerator.getReadableFieldsQuery();
        //String query = 'SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate,LastModifiedById, LastModifiedBy.Name, SystemModstamp, MayEdit, IsLocked, LastViewedDate, LastReferencedDate,Display_Local_ASP_Capture_AGN__c, Product_Name_AGN__c, Value_Type_AGN__c, Data_Period_Collection_AGN__c, Time_Frame_AGN__c,Projection_Metric_AGN__c, Change_Metrics_AGN__c, Financial_Projection_Period_Mths_AGN__c, Use_Market_Data_AGN__c,Data_Collection_Period_1_AGN__c, Data_Collection_Period_2_AGN__c, Use_Dosage_Data_AGN__c, Value_Per_Dosage_Unit_AGN__c,toLabel(Status_AGN__c),Country_Code_AGN__c, Current_User_Country_Code_AGN__c, Assessment_Type_AGN__c, Due_Date_AGN__c,Custom_Question_1_AGN__c, Custom_Question_1_Type_AGN__c, Custom_Question_1_List_Of_Values_AGN__c, Custom_Question_2_AGN__c,Custom_Question_3_AGN__c, Custom_Question_4_AGN__c, Custom_Question_2_List_Of_Values_AGN__c, Custom_Question_3_List_Of_Values_AGN__c,Custom_Question_4_List_Of_Values_AGN__c, Custom_Question_2_Type_AGN__c, Custom_Question_3_Type_AGN__c, Custom_Question_4_Type_AGN__c,Business_Size_Question_AGN__c, Business_Size_Question_Override_AGN__c, Indication_Therapy_Area_AGN__c, Share_Capture_AGN__c,Secondary_Brand_Name_AGN__c, AGN_Share_Absolute_Question_AGN__c, AGN_Share_Percentage_Question_AGN__c,AGN_Share_Percent_Question_Override_AGN__c, AGN_Share_Absolute_Question_Override_AGN__c, Dose_Per_Treatment_Question_AGN__c, Dose_Per_Treatment_Question_Override_AGN__c, Freq_Of_Treatment_Question_Override_AGN__c, Freq_Of_Treatment_Question_AGN__c, Projection_Analysis_Note_AGN__c, Secondary_Brand_Question_Override_AGN__c, Secondary_Brand_Question_AGN__c, Allow_Account_Removal_AGN__c, Secondary_Brand_Indication_AGN__c, Default_Dosage_PP_AGN__c, Unit_AGN__c, Secondary_Brand_AGN__c, Use_Frequency_Data_AGN__c, Default_Frequency_AGN__c, Display_KOL_Capture_AGN__c, Display_Referrer_Capture_AGN__c, Product_List_AGN__c, Dosage_Unit_AGN__c, Display_Confidence_Level_Capture_AGN__c, Overdue_in_Days_AGN__c FROM GPS_Assessment__c';       
        // String query = 'SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, SystemModstamp, MayEdit, IsLocked, AGN_Share_Absolute_Question_AGN__c, AGN_Share_Absolute_Question_Override_AGN__c, AGN_Share_Percent_Question_Override_AGN__c, AGN_Share_Percentage_Question_AGN__c, Allow_Account_Removal_AGN__c, Assessment_Type_AGN__c, Business_Size_Question_AGN__c, Business_Size_Question_Override_AGN__c, Change_Metrics_AGN__c, Custom_Question_1_AGN__c, Custom_Question_1_List_Of_Values_AGN__c, Custom_Question_1_Type_AGN__c, Custom_Question_2_AGN__c, Custom_Question_2_List_Of_Values_AGN__c, Custom_Question_2_Type_AGN__c, Custom_Question_3_AGN__c, Custom_Question_3_List_Of_Values_AGN__c, Custom_Question_3_Type_AGN__c, Custom_Question_4_AGN__c, Custom_Question_4_List_Of_Values_AGN__c, Custom_Question_4_Type_AGN__c, Data_Collection_Period_1_AGN__c, Data_Collection_Period_2_AGN__c, Data_Period_Collection_AGN__c, Default_Dosage_PP_AGN__c, Default_Frequency_AGN__c, Display_Confidence_Level_Capture_AGN__c, Display_KOL_Capture_AGN__c, Display_Referrer_Capture_AGN__c, Dosage_Unit_AGN__c, Dose_Per_Treatment_Question_AGN__c, Dose_Per_Treatment_Question_Override_AGN__c, Due_Date_AGN__c, Financial_Projection_Period_Mths_AGN__c, Freq_Of_Treatment_Question_AGN__c, Freq_Of_Treatment_Question_Override_AGN__c, Indication_Therapy_Area_AGN__c, Overdue_in_Days_AGN__c, Product_List_AGN__c, Projection_Analysis_Note_AGN__c, Projection_Metric_AGN__c, Secondary_Brand_AGN__c, Secondary_Brand_Indication_AGN__c, Secondary_Brand_Name_AGN__c, Secondary_Brand_Question_AGN__c, Secondary_Brand_Question_Override_AGN__c, Share_Capture_AGN__c,toLabel(Status_AGN__c), Time_Frame_AGN__c, Unit_AGN__c, Use_Dosage_Data_AGN__c, Use_Frequency_Data_AGN__c, Use_Market_Data_AGN__c, Value_Per_Dosage_Unit_AGN__c, Value_Type_AGN__c, Display_Local_ASP_Capture_AGN__c, Product_Name_AGN__c, Country_Code_AGN__c, Current_User_Country_Code_AGN__c FROM GPS_Assessment__c';     
        //PMO 3408: GPS Assessment: 'query' has been modified, with removal of fields not necessary
        String query = 'SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, SystemModstamp, MayEdit, IsLocked, AGN_Share_Absolute_Question_AGN__c, AGN_Share_Absolute_Question_Override_AGN__c, Allow_Account_Removal_AGN__c, Assessment_Type_AGN__c, Business_Size_Question_AGN__c, Business_Size_Question_Override_AGN__c, Change_Metrics_AGN__c, Custom_Question_1_AGN__c, Custom_Question_1_List_Of_Values_AGN__c, Custom_Question_1_Type_AGN__c, Custom_Question_2_AGN__c, Custom_Question_2_List_Of_Values_AGN__c, Custom_Question_2_Type_AGN__c, Custom_Question_3_AGN__c, Custom_Question_3_List_Of_Values_AGN__c, Custom_Question_3_Type_AGN__c, Custom_Question_4_AGN__c, Custom_Question_4_List_Of_Values_AGN__c, Custom_Question_4_Type_AGN__c, Display_Confidence_Level_Capture_AGN__c, Display_KOL_Capture_AGN__c, Display_Referrer_Capture_AGN__c, Due_Date_AGN__c,Financial_Projection_Period_Mths_AGN__c, Overdue_in_Days_AGN__c, Product_List_AGN__c, Projection_Analysis_Note_AGN__c, Projection_Metric_AGN__c, toLabel(Status_AGN__c), Time_Frame_AGN__c, Unit_AGN__c, Value_Type_AGN__c, Product_Name_AGN__c, Country_Code_AGN__c, Current_User_Country_Code_AGN__c FROM GPS_Assessment__c';  
        if(sortField != null) {
            String sortDirection = sortIsAsc ? ' ASC ' : ' DESC ' ;
            String nullsSortDirection = sortIsAsc ? ' NULLS FIRST ' : ' NULLS LAST ' ;
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + sortDirection + nullsSortDirection;
        }
        if(recordsPerPage != null) query += ' LIMIT ' + recordsPerPage;
        if(recordsPerPage != null && pageNumber != null) {
            Integer offsetCount = ((Integer)pageNumber - 1) * recordsPerPage;
            System.debug('offsetCount=' + offsetCount);
            query += ' OFFSET ' + offsetCount;
        }
        
        System.debug('getGPSAssessments query=' + query);
        return (List<GPS_Assessment__c>)Database.query(query);
    }
    
    @AuraEnabled
    public static Integer getGPSAssessmentsTotalCount() {
        return [SELECT COUNT() FROM GPS_Assessment__c];
    }
    
    //PMO 3408: GPS Assessment: Start: Business unit Multiselect-Picklist Assignment
    /*
public static GPS_Assessment__c saveGPSAssessment(GPS_Assessment__c assessment) {
upsert assessment;
assessment = getGPSAssessment(assessment.Id);
return assessment;
}
*/
    @AuraEnabled
    public static GPS_Assessment__c saveGPSAssessment(GPS_Assessment__c assessment, List<String> selectedBusinessUnitList) {
        String selectedBusinessUnitString = '';
        for (String businessUnit : selectedBusinessUnitList){
            selectedBusinessUnitString += (businessUnit + ';');
        }
        if(Schema.sObjectType.GPS_Assessment__c.fields.Business_Unit_AGN__c.isCreateable() &&
           Schema.sObjectType.GPS_Assessment__c.fields.Business_Unit_AGN__c.isUpdateable()){    //Checkmarks
            assessment.Business_Unit_AGN__c = selectedBusinessUnitString;
        }
        upsert assessment;
        assessment = getGPSAssessment(assessment.Id);
        return assessment;
    }
    //PMO 3408: GPS Assessment: End: Business unit Multiselect-Picklist Assignment
    
    //PMO 3408: GPS Assessment: Start: Export
    @AuraEnabled
    public static Map<String, String> exportGPSAssessment(Id assessmentId) {
        System.debug('Exporting assessment: ' + assessmentId);
        
        Map<String, String> exportMap = new Map<String, String>();
        
        //Fetch
        GPS_Assessment__c assessment = getGPSAssessment(assessmentId);
        List<Account_GPS_Assessment__c> assessmentResponseList = [SELECT ID, Owner.ID, Owner.Name, GPS_Assessment_AGN__c, Account_AGN__c, Account_AGN__r.Name, Account_AGN__r.Primary_Parent_vod__c, 
                                                                  Business_Size_Current_AGN__c, AGN_Share_Absolute_Current_AGN__c, Stakeholder_AGN__c, Consent_for_Digital_AGN__c, Digital_Only_AGN__c
                                                                  FROM Account_GPS_Assessment__c
                                                                  WHERE GPS_Assessment_AGN__c =: assessmentId
                                                                 ];
        List<Account_Customer_GPS_Assessment_AGN__c> accCustAssessmentList = [SELECT ID, Customer_AGN__r.Name, Account_GPS_Assessment_AGN__r.Account_AGN__r.Name, Account_GPS_Assessment_AGN__r.Account_AGN__r.Id,
                                                                              Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Id, Assessment_Completed_AGN__c, Customer_AGN__c, KOL_AGN__c,
                                                                              Business_Size_Acc_Cust_Assessment_AGN__c, AGN_Usage_Acc_Cust_Assessment_AGN__c, Consent_for_Digital_Acc_Cust_Assmnt_AGN__c, Digital_Only_Acc_Cust_Assessment_AGN__c
                                                                              FROM Account_Customer_GPS_Assessment_AGN__c 
                                                                              where Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Id =: assessmentId
                                                                             ];
        //Get all the reps associated with the assessment
        List<Id> repList = new List<Id>();
        if(assessmentResponseList.size() > 0){
            for(Account_GPS_Assessment__c response : assessmentResponseList){
                repList.add(response.Owner.ID);
            }
        }
        
        //Map of territoryId : userId
        Map<Id, Id> territoryIdUserIdMap = new Map<Id, Id>();
        for(UserTerritory2Association userTerritory: [SELECT Territory2Id, UserId FROM UserTerritory2Association WHERE UserId IN :repList AND Territory2.Territory2Model.State ='Active']){
            territoryIdUserIdMap.put(userTerritory.Territory2Id, userTerritory.UserId);
        }
        
        //Map of userId : territoryName
        Map<Id, String> userIdTerritoryNameMap = new Map<Id, String>();
        for(Territory2 territory: [SELECT Id, Name FROM Territory2 WHERE Id IN :territoryIdUserIdMap.keySet()]){
            userIdTerritoryNameMap.put(territoryIdUserIdMap.get(territory.Id), territory.Name);
        }
        //PMO - 3874: Map for getting the Assessment ID's - Start
        Map<Id, String> idMap = new Map<Id, String>();
        for(Account_GPS_Assessment__c response1 : assessmentResponseList)
        {
           String ValueMap = userIdTerritoryNameMap.get(response1.Owner.Id) + '$' + response1.Owner.Name + '$' + response1.Account_AGN__c + '$';
           idMap.put(response1.id, ValueMap);
           //System.debug('idMap is' + idMap);
        }
        //PMO - 3874: Map for getting the Assessment ID's - End
        
        if(assessment.Assessment_Type_AGN__c == 'Accounts'){
            
            String csvStringAccount = 'Territory,Rep,Market,Product,Account ID,Account,Total Patient/Potential,AGN Usage,Customer Group'+'\n';
            
            for(Account_GPS_Assessment__c response : assessmentResponseList){
                csvStringAccount += ( userIdTerritoryNameMap.get(response.Owner.Id) + ',' + response.Owner.Name +',' + (assessment.Business_Unit_AGN__c != null ? assessment.Business_Unit_AGN__c : '') + ',' + (assessment.Product_List_AGN__c).replace('\n','; ').replace(', Â','-').replace(', ','-') + ',' + response.Account_AGN__c +',' + response.Account_AGN__r.Name + ',' + (response.Business_Size_Current_AGN__c != null ? String.valueOf(response.Business_Size_Current_AGN__c) : '') + ',' + (response.AGN_Share_Absolute_Current_AGN__c != null ? String.valueOf(response.AGN_Share_Absolute_Current_AGN__c) : '') + ',' + 'Accounts') + '\n';     
            }
            
            exportMap.put('AccountExport', csvStringAccount);
            
            String csvStringIndividual = 'Territory,Rep,Market,Product,Account ID,HCP ID,Name,Total Patient,AGN Usage,Customer Group,'+ (assessment.Consent_for_Digital_AGN__c ? 'Consent for Digital(Yes/No),':'')+ (assessment.Digital_Only_AGN__c ? 'Digital Only Customer(Yes/No)':'')+'\n';
            
            //PMO - 3874: Export feature updated: Start
                for(Account_Customer_GPS_Assessment_AGN__c accCust : accCustAssessmentList)
                {
                    if(idMap.get(accCust.Account_GPS_Assessment_AGN__c) != NULL )
                    {
                       // csvStringIndividual += ( userIdTerritoryNameMap.get(response.Owner.Id) + ',' + response.Owner.Name + ',' + (assessment.Business_Unit_AGN__c != null ? assessment.Business_Unit_AGN__c : '') + ',' + (assessment.Product_List_AGN__c).replace('\n','; ') + ',' + response.Account_AGN__c +',' + accCust.Customer_AGN__c + ',' + accCust.Customer_AGN__r.Name + ',' + (accCust.Business_Size_Acc_Cust_Assessment_AGN__c != null ? String.valueOf(accCust.Business_Size_Acc_Cust_Assessment_AGN__c) : '') + ',' + (accCust.AGN_Usage_Acc_Cust_Assessment_AGN__c != null ? String.valueOf(accCust.AGN_Usage_Acc_Cust_Assessment_AGN__c) : '') + ',' + 'Individual' + ',' + (assessment.Consent_for_Digital_AGN__c ?(accCust.Consent_for_Digital_Acc_Cust_Assmnt_AGN__c ? 'Yes,':'No,' ) : '')  + (assessment.Digital_Only_AGN__c ?(accCust.Digital_Only_Acc_Cust_Assessment_AGN__c ? 'Yes':'No' ) : '')  ) + '\n';  
                       String valueBreak = idMap.get(accCust.Account_GPS_Assessment_AGN__c);
                       List<String> valueBreak1 = valueBreak.split('\\$');
                       csvStringIndividual += (valueBreak1[0] + ',' + valueBreak1[1] + ',' + (assessment.Business_Unit_AGN__c != null ? assessment.Business_Unit_AGN__c : '') + ',' + (assessment.Product_List_AGN__c).replace('\n','; ') + ',' + valueBreak1[2] +',' + accCust.Customer_AGN__c + ',' + accCust.Customer_AGN__r.Name + ',' + (accCust.Business_Size_Acc_Cust_Assessment_AGN__c != null ? String.valueOf(accCust.Business_Size_Acc_Cust_Assessment_AGN__c) : '') + ',' + (accCust.AGN_Usage_Acc_Cust_Assessment_AGN__c != null ? String.valueOf(accCust.AGN_Usage_Acc_Cust_Assessment_AGN__c) : '') + ',' + 'Individual' + ',' + (assessment.Consent_for_Digital_AGN__c ?(accCust.Consent_for_Digital_Acc_Cust_Assmnt_AGN__c ? 'Yes,':'No,' ) : '')  + (assessment.Digital_Only_AGN__c ?(accCust.Digital_Only_Acc_Cust_Assessment_AGN__c ? 'Yes':'No' ) : '')  ) + '\n';
                    }
                }   
            
            exportMap.put('IndividualExport', csvStringIndividual);
            
            
            if(assessment.Display_KOL_Capture_AGN__c == True){
                String csvStringStakeholder = 'Territory,Rep,Market,Product,Account ID,HCP ID,Name,Segment Of Stakeholder,' + (assessment.Consent_for_Digital_AGN__c ? 'Consent for Digital(Yes/No),' : '') + (assessment.Digital_Only_AGN__c ? 'Digital Only Customer(Yes/No)' : '') +'\n';
                
                    for(Account_Customer_GPS_Assessment_AGN__c accCust : accCustAssessmentList)
                    {
                        if(idMap.get(accCust.Account_GPS_Assessment_AGN__c) != NULL && accCust.KOL_AGN__c)
                        {
                            //csvStringStakeholder += ( userIdTerritoryNameMap.get(response.Owner.Id) + ',' + response.Owner.Name + ',' + (assessment.Business_Unit_AGN__c != null ? assessment.Business_Unit_AGN__c : '') + ',' + (assessment.Product_List_AGN__c).replace('\n','; ') + ',' + response.Account_AGN__c +',' + accCust.Customer_AGN__c + ',' + accCust.Customer_AGN__r.Name + ',' + 'SH' + ',' +  (assessment.Consent_for_Digital_AGN__c ? (accCust.Consent_for_Digital_Acc_Cust_Assmnt_AGN__c ? 'Yes,':'No,') : '') + (assessment.Digital_Only_AGN__c ? (accCust.Digital_Only_Acc_Cust_Assessment_AGN__c ? 'Yes':'No') : '') ) + '\n';  
                        	String valueBreak = idMap.get(accCust.Account_GPS_Assessment_AGN__c);
                            List<String> valueBreak1 = valueBreak.split('\\$');
                            csvStringStakeholder += ( valueBreak1[0] + ',' + valueBreak1[1] + ',' + (assessment.Business_Unit_AGN__c != null ? assessment.Business_Unit_AGN__c : '') + ',' + (assessment.Product_List_AGN__c).replace('\n','; ') + ',' + valueBreak1[2] +',' + accCust.Customer_AGN__c + ',' + accCust.Customer_AGN__r.Name + ',' + 'SH' + ',' +  (assessment.Consent_for_Digital_AGN__c ? (accCust.Consent_for_Digital_Acc_Cust_Assmnt_AGN__c ? 'Yes,':'No,') : '') + (assessment.Digital_Only_AGN__c ? (accCust.Digital_Only_Acc_Cust_Assessment_AGN__c ? 'Yes':'No') : '') ) + '\n';
                        }
                    }   
                //PMO - 3874: Export feature updated: End
                exportMap.put('StakeholderExport', csvStringStakeholder);
            }    
        }else if(assessment.Assessment_Type_AGN__c == 'Customers'){
            
            String csvStringIndividual = 'Territory,Rep,Market,Product,Account ID,HCP ID,Name,Total Patient,AGN Usage,Customer Group,' + (assessment.Consent_for_Digital_AGN__c ? 'Consent for Digital(Yes/No),' : '') + (assessment.Digital_Only_AGN__c ? 'Digital Only Customer(Yes/No)' : '') +'\n';
            
            for(Account_GPS_Assessment__c response : assessmentResponseList){
                
                String accPrimaryParent = '';
                
                if(response.Account_AGN__r.Primary_Parent_vod__c != null){
                    accPrimaryParent = response.Account_AGN__r.Primary_Parent_vod__c;
                }
                
                csvStringIndividual += ( userIdTerritoryNameMap.get(response.Owner.Id) + ',' + response.Owner.Name + ',' + (assessment.Business_Unit_AGN__c != null ? assessment.Business_Unit_AGN__c : '') + ',' + (assessment.Product_List_AGN__c).replace('\n','; ') + ',' + accPrimaryParent +',' + response.Account_AGN__c +',' + response.Account_AGN__r.Name + ',' + (response.Business_Size_Current_AGN__c != null ? String.valueOf(response.Business_Size_Current_AGN__c) : '') + ',' +  (response.AGN_Share_Absolute_Current_AGN__c != null ? String.valueOf(response.AGN_Share_Absolute_Current_AGN__c) : '') + ',' + 'Individual' + ',' + (assessment.Consent_for_Digital_AGN__c ? (response.Consent_for_Digital_AGN__c ? 'Yes,':'No,') : '') + (assessment.Digital_Only_AGN__c ? (response.Digital_Only_AGN__c ? 'Yes':'No') : '')) + '\n';     
                
            }
            
            exportMap.put('IndividualExport', csvStringIndividual);
            
            if(assessment.Display_KOL_Capture_AGN__c == True){
                String csvStringStakeholder = 'Territory,Rep,Market,Product,Account ID,HCP ID,Name,Segment Of Stakeholder,' + (assessment.Consent_for_Digital_AGN__c ? 'Consent for Digital(Yes/No),' : '') + (assessment.Digital_Only_AGN__c ? 'Digital Only Customer(Yes/No)' : '') +'\n';
                
                for(Account_GPS_Assessment__c response : assessmentResponseList){
                    
                    if(response.Stakeholder_AGN__c){
                        
                        String accPrimaryParent = '';
                        
                        if(response.Account_AGN__r.Primary_Parent_vod__c != null){
                            accPrimaryParent = response.Account_AGN__r.Primary_Parent_vod__c;
                        }
                        
                        csvStringStakeholder += ( userIdTerritoryNameMap.get(response.Owner.Id) + ',' + response.Owner.Name + ',' + (assessment.Business_Unit_AGN__c != null ? assessment.Business_Unit_AGN__c : '') + ',' + (assessment.Product_List_AGN__c).replace('\n','; ') + ',' + accPrimaryParent +',' + response.Account_AGN__c +',' + response.Account_AGN__r.Name + ',' + 'SH' + ',' +  (assessment.Consent_for_Digital_AGN__c ? (response.Consent_for_Digital_AGN__c ? 'Yes,':'No,') : '') + (assessment.Digital_Only_AGN__c ? (response.Digital_Only_AGN__c ? 'Yes':'No') : '')) + '\n';     
                        
                    }
                }
                
                exportMap.put('StakeholderExport', csvStringStakeholder);
            }
        }
        
        //Return the csv string to be exported
        return exportMap;
    }
    //PMO 3408: GPS Assessment: End: Export
    
    @AuraEnabled
    public static GPS_Assessment__c cloneGPSAssessment(Id assessmentId) {
        System.debug('assessmentId=' + assessmentId);
        
        // Clone the assessment
        GPS_Assessment__c originalAssessment = getGPSAssessment(assessmentId);
        GPS_Assessment__c clonedAssessment = originalAssessment.clone();
        insert clonedAssessment;
        
        // Clone the list of products
        List<GPS_Assessment_Product_AGN__c> clonedAssessmentProducts = new List<GPS_Assessment_Product_AGN__c>();
        QueryStringGenerator queryStringGenerator = new QueryStringGenerator(Schema.GPS_Assessment_Product_AGN__c.SObjectType);
        String query = queryStringGenerator.getReadableFieldsQuery() + 'WHERE GPS_Assessment_AGN__c = :assessmentId';
        for(GPS_Assessment_Product_AGN__c assessmentProduct : (List<GPS_Assessment_Product_AGN__c>)Database.query(query)) {
            GPS_Assessment_Product_AGN__c clonedAssessmentProduct = assessmentProduct.clone();
            //   if(Schema.sObjectType.GPS_Assessment_Product_AGN__c.fields.GPS_Assessment_AGN__c.isCreateable()) // AKJ_cc
            //   {
            clonedAssessmentProduct.GPS_Assessment_AGN__c = clonedAssessment.Id;
            //    }
            
            
            clonedAssessmentProducts.add(clonedAssessmentProduct);
        }
        if(Schema.sObjectType.GPS_Assessment_Product_AGN__c.isCreateable())
        {
            insert clonedAssessmentProducts;
        }
        
        
        // Requery and return the new clone assessment
        return getGPSAssessment(clonedAssessment.Id);
    }
    
    @AuraEnabled
    public static List<Product_vod__c> getProductCatalog(Id assessmentId, String searchString) {
        String query = 'SELECT Id, Name, Product_Type_vod__c FROM Product_vod__c'
            + '\nWHERE Id NOT IN (SELECT Product_AGN__c FROM GPS_Assessment_Product_AGN__c WHERE GPS_Assessment_AGN__c = :assessmentId)';
        
        if(searchString != null) query +=  '\nAND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
        
        query += '\nORDER BY Name LIMIT 150'; // TODO add paging support
        
        return (List<Product_vod__c>)Database.query(query);
    }
    
    @AuraEnabled
    public static void createAssessmentProducts(Id assessmentId, List<Id> productIds) {
        List<GPS_Assessment_Product_AGN__c> assessmentProducts = new List<GPS_Assessment_Product_AGN__c>();
        for(Id productId : productIds) {
            if( Schema.sObjectType.GPS_Assessment_Product_AGN__c.fields.Product_AGN__c.isCreateable() &&
               Schema.sObjectType.GPS_Assessment_Product_AGN__c.fields.Product_AGN__c.isUpdateable())  //AKJ_cc 
            {
                GPS_Assessment_Product_AGN__c assessmentProduct = new GPS_Assessment_Product_AGN__c(
                    GPS_Assessment_AGN__c = assessmentId,
                    Product_AGN__c        = productId
                );
                GPSAssessmentUtils.setAssessmentProductUniqueId(assessmentProduct);
                assessmentProducts.add(assessmentProduct);
            }
        }   
        
        if(Schema.sObjectType.GPS_Assessment_Product_AGN__c.isUpdateable() &&
           Schema.sObjectType.GPS_Assessment_Product_AGN__c.isCreateable())  // AKJ_cc
        {
            upsert assessmentProducts Unique_ID_AGN__c;
        }
        
    }
    
    @AuraEnabled
    public static void createAccountAssessmentRecordsForAccountIds(Id assessmentId, Id ownerId, List<Id> accountIds) {
        System.debug('assessmentId=' + assessmentId);
        System.debug('ownerId=' + ownerId);
        System.debug('accountIds=' + accountIds);
        
        String accountIdString = convertIdsToQueryString(accountIds);
        String accountQuery = 'SELECT Id, OwnerId FROM Account WHERE Id IN ' + accountIdString;
        System.debug('accountQuery=' + accountQuery);
        List<Account> accounts = (List<Account>)Database.query(accountQuery);
        System.debug('accounts=' + JSON.serialize(accounts));
        
        List<Account_GPS_Assessment__c> accountAssessments = generateAccountAssessments(assessmentId, accounts, ownerId);
        //Database.executeBatch(new GPSDataImport(accountAssessments, assessmentId));
        System.debug(accountAssessments);
        if(Schema.sObjectType.Account_GPS_Assessment__c.isUpdateable() &&
           Schema.sObjectType.Account_GPS_Assessment__c.isCreateable())    // AKJ_cc
        {
            upsert accountAssessments Unique_ID_AGN__c;
        }
        
        System.debug('upsert done');
    }
    
    /* @AuraEnabled
public static void createAccountAssessmentRecordsForUserIds(Id assessmentId, List<Id> userIds) {
// Get assessment
GPS_Assessment__c assessment = getGPSAssessment(assessmentId);
Boolean isPersonAccounts = assessment.Assessment_Type_AGN__c == 'Customers';

List<Id> accountIdsWithProducts = getAccountIdsWithProducts(assessmentId, isPersonAccounts);
List<Account> targetAccounts = [
SELECT Id
FROM Account
WHERE Target__c = true
AND IsPersonAccount = :isPersonAccounts
AND Id IN :accountIdsWithProducts
];

// Generate the account assessment records
List<Account_GPS_Assessment__c> accountAssessments = new List<Account_GPS_Assessment__c>();
for(Id userId : userIds) {
for(Account targetAccount : targetAccounts) {
Account_GPS_Assessment__c accountAssessment = new Account_GPS_Assessment__c(
Account_AGN__c        = targetAccount.Id,
GPS_Assessment_AGN__c = assessmentId,
OwnerId               = userId
);
GPSAssessmentUtils.setAccountAssessmentUniqueId(accountAssessment);
accountAssessments.add(accountAssessment);
}
}
Database.executeBatch(new GPSDataImport(accountAssessments, assessmentId));
} */
    
    /* R14 ER : TSF checking added to below method as part of PMO 1850 */
    
    @AuraEnabled
    public static void createAccountAssessmentRecordsForUserIds(Id assessmentId, List<Id> userIds) {
        // Get assessment
        GPS_Assessment__c assessment = getGPSAssessment(assessmentId);
        Boolean isPersonAccounts = assessment.Assessment_Type_AGN__c == 'Customers';
        
        // Get the product IDs from the list of assessment-products
        List<GPS_Assessment_Product_AGN__c> assessmentProducts = getGPSAssessmentProducts(assessmentId);
        List<Id> productIds = new List<Id>();
        for(GPS_Assessment_Product_AGN__c assessmentProduct : assessmentProducts) {
            productIds.add(assessmentProduct.Product_AGN__c);
        }
        
        // Get the list of user territories, accounts by territory (TSF) and the territories
        Map<String, List<UserTerritory2Association>> usersByTerritoryName = getUsersByTerritoryName(userIds, productIds);
        // getAccountsByTerritoryName method handles filtering to target accounts with matching products for the assessment
        
        Map<String, List<TSF_vod__c>> accountsByTerritoryName = getAccountsByTerritoryName(userIds, productIds, isPersonAccounts);
        Map<Id, Territory2> territoriesById = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2 WHERE Name IN :usersByTerritoryName.keySet()]);
        
        // Generate the account assessment records
        List<Account_GPS_Assessment__c> accountAssessments = new List<Account_GPS_Assessment__c>();
        for(List<UserTerritory2Association> userTerritories : usersByTerritoryName.values()) {
            for(UserTerritory2Association userTerritory : userTerritories) {
                // Get the territory so we can access the territory name
                Territory2 territory = territoriesById.get(userTerritory.Territory2Id);
                List<TSF_vod__c> accountTsfInTerritory = accountsByTerritoryName.get(territory.Name);
                
                // If there are no accounts in the user territory, skip to next user territory
                if(accountTsfInTerritory == null) continue;
                
                // Create the account assessment record
                for(TSF_vod__c accountTsf : accountTsfInTerritory) {
                    Account_GPS_Assessment__c accountAssessment = new Account_GPS_Assessment__c(
                        Account_AGN__c        = accountTsf.Account_vod__c,
                        GPS_Assessment_AGN__c = assessmentId,
                        OwnerId               = userTerritory.UserId
                    );
                    GPSAssessmentUtils.setAccountAssessmentUniqueId(accountAssessment);
                    accountAssessments.add(accountAssessment);
                }
            }
        }
        
        Database.executeBatch(new GPSDataImport(accountAssessments, assessmentId));
    }
    
    @AuraEnabled
    public static List<Account_GPS_Assessment__c> createAccountAssessmentRecordsForBulkUpload(Id assessmentId, String fileName, String base64Data, String contentType, String item) {
        List<String> fileData                            = new List<String>();
        List<Account_GPS_Assessment__c> lstAcctGPSAssess = new List<Account_GPS_Assessment__c>();
        Map<String, Integer> fieldNumberMap              = new Map<String, Integer>();
        List<String> lstFieldNames                       = new List<String>();
        String fieldValue;
        Integer fieldNumber;
        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        System.debug('filedata=='+base64Data);
        System.debug('filedata=='+(EncodingUtil.base64Decode(base64Data)).toString());
        base64Data=EncodingUtil.base64Decode(base64Data).toString();
        
        fileData= base64Data.split('\n');
        for(String fileDataRow : fileData) {
            fileDataRow = fileDataRow.replace('\r', '');
        }
        
        string[] csvFieldNames = fileData[0].split(',');
        for(Integer i = 0; i < csvFieldNames.size(); i++) {
            fieldNumberMap.put(csvFieldNames[i], i);
            // lstFieldNames.add(csvFieldNames[i].trim());
        }
        System.debug('csvFieldNames=' + csvFieldNames);
        Map<String, Id> usernameToIdMap = new Map<String, Id>();
        for(User user : [SELECT Id, Username FROM User]) {
            usernameToIdMap.put(user.Username, user.Id);
        }
        for (Integer i = 1; i < fileData.size(); i++) {
            Account_GPS_Assessment__c gpsObj = new Account_GPS_Assessment__c();
            List<String> csvRecordData = fileData[i].split(',');
            
            gpsObj.put('GPS_Assessment_AGN__c',assessmentId);
            for(String fieldName: csvFieldNames) {
                //  fieldName = fieldName.replace('\r', '').trim();
                fieldNumber = fieldNumberMap.get(fieldName);
                // if(fieldNumber == null) continue;
                
                fieldValue = csvRecordData[fieldNumber];
                System.debug('fieldName=' + fieldName);
                System.debug('fieldNumber=' + fieldNumber);
                System.debug('fieldValue=' + fieldValue);
                System.debug('!String.isEmpty(fieldValue)=' + !String.isEmpty(fieldValue));
                if(fieldName.touppercase().trim()=='ACCOUNTID' && !String.isBlank(fieldValue))
                {
                    
                    gpsObj.put('Account_AGN__c', fieldValue.trim());
                }
                
                else if(fieldName.touppercase().trim()=='USERID' && !String.isBlank(fieldValue))
                {
                    // If the file contains the user ID, then we don't need to query for it
                    gpsObj.put('OwnerId', fieldValue.trim());
                }
                else if(fieldName.touppercase().trim()=='USERNAME' && !String.isBlank(fieldValue))
                {
                    // We can use the User object's username to set the OwnerId because username is an external ID field
                    // This eliminates the need to query for the user ID
                    /*string query='select Id,name from user where Username = \'' + fieldValue.trim() + '\'';
user objUser=(User)Database.query(query);
gpsObj.put('OwnerId', objUser.Id);*/
                    gpsObj.put('OwnerId', usernameToIdMap.get(fieldValue.trim()));
                }
                
                
                
            }
            lstAcctGPSAssess.add(gpsObj);
        }
        //insert lstAcctGPSAssess;
        // Dedupe the list
        lstAcctGPSAssess = new List<Account_GPS_Assessment__c>(new Set<Account_GPS_Assessment__c>(lstAcctGPSAssess));
        System.debug('lstAcctGPSAssess:' + lstAcctGPSAssess);
        
        Database.executeBatch(new GPSDataImport(lstAcctGPSAssess,assessmentId));
        return lstAcctGPSAssess;
    }
    
    @AuraEnabled
    public static List<User> getUsersToAdd(Id assessmentId) {
        List<Id> matchingUserIds = new List<Id>();
        
        System.debug('assessmentId=' + assessmentId);
        GPS_Assessment__c assessment = getGPSAssessment(assessmentId);
        
        List<Id> userIds = new List<Id>();
        List<Id> productIds = new List<Id>();
        
        //PMO 3408: GPS Assessment: Start: Use Metadata instead of hardcoded profile names
        List<String> profileNames = new List<String>();
        for(AGN_GPS_Profile__mdt pf : [SELECT DeveloperName, MasterLabel FROM AGN_GPS_Profile__mdt]){
            profileNames.add(pf.MasterLabel);
        }
        System.debug('profileNames'+profileNames);
        //List<String> profileNames = new List<String>{'SMB Management Sales - Platform', 'SMB Primary Care Sales - Platform'};
        //PMO 3408: GPS Assessment: End: Use Metadata instead of hardcoded profile names
        
        String mySetupProductsQuery = 'SELECT OwnerId, Product_vod__c FROM My_Setup_Products_vod__c'
            + ' WHERE Product_vod__c IN (SELECT Product_AGN__c FROM GPS_Assessment_Product_AGN__c WHERE GPS_Assessment_AGN__c = \'' + assessmentId + '\')'
            + ' AND OwnerId IN (SELECT Id FROM User WHERE Profile.Name IN :profileNames AND IsActive = true)';
        System.debug(mySetupProductsQuery);
        for(My_Setup_Products_vod__c product : (List<My_Setup_Products_vod__c>)Database.query(mySetupProductsQuery)) {
            userIds.add(product.OwnerId);
            productIds.add(product.Product_vod__c);
        }
        
        Boolean isPersonAccounts = assessment.Assessment_Type_AGN__c == 'Customers';
        System.debug('userIds::::'+userIds);
        System.debug('productIds::::'+productIds);
        
        Map<String, List<TSF_vod__c>> accountsByTerritoryName = getAccountsByTerritoryName(userIds, productIds, isPersonAccounts);
        
        System.debug('accountsByTerritoryName::::'+accountsByTerritoryName);
        Map<String, List<UserTerritory2Association>> usersByTerritoryName = getUsersByTerritoryName(userIds, productIds, accountsByTerritoryName.keySet());
        System.debug('usersByTerritoryName::::'+usersByTerritoryName);
        for(String userTerritoryName : usersByTerritoryName.keySet()) {
            List<UserTerritory2Association> userTerritories = usersByTerritoryName.get(userTerritoryName);
            for(UserTerritory2Association userTerritory : userTerritories) {
                List<TSF_vod__c> targetAccountsForTerritory = accountsByTerritoryName.get(userTerritoryName);
                if(targetAccountsForTerritory != null) matchingUserIds.add(userTerritory.UserId);
            }
        }
        
        List<Id> managerIds = new List<Id>();
        for(User user : [SELECT ManagerId FROM User WHERE Id IN :matchingUserIds]) {
            managerIds.add(user.ManagerId);
        }
        
        System.debug('matchingUserIds::'+matchingUserIds);
        String query =
            'SELECT Id, Name, Email, ProfileId, Profile.Name, UserRoleId, UserRole.Name, '
            +'\n(SELECT Id, Name, Email, ManagerId, ProfileId, Profile.Name, UserRoleId, UserRole.Name FROM ManagedUsers WHERE Id IN ' + convertIdsToQueryString(matchingUserIds) + 'ORDER BY Name)'
            + '\nFROM User'
            + '\nWHERE Id IN ' + convertIdsToQueryString(managerIds)
            + '\nOR (Id IN ' + convertIdsToQueryString(matchingUserIds) + ' AND ManagerId = null)'
            + '\nORDER BY Name';
        
        System.debug(query.replace('\n', ' ' ));
        System.debug('query:::'+query);
        
        return (List<User>)Database.query(query);
    } 
    
    // For Testing
    @AuraEnabled
    public static List<Account> getAccountsToAdd(Id assessmentId, String searchString, Id ownerId, Boolean filterByProducts) {
        System.debug('assessmentId=' + assessmentId);
        System.debug('searchString=' + searchString);
        System.debug('ownerId=' + ownerId);
        
        String active ='Active';
        String inactive ='Inactive';
        String unassigned ='Unassigned';
        if(filterByProducts == null) filterByProducts = true;
        
        QueryStringGenerator queryStringGenerator = new QueryStringGenerator(Schema.Account.SObjectType);
        
        queryStringGenerator.includeFields(new List<String>{'RecordType.Description'});
        
        GPS_Assessment__c assessment = getGPSAssessment(assessmentId);
        
        // Used to filter for business accounts (false) or person accounts (true)
        Boolean personAccounts = assessment.Assessment_Type_AGN__c == 'Customers';
        
        List<Id> productIdsToInclude = new List<Id>();
        for(My_Setup_Products_vod__c mySetupProduct : [
            SELECT OwnerId, Product_vod__c FROM My_Setup_Products_vod__c
            WHERE Product_vod__c IN (SELECT Product_AGN__c FROM GPS_Assessment_Product_AGN__c WHERE GPS_Assessment_AGN__c = :assessmentId)
            AND OwnerId = :ownerId
        ]) {
            productIdsToInclude.add(mySetupProduct.Product_vod__c);
        }
        
        List<Id> accountIdsWithProducts = getAccountIdsWithProducts(assessmentId, personAccounts, productIdsToInclude);
        
        // Query for person accounts or business accounts, based on the assessment type
        String query = queryStringGenerator.getReadableFieldsQuery();
        System.debug('query::::' + query);
        query += '\nWHERE IsPersonAccount = ' + personAccounts;
        
        if(!String.isBlank(searchString)) query+= '\nAND Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
        
        // Get only accounts with the same product(s) as the assessment
        if(filterByProducts) query += '\nAND Id IN :accountIdsWithProducts';
        System.debug('accountIdsWithProducts.size()=' + accountIdsWithProducts.size());
        //System.debug('accountIdsWithProducts=' + JSON.serialize(accountIdsWithProducts));
        // Exclude existing acct-assessments for the same account ID + owner ID combination
        query += '\nAND Id NOT IN (SELECT Account_AGN__c FROM Account_GPS_Assessment__c WHERE GPS_Assessment_AGN__c = :assessmentId AND OwnerId = :ownerId )';
        query += '\nAND Status_AGN__c NOT IN (:inactive,:unassigned)';
        query += '\nORDER BY Name';
        query += '\nLIMIT 150';  //TODO add paging support
        System.debug('query=' + query.replace('\n', ' '));
        
        
        
        
        
        // *start Release 14 #Search based on primary business account name //
        
        String query2 = queryStringGenerator.getReadableFieldsQuery();
        System.debug('query2::::' + query2);
        query2 += '\nWHERE IsPersonAccount = ' + personAccounts;
        if(!String.isBlank(searchString)) query2+= '\nAND Primary_Parent_vod__r.Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'' ;
        
        // Get only accounts with the same product(s) as the assessment
        if(filterByProducts) query2 += '\nAND Id IN :accountIdsWithProducts';
        System.debug('accountIdsWithProducts.size()=' + accountIdsWithProducts.size());
        //System.debug('accountIdsWithProducts=' + JSON.serialize(accountIdsWithProducts));
        // Exclude existing acct-assessments for the same account ID + owner ID combination
        query2 += '\nAND Id NOT IN (SELECT Account_AGN__c FROM Account_GPS_Assessment__c WHERE GPS_Assessment_AGN__c = :assessmentId AND OwnerId = :ownerId )';
        query2 += '\nAND Status_AGN__c NOT IN (:inactive,:unassigned)';
        query2 += '\nORDER BY Name';
        query2 += '\nLIMIT 150';  //TODO add paging support
        System.debug('query2=' + query2.replace('\n', ' '));
        
        // *end Release 14 #Search based on primary business account name //
        
        
        List<Account> results1 = (List<Account>)Database.query(query);
        List<Account> results2 = (List<Account>)Database.query(query2);
        
        //To return the list of Accounts
        List<Account> finalList = new List<Account>();
        
        // Remove duplicates
        integer k = 0; //counter
        for(Account results1Id : results1)
        {
            for(Account results2Id : results2)
            {
                if(results1Id.id == results2Id.id)
                {
                    k++;
                    System.debug('Duplicate IDs: '+results1Id.id);
                    break;
                }
            }
            
            if(k == 0)
            {
                finalList.add(results1Id);
            }
        }  
        
        finalList.addAll(results2);
        
        System.debug('Results1 Name size'+results1.size());
        System.debug('Results2 Name size'+results2.size());
        System.debug('FinalList size'+finalList.size());      
        
        return finalList;
    }      
    
    
    @AuraEnabled
    public static void createAccountAssessments(Id assessmentId, String accountIdsString) {
        List<Id> accountIds = accountIdsString.split(',');
        
        List<Account_GPS_Assessment__c> accountAssessments =new List<Account_GPS_Assessment__c>();
        for (Id accountId :  accountIds) {
            if(Schema.sObjectType.Account_GPS_Assessment__c.fields.Account_AGN__c.isCreateable() && 
               Schema.sObjectType.Account_GPS_Assessment__c.fields.Account_AGN__c.isUpdateable() &&
               Schema.sObjectType.Account_GPS_Assessment__c.fields.GPS_Assessment_AGN__c.isCreateable() &&
               Schema.sObjectType.Account_GPS_Assessment__c.fields.GPS_Assessment_AGN__c.isUpdateable())    // AKJ_cc
            {
                Account_GPS_Assessment__c accountAssessment = new Account_GPS_Assessment__c(
                    Account_AGN__c        = accountId,
                    GPS_Assessment_AGN__c = assessmentId
                );
                accountAssessments.add(accountAssessment);
            }
            
        }
        if(Schema.sObjectType.Account_GPS_Assessment__c.isUpdateable() &&
           Schema.sObjectType.Account_GPS_Assessment__c.isCreateable())    // AKJ_cc
        {
            upsert accountAssessments;
        }
        
    }
    
    @AuraEnabled
    public static List<GPS_Assessment_Product_AGN__c> getGPSAssessmentProducts(Id assessmentId) {
        QueryStringGenerator queryStringGenerator = new QueryStringGenerator(Schema.GPS_Assessment_Product_AGN__c.SObjectType);
        queryStringGenerator.includeFields(new List<String>{
            'Product_AGN__r.Parent_Product_vod__c',
                'Product_AGN__r.Product_Type_vod__c',
                'Product_AGN__r.External_ID_vod__c'
                });
        
        String query = queryStringGenerator.getReadableFieldsQuery()
            + '\nWHERE GPS_Assessment_AGN__c = :assessmentId'
            + '\nORDER BY Product_AGN__r.Name';
        
        return (List<GPS_Assessment_Product_AGN__c>)Database.query(query);
    }
    
    @AuraEnabled
    public static List<AccountAssessmentWithStatsWrapper> getGPSAssessmentsForListView(Id ownerId, String sortField, Decimal pageNumber, Integer recordsPerPage, Boolean sortIsAsc) {
        QueryStringGenerator queryStringGenerator = new QueryStringGenerator(Schema.GPS_Assessment__c.SObjectType);
        //  String query = queryStringGenerator.getReadableFieldsQuery()
        //String query = 'SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, SystemModstamp, MayEdit, IsLocked, AGN_Share_Absolute_Question_AGN__c, AGN_Share_Absolute_Question_Override_AGN__c, AGN_Share_Percent_Question_Override_AGN__c, AGN_Share_Percentage_Question_AGN__c, Allow_Account_Removal_AGN__c, Assessment_Type_AGN__c, Business_Size_Question_AGN__c, Business_Size_Question_Override_AGN__c, Change_Metrics_AGN__c, Custom_Question_1_AGN__c, Custom_Question_1_List_Of_Values_AGN__c, Custom_Question_1_Type_AGN__c, Custom_Question_2_AGN__c, Custom_Question_2_List_Of_Values_AGN__c, Custom_Question_2_Type_AGN__c, Custom_Question_3_AGN__c, Custom_Question_3_List_Of_Values_AGN__c, Custom_Question_3_Type_AGN__c, Custom_Question_4_AGN__c, Custom_Question_4_List_Of_Values_AGN__c, Custom_Question_4_Type_AGN__c, Data_Collection_Period_1_AGN__c, Data_Collection_Period_2_AGN__c, Data_Period_Collection_AGN__c, Default_Dosage_PP_AGN__c, Default_Frequency_AGN__c, Display_Confidence_Level_Capture_AGN__c, Display_KOL_Capture_AGN__c, Display_Referrer_Capture_AGN__c, Dosage_Unit_AGN__c, Dose_Per_Treatment_Question_AGN__c, Dose_Per_Treatment_Question_Override_AGN__c, Due_Date_AGN__c, Financial_Projection_Period_Mths_AGN__c, Freq_Of_Treatment_Question_AGN__c, Freq_Of_Treatment_Question_Override_AGN__c, Indication_Therapy_Area_AGN__c, Overdue_in_Days_AGN__c, Product_List_AGN__c, Projection_Analysis_Note_AGN__c, Projection_Metric_AGN__c, Secondary_Brand_AGN__c, Secondary_Brand_Indication_AGN__c, Secondary_Brand_Name_AGN__c, Secondary_Brand_Question_AGN__c, Secondary_Brand_Question_Override_AGN__c, Share_Capture_AGN__c, toLabel(Status_AGN__c), Time_Frame_AGN__c, Unit_AGN__c, Use_Dosage_Data_AGN__c, Use_Frequency_Data_AGN__c, Use_Market_Data_AGN__c, Value_Per_Dosage_Unit_AGN__c, Value_Type_AGN__c, Display_Local_ASP_Capture_AGN__c, Product_Name_AGN__c, Country_Code_AGN__c, Current_User_Country_Code_AGN__c FROM GPS_Assessment__c WHERE Id IN (SELECT GPS_Assessment_AGN__c FROM Account_GPS_Assessment__c WHERE OwnerId = :ownerId)';
        //PMO 3408: GPS Assessment: 'query' has been modified, with removal of fields not necessary
        String query = 'SELECT Id, OwnerId, Owner.Name, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, CreatedBy.Name, LastModifiedDate, LastModifiedById, LastModifiedBy.Name, SystemModstamp, MayEdit, IsLocked, AGN_Share_Absolute_Question_AGN__c, AGN_Share_Absolute_Question_Override_AGN__c, Allow_Account_Removal_AGN__c, Assessment_Type_AGN__c, Business_Size_Question_AGN__c, Business_Size_Question_Override_AGN__c, Change_Metrics_AGN__c, Custom_Question_1_AGN__c, Custom_Question_1_List_Of_Values_AGN__c, Custom_Question_1_Type_AGN__c, Custom_Question_2_AGN__c, Custom_Question_2_List_Of_Values_AGN__c, Custom_Question_2_Type_AGN__c, Custom_Question_3_AGN__c, Custom_Question_3_List_Of_Values_AGN__c, Custom_Question_3_Type_AGN__c, Custom_Question_4_AGN__c, Custom_Question_4_List_Of_Values_AGN__c, Custom_Question_4_Type_AGN__c, Display_Confidence_Level_Capture_AGN__c, Display_KOL_Capture_AGN__c, Display_Referrer_Capture_AGN__c, Due_Date_AGN__c, Financial_Projection_Period_Mths_AGN__c, Overdue_in_Days_AGN__c, Product_List_AGN__c, Projection_Analysis_Note_AGN__c, Projection_Metric_AGN__c, toLabel(Status_AGN__c), Time_Frame_AGN__c, Unit_AGN__c,Value_Type_AGN__c, Product_Name_AGN__c, Country_Code_AGN__c, Current_User_Country_Code_AGN__c FROM GPS_Assessment__c WHERE Id IN (SELECT GPS_Assessment_AGN__c FROM Account_GPS_Assessment__c WHERE OwnerId = :ownerId)';
        if(sortField != null) {
            String sortDirection = sortIsAsc ? ' ASC ' : ' DESC ' ;
            String nullsSortDirection = sortIsAsc ? ' NULLS FIRST ' : ' NULLS LAST ' ;
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + sortDirection + nullsSortDirection;
        }
        
        if(recordsPerPage != null) query += ' LIMIT ' + recordsPerPage;
        if(recordsPerPage != null && pageNumber != null) {
            Integer offsetCount = ((Integer)pageNumber - 1) * recordsPerPage;
            System.debug('offsetCount=' + offsetCount);
            query += ' OFFSET ' + offsetCount;
        }
        System.debug('query=' + query);
        List<GPS_Assessment__c> assessments = (List<GPS_Assessment__c>)Database.query(query);
        
        String aggregateQuery = 'SELECT GPS_Assessment_AGN__c assessmentId, SUM(Assessment_Completed_Numeric_AGN__c) completed, COUNT(Id) total'
            + ' FROM ' + Schema.Account_GPS_Assessment__c.SObjectType
            + '\nWHERE OwnerId = :ownerId'
            + '\nGROUP BY GPS_Assessment_AGN__c';
        List<AggregateResult> aggregates = (List<AggregateResult>)Database.query(aggregateQuery);
        
        Map<Id, AggregateResult> aggregateResultsByAssessmentId = new Map<Id, AggregateResult>();
        for(AggregateResult aggregate : aggregates) {
            aggregateResultsByAssessmentId.put((Id)aggregate.get('assessmentId'), aggregate);
        }
        
        List<AccountAssessmentWithStatsWrapper> results = new List<AccountAssessmentWithStatsWrapper>();
        for(GPS_Assessment__c assessment : assessments) {
            AccountAssessmentWithStatsWrapper stats = new AccountAssessmentWithStatsWrapper();
            stats.assessment               = assessment;
            stats.completedAssessmentCount = (Decimal)aggregateResultsByAssessmentId.get(assessment.Id).get('completed');
            stats.totalAssessmentCount     = (Decimal)aggregateResultsByAssessmentId.get(assessment.Id).get('total');
            results.add(stats);
        }
        return results;
    }
    
    @AuraEnabled
    public static Integer getGPSAssessmentsTotalCountForListView(Id ownerId) {
        return [SELECT COUNT() FROM GPS_Assessment__c WHERE Id IN (SELECT GPS_Assessment_AGN__c FROM Account_GPS_Assessment__c WHERE OwnerId = :ownerId)];
    }
    
    @AuraEnabled
    public static List<Account_GPS_Assessment__c> getAccountGPSAssessments(Id assessmentId, Id ownerId, Boolean filterIsCompleted, String sortField, Decimal pageNumber, Integer recordsPerPage, Boolean sortIsAsc,  String searchString) {
        if(ownerId == null) ownerId = UserInfo.getUserId();
        
        System.debug('getAccountGPSAssessments');
        System.debug('assessmentId='+assessmentId);
        System.debug('ownerId='+ownerId);
        System.debug('recordsPerPage=' + recordsPerPage);
        System.debug('filterIsCompleted=' + filterIsCompleted);
        System.debug('searchString=' + searchString);
        
        // *start Release 14 #queried firstName and lastName //
        
        QueryStringGenerator queryStringGenerator = new QueryStringGenerator(Schema.Account_GPS_Assessment__c.SObjectType);
        queryStringGenerator.includeFields(new List<String>{
            'Account_AGN__r.Veeva_Id_AGN__c', 'Account_AGN__r.Primary_Parent_vod__c', 'Account_AGN__r.Primary_Parent_vod__r.Name', 'Account_AGN__r.FirstName', 'Account_AGN__r.LastName','Account_AGN__r.Status_AGN__c'
                });
        
        // *end Release 14 #queried firstName and lastName //
        
        String query = queryStringGenerator.getReadableFieldsQuery()
            + '  WHERE GPS_Assessment_AGN__c = :assessmentId'
            + ' AND OwnerId = :ownerId';
        
        if(!string.isBlank(searchString))
            query= query+ ' AND Account_AGN__r.Name LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\'';
        
        if(filterIsCompleted != null) {
            query += ' AND Assessment_Completed_AGN__c = :filterIsCompleted';
        }
        
        if(sortField == null) {
            sortField = 'Account_AGN__r.Name';
            sortIsAsc = true;
        }
        if(sortField != null) {
            String sortDirection = sortIsAsc ? ' ASC ' : ' DESC ' ;
            String nullsSortDirection = sortIsAsc ? ' NULLS FIRST ' : ' NULLS LAST ' ;
            query += ' ORDER BY ' + String.escapeSingleQuotes(sortField) + sortDirection + nullsSortDirection;
        } // AKJ cc
        
        if(recordsPerPage != null) query += ' LIMIT ' + recordsPerPage;
        if(recordsPerPage != null && pageNumber != null) {
            Integer offsetCount = ((Integer)pageNumber - 1) * recordsPerPage;
            System.debug('offsetCount=' + offsetCount);
            query += ' OFFSET ' + offsetCount;
        }
        System.debug('query=' + query);
        return (List<Account_GPS_Assessment__c>)Database.query(query);
    }
    
    @AuraEnabled
    public static Integer getAccountGPSAccountAssessmentsTotalCount(Id assessmentId, Id ownerId) {
        return [SELECT COUNT() FROM Account_GPS_Assessment__c WHERE GPS_Assessment_AGN__c = :assessmentId AND OwnerId = :ownerId];
    }
    
    @AuraEnabled
    public static List<AggregateResult> getAccountGPSAssessmentStatsByOwner(Id assessmentId, String sortField, Decimal pageNumber, Integer recordsPerPage, Boolean sortIsAsc) {
        String query =
            'SELECT OwnerId, Owner.Name OwnerName, SUM(Assessment_Completed_Numeric_AGN__c) CompletedAssessments, COUNT(Id) TotalAssessments'
            + ' FROM Account_GPS_Assessment__c'
            + ' WHERE GPS_Assessment_AGN__c = \'' + assessmentId + '\'';
        
        String groupByString = ' GROUP BY OwnerId';
        String orderyByString = '';
        if(sortField != null) {
            String sortDirection = sortIsAsc ? ' ASC ' : ' DESC ' ;
            String nullsSortDirection = sortIsAsc ? ' NULLS FIRST ' : ' NULLS LAST ' ;
            orderyByString = ' ORDER BY ' + String.escapeSingleQuotes(sortField) + sortDirection + nullsSortDirection;  // AKJ cc
            groupByString += ', ' + String.escapeSingleQuotes(sortField);  // AKJ cc
        }
        query += groupByString + orderyByString;
        
        if(recordsPerPage != null) query += ' LIMIT ' + recordsPerPage;
        if(recordsPerPage != null && pageNumber != null) {
            Integer offsetCount = ((Integer)pageNumber - 1) * recordsPerPage;
            System.debug('offsetCount=' + offsetCount);
            query += ' OFFSET ' + offsetCount;
        }
        System.debug('query=' + query);
        return (List<AggregateResult>)Database.query(query);
    }
    
    @AuraEnabled
    public static Integer getAccountGPSAssessmentStatsByOwnerTotalCount(Id assessmentId) {
        AggregateResult result = [SELECT COUNT_DISTINCT(OwnerId) cnt FROM Account_GPS_Assessment__c WHERE GPS_Assessment_AGN__c = :assessmentId];
        return (Integer)result.get('cnt');
    }
    
    @AuraEnabled
    public static Id deleteAccountGPSAssessment(Id accountAssessmentId) {
        Account_GPS_Assessment__c accountAssessment = [SELECT Id, OwnerId FROM Account_GPS_Assessment__c WHERE Id = :accountAssessmentId];
        if(Account_GPS_Assessment__c.sObjectType.getDescribe().isDeletable())
            delete accountAssessment;
        return accountAssessment.OwnerId;
    }
    
    @AuraEnabled
    public static void deleteAccountCustomerGPSAssessment(Id accountCustomerAssessmentId) {
        System.debug('id:' + accountCustomerAssessmentId);
        Account_Customer_GPS_Assessment_AGN__c accountAssessment = new Account_Customer_GPS_Assessment_AGN__c(Id = accountCustomerAssessmentId);
        if(Account_Customer_GPS_Assessment_AGN__c.sObjectType.getDescribe().isDeletable())
            delete accountAssessment;
    }
    
    @AuraEnabled
    public static void deleteGPSAssessmentProduct(Id assessmentProductId) {
        System.debug('deleteAssessmentProduct');
        System.debug(assessmentProductId);
        GPS_Assessment_Product_AGN__c assessmentProduct = new GPS_Assessment_Product_AGN__c(Id = assessmentProductId);
        if(GPS_Assessment_Product_AGN__c.sObjectType.getDescribe().isDeletable())
            delete assessmentProduct;
        Database.emptyRecycleBin(assessmentProduct);
    }
    
    @AuraEnabled
    public static List<Account_GPS_Assessment__c> saveAccountGPSAssessments(List<Account_GPS_Assessment__c> accountAssessments, Boolean filterIsCompleted, String sortField, Decimal pageNumber, Integer recordsPerPage, Boolean sortIsAsc, String searchString) {
        System.debug('start saveAccountGPSAssessments');
        System.debug('filterIsCompleted=' + filterIsCompleted);
        System.debug('sortField=' + sortField);
        System.debug('pageNumber=' + pageNumber);
        System.debug('recordsPerPage=' + recordsPerPage);
        System.debug('sortIsAsc=' + sortIsAsc);
        System.debug('searchString=' + searchString);
        
        update accountAssessments;
        
        Id assessmentId = accountAssessments[0].GPS_Assessment_AGN__c;
        Id ownerId = accountAssessments[0].OwnerId;
        
        return getAccountGPSAssessments(assessmentId, ownerId, filterIsCompleted, sortField, pageNumber, recordsPerPage, sortIsAsc, searchString);
    }
    /* End Business Excellence user methods */
    
    /* Start Sales Rep user methods */
    /*** Start Sales Rep user - account customer form methods ***/
    @AuraEnabled
    public static AccountCustomerAssessmentWrapper getAssessmentAccountCustomerRecords(Id userId, Id accountAssessmentId) {
        AccountCustomerAssessmentWrapper wrapper = new AccountCustomerAssessmentWrapper();
        
        // Get the Account_Customer_GPS_Assessment_AGN__c records
        //PMO 3408: GPS Assessment: Account-Customer modification
        String query = 'SELECT Id, Customer_AGN__r.Veeva_Id_AGN__c,Customer_AGN__r.Name,Customer_AGN__r.Primary_Parent_vod__c,'
            //+ '\n Customer_AGN__r.Primary_Parent_vod__r.Name, KOL_AGN__c,Digital_Only_Acc_Cust_Assessment_AGN__c,Consent_for_Digital_Acc_Cust_Assmnt_AGN__c, Business_Size_Acc_Cust_Assessment_AGN__c, AGN_Usage_Acc_Cust_Assessment_AGN__c, Customer_Contribution_AGN__c, Rationale_AGN__c, Total_Account_Contribution_AGN__c, '
            + '\n Customer_AGN__r.Primary_Parent_vod__r.Name, KOL_AGN__c,Digital_Only_Acc_Cust_Assessment_AGN__c,Consent_for_Digital_Acc_Cust_Assmnt_AGN__c, Business_Size_Acc_Cust_Assessment_AGN__c, AGN_Usage_Acc_Cust_Assessment_AGN__c, Total_Account_Contribution_AGN__c, '
            + '\n Custom_Question_1_Response_AGN__c, Custom_Question_2_Response_AGN__c, Custom_Question_3_Response_AGN__c, Custom_Question_4_Response_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Status_AGN__c, Account_GPS_Assessment_AGN__r.Business_Size_Current_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Allow_Account_Removal_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Consent_for_Digital_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Digital_Only_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Display_KOL_Capture_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Business_Size_Question_Override_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Business_Size_Question_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.AGN_Share_Absolute_Question_Override_AGN__c, ' 
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.AGN_Share_Absolute_Question_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_1_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_2_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_3_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_4_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_1_Type_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_2_Type_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_3_Type_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_4_Type_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_1_List_Of_Values_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_2_List_Of_Values_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_3_List_Of_Values_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Custom_Question_4_List_Of_Values_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.AGN_Share_Absolute_QSTN_Mandatory_AGN__c, '
            + '\n Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__r.Business_Size_Question_Mandatory_AGN__c '
            + '\n FROM Account_Customer_GPS_Assessment_AGN__c '
            + '\n WHERE OwnerId = :userId AND Account_GPS_Assessment_AGN__c = :accountAssessmentId '
            + '\n ORDER BY Customer_AGN__r.Name';
        wrapper.accountCustomerAssessments = (List<Account_Customer_GPS_Assessment_AGN__c>)Database.query(query);
        
        // Get the account totals
        // //PMO 3408: GPS Assessment: Account-Customer modification
        String groupedResultsQuery =
            //'SELECT Customer_AGN__r.Primary_Parent_vod__c accountId,sum(Customer_Contribution_AGN__c) sumContr'
            'SELECT Customer_AGN__r.Primary_Parent_vod__c accountId'
            + '\nFROM Account_Customer_GPS_Assessment_AGN__c'
            + '\nWHERE OwnerId = \'' + userId + '\''
            + '\nAND Account_GPS_Assessment_AGN__c = \'' + accountAssessmentId + '\''
            + '\nGROUP BY Customer_AGN__r.Primary_Parent_vod__c';
        AggregateResult[] groupedResults = (List<AggregateResult>)Database.query(groupedResultsQuery);
        Map<Id, Decimal> accountTotals = new Map<Id, Decimal>();
        //for(AggregateResult result : groupedResults) accountTotals.put((Id)result.get('accountId'), (Decimal)result.get('sumContr'));
        for(AggregateResult result : groupedResults) accountTotals.put((Id)result.get('accountId'),null) ;
        wrapper.accountTotals = accountTotals;
        System.debug('accountTotals'+accountTotals);
        
        return wrapper;
    }
    
    @AuraEnabled
    public static List<Account> getCustomerRecords(Id accountAssessmentId) {
        System.debug('getCustomerRecords');
        System.debug('accountAssessmentId:' + accountAssessmentId);
        Account_GPS_Assessment__c accountAssessment = [SELECT Id, Account_AGN__c, GPS_Assessment_AGN__c FROM Account_GPS_Assessment__c WHERE Id = :accountAssessmentId];
        System.debug('accountAssessment.Id:' + accountAssessment.Id);
        System.debug('accountAssessment.Account_AGN__c:' + accountAssessment.Account_AGN__c);
        System.debug('accountAssessment.GPS_Assessment_AGN__c:' + accountAssessment.GPS_Assessment_AGN__c);
        
        List<Account> lstAcct = [
            SELECT Id, Name, Target__c
            FROM Account
            WHERE IsPersonAccount = true
            AND Primary_Parent_vod__c = :accountAssessment.Account_AGN__c
            AND Id NOT IN (
                SELECT Customer_AGN__c FROM Account_Customer_GPS_Assessment_AGN__c
                WHERE Account_GPS_Assessment_AGN__r.GPS_Assessment_AGN__c = :accountAssessment.GPS_Assessment_AGN__c
            )
            ORDER BY Name
        ];
        System.debug('customer:' + lstAcct);
        return lstAcct;
    }
    
    @AuraEnabled
    public static void createAccountCustomerRecord(Id userId, Id accountAssessmentId, List<Id> customerIds) {
        List<Account_Customer_GPS_Assessment_AGN__c > assessmentAccounts = new List<Account_Customer_GPS_Assessment_AGN__c  >();
        // Account_GPS_Assessment__c objAccount=new Account_GPS_Assessment__c();
        //  objAccount=[select OwnerId from Account_GPS_Assessment__c where Id=:accountAssessmentId];
        for(Id customerId : customerIds) {
            if(Schema.sObjectType.Account_Customer_GPS_Assessment_AGN__c.fields.Account_GPS_Assessment_AGN__c.isCreateable() &&
               Schema.sObjectType.Account_Customer_GPS_Assessment_AGN__c.fields.Customer_AGN__c.isCreateable() &&
               Schema.sObjectType.Account_Customer_GPS_Assessment_AGN__c.fields.OwnerId.isCreateable())
            {
                
                
                
                Account_Customer_GPS_Assessment_AGN__c  assessmentAccount = new Account_Customer_GPS_Assessment_AGN__c(
                    Account_GPS_Assessment_AGN__c = accountAssessmentId,
                    Customer_AGN__c               = customerId,
                    OwnerId                       = userId
                );
                
                
                assessmentAccounts.add(assessmentAccount);
            }
        }
        if(Schema.sObjectType.Account_Customer_GPS_Assessment_AGN__c.isCreateable())
            insert assessmentAccounts;
    }
    
    @AuraEnabled
    public static void upsertAccountCustomerAssessment(String wrapperJSON) {
        System.debug('wrapper');
        AccountCustomerAssessmentWrapper wrapper = (AccountCustomerAssessmentWrapper)JSON.deserialize(wrapperJSON, AccountCustomerAssessmentWrapper.class);
        System.debug(wrapper);
        update wrapper.accountCustomerAssessments;
    }
    /*** End Sales Rep user - account customer form methods ***/
    
    /* End Sales Rep user methods */
    
    /* Start Line Manager user methods */
    @AuraEnabled
    public static List<wrapperClass> getDirectReports(Id userId, Decimal pageNumber, Integer recordToDisply) {
        System.debug('start2');
        System.debug('pageNumber:' + pageNumber);
        System.debug('recordToDisply:' + recordToDisply);
        
        Schema.SObjectType sobjType = Schema.User.SObjectType;
        QueryStringGenerator queryStringGenerator = new QueryStringGenerator(sobjType);
        
        String query = 'SELECT Id, Name, FirstName, LastName, Email, Username, UserRoleId, UserRole.Name FROM User'
            + ' WHERE (ManagerId = :userId OR Id = :userId)'
            + ' AND Id IN (SELECT OwnerId FROM Account_GPS_Assessment__c)'
            + ' ORDER BY Name';
        List<User> lstUser = Database.query(query);
        
        User objUser;
        Integer pageSize = recordToDisply;
        Integer offset   = ((Integer)pageNumber - 1) * pageSize;
        Integer counter  = 0;
        
        AggregateResult[] groupedResults = [
            SELECT count(id) cnt, OwnerId Own,Owner.Firstname FNm,Owner.Lastname LNm
            FROM Account_GPS_Assessment__c
            WHERE OwnerId IN :lstUser
            GROUP BY OwnerId, Owner.Firstname, Owner.LastName
        ];
        
        AggregateResult[] assessmentCount = [
            SELECT count_distinct(GPS_Assessment_AGN__c) asscnt, OwnerId Own FROM Account_GPS_Assessment__c
            WHERE OwnerId IN :lstUser
            GROUP BY OwnerId
        ];
        
        System.debug('aggregateresult:' + groupedResults);
        wrapperClass objwrapperClass;
        List<wrapperClass> lstWrapper=new List<wrapperClass> ();
        for(User objasuser : lstUser) {
            objwrapperClass = new wrapperClass();
            objwrapperClass.assessmentCount=0;
            for(AggregateResult ar : groupedResults)  {
                if(objasUser.Id == ar.get('Own')) objwrapperClass.assessmentCount = (Integer)ar.get('cnt');
            }
            for(AggregateResult ac : assessmentCount)  {
                if(objasUser.Id == ac.get('Own')) objwrapperClass.gpsAssessmentCount = (Integer)ac.get('asscnt');
            }
            
            objwrapperClass.objUser = objasUser;
            
            if(counter >= offset && counter < (offset + pageSize)) lstWrapper.add(objwrapperClass);
            
            counter++;
        }
        
        System.debug('wrapper:' + lstWrapper);
        return lstWrapper;
    }
    
    @AuraEnabled
    public static Integer getTotal(Id userId) {
        String queryString = 'SELECT COUNT() FROM User WHERE ManagerId = :userId';
        return Database.countQuery(queryString);
    }
    /* End Line Manager user methods */
    
    private static List<Account_GPS_Assessment__c> generateAccountAssessments(Id assessmentId, List<Account> accounts) {
        return generateAccountAssessments(assessmentId, accounts, null);
    }
    
    private static List<Account_GPS_Assessment__c> generateAccountAssessments(Id assessmentId, List<Account> accounts, Id ownerId) {
        System.debug('start generateAccountAssessments');
        
        List<Account_GPS_Assessment__c> accountAssessments = new List<Account_GPS_Assessment__c>();
        for(Account account : accounts) {
            if(Schema.sObjectType.Account_GPS_Assessment__c.fields.Account_AGN__c.isCreateable() && 
               Schema.sObjectType.Account_GPS_Assessment__c.fields.Account_AGN__c.isUpdateable() &&
               Schema.sObjectType.Account_GPS_Assessment__c.fields.OwnerId.isCreateable() &&
               Schema.sObjectType.Account_GPS_Assessment__c.fields.OwnerId.isUpdateable() &&
               Schema.sObjectType.Account_GPS_Assessment__c.fields.GPS_Assessment_AGN__c.isCreateable() &&
               Schema.sObjectType.Account_GPS_Assessment__c.fields.GPS_Assessment_AGN__c.isUpdateable())    // AKJ_cc
            {
                Account_GPS_Assessment__c accountAssessment = new Account_GPS_Assessment__c(
                    Account_AGN__c        = account.Id,
                    GPS_Assessment_AGN__c = assessmentId,
                    OwnerId               = ownerId != null ? ownerId : account.OwnerId
                );
                GPSAssessmentUtils.setAccountAssessmentUniqueId(accountAssessment);
                accountAssessments.add(accountAssessment);
                
            }
        }
        
        return accountAssessments;
    }
    
    private static List<Id> getAccountIdsWithProducts(Id assessmentId, Boolean personAccounts) {
        return getAccountIdsWithProducts(assessmentId, personAccounts, null);
    }
    
    private static List<Id> getAccountIdsWithProducts(Id assessmentId, Boolean personAccounts, List<Id> productIdsToInclude) {
        // for assessmentId, get product codes
        // for territories, get accounts with product codes
        List<Id> accountIds = new List<Id>();
        String query =
            'SELECT Account_vod__c FROM Product_Metrics_vod__c'
            + ' WHERE Products_vod__c IN (SELECT Product_AGN__c FROM GPS_Assessment_Product_AGN__c WHERE GPS_Assessment_AGN__c = :assessmentId)'
            + ' AND Account_vod__r.IsPersonAccount = :personAccounts';
        
        if(productIdsToInclude != null && !productIdsToInclude.isEmpty()) query += ' AND Products_vod__c IN :productIdsToInclude';
        
        for(Product_Metrics_vod__c productMetric : (List<Product_Metrics_vod__c>)Database.query(query)) {
            accountIds.add(productMetric.Account_vod__c);
        }
        
        return accountIds;
    }
    
    
    private static Map<String, List<TSF_vod__c>> getAccountsByTerritoryName(List<Id> userIds, List<Id> productIds, Boolean isPersonAccounts) {
        
        Map<String, List<TSF_vod__c>> targetAccountsByTerritoryName = new Map<String, List<TSF_vod__c>>();
        
        System.debug('inside getAccountsByTerritoryName......');
        
        Map<String, List<UserTerritory2Association>> usersByTerritoryName = getUsersByTerritoryName(userIds, productIds);
        List<TSF_vod__c> targetAccounts = [
            SELECT Account_vod__c, Territory_vod__c
            FROM TSF_vod__c
            WHERE Territory_vod__c IN :usersByTerritoryName.keySet()
            AND Account_vod__c IN (SELECT Account_vod__c FROM Product_Metrics_vod__c WHERE Products_vod__c IN :productIds)
            AND Account_vod__r.Target__c = true
            AND Account_vod__r.IsPersonAccount = :isPersonAccounts
        ];
        
        System.debug('targetAccounts::::::::::'+targetAccounts);
        for(TSF_vod__c targetAccount : targetAccounts) {
            if(targetAccount.Territory_vod__c == null) continue;
            
            List<TSF_vod__c> targetAccountsForTerritoryName = targetAccountsByTerritoryName.get(targetAccount.Territory_vod__c);
            if(targetAccountsForTerritoryName == null) targetAccountsForTerritoryName = new List<TSF_vod__c>();
            
            targetAccountsForTerritoryName.add(targetAccount);
            targetAccountsByTerritoryName.put(targetAccount.Territory_vod__c, targetAccountsForTerritoryName);
        }
        
        return targetAccountsByTerritoryName;
        
    }
    
    private static Map<String, List<UserTerritory2Association>> getUsersByTerritoryName(List<Id> userIds, List<Id> productIds) {
        return getUsersByTerritoryName(userIds, productIds, null);
    }
    
    private static Map<String, List<UserTerritory2Association>> getUsersByTerritoryName(List<Id> userIds, List<Id> productIds, Set<String> territoryNames) {
        Map<String, List<UserTerritory2Association>> usersByTerritoryName = new Map<String, List<UserTerritory2Association>>();
        
        String territoryQuery = 'SELECT Id, Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId IN :userIds AND Territory2.Territory2Model.State =\'Active\')';
        if(territoryNames != null) territoryQuery +=  ' AND Name IN :territoryNames';
        Map<Id, Territory2> territoriesById = new Map<Id, Territory2>((List<Territory2>)Database.query(territoryQuery));
        
        for(UserTerritory2Association userTerritory : [SELECT Id, UserId, Territory2Id FROM UserTerritory2Association WHERE UserId IN :userIds AND Territory2.Territory2Model.State ='Active']) {
            Territory2 territory = territoriesById.get(userTerritory.Territory2Id);
            
            if(territory == null) continue;
            
            List<UserTerritory2Association> userTerritories = usersByTerritoryName.get(territory.Name);
            if(userTerritories == null) userTerritories = new List<UserTerritory2Association>();
            
            userTerritories.add(userTerritory);
            usersByTerritoryName.put(territory.Name, userTerritories);
        }
        
        return usersByTerritoryName;
    }
    
    private static String convertIdsToQueryString(Set<Id> recordIds) {
        return convertIdsToQueryString(new List<Id>(recordIds));
    }
    
    private static String convertIdsToQueryString(List<Id> recordIds) {
        return convertStringsToQueryString(recordIds);
    }
    
    private static String convertStringsToQueryString(Set<String> values) {
        return convertStringsToQueryString(new List<String>(values));
    }
    
    private static String convertStringsToQueryString(List<String> values) {
        return '(\'' + String.join(values, '\', \'') + '\')';
    }
    
}