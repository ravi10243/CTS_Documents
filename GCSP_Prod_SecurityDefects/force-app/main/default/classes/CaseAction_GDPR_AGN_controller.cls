/*
*---------------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      GDPR Team
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        1.0
* @created        
* @modified      15-Nov-2019
* @testClass     
* @Class Name    CaseAction_GDPR_AGN_controller
* -------------------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Nov-2019           
*  Apex Controller for Aura Component AssignTask_GDPR_AGN which is used to Assign Business Owner Task to BO from Case by DPO.
*-------------------------------------------------------------------------------------------------------------------------------+
*/


public with sharing class CaseAction_GDPR_AGN_controller 
{
    @AuraEnabled
    public static List<Case> ValidateCaseDetails(Id caseId) 
    {
        List<Case> ca = new List<Case>();
        ca = [SELECT Id,Status, DS_Validation_complete_AGN__c, RecordType.Name FROM Case WHERE Id = :caseId];
        return ca;
    }
   // Added by Kunal Banerjee on 22/11/2019: This method has been added to fetch logged in User division. 
   // LPO user should not be able to assign task. 
    @AuraEnabled
    public static List<User> ValidateUserDetails(Id userId) 
    {
       List<User> us = new List<User>();
       us = [SELECT Division FROM User WHERE Id = :userId];
       return us;
    }
    @AuraEnabled
    public static List<Asset_Register_AGN__c> fetchCaseDetails(Id caseId) 
    { 
        boolean isGDPR = false;
        boolean isCCPA = false;
        Case ca = new Case();
        ca = [SELECT Id,CaseNumber,Country_AGN_GDPR__c,Role_with_Allergan_GDPR_AGN__c,Status, RecordType.Name FROM Case WHERE Id = :caseId];
        
        System.debug('Case Id'+ca.Id);  
        
        //Fetching the details from Custom Setting AGN_GDPR_CaseToAssetRegistersMapping__c for Role Maping
        AGN_GDPR_CaseToAssetRegistersMapping__c assetRegMap = AGN_GDPR_CaseToAssetRegistersMapping__c.getValues(ca.Role_with_Allergan_GDPR_AGN__c);
        System.debug('Custom Setting Mapped Value'+assetRegMap.AGN_GDPR_AssetData__c);
        String dsname = assetRegMap.AGN_GDPR_AssetData__c;
        
        String cntry=ca.Country_AGN_GDPR__c;
        System.debug('Country'+cntry);
        System.debug('dsname'+dsname);
        string strRecordType = ca.RecordType.Name;
        
        List<Asset_Register_AGN__c> assetList = new List<Asset_Register_AGN__c>();
        if(strRecordType == 'GDPR Case')
        {
            isGDPR = true;
            isCCPA = false;
            /*assetList =[SELECT Name,Is_Active_AGN__c,Data_Subject_GDPR_AGN__c,Countries_Data_Collected_From_GDPR_AGN__c,Business_Owner_GDPR_AGN__c,Business_Owner_GDPR_AGN__r.Name FROM Asset_Register_AGN__c 
                        WHERE Data_Subject_GDPR_AGN__c INCLUDES(:dsname) AND Countries_Data_Collected_From_GDPR_AGN__c LIKE :('%' + cntry + '%') AND 
                        Is_Active_AGN__c=True and RecordType.Name != 'CCPA'];  */
            String country= '\''+'%'+cntry+'%'+'\'';
            String querylist='SELECT Name,Is_Active_AGN__c,Data_Subject_GDPR_AGN__c,Countries_Data_Collected_From_GDPR_AGN__c,Business_Owner_GDPR_AGN__c,Business_Owner_GDPR_AGN__r.Name FROM Asset_Register_AGN__c WHERE Data_Subject_GDPR_AGN__c INCLUDES('+dsname+') AND Countries_Data_Collected_From_GDPR_AGN__c LIKE '+country+' AND Is_Active_AGN__c=True order by name asc';
            System.debug('AssetGDPR'+querylist);
            assetList=Database.query(querylist);
        }
        else if(strRecordType == 'CCPA Case' || strRecordType == 'Contact Center')
        {
            isGDPR = false;
            isCCPA = true;
            /* Added below implimentation by Preeti Achary on 14Nov'201()
- Effective Date of Application Status.  DSRm task assignment:
- Only assets less than or equal to current date should be included
- Only Active Assets should be included*/
           
            Id CCPARecTypeId = AGN_GDPR_Utility.getRecTypeIdByDevName(AGN_GDPR_ConstantUtility.ASSET_REG_OBJECT_API,AGN_GDPR_ConstantUtility.CCPA_AGN);
           
            /*assetList =[SELECT Name,Is_Active_AGN__c,Data_Subject_GDPR_AGN__c,Geography_Region_AGN__c,Asset_Status_AGN__c,Business_Owner_GDPR_AGN__c,Business_Owner_GDPR_AGN__r.Name, 
                        AGN_Assign_Primary_Owner_in_queue__c, Top_Level_Business_Unit_GDPR_AGN__c,Approved_Data_Record_Count_AGN__c FROM Asset_Register_AGN__c 
                        WHERE RecordTypeId =:CCPARecTypeId AND IsApproved_AGN__c=True AND Data_Subject_GDPR_AGN__c INCLUDES (:dsname) AND Geography_Region_AGN__c !='International' AND Approved_Data_Record_Count_AGN__c > 0 ]; */
           
             String region='International';    
             String active = 'Active';
         // Modified by Kunal to include only active asset in task assignment for CCPA
             String querystring='SELECT Name,Is_Active_AGN__c,Data_Subject_GDPR_AGN__c,Geography_Region_AGN__c,Asset_Status_AGN__c,Business_Owner_GDPR_AGN__c,Business_Owner_GDPR_AGN__r.Name,AGN_Assign_Primary_Owner_in_queue__c, Top_Level_Business_Unit_GDPR_AGN__c,Approved_Data_Record_Count_AGN__c FROM Asset_Register_AGN__c WHERE RecordTypeId =:CCPARecTypeId AND Is_Active_AGN__c=True AND Data_Subject_GDPR_AGN__c INCLUDES ('+dsname+') AND geography_Region_AGN__c !=:region AND Approved_Data_Record_Count_AGN__c > 0 order by name asc'; 
             System.debug('AssetCCPA'+querystring);
             assetList=Database.query(querystring);
        }
        
        System.debug('Asset DATA '+assetList);
        return assetList;
    }
    
    
    @AuraEnabled
    public static boolean createtask(List<Id> lstRecordId,String caserecordId) 
    {
        Case ca = new Case();
        ca = [SELECT Id,CaseNumber,ContactId,Role_with_Allergan_GDPR_AGN__c,Full_Address_GDPR_AGN__c,SuppliedCompany,SuppliedEmail,
              SuppliedName,SuppliedPhone,Affiliation_GDPR_AGN__c,Comments_GDPR_AGN__c,
              Date_of_Form_Submission_GDPR_AGN__c,Request_Type_GDPR_AGN_new__c,Subject,
              Submitting_for_Another_Person_GDPR_AGN__c,Person_E_Mail_Address_GDPR_AGN__c,
              Person_First_Name_GDPR_AGN__c,Person_Last_Name_GDPR_AGN__c,
              Person_Requester_Relationship_GDPR_AGN__c,CreatedDate,
              ClosedDate,Description,Country_AGN_GDPR__c,E_Mail_Address_GDPR_AGN__c,
              Affiliation_Bus_Clinic_Name_GDPR_AGN__c,Phone_GDPR_AGN__c,
              Street_Address_GDPR_AGN__c,Town_City_GDPR_AGN__c,
              State_GDPR_AGN__c,Case_Creation_Channel_GDPR_AGN__c,Data_Subject_Email_GDPR_AGN__c,
              Data_Subject_Phone_GDPR_AGN__c,Provide_Consent_GDPR_AGN__c,Withdraw_Consent_GDPR_AGN__c,
              Postal_Country_AGN_GDPR__c,Post_State_GDPR_AGN__c,States_CCPA_AGN__c,
              Post_Street_Address_GDPR_AGN__c,Post_Town_City_GDPR_AGN__c,Full_Name_GDPR_AGN__c,OwnerId,Owner.name,Personal_Data_GDPR_AGN__c,
              Justification_for_Others_Role_GDPR_AGN__c,Post_Zip_GDPR_AGN__c,Zip_AGN_GDPR__c,
              OptINOthers_AGN_GDPR__c,OptOUTOthers_AGN_GDPR__c,Priority, RecordType.Name,Rectification_changes_GDPR_AGN__c
              FROM Case WHERE Id = :caserecordId];
        
        Map<Id,Asset_Register_AGN__c> TaskMAp = new  Map<Id,Asset_Register_AGN__c>();  
        
        List<Asset_Register_AGN__c> ast = new List<Asset_Register_AGN__c>();
        Asset_Register_AGN__c asset = new Asset_Register_AGN__c();
        
        ast= [SELECT Name,Business_Owner_GDPR_AGN__c, Leave_From_GDPR_AGN__c, Leave_Till_GDPR_AGN__c, 
              Delegate_to_GDPR_AGN__c, AGN_Assign_Primary_Owner_in_queue__c, Top_Level_Business_Unit_GDPR_AGN__c,Owner.Id 
              FROM Asset_Register_AGN__c WHERE Id IN :lstRecordId];
        
        for(Asset_Register_AGN__c a : ast)
        { 
            TaskMAp.put(a.Id,a);
        }
        System.debug('TaskMAp '+TaskMAp);
        
        
        List<Business_Owner_Task_GDPR_AGN__c> tskList = new List<Business_Owner_Task_GDPR_AGN__c>();
        
        Integer TaskCount = [SELECT count() FROM Business_Owner_Task_GDPR_AGN__c WHERE Related_to_GDPR_AGN__c = :caserecordId];
        System.debug('ExistingTaskCount '+TaskCount);
        TaskCount = TaskCount+1;
        
        //Get List of all Queue name from Custom Setting
        List<AGN_CCPA_Primary_Owner_Assignment__c> lstPriownerAss = AGN_CCPA_Primary_Owner_Assignment__c.getall().values();
        map<string, string> mapPriownerAss = new map<string, string>();
        for(AGN_CCPA_Primary_Owner_Assignment__c obj : lstPriownerAss)
        {
            mapPriownerAss.put(obj.AGN_Business_Unit__c, obj.AGN_Primary_Owner_Queue__c);
        }
        
        List<Group> lstGrp = [SELECT DeveloperName,Name,Type FROM Group WHERE Type = 'Queue'];
        map<string, Id> mapQueue = new map<string, Id>();
        for(Group objGrp : lstGrp)
        {
            mapQueue.put(objGrp.Name, objGrp.Id);
        }
        //End
        
        List<Business_Owner_Task_GDPR_AGN__c> ExistingTaskList = [SELECT Asset_GDPR_AGN__c,Id,Related_to_GDPR_AGN__c FROM Business_Owner_Task_GDPR_AGN__c WHERE Related_to_GDPR_AGN__c = :caserecordId and Asset_GDPR_AGN__c IN :TaskMAp.keySet()];
        
        List<ID> lstId = new List<ID>();
        for(Business_Owner_Task_GDPR_AGN__c bst : ExistingTaskList)
        {
            lstId.add(bst.Asset_GDPR_AGN__c);
        }
        
     //Bug fix to Prevent Governor limits. Moved the bunch of code from line 211-220 to below to solve the issue.
     String casetype;
        Id rt;
     if(ca.recordtype.name=='CCPA Case' || ca.recordtype.name=='Contact Center')
                {
                    casetype='CCPA';
                     rt=[SELECT Id FROM RecordType WHERE DeveloperName = 'CCPA_Task'].Id;
                }
               if(ca.recordtype.name=='GDPR Case' || ca.recordtype.name=='GDPR DPO')
                {
                    casetype='GDPR';
                    rt=[SELECT Id FROM RecordType WHERE DeveloperName = 'GDPR_Task'].Id;
               }
        
        //End
               
        for(Id key : TaskMAp.KeySet())
        {  
            if(lstId.contains(key))
            {
                System.debug('Copy Available');
            }
            else
            {
                //Business_Owner_Task_GDPR_AGN__Share boShare = new Business_Owner_Task_GDPR_AGN__Share();
                Business_Owner_Task_GDPR_AGN__c tsk= new Business_Owner_Task_GDPR_AGN__c();   
                tsk.Name='Case '+ca.CaseNumber+'/'+ TaskCount;
                tsk.Related_to_GDPR_AGN__c = caserecordId;
                // tsk.Assigned_To_GDPR_AGN__c='User Lookup';
                tsk.Status_GDPR_AGN__c = 'Not Started';
                //tsk.CurrencyIsoCode='';
                tsk.Full_Address_GDPR_AGN__c=ca.Full_Address_GDPR_AGN__c;
                tsk.Data_Subject_Name_GDPR_AGN__c=ca.Full_Name_GDPR_AGN__c;
                tsk.Data_Subject_Phone_GDPR_AGN__c=ca.SuppliedPhone;
                // tsk.Affiliation_GDPR_AGN__c=ca.Affiliation_GDPR_AGN__c;
                tsk.Business_Owner_Comment_AGN_GDPR_Case__c=ca.Description;
                tsk.Personal_Data_GDPR_AGN__c=ca.Personal_Data_GDPR_AGN__c;
                tsk.Justification_for_Others_Role_GDPR_AGN__c=ca.Justification_for_Others_Role_GDPR_AGN__c;
                tsk.Post_Zip_GDPR_AGN__c=ca.Post_Zip_GDPR_AGN__c;
                tsk.Zip_AGN_GDPR__c=ca.Zip_AGN_GDPR__c;
                tsk.OptINOthers_AGN_GDPR__c=ca.OptINOthers_AGN_GDPR__c;
                tsk.OptOUTOthers_AGN_GDPR__c=ca.OptOUTOthers_AGN_GDPR__c;
                tsk.BO_Priority_GDPR_AGN__c=ca.Priority;
                //tsk.Case_Type_GDPR_AGN__c=ca.Owner.Name;
              /*  if(ca.recordtype.name=='CCPA Case' || ca.recordtype.name=='Contact Center')
                {
                    tsk.Case_Type_GDPR_AGN__c='CCPA';
                     tsk.recordtypeid=[SELECT Id FROM RecordType WHERE DeveloperName = 'CCPA_Task'].Id;
                }
               if(ca.recordtype.name=='GDPR Case' || ca.recordtype.name=='GDPR DPO')
                {
                    tsk.Case_Type_GDPR_AGN__c='GDPR';
                    tsk.recordtypeid=[SELECT Id FROM RecordType WHERE DeveloperName = 'GDPR_Task'].Id;
               }*/
               
                //rt and casetype new variables have been added.
                tsk.recordtypeid=rt;
                tsk.Case_Type_GDPR_AGN__c=casetype;
                
                tsk.Provide_additional_Information_GDPR_AGN__c='';
                tsk.Request_Type_GDPR_AGN__c=ca.Request_Type_GDPR_AGN_new__c;
                tsk.Rectification_changes_GDPR_AGN__c=ca.Rectification_changes_GDPR_AGN__c;
                tsk.Role_with_Allergan_GDPR_AGN__c=ca.Role_with_Allergan_GDPR_AGN__c;
                tsk.Task_Subject_GDPR_AGN__c = ca.Subject;
                tsk.Submitting_for_Another_Person_GDPR_AGN__c=ca.Submitting_for_Another_Person_GDPR_AGN__c;
                tsk.Requester_E_Mail_Address_GDPR_AGN__c=ca.Person_E_Mail_Address_GDPR_AGN__c;
                tsk.Requester_First_Name_GDPR_AGN__c=ca.Person_First_Name_GDPR_AGN__c;
                tsk.Requester_Last_Name_GDPR_AGN__c=ca.Person_Last_Name_GDPR_AGN__c;
                tsk.Requester_Relationship_GDPR_AGN__c=ca.Person_Requester_Relationship_GDPR_AGN__c;
                tsk.Affiliation_GDPR_AGN__c=ca.Affiliation_Bus_Clinic_Name_GDPR_AGN__c;
                tsk.Address_Line_1_Country_GDPR_AGN__c=ca.Country_AGN_GDPR__c;
                tsk.Address_Line_1_E_Mail_Address_GDPR_AGN__c=ca.E_Mail_Address_GDPR_AGN__c;
                tsk.Address_Line_1_Phone_GDPR_AGN__c=ca.Phone_GDPR_AGN__c;
                tsk.Address_Line_1_Street_Address_GDPR_AGN__c=ca.Street_Address_GDPR_AGN__c;
                tsk.Address_Line_1_Town_City_GDPR_AGN__c=ca.Town_City_GDPR_AGN__c;
                tsk.Address_Line_1_State_GDPR_AGN__c=ca.State_GDPR_AGN__c;
                tsk.BO_Case_Creation_Channel_GDPR_AGN__c=ca.Case_Creation_Channel_GDPR_AGN__c;
                tsk.BO_Data_Subject_Email_GDPR_AGN__c=ca.Data_Subject_Email_GDPR_AGN__c;
                tsk.BO_Provide_Consent_GDPR_AGN__c=ca.Provide_Consent_GDPR_AGN__c;
                tsk.DO_Withdraw_Consent_GDPR_AGN__c=ca.Withdraw_Consent_GDPR_AGN__c;
                tsk.Postal_Street_Address_GDPR_AGN__c=ca.Post_Street_Address_GDPR_AGN__c;
                tsk.Postal_Country_GDPR_AGN__c=ca.Postal_Country_AGN_GDPR__c;
                if(ca.RecordType.Name == 'GDPR Case')
                    tsk.Postal_State_GDPR_AGN__c=ca.Post_State_GDPR_AGN__c;
                if(ca.RecordType.Name == 'CCPA Case' || ca.RecordType.Name == 'Contact Center')
                    tsk.Postal_State_GDPR_AGN__c=ca.States_CCPA_AGN__c;
                tsk.Postal_Town_City_GDPR_AGN__c=ca.Post_Town_City_GDPR_AGN__c;
                tsk.Address_Line_1_Phone_GDPR_AGN__c=ca.Data_Subject_Phone_GDPR_AGN__c;
                 
                
                
                //Added by Rajeev - 11 NOV 2019
                tsk.AGN_AcknowledgeMessage__c = System.Label.CCPA_Acknowledge_Message_AGN;
                
                
                if(TaskMAp.containsKey(key))
                {
                    
                    Asset_Register_AGN__c assetreg = TaskMAp.get(key);
                    tsk.Asset_GDPR_AGN__c=  assetreg.Id;
                    
                    if(ca.RecordType.Name == 'GDPR Case')
                    {
                        if(date.today() >= assetreg.Leave_From_GDPR_AGN__c && date.today() <= assetreg.Leave_Till_GDPR_AGN__c)
                        {
                            tsk.Assigned_To_GDPR_AGN__c = assetreg.Delegate_to_GDPR_AGN__c;
                            tsk.OwnerId = assetreg.Delegate_to_GDPR_AGN__c;
                            tsk.Is_Delegated_GDPR_AGN__c=TRUE;
                        }
                        /*else
                        {
                            tsk.Assigned_To_GDPR_AGN__c = assetreg.Business_Owner_GDPR_AGN__c;
                            tsk.OwnerId = assetreg.Business_Owner_GDPR_AGN__c;
                        }*/
                        else
                        {
                            tsk.Assigned_To_GDPR_AGN__c = assetreg.OwnerId;
                            tsk.OwnerId = assetreg.OwnerId;
                        }
                    }
                    else if(ca.RecordType.Name == 'CCPA Case' || ca.RecordType.Name == 'Contact Center')
                    {
                        if(assetreg.AGN_Assign_Primary_Owner_in_queue__c) // If Owner is Queue
                        {
                            tsk.OwnerId = mapQueue.get(mapPriownerAss.get(assetreg.Top_Level_Business_Unit_GDPR_AGN__c));
                        }
                        else
                        {
                            tsk.OwnerId = assetreg.Business_Owner_GDPR_AGN__c;   
                        }
                    }
                } 
                
                tskList.add(tsk);
                TaskCount++;
            }
            
        }
        
        
        System.debug('Before Insert'+tskList);
        System.debug('Before Insert Size'+ tskList.size());
        
        try 
        {
            
            
            if(tskList.size()>0)
            {
                insert tskList;
                Case c = new Case();
                c.Id = caserecordId;
                c.Status='In-Progress';
                
                System.debug('Update : '+c);
                update c;          
            } 
            return true;
        }
        catch(DmlException e)
        {   
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            return false;
        }
           
    }
   
}