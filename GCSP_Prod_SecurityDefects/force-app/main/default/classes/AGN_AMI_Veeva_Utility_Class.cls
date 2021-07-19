//20 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team

public class AGN_AMI_Veeva_Utility_Class  
{
    //To Handle Apex call from Process Builders
    @InvocableMethod
    public static void processBuilderSupport(List<id> idList)
    {
        List<AMI_Workshop_Attendee_AGN__c> workshopAttendees = [Select id,Account_AGN__c,CreatedDate 
                                                                from AMI_Workshop_Attendee_AGN__c 
                                                                where id = :idList];
        
        List<AMI_Learning_Path_AGN__c> LearningPathList =[Select id,HCP_AGN__c,Curriculum_name_AGN__c,
                                                          Module_Name_AGN__c,Module_Percent_AGN__c,Module_Status_AGN__c,LastModifiedDate 
                                                          from AMI_Learning_Path_AGN__c where id in :idList];
                
        List<Event_Attendee_vod__c> EventAttendeeList = [Select id,Account_vod__c,AMI_Target_HCP_AGN__c,AMI_UserID_AGN__c 
                                                         from Event_Attendee_vod__c 
                                                         where id in :idList 
                                                         and RecordType.DeveloperName =:AGN_AMI_Static_Labels.meetingAttendeeRecordtype];
        
        if(!workshopAttendees.isEmpty()){
            workshopActivity(workshopAttendees);
        }
        else if(!LearningPathList.isEmpty()){
            ModuleActivityCreate(LearningPathList);
        }
        else if(!EventAttendeeList.isEmpty()){
            updateMeetingAttendeeTargetHCPUserID(EventAttendeeList);
        }
        else 
        {
            createSuggestionStatus(idList);
            createEventStatus(idList);
            createModuleStatus(idList);
            createSurveyStatus(idList);
        }
    }
    
    //Multichannel Activity Creations/Updates
    public static void workshopActivity(List<AMI_Workshop_Attendee_AGN__c> workshopAttendees)
    {
        List<Multichannel_Activity_vod__c> activities = new List<Multichannel_Activity_vod__c>();
        Id recordTypeId  = [Select id from RecordType 
                            where DeveloperName = :AGN_AMI_Static_Labels.MCActivityWorkshopRecordType Limit 1].Id;
        for(AMI_Workshop_Attendee_AGN__c wa : workshopAttendees)
        {
            Multichannel_Activity_vod__c activity = new Multichannel_Activity_vod__c();
            activity.Account_vod__c = wa.Account_AGN__c;
            activity.AMI_Workshop_Attendee_AGN__c = wa.Id;
            activity.Start_DateTime_vod__c = wa.CreatedDate;
            activity.RecordTypeId = recordTypeId;
            activities.add(activity);    
        }        
        if(! activities.isEmpty())
            insert activities;
    }
    public static void ModuleActivityCreate(List<AMI_Learning_Path_AGN__c> LearningPathList)
    {
        List<Multichannel_Activity_vod__c> activities = new List<Multichannel_Activity_vod__c>();
        List<Multichannel_Activity_vod__c> activityInsertList = new List<Multichannel_Activity_vod__c>();
        List<Multichannel_Activity_vod__c> activityUpdateList = new List<Multichannel_Activity_vod__c>();
        Set<id> ALPIds =  new Set<id>();
        Id recordTypeId  = [Select id from RecordType 
                            where DeveloperName = :AGN_AMI_Static_Labels.MCActivityLPRecordType Limit 1].Id;
        
        for(AMI_Learning_Path_AGN__c Lp : LearningPathList)
        {
            ALPIds.add(lp.id);
        } 
        
        if(!ALPIds.isEmpty()){
            activities = [Select Id,Account_vod__c,AMI_Learning_Path_AGN__c,Start_DateTime_vod__c From Multichannel_Activity_vod__c 
                          where AMI_Learning_Path_AGN__c in : ALPIds];
        }
        Map<Id,Multichannel_Activity_vod__c> MAMap = new Map<Id,Multichannel_Activity_vod__c>();
        if(!activities.isEmpty()){
            for(Multichannel_Activity_vod__c ma : activities){
                MAMap.put(ma.AMI_Learning_Path_AGN__c,ma);
            }
            for(AMI_Learning_Path_AGN__c Lp : LearningPathList)
            {
                Multichannel_Activity_vod__c activity = new Multichannel_Activity_vod__c();
                activity = MAMap.get(Lp.id);
                activity.Start_DateTime_vod__c = lp.LastModifiedDate;
                activityUpdateList.add(activity);
            } 
        }else{
            for(AMI_Learning_Path_AGN__c Lp : LearningPathList)
            {
                Multichannel_Activity_vod__c activity = new Multichannel_Activity_vod__c();
                activity.Account_vod__c = Lp.HCP_AGN__c;
                activity.AMI_Learning_Path_AGN__c = Lp.Id;
                activity.Start_DateTime_vod__c = Lp.LastModifiedDate;
                activity.RecordTypeId = recordTypeId;
                activityInsertList.add(activity);    
            } 
        }
        
        if(! activityUpdateList.isEmpty()){
            update activityUpdateList;
        }
        if(! activityInsertList.isEmpty()){
            insert activityInsertList;
        }
    }
    
    public static void PreDQHCPLastLoginActivityCreate(Id userId)
    {
        List<Multichannel_Activity_vod__c> activities = new List<Multichannel_Activity_vod__c>();
        List<Multichannel_Activity_vod__c> activityInsertList = new List<Multichannel_Activity_vod__c>();
        List<Multichannel_Activity_vod__c> activityUpdateList = new List<Multichannel_Activity_vod__c>();
        Set<id> usrAccountIds =  new Set<id>();
        try{
            List<User> UserList =[SELECT id,LastLoginDate,contactId,AccountId,profile.name,Account.ispersonaccount,isactive,email,country_code__c 
                                  FROM User 
                                  where id = :userId 
                                  and isactive=true 
                                  and Account.ispersonaccount=true 
                                  and Account.AGN_AMI_Enabled__c = true and LastLoginDate!=Null];
            Id recordTypeId  = [Select id from RecordType where DeveloperName = :AGN_AMI_Static_Labels.MCActivityLastLoginRecordType Limit 1].Id;
            for(User usr : UserList){
                //if(usr.LastLoginDate!=Null){
                usrAccountIds.add(usr.AccountId); 
                //}
            }
            if(!usrAccountIds.isEmpty()){
                activities = [Select Id,AMI_Portal_Login_AGN__c,Account_vod__c,Start_DateTime_vod__c From Multichannel_Activity_vod__c 
                              where Account_vod__c in : usrAccountIds  and RecordType.DeveloperName = :AGN_AMI_Static_Labels.MCActivityLastLoginRecordType];
            }
            Map<Id,Multichannel_Activity_vod__c> MAMap = new Map<Id,Multichannel_Activity_vod__c>();
            if(!activities.isEmpty()){
                for(Multichannel_Activity_vod__c ma : activities){
                    MAMap.put(ma.Account_vod__c,ma);
                }
                
                for(User usr : UserList){
                    Multichannel_Activity_vod__c activity = new Multichannel_Activity_vod__c();
                    activity = MAMap.get(usr.AccountId);
                    activity.AMI_Portal_Login_AGN__c = usr.LastLoginDate;
                    activity.Start_DateTime_vod__c = usr.LastLoginDate;
                    activityUpdateList.add(activity);
                }
                
            }else{  
                
                for(User usr : UserList){
                    //if(usr.Account.ispersonaccount==true && usr.LastLoginDate!=Null){ 
                    Multichannel_Activity_vod__c activity = new Multichannel_Activity_vod__c();
                    activity.RecordTypeId = recordTypeId;
                    activity.Account_vod__c = usr.AccountId;  
                    activity.AMI_Portal_Login_AGN__c = usr.LastLoginDate;   
                    activity.Start_DateTime_vod__c = usr.LastLoginDate;
                    activityInsertList.add(activity); 
                    //}
                }
            }
            if(!activityUpdateList.isEmpty()){
                update activityUpdateList;
            }
            
            if(!activityInsertList.isEmpty()){
                insert activityInsertList;
            }
        }catch(Exception e){
            //Error Logger to be added
        }
    }
    
