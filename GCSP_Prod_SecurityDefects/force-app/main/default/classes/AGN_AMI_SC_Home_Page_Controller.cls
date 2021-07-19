// This class is created as the Controller class of the Visualforce Page - AGN_AMI_SC_Home_Page
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public without sharing class AGN_AMI_SC_Home_Page_Controller 
{
    User user; 
    Account accountRecord;
    public Contact contactRecord {get; set;}
    public String userCountryName {get;set;}
    public String userLanguage {get; set;}
    public String videoUrl {get;set;}
    public List<AMI_Event_Agenda_AGN__c> lstEvent{get;set;}
    public List<AMI_Event_AGN__c> lstEventRecord{get;set;}
    public List<AMI_Event_AGN__c> lstAllEvent{get; set;}
    public List<AMI_Event_AGN__c> lstLiveEvent{get;set;}
    public List<AMI_Event_Faculty_AGN__c> lstFaculty{get;set;}
    List<RecordType> lstRecordType;
    List<AMI_Learning_Path_AGN__c> curModList;
    public AMI_Learning_Path_AGN__c curMod {get; set;}
    public List<AMI_Path_Session_AGN__c> sessions {get; set;}
    public List<AMI_Lrn_Rel_Dtl_AGN__c> recModList {get; set;}
    public List<AMI_Learning_Path_AGN__c> userModList {get; set;}
    List<AMI_Learning_Path_AGN__c> userModListTemp;
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
    public AGN_AMI_SC_Web_Visibility_Setting__mdt AWV {get; set;}
    public string liveEventRecType;
    public string recEventRecType;
    public string recEventURL{get;set;}
    public date eventToDate {get;set;}
    public AGN_AMI_SC_Home_Page_Controller()
    {
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
        
        
        AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();  
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        // All instances of Account related data fetch updated with this 
        accountRecord = userDetails.accountRecord;
        contactRecord = userDetails.contactRecord;       
        
        AWV=[Select id,AMI_Faculty_AGN__c,AMI_Int_Experts_AGN__c,AMI_Team_AGN__c,Community__c,Curricula_Tab__c,Disclaimer__c,Event_Tab_AGN__c,FAQ_Tab_AGN__c,Global_Search__c,Home_Page_Faculty__c,
             Home_Tab__c,In_Focus__c,Learning_Path_Tab__c,Module_Tab__c,Personalization_Option_AGN__c,Prescribing_Information_Header_Tab__c,Profile_Page_AGN__c,Register_Button_AGN__c,
             Workshop_AGN__c,Workshop_Email_List_AGN__c,Workshop_Notification_AGN__c,Workshop_Price_AGN__c from AGN_AMI_SC_Web_Visibility_Setting__mdt where label =:userCountryName];
        liveEventCount = 0;
        eventNameAGN = ' ';
        
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
        System.debug('lstAllEvent@@@@@' + lstAllEvent);
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
        
        // End of Fetching the Event Agenda 
        
        
        // Fetching the Event Faculty
        lstFaculty = [select AMI_Faculty_AGN__r.Name_AGN__c,
                      AMI_Faculty_AGN__r.Hospital_AGN__c,
                      AMI_Faculty_AGN__r.email_AGN__c, 
                      AMI_Faculty_AGN__r.Image_URL_AGN__c
                      from AMI_Event_Faculty_AGN__c 
                      where AMI_Event_AGN__c =: eventNameAGN 
                      and AMI_Faculty_AGN__r.Country_Code_AGN__c=: user.Country_Code__c limit 1];
        
        eventFacCount = lstFaculty.size();
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
        
        if(curModList.size()>0)
        {
            curMod = curModList[0];
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
        
        getLearningPath();
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
        
    }
    //This Method Fetched the Learning Path of the Specific HCP    
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
    }
    //This module redirects to the  AGN_AMI_SC_Module_Details_Page page when the specific Module is clicked.   
    public PageReference redirectToModulePage()
    {
        moduleId=ApexPages.currentPage().getParameters().get('moduleId');
        PageReference pr = new PageReference(System.Label.AGN_AMI_SC_Module_Details_Page);
        pr.setRedirect(true);
        pr.getParameters().put('lRDId',moduleId);
        return pr;
    }
    public PageReference redirectEventVideo()
    {
        moduleId=ApexPages.currentPage().getParameters().get('recordedWeb');
        return null;
    }
    //This module redirects to the AGN_AMI_SC_Module_Details_Page for the specific Session    
    public PageReference redirectToSession()
    {
        moduleId=ApexPages.currentPage().getParameters().get('moduleId');
        String sessionIdTemp=ApexPages.currentPage().getParameters().get('sessionName');
        List<AMI_Sessions_AGN__c> ListSession = [Select id 
                                                 from AMI_Sessions_AGN__c 
                                                 where Session_Code_AGN__c =: sessionIdTemp 
                                                 and Parent_Module_AGN__c =: curMod.Module__r.Module_AGN__c
                                                 Limit 1];
        if(ListSession.size()>0)
            sessionId=ListSession[0].Id;
        
        PageReference pr = new PageReference(System.Label.AGN_AMI_SC_Module_Details_Page);
        pr.setRedirect(true);
        pr.getParameters().put('lRDId',moduleId);
        pr.getParameters().put('blVideo','true');
        pr.getParameters().put('sessionId',sessionId);
        return pr;
    }
    //This module load the recommended modules for the specific HCP    
    public void getRecommended()
    { 
        recModList = new list<AMI_Lrn_Rel_Dtl_AGN__c>();
        Set<Id> SetUserResc = new Set<Id>();
        set<Id> setUserPersonalizeRec = new Set<Id>();
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
        
        List<AMI_Module_Visibility_AGN__c> LstUserresModule = [Select AMI_Learning_agn__c
                                                               from AMI_Module_Visibility_AGN__c 
                                                               where AMI_Specialty_AGN__c = :SetUserSpec
                                                               and Country_Code__c=: userCountryName];           
        
        
        List<AMI_Module_Visibility_AGN__c> LstpersonalModule = [Select AMI_Learning_agn__c
                                                                from AMI_Module_Visibility_AGN__c 
                                                                where Level_AGN__c=: hcpLevel
                                                                and Category_AGN__c=: hcpcategory 
                                                                and Country_Code__c=: userCountryName];   
        
        
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
                    if(SetUserspecificmodules.contains(alrd.Id) || setUserPersonalizeRec.contains(alrd.Module_AGN__c))
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
        
        AGN_AMI_SC_Web_Visibility_Setting__mdt AWV=[Select id,AMI_Faculty_AGN__c,AMI_Int_Experts_AGN__c,AMI_Team_AGN__c,Community__c,Curricula_Tab__c,Disclaimer__c,Event_Tab_AGN__c,FAQ_Tab_AGN__c,Global_Search__c,Home_Page_Faculty__c,
                                                    Home_Tab__c,In_Focus__c,Learning_Path_Tab__c,Module_Tab__c,Personalization_Option_AGN__c,Prescribing_Information_Header_Tab__c,Profile_Page_AGN__c,Register_Button_AGN__c,
                                                    Workshop_AGN__c,Workshop_Email_List_AGN__c,Workshop_Notification_AGN__c,Workshop_Price_AGN__c from AGN_AMI_SC_Web_Visibility_Setting__mdt where label =:userCountryName];
        if(profileList.size()>0)
        {
            if(!profileList[0].User_Completed_AGN__c && !profileList[0].User_Skipped_AGN__c && AWV.Personalization_Option_AGN__c)
            {
                return new PageReference(System.label.AGN_AMI_SC_Personalization_Page); 
            }
        }
        return null;       
    }
    
    
}