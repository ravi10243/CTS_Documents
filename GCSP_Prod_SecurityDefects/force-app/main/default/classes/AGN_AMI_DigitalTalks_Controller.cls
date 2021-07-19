/**************************************************************************************************************************
@ Class:          AGN_AMI_DigitalTalks_Controller 
@ Version:        1.0
@ Author:         Sujan Guha (sujan.guha@cognizant.com) 
@ Purpose:        This is Controller class for AGN_AMI_DigitalTalks_Page
@ PMO:            CR-3439: Digital Talks
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.08.2020 / Sujan Guha / Created the class.
***************************************************************************************************************************/

public class AGN_AMI_DigitalTalks_Controller {
    
    /** Constants **/
    private Static String RecordString='Recorded'; 
    private Static String PlannedString='Planned';
    private Static String RequestString='request';
	private Static String EventId='eventId';
    
	/** Properties **/
    public String userLanguage {get; set;}
    public String userCountryName {get;set;} 
    public list<AGN_AMI_Meeting_Details_Wrapper> digiTalksmeetings {get; set;}
    public List<AGN_AMI_Meeting_Details_Wrapper> fullMeetings {get; set;}
    public AGN_AMI_Meeting_Details_Wrapper firstMeeting {get; set;}
    public integer digitalCount {get; set;}
    public String clickedEvent {get; set;}
    public String clickedAction {get; set;}
    public String facultyName {get; set;}
    public String searchString {get; set;}
    public String searchStart {get; set;}
    public String searchEnd {get; set;}
    
    
    /** Variables **/
	List<Medical_Event_vod__c> allAvailableMeetings;
    List<Id> allMeetingsId;
    User user;
    Account accountRecord; 
    List<AGN_AMI_Meeting_Details_Wrapper> finalDigiTalksmeetings;
    
    /**********************************************************************************************************************
    @ Constructor:    AGN_AMI_DigitalTalks_Controller 
    @ Version:        1.0
    @ Author:         Sujan Guha (sujan.guha@cognizant.com)
    @ Purpose:        Initialises the class members.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.08.2020 / Sujan Guha / Created the constructor
    ***********************************************************************************************************************/    
    
    public AGN_AMI_DigitalTalks_Controller(){
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        digiTalksmeetings=new list<AGN_AMI_Meeting_Details_Wrapper>();
        fullMeetings = new List<AGN_AMI_Meeting_Details_Wrapper>();
        finalDigiTalksmeetings=new List<AGN_AMI_Meeting_Details_Wrapper>();
        user =  userDetails.user;
        accountRecord = userDetails.accountRecord;
        allMeetingsId = new List<Id>();
        String meetingRecordTypeId  = Schema.SObjectType.Medical_Event_vod__c.getRecordTypeInfosByName().get(Label.AGN_AMI_Digital_Talks_Record_Type).getRecordTypeId();
        allAvailableMeetings = AGN_AMI_SC_Event_Util_Class.getAllEvents(userCountryName, meetingRecordTypeId,AGN_AMI_SC_Static_Labels.medicalAesthetics);
        for(Medical_Event_vod__c me : allAvailableMeetings)
        {
            allMeetingsId.add(me.Id);
        }
        
        List<Meeting_Speaker_AGN__c> speakerList = [Select AMI_Faculty_AGN__r.Name_AGN__c,meeting_AGN__c
                                                    from Meeting_Speaker_AGN__c 
                                                    where Meeting_AGN__c in: allMeetingsId
                                                    and AMI_Primary_Speaker_AGN__c = true Order By LastModifiedDate Asc ];
        Map<Id, String> facultyNameMap = new Map<Id, String>();
        for(Meeting_Speaker_AGN__c ms : speakerList) {
            facultyNameMap.put(ms.meeting_AGN__c, ms.AMI_Faculty_AGN__r.Name_AGN__c);
        }
        
        for(Medical_Event_vod__c meeting : allAvailableMeetings)
        {

            if(meeting.AMI_Event_Type_AGN__c == AGN_AMI_Static_Labels.meetingTypePublic) // || (invitedMeetingId.contains(meeting.Id)) || invitationFlag)
            {
                integer flag = 0;
                
                facultyName = (facultyNameMap.keySet().contains(meeting.Id))?facultyNameMap.get(meeting.Id):'';
                
                if( meeting.AMI_Event_Status_AGN__c == RecordString || meeting.AMI_Event_Status_AGN__c == PlannedString)
                {
                    digiTalksmeetings.add(new AGN_AMI_Meeting_Details_Wrapper(meeting,false,facultyName));

                }
                
            }
        }
        //Reversing the order of the Events from most recent
         for(Integer i = digiTalksmeetings.size()-1; i>=0;i--) 
        {
            finalDigiTalksmeetings.add(digiTalksmeetings.get(i));
        }
        digiTalksmeetings.clear();
        digiTalksmeetings.addAll(finalDigiTalksmeetings);
        
        digitalCount=digiTalksmeetings.size();
        if(digitalCount >0){
            firstMeeting = digiTalksmeetings[0];
        }
        fullMeetings.addAll(digiTalksmeetings);
        
    }

    /***********************************************************************************************************************
    @ Method:         redirectToEvent
    @ Version:        1.0
    @ Author:         Sujan Guha (sujan.guha@cognizant.com)
    @ Purpose:        This method redirects to the Digital Talks Detail Page,  It is a dynamic function which redirects to 
					  Digital Talks Detail Page of the Particular Event with proper requests like - view, play. 
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.08.2020 / Sujan Guha / Created the method.
    ***********************************************************************************************************************/

    public PageReference redirectToEvent()
    {
        PageReference pr = new PageReference(Label.AGN_AMI_Digital_Talks_Detail_Page);
        pr.setRedirect(true);
        pr.getParameters().put(EventId,clickedEvent);
        pr.getParameters().put(RequestString,clickedAction);
        return pr;
    }
    
    /***********************************************************************************************************************
    @ Method:         searchEvents
    @ Version:        1.0
    @ Author:         Sujan Guha (sujan.guha@cognizant.com)
    @ Purpose:        This method filters out the available events in accordance with the conditions selected in the page.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.08.2020 / Sujan Guha / Created the method.
    ***********************************************************************************************************************/    
    
    public PageReference searchEvents()
    {
        digiTalksmeetings.clear();
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
            endDate = datetime.newInstance(Integer.valueOf(endList[2]),Integer.valueOf(endList[1]),Integer.valueOf(endList[0])+1);
        }
        
        for(AGN_AMI_Meeting_Details_Wrapper mdw : fullMeetings)
            
        {
            
            
            if(!String.isBlank(searchString) && mdw.meeting.Name.containsIgnoreCase(searchString) && mdw.meeting.Start_Time_vod__c > startDate && mdw.meeting.End_Time_vod__c <= endDate)
            {
                digiTalksmeetings.add(mdw);
            }
            else if(String.isBlank(searchString) && mdw.meeting.Start_Time_vod__c > startDate && mdw.meeting.End_Time_vod__c <= endDate)
            {
                digiTalksmeetings.add(mdw);
            }
        }
        
        return null;
    } 
    
}