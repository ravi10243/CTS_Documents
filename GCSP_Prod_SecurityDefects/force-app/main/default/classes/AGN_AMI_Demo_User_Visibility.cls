/**
  
 This class will pull the demo user and add to the Event
  PMO#3242.
*/
public class AGN_AMI_Demo_User_Visibility 
{
 @InvocableMethod(label='Add Attendee' description=' Add demo user to the event attendee List')
    public static void addDemoUsertoEvent(List<id> idList){
        
        try{
            
            List<Event_Attendee_Vod__c> demoAttendeeList = new List<Event_Attendee_Vod__c>();
            List<String> contactList= new List<String>();
            
            List<Medical_Event_vod__c> currentEventsRecord = [Select id, Country_Code__c from Medical_Event_vod__c where id in :idList and RecordType.DeveloperName ='AMI_Portal_Event_AGN'];
            // CR-3845 Strata event Demo user automatic addition fix. Extra condition- Add MA_User_Country_Code_AGN__c field in the filter creteria
            List<User> demoUserList = [Select contactId from User where (Country_Code__c =:currentEventsRecord[0].Country_Code__c or MA_User_Country_Code_AGN__c= :currentEventsRecord[0].Country_Code__c) and Is_AMI_Demo_User_AGN__c= true and Profile_Name_vod__c='AMI Customer Community' and IsActive = true];
            for(user usr:demoUserList)
            {   
               contactList.add(usr.contactId);
            }
           
            List<AccountContactRelation>  acrList= [Select AccountId, ContactId
                                                  from AccountContactRelation 
                                                  where ContactId IN:contactList 
                                                  and IsDirect = false
                                                  and Account.AGN_AMI_Enabled__c = true 
                                                  ];
           
           for(AccountContactRelation acr:acrList)
            {
                Id recordtypeid = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get('Portal Attendee').getRecordTypeId();
                Event_Attendee_Vod__c myeventattendee = new Event_Attendee_Vod__c();
                myeventattendee.Medical_Event_vod__c = currentEventsRecord[0].Id;
                myeventattendee.recordtypeid = recordtypeid;
                myeventattendee.Account_vod__c = acr.AccountId;
                myeventattendee.Status_vod__c= 'Accepted';
                demoAttendeeList.add(myeventattendee);
             }       
            //AMI_User_Settings_AGN__c userSetting = AMI_User_Settings_AGN__c.getInstance(currentEventsRecord[0].Country_Code__c ).xxxxxxx;
          /*  for(user usr:demoUserList)
            {
                Id recordtypeid = Schema.SObjectType.Event_Attendee_vod__c.getRecordTypeInfosByName().get('Portal Attendee').getRecordTypeId();
                Event_Attendee_Vod__c myeventattendee = new Event_Attendee_Vod__c();
                myeventattendee.Medical_Event_vod__c = currentEventsRecord[0].Id;
                myeventattendee.recordtypeid = recordtypeid;
                myeventattendee.Account_vod__c = usr.Contact.Account.Id;
                myeventattendee.Status_vod__c= 'Accepted';
                demoAttendeeList.add(myeventattendee);
            }*/
            
           
            
            insert demoAttendeeList;
        }
        
        catch(exception e){
            system.debug('Error occurred' +e) ;
        }
        
       } 
   }