// This class is created as the Controller class of the Visualforce Page - AGN_AMI_All_Event
// Author - Ayush Basak
// Created Date - 10/12/2018
// Last Modified By - Ayush Basak
public without sharing class AGN_AMI_All_Event_Controller 
{

    
    User user; 
    Account accountRecord;
    public String userCountryName {get;set;}
    public String userLanguage {get; set;}
    
    public integer upcomingCount {get; set;}
    public integer pastCount {get; set;}
    //PMO#-3242-Start
    public boolean hideRequestTab{get; set;}
    //PMO#-3242-End
    public List<AGN_AMI_Meeting_Details_Wrapper> upcomingMeetings {get; set;}
    public List<AGN_AMI_Meeting_Details_Wrapper> pastMeetings {get; set;}
    public List<AGN_AMI_Meeting_Details_Wrapper> fullMeetings {get; set;}
    public AGN_AMI_Meeting_Details_Wrapper firstMeeting {get; set;}
    List<Medical_Event_vod__c> allAvailableMeetings;
    List<Id> allMeetingsId;
    public String clickedEvent {get; set;}
    public String clickedAction {get; set;}
    public String searchString {get; set;}
    public String searchPast {get; set;}
    public String searchStart {get; set;}
    public String searchEnd {get; set;}
    List<AGN_AMI_Meeting_Details_Wrapper> finalpastMeeting;//PMO-3379 Date-14/07/2020
    //PMO CR:3658 Strata Integration-Added variable for VF page- Start
    List<AGN_AMI_Meeting_Details_Wrapper> liveMeetings;//CR:3658
    public boolean isStrata { get; set; } //CR:3658
    public String eventPreviewDays { get; set; } //CR:3658
    public String clickedStatus { get; set; } //CR:3658
    public Datetime previewStartTime { get; set; } //CR:3658
    //PMO CR:3658 Strata Integration-Added variable for VF page- End
    
    // Constructor is used to fetch all the events visible to the User, along with additional data required to display along with the Events
    public AGN_AMI_All_Event_Controller()
    {
      /*  user = [Select contact.AccountId, contact.Account.Country_vod__r.Name,
                       Country_code__c, LanguageLocaleKey 
                from user 
                where id =: Userinfo.getUserid() 
                limit 1];
         
        userCountryName = user.contact.Account.Country_vod__r.Name;
        userLanguage = user.LanguageLocaleKey; */
        
         AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            
         //userDetails  = AGN_AMI_Utility_class.getUserDeails();   
         userLanguage = userDetails.userLanguage;
         userCountryName =  userDetails.userCountryName;
         user =  userDetails.user;
         //PMO#3242- Start
        if(userDetails.user.Is_AMI_Demo_User_AGN__c == true){
            hideRequestTab=true;
        }
        //PMO#3242- End
         accountRecord = userDetails.accountRecord;
        String meetingRecordTypeId  = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AMI_Meeting_Record_Type_AGN).getRecordTypeId();
        String attendeeRecordTypeId  = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_Attendee_Record_Type_AGN).getRecordTypeId();
        
        fullMeetings = new List<AGN_AMI_Meeting_Details_Wrapper>();
        upcomingMeetings = new List<AGN_AMI_Meeting_Details_Wrapper>();
        pastMeetings = new List<AGN_AMI_Meeting_Details_Wrapper>();
        allMeetingsId = new List<Id>();
        finalpastMeeting = new list<AGN_AMI_Meeting_Details_Wrapper>();
        liveMeetings = new list<AGN_AMI_Meeting_Details_Wrapper>();//PMO CR:3658 Strata Integration-new wrapper list only for livemeetings
        /* Speciality Care - Utlity Class Implementation -- Starts */
        /*
        allAvailableMeetings = [Select Id, Name,AMI_Event_Type_AGN__c, Description_vod__c, AMI_Event_Delivery_Type_AGN__c,
                                      Start_Time_vod__c, End_Time_vod__c, AMI_Event_Status_AGN__c,Location__c,
                                      Banner_Total_Time_Duration_AGN__c, Total_Time_Duration_AGN__c                              
                                from Medical_Event_vod__c 
                                where RecordTypeId =: meetingRecordTypeId
                                and Country_AGN__r.Name =: userCountryName
                                and AMI_Business_Unit__c ='Medical Aesthetics'   
                                order by Start_Time_vod__c];
        
        List<Event_Attendee_vod__c> registrationList = [Select Medical_Event_vod__c,Status_vod__c 
                                                        from Event_Attendee_vod__c
                                                        where Account_vod__c =: accountRecord.Id
                                                        and RecordTypeId =: attendeeRecordTypeId];
        */
        
        allAvailableMeetings = AGN_AMI_SC_Event_Util_Class.getAllEvents(userCountryName, meetingRecordTypeId,AGN_AMI_SC_Static_Labels.medicalAesthetics); 
        List<Event_Attendee_vod__c> registrationList = AGN_AMI_SC_Event_Util_Class.getRegisteredAttendees(accountRecord.Id, attendeeRecordTypeId);
        /* --Speciality Care - Utlity Class Implementation -- Ends */
        List<Id> invitedMeetingId = new List<Id>();
        for(Event_Attendee_vod__c ea : registrationList)
        {
            invitedMeetingId.add(ea.Medical_Event_vod__c); 
        }
        for(Medical_Event_vod__c me : allAvailableMeetings)
        {
            allMeetingsId.add(me.Id);
        }
        List<Meeting_Speaker_AGN__c> speakerList = [Select AMI_Faculty_AGN__r.Name_AGN__c,meeting_AGN__c
                                                    from Meeting_Speaker_AGN__c 
                                                    where Meeting_AGN__c in: allMeetingsId
                                                    and AMI_Primary_Speaker_AGN__c = true Order By LastModifiedDate Asc];
        
        for(Medical_Event_vod__c meeting : allAvailableMeetings)
        {
            boolean invitationFlag = false;
            for(Id meetId : invitedMeetingId)
            {
                if(meetId == meeting.Id)
                    invitationFlag = true;
            }
            if(meeting.AMI_Event_Type_AGN__c == AGN_AMI_Static_Labels.meetingTypePublic || (invitedMeetingId.contains(meeting.Id)) || invitationFlag)
            {
                integer flag = 0;
                for(Event_Attendee_vod__c attendee : registrationList)
                {
                     
                    if(meeting.Id == attendee.Medical_Event_vod__c && attendee.Status_vod__c != AGN_AMI_Static_Labels.attendeeStatusInvited 
                       && attendee.Status_vod__c != AGN_AMI_Static_Labels.attendeeStatusCancelled)
                    {
                        //PMO CR:3658 Strata Integration - If condition to identify Attendeed/Accepted Ateendee.
                        if(meeting.AMI_Event_Status_AGN__c == AGN_AMI_Static_Labels.meetingStatusPostView && meeting.Is_Strata_Event__c && (attendee.Status_vod__c == AGN_AMI_Static_Labels.attendeeStatusAttended ||attendee.Status_vod__c == AGN_AMI_Static_Labels.attendeeStatusAccepted))
                           {
                             flag = 2;  
                             System.debug('Flag==============='+flag);   
                           }else{
                             flag = 1;
                           }
                                  
                    } 
   
                }
                String facultyName = '';
                for(Meeting_Speaker_AGN__c ms : speakerList)
                {
                    if(ms.meeting_AGN__c == meeting.Id)
                    {
                        facultyName = ms.AMI_Faculty_AGN__r.Name_AGN__c;
                    }                
                }
                
                if(flag == 0 && meeting.AMI_Event_Status_AGN__c == 'Live')
                {
                    upcomingMeetings.add(new AGN_AMI_Meeting_Details_Wrapper(meeting,false,facultyName));
                } else if(flag == 0 && meeting.AMI_Event_Status_AGN__c == 'Recorded')
                {
                    pastMeetings.add(new AGN_AMI_Meeting_Details_Wrapper(meeting,false,facultyName));
                }
                
                else if(flag == 1 && meeting.AMI_Event_Status_AGN__c == 'Live')
                {
                    upcomingMeetings.add(new AGN_AMI_Meeting_Details_Wrapper(meeting,true,facultyName));
                }
                else if(flag == 1 && meeting.AMI_Event_Status_AGN__c == 'Recorded')
                {
                    pastMeetings.add(new AGN_AMI_Meeting_Details_Wrapper(meeting,true,facultyName));
                    
                } else if(flag == 2 && meeting.AMI_Event_Status_AGN__c == AGN_AMI_Static_Labels.meetingStatusPostView) //PMO CR:3658 Strata Integration - Added the 'Post View' Status.
                {
                   
                    upcomingMeetings.add(new AGN_AMI_Meeting_Details_Wrapper(meeting,true,facultyName));
                }
            }
        }
        
        //PMO#3379 Start -- To get the past event details in reverse chronological order
        
        for(Integer i = pastMeetings.size()-1; i>=0;i--) 
        {
            finalpastMeeting.add(pastMeetings.get(i));
        }
        pastMeetings.clear();
        pastMeetings.addAll(finalpastMeeting);
        //PMO#3379 End 
        
        upcomingCount = upcomingMeetings.size();
        pastCount = pastMeetings.size();
        
        
        if(upcomingCount>0)
         {
            //PMO CR:3658 Strata Integration-sorting the live meetings -Start
            for(Integer i =0; i< upcomingMeetings.size(); i++) 
            {
                
                if( upcomingMeetings.get(i).meeting.AMI_Event_Status_AGN__c == 'Live'){
                      liveMeetings.add(upcomingMeetings.get(i));
                 }
            }
            if(!liveMeetings.isEmpty()){
             system.debug('Live meeting==='+ liveMeetings[0]);
               firstMeeting = liveMeetings[0];
               if(liveMeetings[0].meeting.Is_Strata_Event__c)
                  {
                    isStrata =true;
                  }
                  eventPreviewDays= liveMeetings[0].meeting.Event_Preview_Days__c;
                  previewStartTime = liveMeetings[0].meeting.Preview_Start_Time__c;
                  System.debug('Preview Start Time========='+previewStartTime);
             }else{
             system.debug('upcoming meeting list==='+ upcomingMeetings[0]);
                if(upcomingMeetings[0].meeting.Is_Strata_Event__c)
                  {
                    isStrata =true;
                  } 
               firstMeeting = upcomingMeetings[0];
            }
         }
         //PMO CR:3658 Strata Integration-sorting the live meetings -End
        //PMO#3379 Start
        fullMeetings.addAll(upcomingMeetings);
        fullMeetings.addAll(pastMeetings);
        //PMO#3379 End 
                
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
        pr.getParameters().put('status',clickedStatus);
        
        return pr;
    }  
    // Added logic to mark Attendance for zoom event for CR#3611    
    public void markAttendance()    
    {   
        string meetingId= system.CurrentPageReference().getParameters().get('meetingId');   
        //string accountId= system.CurrentPageReference().getParameters().get('accountId'); 
            
        Event_Attendee_vod__c eventAttendee = [Select Id,Status_vod__c from Event_Attendee_vod__c   
                                               where Account_vod__c =: accountRecord.Id 
                                               and Medical_Event_vod__c =: meetingId    
                                               limit 1];    
        eventAttendee.Status_vod__c = AGN_AMI_Static_Labels.attendeeStatusAttended; 
        try 
        {   
           update eventAttendee;    
        }   
        catch(Exception ex) 
        {   
             AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_All_Event_Controller','markAttendance');   
        }   
        
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
            
        for(AGN_AMI_Meeting_Details_Wrapper mdw : fullMeetings)
            
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
        try
        {
 /* Speciality Care - Utlity Class Implementation -- Starts */
            /*
            Event_Attendee_vod__c ea = [Select Id from Event_Attendee_vod__c 
                                        where Account_vod__c =: accountRecord.Id
                                        and Medical_Event_vod__c =: clickedEvent
                                        limit 1];
            ea.Status_vod__c = AGN_AMI_Static_Labels.attendeeStatusCancelled;
            update ea; 
            */
            String stat=AGN_AMI_SC_Event_Util_Class.updateEvent(accountRecord.Id, clickedEvent,AGN_AMI_SC_Static_Labels.attendeeStatusCancelled);
 /* Speciality Care - Utlity Class Implementation -- Ends */
            for(AGN_AMI_Meeting_Details_Wrapper mdw : fullMeetings)
            {
                if(mdw.meeting.Id == clickedEvent)
                {
                    AGN_AMI_Meeting_Details_Wrapper updatedMDW = mdw;
                    updatedMDW.registered = false;
                    fullMeetings[fullMeetings.indexOf(MDW)] = updatedMDW;
                }    
            }
            for(AGN_AMI_Meeting_Details_Wrapper mdw : upcomingMeetings)
            {
                if(mdw.meeting.Id == clickedEvent) //PMO CR:3658 Strata Integration
                {
                    AGN_AMI_Meeting_Details_Wrapper updatedMDW = mdw;
                    updatedMDW.registered = false;
                    upcomingMeetings[upcomingMeetings.indexOf(mdw)] = updatedMDW;
                }    
            }
        }
        catch(Exception ex)
        {
            System.debug(ex);
        }
        List<AGN_AMI_Meeting_Details_Wrapper> firstLiveMeetings=new List<AGN_AMI_Meeting_Details_Wrapper>();//PMO CR:3658 Strata Integration-find the first live meeting
         for(Integer i =0; i< upcomingMeetings.size(); i++) 
            {
                
                if( upcomingMeetings.get(i).meeting.AMI_Event_Status_AGN__c == 'Live'){
                      firstLiveMeetings.add(upcomingMeetings.get(i));
                 }
            }
            if(!firstLiveMeetings.isEmpty()){
             system.debug('Live meeting==='+ liveMeetings[0]);
               firstMeeting = firstLiveMeetings[0];
               if(firstLiveMeetings[0].meeting.Is_Strata_Event__c)
                  {
                    isStrata =true;
                  }
             } else{
             system.debug('upcoming meeting list==='+ upcomingMeetings[0]);
                if(upcomingMeetings[0].meeting.Is_Strata_Event__c)
                  {
                    isStrata =true;
                  }
                firstMeeting = upcomingMeetings[0];
                
             }   
        return null;
    }
    //PMO CR:3658 Strata Integration- Update the Attendance Preview/Post View Status
   /** public static void upsertAttendanceStatus()    
    {
      
      string meetingId= system.CurrentPageReference().getParameters().get('meetingId');
      string status= system.CurrentPageReference().getParameters().get('status');
      string accountId= system.CurrentPageReference().getParameters().get('accountId');  
      String eajsRecordTypeId  = Schema.SObjectType.AMI_Event_Attendee_Journey_Status_AGN__c.getRecordTypeInfosByName().get('Event View').getRecordTypeId();
     
       AGN_AMI_SC_Event_Util_Class.upsertAttendanceStatus(accountId,meetingId,status,eajsRecordTypeId);
      
    }*/
}