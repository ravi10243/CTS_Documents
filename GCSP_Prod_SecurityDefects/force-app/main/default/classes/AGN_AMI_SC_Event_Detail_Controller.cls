// This class is created as the Controller class of the Visualforce Page - AGN_AMI_SC_Event_Detail_Page
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant 
public without sharing class AGN_AMI_SC_Event_Detail_Controller {
    public User user {get; set;} 
    Account accountRecord;
    Contact contactRecord;
    public String userCountryName {get;set;}
    public String userLanguage {get; set;}
    Medical_Event_vod__c meetingRecord;
    public AGN_AMI_SC_Meeting_Details_Wrapper event {get; set;}
    public List<Meeting_Speaker_AGN__c> speakerList {get;set;}
    public List<AMI_Event_Agenda_AGN__c> agendaList {get; set;}
    public List<AgendaWrapper> agendaWrapperList {get; set;}
    public List<AGN_AMI_Meeting_Doc__c> agnAMIMeetingDocList {get; set;}
    public String request {get; set;}
    public boolean isLive {get; set;}
    public Meeting_Speaker_AGN__c selectedFaculty {get; set;}
    public String clickedFaculty {get; set;}
    public Event_Attendee_vod__c eventAttendee {get; set;}
    public List<Event_Attendee_vod__c> attendanceList {get; set;}
    public Boolean registered {get; set;}
    public Boolean regOpen {get; set;}
    public Boolean playerOpen {get; set;}
    Public String eventId {get; set;}
    
    // Constructor is used to fetch the details of the particular event which is based on eventId parameter in URL.
    // Addtional information of the Events are fetched from Event Attendee, Meeting Speaker, AMI Meeting Docs and AMI Event Agenda
    public AGN_AMI_SC_Event_Detail_Controller()
    {
        AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        accountRecord = userDetails.accountRecord;
        contactRecord = userDetails.contactRecord;
        
        eventId= ApexPages.currentPage().getParameters().get('eventId');
        system.debug('eventId-->'+eventId);
        meetingRecord = [Select Id, Name, Description_vod__c, toLabel(AMI_Event_Delivery_Type_AGN__c), Banner_Total_Time_Duration_AGN__c,Detail_Page_Image_AGN__c,
                         Start_Time_vod__c, End_Time_vod__c, AMI_Event_Status_AGN__c,Location__c, Detail_Page_Video_AGN__c,Building_Name_AGN__c,
                         Event_Broadcast_Link_AGN__c, Live_Event_Description_AGN__c, Past_Event_Description_AGN__c,Location_Description_AGN__c,AMI_AVT_Broadcast_Platform_AGN__c
                         from Medical_Event_vod__c 
                         where Id =: eventId Limit 1];
        
        isLive = meetingRecord.AMI_Event_Status_AGN__c == AGN_AMI_SC_Static_Labels.meetingStatusLive;
        speakerList = [Select Id,AMI_Faculty_AGN__r.id, AMI_Faculty_AGN__r.Name, 
                       AMI_Faculty_AGN__r.AMI_Specialty_AGN__r.Name_AGN__c, AMI_Faculty_AGN__r.Hospital_AGN__c,
                       AMI_Faculty_AGN__r.Image_URL_AGN__c, AMI_Faculty_AGN__r.Country_AGN__c, 
                       AMI_Faculty_AGN__r.Name_AGN__c, AMI_Faculty_AGN__r.Title_AGN__c, 
                       AMI_Faculty_AGN__r.email_AGN__c,AMI_Primary_Speaker_AGN__c
                       from Meeting_Speaker_AGN__c 
                       where Meeting_AGN__c =: meetingRecord.Id Order By LastModifiedDate Asc];
        String FacultyName = '';
        agendaWrapperList = new List<AgendaWrapper>();
        if(speakerList.size()>0)
        {
            selectedFaculty = speakerList[0];
            for(Meeting_Speaker_AGN__c MS : speakerList)
            {
                if(MS.AMI_Primary_Speaker_AGN__c)
                    FacultyName = MS.AMI_Faculty_AGN__r.Name_AGN__c;
            }
        }
        event = new AGN_AMI_SC_Meeting_Details_Wrapper(meetingRecord,false,FacultyName); 
        if(isLive)
        {
            agendaList = [Select Name_AGN__c,
                          Description_AGN__c,
                          End_Time_AGN__c,
                          Start_Time_AGN__c,
                          Day_of_Activity_AGN__c,
                          AMI_Faculty_AGN__r.Name_AGN__c
                          from AMI_Event_Agenda_AGN__c  
                          where Meeting_AGN__c =: event.meeting.Id
                          and Country_AGN__r.Name =: userCountryName
                          and Active_AGN__c = TRUE 
                          and Language_AGN__c =: userLanguage 
                          ORDER BY Sequence_Number_AGN__c];    
            if(! agendaList.isEmpty())
            {
                for(AMI_Event_Agenda_AGN__c agenda : agendaList)
                {
                    agendaWrapperList.add(new AgendaWrapper(agenda));
                }
            }
            
        }
        else
            agnAMIMeetingDocList = [select Name, Link_AGN__c from AGN_AMI_Meeting_Doc__c where Meeting_AGN__c =: event.meeting.Id order by Meeting_Sequence_AGN__c];
        attendanceList = [Select Id,toLabel(AMI_Registration_Type_AGN__c) from Event_Attendee_vod__c 
                          where Medical_Event_vod__c =: event.meeting.Id 
                          and Account_vod__c =: accountRecord.Id 
                          and status_vod__c != : AGN_AMI_SC_Static_Labels.attendeeStatusInvited
                          and status_vod__c != : AGN_AMI_SC_Static_Labels.attendeeStatusCancelled
                          limit 1];
        system.debug('attendanceList-->'+attendanceList);
        if(!(attendanceList.isEmpty()))
        {
            registered = true;
        }
        
        else
            registered = false;
        request = ApexPages.currentPage().getParameters().get('request');
        regOpen = false;
        playerOpen = false;
        if(request == 'register')
            regOpen = true; 
        if(request == 'play')
            playerOpen = true;
        
    }
    
    // Method refreshes the highlighted faculty in the page.
    public PageReference changeSelectFaculty()
    {
        System.debug(clickedFaculty);
        for(Meeting_Speaker_AGN__c ms : speakerList)
        {
            if(ms.Id == clickedFaculty)
                selectedFaculty = ms; 
        }
        return null;
    }
    
    // Method is triggered when user registers. It creates a Event Attendee record with status 'registered' and RecordType 'Portal Attendeee'
    public PageReference saveStreaming(){
        eventAttendee =  new Event_Attendee_vod__c();
        system.debug('@@@@accountRecord.Id'+ accountRecord.Id);
        system.debug('@@@@event.meeting.Id'+ event.meeting.Id);
        List<Event_Attendee_vod__c> pastReg = [Select Id,Status_vod__c from Event_Attendee_vod__c 
                                               where Account_vod__c =: accountRecord.Id  
                                               and Medical_Event_vod__c =: event.meeting.Id
                                               and AGN_AMI_Business_Unit__c=: AGN_AMI_SC_Static_Labels.specialityCare
                                               limit 1];
        
        system.debug('@@@@pastReg'+ pastReg);
        if(pastReg.size() > 0)
        {
            system.debug('@@@@insideee');
            eventAttendee = pastReg[0];
            eventAttendee.AMI_Registration_Type_AGN__c = AGN_AMI_SC_Static_Labels.meetingStatusLive;
            eventAttendee.Status_vod__c = AGN_AMI_SC_Static_Labels.attendeeStatusAccepted;
            eventAttendee.AGN_AMI_Business_Unit__c=AGN_AMI_SC_Static_Labels.specialityCare;
            
        }
        else
        {
            system.debug('@@@@outerelse');
            eventAttendee.AMI_Registration_Type_AGN__c = AGN_AMI_SC_Static_Labels.meetingStatusLive;
            eventAttendee.Account_vod__c = accountRecord.Id ;
            eventAttendee.Contact_AGN__c = contactRecord.Id;
            eventAttendee.Email_vod__c = user.email;
            eventAttendee.Status_vod__c = AGN_AMI_SC_Static_Labels.attendeeStatusAccepted;
            eventAttendee.Medical_Event_vod__c = event.meeting.Id;
            eventAttendee.AGN_AMI_Business_Unit__c=AGN_AMI_SC_Static_Labels.specialityCare;
            eventAttendee.RecordTypeId = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_SC_Attendee_Record_Type_AGN).getRecordTypeId();
        }
        system.debug(eventAttendee);
        try
        {
            if(!Test.isRunningTest()){ 
                upsert eventAttendee;
            }    
            system.debug('@@@@afterupsert');
            registered = true;
            attendanceList.add(eventAttendee);
        }
        catch(Exception ex)
        {
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_SC_Event_Detail_Controller','saveStreaming');
        }
        return null;
    }
    //This method updates the EventAttendee
    public void markAttendance()
    {
        eventAttendee =  attendanceList[0];
        eventAttendee.Status_vod__c = AGN_AMI_SC_Static_Labels.attendeeStatusAttended;
        try
        {
            if(!Test.isRunningTest()){
                update eventAttendee;
            }
        }
        catch(Exception ex)
        {
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_SC_Event_Detail_Controller','markAttendance');
        }
    }
    public Class AgendaWrapper
    {
        public AMI_Event_Agenda_AGN__c agenda {get; set;}
        public String formattedTime {get; set;}
        public agendaWrapper(AMI_Event_Agenda_AGN__c agenda)
        {
            String tz = UserInfo.getTimeZone().toString();
            this.agenda = agenda;
            formattedTime = agenda.Start_Time_AGN__c.format('HH:mm', tz) + ' - ' + agenda.End_Time_AGN__c.format('HH:mm', tz);
        }
    }
    
    public PageReference AVT_Webpage(){
        PageReference pr = new PageReference(Label.AGN_AMI_SC_AVT_Webpage);
        pr.setRedirect(true);
        pr.getParameters().put('eventId',eventId);
        return pr;
     } 
}