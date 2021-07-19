public class AGN_AMI_MeetingLayout_Controller 
{
    public Medical_Event_vod__c meeting {get; set;}
    public boolean showBanner {get; set;}
    public AGN_AMI_MeetingLayout_Controller(ApexPages.StandardController controller) 
    {
        meeting = [Select Id, Event_Broadcast_Link_AGN__c, AMI_Event_Delivery_Type_AGN__c 
                     from Medical_Event_vod__c 
                     where id = :ApexPages.currentPage().getParameters().get('id')];
        showBanner = (meeting.AMI_Event_Delivery_Type_AGN__c == 'Live Stream') && (String.isBlank(meeting.Event_Broadcast_Link_AGN__c));
    }
}