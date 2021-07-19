/*
*------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev Roushan
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        2.0
* @created        
* @modified      24 March 2020
* @testClass      
* ----------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 15-Nov-2019           
* Apex class added for populating User Created active date
*-------------------------------------------------------------------------------------------------------------------------+
*/
public class AGN_User_To_Case_Batch implements Database.Batchable<SObject>{
    public Database.QueryLocator start(Database.BatchableContext context) 
    {
        //Fetching list of Active Users accessing DSRM Portal
        return Database.getQueryLocator([SELECT Id,Email,Profile.Name,CreatedDate,Position_AGN__c FROM User WHERE IsActive = true  
                                         AND Profile.Name = 'AGN_DS_Community_User']);  
    }
    public void execute(Database.BatchableContext context, List<User> scope) 
    {
        Map<String,Id> userEmailToUserIdMap = new Map<String,Id>();
        Map<String,Date> userEmailToUserDateMap = new Map<String,Date>();
        List<Case> case_id = new List<Case>();
        
        // Inserting MAp of User-> Email,Id and Map of User--> Email,CreatedDate List of active Community User in the Org.
        for(User usr: scope) 
        {
            userEmailToUserIdMap.put(usr.Email,usr.id);
            userEmailToUserDateMap.put(usr.Email,usr.CreatedDate.date());                         
        }
        // List of cases where community user created but Portal User Details are absent for the Report List of Active Users.
        List<Case> cs= [Select Id,Data_Subject_Email_GDPR_AGN__c from case where Status in ('Task Completed','Closed') 
                        AND Request_Type_GDPR_AGN_new__c  in('Access','Specific pieces of personal information (Access)','Portability')
                        AND RecordType.DeveloperName in ('CCPA_Case','GDPR_Case','Contact_Center_AGN','GDPR_DPO')
                        AND ContactId!= NULL AND Portal_User_AGN__c = NULL AND Portal_User_active_date_AGN__c = NULL];
        
        for(Case caseObj: cs)
        {
            if(userEmailToUserIdMap.ContainsKey(caseObj.Data_Subject_Email_GDPR_AGN__c)) // Null Pointer Exception Check
            {
                System.debug('case id caseObj ----->'+caseObj.id);
                case c = new case();
                c.id=caseObj.Id;
                c.Portal_User_AGN__c = userEmailToUserIdMap.get(caseObj.Data_Subject_Email_GDPR_AGN__c) ; // Assigning User ID 
                if(userEmailToUserDateMap.ContainsKey(caseObj.Data_Subject_Email_GDPR_AGN__c))
                {
                    c.Portal_User_active_date_AGN__c = userEmailToUserDateMap.get(caseObj.Data_Subject_Email_GDPR_AGN__c); // Assigning User Created Date
                }
                case_id.add(c);   
            }
        } 
        try
        {
            update case_id;
        }
        catch(DmlException e)
        {
            System.debug('DML Error occured updating Case '+e);
        }
        catch(Exception e)
        {
            System.debug('Error occured updating Case '+e);
        }
    }
    
    public void finish(Database.BatchableContext context) 
    {
        
    }
    
}