    public static void PostDQHCPLastLoginActivityCreate(Id userId)
    {
        List<Multichannel_Activity_vod__c> activities = new List<Multichannel_Activity_vod__c>();
        List<Multichannel_Activity_vod__c> activityInsertList = new List<Multichannel_Activity_vod__c>();
        List<Multichannel_Activity_vod__c> activityUpdateList = new List<Multichannel_Activity_vod__c>();
        List<AccountContactRelation> accConRelationshipList = new List<AccountContactRelation>();
        Set<id> usrContactIds =  new Set<id>();
        Set<id> usrAccountIds =  new Set<id>();
        
        try{
            List<User> UserList = [SELECT id,LastLoginDate,contactId,AccountId,profile.name,Account.ispersonaccount,isactive,email,country_code__c 
                                   FROM User 
                                   where id =: userId 
                                   and isactive=true 
                                   and Account.ispersonaccount=false 
                                   and Contact.is_AMI_Contact_AGN__C = true 
                                   and LastLoginDate!=Null];
            
            Id recordTypeId  = [Select id from RecordType where DeveloperName = :AGN_AMI_Static_Labels.MCActivityLastLoginRecordType Limit 1].Id;
            
            for(User usr : UserList){
                //if(usr.Account.ispersonaccount==true && usr.LastLoginDate!=Null){
                usrContactIds.add(usr.ContactId); 
                //}
            }
            
            if(!usrContactIds.isEmpty()){
                accConRelationshipList  = [Select AccountId,ContactId,IsDirect from AccountContactRelation where contactID in : usrContactIds and IsDirect=False];          
            }
            
            Map<Id,Id> ACRMap = new Map<Id,Id>();
            
            if(!accConRelationshipList.isEmpty()){
                for(AccountContactRelation acr : accConRelationshipList){
                    usrAccountIds.add(acr.AccountId);
                    ACRMap.put(acr.ContactId,acr.AccountId);
                }
                
            }
            
            if(!usrAccountIds.isEmpty()){
                activities = [Select Id,AMI_Portal_Login_AGN__c,Account_vod__c,Start_DateTime_vod__c From Multichannel_Activity_vod__c 
                              where Account_vod__c in : usrAccountIds  and RecordType.DeveloperName = :AGN_AMI_Static_Labels.MCActivityLastLoginRecordType];
            }
            
            Map<Id,Multichannel_Activity_vod__c> MAMap = new Map<Id,Multichannel_Activity_vod__c>();
            if(!activities.isEmpty()){
                for(Multichannel_Activity_vod__c ma : activities){
                    MAMap.put(ma.Account_vod__c,ma);
                }
                
                for(User usr : UserList){
                    Multichannel_Activity_vod__c activity = new Multichannel_Activity_vod__c();
                    activity = MAMap.get(ACRMap.get(usr.ContactId));
                    activity.AMI_Portal_Login_AGN__c = usr.LastLoginDate;
                    activity.Start_DateTime_vod__c = usr.LastLoginDate;
                    activityUpdateList.add(activity);
                }
                
            }else{  
                
                for(User usr : UserList){
                    //if(usr.Account.ispersonaccount==true && usr.LastLoginDate!=Null){ 
                    Multichannel_Activity_vod__c activity = new Multichannel_Activity_vod__c();
                    activity.RecordTypeId = recordTypeId;
                    activity.Account_vod__c = ACRMap.get(usr.ContactId);  
                    activity.AMI_Portal_Login_AGN__c = usr.LastLoginDate;   
                    activity.Start_DateTime_vod__c = usr.LastLoginDate;
                    activityInsertList.add(activity); 
                    //}
                }
            }
            
            
            if(!activityUpdateList.isEmpty()){
                update activityUpdateList;
            }
            
            if(!activityInsertList.isEmpty()){
                insert activityInsertList;
            }
        }catch(Exception e){
            //Error Logger to be added
        }
    }
    
    //Update Attendee Record with Target Rep information
    public static void updateMeetingAttendeeTargetHCPUserID(List<Event_Attendee_vod__c > EventAttendeeList)
    {
        
        List<Event_Attendee_vod__c> updateEventAttendeeList = new List<Event_Attendee_vod__c>();
        List<TSF_vod__c > TSFList = new List<TSF_vod__c >();
        Set<Id> accountIds =  new Set<Id>();
        for(Event_Attendee_vod__c ea : EventAttendeeList){
            accountIds.add(ea.Account_vod__c);
        }
        
        if(!accountIds.isEmpty()){
            TSFList = [SELECT Account_vod__c,My_Target_vod__c,Territory_vod__c,createddate,lastmodifieddate 
                       FROM TSF_vod__c where My_Target_vod__c=true and account_vod__c in : accountIds order by LastModifiedDate desc];
        }
        
        List<String> territoryNames =  new List<String>();
        List<TSF_vod__c> tsfRecords = new List<TSF_vod__c>();
        Map<id,TSF_vod__c> tsfMap = new Map<id,TSF_vod__c>();
        if(!TSFList.isEmpty()){
            for(TSF_vod__c tsf : TSFList){
                territoryNames.add(tsf.Territory_vod__c);
                tsfMap.put(tsf.Account_vod__c,tsf);
            }
        }  
        
        
        //changes for TM 1.0 to TM 2.0 Migration - Start
        List<Territory2> territoryList = new List<Territory2>();
        if (!territoryNames.isEmpty()) {
            territoryList = [Select id, Name from Territory2 where name in : territoryNames];
            //userTerritoryList=[SELECT Id,IsActive,TerritoryId,UserId FROM UserTerritory 
            //where Territoryid in (select id from territory where name in :territoryNames)];
        }
        
        Map<String,Id> territoryMap = new Map<String,Id>();
        if(!territoryList.isEmpty()){
            for(Territory2 terri : territoryList){
                territoryMap.put(terri.Name,terri.id); 
            }
        }
        
        List<UserTerritory2Association> userTerritoryList=new  List<UserTerritory2Association>();
        if(!territoryMap.isEmpty()){
            userTerritoryList=[SELECT Id,IsActive,Territory2Id,UserId FROM UserTerritory2Association where Territory2Id in :territoryMap.values() AND Territory2.Territory2Model.State ='Active' order by lastmodifieddate];
        }
        
        Map<id,id> userterriIdMap = new Map<id,Id>();
        if(!userTerritoryList.isEmpty()){
            for(UserTerritory2Association userTerri : userTerritoryList){
                userterriIdMap.put(userTerri.Territory2Id,userTerri.UserId);
            }   
        }
        //changes for TM 1.0 to TM 2.0 Migration - End
        
        for(Event_Attendee_vod__c ea : EventAttendeeList){
            TSF_vod__c tsf = new TSF_vod__c();
            if(tsfMap.containsKey(ea.Account_vod__c)){
                tsf = tsfMap.get(ea.Account_vod__c);
                if(tsf!=Null){
                    ea.AMI_Target_HCP_AGN__c= True;
                    Id userId = userterriIdMap.get(territoryMap.get(tsf.Territory_vod__c));
                    if(userId!=Null){
                        ea.AMI_UserID_AGN__c = userId;
                    }
                    updateEventAttendeeList.add(ea);
                }    
            }
        }
        
        if(!updateEventAttendeeList.isEmpty()){
            Update updateEventAttendeeList;
        }
        
    }
    
