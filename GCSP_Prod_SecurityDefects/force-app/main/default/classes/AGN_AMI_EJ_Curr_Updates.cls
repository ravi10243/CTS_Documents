global class AGN_AMI_EJ_Curr_Updates implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        string query = 'Select id, Module__r.Module_AGN__c, HCP_AGN__c, Module_Percent_AGN__c ' 
            + 'from AMI_Learning_Path_AGN__c '
            + 'where lastModifieddate = Yesterday';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> batch)
    {
        AGN_AMI_Veeva_Utility_Class.ejCompletionSync((List<AMI_Learning_Path_AGN__c>) batch);
    }
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}