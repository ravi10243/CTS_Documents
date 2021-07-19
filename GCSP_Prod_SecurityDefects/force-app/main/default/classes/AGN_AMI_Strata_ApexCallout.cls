/**************************************************************************************************************************
@ Class:          AGN_AMI_Strata_ApexCallout
@ Version:        1.0
@ Author:         Cognizant
@ Purpose:        Invocalble class for Process Builder.
@ PMO:            CR-3658
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 

***************************************************************************************************************************/
global class AGN_AMI_Strata_ApexCallout {

  
  @InvocableMethod
   public static void groovyGeckoApexcallout(list<Medical_Event_vod__c> meeting) {
      //AGN_AMI_Strata_API_Callout.strataGetCallout(meeting[0].Id);
      System.enqueueJob(new RestApiCall(meeting));
   }
   
   public class RestApiCall implements System.Queueable, Database.AllowsCallouts {
   
            String  strataMeetingId=null;
            String  strataWebcastId =null; 
            String  presentationId =null;
            
            public RestApiCall(list<Medical_Event_vod__c> meetings){
                strataMeetingId= meetings[0].Id;
                strataWebcastId= meetings[0].Strata_Webcast_Id__c;
                presentationId = meetings[0].Strata_Presentation_Id__c;
            }
       
       public void execute(System.QueueableContext ctx) {
       
            getAttendeeRatings(strataMeetingId,strataWebcastId,presentationId);

        }
    
    
    }
    
       webservice static String getAttendeeRatings(String strataMeetingId, String strataWebcastId, String presentationId){
    
           String status=null;
           
           Medical_Event_vod__c meetingRecord = new Medical_Event_vod__c(id=strataMeetingId);
           try{
           //https://groovygecko-api.eckoenterprise-staging.net/api/admin/webcasts/webCastId/presentations/presentationId/statistics/attendees?required=veevaId&with=survey.feedback&return=veevaId,survey.rating
           AMI_Strata_Integration_credentials__c strataCreds = AMI_Strata_Integration_credentials__c.getInstance('Groovygecko');
           
           String endPoint = strataCreds.API_Endpoint__c.replace('webCastId', strataWebcastId).replace('presentationId',presentationId);
            //System.debug('strataendPoint -----------------'+endPoint );
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            request.setMethod('GET');
            // CR-3979- Read Timeout issue fix
            request.setTimeout(120000);
            request.setHeader('Content-Type','application/json');
            request.setHeader('X-Authorization',strataCreds.Authentication_Token__c);
            HttpResponse response = http.send(request);
            System.Debug('response---'+response);
            // If the request is successful, parse the JSON response.
            
            if (response.getStatusCode() == 200) {

                  String retBody=  response.getBody(); 
                  //String retBody= '[{"veevaId":"2233","survey_rating":3},{"veevaId":"0011j00000q1VbLAAU","survey_rating":5},{"veevaId":"1234","survey_rating":3}]';
                  System.debug('Grrovygeko response=====' + response.getBody());
                  System.debug('Finall response========' +AGN_AMI_Strata_API_Callout_Wrapper.parse(retBody));
                  List<AGN_AMI_Strata_API_Callout_Wrapper> listOfStrataRespose=AGN_AMI_Strata_API_Callout_Wrapper.parse(retBody);
                  if(listOfStrataRespose.size() > 0)
                  {
                    meetingRecord.AMI_Strata_Callout_Status__c = 'API Callout Sucess' + ':' +response.getStatusCode();
                    status= String.valueOf(response.getStatusCode());
                  }else{
                    meetingRecord.AMI_Strata_Callout_Status__c = 'No Result Return';
                    status= 'No Result Return';
                  }
                  Map<String,String> ratingMap= new Map<String,String>();
                  
                  for(AGN_AMI_Strata_API_Callout_Wrapper strataWrapper:listOfStrataRespose){
                       ratingMap.put(strataWrapper.veevaId,strataWrapper.survey_rating);
                  }
                  List<Event_Attendee_vod__c> eventAttendeelist= [select Account_vod__c,AMI_Attendee_Status_AGN__c,AGN_AMI_Post_Event_Rating__c from Event_Attendee_vod__c where Account_vod__c=:ratingMap.keySet() and Medical_Event_vod__c=:strataMeetingId];
                   
                   for(Event_Attendee_vod__c eventAttendee :eventAttendeelist)
                      {
                           if(ratingMap.containsKey(eventAttendee.Account_vod__c))
                             {
                                     eventAttendee.Status_vod__c= AGN_AMI_Static_Labels.attendeeStatusAttended;
                                     eventAttendee.AGN_AMI_Post_Event_Rating__c= ratingMap.get(eventAttendee.Account_vod__c);
                              }
                           
                             /**for(AGN_AMI_Strata_API_Callout_Wrapper strataWrapper:listOfStrataRespose){
                                if(eventAttendee.Account_vod__c == strataWrapper.veevaId)
                                  {
                                     eventAttendee.Status_vod__c='Attended';
                                     eventAttendee.AGN_AMI_Post_Event_Rating__c= strataWrapper.survey_rating;
                                  }
                              
                           }*/
                      }
                        update eventAttendeelist;
      
               } else if(response.getStatusCode() == 412){
                   Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                   String errorMessage= (String) results.get('error');
                   meetingRecord.AMI_Strata_Callout_Status__c = errorMessage + ':' +response.getStatusCode();
                   System.debug('errorMessage ===================='+errorMessage);
                   status= String.valueOf(errorMessage);
                }else if(response.getStatusCode() == 400){
                   Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                   String errorMessage= (String) results.get('message');
                    meetingRecord.AMI_Strata_Callout_Status__c = errorMessage + ':' +response.getStatusCode();
                   status= String.valueOf(errorMessage);
                }else {
                   meetingRecord.AMI_Strata_Callout_Status__c = response.getStatus() + ':' +response.getStatusCode();
                   status= String.valueOf(response.getStatusCode());
                }
              
                update meetingRecord;
                }catch (Exception ex){
                    System.debug('Error: update Strata Callout : Error' + ex);
                    AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Strata_ApexCallout','groovyGeckoApexcallout');  
                }
                
                return status;
       }
       
       

}