    // Journey Status Creations
    @future
    public static void createEventStatus(List<ID> meetingIds)
    {
        List<AMI_Event_Journey_Controller_AGN__c> controllingRecords = [Select id, AMI_Related_Event_AGN__c ,AMI_Meeting_AGN__c, AMI_Type_AGN__c 
                                                                        from AMI_Event_Journey_Controller_AGN__c 
                                                                        where RecordType.DeveloperName = :AGN_AMI_Static_Labels.EJCEventRecordtype
                                                                        and AMI_Meeting_AGN__c in :meetingIds
                                                                        and ((AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c 
                                                                              = :AGN_AMI_Static_Labels.meetingStatusLive
                                                                              and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJCTaskTypePre) 
                                                                             or (AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c 
                                                                                 = :AGN_AMI_Static_Labels.meetingStatusFollowUp 
                                                                                 and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJASTaskTypePost))];
        List<Event_Attendee_vod__c> attendeeRecords = [Select Id, Medical_Event_vod__c 
                                                       from Event_Attendee_vod__c 
                                                       where Medical_Event_vod__c in: meetingIds 
                                                       and ((Status_vod__c =:AGN_AMI_Static_Labels.attendeeStatusInvited 
                                                             and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusLive)
                                                       or (Status_vod__c = :AGN_AMI_Static_Labels.attendeeStatusPhysically 
                                                           and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusFollowUp)
                                                       or (Status_vod__c= :AGN_AMI_Static_Labels.attendeeStatusAttended 
                                                           and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusFollowUp))];
        
        List<AMI_Event_Attendee_Journey_Status_AGN__c> insertList = new List<AMI_Event_Attendee_Journey_Status_AGN__c>();
        String eventRecordtype = [Select Id from RecordType 
                                  where SObjectType ='AMI_Event_Attendee_Journey_Status_AGN__c' 
                                  and DeveloperName = :AGN_AMI_Static_Labels.EJCEventRecordtype 
                                  limit 1].Id;
        for(AMI_Event_Journey_Controller_AGN__c ejc : controllingRecords)
        {
            for(Event_Attendee_vod__c attendee : attendeeRecords)
            {
                if(attendee.Medical_Event_vod__c == ejc.AMI_Meeting_AGN__c)
                {
                    AMI_Event_Attendee_Journey_Status_AGN__c tempEAJS = new AMI_Event_Attendee_Journey_Status_AGN__c();
                    tempEAJS.AMI_Related_Event_AGN__c = ejc.AMI_Related_Event_AGN__c;
                    tempEAJS.RecordTypeId = eventRecordtype;
                    tempEAJS.AMI_Meeting_Attendee_AGN__c = attendee.Id;
                    tempEAJS.AMI_Type_AGN__c = ejc.AMI_Type_AGN__c;
                    insertList.add(tempEAJS);
                }
            }
        }
        if(! insertList.isEmpty())
            insert insertList;
    }
    @future
    public static void createSuggestionStatus(List<Id> meetingIds)
    {
        List<AMI_Event_Journey_Controller_AGN__c> controllingRecords = [Select id, AMI_Type_AGN__c, AMI_Description_AGN__c, AMI_Planned_Date_AGN__c, 
                                                                        AMI_Meeting_AGN__c, AMI_Visit_Suggested_AGN__c 
                                                                        from AMI_Event_Journey_Controller_AGN__c 
                                                                        where RecordType.DeveloperName = :AGN_AMI_Static_Labels.EJCCallRecordtype
                                                                        and AMI_Meeting_AGN__c in :meetingIds 
                                                                        and ((AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c 
                                                                              = :AGN_AMI_Static_Labels.meetingStatusLive
                                                                              and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJCTaskTypePre) 
                                                                             or (AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c 
                                                                                 = :AGN_AMI_Static_Labels.meetingStatusFollowUp 
                                                                                 and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJASTaskTypePost))];
        List<Event_Attendee_vod__c> attendeeRecords = [Select Id, Medical_Event_vod__c 
                                                       from Event_Attendee_vod__c 
                                                       where Medical_Event_vod__c in: meetingIds 
                                                       and ((Status_vod__c =:AGN_AMI_Static_Labels.attendeeStatusInvited 
                                                             and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusLive)
                                                       or (Status_vod__c = :AGN_AMI_Static_Labels.attendeeStatusPhysically 
                                                           and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusFollowUp)
                                                       or (Status_vod__c= :AGN_AMI_Static_Labels.attendeeStatusAttended 
                                                           and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusFollowUp))];
        
        List<AMI_Event_Attendee_Journey_Status_AGN__c> insertList = new List<AMI_Event_Attendee_Journey_Status_AGN__c>();
        String callRecordtype = [Select Id from RecordType 
                                 where SObjectType ='AMI_Event_Attendee_Journey_Status_AGN__c' 
                                 and DeveloperName = :AGN_AMI_Static_Labels.EJCCallRecordtype 
                                 limit 1].Id;
        for(AMI_Event_Journey_Controller_AGN__c ejc : controllingRecords)
        {
            for(Event_Attendee_vod__c attendee : attendeeRecords)
            {
                if(attendee.Medical_Event_vod__c == ejc.AMI_Meeting_AGN__c)
                {
                    AMI_Event_Attendee_Journey_Status_AGN__c tempEAJS = new AMI_Event_Attendee_Journey_Status_AGN__c();
                    tempEAJS.RecordTypeId = callRecordtype;
                    tempEAJS.AMI_Meeting_Attendee_AGN__c = attendee.Id;
                    tempEAJS.AMI_Planned_Call_Date_AGN__c = ejc.AMI_Planned_Date_AGN__c;
                    tempEAJS.AMI_Description_AGN__c = ejc.AMI_Description_AGN__c;
                    tempEAJS.AMI_Type_AGN__c = ejc.AMI_Type_AGN__c;
                    tempEAJS.AMI_Visit_Suggested_AGN__c = ejc.AMI_Visit_Suggested_AGN__c; 
                    insertList.add(tempEAJS);
                }
            }
        }
        if(! insertList.isEmpty())
            insert insertList;
    }
    @future
    public static void createModuleStatus(List<ID> meetingIds)
    {
        
        List<AMI_Event_Journey_Controller_AGN__c> controllingRecords = [Select id, AMI_Learning_Relationship_Detail_AGN__c,AMI_Meeting_AGN__c, 
                                                                        AMI_Type_AGN__c,AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c 
                                                                        from AMI_Event_Journey_Controller_AGN__c 
                                                                        where RecordType.DeveloperName = :AGN_AMI_Static_Labels.EJCModuleRecordtype
                                                                        and AMI_Meeting_AGN__c in :meetingIds 
                                                                        and ((AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c 
                                                                              = :AGN_AMI_Static_Labels.meetingStatusLive
                                                                              and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJCTaskTypePre) 
                                                                             or (AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c 
                                                                                 = :AGN_AMI_Static_Labels.meetingStatusFollowUp 
                                                                                 and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJASTaskTypePost))];
       
        List<Event_Attendee_vod__c> attendeeRecords = [Select Id, Medical_Event_vod__c,Account_vod__c,Status_vod__c 
                                                       from Event_Attendee_vod__c 
                                                       where Medical_Event_vod__c in: meetingIds 
                                                       and ((Status_vod__c =:AGN_AMI_Static_Labels.attendeeStatusInvited 
                                                             and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusLive)
                                                       or (Status_vod__c = :AGN_AMI_Static_Labels.attendeeStatusPhysically 
                                                           and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusFollowUp)
                                                       or (Status_vod__c= :AGN_AMI_Static_Labels.attendeeStatusAttended 
                                                           and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusFollowUp))];
        
        
        Set<Id> AccountIds = new Set<Id>();     
        for(Event_Attendee_vod__c attendee : attendeeRecords){
              AccountIds.add(attendee.Account_vod__c);
          }
        
        
        Set<Id> EJC_LRDIds = new Set<Id>(); 
        for(AMI_Event_Journey_Controller_AGN__c aejc : controllingRecords){
           EJC_LRDIds.add(aejc.AMI_Learning_Relationship_Detail_AGN__c);
        }
        
       
        //Retriving existing Learning Path
        List<AMI_Learning_Path_AGN__c> ExistingLearningPathRecords = [Select id,Module__c,HCP_AGN__c from AMI_Learning_Path_AGN__c 
                                                                      where Module__c in : EJC_LRDIds and HCP_AGN__c in : AccountIds];
        
        
        Map<id,List<AMI_Learning_Path_AGN__c>> ExistingLpMap = new Map<id,List<AMI_Learning_Path_AGN__c>>();
        Set<Id> LPModuleIds = new Set<Id>();
        if(!ExistingLearningPathRecords.isEmpty()){
            for(AMI_Learning_Path_AGN__c lp : ExistingLearningPathRecords){
                LPModuleIds.add(lp.Module__c);
                
                List<AMI_Learning_Path_AGN__c> lpList = ExistingLpMap.get(lp.Module__c);
                if(lpList!=Null){
                  lpList.add(lp);  
                }else{
                   List<AMI_Learning_Path_AGN__c> lpList2 = new List<AMI_Learning_Path_AGN__c>();
                    lpList2.add(lp);
                    ExistingLpMap.put(lp.Module__c,lpList2);
                } 
            }
        }
         
        
        // Added - Start
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
           SessionList = [select Id,Parent_Module_AGN__c,Name_AGN__c,Session_Code_AGN__c, Content_Type_AGN__c,
                          Duration_AGN__c,File_name_AGN__c,Parent_Module_AGN__r.Module_Content_Type_AGN__c,
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
        
         List<AccountContactRelation> acrList = [Select ContactId, AccountId 
                                                from AccountContactRelation 
                                                where AccountId in : AccountIds and Contact.is_AMI_Contact_AGN__c = true 
                                                and Account.AGN_AMI_Enabled__c = true 
                                                and isDirect = false];
        
        Map<String,String> accountContactMap = new Map<String,String>();
        for(AccountContactRelation acr : acrList)
        {
            accountContactMap.put(acr.AccountId, acr.ContactId);
        }
            
        
         Id LPRecordtype = Schema.SObjectType.AMI_Learning_Path_AGN__c.getRecordTypeInfosByDeveloperName().get('AGN_Defined').getRecordTypeId();
         List<AMI_Learning_Path_AGN__c> insertLPList = new List<AMI_Learning_Path_AGN__c>();
        for(AMI_Event_Journey_Controller_AGN__c ejc : controllingRecords){
           if(ejc.AMI_Type_AGN__c == AGN_AMI_Static_Labels.EJASTaskTypePost){
            for(Event_Attendee_vod__c attendee : attendeeRecords){
                if(attendee.Medical_Event_vod__c == ejc.AMI_Meeting_AGN__c){     
                     if(ExistingLpMap.containsKey(ejc.AMI_Learning_Relationship_Detail_AGN__c)){
                       List<AMI_Learning_Path_AGN__c> lpRecords = ExistingLpMap.get(ejc.AMI_Learning_Relationship_Detail_AGN__c);
                       //if(!lpRecords.isEmpty()){
                        for(AMI_Learning_Path_AGN__c lp : lpRecords){
                           if(lp.HCP_AGN__c != attendee.Account_vod__c){
                           
                            if(LRDMap.containsKey(ejc.AMI_Learning_Relationship_Detail_AGN__c)){
                              AMI_Lrn_Rel_Dtl_AGN__c lrd = LRDMap.get(ejc.AMI_Learning_Relationship_Detail_AGN__c);
                                
                            if(accountContactMap.containsKey(attendee.Account_vod__c)){
                             string contactId = accountContactMap.get(attendee.Account_vod__c);
                                
                            AMI_Learning_Path_AGN__c  ALP = new AMI_Learning_Path_AGN__c();
                            
                            ALP.HCP_AGN__c= attendee.Account_vod__c;
                            ALP.Contact_AGN__c = contactId;
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
                      }
                    }
                    else{
                        
                        if(LRDMap.containsKey(ejc.AMI_Learning_Relationship_Detail_AGN__c)){
                              AMI_Lrn_Rel_Dtl_AGN__c lrd = LRDMap.get(ejc.AMI_Learning_Relationship_Detail_AGN__c);
                                
                            if(accountContactMap.containsKey(attendee.Account_vod__c)){
                             string contactId = accountContactMap.get(attendee.Account_vod__c);
                                
                            AMI_Learning_Path_AGN__c  ALP = new AMI_Learning_Path_AGN__c();
                            
                            ALP.HCP_AGN__c= attendee.Account_vod__c;
                            ALP.Contact_AGN__c = contactId;
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
                    
                 //}
                }
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
       // Added -End
        
        
        //Retriving all Learning Path
        List<AMI_Learning_Path_AGN__c> AllLearningPathRecords = [Select id,Module__c,HCP_AGN__c from AMI_Learning_Path_AGN__c 
                                                                 where Module__c in : EJC_LRDIds];
        
         Map<id,List<AMI_Learning_Path_AGN__c>> LpIdMap = new Map<id,List<AMI_Learning_Path_AGN__c>>();
        if(!AllLearningPathRecords.isEmpty()){
            for(AMI_Learning_Path_AGN__c lp : AllLearningPathRecords){
                List<AMI_Learning_Path_AGN__c> lpList = LpIdMap.get(lp.Module__c);
                if(lpList!=Null){
                  lpList.add(lp);  
                }else{
                   List<AMI_Learning_Path_AGN__c> lpList2 = new List<AMI_Learning_Path_AGN__c>();
                    lpList2.add(lp);
                    LpIdMap.put(lp.Module__c,lpList2);
                }
                
            }
        }
        
        List<AMI_Event_Attendee_Journey_Status_AGN__c> insertList = new List<AMI_Event_Attendee_Journey_Status_AGN__c>();
        Id eventRecordtype = Schema.SObjectType.AMI_Event_Attendee_Journey_Status_AGN__c.getRecordTypeInfosByDeveloperName()
            .get(AGN_AMI_Static_Labels.EJCModuleRecordtype).getRecordTypeId();
        for(AMI_Event_Journey_Controller_AGN__c ejc : controllingRecords)
        {
            for(Event_Attendee_vod__c attendee : attendeeRecords)
            {
                if(attendee.Medical_Event_vod__c == ejc.AMI_Meeting_AGN__c)
                {
                    AMI_Event_Attendee_Journey_Status_AGN__c tempEAJS = new AMI_Event_Attendee_Journey_Status_AGN__c();
                    tempEAJS.AMI_Learning_Relationship_Detail_AGN__c = ejc.AMI_Learning_Relationship_Detail_AGN__c;
                    tempEAJS.RecordTypeId = eventRecordtype;
                    tempEAJS.AMI_Meeting_Attendee_AGN__c = attendee.Id;
                    tempEAJS.AMI_Type_AGN__c = ejc.AMI_Type_AGN__c;
                    if(LpIdMap.containsKey(ejc.AMI_Learning_Relationship_Detail_AGN__c)){
                        List<AMI_Learning_Path_AGN__c> lpRecords = LpIdMap.get(ejc.AMI_Learning_Relationship_Detail_AGN__c);
                        for(AMI_Learning_Path_AGN__c lp : lpRecords){
                            if(lp.HCP_AGN__c == attendee.Account_vod__c && lp.Module__c == ejc.AMI_Learning_Relationship_Detail_AGN__c){
                                tempEAJS.AMI_Learning_Path_AGN__c = lp.id;
                            }
                        }
                    }
                    insertList.add(tempEAJS);
                }
            }
        }
        
        if(! insertList.isEmpty())
            insert insertList;
    }
    
    @future
    public static void createSurveyStatus(List<Id> meetingIds)
    {
        List<AMI_Event_Journey_Controller_AGN__c> controllingRecords = [Select id, AMI_Type_AGN__c, AMI_Meeting_AGN__c, AMI_Survey_AGN__c 
                                                                        from AMI_Event_Journey_Controller_AGN__c 
                                                                        where RecordType.DeveloperName = :AGN_AMI_Static_Labels.EJCSurveyRecordtype
                                                                        and AMI_Meeting_AGN__c in :meetingIds 
                                                                        and ((AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c 
                                                                              = :AGN_AMI_Static_Labels.meetingStatusLive
                                                                              and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJCTaskTypePre) 
                                                                             or (AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c 
                                                                                 = :AGN_AMI_Static_Labels.meetingStatusFollowUp 
                                                                                 and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJASTaskTypePost))];
        List<Event_Attendee_vod__c> attendeeRecords = [Select Id, Medical_Event_vod__c 
                                                       from Event_Attendee_vod__c 
                                                       where Medical_Event_vod__c in: meetingIds
                                                       and ((Status_vod__c =:AGN_AMI_Static_Labels.attendeeStatusInvited 
                                                             and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusLive)
                                                       or (Status_vod__c = :AGN_AMI_Static_Labels.attendeeStatusPhysically 
                                                           and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusFollowUp)
                                                       or (Status_vod__c= :AGN_AMI_Static_Labels.attendeeStatusAttended 
                                                           and Medical_Event_vod__r.AMI_Event_Status_AGN__c = :AGN_AMI_Static_Labels.meetingStatusFollowUp))];
        
        List<AMI_Event_Attendee_Journey_Status_AGN__c> insertList = new List<AMI_Event_Attendee_Journey_Status_AGN__c>();
        String surveyRecordtype = [Select Id from RecordType 
                                   where SObjectType ='AMI_Event_Attendee_Journey_Status_AGN__c' 
                                   and DeveloperName = :AGN_AMI_Static_Labels.EJCSurveyRecordtype 
                                   limit 1].Id;
        Set<Id> surveyIds = new Set<id>();
        for(AMI_Event_Journey_Controller_AGN__c ejc : controllingRecords)
        {
            surveyIds.add(ejc.AMI_Survey_AGN__c);
        }
        
        List<SurveyInvitation> invitationList = [Select id, InvitationLink, SurveyId 
                                                 from SurveyInvitation 
                                                 where SurveyId in :surveyIds 
                                                 and Community.Name = 'Allergan Medical Institute(AMI)'];
        Map<id,SurveyInvitation> invitationMap = new Map<id,SurveyInvitation>();
        for(SurveyInvitation si : invitationList)
        {
            invitationMap.put(si.SurveyId, si);
        }
        
        for(AMI_Event_Journey_Controller_AGN__c ejc : controllingRecords)
        {
            for(Event_Attendee_vod__c attendee : attendeeRecords)
            {
                if(attendee.Medical_Event_vod__c == ejc.AMI_Meeting_AGN__c)
                {
                    AMI_Event_Attendee_Journey_Status_AGN__c tempEAJS = new AMI_Event_Attendee_Journey_Status_AGN__c();
                    tempEAJS.RecordTypeId = surveyRecordtype;
                    tempEAJS.AMI_Meeting_Attendee_AGN__c = attendee.Id;
                    tempEAJS.AMI_Type_AGN__c = ejc.AMI_Type_AGN__c;
                    tempEAJS.AMI_Survey_Invitation_AGN__c = (invitationMap.containsKey(ejc.AMI_Survey_AGN__c))?invitationMap.get(ejc.AMI_Survey_AGN__c).Id:null;
                    tempEAJS.AMI_Survey_Link_AGN__c = (invitationMap.containsKey(ejc.AMI_Survey_AGN__c))?
                        invitationMap.get(ejc.AMI_Survey_AGN__c).InvitationLink:null;
                    insertList.add(tempEAJS);
                }
            }
        }
        if(! insertList.isEmpty())
            insert insertList;
    } 
    
    // Journey Status updates with Account Transaction Records
    public static void updateEventStatus()
    {
        List<AMI_Event_Attendee_Journey_Status_AGN__c> journeyStatusList = [Select id,AMI_Account_Id_AGN__c,  AMI_Related_Event_AGN__c 
                                                                            from AMI_Event_Attendee_Journey_Status_AGN__c 
                                                                            where RecordType.DeveloperName = :AGN_AMI_Static_Labels.EJCEventRecordtype 
                                                                            and AMI_Related_Event_Attendee_AGN__c = null 
                                                                            and (AMI_Meeting_Attendee_AGN__r.Medical_event_vod__r.AMI_Event_Status_AGN__c 
                                                                                 = :AGN_AMI_Static_Labels.meetingStatusLive 
                                                                                 Or AMI_Meeting_Attendee_AGN__r.Medical_event_vod__r.AMI_Event_Status_AGN__c 
                                                                                 = :AGN_AMI_Static_Labels.meetingStatusFollowUp)
                                                                            and CreatedDate = LAST_90_DAYS];
        Set<id> attendeeList = new Set<id>();
        Set<Id> meetingList = new Set<id>();
        for(AMI_Event_Attendee_Journey_Status_AGN__c eajs : journeyStatusList)
        {
            attendeeList.add(eajs.AMI_Account_Id_AGN__c);
            meetingList.add(eajs.AMI_Related_Event_AGN__c);
        }
        List<Event_Attendee_vod__c> relavantAttendeeList = [Select id, Account_vod__c, Medical_event_vod__c 
                                                            from Event_Attendee_vod__c 
                                                            where Account_vod__c in: attendeeList
                                                            and Medical_event_vod__c in: meetingList];
        Map<String,String> relavantIdMap = new Map<String,String>();
        for(Event_Attendee_vod__c attendee : relavantAttendeeList)
        {
            relavantIdMap.put(attendee.Account_vod__c+'_'+attendee.Medical_Event_vod__c, attendee.Id);
        }
        List<AMI_Event_Attendee_Journey_Status_AGN__c> journeyStatusUpdateList = new List<AMI_Event_Attendee_Journey_Status_AGN__c>();
        for(AMI_Event_Attendee_Journey_Status_AGN__c eajs : journeyStatusList)
        {
            if(relavantIdMap.containsKey(eajs.AMI_Account_Id_AGN__c+'_'+eajs.AMI_Related_Event_AGN__c))
            {
                eajs.AMI_Related_Event_Attendee_AGN__c = relavantIdMap.get(eajs.AMI_Account_Id_AGN__c+'_'+eajs.AMI_Related_Event_AGN__c);
                journeyStatusUpdateList.add(eajs);
            }
        }
        if(! journeyStatusUpdateList.isEmpty())
            update journeyStatusUpdateList;
    }
    public static void updateSuggestionStatus()
    {
        List<AMI_Event_Attendee_Journey_Status_AGN__c> journeyStatusList = [Select id,AMI_Suggestion_AGN__c, AMI_Visit_Suggested_AGN__c 
                                                                            from AMI_Event_Attendee_Journey_Status_AGN__c 
                                                                            where RecordType.DeveloperName = :AGN_AMI_Static_Labels.EJCCallRecordtype 
                                                                            and AMI_Suggestion_Status_AGN__c = 'Incomplete' 
                                                                            and CreatedDate = LAST_90_DAYS];
        Set<id> statusList = new Set<id>();
        for(AMI_Event_Attendee_Journey_Status_AGN__c eajs : journeyStatusList)
        {
            statusList.add(eajs.Id);
        }
        List<Suggestion_vod__c> relavantSuggestionList = [Select id, AMI_Event_Attendee_Journey_Status_ID_AGN__c  
                                                          from Suggestion_vod__c 
                                                          where AMI_Event_Attendee_Journey_Status_ID_AGN__c in: statusList
                                                          and RecordType.DeveloperName = 'Call_vod' 
                                                          order by CreatedDate desc];
        List<AMI_Event_Attendee_Journey_Status_AGN__c> journeyStatusUpdateList = new List<AMI_Event_Attendee_Journey_Status_AGN__c>();
        Set<Id> aejsSet = new Set<Id>();
        List<Suggestion_vod__c> suggestionExpirationList = new List<Suggestion_vod__c>();
        for(Suggestion_vod__c suggestion : relavantSuggestionList)
        {
            if(! aejsSet.contains(suggestion.AMI_Event_Attendee_Journey_Status_ID_AGN__c))
            {
                journeyStatusUpdateList.add(new AMI_Event_Attendee_Journey_Status_AGN__c(id=suggestion.AMI_Event_Attendee_Journey_Status_ID_AGN__c, 
                                                                                         AMI_Suggestion_AGN__c=suggestion.Id));
                aejsSet.add(suggestion.AMI_Event_Attendee_Journey_Status_ID_AGN__c);
            }
            else
            {
                suggestion.Expiration_Date_vod__c = Date.today().addDays(-2);
                suggestionExpirationList.add(suggestion);
            }
                
        }
        if(! journeyStatusUpdateList.isEmpty())
            update journeyStatusUpdateList;
        if(! suggestionExpirationList.isEmpty())
            update suggestionExpirationList;
    }
    public static void updateModuleStatus()
    {
        
        List<AMI_Event_Attendee_Journey_Status_AGN__c> journeyStatusList = [Select id,AMI_Learning_Relationship_Detail_AGN__c,AMI_Meeting_Attendee_AGN__c,
                                                                            AMI_Meeting_Attendee_AGN__r.Medical_Event_vod__c 
                                                                            from AMI_Event_Attendee_Journey_Status_AGN__c 
                                                                            where RecordType.DeveloperName = :AGN_AMI_Static_Labels.EJCModuleRecordtype 
                                                                            and AMI_Learning_Path_AGN__c = null 
                                                                            //and AMI_Meeting_Attendee_AGN__r.Medical_event_vod__r.AMI_Event_Status_AGN__c 
                                                                            //= :AGN_AMI_Static_Labels.meetingStatusLive
                                                                            and CreatedDate = LAST_90_DAYS];
        
        
        
        Set<Id> AttendeeIds = new Set<Id>();
        Set<Id> eajs_LRDIds = new Set<Id>();
        for(AMI_Event_Attendee_Journey_Status_AGN__c eajs : journeyStatusList)
        {
            AttendeeIds.add(eajs.AMI_Meeting_Attendee_AGN__c);
            eajs_LRDIds.add(eajs.AMI_Learning_Relationship_Detail_AGN__c);
            
        }
        
        List<Event_Attendee_vod__c> attendeeRecords = [Select Id, Medical_Event_vod__c,Account_vod__c,Status_vod__c 
                                                       from Event_Attendee_vod__c where Id in : AttendeeIds];
        
        Map<Id,Event_Attendee_vod__c> attendeeMap = new Map<Id,Event_Attendee_vod__c>();
        for(Event_Attendee_vod__c attendee : attendeeRecords){
            attendeeMap.put(attendee.Id,attendee);
        }
        
        List<AMI_Learning_Path_AGN__c> relavantLPList = [Select id, Module__c, HCP_AGN__c
                                                         from AMI_Learning_Path_AGN__c where Module__c in: eajs_LRDIds];
        
        List<AMI_Event_Attendee_Journey_Status_AGN__c> journeyStatusUpdateList = new List<AMI_Event_Attendee_Journey_Status_AGN__c>();
        
        for(AMI_Event_Attendee_Journey_Status_AGN__c AEAS : journeyStatusList){
            
            if(attendeeMap.containsKey(AEAS.AMI_Meeting_Attendee_AGN__c)){
                Event_Attendee_vod__c attendee = attendeeMap.get(AEAS.AMI_Meeting_Attendee_AGN__c);
                
                for(AMI_Learning_Path_AGN__c lp : relavantLPList){
                    if(attendee.Account_vod__c == lp.HCP_AGN__c && AEAS.AMI_Learning_Relationship_Detail_AGN__c == lp.Module__c){
                        journeyStatusUpdateList.add(new AMI_Event_Attendee_Journey_Status_AGN__c(id=AEAS.Id, 
                                                                                                 AMI_Learning_Path_AGN__c=lp.Id));
                        
                    }
                }
            }
        }
        if(! journeyStatusUpdateList.isEmpty())
            update journeyStatusUpdateList;
    }
    public static void updateSurveyStatus()
    {
        List<AMI_Event_Attendee_Journey_Status_AGN__c> journeyStatusList = [Select id, AMI_Meeting_Attendee_AGN__r.Account_vod__c, 
                                                                            AMI_Survey_Invitation_AGN__c, AMI_Survey_Response_AGN__c
                                                                            from AMI_Event_Attendee_Journey_Status_AGN__c 
                                                                            where RecordType.DeveloperName = :AGN_AMI_Static_Labels.EJCSurveyRecordtype 
                                                                            and AMI_Survey_Response_AGN__c = null 
                                                                            and CreatedDate = LAST_90_DAYS];
        Set<id> surveyList = new Set<id>();
        for(AMI_Event_Attendee_Journey_Status_AGN__c eajs : journeyStatusList)
        {
            surveyList.add(eajs.AMI_Survey_Invitation_AGN__c);
        }
        List<SurveyResponse> responseList = [Select id, InvitationId, SubmitterId from SurveyResponse where InvitationId in: surveyList];
        List<AccountContactRelation> acrList = [Select ContactId, AccountId 
                                                from AccountContactRelation 
                                                where Contact.is_AMI_Contact_AGN__c = true 
                                                and Account.AGN_AMI_Enabled__c = true 
                                                and isDirect = false];
        Map<String,String> accountContactMap = new Map<String,String>();
        for(AccountContactRelation acr : acrList)
        {
            accountContactMap.put(acr.ContactId, acr.AccountId);
        }
        Map<string,String> surveyMap = new Map<String,String>();
        for(SurveyResponse sr : responseList)
        {
            if(accountContactMap.containsKey(sr.SubmitterId))
            {
                String accountId = accountContactMap.get(sr.SubmitterId);
                surveyMap.put(accountId+'_'+sr.InvitationId,sr.id);
            }
        }
        List<AMI_Event_Attendee_Journey_Status_AGN__c> updateStatusList = new List<AMI_Event_Attendee_Journey_Status_AGN__c>();
        for(AMI_Event_Attendee_Journey_Status_AGN__c eajs : journeyStatusList)
        {
            String key = eajs.AMI_Meeting_Attendee_AGN__r.Account_vod__c + '_' + eajs.AMI_Survey_Invitation_AGN__c;
            if(surveyMap.containsKey(key))
            {
                eajs.AMI_Survey_Response_AGN__c = surveyMap.get(key);
                updateStatusList.add(eajs);
            }
        }
        if(! updateStatusList.isEmpty())
            update updateStatusList;
    }
    
    //Update Attendee Records with view data
    public static void viewAttendeeUpdate()
    {
        List<Event_Attendee_vod__c> attendeeList = [Select id,Account_vod__c, Medical_Event_vod__r.Event_Broadcast_Link_AGN__c, AMI_of_Event_Watched_AGN__c
                                                    from Event_Attendee_vod__c 
                                                    where RecordType.DeveloperName = :AGN_AMI_Static_Labels.meetingAttendeeRecordtype 
                                                    and Medical_Event_vod__r.RecordType.DeveloperName = :AGN_AMI_Static_Labels.meetingRecordType
                                                    and (Medical_Event_vod__r.AMI_Event_Status_AGN__c != :AGN_AMI_Static_Labels.meetingStatusLive 
                                                         or Medical_Event_vod__r.AMI_Event_Status_AGN__c != :AGN_AMI_Static_Labels.meetingStatusPlanned)
                                                    and AMI_of_Event_Watched_AGN__c = null
                                                    and Status_vod__c = :AGN_AMI_Static_Labels.attendeeStatusAttended
                                                    //and LastModifiedDate = Yesterday
                                                   ];
        List<vidyard__Video_View__c> listViews = [Select id, vidyard__Player_Uuid__c, vidyard__Contact__c 
                                                  from vidyard__Video_View__c 
                                                  //where createdDate = Yesterday
                                                 ];
        Map<String,Event_Attendee_vod__c> attendeeMap = new Map<String,Event_Attendee_vod__c>();
        
        List<AccountContactRelation> acrList = [Select ContactId, AccountId 
                                                from AccountContactRelation 
                                                where Contact.is_AMI_Contact_AGN__c = true 
                                                and Account.AGN_AMI_Enabled__c = true 
                                                and isDirect = false];
        Map<String,String> accountContactMap = new Map<String,String>();
        
        for(AccountContactRelation acr : acrList)
        {
            accountContactMap.put(acr.AccountId, acr.ContactId);
        }
        
        for(Event_Attendee_vod__c attendee : attendeeList)
        {
            String url = attendee.Medical_Event_vod__r.Event_Broadcast_Link_AGN__c;
            if(url!= null && url.contains('https://play.vidyard.com/'))
            {
                string uuid = attendee.Medical_Event_vod__r.Event_Broadcast_Link_AGN__c.remove('https://play.vidyard.com/');
                if(accountContactMap.containsKey(attendee.Account_vod__c))
                {
                    string contactId = accountContactMap.get(attendee.Account_vod__c);
                    string key = uuid + '_' + contactId;
                    attendeeMap.put(key, attendee); 
                }             
            }
        }
        Map<String,Event_Attendee_vod__c> updatedAttendeeMap = new Map<String,Event_Attendee_vod__c>();
        for(vidyard__Video_View__c view : listViews)
        {
            string key = view.vidyard__Player_Uuid__c + '_' + view.vidyard__Contact__c;
            if(attendeeMap.containsKey(key))
            {
                Event_Attendee_vod__c attendee = (updatedAttendeeMap.containsKey(key))?
                    updatedAttendeeMap.get(key) : attendeeMap.get(key);
                attendee.AMI_of_Event_Watched_AGN__c = attendee.AMI_of_Event_Watched_AGN__c + view.vidyard__Video_Amount_Watched__c;
                if(attendee.AMI_of_Event_Watched_AGN__c > 100)
                    attendee.AMI_of_Event_Watched_AGN__c = 100;
                updatedAttendeeMap.put(key,attendee);
                
            }
        }
        
        List<Event_Attendee_vod__c> updateAttendeeList = new List<Event_Attendee_vod__c>();
        for(String key : updatedAttendeeMap.keySet())
        {
            updateAttendeeList.add(updatedAttendeeMap.get(key));
        }
        if(! updateAttendeeList.isEmpty())
            update updateAttendeeList;
    }
    
    //Update Attendee Records with Status Roll ups
    public static void updateAttendeeRecords()
    {
        List<Event_Attendee_vod__c> attendeeList = [Select Id, AMI_Module_Completion_AGN__c, AMI_Pre_Event_Completion_AGN__c, AMI_Pre_task_Call_AGN__c
                                                    from Event_Attendee_vod__c 
                                                    where Medical_Event_vod__r.RecordType.DeveloperName =: AGN_AMI_Static_Labels.meetingRecordType 
                                                    and (AMI_Module_Completion_AGN__c = false 
                                                         OR AMI_Pre_Event_Completion_AGN__c = false
                                                         OR AMI_Pre_task_Call_AGN__c = false 
                                                         OR AMI_Pre_Survey_Complete_AGN__c = false
                                                         OR AMI_Post_Module_Completion_AGN__c = false 
                                                         OR AMI_Post_Event_Completion_AGN__c = false
                                                         OR AMI_Post_task_Call_AGN__c = false
                                                         OR AMI_Post_Survey_Complete_AGN__c = false) 
                                                    and CreatedDate = LAST_90_DAYS];
        
        Map<String,attendeeStatusWrapper> attendeeStatusMap = new Map<String,attendeeStatusWrapper>();
        Set<Id> attendeeIds = new Set<Id>();
        for(Event_Attendee_vod__c attendee : attendeeList)
        {
            attendeeIds.add(attendee.Id);
            attendeeStatusMap.put(attendee.Id,new attendeeStatusWrapper());
        }
        List<AMI_Event_Attendee_Journey_Status_AGN__c> statusList = [Select Id,AMI_Type_AGN__c, AMI_Survey_Status_AGN__c, AMI_Meeting_Attendee_AGN__c, 
                                                                     AMI_Related_Events_Status_AGN__c, AMI_Suggestion_Status_AGN__c, AMI_Learning_Status_AGN__c 
                                                                     from AMI_Event_Attendee_Journey_Status_AGN__c 
                                                                     where AMI_Meeting_Attendee_AGN__c in :attendeeIds 
                                                                     and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJASTaskTypePre];
        for(AMI_Event_Attendee_Journey_Status_AGN__c eajs : statusList)
        {
            attendeeStatusWrapper tempCounter = attendeeStatusMap.get(eajs.AMI_Meeting_Attendee_AGN__c);
            if(eajs.AMI_Learning_Status_AGN__c != 'Not Applicable')
            {
                if(eajs.AMI_Learning_Status_AGN__c == 'Completed')
                {
                    if(eajs.AMI_Type_AGN__c == AGN_AMI_Static_Labels.EJCTaskTypePre)
                        tempCounter.completedModules++;
                    else
                        tempCounter.completedModulesPost++;
                }
                if(eajs.AMI_Type_AGN__c == AGN_AMI_Static_Labels.EJCTaskTypePre)
                    tempCounter.requiredModules++;
                else
                    tempCounter.requiredModulesPost++;
            }
            if(eajs.AMI_Suggestion_Status_AGN__c != 'Not Applicable')
            {
                if(eajs.AMI_Suggestion_Status_AGN__c == 'Completed')
                {
                    if(eajs.AMI_Type_AGN__c == AGN_AMI_Static_Labels.EJCTaskTypePre)
                        tempCounter.completedCalls++;
                    else
                        tempCounter.completedCallsPost++;
                }
                if(eajs.AMI_Type_AGN__c == AGN_AMI_Static_Labels.EJCTaskTypePre)
                    tempCounter.requiredCalls++;
                else
                    tempCounter.requiredCallsPost++;
            }
            if(eajs.AMI_Survey_Status_AGN__c != 'Not Applicable')
            {
                if(eajs.AMI_Survey_Status_AGN__c == 'Completed')
                {
                    if(eajs.AMI_Type_AGN__c == AGN_AMI_Static_Labels.EJCTaskTypePre)
                        tempCounter.completedSurvey++;
                    else
                        tempCounter.completedSurveyPost++;
                }
                if(eajs.AMI_Type_AGN__c == AGN_AMI_Static_Labels.EJCTaskTypePre)
                    tempCounter.requiredSurvey++;
                else
                    tempCounter.requiredSurveyPost++;
            }
            if(eajs.AMI_Related_Events_Status_AGN__c != 'Not Applicable')
            {
                if(eajs.AMI_Related_Events_Status_AGN__c == 'Attended')
                {
                    if(eajs.AMI_Type_AGN__c == AGN_AMI_Static_Labels.EJCTaskTypePre)
                        tempCounter.completedEvents++;
                    else
                        tempCounter.completedEventsPost++;
                }
                if(eajs.AMI_Type_AGN__c == AGN_AMI_Static_Labels.EJCTaskTypePre)
                    tempCounter.requiredEvents++;
                else
                    tempCounter.requiredEventsPost++;
            }
            attendeeStatusMap.put(eajs.AMI_Meeting_Attendee_AGN__c, tempCounter);
        }
        List<Event_Attendee_vod__c> updateList = new List<Event_Attendee_vod__c>();
        for(String attendeeId : attendeeStatusMap.keySet())
        {
            Event_Attendee_vod__c tempAttendee = new Event_attendee_vod__c(id=attendeeId);
            attendeeStatusWrapper tempCounter = attendeeStatusMap.get(attendeeId);
            if(tempCounter.completedCalls == tempCounter.requiredCalls && tempCounter.requiredCalls != 0)
                tempAttendee.AMI_Pre_task_Call_AGN__c = true;
            if(tempCounter.completedEvents == tempCounter.requiredEvents && tempCounter.requiredEvents != 0)
                tempAttendee.AMI_Pre_Event_Completion_AGN__c = true;
            if(tempCounter.completedModules == tempCounter.requiredModules && tempCounter.requiredModules != 0)
                tempAttendee.AMI_Module_Completion_AGN__c = true;
            if(tempCounter.completedSurvey == tempCounter.requiredSurvey && tempCounter.requiredSurvey != 0)
                tempAttendee.AMI_Pre_Survey_Complete_AGN__c = true;
            
            if(tempCounter.completedCallsPost == tempCounter.requiredCallsPost && tempCounter.requiredCallsPost != 0)
                tempAttendee.AMI_Post_task_Call_AGN__c = true;
            if(tempCounter.completedEventsPost == tempCounter.requiredEventsPost && tempCounter.requiredEventsPost != 0)
                tempAttendee.AMI_Post_Event_Completion_AGN__c = true;
            if(tempCounter.completedModulesPost == tempCounter.requiredModulesPost && tempCounter.requiredModulesPost != 0)
                tempAttendee.AMI_Post_Module_Completion_AGN__c = true;
            if(tempCounter.completedSurveyPost == tempCounter.requiredSurveyPost && tempCounter.requiredSurveyPost != 0)
                tempAttendee.AMI_Post_Survey_Complete_AGN__c = true;
            
            updateList.add(tempAttendee);
        }
        
        if(! updateList.isEmpty())
            update updateList;
    }
    
    public static void ejCompletionSync(List<AMI_Learning_Path_AGN__c> recentPathList)
    {
        List<AMI_Module_Visibility_AGN__c> visibilityList = [Select id, AMI_Learning_agn__c, Level_AGN__c, Category_AGN__c 
                                                             from AMI_Module_Visibility_AGN__c];
        List<AMI_HCP_EJ_Completion_AGN__c> ejCompletionList = [Select id, AMI_Account_AGN__c, AMI_Category_AGN__c, AMI_Education_Journey_Level_AGN__c, 
                                                               AMI_Completion_Percentage_AGN__c, AMI_Modules_Enrolled_AGN__c, AMI_Total_Modules_AGN__c 
                                                               from AMI_HCP_EJ_Completion_AGN__c];
        Map<String, String> visibilityMap = new Map<String,String>();
        Map<String, Integer> ejcCount = new Map<String,Integer>();
        for(AMI_Module_Visibility_AGN__c mv : visibilityList)
        {
            String ej = mv.Level_AGN__c + '_' + mv.Category_AGN__c;
            visibilityMap.put(mv.AMI_Learning_agn__c, ej);
            if(ejcCount.containsKey(ej))
            {
                Integer count = ejcCount.get(ej);
                ejcCount.put(ej, count+1);
            }
            else
            {
                ejcCount.put(ej, 1);
            }
        }
        Map<String, AMI_HCP_EJ_Completion_AGN__c> ejcMap = new Map<String, AMI_HCP_EJ_Completion_AGN__c>();
        for(AMI_HCP_EJ_Completion_AGN__c ejc : ejCompletionList)
        {
            ejcMap.put(ejc.AMI_Account_AGN__c + '_' + ejc.AMI_Education_Journey_Level_AGN__c + '_' + ejc.AMI_Category_AGN__c, ejc);
        }
        List<AMI_HCP_EJ_Completion_AGN__c> ejCompletionListUpdate = new List<AMI_HCP_EJ_Completion_AGN__c>();
        List<AMI_Learning_Path_AGN__c> pathUpdateList = new List<AMI_Learning_Path_AGN__c>();
        for(AMI_Learning_Path_AGN__c lp : recentPathList)
        {
            if(visibilityMap.containsKey(lp.Module__r.Module_AGN__c))
            {
                AMI_HCP_EJ_Completion_AGN__c ejc;
                String ejcKey = lp.HCP_AGN__c + '_' + visibilityMap.get(lp.Module__r.Module_AGN__c);
                String ejKey = visibilityMap.get(lp.Module__r.Module_AGN__c);
                if(ejcMap.containsKey(ejcKey))
                {
                    ejc = ejcMap.get(ejcKey);
                    ejc.AMI_Modules_Enrolled_AGN__c++;
                    ejc.AMI_Completion_Percentage_AGN__c = ejc.AMI_Completion_Percentage_AGN__c + lp.Module_Percent_AGN__c;
                }
                else
                {
                    ejc = new AMI_HCP_EJ_Completion_AGN__c();
                    ejc.AMI_Modules_Enrolled_AGN__c = 1;
                    ejc.AMI_Completion_Percentage_AGN__c = lp.Module_Percent_AGN__c;
                    ejc.AMI_Account_AGN__c = lp.HCP_AGN__c;
                    
                    ejc.AMI_Total_Modules_AGN__c = ejcCount.get(ejKey);
                    ejc.AMI_Education_Journey_Level_AGN__c = ejKey.split('_')[0];
                    ejc.AMI_Category_AGN__c = ejKey.split('_')[1];
                }
                ejcMap.put(ejcKey, ejc);
                //ejCompletionListUpdate.add(ejc);
            }
        }
        for(String key : ejcMap.keySet())
            ejCompletionListUpdate.add(ejcMap.get(key));
        if(! ejCompletionListUpdate.isEmpty())
            upsert ejCompletionListUpdate;
    }
    
    public class attendeeStatusWrapper
    {
        public Integer requiredModules;
        public Integer completedModules;
        public Integer requiredEvents;
        public Integer completedEvents;
        public Integer requiredCalls;
        public Integer completedCalls;
        public Integer requiredModulesPost;
        public Integer completedModulesPost;
        public Integer requiredEventsPost;
        public Integer completedEventsPost;
        public Integer requiredCallsPost;
        public Integer completedCallsPost;
        public Integer requiredSurvey;
        public Integer completedSurvey;
        public Integer requiredSurveyPost;
        public Integer completedSurveyPost;
        
        public attendeeStatusWrapper()
        {
            requiredModules = completedModules 
                = requiredEvents 
                = completedEvents 
                = requiredCalls 
                = completedCalls 
                = requiredModulesPost 
                = completedModulesPost 
                = requiredCallsPost 
                = completedCallsPost 
                = requiredSurvey 
                = completedSurvey 
                = requiredSurveyPost 
                = completedSurveyPost
                = 0;
        }
    }
}