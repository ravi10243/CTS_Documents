global class AGN_AMI_Attendee_Insert_Batch implements Database.Batchable<String>
{
    global List<String> accIdList;
    global Id eventId;
    global AGN_AMI_Attendee_Insert_Batch(List<String> accIdList, Id eventId)
    {
        this.accIdList = accIdList;
        this.eventId = eventId;
    }
    global Iterable<String> start(Database.BatchableContext BC) 
    {
        return accIdList;
    }
    global void execute(Database.BatchableContext BC, List<String> batch)
    {
        addAllAddendeesbatch(batch);
    }
    global void finish(Database.BatchableContext BC) 
    {
        // Access initialState here 
    }
    global void addAllAddendeesbatch(List<String> batch)
    {
        Id recordtypeid = Schema.SObjectType.Event_Attendee_Vod__c.getRecordTypeInfosByDeveloperName().get('Portal_Attendee_AGN').getRecordTypeId();
        list<Event_Attendee_Vod__c> insertAttendeelist = new list<Event_Attendee_Vod__c>();
        for(Id accId : batch){
            Event_Attendee_Vod__c myeventattendee = new Event_Attendee_Vod__c();
            myeventattendee.Medical_Event_vod__c = eventId;
            myeventattendee.recordTypeId = recordtypeid;
            myeventattendee.Account_vod__c = accId;
            insertAttendeelist.add(myeventattendee);
        }
        try
        {
            insert insertAttendeelist;
        }
        catch(Exception ex)
        {
            
        }
    }
}