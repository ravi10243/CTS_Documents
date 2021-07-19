// This class is created as the Controller class of the Visualforce Components - AGN_AMI_SC_External_Header_Component and AGN_AMI_SC_Header_Component
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public without sharing class AGN_AMI_SC_HeaderController {
    
    public String SelSearch { get; set; }
    public Map<string,List<AMI_Learning_AGN__c>> franBasedCurriculum{get;set;}
    set<string> setFran;
    List<string> setFranList;
    public AGN_AMI_SC_Web_Visibility_Setting__mdt AWV {get; set;}
    public List<string> reversedsetFranList{get;set;}
    List<AMI_Learning_AGN__c> lstTemp;
    public string nameInit{get;set;}
    public string selMod{get;set;}
    public String userCountry{get;set;}
    public String externalCountry {get; set;}
    public String externalLanguage {get; set;}
    public String searchKey {get; set;}
    public string userSessionId{get;set;}
    public string botoxLink{get;set;}
    public String userRole {get; set;} //changes for specialty care portal access
    List<AGN_AMI_SC_AGN_Redirection_Links__mdt> lstRedLinks;
    
    public AGN_AMI_SC_HeaderController()
    {
        userSessionId=userinfo.getSessionId();
        userRole = userInfo.getUserRoleId();//changes for specialty care portal access 
        nameInit=UserInfo.getFirstName().substring(0,1)+UserInfo.getLastName().substring(0,1);
        AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();
        userCountry =  userDetails.userCountryName;
        externalCountry = ApexPages.currentPage().getParameters().get('country');
        externalLanguage = ApexPages.currentPage().getParameters().get('lang');
        franBasedCurriculum=new Map<string,List<AMI_Learning_AGN__c>>();
        
        if(externalCountry!=null){
        lstRedLinks=[select AGN_AMI_Country__c,
                     AGN_AMI_Report_Adverse_Event__c,
                     AGN_AMI_Botox__c,
                     AGN_AMI_Juvederm__c,
                     AGN_AMI_About__c
                     from AGN_AMI_SC_AGN_Redirection_Links__mdt
                     where AGN_AMI_Country__c=:externalCountry Limit 1];
        }
        else
        {
              lstRedLinks=[select AGN_AMI_Country__c,
                     AGN_AMI_Report_Adverse_Event__c,
                     AGN_AMI_Botox__c,
                     AGN_AMI_Juvederm__c,
                     AGN_AMI_About__c
                     from AGN_AMI_SC_AGN_Redirection_Links__mdt
                     where AGN_AMI_Country__c=:userCountry Limit 1];
        }
        
        botoxLink=lstRedLinks.size()>0?lstRedLinks[0].AGN_AMI_Botox__c:'';
        
        
        if(externalCountry!=null){
            AWV =[Select id,AMI_Faculty_AGN__c,AMI_Int_Experts_AGN__c,AMI_Team_AGN__c,Community__c,Curricula_Tab__c,Disclaimer__c,Event_Tab_AGN__c,FAQ_Tab_AGN__c,Global_Search__c,Home_Page_Faculty__c,
                  Home_Tab__c,In_Focus__c,Learning_Path_Tab__c,Module_Tab__c,Personalization_Option_AGN__c,Prescribing_Information_Header_Tab__c,Profile_Page_AGN__c,Register_Button_AGN__c,
                  Workshop_AGN__c,Workshop_Email_List_AGN__c,Workshop_Notification_AGN__c,Workshop_Price_AGN__c from AGN_AMI_SC_Web_Visibility_Setting__mdt where label =:externalCountry];
            
        }else{
            AWV =[Select id,AMI_Faculty_AGN__c,AMI_Int_Experts_AGN__c,AMI_Team_AGN__c,Community__c,Curricula_Tab__c,Disclaimer__c,Event_Tab_AGN__c,FAQ_Tab_AGN__c,Global_Search__c,Home_Page_Faculty__c,
                  Home_Tab__c,In_Focus__c,Learning_Path_Tab__c,Module_Tab__c,Personalization_Option_AGN__c,Prescribing_Information_Header_Tab__c,Profile_Page_AGN__c,Register_Button_AGN__c,
                  Workshop_AGN__c,Workshop_Email_List_AGN__c,Workshop_Notification_AGN__c,Workshop_Price_AGN__c from AGN_AMI_SC_Web_Visibility_Setting__mdt where label =:userCountry];
            
        }
        
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
        
        for(AMI_Learning_AGN__c al:currWithfranchise)
        {
            setFran.add(al.Franchise_AGN__c);
        }
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
        
    }
    // The method will fetch the Allegan logo from AGN_AMI_SC_URL_Redirect_Setting__mdt metadata based on Country
    public String getImageName() {
        AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();  
        String userCountryName =  userDetails.userCountryName;
        String retLogo;
        if(userCountryName==null){
            userCountryName=externalCountry;
        }
        List<AGN_AMI_SC_URL_Redirect_Setting__mdt> lstAllerganLogo = new List<AGN_AMI_SC_URL_Redirect_Setting__mdt>();
        lstAllerganLogo=[select Label,AGN_AMI_Country_Code__c,AGN_AMI_Logo_Link__c from AGN_AMI_SC_URL_Redirect_Setting__mdt                     
                         where AGN_AMI_Country_Code__c =:userCountryName
                         limit 1];
        if(lstAllerganLogo.size() > 0)
        {
            for(AGN_AMI_SC_URL_Redirect_Setting__mdt logo:lstAllerganLogo) {
                retLogo=logo.AGN_AMI_Logo_Link__c; 
            }
        }
        else{
            retLogo=[select Label,AGN_AMI_Country_Code__c,AGN_AMI_Logo_Link__c from AGN_AMI_SC_URL_Redirect_Setting__mdt 
                     where AGN_AMI_Country_Code__c ='GB'].AGN_AMI_Logo_Link__c;
        }
        return retLogo;
        
    }
    //This Method will redirect to the AGN_AMI_SC_Search_Page page.
    public pagereference searchRedirect()
    {
        Pagereference pr=new PageReference(System.Label.AGN_AMI_SC_Search_Link);
        pr.setRedirect(true);
        pr.getParameters().put('search',searchKey);  
        if(searchKey == '' || searchKey == null)
            return null;
        else
            return pr;        
    }
    
    // Single User Session-Logs out the user if it is Idle for 6 secs
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
        Pagereference pr;
        // If [Multiple User sessions exists and the User is not in exclustion list] or stale session exists
        if((deactivateSession && !userList[0].AMI_Single_Session_Exclusion_AGN__c) || userList[0].UserType == 'Guest')
        {
            pr = new PageReference(System.Label.AGN_AMI_SC_Customer_Portal_Logout_Page_Link);
            pr.setRedirect(true);
        }
        else{
            pr = null;
        }
        
        return pr;
    }
    
}