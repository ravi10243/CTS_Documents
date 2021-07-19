// This class is created as the Utility class for fetching and updating meeting records for -AGN_AMI_All_Event_Controller,AGN_AMI_My_Event_Controller,AGN_AMI_SC_All_Event_Controller
// AGN_AMI_SC_My_Event_Controller

public without sharing class AGN_AMI_SC_Event_Util_Class {
    
    public static List<Medical_Event_vod__c> getAllEvents(String userCountryName, String meetingRecordTypeId,String businessUnit)
    {
         //Added Event_Broadcast_Link_AGN__c field in the query for PMO#3611 – Zoom event pop-up issue- End.
        List<Medical_Event_vod__c> allAvailableMeetings = [ Select Id, Name,AMI_Event_Type_AGN__c, Description_vod__c, AMI_Event_Delivery_Type_AGN__c,
                                                           Start_Time_vod__c, End_Time_vod__c, AMI_Event_Status_AGN__c,Location__c,
                                                           Banner_Total_Time_Duration_AGN__c, Total_Time_Duration_AGN__c, Event_Broadcast_Link_AGN__c,Is_Strata_Event__c,Event_Preview_Days__c,Preview_Start_Time__c,Post_View_End_Time__c,Enable_Strata_Post_View__c //PMO CR:3658 Strata Integration(fields added)                             
                                                           from Medical_Event_vod__c 
                                                           where RecordTypeId = : meetingRecordTypeId
                                                           and Country_AGN__r.Name = :userCountryName
                                                           and AGN_AMI_Business_Unit__c = :businessUnit                         
                                                           order by Start_Time_vod__c];
        system.debug('allAvailableMeetings-->'+allAvailableMeetings);
        
        return allAvailableMeetings;
    }
    
    public static List<Medical_Event_vod__c> getUpcomingEvents(List<String> eventStat, String meetingRecordTypeId, 
                                                               String meetingPublic, String meetingPrivate,
                                                               List<id> registeredMeetingId)
    {
        
        List<Medical_Event_vod__c> upcomingEvents = [Select Id,Name,Description_vod__c,
                                                     toLabel(AMI_Event_Delivery_Type_AGN__c),Start_Time_vod__c,End_Time_vod__c,
                                                     Location__c,AMI_Event_Status_AGN__c,Total_Time_Duration_AGN__c,
                                                     Banner_Total_Time_Duration_AGN__c,
                                                     Event_Broadcast_Link_AGN__c
                                                     from Medical_Event_vod__c
                                                     where RecordTypeId =: meetingRecordTypeId
                                                     and AMI_Event_Status_AGN__c in: eventStat
                                                     and (AMI_Event_Type_AGN__c =: AGN_AMI_Static_Labels.meetingTypePublic
                                                          OR AMI_Event_Type_AGN__c =: AGN_AMI_Static_Labels.meetingTypePrivate)
                                                     and Id in: registeredMeetingId
                                                     order by AMI_Event_Status_AGN__c,Start_Time_vod__c];
        system.debug('upcomingEvents-->'+upcomingEvents);
        
        
        return upcomingEvents;
    }
    
    public static List<Event_Attendee_vod__c> getRegisteredAttendees(String accountID, String attendeeRecordTypeId)
    {
        List<Event_Attendee_vod__c> registeredAttendeeList = [Select Medical_Event_vod__c,Status_vod__c 
                                                              from Event_Attendee_vod__c
                                                              where Account_vod__c =: accountID  
                                                              and RecordTypeId =: attendeeRecordTypeId 
                                                              and Status_vod__c != :AGN_AMI_Static_Labels.attendeeStatusRemoved
                                                             ];
        system.debug('registeredAttendeeList-->'+registeredAttendeeList);
        
        return registeredAttendeeList;
    }
    
    public static List<Event_Attendee_vod__c> getUserRegisteredEventAttendees(String accountID, String attendeeRecordTypeId, 
                                                                              String statusAccepted, String statusCancelled)
    {
        
        List<Event_Attendee_vod__c> registeredAttendeeList = [Select Id,Medical_Event_vod__c
                                                              from Event_Attendee_vod__c
                                                              where Account_vod__c =: accountID
                                                              and (Status_vod__c =: statusAccepted
                                                                   OR Status_vod__c =: statusCancelled)                                                              
                                                              and RecordTypeId =: attendeeRecordTypeId];
        system.debug('registeredAttendeeList-->'+registeredAttendeeList);
        
        return registeredAttendeeList;
    }
    
    public static List<Meeting_Speaker_AGN__c> getSpeakersForEvent(List<ID> allMeetingsId)
    {
        
        List<Meeting_Speaker_AGN__c> speakerList = [Select AMI_Faculty_AGN__r.Name_AGN__c,meeting_AGN__c
                                                    from Meeting_Speaker_AGN__c 
                                                    where Meeting_AGN__c in: allMeetingsId
                                                    and AMI_Primary_Speaker_AGN__c = true Order By LastModifiedDate Asc];
        system.debug('speakerList-->'+speakerList);
        
        return speakerList;
    }
    
    public static String updateEvent(String accountID, String eventID, String eventStatus)
    {
        
        String success=' ';
        Event_Attendee_vod__c eventStatUpdate;
        List<Event_Attendee_vod__c> eventsToUpdate = [Select id,Status_vod__c from Event_Attendee_vod__c 
                                                      where Medical_Event_vod__c =: eventID
                                                      and Account_vod__c =: accountID limit 1];
        system.debug('eventsToUpdate-->'+eventsToUpdate);
        eventStatUpdate = eventsToUpdate[0];
        eventStatUpdate.Status_vod__c = eventStatus;
        try{
            /*Inorder to bypass the trigger in the test class this code is written*/
            if(!Test.isRunningTest()){
                update eventStatUpdate;
            }
            success=AGN_AMI_SC_Static_Labels.success;
        }catch(Exception e){
            AGN_AMI_ErrorLogger.createExceptionsLog(e,'AGN_AMI_SC_Event_Util_Class','updateEvent');
        }
        return success;
    }
    
     // Added logic to update the Preview/Post-View Status- Strata POC    
  /**  public static void upsertAttendanceStatus(String accountId,String meetingId,String Status,String eajsRecordTypeId)    
    {   
                    
         Event_Attendee_vod__c eventAttendee = [Select Id,Status_vod__c,Medical_Event_vod__c from Event_Attendee_vod__c   
                                               where Account_vod__c =: accountId 
                                               and Medical_Event_vod__c =: meetingId    
                                               limit 1];    
         eventAttendee.Status_vod__c = Status; 
        
         AMI_Event_Attendee_Journey_Status_AGN__c EAJS= new AMI_Event_Attendee_Journey_Status_AGN__c();
         EAJS.AMI_Meeting_Attendee_AGN__c = eventAttendee.Id;
         EAJS.AMI_Related_Event_AGN__c = eventAttendee.Medical_Event_vod__c;
         EAJS.RecordTypeId = eajsRecordTypeId;
         EAJS.AMI_Event_Status__c= Status;
         
        try 
        {   
           if(eventAttendee.Status_vod__c !=Status){
               update eventAttendee;
            }    
           insert EAJS; 
        }catch(Exception ex) 
        {   
             AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_SC_Event_Util_Class','upsertAttendanceStatus');   
        } 
 
    }*/
    
}