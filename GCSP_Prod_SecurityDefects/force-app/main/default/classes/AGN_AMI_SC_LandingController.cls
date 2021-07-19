// This class is created as the Controller class of the Visualforce Page - AGN_AMI_SC_Landing_Page and Component - AGN_AMI_SC_Landing_Component
// This will control the landing page in AMI Specialty Care portal

public without sharing class AGN_AMI_SC_LandingController {
    public String amiusername{get;set;}
    public String amipassword{get;set;}
    public string emailId {get;set;}
    public Allergan_Customer_Registration_AGN__c custReg{ get; set; }
    List<Country_vod__c>  countryList;   
    String lang_code;
    public string user_country{get;set;}
    public string user_lang{get;set;}
    public AGN_AMI_SC_AGN_Language__mdt defLang {get; set;}
    public string headercountry{get;set;}
    public List<SelectOption> languageList{get;set;}
    public Map<String,String> langList{get;set;}
    String USERNAME_SUFFIX;
    public boolean errorLogin{get;set;}
    public boolean duplicateEmail{get;set;}
    public String defaultLang {get; set;}
    public List<AMI_Landing_Element_AGN__c> lstALC;
    public string video1Text1{get;set;}
    public string video1Text2{get;set;}
    public string video2Text1{get;set;}
    public string video2Text2{get;set;}
    public string video3Text1{get;set;}
    public string video3Text2{get;set;}
    public string Video123Text3{get;set;}
    public string Banner1Text1{get;set;}
    public string Banner1Text2{get;set;}
    public string Banner1Text3{get;set;}
    public string Banner2Text1{get;set;}
    public string Banner2Text2{get;set;}
    public string Banner2Text3{get;set;}
    public string VideoLink1{get;set;}
    public string VideoLink2{get;set;}
    public string VideoLink3{get;set;}
    public string VideoLinkVirtualTour{get;set;}
    public string VideoLinkLearnMore{get;set;}
    public string Poster1Text1{get;set;}
    public string Poster2Text2{get;set;}
    public string Poster3Text3{get;set;}
    public string ImageText1{get;set;}
    public string ImageText2{get;set;}
    public string registrationError{get;set;}
    public boolean Locked{get;set;}
    public boolean lockwarning{get;set;}															//  cr3381  
    public boolean lockedwarning{get;set;}															//  cr3381
    public boolean sessionWarning {get; set;}
    public String casenumber {get; set;}
    
    public AGN_AMI_SC_Web_Visibility_Setting__mdt AWV {get; set;}
    public AGN_AMI_SC_LandingController()
    {   
        Lockwarning=False;																			//CR3381
        errorLogin=False;	
        duplicateEmail=false;
        USERNAME_SUFFIX ='ami';
        emailId=ApexPages.currentPage().getParameters().get('emailId');
        amiusername=string.isBlank(emailId)?'':emailId ;
        custReg=new Allergan_Customer_Registration_AGN__c();
        languageList=new List<SelectOption>();  
        langList = new Map<String,String>();
        countryList = [SELECT Id, Name,AGN_Country_Name__c From Country_vod__c];
      
        if(ApexPages.currentPage().getParameters().get('lang') != null){
            lang_code = ApexPages.currentPage().getParameters().get('lang');
        }
        else{
            lang_code = AGN_AMI_SC_Static_Labels.en_GB;
        }
        if(lang_code==AGN_AMI_SC_Static_Labels.en_US){
            lang_code=AGN_AMI_SC_Static_Labels.en_GB;
        }
        List<AGN_AMI_SC_AGN_Language__mdt> langLst=[Select id,Label,language,AGN_AMI_Lang_Code__c,AGN_AMI_Language__c,DeveloperName from AGN_AMI_SC_AGN_Language__mdt where DeveloperName in(:lang_code,:AGN_AMI_SC_Static_Labels.en_GB)];
        for(AGN_AMI_SC_AGN_Language__mdt l:langLst){
            if(l.Label==(lang_code)){
                defLang=l;
                headerCountry=l.AGN_AMI_Language__c;
            }
        }
        
        languageList.add(new SelectOption(defLang.AGN_AMI_Language__c,defLang.AGN_AMI_Language__c));  
        user_country = ApexPages.currentPage().getParameters().get('country');
    
        user_lang = ApexPages.currentPage().getParameters().get('lang');
        lstALC=new List<AMI_Landing_Element_AGN__c>(); 
        lstALC=[select  Country_Code_AGN__c,Video1_Text1_AGN__c, Video1_Text2_AGN__c, Video2_Text1_AGN__c, Video2_Text2_AGN__c, Video3_Text1_AGN__c, Video3_Text2_AGN__c,
                Video123_Text3_AGN__c, Banner1_Text1_AGN__c, Banner1_Text2_AGN__c, Banner2_Text1_AGN__c, Banner2_Text2_AGN__c, Banner2_Text3_AGN__c,AGN_AMI_Business_Unit__c,
                Video1_Link_AGN__c, Video2_Link_AGN__c, Video3_Link_AGN__c, Video_Link_Virtual_Tour_AGN__c, Video_Link_Learn_More_AGN__c,
                Poster1_AGN__c,Poster2_AGN__c,Poster3_AGN__c,Image_Link_Virtual_Tour_AGN__c,Image_Link_Learn_More_AGN__c, Registration_Error_AGN__c
                from AMI_Landing_Element_AGN__c where Country_Code_AGN__c=: user_country and Language_code_AGN__c =: defLang.AGN_AMI_Lang_Code__c and AGN_AMI_Business_Unit__c=:AGN_AMI_SC_Static_Labels.specialityCare];
        
        if(user_country!=null){
            AWV =[Select id,AMI_Faculty_AGN__c,AMI_Int_Experts_AGN__c,AMI_Team_AGN__c,Community__c,Curricula_Tab__c,Disclaimer__c,Event_Tab_AGN__c,FAQ_Tab_AGN__c,Global_Search__c,Home_Page_Faculty__c,
            Home_Tab__c,In_Focus__c,Learning_Path_Tab__c,Module_Tab__c,Personalization_Option_AGN__c,Prescribing_Information_Header_Tab__c,Profile_Page_AGN__c,Register_Button_AGN__c,
            Workshop_AGN__c,Workshop_Email_List_AGN__c,Workshop_Notification_AGN__c,Workshop_Price_AGN__c from AGN_AMI_SC_Web_Visibility_Setting__mdt where label =:user_country];
        }else{
            AWV =[Select id,AMI_Faculty_AGN__c,AMI_Int_Experts_AGN__c,AMI_Team_AGN__c,Community__c,Curricula_Tab__c,Disclaimer__c,Event_Tab_AGN__c,FAQ_Tab_AGN__c,Global_Search__c,Home_Page_Faculty__c,
            Home_Tab__c,In_Focus__c,Learning_Path_Tab__c,Module_Tab__c,Personalization_Option_AGN__c,Prescribing_Information_Header_Tab__c,Profile_Page_AGN__c,Register_Button_AGN__c,
            Workshop_AGN__c,Workshop_Email_List_AGN__c,Workshop_Notification_AGN__c,Workshop_Price_AGN__c from AGN_AMI_SC_Web_Visibility_Setting__mdt where label =:AGN_AMI_SC_Static_Labels.GB];
        }
        registrationError = lstALC.size()>0?lstALC[0].Registration_Error_AGN__c:'';
        Poster1Text1=lstALC.size()>0?lstALC[0].Poster1_AGN__c:'';
        Poster2Text2=lstALC.size()>0?lstALC[0].Poster2_AGN__c:'';
        Poster3Text3=lstALC.size()>0?lstALC[0].Poster3_AGN__c:'';
        ImageText1=lstALC.size()>0?lstALC[0].Image_Link_Learn_More_AGN__c:'';
        ImageText2=lstALC.size()>0?lstALC[0].Image_Link_Virtual_Tour_AGN__c:'';
        video1Text1=lstALC.size()>0?lstALC[0].Video1_Text1_AGN__c:'';
        video1Text2=lstALC.size()>0?lstALC[0].Video1_Text2_AGN__c:'';
        video2Text1=lstALC.size()>0?lstALC[0].Video2_Text1_AGN__c:'';
        video2Text2=lstALC.size()>0?lstALC[0].Video2_Text2_AGN__c:'';
        video3Text1=lstALC.size()>0?lstALC[0].Video3_Text1_AGN__c:'';
        video3Text2=lstALC.size()>0?lstALC[0].Video3_Text2_AGN__c:'';
        Video123Text3=lstALC.size()>0?lstALC[0].Video123_Text3_AGN__c:'';
        Banner1Text1=lstALC.size()>0?lstALC[0].Banner1_Text1_AGN__c:'';
        Banner1Text2=lstALC.size()>0?lstALC[0].Banner1_Text2_AGN__c:'';        
        Banner2Text1=lstALC.size()>0?lstALC[0].Banner2_Text1_AGN__c:'';
        Banner2Text2=lstALC.size()>0?lstALC[0].Banner2_Text2_AGN__c:'';
        Banner2Text3=lstALC.size()>0?lstALC[0].Banner2_Text3_AGN__c:'';
        VideoLink1=lstALC.size()>0?lstALC[0].Video1_Link_AGN__c:'';
        VideoLink2=lstALC.size()>0?lstALC[0].Video2_Link_AGN__c:'';        
        VideoLink3=lstALC.size()>0?lstALC[0].Video3_Link_AGN__c:'';
        VideoLinkVirtualTour=lstALC.size()>0?lstALC[0].Video_Link_Virtual_Tour_AGN__c:'';
        VideoLinkLearnMore=lstALC.size()>0?lstALC[0].Video_Link_Learn_More_AGN__c:'';
        getLanguage();        
        if(ApexPages.currentPage().getParameters().get('country') == null || ApexPages.currentPage().getParameters().get('lang') == null){
            siteRedirect();
        }
    }
    // The method will fetch the Allegan logo from AGN_AMI_SC_URL_Redirect_Setting__mdt metadata based on Country
     public String getImageName() {
        AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();  
        String userCountryName =  userDetails.userCountryName; 
        String retLogo;
        List<AGN_AMI_SC_URL_Redirect_Setting__mdt> lstAllerganLogo = new List<AGN_AMI_SC_URL_Redirect_Setting__mdt>();
        lstAllerganLogo=[select Label,AGN_AMI_Country_Code__c,AGN_AMI_Logo_Link__c from AGN_AMI_SC_URL_Redirect_Setting__mdt 
                         where AGN_AMI_Country_Code__c =:user_country
                         
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
    //This method will redirect to the Home page Specfic to the country after Successful Login
    public PageReference siteRedirect()
    {
        User user = [Select Id, Profile.Name from User where Id =: UserInfo.getUserId() Limit 1];
        if(user.Profile.Name == AGN_AMI_SC_Static_Labels.AMI_SC_Customer_Community)  
            return new PageReference(Label.AGN_AMI_SC_Home_Page);
        else if(ApexPages.currentPage().getParameters().get('country') == null || ApexPages.currentPage().getParameters().get('lang') == null)
            return new PageReference(Label.AGN_AMI_SC_Site_Landing_Link); 
        else
            return null;
    }
    //This method Displays the Country in Landing page.Mainly used for Australia/New Zealand.For Other Countries it will show that country itself
    public List<SelectOption> getcountryList(){
        List<SelectOption> optns = new List<Selectoption>();
        String countryName = ApexPages.currentPage().getParameters().get('country');
        Map<id,String> uniqueCountryList = new Map<id,String>();
        for(Country_vod__c country : countryList )
        {  
            if(countryName.contains(country.Name))
            {
                custReg.Country_AGN__c=country.Id; 
                if (country.AGN_Country_Name__c == 'Australia')
                    uniqueCountryList.put(country.Id, 'Australia/New Zealand');
                else
                  uniqueCountryList.put(country.Id, country.AGN_Country_Name__c);
            }           
        }  
        for(Id countryId : uniqueCountryList.keySet())
        {  
            optns.add(new selectOption(countryId, uniqueCountryList.get(countryId)));                      
        }
        return optns;
    }   
    //This method Displays the Language specific to Country in Landing page and refernces the AGN_AMI_SC_AGN_Language__mdt metadata .
    public List<SelectOption> getLanguage(){
        Map<String,String> uniqueLanguage = new Map<String,String>();
        languageList = new List<SelectOption>();
        string country = ApexPages.currentPage().getParameters().get('country');
        
        List<AGN_AMI_SC_AGN_Language__mdt> lstLanguages=[Select id,Label,language,AGN_AMI_Lang_Code__c,AGN_AMI_Country__c,AGN_AMI_Language__c,DeveloperName from AGN_AMI_SC_AGN_Language__mdt];
        for( AGN_AMI_SC_AGN_Language__mdt lang : lstLanguages)
        {
            if (lang.AGN_AMI_Country__c == country)
            {
                if(!uniqueLanguage.keySet().contains(lang.AGN_AMI_Lang_Code__c))
                    uniqueLanguage.put(lang.AGN_AMI_Lang_Code__c,lang.AGN_AMI_Language__c);              
                if(lang.DeveloperName != lang_code)                  
                    langList.put(lang.DeveloperName, lang.AGN_AMI_Language__c);
            }
        }
        
        for( string l : uniqueLanguage.keySet()){
            languageList.add(new SelectOption(l , uniqueLanguage.get(l)));
        }
        return languageList;
    }
    //This method is used to Validate the User Login Credentials
    public PageReference amilogin() 
    {
        system.debug('Inside amilogin****>>');
        system.debug(amiusername + '--'+USERNAME_SUFFIX+'--' + amipassword );
        List<User> userList = [Select username, Contact.Account.AGN_AMI_SC_Enabled__c, 
                               contact.Is_AMI_SC_Contact_AGN__c, contact.account.IsPersonAccount from User 
                               where Email =: amiusername.trim()];
        User user;
        List<userLogin> userLoginList ;

        
        if(userList.size() > 0){
        	for(User tempUser : userList)
        	{
         	   if(tempUser.Contact.Account.IsPersonAccount && tempUser.Contact.Account.AGN_AMI_SC_Enabled__c)
        	    { 
          	      user = tempUser;
      	      }
      	      
      	      else if(!tempUser.Contact.Account.IsPersonAccount && tempUser.Contact.Is_AMI_SC_Contact_AGN__c)
      	      {
        	        user = tempUser;
       	     }
      	  }
        }
        
        PageReference pr;
        if (amiusername != '' && amipassword != ''){
            if(user != null)
            {
                userLoginList =  [select userId from userLogin where userId =: user.id and isPasswordLocked=true];
                pr=Site.login(user.username, amipassword,null); 
            }
//            if(pr == null){																											//CR3381
//                system.debug('PR is null');																							//CR3381
//                pr= Site.login(amiusername.trim(), amipassword,null);																	//CR3381 
//            }																															//CR3381
            
            if(pr!=null) {
                system.debug('PR-->'+pr);
                return pr;
            } else {                
                
                if (userLoginList!=null && userLoginList.size()>0)
				{                
                    Locked = true;  
                }
                else
                {
                    errorLogin=true;    
                    integer loginCounter = (integer)AMI_Global_Setting_AGN__c.getInstance().AMI_invalid_login_attempts_AGN__c;
                    integer count=0; 																										//CR3381 Begins                  
                    List<Loginhistory> LoginList;            
                    LoginList = [SELECT logintime,status FROM LoginHistory where userId =: user.id order by LoginTime desc limit :loginCounter];   
                    For(LoginHistory eachrec :  LoginList) 
                    {
                        if (eachrec.Status != 'Invalid Password')//  and (eachrec.Logintime > ts_most_recent)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      )
                        {   break;}
                        else{ count++;}
                    }
                    if(count==(loginCounter-1)) {lockwarning = true;
                                   system.debug('ninth attempt');
                                  }
                    if(count==loginCounter) {lockedwarning = true;
                                   system.debug('Tenth attempt');																			//CR3381 Ends
                                  }  
                   }
                return null;
            }
        }
        else {
            return null;
        }
    }
    
    //This Page is used to Go to the Registration Page
    public PageReference goToRegistrationPage() {
        List<User> lstUser=new List<User>();
        lstUser=[select Id from User where Email =:custReg.Email_AGN__c 
                 and (Contact.Account.AGN_AMI_Enabled__c = true 
                      or contact.Is_AMI_Contact_AGN__c = true)];
        if(lstUser.size()==0)
        {
            
            List<AGN_AMI_SC_AGN_Language__mdt> lstLanguages=[Select id,Label,language,AGN_AMI_Lang_Code__c,AGN_AMI_Country__c,DeveloperName from AGN_AMI_SC_AGN_Language__mdt];
            AGN_AMI_SC_AGN_Language__mdt AL = new AGN_AMI_SC_AGN_Language__mdt();
            for(AGN_AMI_SC_AGN_Language__mdt alTemp : lstLanguages)
            {
                if(alTemp.AGN_AMI_Country__c == user_country && alTemp.AGN_AMI_Lang_code__c == custReg.Language_AGN__c)
                    AL = alTemp;
            }
            string countryCode=custReg.Country_AGN__c;
            List<AMI_Country_Setting_AGN__mdt> countrysettings = new List<AMI_Country_Setting_AGN__mdt>([Select Community_URL__c from AMI_Country_Setting_AGN__mdt Where Developername =:countryCode ]) ;
            string siteURL = countrysettings.isEmpty()? Site.getBaseUrl().removeEnd('/'):countrysettings[0].Community_URL__c;
            List<AGN_AMI_SC_AGN_Redirection_Links__mdt> lstRedLinks=[select AGN_AMI_Country__c,
                     AGN_AMI_Report_Adverse_Event__c,
                     AGN_AMI_Botox__c,
                     AGN_AMI_Juvederm__c,
                     AGN_AMI_About__c,
                     AGN_AMI_Registration_Page__c
                     from AGN_AMI_SC_AGN_Redirection_Links__mdt
                    where AGN_AMI_Country__c=:user_country Limit 1];
            
            string url= siteURL +'/'+lstRedLinks[0].AGN_AMI_Registration_Page__c+'?'+     
                'countryCode='+custReg.Country_AGN__c+
                '&country='+user_country+
                '&userlang='+custReg.Language_AGN__c+
                '&lang='+AL.DeveloperName+
                '&firstName='+custReg.First_Name_AGN__c+
                '&lastName='+custReg.Last_Name_AGN__c+
                '&email='+custReg.Email_AGN__c+
                '&registrationRef='+custReg.Physician_Registration_Reference_AGN__c;
            
            PageReference logInPageUrl = new PageReference(url);
            logInPageUrl.setRedirect(true);
            return logInPageUrl;
        }
        else
        {
            duplicateEmail=true;
            return null;
        }
        
    }
    //This method redirects to the AGN_AMI_SC_Forget_Password page with country and language parameters
    public PageReference goToForgetPassword() {
        String url = System.Label.AGN_AMI_SC_Forget_Link + '?country=' + user_country + '&lang=' + lang_code;    
        PageReference logInPageUrl = new PageReference(url);
        logInPageUrl.setRedirect(true);
        return logInPageUrl;
        
    }
    
    
    // Check if existing user already has a active session
    public void checkUserSession()
    {
        String domainURL = '%'+URL.getCurrentRequestUrl().toExternalForm()+'%';
        List<User> user = [Select id, username, AMI_Single_Session_Exclusion_AGN__c from User 
                           where Email =: amiusername.trim() 
                           and (Contact.Account.AGN_AMI_SC_Enabled__c = true or Contact.Is_AMI_SC_Contact_AGN__c = true)];
        List<AuthSession> activeSessions;
        if(! user.isEmpty())
        {
            activeSessions = [Select id, LoginHistory.LoginUrl from AuthSession 
                              where UsersId =: user[0].Id
                              and UserType = :AGN_AMI_SC_Static_Labels.CspLitePortal
                              and SessionType = :AGN_AMI_SC_Static_Labels.ChatterNetworks
                              ORDER BY ParentId ASC NULLS LAST
                             ];
        }
        
        if(! user.isEmpty())
        {
            if(! activeSessions.isEmpty() && !user[0].AMI_Single_Session_Exclusion_AGN__c)
                sessionWarning = true;
            else
                sessionWarning = false;
        }
    }
    
    // Check for Duplicate Registration before allowing user to go to registration page
    public void checkDuplicateRegistration()
    {
        List<Allergan_Customer_Registration_AGN__c> acr = [Select Id, Case_AGN__r.CaseNumber 
                                                           from Allergan_Customer_Registration_AGN__c 
                                                           where First_Name_AGN__c = :custReg.First_Name_AGN__c 
                                                           and Last_Name_AGN__c = :custReg.Last_Name_AGN__c 
                                                           and Email_AGN__c = :custReg.Email_AGN__c 
                                                           and Country_AGN__c = :custReg.Country_AGN__c 
                                                           and RecordType.DeveloperName = :AGN_AMI_SC_Static_Labels.New_AMI_AGN
                                                           Limit 1];
        if(! acr.isEmpty())
        {
            casenumber = acr[0].Case_AGN__r.CaseNumber;
        }
        else
        {
            casenumber = null;
        }
    }

}