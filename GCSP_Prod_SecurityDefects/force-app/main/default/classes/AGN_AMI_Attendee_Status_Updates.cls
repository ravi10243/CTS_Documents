global class AGN_AMI_Attendee_Status_Updates implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        string query = 'Select id,AMI_Account_Id_AGN__c,  AMI_Related_Event_AGN__c ' + 
            'from AMI_Event_Attendee_Journey_Status_AGN__c where CreatedDate = LAST_90_DAYS';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> batch)
    {
        AGN_AMI_Veeva_Utility_Class.updateEventStatus();
        AGN_AMI_Veeva_Utility_Class.updateSuggestionStatus();
        AGN_AMI_Veeva_Utility_Class.updateModuleStatus();
        AGN_AMI_Veeva_Utility_Class.updateSurveyStatus();
        AGN_AMI_Veeva_Utility_Class.viewAttendeeUpdate();
        AGN_AMI_Veeva_Utility_Class.updateAttendeeRecords();
    }
    global void finish(Database.BatchableContext BC) 
    {
        
    }
}