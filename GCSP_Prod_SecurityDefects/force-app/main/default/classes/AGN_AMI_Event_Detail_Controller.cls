// This class is created as the Controller class of the Visualforce Page - AGN_AMI_Event_Detail
// Author - Ayush Basak
// Created Date - 11/12/2018
// Last Modified By - Ayush Basak
public without sharing class AGN_AMI_Event_Detail_Controller 
{
    public User user {get; set;} 
    public Account accountRecord{get; set;} // PMO CR:3658 Strata Integration- update the getter/setter
    Contact contactRecord;
    public String userCountryName {get;set;}
    public String userLanguage {get; set;}
    Medical_Event_vod__c meetingRecord;
    public AGN_AMI_Meeting_Details_Wrapper event {get; set;}
    public List<Meeting_Speaker_AGN__c> speakerList {get;set;}
    public List<AMI_Event_Agenda_AGN__c> agendaList {get; set;}
    public List<AgendaWrapper> agendaWrapperList {get; set;}
    public List<AGN_AMI_Meeting_Doc__c> agnAMIMeetingDocList {get; set;}
    public String request {get; set;}
    public boolean isLive {get; set;}
    //public String gmapSearchKey {get; set;}
    public Meeting_Speaker_AGN__c selectedFaculty {get; set;}
    public String clickedFaculty {get; set;}
    public Event_Attendee_vod__c eventAttendee {get; set;}
    public List<Event_Attendee_vod__c> attendanceList {get; set;}
    public Boolean registered {get; set;}
    public Boolean regOpen {get; set;}
    public Boolean playerOpen {get; set;}
    //PMO#3020 this variable is created to get the rating value from the event detail page starts 
    public String eventRating {get;set;}
    public Event_Attendee_vod__c attendeeRating {get;set;}
    public String ratingTime {get;set;}
    //PMO#3020 this variable is created to get the rating value from the event detail page ends
    public String eventName {get; set;}
    public List<String> requiredModules {get; set;}
    public List<AMI_Lrn_Rel_Dtl_AGN__c> requiredModulesList {get; set;}
    public List<AMI_Learning_Path_AGN__c> requiredModulesProgressList {get; set;}
    List<AMI_Event_Journey_Controller_AGN__c> preEventList;
    List<AMI_Event_Journey_Controller_AGN__c> preModuleList;
    public String moduleId {get; set;}
    public Boolean showModuleSection {get; set;}
    public Integer moduleSize {get; set;}
    public boolean showPopup {get; set;}
    public boolean sp{get;set;} 
    //PMO CR:3658 Strata Integration- Added varibles for VF page- Start
    public boolean isStrata{get;set;} //CR:3658
    public String eventPreviewDays { get; set; } //CR:3658
    public Datetime previewStratTime { get; set; } //CR:3658
    public String eventPasscode { get; set; } //CR:3658-18/01
    public String userCountryIntVEP{ get; set; }// Fix for Strata Country code issue.22/02/2021
    public AGN_AMI_Meeting_Doc__c selectedcontent{get; set;}
    //PMO CR:3658 Strata Integration- Added varibles for VF page- End
    // Constructor is used to fetch the details of the particular event which is based on eventId parameter in URL.
    // Addtional information of the Events are fetched from Event Attendee, Meeting Speaker, AMI Meeting Docs and AMI Event Agenda
    public AGN_AMI_Event_Detail_Controller()
    {
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        
        //userDetails  = AGN_AMI_Utility_class.getUserDeails();   
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        //Incident Fix for Strata country code issue.22/02/2021
        userCountryIntVEP = userDetails.userCountryForStrata;
        user =  userDetails.user;
        accountRecord = userDetails.accountRecord;
        contactRecord = userDetails.contactRecord;
        
        
        String eventId= ApexPages.currentPage().getParameters().get('eventId');
        meetingRecord = [Select Id, Name, AMI_Event_Passcode__c, Description_vod__c, Country_code__c, toLabel(AMI_Event_Delivery_Type_AGN__c), Banner_Total_Time_Duration_AGN__c,Detail_Page_Image_AGN__c,
                         Start_Time_vod__c, End_Time_vod__c, AMI_Event_Status_AGN__c,Location__c, Detail_Page_Video_AGN__c,Building_Name_AGN__c,
                         Event_Broadcast_Link_AGN__c, Live_Event_Description_AGN__c, Past_Event_Description_AGN__c,Location_Description_AGN__c,Is_Strata_Event__c,Event_Preview_Days__c,Preview_Start_Time__c// PMO CR:3658 Strata Integration- Added field to query
                         from Medical_Event_vod__c 
                         where Id =: eventId Limit 1];
        showPopup = AMI_User_Settings_AGN__c.getValues(meetingRecord.Country_Code__c).Veeve_Integration_Enabled_AGN__c;
        //gmapSearchKey = (meetingRecord.Location_Description_AGN__c!=null)?meetingRecord.Location_Description_AGN__c.replaceAll(' ','+'):'';
        isLive = meetingRecord.AMI_Event_Status_AGN__c == 'Live' || meetingRecord.AMI_Event_Status_AGN__c == AGN_AMI_Static_Labels.meetingStatusPostView; // PMO CR:3658 Strata Integration- Added Post View condition.
        isStrata = meetingRecord.Is_Strata_Event__c; // PMO CR:3658 Strata Integration- assign IsStrata value to a varibale for VF
        //eventPreviewDays= meetingRecord.Event_Preview_Days__c;
        previewStratTime = meetingRecord.Preview_Start_Time__c;// PMO CR:3658 Strata Integration-assign previewStartTime to a varible for VF
        eventPasscode= meetingRecord.AMI_Event_Passcode__c;// 18/01-PMO CR:3658 Strata Integration-assign previewStartTime to a varible for VF
        speakerList = [Select Id,AMI_Faculty_AGN__r.id, AMI_Faculty_AGN__r.Name, 
                       AMI_Faculty_AGN__r.AMI_Specialty_AGN__r.Name_AGN__c, AMI_Faculty_AGN__r.Hospital_AGN__c,
                       AMI_Faculty_AGN__r.Image_URL_AGN__c, AMI_Faculty_AGN__r.Country_AGN__c, 
                       AMI_Faculty_AGN__r.Name_AGN__c, AMI_Faculty_AGN__r.Title_AGN__c, 
                       AMI_Faculty_AGN__r.email_AGN__c,AMI_Primary_Speaker_AGN__c
                       from Meeting_Speaker_AGN__c 
                       where Meeting_AGN__c =: meetingRecord.Id Order By LastModifiedDate Asc];
      
       
        /*render if speakeer list is more than 1 */
        if (speakerList.size()>1)
        {
         sp=true;   
        }
        else
        {
         sp=false;
        }
      
     
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
        event = new AGN_AMI_Meeting_Details_Wrapper(meetingRecord,false,FacultyName); 
        if(isLive)
        {
            preEventList = [Select  AMI_Related_Event_AGN__r.Name 
                            from AMI_Event_Journey_Controller_AGN__c 
                            where AMI_Meeting_AGN__c = :event.meeting.Id and 
                            recordtype.developername = :AGN_AMI_Static_Labels.EJCEventRecordtype
                            and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJCTaskTypePre
                            limit 1];
            if(preEventList != null && preEventList.size()>0)
                eventName = preEventList[0].AMI_Related_Event_AGN__r.Name;
            
             preModuleList = [Select AMI_Learning_Relationship_Detail_AGN__r.Module_Fma_AGN__c 
                                                                       from AMI_Event_Journey_Controller_AGN__c 
                                                                       where AMI_Meeting_AGN__c = :event.meeting.Id  and 
                                                                       recordtype.developername = :AGN_AMI_Static_Labels.EJCModuleRecordtype
                                                                       and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJCTaskTypePre];
           
            
            requiredModules = new List<String>();
            Set<Id> moduleIdList = new Set<Id>();
            if(preModuleList != null && preModuleList.size()>0)
            {
                
                for(AMI_Event_Journey_Controller_AGN__c EJC : preModuleList)
                {
                    moduleIdList.add(EJC.AMI_Learning_Relationship_Detail_AGN__c);
                    requiredModules.add(EJC.AMI_Learning_Relationship_Detail_AGN__r.Module_Fma_AGN__c);
                }
            }
            
             moduleSize = requiredModules.size();
            
            requiredModulesProgressList = [Select Id, Module__c, HCP_AGN__c,
                                           Module__r.Curriculum_AGN__c,Module__r.Curriculum_Fma_AGN__c,
                                           Module__r.Module_AGN__c,Module__r.Module_Fma_AGN__c,
                                           Module__r.Program_AGN__c,Module__r.Program_Fma_AGN__c,
                                           Module__r.Module_AGN__r.Anatomy_Area_AGN__c,
                                           Module__r.Module_AGN__r.Module_Duration_AGN__c,
                                           Module__r.Module_AGN__r.AMI_Image_URL_AGN__c,CreatedDate,
                                           Module__r.Module_AGN__r.Description_AGN__c,
                                           Module__r.Module_AGN__r.Module_Content_Type_AGN__c,
                                           Module_Status_AGN__c,
                                           Module__r.Module_AGN__r.Module_format_AGN__c
                                           from AMI_Learning_Path_AGN__c 
                                           where HCP_AGN__c =: accountRecord.Id 
                                           and Module__r.Active_AGN__c = true 
                                           and Module__c in: moduleIdList];
            for(AMI_Learning_Path_AGN__c lp : requiredModulesProgressList)
            {
                moduleIdList.remove(lp.Module__c);
            }
            requiredModulesList = [Select Curriculum_AGN__c,
                                                Curriculum_Fma_AGN__c,
                                                Module_AGN__c,
                                                Module_Fma_AGN__c,
                                                Program_AGN__c,
                                                Program_Fma_AGN__c,
                                                Module_AGN__r.Anatomy_Area_AGN__c,
                                                Module_AGN__r.Module_Content_Type_AGN__c,
                                                Module_AGN__r.Tags_AGN__c,
                                                Module_AGN__r.Description_AGN__c,
                                                Module_AGN__r.Module_Duration_AGN__c,
                                                Module_AGN__r.Duration_FMA_AGN__c,
                                                Module_AGN__r.AMI_Image_URL_AGN__c,
                                                Module_AGN__r.AMI_Recommended_AGN__c,
                                                Module_AGN__r.LastModifiedDate,
                                                Module_AGN__r.Module_format_AGN__c,
                                                Country_AGN__c,
                                                Module_AGN__r.Restricted_AGN__c
                                                from AMI_Lrn_Rel_Dtl_AGN__c
                                                where Active_AGN__c = true  //  Module_AGN__r.AMI_Recommended_AGN__c=true and 
                                                and Country_AGN__r.name =: userCountryName
                                                and Language_AGN__c =: userLanguage and id in: moduleIdList];
            agendaList = [Select Name_AGN__c,
                          Description_AGN__c,
                          End_Time_AGN__c,
                          Start_Time_AGN__c,
                          Day_of_Activity_AGN__c,
                          AMI_Faculty_AGN__r.Name_AGN__c
                          from AMI_Event_Agenda_AGN__c  
                          where Meeting_AGN__c =: event.meeting.Id and
                           Country_AGN__r.Name =: userCountryName
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
        {
             preModuleList = [Select AMI_Learning_Relationship_Detail_AGN__r.Module_Fma_AGN__c 
                                                                       from AMI_Event_Journey_Controller_AGN__c 
                                                                       where AMI_Meeting_AGN__c = :event.meeting.Id  and 
                                                                       recordtype.developername = :AGN_AMI_Static_Labels.EJCModuleRecordtype
                                                                       and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJASTaskTypePost];
            Set<Id> moduleIdList = new Set<Id>();
            if(preModuleList != null && preModuleList.size()>0)
            {
                requiredModules = new List<String>();
                for(AMI_Event_Journey_Controller_AGN__c EJC : preModuleList)
                {
                    moduleIdList.add(EJC.AMI_Learning_Relationship_Detail_AGN__c);
                    requiredModules.add(EJC.AMI_Learning_Relationship_Detail_AGN__r.Module_Fma_AGN__c);
                }
            }
            requiredModulesProgressList = [Select Id, Module__c, HCP_AGN__c,
                                           Module__r.Curriculum_AGN__c,Module__r.Curriculum_Fma_AGN__c,
                                           Module__r.Module_AGN__c,Module__r.Module_Fma_AGN__c,
                                           Module__r.Program_AGN__c,Module__r.Program_Fma_AGN__c,
                                           Module__r.Module_AGN__r.Anatomy_Area_AGN__c,
                                           Module__r.Module_AGN__r.Module_Duration_AGN__c,
                                           Module__r.Module_AGN__r.AMI_Image_URL_AGN__c,CreatedDate,
                                           Module__r.Module_AGN__r.Description_AGN__c,
                                           Module__r.Module_AGN__r.Module_Content_Type_AGN__c,
                                           Module_Status_AGN__c,
                                           Module__r.Module_AGN__r.Module_format_AGN__c
                                           from AMI_Learning_Path_AGN__c 
                                           where HCP_AGN__c =: accountRecord.Id 
                                           and Module__r.Active_AGN__c = true 
                                           and Module__c in: moduleIdList];
            for(AMI_Learning_Path_AGN__c lp : requiredModulesProgressList)
            {
                moduleIdList.remove(lp.Module__c);
            }
            requiredModulesList = [Select Curriculum_AGN__c,
                                                Curriculum_Fma_AGN__c,
                                                Module_AGN__c,
                                                Module_Fma_AGN__c,
                                                Program_AGN__c,
                                                Program_Fma_AGN__c,
                                                Module_AGN__r.Anatomy_Area_AGN__c,
                                                Module_AGN__r.Module_Content_Type_AGN__c,
                                                Module_AGN__r.Tags_AGN__c,
                                                Module_AGN__r.Description_AGN__c,
                                                Module_AGN__r.Module_Duration_AGN__c,
                                                Module_AGN__r.Duration_FMA_AGN__c,
                                                Module_AGN__r.AMI_Image_URL_AGN__c,
                                                Module_AGN__r.AMI_Recommended_AGN__c,
                                                Module_AGN__r.LastModifiedDate,
                                                Module_AGN__r.Module_format_AGN__c,
                                                Country_AGN__c,
                                                Module_AGN__r.Restricted_AGN__c
                                                from AMI_Lrn_Rel_Dtl_AGN__c
                                                where Active_AGN__c = true  //  Module_AGN__r.AMI_Recommended_AGN__c=true and 
                                                and Country_AGN__r.name =: userCountryName
                                                and Language_AGN__c =: userLanguage and id in: moduleIdList];
            
        }
        //PMO#3018 HCP to be able download pre documents for upcoming events Strats
        agnAMIMeetingDocList = [select Name, Link_AGN__c,AGN_AMI_Document_Section__c from AGN_AMI_Meeting_Doc__c where Meeting_AGN__c =: event.meeting.Id order by Meeting_Sequence_AGN__c];
        //PMO#3018 HCP to be able download pre documents for upcoming events ends

        showModuleSection = !(requiredModulesProgressList.isEmpty() && requiredModulesList.isEmpty()); 
          //PMO CR:3658 Strata Integration- added a field Medical_Event_vod__c  
        attendanceList = [Select Id,Medical_Event_vod__c,toLabel(AMI_Registration_Type_AGN__c) from Event_Attendee_vod__c 
                          where Medical_Event_vod__c =: event.meeting.Id 
                          and Account_vod__c =: accountRecord.Id 
                          and status_vod__c != : AGN_AMI_Static_Labels.attendeeStatusInvited
                          and status_vod__c != : AGN_AMI_Static_Labels.attendeeStatusCancelled
                          limit 1];
        
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
            
        //PMO#3020 this query is use to get the rating intially when the page loads starts
        if(!(attendanceList.isEmpty())){
        attendeeRating = [Select AGN_AMI_Post_Event_Rating__c from Event_Attendee_vod__c 
                                               where Account_vod__c =: accountRecord.Id  
                                               and Medical_Event_vod__c =: event.meeting.Id
                                          limit 1];
        }
        //PMO#3020 this query is use to get the rating intially when the page loads ends
        //PMO#3020 this is to get the customsetting value and pass it to the vf page starts
        AMI_Web_Visibility_Settings_AGN__c wbSetting = AMI_Web_Visibility_Settings_AGN__c.getValues(userCountryName);
        ratingTime = wbSetting.AGN_AMI_Event_Rating_Time__c;
        system.debug(ratingTime);
        system.debug(userCountryName+'userCountryName@@');
        //PMO#3020 this is to get the customsetting value and pass it to the vf page ends     
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
        //Incident fix for Strata 'Pre Event Access'.22/02/2021
        List<Event_Attendee_vod__c> pastReg = [Select Id,Medical_Event_vod__c,Status_vod__c from Event_Attendee_vod__c 
                                               where Account_vod__c =: accountRecord.Id  
                                               and Medical_Event_vod__c =: event.meeting.Id
                                               limit 1];
        if(pastReg.size() > 0)
        {
            eventAttendee = pastReg[0];
            eventAttendee.AMI_Registration_Type_AGN__c = 'Live Stream';
            eventAttendee.Status_vod__c = AGN_AMI_Static_Labels.attendeeStatusAccepted;
        }
        else
        {
            eventAttendee.AMI_Registration_Type_AGN__c = 'Live Stream';
            eventAttendee.Account_vod__c = accountRecord.Id ;
            eventAttendee.Contact_AGN__c = contactRecord.Id;
            eventAttendee.Email_vod__c = user.email;
            eventAttendee.Status_vod__c = AGN_AMI_Static_Labels.attendeeStatusAccepted;
            eventAttendee.Medical_Event_vod__c = event.meeting.Id;
            eventAttendee.RecordTypeId = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_Attendee_Record_Type_AGN).getRecordTypeId();
        }
        system.debug(eventAttendee);
        try
        {
            upsert eventAttendee;
            registered = true;
            attendanceList.add(eventAttendee);
            if(preEventList != null){
                addToRelatedEvent();
            }
            if(preModuleList != null){
             preEventAddToLearningPath();
            }
                 
        }
        catch(Exception ex)
        {
            System.debug(ex);
        }
        return null;
    }
    
    
   public Event_Attendee_vod__c geteventAddendee(){

        Event_Attendee_vod__c eventAddendee = [Select Id,Attendee_Name_AGN__c,Account_vod__r.PersonEmail,Status_vod__c,Account_vod__c,Medical_Event_vod__r.Name,Medical_Event_vod__r.Start_Time_vod__c,Medical_Event_vod__r.End_Time_vod__c,Medical_Event_vod__r.AMI_Portal_Link_AGN__c from Event_Attendee_vod__c
                                               where Account_vod__c =: accountRecord.Id  
                                               and Medical_Event_vod__c =: event.meeting.Id
                                               limit 1];
                                               
        return eventAddendee;
    }
    
   public PageReference outlook_EventSave(){
      return Page.AGN_AMI_Outlook_EventSave;
     }
    
   public String getReferer(){
    return ApexPages.currentPage().getHeaders().get('referer');
    }
    
    public void markAttendance()
    {
        //Change the markAttendance logic-CR#3611 – Zoom event pop-up issue- Start
        if(attendanceList.size() > 0){
        
            eventAttendee =  attendanceList[0];
            eventAttendee.Status_vod__c = AGN_AMI_Static_Labels.attendeeStatusAttended;
           }else{
       
             eventAttendee = [Select Id,Attendee_Name_AGN__c,Account_vod__r.PersonEmail,Status_vod__c,Account_vod__c,Medical_Event_vod__r.Name,Medical_Event_vod__r.Start_Time_vod__c,Medical_Event_vod__r.End_Time_vod__c,Medical_Event_vod__r.AMI_Portal_Link_AGN__c from Event_Attendee_vod__c
                                               where Account_vod__c =: accountRecord.Id  
                                               and Medical_Event_vod__c =: event.meeting.Id
                                               limit 1];
              eventAttendee.Status_vod__c = AGN_AMI_Static_Labels.attendeeStatusAttended;
          
            }
            //Change the markAttendance logic-CR#3611 – Zoom event pop-up issue-End
            try
            {
                update eventAttendee;
            }
            catch(Exception ex)
            {
                System.debug(ex);
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
            //CR3262 - Timezone added to string formatting
            formattedTime = agenda.Start_Time_AGN__c.format('HH:mm', tz) + ' - ' + agenda.End_Time_AGN__c.format('HH:mm z', tz);
        }
    }
    //PMO#3020 this method is created to get the rating value from the event detail page and update in the attendee record
    public PageReference updateRating(){
        system.debug('Entering the function@@@@');
        system.debug('Rating@@@'+ eventRating);
        Event_Attendee_vod__c attendee = [Select Id,Status_vod__c from Event_Attendee_vod__c 
                                               where Account_vod__c =: accountRecord.Id  
                                               and Medical_Event_vod__c =: event.meeting.Id
                                          limit 1];
        attendee.AGN_AMI_Post_Event_Rating__c = eventRating;
        attendeeRating = attendee;
        update attendee;

        return null;
    }
    public void addToRelatedEvent()
    {
        //Incident fix for Strata 'Pre Event Access'.22/02/2021
        List<Event_Attendee_vod__c> pastReg = [Select Id,Status_vod__c,Medical_Event_vod__c from Event_Attendee_vod__c 
                                               where Account_vod__c =: accountRecord.Id  
                                               and Medical_Event_vod__c =: preEventList[0].AMI_Related_Event_AGN__c
                                               limit 1];
        Event_attendee_vod__c secondReg = new Event_attendee_vod__c();
        if(pastReg.size() > 0)
        {
            secondReg = pastReg[0];
            secondReg.AMI_Registration_Type_AGN__c = 'Live Stream';
            secondReg.Status_vod__c = AGN_AMI_Static_Labels.attendeeStatusAccepted;
        }
        else
        {
            secondReg.AMI_Registration_Type_AGN__c = 'Live Stream';
            secondReg.Account_vod__c = accountRecord.Id ;
            secondReg.Contact_AGN__c = contactRecord.Id;
            secondReg.Email_vod__c = user.email;
            secondReg.Status_vod__c = AGN_AMI_Static_Labels.attendeeStatusAccepted;
            secondReg.Medical_Event_vod__c = preEventList[0].AMI_Related_Event_AGN__c;
            secondReg.RecordTypeId = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get(Label.AMI_Attendee_Record_Type_AGN).getRecordTypeId();
        }
        upsert secondReg;
    }
    
    public PageReference redirectToModulePage()
    {
        moduleId=ApexPages.currentPage().getParameters().get('moduleId');
        PageReference pr = new PageReference(System.Label.AGN_AMI_Module_Details_Page);
        pr.setRedirect(true);
        pr.getParameters().put('lRDId',moduleId);
        return pr;
    }
    
    
    public void preEventAddToLearningPath()
    {
        
        List<AMI_Event_Journey_Controller_AGN__c> controllingRecords = [Select id, AMI_Learning_Relationship_Detail_AGN__c,AMI_Meeting_AGN__c, AMI_Type_AGN__c,AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c 
                                                                        from AMI_Event_Journey_Controller_AGN__c 
                                                                        where RecordType.DeveloperName = :AGN_AMI_Static_Labels.EJCModuleRecordtype
                                                                        and AMI_Meeting_AGN__c = :event.meeting.Id
                                                                        and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJCTaskTypePre];
        
        
        Set<Id> EJC_LRDIds = new Set<Id>(); 
        for(AMI_Event_Journey_Controller_AGN__c aejc : controllingRecords){
           EJC_LRDIds.add(aejc.AMI_Learning_Relationship_Detail_AGN__c);
        }
        
       
        //Retriving existing Learning Path
        List<AMI_Learning_Path_AGN__c> ExistingLearningPathRecords = [Select id,Module__c,HCP_AGN__c from AMI_Learning_Path_AGN__c 
                                                              where Module__c in : EJC_LRDIds and HCP_AGN__c = : accountRecord.Id];
        
        
        Map<id,AMI_Learning_Path_AGN__c> ExistingLpMap = new Map<id,AMI_Learning_Path_AGN__c>();
        if(!ExistingLearningPathRecords.isEmpty()){
            for(AMI_Learning_Path_AGN__c lp : ExistingLearningPathRecords){
                ExistingLpMap.put(lp.Module__c,lp);
            }
        }
         
        
        List<AMI_Lrn_Rel_Dtl_AGN__c> LRDRecords = [Select Curriculum_AGN__r.Curriculum_AGN__c,Curriculum_AGN__r.Id,
                                                    CurrencyIsoCode,Program_AGN__r.Program_AGN__c,
                                                    Country_AGN__r.Country_Name_vod__c,
                                                    Country_AGN__c,Module_AGN__c,Module_AGN__r.Id,Curriculum_Fma_AGN__c,Program_Fma_AGN__c 
                                                    from AMI_Lrn_Rel_Dtl_AGN__c where id in : EJC_LRDIds];
        
        
        Map<Id,AMI_Lrn_Rel_Dtl_AGN__c> LRDMap = new Map<Id,AMI_Lrn_Rel_Dtl_AGN__c>();
        Set<Id> LRD_ModuleIds = new Set<Id>();
         for(AMI_Lrn_Rel_Dtl_AGN__c lrd : LRDRecords){
            LRDMap.put(lrd.id,lrd);
            LRD_ModuleIds.add(lrd.Module_AGN__c);
        }
        
     
        List<AMI_Sessions_AGN__c> SessionList = new List<AMI_Sessions_AGN__c>();
        if(!LRD_ModuleIds.isEmpty()){ 
           SessionList = [select Id,Parent_Module_AGN__c,Name_AGN__c,Session_Code_AGN__c, Content_Type_AGN__c,Duration_AGN__c,File_name_AGN__c,Parent_Module_AGN__r.Module_Content_Type_AGN__c,
                          Status_AGN__c, Training_URL_AGN__c,ZINC_number_AGN__c, Sequence_Number_AGN__c
                          from AMI_Sessions_AGN__c where Parent_Module_AGN__c in :LRD_ModuleIds and IsActive_AGN__c = true
                          order by Sequence_Number_AGN__c asc];
        }
        
        
        Map<id,List<AMI_Sessions_AGN__c>> SessionMap = new Map<id,List<AMI_Sessions_AGN__c>>();
        for(AMI_Sessions_AGN__c AMISession : SessionList){
            List<AMI_Sessions_AGN__c> AMISessionList = SessionMap.get(AMISession.Parent_Module_AGN__c);
            if(AMISessionList!=Null){
               AMISessionList.add(AMISession); 
            }else{
                List<AMI_Sessions_AGN__c> AMISessionList2 = new List<AMI_Sessions_AGN__c>();
                AMISessionList2.add(AMISession);
                SessionMap.put(AMISession.Parent_Module_AGN__c,AMISessionList2);
            }
        }
            
        
         Id LPRecordtype = Schema.SObjectType.AMI_Learning_Path_AGN__c.getRecordTypeInfosByDeveloperName().get('AGN_Defined').getRecordTypeId();
         List<AMI_Learning_Path_AGN__c> insertLPList = new List<AMI_Learning_Path_AGN__c>();
             for(AMI_Event_Journey_Controller_AGN__c ejc : controllingRecords){
            
                          AMI_Learning_Path_AGN__c lpRecord = ExistingLpMap.get(ejc.AMI_Learning_Relationship_Detail_AGN__c);
                          if(lpRecord==Null){
                           
                            if(LRDMap.containsKey(ejc.AMI_Learning_Relationship_Detail_AGN__c)){
                              AMI_Lrn_Rel_Dtl_AGN__c lrd = LRDMap.get(ejc.AMI_Learning_Relationship_Detail_AGN__c);
                                
                            AMI_Learning_Path_AGN__c  ALP = new AMI_Learning_Path_AGN__c();
                            
                            ALP.HCP_AGN__c= accountRecord.Id;
                            ALP.Contact_AGN__c = contactRecord.Id;
                            ALP.Module__c = lrd.id;
                            ALP.Country_AGN__c=lrd.Country_AGN__c;
                            ALP.Country_code_AGN__c=lrd.Country_AGN__r.Country_Name_vod__c;
                            //ALP.OwnerId=lstAmiAdmin.size()>0?lstAmiAdmin[0].Id:Userinfo.getUserid();
                            ALP.CurrencyIsoCode=lrd.CurrencyIsoCode;
                            ALP.RecordTypeId= LPRecordtype;
                          insertLPList.add(ALP);
                          
              }  
           }
        }
        
        if(!insertLPList.isEmpty()){
            insert insertLPList;
        }
        
       Set<Id> LpIdSet = new Set<Id>();
        for(AMI_Learning_Path_AGN__c lp : insertLPList){
          LpIdSet.add(lp.Id);  
        }
        
        List<AMI_Learning_Path_AGN__c> FinalLPList = new List<AMI_Learning_Path_AGN__c>();
        if(!LpIdSet.isEmpty()){
            FinalLPList =[Select id,Module__c,HCP_AGN__c,Module__r.Module_AGN__c from AMI_Learning_Path_AGN__c where id in : LpIdSet];
        }
        
        List<AMI_Path_Session_AGN__c> insertAPSList = new List<AMI_Path_Session_AGN__c>();
        for(AMI_Learning_Path_AGN__c lp : FinalLPList){
            
            List<AMI_Sessions_AGN__c> getSession =  SessionMap.get(lp.Module__r.Module_AGN__c);
                   
            for(AMI_Sessions_AGN__c session : getSession){
                                    
                      AMI_Path_Session_AGN__c aps = new AMI_Path_Session_AGN__c();
                        aps.AMI_Learning_Path_agn__c=lp.Id;
                        aps.Duration_AGN__c=session.Duration_AGN__c;
                        aps.File_name_AGN__c=session.File_name_AGN__c;
                        aps.Name_AGN__c=session.Name_AGN__c;
                        aps.ZINC_number_AGN__c=session.ZINC_number_AGN__c;
                        aps.Training_URL_AGN__c=session.Training_URL_AGN__c;
                        aps.Session_Code_AGN__c=session.Session_Code_AGN__c;
                        aps.Active_AGN__c = true;
                     insertAPSList.add(aps);
              }
            
        }
        
        if(!insertAPSList.isEmpty()){
            insert insertAPSList;
        }
    } 
    
    // PMO CR:3658 Strata Integration-Added logic to update the Preview/Post-View Status 
    //Update Attended logic for Live button click-20/01/2021 
    // PMO CR: 3979 reorganized the code to avoid NullPointerException -27/05/2021
   public void upsertAttendanceStatus()    
    {   
           User usr= [SELECT Profile_Name_vod__c FROM User WHERE Id=:userinfo.getuserid() LIMIT 1];
          
           string status= system.CurrentPageReference().getParameters().get('status');
           eventAttendee =  new Event_Attendee_vod__c();
           AMI_Event_Attendee_Journey_Status_AGN__c EAJS= new AMI_Event_Attendee_Journey_Status_AGN__c();
          if(status !='Live')
          {
              String eventStatus='';
              if(status == 'Postview')
              {
                eventStatus= AGN_AMI_Static_Labels.meetingStatusPostView;
              }else{
                 eventStatus= status;
              }
              String eajsRecordTypeId  = Schema.SObjectType.AMI_Event_Attendee_Journey_Status_AGN__c.getRecordTypeInfosByName().get('Event View').getRecordTypeId();
            
             if(attendanceList.size() > 0){
            
                  eventAttendee =  attendanceList[0];
                  EAJS.AMI_Meeting_Attendee_AGN__c = eventAttendee.Id;
                  EAJS.AMI_Related_Event_AGN__c = eventAttendee.Medical_Event_vod__c;
                  EAJS.RecordTypeId = eajsRecordTypeId;
                  EAJS.AMI_Event_Stage__c= eventStatus;
                  EAJS.AMI_Event_Interaction_Date__c = System.now();
               }
             
            try 
            {   
              insert EAJS; 
            }catch(Exception ex) 
            {   
               AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Event_Detail_Controller','insertJourneyStatus');   
            } 
      }else{
         
         if(usr.Profile_Name_vod__c =='AGN AMI Admin Profile' || usr.Profile_Name_vod__c =='SMB Primary Care Sales - Platform')
         {
            system.debug('Exception : Status can not be changed as "Attended" if the parent meeting status is not "Completed');
          }else{
            
            if(attendanceList.size() > 0){
            
                 eventAttendee =  attendanceList[0];
                 eventAttendee.Status_vod__c = AGN_AMI_Static_Labels.attendeeStatusAttended;
               }
              try 
              {   
                
                  update eventAttendee;
                  
              }catch(Exception ex){   
                 AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Event_Detail_Controller','upsertAttendanceStatus');   
              } 
           }
        }
    }
    
    /*CR - 3763- Start */
    public PageReference meetingdocTrack()
    {
        
        String eventtrack=Apexpages.currentPage().getParameters().get('eventtrack');
        for(AGN_AMI_Meeting_Doc__c mt : agnAMIMeetingDocList)
        {
            if(mt.Id == eventtrack)
            {
                selectedContent = mt;
                break;
            }
        }
        try{
            list<AMI_Trend_Tracking_AGN__c> trackList=[select id,AMI_HCP_Name_AGN__c,AMI_Number_of_Views_AGN__c from AMI_Trend_Tracking_AGN__c where AMI_HCP_Name_AGN__c=:accountRecord.id and AMI_Meeting_Document_Track_AGN__c=:selectedcontent.ID];
            if(trackList !=null && !trackList.isEmpty()){
                trackList[0].AMI_Number_of_Views_AGN__c=trackList[0].AMI_Number_of_Views_AGN__c+1;
                trackList[0].AMI_Last_view_Date_Time_AGN__c=datetime.now();
                update Tracklist;
            }
            else{
                trackList.add(new AMI_Trend_Tracking_AGN__c(AMI_HCP_Name_AGN__c=accountRecord.id,
                                                                 AMI_Number_of_Views_AGN__c=1,
                                                                 AMI_Meeting_Document_Track_AGN__c=selectedcontent.id,
                                                                 AMI_Last_view_Date_Time_AGN__c=datetime.now(),
                                                                 RecordTypeId=schema.SObjectType.AMI_Trend_Tracking_AGN__c.getRecordTypeinfosByName().get('AMI Meeting Document Track').getRecordTypeId()));
                insert trackList;
            }
            list<AMI_Trend_Tracking_Item_AGN__c> apdtList=new list<AMI_Trend_Tracking_Item_AGN__c>();
            if(trackList !=null && !trackList.isEmpty()){
                apdtList.add(new AMI_Trend_Tracking_Item_AGN__c(AMI_HCP_Name_AGN__c=accountRecord.id,
                                                               AMI_view_Date_Time_AGN__c=datetime.now(),
                                                               AMI_Meeting_Document_Name_AGN__c=selectedcontent.id,
                                                               AMI_Portal_Tracking_Name_AGN__c=Tracklist[0].id));
                insert apdtList;
            }
        }catch(Exception ex){
            system.debug('Exception : '+ex.getMessage());
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Event_Detail_Controller','meetingdocTrack');
        }   
        
        
        return null;
    }
    /*CR - 3763- End */
    /*CR - 3961- Start */
    public PageReference UpcmeetingdocVideo()
    {
        
        String eventtrack=Apexpages.currentPage().getParameters().get('eventtrack');
        for(AGN_AMI_Meeting_Doc__c mt : agnAMIMeetingDocList)
        {
            if(mt.Id == eventtrack)
            {
                selectedContent = mt;
                break;
            }
        }
        return null;
    }
    /*CR - 3961- End */
}