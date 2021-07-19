public with sharing class AGN_OpportunityRollUpOnMeeting{
    Set<Id> meetingIds = new Set<Id>();
    List<Medical_Event_vod__c> meetingsToUpdate = new List<Medical_Event_vod__c>();
     
    public void OppRollMeetings(List<opportunity> opplist){
        
        for (Opportunity opp : opplist){
                meetingIds.add(opp.Meeting_AGN__c);
            system.debug('---opp'+opp);}
            // get a map of the meetings with the number of opportunities
            Map<Id,Medical_Event_vod__c> meetingMap = new Map<Id,Medical_Event_vod__c>([SELECT Id, NumberOfOpportunities_AGN__c FROM Medical_Event_vod__c WHERE Id IN :meetingIds]);
            Map<Id,AggregateResult> opportunityAmountMap = new Map<Id,AggregateResult>([SELECT Meeting_AGN__r.Id, SUM(Total_Amount_AGN__c) totalAmount FROM Opportunity WHERE Meeting_AGN__c != NULL AND Meeting_AGN__c IN :meetingIds GROUP BY Meeting_AGN__r.Id]);

            // query the meetings and the related opportunities and add the total no. of opportunities to the meeting
            for (Medical_Event_vod__c meeting : [select Id, Name, NumberOfOpportunities_AGN__c, AmountAllOpportunities_AGN__c, (SELECT Id from Opportunities__r) FROM Medical_Event_vod__c WHERE Id IN :meetingIds]) {
                 
                meetingMap.get(meeting.Id).NumberOfOpportunities_AGN__c = meeting.Opportunities__r !=null?meeting.Opportunities__r.size():0;               
                meetingMap.get(meeting.Id).AmountAllOpportunities_AGN__c = opportunityAmountMap.containsKey(meeting.Id)?(Double)opportunityAmountMap.get(meeting.Id).get('totalAmount'):0;
              
                // add the value in the map to a list to update it
                meetingsToUpdate.add(meetingMap.get(meeting.Id));
                    
            }
            system.debug('----------++++' + meetingsToUpdate);
        update meetingsToUpdate;
    }
}