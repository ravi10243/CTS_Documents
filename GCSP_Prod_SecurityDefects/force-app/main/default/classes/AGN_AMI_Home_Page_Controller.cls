public without sharing class AGN_AMI_Home_Page_Controller 
{
    User user; 
    Account accountRecord;
    public Contact contactRecord {get; set;}
    //Id userCountry;
    public String userCountryName {get;set;}
    public String userLanguage {get; set;}
    public String videoUrl {get;set;}
    public List<AMI_Event_Agenda_AGN__c> lstEvent{get;set;}
    public List<AMI_Event_AGN__c> lstEventRecord{get;set;}
    public List<AMI_Event_AGN__c> lstAllEvent{get; set;}
    public List<AMI_Event_AGN__c> lstLiveEvent{get;set;}
    public List<AMI_Event_Faculty_AGN__c> lstFaculty{get;set;}
    public List<RecordType> lstRecordType;
    List<AMI_Learning_Path_AGN__c> curModList;
    public AMI_Learning_Path_AGN__c curMod {get; set;}
    public List<AMI_Path_Session_AGN__c> sessions {get; set;}
    public List<AMI_Lrn_Rel_Dtl_AGN__c> recModList {get; set;}
    public List<AMI_Learning_Path_AGN__c> userModList {get; set;}
    public List<AMI_Learning_Path_AGN__c> userModListTemp;
    public Integer recModCount {get; set;}
    public Integer yourModCount {get; set;}
    public Integer eventFacCount {get;set;}
    public Integer eventConCount {get;set;}
    public Integer recordedWebinarCount {get;set;}
    public Integer eventCount {get;set;}
    public Integer liveEventCount {get;set;}
    public List<AMI_Faculty_AGN__c> amiFaculties {get; set;} 
    public User userName {get; set;}
    public string moduleId {get; set;}
    public string sessionId {get; set;}
    public string sessionName {get; set;}
    public string lastSession {get; set;}
    public string eventName {get; set;}
    public string eventNameAGN {get; set;}
    public string eventLiveEmail {get;set;}
    public string starttime {get;set;}
    public string endtime {get;set;}
    public string eventFrom {get;set;}
    public string eventURL {get;set;}
    public AMI_Web_Visibility_Settings_AGN__c AWV {get; set;}
    public string liveEventRecType;
    public string recEventRecType;
    public string recEventURL{get;set;}
    public date eventToDate {get;set;}
    //Added for LearningPath in Recommended module
    public string getLRDId {get; set;}
    public List<User> lstAmiAdmin;
    public AMI_Lrn_Rel_Dtl_AGN__c objALRD{get;set;}
    public List<AMI_Sessions_AGN__c> lstSession{get;set;}
    public Map<String, List<String>> eventModuleMap {get; set;}
    public Boolean showModuleSection {get; set;}
    public List<AMI_Learning_Path_AGN__c> requiredModulesProgressList {get; set;}
    public List<AMI_Lrn_Rel_Dtl_AGN__c> requiredModulesList {get; set;}
    public List<AGN_AMI_Meeting_Doc__c> agnAMIMeetingDocList {get; set;}
    //public List<AMI_Event_Journey_Controller_AGN__c> postModuleList {get; set;}
    public List<String> requiredModuleNames {get; set;}
    public String ContactFirstName {get; set;}
    public list<AMI_Certification_AGN__c> num_of_cert {get;set;} 
    public contact num_of_ids_cert{get;set;}
    public list<string> listofcertid{get;set;}
    public  list<string> con_listofcertid{get;set;}
    public list <string> not_in_con_listofcertid{get;set;}
    public string certid{get;set;}
    public boolean flagForSec{get; set;}
    public decimal TimeInSeconds{get; set;}

    public AGN_AMI_Home_Page_Controller()
    {
        flagForSec = false;
        lstRecordType = new List <RecordType>();
        lstRecordType = [Select id,SobjectType,DeveloperName from RecordType];
        if(lstRecordType.size() > 0)
        {
            for(RecordType b:lstRecordType)
            {
                if(b.DeveloperName == 'Live')
                    liveEventRecType = b.id;
                if(b.DeveloperName == 'Recorded')
                    recEventRecType = b.id;
            }
        }
        lstAllEvent   = New List<AMI_Event_AGN__c>();
        lstEventRecord = New List<AMI_Event_AGN__c>();
        lstLiveEvent   = New List<AMI_Event_AGN__c>();
        lstFaculty     = New List<AMI_Event_Faculty_AGN__c>();
        //user = [Select contact.AccountId,Country_code__c,LanguageLocaleKey,Email,FirstName,LastName,LocaleSidKey,contact.Account.PersonTitle,contact.Account.Salutation,LastLoginDate  from user where id =: Userinfo.getUserid() limit 1];
        //userName = user;
        //System.debug('The country code is--->' +user.Country_code__c);
        //System.debug('The user email is --->' +user.Email);
        // userId = user.Contact.AccountId;
        //System.debug('The user is is---->' +userId);
        /* userName = user;
        userCountryName = [Select Country_vod__r.name from account where id =: userId limit 1].Country_vod__r.name;
        userLanguage = user.LanguageLocaleKey; */
        
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();  
        userLanguage = userDetails.userLanguage;
        /*AMI MENA changes- Start */
        //userCountryName =  userDetails.userCountryName;
        userCountryName =userDetails.maskedUserCountryName;
        system.debug('userCountryName-->'+userCountryName);
        /*AMI MENA changes- End */
        user =  userDetails.user;
        
        // DQ - HCP Harmonization changes start
        // All instances of Account related data fetch updated with this 
        accountRecord = userDetails.accountRecord;
        contactRecord = userDetails.contactRecord;
        // DQ - HCP Harmonization changes end
        ContactFirstName = contactRecord.FirstName;
        
        AWV = AMI_Web_Visibility_Settings_AGN__c.getValues(userCountryName);
        
        liveEventCount = 0;
        eventNameAGN = ' ';
        //System.Debug('The user language is--->' +userLanguage);
        
        // Fetching the Live Event and Recorded Webinar      
        //calcEvent = [Select Id,Name_AGN__c,Description_AGN__c,Country_AGN__c from AMI_Event_AGN__c where RecordTypeId = '0125E000000HJ7EQAW' 
        //    and Country_AGN__r.Name =: user.Country_Code__c limit 1];
        lstAllEvent = [Select Id,
                       Name_AGN__c,
                       Description_AGN__c,
                       Country_AGN__c,
                       Video_URL_AGN__c,
                       Event_From_AGN__c,
                       Event_To_AGN__c,
                       Active_AGN__c,
                       Language_AGN__c,
                       Anatomy_Area_AGN__c,
                       RecordTypeId,
                       Event_Content_Type_AGN__c,
                       Event_Duration_AGN__c,
                       Image_URL_AGN__c
                       from AMI_Event_AGN__c 
                       where Country_AGN__r.Name =: user.Country_Code__c 
                       and Active_AGN__c = TRUE 
                       and Language_AGN__c =: userLanguage];
        eventCount = lstAllEvent.size();
        //System.debug('eventCount--->' + eventCount);
        //System.debug('The Event URL is--->' + eventURL);
        if(eventCount>0)
        {
            for(AMI_Event_AGN__c a:lstAllEvent)
            {    
                if(a.RecordTypeId == liveEventRecType  && liveEventCount == 0)
                {
                    lstLiveEvent.add(a);
                    eventNameAGN   = a.Id;
                    eventLiveEmail = a.Video_URL_AGN__c + '?vyemail=' + user.Email;
                    eventToDate    = a.Event_To_AGN__c;
                    liveEventCount ++;
                }
                if(a.RecordTypeId == recEventRecType)
                    lstEventRecord.add(a);
            }
        }
        //System.Debug ('Recorded Events are---->' +lstEventRecord);
        recordedWebinarCount = lstEventRecord.size();
        // End of Fetching the Live Event and Recorded Webinar 
        
        // Fetching the Event Agenda   
        lstEvent   = [Select Name_AGN__c,
                      Description_AGN__c,
                      AMI_Event_AGN__c,
                      Sequence_Number_AGN__c,
                      End_Time_AGN__c,
                      Start_Time_AGN__c,
                      Active_AGN__c,
                      Language_AGN__c
                      from AMI_Event_Agenda_AGN__c  
                      where AMI_Event_AGN__c=: eventNameAGN
                      and Country_AGN__r.Name =: user.Country_Code__c and Active_AGN__c = TRUE and Language_AGN__c =: userLanguage ORDER BY Sequence_Number_AGN__c];
        System.debug('Event Agenda--->' +lstEvent);
        
        // End of Fetching the Event Agenda 
        
        
        // Fetching the Event Faculty
        lstFaculty = [select AMI_Faculty_AGN__r.Name_AGN__c,
                      AMI_Faculty_AGN__r.Hospital_AGN__c,
                      AMI_Faculty_AGN__r.email_AGN__c, 
                      AMI_Faculty_AGN__r.Image_URL_AGN__c
                      from AMI_Event_Faculty_AGN__c 
                      where AMI_Event_AGN__c =: eventNameAGN 
                      and AMI_Faculty_AGN__r.Country_Code_AGN__c=: user.Country_Code__c limit 1];
        //System.Debug ('Event Faculty List is----->' +lstFaculty);
        eventFacCount = lstFaculty.size();
        //System.Debug('Faculty Count is--->' +eventFacCount);
        // End of Fetching of Event Faculty 
        
        
        curModList = [Select Id,
                      Module_Name_AGN__c,
                      Curriculum_name_AGN__c,
                      Program_Name_AGN__c,
                      Module__r.Module_AGN__r.Duration_FMA_AGN__c,
                      Module__r.Module_AGN__r.Module_Duration_AGN__c,
                      Module__r.Module_AGN__r.Anatomy_Area_AGN__c,
                      Module__r.Module_AGN__r.Module_format_AGN__c,
                      Module__r.Module_AGN__r.Module_Content_Type_AGN__c,
                      Module__r.Module_AGN__r.AMI_Image_URL_AGN__c
                      from AMI_Learning_Path_AGN__c 
                      where HCP_AGN__c =: accountRecord.Id 
                      and Module_Status_AGN__c = 'In Progress'
                      and Module__r.Active_AGN__c = true
                      order by Last_Attended_AGN__c desc 
                      Limit 1];
        
        //System.debug('curModList--->' + curModList);        
        if(curModList.size()>0)
        {
            if(curModList[0].Module__r.Module_AGN__r.Module_Duration_AGN__c<1){
               TimeInSeconds =  curModList[0].Module__r.Module_AGN__r.Module_Duration_AGN__c*60;
                flagForSec = true;
            }
            system.debug(TimeInSeconds);
            system.debug(flagForSec);
            curMod = curModList[0];
            //sessionList = new list<AMI_Learning_Path_AGN__c>();
            sessions = [Select Id,
                        Percent_Completed_AGN__c,
                        Name_AGN__c,
                        Duration_AGN__c,
                        Session_Code_AGN__c,
                        LastModifiedDate,
                        Session_Status_AGN__c,
                        AMI_Learning_Path_AGN__r.Last_Attended_AGN__c
                        from AMI_Path_Session_AGN__c 
                        where AMI_Learning_Path_AGN__c =: curMod.Id
                        and Active_AGN__c=true];
            
            for(AMI_Path_Session_AGN__c aps : sessions)
            {
                if(aps.Session_Status_AGN__c == 'In Progress' && aps.LastModifiedDate == aps.AMI_Learning_Path_AGN__r.Last_Attended_AGN__c)
                {
                    lastSession = aps.Session_Code_AGN__c;
                    break;
                }
            }
            if(lastSession == null)
            {
                for(AMI_Path_Session_AGN__c aps : sessions)
                {
                    if(aps.Session_Status_AGN__c == 'Not Started')
                    {
                        lastSession = aps.Session_Code_AGN__c;
                        break;
                    }
                }
            }
        }
        system.debug(sessions);
        getLearningPath();
        system.debug(userModList);
        getRecommended();
        recModCount = recModList.size();
        amiFaculties = [select Title_AGN__c,
                        Name_AGN__c,
                        Hospital_AGN__c,
                        email_AGN__c,
                        Image_URL_AGN__c,
                        AMI_Faculty_Description_AGN__c
                        from AMI_Faculty_AGN__c 
                        where Active_AGN__c=true
                        and AMI_Is_Country_Expert_AGN__c= true
                        and AMI_Is_International_Expert_AGN__c <> true
                        and Country_Code_AGN__c=:userCountryName order by Name_AGN__c];
                        
        //Added for post event pop-up logic - Start
        Datetime somedate = Datetime.now().addDays(-15);
        eventModuleMap = new Map<String,List<String>>();
        List<String> requiredModules = new List<String>();
        system.debug(somedate);
        List<Event_Attendee_vod__c>  eventAttendeeList = [Select id,Medical_Event_vod__c,Account_vod__c,Medical_Event_vod__r.End_Time_vod__c from Event_Attendee_vod__c 
                                                          where Account_vod__c =: accountRecord.Id 
                                                          and (Status_vod__c = :AGN_AMI_Static_Labels.attendeeStatusAttended or 
                                                               Status_vod__c = :AGN_AMI_Static_Labels.attendeeStatusPhysically)
                                                          and Medical_Event_vod__r.AMI_Event_Status_AGN__c =:AGN_AMI_Static_Labels.meetingStatusRecorded
                                                          and Medical_Event_vod__r.End_Time_vod__c > :somedate];
        
        System.debug(eventAttendeeList);
        List<AMI_Event_Journey_Controller_AGN__c> postModuleList = new List<AMI_Event_Journey_Controller_AGN__c>();
        Set<Id> eventIdSet = new Set<Id>();
        if(!eventAttendeeList.isEmpty())
        {
            for(Event_Attendee_vod__c ea : eventAttendeeList)
            {
                eventIdSet.add(ea.Medical_Event_vod__c);
            }
            postModuleList = [Select AMI_Learning_Relationship_Detail_AGN__r.Module_Fma_AGN__c,AMI_Meeting_AGN__r.Name, AMI_Meeting_AGN__c,AMI_Meeting_AGN__r.AMI_Event_Status_AGN__c,AMI_Meeting_AGN__r.End_Time_vod__c
                                                                       from AMI_Event_Journey_Controller_AGN__c 
                                                                       where AMI_Meeting_AGN__c in :eventIdSet and 
                                                                       recordtype.developername = :AGN_AMI_Static_Labels.EJCModuleRecordtype
                                                                       and AMI_Type_AGN__c = :AGN_AMI_Static_Labels.EJASTaskTypePost];
            
        }
        

       
            requiredModuleNames = new List<String>();
            if(!postModuleList.isEmpty())
            {
               
                for(AMI_Event_Journey_Controller_AGN__c EJC : postModuleList)
                {
                    //moduleIdList.add(EJC.AMI_Learning_Relationship_Detail_AGN__c);
                    requiredModuleNames.add(EJC.AMI_Learning_Relationship_Detail_AGN__r.Module_Fma_AGN__c);
                }
            }
        
          /* Set<Id> moduleIdList = new Set<Id>();
            if(!postModuleList.isEmpty())
            {
                for(AMI_Event_Journey_Controller_AGN__c EJC : postModuleList)
                {
                    if(eventModuleMap.containsKey(EJC.AMI_Meeting_AGN__r.Name))
                       requiredModules = eventModuleMap.get((EJC.AMI_Meeting_AGN__r.Name));
                    else
                        requiredModules = new List<String>();
                    requiredModules.add(EJC.AMI_Learning_Relationship_Detail_AGN__r.Module_Fma_AGN__c);
                    eventModuleMap.put(EJC.AMI_Meeting_AGN__r.Name, requiredModules);
                }
            }
          
         showModuleSection = !(eventModuleMap.isEmpty()); */
        
         showModuleSection = (!requiredModuleNames.isEmpty());
         System.debug('requiredModuleNames ====' +showModuleSection);
        //Added for post event pop-up logic - End
		list_of_cert();
    }
    
    
    public void getLearningPath()
    {        
        userModList = new List<AMI_Learning_Path_AGN__c>();
        userModListTemp = [Select Id, Module__c, HCP_AGN__c,
                           Module__r.Curriculum_AGN__c,Module__r.Curriculum_Fma_AGN__c,
                           Module__r.Module_AGN__c,Module__r.Module_Fma_AGN__c,
                           Module__r.Program_AGN__c,Module__r.Program_Fma_AGN__c,
                           Module__r.Module_AGN__r.Anatomy_Area_AGN__c,
                           Module__r.Module_AGN__r.Module_Duration_AGN__c,
                           Module__r.Module_AGN__r.AMI_Image_URL_AGN__c,CreatedDate,
                           Module__r.Module_AGN__r.Description_AGN__c,
                           Module__r.Module_AGN__r.Module_Content_Type_AGN__c,
                           Module_Status_AGN__c,
                           Module__r.Module_AGN__r.Module_format_AGN__c
                           from AMI_Learning_Path_AGN__c where HCP_AGN__c =: accountRecord.Id and Module__r.Active_AGN__c = true];
        Integer moduleCount=0;
        for(AMI_Learning_Path_AGN__c ALP : userModListTemp)
        {
            if(ALP.Module_Status_AGN__c == 'In Progress')
                userModList.add(ALP);
        }
        for(AMI_Learning_Path_AGN__c ALP : userModListTemp)
        {
            if(ALP.Module_Status_AGN__c == 'Not Started')
                userModList.add(ALP);
        }
        for(AMI_Learning_Path_AGN__c ALP : userModListTemp)
        {
            if(ALP.Module_Status_AGN__c == 'Completed')
                userModList.add(ALP);
        }  
        yourModCount = userModList.size();
        System.debug('yourModCount--->' + yourModCount); 
    }
    public PageReference redirectToModulePage()
    {
        moduleId=ApexPages.currentPage().getParameters().get('moduleId');
        PageReference pr = new PageReference(System.Label.AGN_AMI_Module_Details_Page);
        pr.setRedirect(true);
        pr.getParameters().put('lRDId',moduleId);
        return pr;
    }
    public PageReference redirectEventVideo()
    {
        moduleId=ApexPages.currentPage().getParameters().get('recordedWeb');
        return null;
    }
    public PageReference redirectToSession()
    {
        moduleId=ApexPages.currentPage().getParameters().get('moduleId');
        String sessionIdTemp=ApexPages.currentPage().getParameters().get('sessionName');
        System.debug(moduleId + sessionIdTemp);
        List<AMI_Sessions_AGN__c> ListSession = [Select id 
                                                 from AMI_Sessions_AGN__c 
                                                 where Session_Code_AGN__c =: sessionIdTemp 
                                                 and Parent_Module_AGN__c =: curMod.Module__r.Module_AGN__c
                                                 Limit 1];
        if(ListSession.size()>0)
            sessionId=ListSession[0].Id;
        
        PageReference pr = new PageReference(System.Label.AGN_AMI_Module_Details_Page);
        pr.setRedirect(true);
        pr.getParameters().put('lRDId',moduleId);
        pr.getParameters().put('blVideo','true');
        pr.getParameters().put('sessionId',sessionId);
        return pr;
    }
    public void getRecommended()
    { 
        system.debug('Inside getRecommended-->');
        /*AMI MENA changes- Start */
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();  
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        system.debug('userCountryName-->'+userCountryName);
        /*AMI MENA changes- End */
        recModList = new list<AMI_Lrn_Rel_Dtl_AGN__c>();
        Set<Id> SetUserResc = new Set<Id>();
        set<Id> setUserPersonalizeRec = new Set<Id>();
        set<Id> setUserVisibility = new Set<Id>();
        Set<Id> SetUserspecificmodules = new Set<Id>();
        Set<Id> SetUserLearningPath = new Set<Id>();
        ID SetUserSpec;
        String SetUsertype;
        List<AMI_HCP_Profile_AGN__c> hCPProfile;
        List<AMI_Learning_Path_AGN__c> userLearningPath = [Select Id,
                                                           Module__r.Module_AGN__c
                                                           from AMI_Learning_Path_AGN__c 
                                                           where HCP_AGN__c =: accountRecord.Id
                                                           and Country_AGN__r.name =: userCountryName];
        System.debug('^^'+userCountryName+userLanguage);
        
        List<AMI_Lrn_Rel_Dtl_AGN__c> lstALRD = [Select Curriculum_AGN__c,
                                                Curriculum_Fma_AGN__c,
                                                Module_AGN__c,
                                                Module_Fma_AGN__c,
                                                Program_AGN__c,
                                                Program_Fma_AGN__c,
                                                Module_AGN__r.Anatomy_Area_AGN__c,
                                                Module_AGN__r.Module_Content_Type_AGN__c,
                                                Module_AGN__r.Tags_AGN__c,
                                                Module_AGN__r.Description_AGN__c,
                                                Module_AGN__r.Module_Duration_AGN__c,
                                                Module_AGN__r.Duration_FMA_AGN__c,
                                                Module_AGN__r.AMI_Image_URL_AGN__c,
                                                Module_AGN__r.AMI_Recommended_AGN__c,
                                                Module_AGN__r.LastModifiedDate,
                                                Module_AGN__r.Module_format_AGN__c,
                                                Country_AGN__c,
                                                Module_AGN__r.Restricted_AGN__c
                                                from AMI_Lrn_Rel_Dtl_AGN__c
                                                where Active_AGN__c = true  //  Module_AGN__r.AMI_Recommended_AGN__c=true and 
                                                and Country_AGN__r.name =: userCountryName
                                                and Language_AGN__c =: userLanguage];
        /* Substituted by accountRecord from AGN_AMI_Utility_class
        List<Account> LstUserDetails = [Select Id,
                                        Name,
                                        AMI_Specialty_AGN__c,
                                        Type_AGN__c,
                                        Country_vod__c
                                        from Account 
                                        where Id =: accountRecord.Id limit 1];
        
        for(Account spec:LstUserDetails)
        {
            SetUserSpec = spec.AMI_Specialty_AGN__c;
            SetUsertype = spec.Type_AGN__c;
            UsrCountry = spec.Country_vod__c;
        }*/
        
        SetUserSpec = accountRecord.AMI_Specialty_AGN__c;
        SetUsertype = accountRecord.Type_AGN__c;
        hCPProfile = [Select Id,
                      Account_AGN__c,
                      Injector_Status_AGN__c,
                      AMI_Education_AGN__c,
                      HCP_Category_AGN__c
                      from AMI_HCP_Profile_AGN__c 
                      where Account_AGN__c = : accountRecord.Id limit 1];
        string injecstatus = hCPProfile.size()>0?hCPProfile[0].Injector_Status_AGN__c:null;  
        String hcpLevel = hCPProfile.size()>0?hCPProfile[0].AMI_Education_AGN__c:null;
        String hcpcategory = hCPProfile.size()>0?hCPProfile[0].HCP_Category_AGN__c:null;
        system.debug('hcpLevel___'+hcpLevel);
        system.debug('hcpcategory==='+hcpcategory);
        system.debug('SetUserSpec##'+SetUserSpec);
        List<AMI_Module_Visibility_AGN__c> LstUserresModule = [Select AMI_Learning_agn__c
                                                               from AMI_Module_Visibility_AGN__c 
                                                               where AMI_Specialty_AGN__c = :SetUserSpec
                                                               and Country_Code__c=: userCountryName];           
        
        //SCTASK0942105 changes Start
        for(AMI_Module_Visibility_AGN__c a:LstUserresModule )
        {
            setUserVisibility.add(a.AMI_Learning_agn__c);
        }
        //SCTASK0942105 changes End
        system.debug(LstUserresModule);
        system.debug(setUserVisibility);
        List<AMI_Module_Visibility_AGN__c> LstpersonalModule = [Select AMI_Learning_agn__c
                                                                from AMI_Module_Visibility_AGN__c 
                                                                where Level_AGN__c=: hcpLevel
                                                                and Category_AGN__c=: hcpcategory 
                                                                and Country_Code__c=: userCountryName];   
       
        system.debug('LstpersonalModule&&&'+LstpersonalModule);
        
        for(AMI_Module_Visibility_AGN__c a:LstpersonalModule )
        {
            setUserPersonalizeRec.add(a.AMI_Learning_agn__c);
        }
        for(AMI_Learning_Path_AGN__c ALP : userLearningPath)
        {
            SetUserLearningPath.add(ALP.Module__r.Module_AGN__c);
        }
        List<AMI_HCP_modules_AGN__c  > LstUserspecModule =[Select AMI_Module_AGN__c
                                                           from AMI_HCP_modules_AGN__c  
                                                           where AMI_Account_AGN__c = : accountRecord.Id ];   
        
        
        for(AMI_HCP_modules_AGN__c b:LstUserspecModule )
        {
            SetUserspecificmodules.add(b.AMI_Module_AGN__c);
        } 
        for(AMI_Lrn_Rel_Dtl_AGN__c alrd:lstALRD) 
        {   
            if(alrd.Module_AGN__r.AMI_Recommended_AGN__c){
                if(alrd.Module_AGN__r.Restricted_AGN__c)
                {
                    if(SetUserspecificmodules.contains(alrd.Id) || setUserVisibility.contains(alrd.Module_AGN__c))
                    {
                        if(!SetUserLearningPath.contains(alrd.Module_AGN__c))
                        {
                            recModList.add(alrd);
                        }
                    }
                }
                else
                {        
                    
                    if(!SetUserLearningPath.contains(alrd.Module_AGN__c))
                    {   
                        if(!recModList.contains(alrd))
                        {
                            recModList.add(alrd);
                        }
                    }                
                }
            }   
            else{
                if(setUserPersonalizeRec.contains(alrd.Module_AGN__c)){
                    if(!SetUserLearningPath.contains(alrd.Module_AGN__c))
                    {
                        recModList.add(alrd);
                    }
                }
            }
        }                                                    
    } 
    // Personalization Redirect Method
    public PageReference redirectPersonalization()
    {
        List<AMI_HCP_Profile_AGN__c> profileList = [SELECT Id,User_Completed_AGN__c,User_Skipped_AGN__c 
                                                    FROM AMI_HCP_Profile_AGN__c 
                                                    WHERE Account_AGN__c =: accountRecord.Id
                                                    Limit 1];
        AMI_Web_Visibility_Settings_AGN__c AWV = AMI_Web_Visibility_Settings_AGN__c.getInstance(userCountryName);
        if(profileList.size()>0)
        {
            if(!profileList[0].User_Completed_AGN__c && !profileList[0].User_Skipped_AGN__c && AWV.Personalization_Option_AGN__c)
            {
                return new PageReference(System.label.AGN_AMI_Personalization_Page); 
            }
        }
        return null;       
    }
    public PageReference addtoLearningPath(){
        system.debug('Entering function@@@@@@');
        /*AMI MENA changes- Start */
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userCountryName =userDetails.maskedUserCountryName;
        /*AMI MENA changes- End */
        getLRDId    =   ApexPages.currentPage().getParameters().get('getLRDId');   
        system.debug('getLRDId@@@@' + getLRDId);
        system.debug('userCountryName@@@@' + userCountryName);
        string lpRecOwner = AMI_User_Settings_AGN__c.getValues(userCountryName).LP_Record_Owner_AGN__c;
        system.debug('userCountryName@@@@' + lpRecOwner);
        lstAmiAdmin=[select Id from user where UserName=:lpRecOwner Limit 1];
                        system.debug('lRDId:' + getLRDId);
        AMI_Learning_Path_AGN__c  objALP    = new AMI_Learning_Path_AGN__c();
        
        objALRD=[Select Curriculum_AGN__r.Curriculum_AGN__c,Curriculum_AGN__r.Id,
                 CurrencyIsoCode,Program_AGN__r.Program_AGN__c,
                 Country_AGN__r.Country_Name_vod__c,
                 Country_AGN__c,Module_AGN__r.Id,Curriculum_Fma_AGN__c,Program_Fma_AGN__c 
                 from AMI_Lrn_Rel_Dtl_AGN__c 
                 where id=:getLRDId limit 1];
        
        
        lstSession=[select Id,Name_AGN__c,Session_Code_AGN__c, Content_Type_AGN__c,Duration_AGN__c,File_name_AGN__c,Parent_Module_AGN__r.Module_Content_Type_AGN__c,
                    Status_AGN__c, Training_URL_AGN__c,ZINC_number_AGN__c, Sequence_Number_AGN__c
                    from AMI_Sessions_AGN__c 
                    where Parent_Module_AGN__c=: objALRD.Module_AGN__r.Id and IsActive_AGN__c = true
                    order by Sequence_Number_AGN__c asc];
        system.debug('lstSession-->'+lstSession);
        List<AMI_Path_Session_AGN__c> lstAPSess=new List<AMI_Path_Session_AGN__c>();
        
                
            objALP.HCP_AGN__c= accountRecord.Id;
            objALP.Contact_AGN__c = contactRecord.Id;
            //objALP.Module__c=Id.Valueof(ApexPages.currentPage().getParameters().get('lRDId'));
            objALP.Module__c=ApexPages.currentPage().getParameters().get('getLRDId');
            /*AMI MENA changes- Start*/ 
            objALP.Country_AGN__c=[Select id from Country_vod__c where Name=:userCountryName].id;
            objALP.Country_code_AGN__c=userCountryName;
            /*AMI MENA changes- End */
            objALP.OwnerId=lstAmiAdmin.size()>0?lstAmiAdmin[0].Id:Userinfo.getUserid();
            objALP.CurrencyIsoCode=objALRD.CurrencyIsoCode;
            objALP.RecordTypeId= [Select id from RecordType where SobjectType = 'AMI_Learning_Path_AGN__c' AND DeveloperName = 'AGN_Defined'][0].id;
            System.debug('The Record Type Id is--->' +objALP.RecordTypeId);
            if(objALP!= null)
            {
                try
                {
                    insert objALP;
                }
                Catch(DMLException ex)
                {
                    AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Module_Detail_Controller','AddCurrToLearningPath');
                } 
            }
            for(AMI_Sessions_AGN__c objSess:lstSession)
                lstAPSess.add(new AMI_Path_Session_AGN__c(AMI_Learning_Path_agn__c=objALP.Id,
                                                           Duration_AGN__c=objSess.Duration_AGN__c,
                                                          File_name_AGN__c=objSess.File_name_AGN__c,
                                                          Name_AGN__c=objSess.Name_AGN__c,
                                                          ZINC_number_AGN__c=objSess.ZINC_number_AGN__c,
                                                          Training_URL_AGN__c=objSess.Training_URL_AGN__c,
                                                          Session_Code_AGN__c=objSess.Session_Code_AGN__c,
                                                          Active_AGN__c = true));
            
            if(lstAPSess!=null)  
            {
                try
                {
                    insert lstAPSess;
                }
                Catch(DMLException ex)
                {
                    AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_Module_Detail_Controller','AddCurrToLearningPath');
                }
            }
        
        System.debug('objALPId@@@'+objALP.Id);
        return null;
    }
	
    public PageReference redirect_to_cpd(){
        
        string certid1=ApexPages.currentPage().getParameters().get('certificateId2');
        PageReference pageRef = new PageReference('/AMI/AGN_AMI_CPD_Course_Page');
       pageRef.getParameters().put('certId',certid1);
        pageRef.setRedirect(true);
        
        return pageRef;    
        
    }
    
    /*adding visited certificateid to certificate_visit field in contact object*/
    public PageReference update_for_close()
    {
        certid=ApexPages.currentPage().getParameters().get('certificateId');
        String clickSource = ApexPages.currentPage().getParameters().get('clickSource');
        //string certificateid=ApexPages.currentPage().getParameters().get('certificateId');
      
        contact addvisit=[SELECT Certificate_visits_AGN_AMI__c 
                          FROM contact 
                          WHERE id =: contactRecord.Id ];
        addvisit.Certificate_visits_AGN_AMI__c= (addvisit.Certificate_visits_AGN_AMI__c!=null) 
            ? addvisit.Certificate_visits_AGN_AMI__c+';'+certid : certid;
        
        UPDATE addvisit;
        
        PageReference pageRef;
        if(clickSource == 'link') {
            pageRef = new PageReference('/AMI/AGN_AMI_CPD_Course_Page');
            pageRef.getParameters().put('certId',certid);
            pageRef.setRedirect(true);
        }
        
        return pageRef;
        
    }
    /*3277 to show pop-up certificate component 
     if certificate id is not present in the 
    certificate_visit field in contact object*/
    
    public void list_of_cert()
    {
        not_in_con_listofcertid=new list<string>();
        num_of_ids_cert=[SELECT Certificate_visits_AGN_AMI__c, accountid
                         FROM contact
                         WHERE Id = :contactRecord.Id LIMIT 1]; 
        List<String> certificatesViewed = (num_of_ids_cert.Certificate_visits_AGN_AMI__c!= null)
            ? num_of_ids_cert.Certificate_visits_AGN_AMI__c.split(';') : new List<String>();
        
        num_of_cert=[SELECT id, Name,Active_AGN_AMI__c,Certificate_Location_AGN_AMI__c,Certificate_Logo_AGN_AMI__c, 
                     Certificate_Zinc_Code_AGN_AMI__c, Country_AGN_AMI__c,Country_code_AGN_AMI__c,
                     Course_Description_AGN_AMI__c,CPD_Points_AGN_AMI__c,Curriculum_Banner_AGN_AMI__c,Disclaimer_AGN_AMI__c,
                     First_Signature_Image_AGN_AMI__c,First_Signature_Text_AGN_AMI__c,Second_Signature_Image_AGN_AMI__c,
                     Second_Signature_Text_AGN_AMI__c,Description_AGN_AMI__c,Unique_Number_AGN_AMI__c,Valid_From_AGN_AMI__c,
                     Valid_Through_AGN_AMI__c
                     FROM AMI_Certification_AGN__c
                     WHERE Id NOT IN :certificatesViewed 
                     AND ShowPopup_AGN_AMI__c = TRUE 
                     AND Country_code_AGN_AMI__c =: userCountryName 
                     AND Active_AGN_AMI__c = true];
        
    }
}