/**************************************************************************************************************************
@ Class:          AGN_AMI_DigitalTalks_Details_Controller 
@ Version:        1.0
@ Author:         Sujan Guha (sujan.guha@cognizant.com) 
@ Purpose:        This is Controller class for AGN_AMI_DigitalTalks_Detail_Page
@ PMO:            CR-3439: Digital Talks
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 05.08.2020 / Sujan Guha / Created the class.
***************************************************************************************************************************/
public without sharing class AGN_AMI_DigitalTalks_Details_Controller {
  
    /** Constants **/
    
    private Static String RequestString='request';
    private Static String PlayString='play';
  private Static String EventId='eventId';
    Private static String TimeFormat='HH:mm';
    Private Static String Digital='Digital Talks';
    /** Properties **/
    
  public List<AGN_AMI_Meeting_Doc__c> agnAMIMeetingDocList {get; set;}
    public User user {get; set;} 
    public String userCountryName {get;set;}
    public String userLanguage {get; set;}
    public AGN_AMI_Meeting_Details_Wrapper event {get; set;}
    public List<Meeting_Speaker_AGN__c> speakerList {get;set;}
    public Boolean playerOpen {get; set;}
    public String request {get; set;}
    //public List<AgendaWrapper> agendaWrapperList {get; set;}
    public Meeting_Speaker_AGN__c selectedFaculty {get; set;}
    public String clickedFaculty {get; set;}
    public boolean speakerExist {get; set;}
    Public  String DigiTalks{get; set;}
    public AGN_AMI_Meeting_Doc__c selectedcontent{get; set;}
    /* CR - 3961 chnages -Start */
    public String clickedvideo {get; set;}
    public AGN_AMI_Meeting_Doc__c selectedvideo{get; set;}
    /* CR - 3961 chnages -End */
    /** Variables **/
    Medical_Event_vod__c meetingRecord;
    Account accountRecord;
    Contact contactRecord;
    
    /**********************************************************************************************************************
    @ Constructor:    AGN_AMI_DigitalTalks_Details_Controller 
    @ Version:        1.0
    @ Author:         Sujan Guha (sujan.guha@cognizant.com)
    @ Purpose:        Initialises the class members.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.08.2020 / Sujan Guha / Created the constructor
    ***********************************************************************************************************************/
    
    public AGN_AMI_DigitalTalks_Details_Controller(){
      
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        accountRecord = userDetails.accountRecord;
        contactRecord = userDetails.contactRecord;
        String eventId= ApexPages.currentPage().getParameters().get(EventId);
        if(eventId != null) {
            if(Schema.sObjectType.Medical_Event_vod__c.isAccessible()){
                meetingRecord = [Select Id, Name, Description_vod__c, Country_code__c, toLabel(AMI_Event_Delivery_Type_AGN__c), Banner_Total_Time_Duration_AGN__c,Detail_Page_Image_AGN__c,
                                 Start_Time_vod__c, End_Time_vod__c, AMI_Event_Status_AGN__c,Location__c, Detail_Page_Video_AGN__c,Building_Name_AGN__c,
                                 Event_Broadcast_Link_AGN__c, Live_Event_Description_AGN__c, Past_Event_Description_AGN__c,Location_Description_AGN__c,Time_Duration_AGN__c 
                                 from Medical_Event_vod__c 
                                 where Id =: eventId Limit 1];
            }
            
            if(Schema.sObjectType.Meeting_Speaker_AGN__c.isAccessible()){
                speakerList = [Select Id,AMI_Faculty_AGN__r.id, AMI_Faculty_AGN__r.Name, 
                               AMI_Faculty_AGN__r.AMI_Specialty_AGN__r.Name_AGN__c, AMI_Faculty_AGN__r.Hospital_AGN__c,
                               AMI_Faculty_AGN__r.Image_URL_AGN__c, AMI_Faculty_AGN__r.Country_AGN__c, 
                               AMI_Faculty_AGN__r.Name_AGN__c, AMI_Faculty_AGN__r.Title_AGN__c, 
                               AMI_Faculty_AGN__r.email_AGN__c,AMI_Primary_Speaker_AGN__c
                               from Meeting_Speaker_AGN__c 
                               where Meeting_AGN__c =: meetingRecord.Id Order By LastModifiedDate Asc];
            }
            /*render if speakeer list is more than 1 */
            if (speakerList.size()>1)
            {
                speakerExist=true;   
            }
            else
            {
                speakerExist=false;
            }
            
            //agendaWrapperList = new List<AgendaWrapper>();
            
            String FacultyName = '';
            if(speakerList.size()>0)
            {
                selectedFaculty = speakerList[0];
                for(Meeting_Speaker_AGN__c MS : speakerList)
                {
                    if(MS.AMI_Primary_Speaker_AGN__c) {
                        FacultyName = MS.AMI_Faculty_AGN__r.Name_AGN__c; 
                    }
                }
            }
            event = new AGN_AMI_Meeting_Details_Wrapper(meetingRecord,false,FacultyName);
            
            if(Schema.sObjectType.AGN_AMI_Meeting_Doc__c.isAccessible()){
                agnAMIMeetingDocList = [select Name, Link_AGN__c,AGN_AMI_Document_Section__c from AGN_AMI_Meeting_Doc__c
                                        where Meeting_AGN__c =: event.meeting.Id order by Meeting_Sequence_AGN__c];
                
            }
            request = ApexPages.currentPage().getParameters().get(RequestString);
            if(request == PlayString){
                playerOpen = true;
            }
            
            DigiTalks=Digital;
        }
        
    }
    
  /**************************************************************************************************************************
  @ Class:          AgendaWrapper 
  @ Version:        1.0
  @ Author:         Sujan Guha (sujan.guha@cognizant.com) 
  @ Purpose:        This is wrapper class for AMI Event Agenda
  @ PMO:            CR-3439: Digital talks
  ---------------------------------------------------------------------------------------------------------------------------
  @ Change history: 05.08.2020 / Sujan Guha / Created the class.
  ***************************************************************************************************************************/   
    /*public Class AgendaWrapper
    {
        public AMI_Event_Agenda_AGN__c agenda {get; set;}
        public String formattedTime {get; set;}
        public agendaWrapper(AMI_Event_Agenda_AGN__c agenda)
        {
            String tz = UserInfo.getTimeZone().toString();
            this.agenda = agenda;
            formattedTime = agenda.Start_Time_AGN__c.format(TimeFormat, tz) + ' - ' + agenda.End_Time_AGN__c.format(TimeFormat, tz);
        }
    }*/
    
    /***********************************************************************************************************************
    @ Method:         changeSelectFaculty
    @ Version:        1.0
    @ Author:         Sujan Guha (sujan.guha@cognizant.com)
    @ Purpose:        This method refreshes the highlighted faculty in the page.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 05.08.2020 / Sujan Guha / Created the method.
    ***********************************************************************************************************************/    

    public PageReference changeSelectFaculty()
    {
        for(Meeting_Speaker_AGN__c ms : speakerList)
        {
            if(ms.Id == clickedFaculty) {
                selectedFaculty = ms; 
            }
        }
        return null;
    }
    /*CR - 3763- Start */
    public PageReference meetingdocTrack()
    {
       string eventtrack;
       if(Apexpages.currentPage().getParameters().get('eventtrack')!=null){
            eventtrack=Apexpages.currentPage().getParameters().get('eventtrack');
       }
       for(AGN_AMI_Meeting_Doc__c ms : agnAMIMeetingDocList)
        {
            if(ms.Id == clickedvideo) {
                selectedvideo = ms; 
            }
            else if(ms.Id==eventtrack){
                selectedvideo=ms;
            }
        }
         
        try{
            system.debug('Account'+accountRecord.id);
            system.debug('Account'+accountRecord.id);
            list<AMI_Trend_Tracking_AGN__c> trackList=[select id,AMI_HCP_Name_AGN__c,AMI_Number_of_Views_AGN__c from AMI_Trend_Tracking_AGN__c where AMI_HCP_Name_AGN__c=:accountRecord.id and AMI_Meeting_Document_Track_AGN__c=:selectedvideo.ID];
            if(trackList !=null && !trackList.isEmpty()){
                trackList[0].AMI_Number_of_Views_AGN__c=trackList[0].AMI_Number_of_Views_AGN__c+1;
                trackList[0].AMI_Last_view_Date_Time_AGN__c=datetime.now();
                update Tracklist;
                 system.debug('third');
            }
            
            else{
                trackList.add(new AMI_Trend_Tracking_AGN__c(AMI_HCP_Name_AGN__c=accountRecord.id,
                                                                 AMI_Number_of_Views_AGN__c=1,
                                                                 AMI_Meeting_Document_Track_AGN__c=selectedvideo.id,
                                                                 AMI_Last_view_Date_Time_AGN__c=datetime.now(),
                                                                 RecordTypeId=schema.SObjectType.AMI_Trend_Tracking_AGN__c.getRecordTypeinfosByName().get('AMI Meeting Document Track').getRecordTypeId()));
                
                insert trackList;
                 system.debug('forth');
            }
            list<AMI_Trend_Tracking_Item_AGN__c> apdtList=new list<AMI_Trend_Tracking_Item_AGN__c>();
            if(trackList !=null && !trackList.isEmpty()){
                apdtList.add(new AMI_Trend_Tracking_Item_AGN__c(AMI_HCP_Name_AGN__c=accountRecord.id,
                                                               AMI_view_Date_Time_AGN__c=datetime.now(),
                                                               AMI_Meeting_Document_Name_AGN__c=selectedvideo.id,
                                                               AMI_Portal_Tracking_Name_AGN__c=Tracklist[0].id));
                insert apdtList;
            }
             system.debug('fifth');
        }catch(Exception ex){
            system.debug('Exception : '+ex.getMessage());
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_DigitalTalks_Details_Controller','meetingdocTrack');
        }   
        
        
        return null;
    }
    /*CR - 3763- End */
    /* CR - 3961 chnages -start */
    public PageReference changeselectvideo()
    {
        for(AGN_AMI_Meeting_Doc__c ms : agnAMIMeetingDocList)
        {
            if(ms.Id == clickedvideo) {
                selectedvideo = ms; 
            }
        }
        return null;
    }
    /* CR - 3961 chnages -End */
    
}