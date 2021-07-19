// This class is created as the Controller class of the Visualforce Page - AGN_SC_My_Events_Page
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant

public without sharing class AGN_AMI_SC_My_Event_Controller {
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
    public AGN_AMI_SC_Meeting_Details_Wrapper firstMeeting {get; set;}
    public List<AGN_AMI_SC_Meeting_Details_Wrapper> upcomingMeetings {get; set;}
    public List<Medical_Event_vod__c>   upcomingEvents {get;set;}
    public List<Event_Attendee_vod__c>  registeredList {get;set;}
    public List<Meeting_Speaker_AGN__c> speakerList    {get;set;}
    
    
    // Constructor is used to fetch all the events visible to the User, along with additional data required to display along with the Events
    public AGN_AMI_SC_My_Event_Controller()
    {
        upcomingEvents = New List<Medical_Event_vod__c>();
        upcomingMeetings = New List<AGN_AMI_SC_Meeting_Details_Wrapper>();
        
        AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;       
        accountRecord = userDetails.accountRecord;        
        String meetingRecordTypeId  = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AMI_SC_Meeting_Record_Type_AGN).getRecordTypeId();
        String attendeeRecordTypeId  = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_SC_Attendee_Record_Type_AGN).getRecordTypeId();
        
        
        registeredList = AGN_AMI_SC_Event_Util_Class.getUserRegisteredEventAttendees(accountRecord.Id,attendeeRecordTypeId,
                                                                                     AGN_AMI_SC_Static_Labels.attendeeStatusAccepted,
                                                                                     AGN_AMI_SC_Static_Labels.attendeeStatusAttended);
        
        
        List<id> registeredMeetingId = new List<id>();
        for(Event_Attendee_vod__c EventAdd: registeredList)
        {
            registeredMeetingId.add(EventAdd.Medical_Event_vod__c);
        }
        List<String> eventStat = new List<String>();
        eventStat.add(AGN_AMI_SC_Static_Labels.meetingStatusLive);
        eventStat.add(AGN_AMI_SC_Static_Labels.meetingStatusRecorded);
        system.debug('registeredMeetingId-->'+registeredMeetingId);
        
        speakerList = AGN_AMI_SC_Event_Util_Class.getSpeakersForEvent(registeredMeetingId);
        system.debug('speakerList-->'+speakerList);
        upcomingEvents = AGN_AMI_SC_Event_Util_Class.getUpcomingEvents(eventStat, meetingRecordTypeId, 
                                                                       AGN_AMI_SC_Static_Labels.meetingTypePublic,
                                                                       AGN_AMI_SC_Static_Labels.meetingTypePrivate,
                                                                       registeredMeetingId);
        system.debug('upcomingEvents-->'+upcomingEvents);
        
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
            upcomingMeetings.add(new AGN_AMI_SC_Meeting_Details_Wrapper(up,true,facultyName));
        }
        if(! upcomingMeetings.isEmpty())
            firstMeeting = upcomingMeetings[0];
        system.debug('upcomingMeetings-->'+upcomingMeetings);
    }
    
    // Method redirects to the Event Detail Page. 
    // It is a dynamic function which redirects to Event Detail Page 
    // of the Particular Event with proper requests like - view, play and register.
    public PageReference redirectToEvent()
    {
        PageReference pr = new PageReference(Label.AGN_AMI_SC_Event_Detail_Page);
        pr.setRedirect(true);
        pr.getParameters().put('eventId',clickedEvent);
        pr.getParameters().put('request',clickedAction);
        return pr;
    }  
    
    //Method to deregister an event and refresh the list subsequently
    public PageReference updateEvent()
    {	
        
        system.debug('clickedEvent@@@@' + clickedEvent);
        String retStat=AGN_AMI_SC_Event_Util_Class.updateEvent(accountRecord.Id, clickedEvent,AGN_AMI_SC_Static_Labels.attendeeStatusCancelled) ;
        system.debug('success@@@@'+ retStat);
        if(retStat=='success')
        {
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
        return null;
    }
}