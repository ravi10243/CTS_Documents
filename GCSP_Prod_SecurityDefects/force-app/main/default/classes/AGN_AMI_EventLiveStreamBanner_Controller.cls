/**************************************************************************************************************************
@ Class:          AGN_AMI_EventLiveStreamBanner_Controller
@ Version:        1.0
@ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
@ Purpose:        Controller class for AGN_AMI_Event_Live_Stream_Banner vf component.
@ PMO:            CR-3141: Banner to communicate live stream events issues
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 24.04.2020 / JOYDEV MONDOL / Created the class.
***************************************************************************************************************************/

public class AGN_AMI_EventLiveStreamBanner_Controller {

    /*Constants*/
    static final String EVENTID = ApexPages.currentPage().getParameters().get('eventId');  //Current event id
    static final String LIVE_STREAMING = 'Live Streaming';                                 //custom setting record name
    
    /*Properties*/
    //current meeting record
    public Medical_Event_vod__c Meeting { get; set; }    
    
    //action poller switch
    public Boolean PushMessage {                        
        get { 
            return AMIPortalPushNotification__c.getInstance(LIVE_STREAMING).Enabled__c; 
        }    
    }
    
    //current language
    public String  Language {                        
        get { 
            return UserInfo.getLanguage(); 
        }    
    }
    
    /**********************************************************************************************************************
    @ Constructor:    AGN_AMI_EventLiveStreamBanner_Controller
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        Initialises the class.
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 24.04.2020 / JOYDEV MONDOL / Created the constructor.
    ***********************************************************************************************************************/
    public AGN_AMI_EventLiveStreamBanner_Controller() {        
        pollEventMessage();
    }
    
    /***********************************************************************************************************************
    @ Method:         pollEventMessage
    @ Version:        1.0
    @ Author:         JOYDEV MONDOL (joydev.mondol@cognizant.com)
    @ Purpose:        Queries the admin message and the show/hide status from the current Meeting object 
                      (polled by actionPoller in UI)
    @ PMO:            CR-3141: Banner to communicate live stream events issues
    -----------------------------------------------------------------------------------------------------------------------
    @ Change history: 24.04.2020 / JOYDEV MONDOL / Created the method.
    ***********************************************************************************************************************/
    public void pollEventMessage() {        
        //Refresh current record
        Meeting = [SELECT ShowMessage__c, EventMessageR__c
                   FROM   Medical_Event_vod__c 
                   WHERE  Id=:EVENTID]; 
    }
}