// This class is created as the Controller class of the Visualforce Page - AGN_SC_All_Events_Page
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant

public class AGN_AMI_SC_All_Event_Controller {
    User user; 
    Account accountRecord;
    public String userCountryName {get;set;}
    public String userLanguage {get; set;}
    
    public integer upcomingCount {get; set;}
    public integer pastCount {get; set;}
    public List<AGN_AMI_SC_Meeting_Details_Wrapper> upcomingMeetings {get; set;}
    public List<AGN_AMI_SC_Meeting_Details_Wrapper> pastMeetings {get; set;}
    public List<AGN_AMI_SC_Meeting_Details_Wrapper> fullMeetings {get; set;}
    public AGN_AMI_SC_Meeting_Details_Wrapper firstMeeting {get; set;}
    List<Medical_Event_vod__c> allAvailableMeetings;
    List<Id> allMeetingsId;
    public String clickedEvent {get; set;}
    public String clickedAction {get; set;}
    public String searchString {get; set;}
    public String searchPast {get; set;}
    public String searchStart {get; set;}
    public String searchEnd {get; set;}
    
    // Constructor is used to fetch all the events visible to the User, along with additional data required to display along with the Events
    public AGN_AMI_SC_All_Event_Controller()
    {      
        AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();
        
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;       
        accountRecord = userDetails.accountRecord;
        String meetingRecordTypeId  = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AMI_SC_Meeting_Record_Type_AGN).getRecordTypeId();
        String attendeeRecordTypeId  = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_SC_Attendee_Record_Type_AGN).getRecordTypeId();
        
        fullMeetings = new List<AGN_AMI_SC_Meeting_Details_Wrapper>();
        upcomingMeetings = new List<AGN_AMI_SC_Meeting_Details_Wrapper>();
        pastMeetings = new List<AGN_AMI_SC_Meeting_Details_Wrapper>();
        allMeetingsId = new List<Id>();
        
        
        allAvailableMeetings = AGN_AMI_SC_Event_Util_Class.getAllEvents(userCountryName, meetingRecordTypeId,AGN_AMI_SC_Static_Labels.specialityCare);
        system.debug('allAvailableMeetings-->>'+allAvailableMeetings);
        List<Event_Attendee_vod__c> registrationList = AGN_AMI_SC_Event_Util_Class.getRegisteredAttendees(accountRecord.Id, attendeeRecordTypeId);
        system.debug('registrationList-->'+registrationList);
        List<Id> invitedMeetingId = new List<Id>();
        for(Event_Attendee_vod__c ea : registrationList)
        {
            invitedMeetingId.add(ea.Medical_Event_vod__c); 
        }
        for(Medical_Event_vod__c me : allAvailableMeetings)
        {
            allMeetingsId.add(me.Id);
        }
        
        List<Meeting_Speaker_AGN__c> speakerList = AGN_AMI_SC_Event_Util_Class.getSpeakersForEvent(allMeetingsId);
        
        for(Medical_Event_vod__c meeting : allAvailableMeetings)
        {
            boolean invitationFlag = false;
            for(Id meetId : invitedMeetingId)
            {
                if(meetId == meeting.Id)
                    invitationFlag = true;
            }
            if(meeting.AMI_Event_Type_AGN__c == AGN_AMI_SC_Static_Labels.meetingTypePublic || (invitedMeetingId.contains(meeting.Id)) || invitationFlag)
            {
                integer flag = 0;
                for(Event_Attendee_vod__c attendee : registrationList)
                {
                    if(meeting.Id == attendee.Medical_Event_vod__c && attendee.Status_vod__c != AGN_AMI_SC_Static_Labels.attendeeStatusInvited 
                       && attendee.Status_vod__c != AGN_AMI_SC_Static_Labels.attendeeStatusCancelled)
                    {
                        flag = 1;           
                    }
                }
                String facultyName = '';
                for(Meeting_Speaker_AGN__c ms : speakerList)
                {
                    if(ms.meeting_AGN__c == meeting.Id)
                    {
                        facultyName = ms.AMI_Faculty_AGN__r.Name_AGN__c;
                        system.debug('facultyName-->'+facultyName);
                    }                
                }
                if(flag == 0 && meeting.AMI_Event_Status_AGN__c == 'Live')
                {
                    upcomingMeetings.add(new AGN_AMI_SC_Meeting_Details_Wrapper(meeting,false,facultyName));
                }
                else if(flag == 0 && meeting.AMI_Event_Status_AGN__c == 'Recorded')
                {
                    pastMeetings.add(new AGN_AMI_SC_Meeting_Details_Wrapper(meeting,false,facultyName));
                }
                else if(flag == 1 && meeting.AMI_Event_Status_AGN__c == 'Live')
                {
                    upcomingMeetings.add(new AGN_AMI_SC_Meeting_Details_Wrapper(meeting,true,facultyName));
                }
                else if(flag == 1 && meeting.AMI_Event_Status_AGN__c == 'Recorded')
                {
                    pastMeetings.add(new AGN_AMI_SC_Meeting_Details_Wrapper(meeting,true,facultyName));
                }
            }
        }
        system.debug('upcomingCount-->'+upcomingCount);
        system.debug('pastMeetings-->'+pastMeetings);
        system.debug('upcomingMeetings-->'+upcomingMeetings);
        upcomingCount = upcomingMeetings.size();
        pastCount = pastMeetings.size();
        if(upcomingCount>0)
            
            firstMeeting = upcomingMeetings[0];
        
        fullMeetings.addAll(upcomingMeetings);
        fullMeetings.addAll(pastMeetings);
        
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
    
    // Method filters out the available events in accordance with the conditions selected in the page. 
    public PageReference searchEvents()
    {
        upcomingMeetings.clear();
        pastMeetings.clear();
        Datetime startDate = datetime.now().addYears(-1);
        Datetime endDate = datetime.now().addYears(1);
        if(!String.isBlank(searchStart))
        {
            List<String> startList = searchStart.split('/');
            startDate = datetime.newInstance(Integer.valueOf(startList[2]),Integer.valueOf(startList[1]),Integer.valueOf(startList[0]));
        }
        if(!String.isBlank(searchEnd))
        {
            List<String> endList = searchEnd.split('/');
            endDate = datetime.newInstance(Integer.valueOf(endList[2]),Integer.valueOf(endList[1]),Integer.valueOf(endList[0]));
        }
        
        for(AGN_AMI_SC_Meeting_Details_Wrapper mdw : fullMeetings)
            
        {
            
            
            if(!String.isBlank(searchString) && mdw.meeting.Name.containsIgnoreCase(searchString) && mdw.meeting.Start_Time_vod__c > startDate && mdw.meeting.End_Time_vod__c < endDate)
            {
                system.debug('%%%%%'+mdw.meeting.AMI_Event_Status_AGN__c);
                if(!String.isBlank(searchPast) && searchPast == 'false' && mdw.meeting.AMI_Event_Status_AGN__c == 'Live')
                    upcomingMeetings.add(mdw);
                else if (!String.isBlank(searchPast) && searchPast == 'true' && mdw.meeting.AMI_Event_Status_AGN__c == 'Recorded')
                    pastMeetings.add(mdw);
            }
            else if(String.isBlank(searchString) && mdw.meeting.Start_Time_vod__c > startDate && mdw.meeting.End_Time_vod__c < endDate)
            {
                if(!String.isBlank(searchPast) && searchPast == 'false' && MDW.meeting.AMI_Event_Status_AGN__c == 'Live')
                    upcomingMeetings.add(mdw);
                else if (!String.isBlank(searchPast) && searchPast == 'true' && MDW.meeting.AMI_Event_Status_AGN__c == 'Recorded')
                    pastMeetings.add(mdw);
            }
        }
        return null;
    }  
    
    // Method deregisters the user from the particular event and refresh the available events accordingly.
    public PageReference deregister()
    {
        
        String retStat=AGN_AMI_SC_Event_Util_Class.updateEvent(accountRecord.Id, clickedEvent,AGN_AMI_SC_Static_Labels.attendeeStatusCancelled);
        
        system.debug('fullMeetings@@@@' + fullMeetings);
        for(AGN_AMI_SC_Meeting_Details_Wrapper mdw : fullMeetings)
        {
            if(mdw.meeting.Id == clickedEvent)
            {
                AGN_AMI_SC_Meeting_Details_Wrapper updatedMDW = mdw;
                updatedMDW.registered = false;
                fullMeetings[fullMeetings.indexOf(MDW)] = updatedMDW;
            }    
        }
        system.debug('upcomingMeetings@@@@' + upcomingMeetings);
        for(AGN_AMI_SC_Meeting_Details_Wrapper mdw : upcomingMeetings)
        {
            if(mdw.meeting.Id == clickedEvent)
            {
                AGN_AMI_SC_Meeting_Details_Wrapper updatedMDW = mdw;
                updatedMDW.registered = false;
                upcomingMeetings[upcomingMeetings.indexOf(mdw)] = updatedMDW;
            }    
        }
        firstMeeting = upcomingMeetings[0];
        
        return null;
    }
    
}