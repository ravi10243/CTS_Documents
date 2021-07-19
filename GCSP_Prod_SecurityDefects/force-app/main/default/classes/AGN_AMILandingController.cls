public without sharing class AGN_AMILandingController {
    public String amiusername{get;set;}
    public String amipassword{get;set;}
    public string langId {get;set;}
    public string emailId {get;set;}
    public Allergan_Customer_Registration_AGN__c custReg{ get; set; }
    Public list<Country_vod__c>  countryList;   
    public string lang_code;
    public string user_country{get;set;}
    public string user_lang{get;set;}
    public AMI_Language_AGN__c defLang {get; set;}
    public string headercountry{get;set;}
    public List<SelectOption> languageList{get;set;}
    public Map<String,String> langList{get;set;}
    public String USERNAME_SUFFIX;
    public boolean errorLogin{get;set;}
    public boolean expiredLogin {get;set;} //CR 3748
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
    public boolean lockwarning{get;set;}//  cr3381  
    public boolean lockedwarning{get;set;}//  cr3381
    public boolean sessionWarning {get; set;}
    public String casenumber {get; set;}
    public String user_country_MENA {get; set;}
    public Boolean is_MENA {get; set;}
    public Boolean is_Manage_Consent {get; set;}// FOR Brazil LGPD CR
    public String toURL;
    public boolean resetSuccess {get; set;}//CR 3748
    public boolean isDemoUser {get; private set;}// CR 3748
    public AMI_Web_Visibility_Settings_AGN__c AWV {get; set;}
    public String contactUsLink{get; set;} //CR 3932
    
    public AGN_AMILandingController()
    {   
        Lockwarning=False;//cr3381        
        errorLogin=False;
        expiredLogin=False;//CR 3748
        system.debug(ApexPages.currentPage().getParameters().get('country'));
        if(ApexPages.currentPage().getParameters().get('country') != null)
        {
      is_Manage_Consent=[select AMI_Manage_Consent__c from AMI_Web_Visibility_Settings_AGN__c //brazil lgpd cr
        where Name=:ApexPages.currentPage().getParameters().get('country') ].AMI_Manage_Consent__c;
        }
        
        duplicateEmail=false;
        system.debug(ApexPages.currentPage().getParameters().get('country'));
        system.debug(USERNAME_SUFFIX);
        toURL = ApexPages.currentPage().getParameters().get('toURL');
        USERNAME_SUFFIX ='ami';
        system.debug(USERNAME_SUFFIX);
        emailId=ApexPages.currentPage().getParameters().get('emailId');
        system.debug('=emailId='+emailId);
        amiusername=string.isBlank(emailId)?'':emailId ;
        system.debug('=amiusername='+amiusername);
        custReg=new Allergan_Customer_Registration_AGN__c();
        languageList=new List<SelectOption>(); 
        langList = new Map<String,String>();
        countryList = [SELECT Id, Name,AGN_Country_Name__c From Country_vod__c];
        system.debug(ApexPages.currentPage().getParameters().get('lang'));
        if(ApexPages.currentPage().getParameters().get('lang') != null)
            lang_code = ApexPages.currentPage().getParameters().get('lang');
        else
            lang_code = 'en_GB';
        system.debug('=lang_code='+lang_code);
        system.debug('AMI_Language_AGN__c.getvalues(lang_code)>>>'+AMI_Language_AGN__c.getvalues(lang_code));
        defLang=AMI_Language_AGN__c.getvalues(lang_code)!=null?AMI_Language_AGN__c.getvalues(lang_code):AMI_Language_AGN__c.getvalues('en_GB');
        system.debug('=defLang='+defLang);
        headerCountry=defLang!=null?defLang.Language__c:AMI_Language_AGN__c.getvalues('en_GB').Language__c;
        languageList.add(new SelectOption(defLang.Language__c,defLang.Language__c));  
        user_country = ApexPages.currentPage().getParameters().get('country');
        system.debug(ApexPages.currentPage().getParameters().get('country'));
        /*AMI MENA changes- Start*/ 
        is_MENA=false;
        List<AGN_AMI_MENA_Mapping__mdt> menaSettings = new List<AGN_AMI_MENA_Mapping__mdt>([Select AGN_AMI_Child_Country_Code__c,AGN_AMI_Parent_Country_Code__c from AGN_AMI_MENA_Mapping__mdt Where MasterLabel =:user_country ]) ;
        if(menaSettings.size() > 0){
            for(AGN_AMI_MENA_Mapping__mdt m:menaSettings){
                user_country_MENA=m.AGN_AMI_Parent_Country_Code__c;
                is_MENA=true;
            }
        }
        /*AMI MENA changes- End*/ 
        user_lang = ApexPages.currentPage().getParameters().get('lang');
        contactUsLink = System.Label.AGN_AMI_CONTACT_US_Page + '?country=' + user_country + '&lang=' + user_lang;
        lstALC=new List<AMI_Landing_Element_AGN__c>();
        /*AMI MENA changes- Start */
        if(!is_MENA){
            lstALC=[select  Country_Code_AGN__c,Video1_Text1_AGN__c, Video1_Text2_AGN__c, Video2_Text1_AGN__c, Video2_Text2_AGN__c, Video3_Text1_AGN__c, Video3_Text2_AGN__c,
                    Video123_Text3_AGN__c, Banner1_Text1_AGN__c, Banner1_Text2_AGN__c, Banner2_Text1_AGN__c, Banner2_Text2_AGN__c, Banner2_Text3_AGN__c,
                    Video1_Link_AGN__c, Video2_Link_AGN__c, Video3_Link_AGN__c, Video_Link_Virtual_Tour_AGN__c, Video_Link_Learn_More_AGN__c,
                    Poster1_AGN__c,Poster2_AGN__c,Poster3_AGN__c,Image_Link_Virtual_Tour_AGN__c,Image_Link_Learn_More_AGN__c, Registration_Error_AGN__c
                    from AMI_Landing_Element_AGN__c where Country_Code_AGN__c=: user_country and Language_code_AGN__c =: defLang.Lang_Code__c and AGN_AMI_Business_Unit__c=:AGN_AMI_SC_Static_Labels.medicalAesthetics];
        }
        else{
            lstALC=[select  Country_Code_AGN__c,Video1_Text1_AGN__c, Video1_Text2_AGN__c, Video2_Text1_AGN__c, Video2_Text2_AGN__c, Video3_Text1_AGN__c, Video3_Text2_AGN__c,
                    Video123_Text3_AGN__c, Banner1_Text1_AGN__c, Banner1_Text2_AGN__c, Banner2_Text1_AGN__c, Banner2_Text2_AGN__c, Banner2_Text3_AGN__c,
                    Video1_Link_AGN__c, Video2_Link_AGN__c, Video3_Link_AGN__c, Video_Link_Virtual_Tour_AGN__c, Video_Link_Learn_More_AGN__c,
                    Poster1_AGN__c,Poster2_AGN__c,Poster3_AGN__c,Image_Link_Virtual_Tour_AGN__c,Image_Link_Learn_More_AGN__c, Registration_Error_AGN__c
                    from AMI_Landing_Element_AGN__c where Country_Code_AGN__c=: user_country_MENA and Language_code_AGN__c =: defLang.Lang_Code__c and AGN_AMI_Business_Unit__c=:AGN_AMI_SC_Static_Labels.medicalAesthetics];          
        }      
        if(!is_MENA){
            AWV = (user_country!=null)?AMI_Web_Visibility_Settings_AGN__c.getInstance(user_country):AMI_Web_Visibility_Settings_AGN__c.getInstance('GB');
        }else{
            AWV = (user_country!=null)?AMI_Web_Visibility_Settings_AGN__c.getInstance(user_country_MENA):AMI_Web_Visibility_Settings_AGN__c.getInstance('GB');
        }
        /*AMI MENA changes- End */
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
        system.debug(ApexPages.currentPage().getParameters().get('country') + ' __ ' + ApexPages.currentPage().getParameters().get('lang'));
        
        if(ApexPages.currentPage().getParameters().get('country') == null || ApexPages.currentPage().getParameters().get('lang') == null)
            siteRedirect();
    }
    public PageReference siteRedirect()
    {
        User user = [Select Id, Profile.Name from User where Id =: UserInfo.getUserId() Limit 1];
        if(user.Profile.Name == 'AMI Customer Community')  
        {
            if(toURL!=null)
                return new PageReference(EncodingUtil.urlDecode(toURL, 'UTF-8'));
            else
                return new PageReference(Label.AGN_AMI_Home_Page);
        }
        
        else if(ApexPages.currentPage().getParameters().get('country') == null || ApexPages.currentPage().getParameters().get('lang') == null)
            return new PageReference(Label.AGN_AMI_Site_Landing_Link); 
        else
            return null;
    }
    public List<SelectOption> getcountryList(){
        
        List<SelectOption> optns = new List<Selectoption>();
        String countryName = ApexPages.currentPage().getParameters().get('country');
        Map<id,String> uniqueCountryList = new Map<id,String>();
        for(Country_vod__c country : countryList )
        {  
            if(countryName.contains(country.Name))
            {
                custReg.Country_AGN__c=country.Id; 
                //uniqueCountryList.put(country.Id, country.AGN_Country_Name__c);
                //Australia Changes - start
                if (country.AGN_Country_Name__c == 'Australia')
                    uniqueCountryList.put(country.Id, 'Australia/New Zealand');
                else
                    uniqueCountryList.put(country.Id, country.AGN_Country_Name__c);
                //Australia Changes - end
            }           
        }  
        for(Id countryId : uniqueCountryList.keySet())
        {  
            optns.add(new selectOption(countryId, uniqueCountryList.get(countryId)));                      
        }
        return optns;
    }   
    public List<SelectOption> getLanguage(){
        system.debug('Country:' + custReg.Country_AGN__c);
        Map<String,String> uniqueLanguage = new Map<String,String>();
        languageList = new List<SelectOption>();
        string country = ApexPages.currentPage().getParameters().get('country');
        List<AMI_Language_AGN__c> lstLanguages=AMI_Language_AGN__c.getAll().values();
        for( AMI_Language_AGN__c lang : lstLanguages)
        {
            if (lang.Country__c == country)
            {
                if(!uniqueLanguage.keySet().contains(lang.Lang_Code__c))
                    uniqueLanguage.put(lang.Lang_Code__c,lang.Language__c);              
                if(lang.Name != lang_code)                  
                    langList.put(lang.Name, lang.Language__c);
            }
        }
        system.debug('--'+country);
        //system.debug('--'+lang.Country__c);
        for( string l : uniqueLanguage.keySet()){
            languageList.add(new SelectOption(l , uniqueLanguage.get(l)));
        }
        return languageList;
    }
    
    public PageReference amilogin()
    {
        system.debug('Inside amilogin****>>');
        system.debug(amiusername + '--'+USERNAME_SUFFIX+'--' + amipassword );
        //CR#3636 - Added the Is_AMI_Country_Demo_User_AGN__c field in the query to fix the cookie issue
        List<User> userList = [Select username,Is_AMI_Demo_User_AGN__c,IsActive,LastPasswordChangeDate,Is_AMI_Country_Demo_User_AGN__c, Contact.Account.AGN_AMI_Enabled__c, 
                               contact.Is_AMI_Contact_AGN__c, contact.account.IsPersonAccount from User 
                               where Email =: amiusername.trim()];
        User user;
        List<userLogin> userLoginList ;
        // DQ - HCP Harmonization changes start
        for(User tempUser : userList)
        {
            System.debug(tempUser);
            // DQ - HCP Harmonization backward compatibility start
            if(tempUser.Contact.Account.IsPersonAccount && tempUser.Contact.Account.AGN_AMI_Enabled__c)
            {
                AGN_AMI_Veeva_Utility_Class.PreDQHCPLastLoginActivityCreate(tempUser.Id);
                user = tempUser;
            }
            // DQ - HCP Harmonization backward compatibility end
            else if(!tempUser.Contact.Account.IsPersonAccount && tempUser.Contact.Is_AMI_Contact_AGN__c)
            {
                AGN_AMI_Veeva_Utility_Class.PostDQHCPLastLoginActivityCreate(tempUser.Id);
                user = tempUser;
            }
        }
        // DQ - HCP Harmonization changes end
        PageReference pr;
        //FYI - Javascript code should ensure username and password are not empty
        if (amiusername != '' && amipassword != ''){
            //Ckeck if AMI User exist based on email address
            if(user != null){
                userLoginList =  [select userId from userLogin where userId =: user.id and isPasswordLocked=true];
                system.debug('userLoginList' +userLoginList);
                //Check if AMI User is Locked
                if (userLoginList!=null && userLoginList.size()>0){                
                    Locked = true;
                    return null;  
                }else{
                    //CR 3748 
                    datetime dt=user.LastPasswordChangeDate;
                    datetime days= System.today() - integer.valueof(system.label.AGN_AMI_Expire_Day_Limit);                    
                    if(dt.date() < days.date() && user.IsActive==true) //CR 3748 
                    {
                        expiredLogin=True;//CR 3748
                        system.debug('Password Expired');
                        return null;
                    }
                    else
                    {
                        pr=Site.login(user.username, amipassword,null);
                        system.debug('PR' +pr);
                         
                        //Check if password is valid
                        if(pr!=null) {
                            Map<String,Cookie> cookieMap = ApexPages.currentPage().getCookies();
                            if(user.Is_AMI_Demo_User_AGN__c){
                                pr.getParameters().put('retURL', System.Label.AGN_AMI_All_Events_Page);
                            }
                            //CR#3636- Added the logic to fix the cookie issue
                            if(! (user.Is_AMI_Country_Demo_User_AGN__c || user.Is_AMI_Demo_User_AGN__c)){
                                if(cookieMap.containsKey('lastPage')){
                                    Cookie lastPage = cookieMap.get('lastPage');
                                    pr.getParameters().put('retURL', lastPage.getValue());
                                }
                            }
                            if(toURL != null){
                                pr.getParameters().put('retURL', toURL);
                            }
                            system.debug('pr is not null');
                            return pr; 
                        }else{
                            system.debug('Password is invalid');
                            errorLogin = true;
                            //Password is invalid. Start count of attempts
                            integer loginCounter = (integer)AMI_Global_Setting_AGN__c.getInstance().AMI_invalid_login_attempts_AGN__c;
                            integer count=0;                                                    //CR3381 Begins               
                            List<Loginhistory> LoginList;            
                            LoginList = [SELECT logintime,status FROM LoginHistory where userId =: user.id order by LoginTime desc limit :loginCounter];   
                            for(LoginHistory eachrec :  LoginList) {
                                if (eachrec.Status != 'Invalid Password'){   
                                    break;
                                }
                                else{ 
                                    count++;
                                }
                            }
                            if(count==(loginCounter-1)) {
                                lockwarning = true;
                                system.debug('ninth attempt');
                            }
                            if(count==loginCounter) {
                                lockedwarning = true;
                                system.debug('ninth attempt');
                            }      
                        }
                   }
                }
            }else{
                system.debug('Worng Password');
                errorLogin = true;
                return null;
            }
        }
        return null;
    }
    
    //CR 3748 start
    public void SendPasswordResetEmail(){
        List<User> userList = [Select username, Contact.Account.AGN_AMI_Enabled__c,     
                               contact.Is_AMI_Contact_AGN__c, contact.account.IsPersonAccount,Is_AMI_Demo_User_AGN__c,Is_AMI_Country_Demo_User_AGN__c from User     
                               where Email =: amiusername.trim() and isActive = true];
        User user;
        for(User tempUser : userList)
        {
            // DQ - HCP Harmonization backward compatibility start
            if(tempUser.Contact.Account.IsPersonAccount && tempUser.Contact.Account.AGN_AMI_Enabled__c)
            {
                user = tempUser;
            }
            // DQ - HCP Harmonization backward compatibility end
            else if(!tempUser.Contact.Account.IsPersonAccount && tempUser.Contact.Is_AMI_Contact_AGN__c)
            {
                user = tempUser;
            }
        }
        if(user != null && !user.Is_AMI_Country_Demo_User_AGN__c && !user.Is_AMI_Demo_User_AGN__c)   
        {   
            resetsuccess = Site.forgotPassword(user.username); 
            isDemoUser = false; 
        }   
        else{   
            resetSuccess = false;              
            isDemoUser = (user !=null && (user.Is_AMI_Country_Demo_User_AGN__c || user.Is_AMI_Demo_User_AGN__c))? true:false; 
        }  
    }
    //CR 3748 end
    
    public PageReference goToRegistrationPage() {
        system.debug('Inside goToRegistrationPage****>>');
        system.debug('country:' + custReg.Country_AGN__c);
        List<User> lstUser=new List<User>();
        lstUser=[select Id from User where Email =:custReg.Email_AGN__c and IsActive=true 
                 and (Contact.Account.AGN_AMI_Enabled__c = true 
                      or contact.Is_AMI_Contact_AGN__c = true)];
        if(lstUser.size()==0)
        {
            List<AMI_Language_AGN__c> lstLanguages=AMI_Language_AGN__c.getAll().values();
            AMI_Language_AGN__c AL = new AMI_Language_AGN__c();
            for(AMI_Language_AGN__c alTemp : lstLanguages)
            {
                if(alTemp.Country__c == user_country && alTemp.Lang_code__c == custReg.Language_AGN__c)
                    AL = alTemp;
            }
            string countryCode=custReg.Country_AGN__c;
            List<AMI_Country_Setting_AGN__mdt> countrysettings = new List<AMI_Country_Setting_AGN__mdt>([Select Community_URL__c from AMI_Country_Setting_AGN__mdt Where Developername =:countryCode ]) ;
            string siteURL = countrysettings.isEmpty()? Site.getBaseUrl().removeEnd('/'):countrysettings[0].Community_URL__c;
            string url= siteURL +'/'+AMI_AGN_Redirection_Links__c.getvalues(user_country).get('Registration_Page_AGN__c')+'?'+ 
                'countryCode='+custReg.Country_AGN__c+
                '&country='+user_country+
                '&userlang='+custReg.Language_AGN__c+
                '&lang='+AL.Name+
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
    public PageReference goToForgetPassword() {
        String url = System.Label.AGN_AMI_Forget_Link + '?country=' + user_country + '&lang=' + lang_code;    
        PageReference logInPageUrl = new PageReference(url);
        logInPageUrl.setRedirect(true);
        return logInPageUrl;
        
    }
    
    // Added for Single User Session - Req 2657
    // Check if existing user already has a active session
    public void checkUserSession()
    {
        String domainURL = '%'+URL.getCurrentRequestUrl().toExternalForm()+'%';
        List<User> user = [Select id, username, AMI_Single_Session_Exclusion_AGN__c from User 
                           where Email =: amiusername.trim() 
                           and (Contact.Account.AGN_AMI_Enabled__c = true or Contact.Is_AMI_Contact_AGN__c = true)];
        List<AuthSession> activeSessions;
        if(! user.isEmpty())
        {
            activeSessions = [Select id, LoginHistory.LoginUrl from AuthSession 
                              where UsersId =: user[0].Id
                              and UserType = 'CspLitePortal' 
                              and SessionType = 'ChatterNetworks'
                              //and LoginHistory.LoginUrl = :domainURL
                              //and ParentId = null
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
        System.debug(activeSessions);        
        System.debug(sessionWarning);
    }
    
    // Check for Duplicate Registration before allowing user to go to registration page
    public void checkDuplicateRegistration()
    {
        casenumber = 'not duplicate'; 
        List<Allergan_Customer_Registration_AGN__c> acr = [Select Id, Case_AGN__r.CaseNumber
                                                           from Allergan_Customer_Registration_AGN__c 
                                                           where Email_AGN__c = :custReg.Email_AGN__c 
                                                           and Country_AGN__c = :custReg.Country_AGN__c 
                                                           and RecordType.DeveloperName = 'New_AMI_AGN'
                                                           and Rejected_AMI_AGN__c = FALSE
                                                           and Process_AGN__c = FALSE
                                                           Limit 1];
       list<user> lstUser=[select Id from User where Email =: custReg.Email_AGN__c and IsActive=true 
                 and (Contact.Account.AGN_AMI_Enabled__c = true 
                      or contact.Is_AMI_Contact_AGN__c = true)];
        
       if( lstUser.isEmpty())
       {
           if(! acr.isEmpty()){
            casenumber = 'duplicate';    
           }
           else{
              casenumber = 'not duplicate';    
           }
          
       }
        else{
            casenumber = 'not duplicate';    
        }
    }
    
    /* 
* @Author Hijith NS
* @description : Added as part of validation Fix 
*          Method fetch validation info from CustomMetada -AGN_AMI_Layout_Setting__mdt
* @param : country Code
* @date : 02/09/2020
*/
    
    @RemoteAction
    public static List<AGN_AMI_Layout_Setting__mdt> getMetadataVal(String countryCde){
        List<AGN_AMI_Layout_Setting__mdt> mData = new  List<AGN_AMI_Layout_Setting__mdt>();
        Set<String> fieldSet = new Set<String>{'First_Name_AGN__c', 'Last_Name_AGN__c', 'Email_AGN__c'};
            try{
                mData = [SELECT FieldName__c,Regex__c,Max_Length__c,
                         Allowable_Characters__c,Country__c,HelpText__c,
                         MaxLenHelpTxt__c,Exclusion__c,Validate__c,
                         show_invalid_character_error__c,Show_max_length_error__c
                         FROM AGN_AMI_Layout_Setting__mdt 
                         WHERE Country__c=:countryCde AND FieldName__c IN:fieldSet LIMIT 3];
                if(mData.isEmpty()){
                    mData = [SELECT FieldName__c,Regex__c,Max_Length__c,
                             Allowable_Characters__c,Country__c,HelpText__c,
                             MaxLenHelpTxt__c,Exclusion__c,Validate__c,
                             show_invalid_character_error__c,Show_max_length_error__c
                             FROM AGN_AMI_Layout_Setting__mdt 
                             WHERE Country__c='Default' AND FieldName__c IN:fieldSet LIMIT 3]; 
                }
            }
        catch(exception ex){
            AGN_AMI_ErrorLogger.createExceptionsLog(ex,'AGN_AMI_CustRegistrationController_AU','getMetadataVal');
        }
        return mData;
    }
}