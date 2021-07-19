// This class is created as the Controller class of the Visualforce Page - AGN_AMI_SC_AVT_Webpage
// Author - Cognizant
// Created Date - 03/08/2020
// Last Modified By - Cognizant

public without sharing class AGN_AMI_SC_AVT_Webpage_Controller {
    
    public String userLanguage {get;set;}
    Public Medical_Event_vod__c meetingRecord {get; set;}
    Public User user {get; set;}
    
    public AGN_AMI_SC_AVT_Webpage_Controller()
    {
        
	   //Retrieve event details	
		//Medical_Event_vod__c meetingRecord;
		AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();
        userLanguage = userDetails.userLanguage;
        user =  userDetails.user;
        
        String eventId= ApexPages.currentPage().getParameters().get('eventId');
        system.debug('eventId-->'+eventId);
       try
       {
        if(String.isNotBlank(eventId)){
        meetingRecord = [Select Event_Broadcast_Link_AGN__c from Medical_Event_vod__c where Id =: eventId WITH SECURITY_ENFORCED Limit 1];
          
        }
       }catch( System.QueryException ee) {
          System.debug('You dont have access to all Meeting fields');
      }
        
    }   

}