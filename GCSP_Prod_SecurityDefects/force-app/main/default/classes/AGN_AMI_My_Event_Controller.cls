// This class is created as the Controller class of the Visualforce Page - AGN_AMI_My_Event
// Author - Rahul Mitra
// Created Date - 10/12/2018
// Last Modified By - Rahul Mitra

public without sharing class AGN_AMI_My_Event_Controller 
{
    user user;
	Account accountRecord;
    public String userCountryName    {get;set;}
    public String userLanguage       {get;set;}
    public String clickedEvent       {get;set;}
    public String clickedAction      {get;set;}
    public String eventStatus        {get;set;}
    public String eventID            {get;set;}
    
    public Boolean displayPopup      {get;set;}
    public Boolean regOpen           {get;set;}
    public Boolean playerOpen        {get;set;}
    
    public datetime eDate {get;set;}
    
    public Integer eventCount {get;set;}
    public AGN_AMI_Meeting_Details_Wrapper firstMeeting {get; set;}
    public List<AGN_AMI_Meeting_Details_Wrapper> upcomingMeetings {get; set;}
    public List<Medical_Event_vod__c>   upcomingEvents {get;set;}
    public List<Event_Attendee_vod__c>  registeredList {get;set;}
    public List<Meeting_Speaker_AGN__c> speakerList    {get;set;}
    
    
    // Constructor is used to fetch all the events visible to the User, along with additional data required to display along with the Events
    public AGN_AMI_My_Event_Controller()
    {
        upcomingEvents = New List<Medical_Event_vod__c>();
        upcomingMeetings = New List<AGN_AMI_Meeting_Details_Wrapper>();
        
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        accountRecord = userDetails.accountRecord;
        String meetingRecordTypeId  = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AMI_Meeting_Record_Type_AGN).getRecordTypeId();
        String attendeeRecordTypeId  = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_Attendee_Record_Type_AGN).getRecordTypeId();
        
        registeredList = [Select Id,Medical_Event_vod__c
                          from Event_Attendee_vod__c
                          where Account_vod__c =: accountRecord.Id
                          and (Status_vod__c =: AGN_AMI_Static_Labels.attendeeStatusAccepted
                               OR Status_vod__c =: AGN_AMI_Static_Labels.attendeeStatusAttended)
                          and RecordTypeId =: attendeeRecordTypeId];
        List<id> registeredMeetingId = new List<id>();
        for(Event_Attendee_vod__c EventAdd: registeredList)
        {
            registeredMeetingId.add(EventAdd.Medical_Event_vod__c);
        }
        List<String> eventStat = new List<String>();
        eventStat.add(AGN_AMI_Static_Labels.meetingStatusLive);
        eventStat.add(AGN_AMI_Static_Labels.meetingStatusRecorded);
        
        speakerList = [Select AMI_Faculty_AGN__r.Name_AGN__c,meeting_AGN__c
                       from Meeting_Speaker_AGN__c where Meeting_AGN__c in :registeredMeetingId 
                       and AMI_Primary_Speaker_AGN__c = true Order By LastModifiedDate Asc];
        
        upcomingEvents = [Select Id,Name,Description_vod__c,
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
                          order by AMI_Event_Status_AGN__c,Start_Time_vod__c
                         ];
        eventCount = upcomingEvents.size();
        if(eventCount != null && eventCount >0 )
        {
            eDate             =   upcomingEvents[0].End_Time_vod__c;
            eventStatus       =   upcomingEvents[0].AMI_Event_Status_AGN__c;
        }
        
        for(Medical_Event_vod__c up: upcomingEvents)
        {
            String facultyName = '';
            for(Meeting_Speaker_AGN__c sp:speakerList)
                if(up.id == sp.Meeting_AGN__c)
                	facultyName = sp.AMI_Faculty_AGN__r.Name_AGN__c;
            upcomingMeetings.add(new AGN_AMI_Meeting_Details_Wrapper(up,true,facultyName));
        }
        if(! upcomingMeetings.isEmpty())
        	firstMeeting = upcomingMeetings[0];
    }
    
    // Method redirects to the Event Detail Page. 
    // It is a dynamic function which redirects to Event Detail Page 
    // of the Particular Event with proper requests like - view, play and register.
    public PageReference redirectToEvent()
    {
        PageReference pr = new PageReference(Label.AGN_AMI_Event_Detail_Page);
        pr.setRedirect(true);
        pr.getParameters().put('eventId',clickedEvent);
        pr.getParameters().put('request',clickedAction);
        return pr;
    }  
    
    //Method to deregister an event and refresh the list subsequently
    public PageReference updateEvent()
    {
/* Speciality Care - Utlity Class Implementation -- Starts */
        /*
        Event_Attendee_vod__c eventStatUpdate;
        
        List<Event_Attendee_vod__c> eventUpdate = [Select id,Status_vod__c from Event_Attendee_vod__c where Medical_Event_vod__c =: clickedEvent
                                                   and Account_vod__c =: accountRecord.Id limit 1];
        if(!eventUpdate.isEmpty())
		*/
        String updStat=AGN_AMI_SC_Event_Util_Class.updateEvent(accountRecord.Id, clickedEvent,AGN_AMI_SC_Static_Labels.attendeeStatusCancelled);
        if(updStat=='success')
        {
            /*
            eventStatUpdate = eventUpdate[0];
            eventStatUpdate.Status_vod__c = AGN_AMI_Static_Labels.attendeeStatusCancelled;
            try
            {
                update eventStatUpdate;
            }
            catch(Exception e)
            {
                System.debug(e);
            } 
			*/
/* Speciality Care - Utlity Class Implementation -- Ends */
            integer index;
            boolean flag =false ;
            for(Medical_event_vod__c meeting : upcomingEvents)
            {
                if(meeting.Id == clickedEvent)
                {
                    index = upcomingEvents.indexOf(meeting);
                    flag= true;
                }    
            }
            if(flag)
            {
                upcomingEvents.remove(index);
                upcomingMeetings.remove(index);
                eventCount --;
            }
        }
        if(!upcomingMeetings.isEmpty())
        	firstMeeting = upcomingMeetings[0];
        else
            firstMeeting = null;
        system.debug(upcomingMeetings.size());
        return null;
    }
    
}