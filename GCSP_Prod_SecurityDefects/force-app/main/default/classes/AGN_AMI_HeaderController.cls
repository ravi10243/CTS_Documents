public without sharing class AGN_AMI_HeaderController {
    
    public String SelSearch { get; set; }
    public Map<string,List<AMI_Learning_AGN__c>> franBasedCurriculum{get;set;}
    set<string> setFran;
    List<string> setFranList;
    public AMI_Web_Visibility_Settings_AGN__c AWV {get; set;}
     // Code change for PMO#3242 Start
    public boolean hideEventSubTab{get; set;}
     // Code change for PMO#3242 End
     // CR#3597 23.09.2020 - G.B --hide my personalise learning & Reset Password links    
    public boolean hideMyProfileLinks {get; private set;}  
    // CR#3598 - hide My Profile & Reset Password links    
    public boolean hideMyProfileLinkSalesRep {get; private set;} 
    public List<string> reversedsetFranList{get;set;}
    List<AMI_Learning_AGN__c> lstTemp;
    public string nameInit{get;set;}
    public string selMod{get;set;}
    public String userCountry{get;set;}
    public String externalCountry {get; set;}
    public String externalLanguage {get; set;}
    public String searchKey {get; set;}
    public string userSessionId{get;set;}
    public String userRole {get; set;}
    
    /* Added for UK Prescribing Information in tab */
    public string botoxLink{get;set;}
    List<AMI_AGN_Redirection_Links__c> lstRedLinks;
    /* end for UK Prescribing Information in tab */
   
    // Added for PMO#3277
    public List<AMI_Certification_AGN__c> certList {get; set;}
    
    // Added for PMO#3262
    public Boolean showInfocus {get; set;}
    public Boolean showVideo {get; set;}
    public Boolean showOthers {get; set;}
    
    public AGN_AMI_HeaderController()
    {
        userSessionId=userinfo.getSessionId();
        userRole = userInfo.getUserRoleId();
        nameInit=UserInfo.getFirstName().substring(0,1)+UserInfo.getLastName().substring(0,1);
        //userCountry = [Select Country_code__c from user where id =: Userinfo.getUserid()].Country_code__c;
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userCountry =  userDetails.userCountryName;
        externalCountry = ApexPages.currentPage().getParameters().get('country');
        externalLanguage = ApexPages.currentPage().getParameters().get('lang');
        franBasedCurriculum=new Map<string,List<AMI_Learning_AGN__c>>();
        
        /* start*/
        lstRedLinks=[select country_AGN__c,
                     Report_Adverse_Event_AGN__c,
                     Botox_AGN__c,
                     Juvederm_AGN__c 
                     from AMI_AGN_Redirection_Links__c
                    where country_AGN__c=:userCountry Limit 1];
        
        botoxLink=lstRedLinks.size()>0?lstRedLinks[0].Botox_AGN__c:'';
        /* end*/
        
        // Comment  for PMO#3172
        // AWV = (externalCountry!=null)?AMI_Web_Visibility_Settings_AGN__c.getValues(externalCountry):AMI_Web_Visibility_Settings_AGN__c.getValues(userCountry);
        // Code change for CR#3172-Start
        if(userDetails.user.Is_AMI_Demo_User_AGN__c == true){
            AWV = AMI_Web_Visibility_Settings_AGN__c.getValues('demo');
            // Code change for PMO#3242 Start
            hideEventSubTab=true;
            // Code change for PMO#3242 Start
        }else{
            AWV = (externalCountry!=null)?AMI_Web_Visibility_Settings_AGN__c.getValues(externalCountry):AMI_Web_Visibility_Settings_AGN__c.getValues(userCountry);
        }
        // Code change for CR#3172-End 
        //Added for POC to hide change password link-Start  
        hideMyProfileLinks = (userDetails.user.Is_AMI_Country_Demo_User_AGN__c || userDetails.user.Is_AMI_Demo_User_AGN__c) ? true: false; 
        //Added for POC to hide change password link-End
        
        // CR#3598 - hide My Profile & Reset Password links- Start
        if(!String.isBlank(userDetails.user.Allergan_Internal_Account_Id__c)){
            hideMyProfileLinkSalesRep = true;
         }else{
           hideMyProfileLinkSalesRep = false;
         }
        // CR#3598 - hide My Profile & Reset Password links- End
        
        setFran=new set<string>();
        setFranList=new List<string>();
        reversedsetFranList=new List<string>();
        List<AMI_Learning_AGN__c> currWithfranchise=[select Id,
                                                     Curriculum_AGN__c,
                                                     toLabel(Franchise_AGN__c )
                                                     from AMI_Learning_AGN__c 
                                                     where Recordtype.Name='Curriculum'
                                                     and Country_AGN__r.Name =: userCountry
                                                     and IsActive_AGN__c=true order by Curriculum_Header_Sequence_AGN__c ASC NULLS LAST];
        System.debug([select Id,
                                                     Curriculum_AGN__c,
                                                     Franchise_AGN__c 
                                                     from AMI_Learning_AGN__c]);
        for(AMI_Learning_AGN__c al:currWithfranchise)
        {
            setFran.add(al.Franchise_AGN__c);
        }
        System.debug('setFran--'+setFran);
        for(string s : setFran)
        {
            setFranList.add(s);
        }
        
        setFranList.sort();
        
        for(Integer i = setFranList.size() - 1; i >= 0; i--){
            reversedsetFranList.add(setFranList[i]);
        }
        for(string fbc: reversedsetFranList)
        {
            lstTemp=new List<AMI_Learning_AGN__c>();
            for(AMI_Learning_AGN__c a: currWithfranchise)
            {
                if(a.Franchise_AGN__c==fbc)
                {
                    
                    lstTemp.add(a);
                    franBasedCurriculum.put(fbc,lstTemp);
                }
            }
            
        }
        
        // Added for PMO#3277
        certList = [SELECT Id, Drop_Down_Label_AGN_AMI__c 
                    FROM AMI_Certification_AGN__c 
                    WHERE Country_code_AGN_AMI__c =: userCountry 
                    AND Active_AGN_AMI__c = true];
        
        // Added for PMO#3262
        showInfocus = false;
        showVideo = false;
        showOthers = false;
        List<AMI_InFocus_AGN__c> trends = [SELECT Id, RecordType.DeveloperName 
                                           FROM AMI_InFocus_AGN__c 
                                           WHERE Country_Code_AGN__c =: userCountry 
                                           AND Active_AGN__c = true 
                                           AND AGN_AMI_Business_Unit__c=: AGN_AMI_SC_Static_Labels.medicalAesthetics];
        for(AMI_InFocus_AGN__c trend : trends){
            system.debug(trend.RecordType.DeveloperName);
            if(trend.RecordType.DeveloperName == 'In_Focus')
                showInfocus = true;
            else if(trend.RecordType.DeveloperName == 'Podcasts')
                showVideo = true;
            else if(trend.RecordType.DeveloperName == 'Others')
                showOthers = true;
        }
        // PMO#3262 - End
    }
    
    
    public pagereference searchRedirect()
    {
        Pagereference pr=new PageReference(System.Label.AGN_AMI_Search_Link);
        pr.setRedirect(true);
        pr.getParameters().put('search',searchKey);  
        if(searchKey == '' || searchKey == null)
            return null;
        else
            return pr;        
    }
    
    // Added for Single User Session - Req 2657
    public pagereference logoutRedirect()
    {
        List<AuthSession> activeSessions = [Select id, LoginHistory.LoginUrl, LoginHistory.LoginTime, IsCurrent from AuthSession 
                                            where UsersId =: Userinfo.getUserid() 
                                            and UserType = 'CspLitePortal' 
                                            and SessionType = 'ChatterNetworks'
                                           ];
        List<User> userList = [Select Id, AMI_Single_Session_Exclusion_AGN__c, UserType from User where Id =: Userinfo.getUserid() Limit 1];
        AuthSession currentSession;
        boolean deactivateSession = false;
        for(AuthSession session : activeSessions)
        {
            if(session.IsCurrent)
                currentSession = session;
        }
        if(currentSession != null)
        {
            for(AuthSession session : activeSessions)
            {
                if(currentSession.LoginHistory.LoginTime < session.LoginHistory.LoginTime)
                    deactivateSession = true;
            }
        }
        System.debug('******' + URL.getCurrentRequestUrl());
        Pagereference pr;
        // If [Multiple User sessions exists and the User is not in exclustion list] or stale session exists
        if((deactivateSession && !userList[0].AMI_Single_Session_Exclusion_AGN__c) || userList[0].UserType == 'Guest')
        {
            pr = new PageReference(System.Label.AGN_AMI_Customer_Portal_Logout_Page_Link);
            pr.setRedirect(true);
        }
        else
            pr = null;
        
        return pr;
    }
}