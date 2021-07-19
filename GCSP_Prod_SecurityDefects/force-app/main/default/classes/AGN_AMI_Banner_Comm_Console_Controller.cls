/**************************************************************************************************************************
@ Class:          AGN_AMI_Banner_Comm_Console_Controller 
@ Version:        1.0
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
@ Purpose:        Controller class for AGN_AMI_Banner_Communication_Console vf page.
@ PMO:            CR-3141: Console to manage communication in one store.
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 29.04.2020 / JOYDEV MONDOL / Created the class.
***************************************************************************************************************************/

public without sharing class AGN_AMI_Banner_Comm_Console_Controller {

    //Wrapper class for meeting records
    public class Meeting {
        
        public Boolean              Selected { get; set; }    //is selected in ui
        public Boolean              OnAir    { get; set; }    //live now flag
        public Medical_Event_vod__c Meeting  { get; set; }    //actual event    
        
        //basic constructor o initialise member
        public Meeting(Medical_Event_vod__c meeting, Boolean onAir) {
            this.Meeting  = meeting;
            this.OnAir    = onAir;
            this.Selected = false;
        }
    }
    
    /*Constants*/
    static final String PLANNED    = 'Planned';                  //event status - planned
    static final String LIVE       = 'Live';                     //event status - live
    static final String BOTH       = 'Both';                     //filter - both
    static final String EVENTAPI   = 'Medical_Event_vod__c';     //Event object api name
    static final String RECTYPEDEV = 'AMI_Portal_Event_AGN';     //event ami portal record type developer name
        
    /*Properties*/
    public List<Medical_Event_vod__c> SelectedMeetings { get; set; }    //selected meetings for bulk updates
    public Medical_Event_vod__c       BlankMeeting     { get; set; }    //Placeholder for inputs 
    public Map<Id, Meeting>           Meetings         { get; set; }    //map of event wrapper objects
    public List<Id>                   OrderedMeetings  { get; set; }    //Ordered list of meeting ids
    public String                     CurrentFilter    { get; set; }    //current filters
    public Boolean                    SelectAll        { get; set; }    //is all selected in ui
    public String                     SelectedId       { get; set; }    //selected id of the current row checked in ui
    public Boolean                    BulkAction       { get; set; }    //bulk action switch
    
    /*Global variables*/
    public Id       RecordTypeId;    //ami portal event record type id
    public String[] Filter;          //Status filters    
    
    /**********************************************************************************************************************
    @ Constructor:    AGN_AMI_Banner_Comm_Console_Controller 
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        Initialises the class members.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the constructor.
    ***********************************************************************************************************************/
    public AGN_AMI_Banner_Comm_Console_Controller() { 
        
        BlankMeeting  = new Medical_Event_vod__c();  
         
        fetchRecordTypeId();  
        filterByAll();
    }
    
    /***********************************************************************************************************************
    @ Method:         fetchRecordTypeId
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        fetches the ami portal event record type id and sets the property
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void fetchRecordTypeId() {
        RecordTypeId = [SELECT Id 
                          FROM RecordType 
                         WHERE SObjectType = :EVENTAPI AND 
                               DeveloperName = :RECTYPEDEV].Id;
    }
    
    /***********************************************************************************************************************
    @ Method:         fetchMeetings
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        fetches the meetings and resets the property
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void fetchMeetings() {
        
        DateTime nowF   = System.now();           //this moment
        DateTime startF = System.today();         //date filter range start
        DateTime endF   = startF.addHours(48);    //startF.addDays(3);    //date filter range end
        
        Meetings        = new Map<Id, Meeting>(); //get meeting records and populate property
        OrderedMeetings = new List<Id>();         //set the meeting ids in order of date asc
        
        //query all ami portal events in live status filtered by events live today and scheduled for next 48 hours
        for(Medical_Event_vod__c meeting : [SELECT   Id, Name, ShowMessage__c, EventMessageR__c, 
                                                     Start_Time_vod__c, End_Time_vod__c, 
                                                     AMI_Event_Status_AGN__c, Country_AGN__c, Country_AGN__r.Name
                                              FROM   Medical_Event_vod__c
                                             WHERE   RecordTypeId = :RecordTypeId AND
                                                     AMI_Event_Status_AGN__c IN:Filter AND
                                                     (
                                                       /*scheduled within filter range*/
                                                       ( Start_Time_vod__c >= :startF AND Start_Time_vod__c <= :endF ) OR
                                                       /*on going events*/
                                                       ( Start_Time_vod__c <= :nowF   AND End_Time_vod__c   >= :nowF )
                                                     )
                                            ORDER BY Start_Time_vod__c ASC]) {
                                                   
            Boolean onAir = (meeting.Start_Time_vod__c <= nowF && meeting.End_Time_vod__c >= nowF ? true : false);
            Meetings.put(meeting.Id, new Meeting(meeting, onAir));      
            OrderedMeetings.add(meeting.Id);                     
        }
        
        //reset selections
        SelectAll = false;
    }
    
    /***********************************************************************************************************************
    @ Method:         withdrawMessages
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        Saves meetings with ShowMessage__c = false
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void displayMessages() {        
        saveChanges(true);
    }
    
    /***********************************************************************************************************************
    @ Method:         displayMessages
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        Saves meetings with ShowMessage__c = true
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void withdrawMessages() {        
        saveChanges(false);
    }
    
    /***********************************************************************************************************************
    @ Method:         saveChanges
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        Saves meetings
    @ Param:          display - value to set in ShowMessage__c for the selected meetings
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void saveChanges(Boolean display) {        
        List<Medical_Event_vod__c> changedMeetings = new List<Medical_Event_vod__c>();
        
        for(Meeting meeting : Meetings.values()) {  
            if(meeting.Selected) {
                meeting.Meeting.ShowMessage__c = display;          
                changedMeetings.add(meeting.Meeting);
            }
        }
        
        if(changedMeetings.size() > 0) {
            update changedMeetings;
        }
        
        fetchMeetings();
    }
    
    /***********************************************************************************************************************
    @ Method:         checkAll
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        Called from action function to select all rows
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void checkAll() {
    
        //toggle selection
        if(SelectAll) { 
            selectAll(); 
        } else { 
            deselectAll(); 
        }
    }
    
    /***********************************************************************************************************************
    @ Method:         selectAll
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        selects all the events in the master map
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void selectAll() {
        for(Meeting meeting : Meetings.values()) {
            meeting.Selected = true;
        }
    }
    
    /***********************************************************************************************************************
    @ Method:         deselectAll
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        deselects all the events in the master map
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void deselectAll() {
        for(Meeting meeting : Meetings.values()) {
            meeting.Selected = false;
        }
    }
    
    /***********************************************************************************************************************
    @ Method:         checkMeeting
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        selects a the events in the master map
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void checkMeeting() { 
        Meetings.get(SelectedId).Selected = !Meetings.get(SelectedId).Selected;
    }
    
    /***********************************************************************************************************************
    @ Method:         showBulkAction
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        switches the flag to go to bulk action mode in ui and extracts the selected events to work upon
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void showBulkAction() {
        BulkAction = true;
        scanSelection();
    }
    
    /***********************************************************************************************************************
    @ Method:         scanSelection
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        extracts all events that are selected
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void scanSelection() {
        SelectedMeetings = new List<Medical_Event_vod__c>();
        
        for(Meeting meeting : Meetings.values()) {
            if(meeting.Selected) { 
                SelectedMeetings.add(meeting.Meeting); 
            }
        }
    }
    
    /***********************************************************************************************************************
    @ Method:         displayBulkMessages
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        updates the selected meetings with set message and show message = true
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void displayBulkMessages() {
        saveBulkChanges(true);        
    }
    
    /***********************************************************************************************************************
    @ Method:         saveBulkChanges
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        updates the changes done in bulk module and goes back to list mode in ui
    @ Param:          display - value to set in ShowMessage__c of selected meetings
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void saveBulkChanges(Boolean display) {
        for(Medical_Event_vod__c meeting : SelectedMeetings) {
            meeting.ShowMessage__c = display;
            meeting.EventMessageR__c = BlankMeeting.EventMessageR__c;
        }
        
        if(SelectedMeetings.size() > 0) {
            update SelectedMeetings;
        }
        
        BulkAction = false;        
    }
    
    /***********************************************************************************************************************
    @ Method:         saveMessages
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        updates the changes done in list view irrespective of show message status
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void saveMessages() {
        List<Medical_Event_vod__c> changedMeetings = new List<Medical_Event_vod__c>();
        
        for(Meeting meeting : Meetings.values()) {  
            changedMeetings.add(meeting.Meeting);
        }
        
        if(changedMeetings.size() > 0) {
            update changedMeetings;
        }
        
        fetchMeetings();
    }
    
    /***********************************************************************************************************************
    @ Method:         cancelBulkChanges
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        discards the bulk selection and/or changes
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void cancelBulkChanges() {
        scanSelection();        
        BulkAction = false; 
    }
    
    /***********************************************************************************************************************
    @ Method:         filterByAll
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        sets the filter options by both planned and live status and makes the query
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void filterByAll() {
        Filter = new String[] {/*PLANNED, */LIVE};
        CurrentFilter = BOTH;        
        fetchMeetings();
    }

    /***********************************************************************************************************************
    @ Method:         filterByLive
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        sets the filter option by live status only and makes the query
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    /* DEPRECATED but might be used in future
    public void filterByLive() {
        Filter = new String[] {LIVE};
        CurrentFilter = LIVE;
        fetchMeetings();
    }
    */

    /***********************************************************************************************************************
    @ Method:         filterByPlanned
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        sets the filter option by planned status only and makes the query
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    /* DEPRECATED but might be used in future
    public void filterByPlanned() {
        Filter = new String[] {PLANNED};
        CurrentFilter = PLANNED;
        fetchMeetings();
    }
    */
    
    /***********************************************************************************************************************
    @ Method:         cancelChanges
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        reloads the page witout saving changes in the meetings
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    /* DEPRECATED but might be used in future
    public void cancelChanges() {
        fetchMeetings();
    }
    */
    
    /***********************************************************************************************************************
    @ Method:         withdrawBulkMessages
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        updates the selected meetings with set message and show message = true
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 29.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    /* DEPRECATED but might be used in future
    public void withdrawBulkMessages() {
        saveBulkChanges(false);        
    }
    */
}