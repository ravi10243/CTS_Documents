// This class is created as the Controller class of the Visualforce Page - AGN_AMI_SC_SiteLanding_Page
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public class AGN_AMI_SC_CountrySelectorController {
    public string country{get;set;}
    public String userCountrycode{get;set;}
    public boolean confirmationRequried {get;set;}
    public boolean confirmation {get; set;}
    public String SelectOptn {get; set;}
    public String confirmationText {get; set;}
    Map<string,string> uniqueCountryList;
    public String privacyLink {get; set;}
    public String tncLink {get; set;}
    public String zincNumber {get; set;}
    String PAGENAME = 'AGN_AMI_SC_SiteLanding_Page';
    public List<SelectOption> optns {get;set;}
    List<AGN_AMI_SC_URL_Redirect_Setting__mdt> lstSettings;
    User user;
    public String userLanguage {get;set;}
    string retURL;
    List<AGN_AMI_SC_Page_Zinc_Mapping__mdt> APZ;
    String cstmLabel ;
    public AGN_AMI_SC_Footer_Visibility_Settings__mdt lstFooterVis {get;set;}
    public AGN_AMI_SC_CountrySelectorController()
    {
        cstmLabel = System.Label.AGN_AMI_SC_Date_Of_Preparation;
        lstSettings=[select Label,AGN_AMI_Redirect_URL__c,AGN_AMI_Country_Code__c,AGN_AMI_Default_Language_AGN__c,AGN_AMI_Confirmation_Required__c,AGN_AMI_Confirmation_Text__c,AGN_AMI_Confirmation_Text_2__c,AGN_AMI_Secondary_URL__c from AGN_AMI_SC_URL_Redirect_Setting__mdt order by Label];
        uniqueCountryList=new Map<string,string>();
        optns = new List<SelectOption>();  
        String dflt_lang;
        String redirectURL;
        user = [Select Country_code__c,LanguageLocaleKey from user where id =: Userinfo.getUserid() limit 1];
        if(ApexPages.currentPage().getParameters().get('country') != null)
        {
            AGN_AMI_SC_URL_Redirect_Setting__mdt aur = [Select label,AGN_AMI_Default_Language_AGN__c,AGN_AMI_Redirect_URL__c,AGN_AMI_Country_Code__c,AGN_AMI_Confirmation_Required__c 
                                                        from AGN_AMI_SC_URL_Redirect_Setting__mdt 
                                                        where AGN_AMI_Country_Code__c = :ApexPages.currentPage().getParameters().get('country') Limit 1];
            country = aur.Label;
            userCountrycode=aur.AGN_AMI_Country_Code__c;
            dflt_lang=aur.AGN_AMI_Default_Language_AGN__c;
            redirectURL=aur.AGN_AMI_Redirect_URL__c;
            //lstFooterVis = AMI_Footer_Visibility_Settings_AGN__c.getValues(ApexPages.currentPage().getParameters().get('country') );
            try{
                lstFooterVis = [Select id,AGN_AMI_About_Page__c,AGN_AMI_Botox_Link__c,AGN_AMI_Botox_Link_Botulinum__c,AGN_AMI_Contact_Us_Page__c,AGN_AMI_Juvederm_Link__c,AGN_AMI_Privacy_Policy_Page_Middle__c,
                                AGN_AMI_Privacy_Policy_Page_Right__c,AGN_AMI_Report_an_Adverse_Event_Link__c,AGN_AMI_Report_Box__c,AGN_AMI_Support_Page__c,AGN_AMI_Terms_and_Conditions_Page_Middle__c,
                                AGN_AMI_Terms_and_Conditions_Page_Right__c from AGN_AMI_SC_Footer_Visibility_Settings__mdt where label =:ApexPages.currentPage().getParameters().get('country')]; 
                
            }
            catch(Exception e){
                system.debug('Select Country again selected');
            }
        }
        else
        {
            getDefCountryAMISCUser(); 
        }  
        for(AGN_AMI_SC_URL_Redirect_Setting__mdt AUR : lstSettings)
        {
            if(AUR.Label == country)
            {
                optns.clear();
                userLanguage = dflt_lang;
                if(AUR.AGN_AMI_Confirmation_Text__c != null && AUR.AGN_AMI_Confirmation_Text_2__c != null)
                {
                    optns.add(new SelectOption('1',AUR.AGN_AMI_Confirmation_Text__c));
                    optns.add(new SelectOption('2',AUR.AGN_AMI_Confirmation_Text_2__c));
                }
                confirmationRequried = AUR.AGN_AMI_Confirmation_Required__c;
                confirmationText = AUR.AGN_AMI_Confirmation_Text__c;
                privacyLink = System.Label.AGN_AMI_SC_Privacy_Page + '?' + aur.AGN_AMI_Redirect_URL__c.substringAfterLast('?');
                tncLink = System.Label.AGN_AMI_SC_TnC_Page + '?' + aur.AGN_AMI_Redirect_URL__c.substringAfterLast('?');
                system.debug('tncLink1-->'+tncLink);
                APZ = [select ZINC_AGN__c,Date_of_Preparation_AGN__c  
                       from AGN_AMI_SC_Page_Zinc_Mapping__mdt 
                       where Page_Name_AGN__c =: PAGENAME
                       and Country_AGN__c =: aur.AGN_AMI_Redirect_URL__c.substringAfter('=').substringBefore('&')
                       Limit 1];
                if(APZ.size()>0)
                    zincNumber = APZ[0].ZINC_AGN__c +' '+cstmLabel + ' ' + APZ[0].Date_of_Preparation_AGN__c;
                else
                    zincNumber = ' ';
            }
        }
        if(userLanguage == null)
        {
            userLanguage = lstSettings[0].AGN_AMI_Default_Language_AGN__c;
            confirmationRequried = lstSettings[0].AGN_AMI_Confirmation_Required__c;
            if(country=='Canada')
            {
                privacyLink = System.Label.AGN_AMI_SC_Privacy_Page_CA;
            }
            else
            {
               
                privacyLink = System.Label.AGN_AMI_SC_Privacy_Page + '?' +lstSettings[0].AGN_AMI_Redirect_URL__c.substringAfterLast('?');
            }
            tncLink = System.Label.AGN_AMI_SC_TnC_Page + '?' + lstSettings[0].AGN_AMI_Redirect_URL__c.substringAfterLast('?');
            
            APZ = [select ZINC_AGN__c,Date_of_Preparation_AGN__c 
                   from AGN_AMI_SC_Page_Zinc_Mapping__mdt 
                   where Page_Name_AGN__c =: PAGENAME
                   and Country_AGN__c =: lstSettings[0].AGN_AMI_Redirect_URL__c.substringAfter('=').substringBefore('&')
                   Limit 1];
            if(APZ.size()>0)
                zincNumber = APZ[0].ZINC_AGN__c +' '+cstmLabel+ ' ' + APZ[0].Date_of_Preparation_AGN__c;
            else
                zincNumber = ' ';
            confirmationText = lstSettings[0].AGN_AMI_Confirmation_Text__c;
            if(lstSettings[0].AGN_AMI_Confirmation_Text__c != null && lstSettings[0].AGN_AMI_Confirmation_Text_2__c != null)
            {
                optns.clear();
                optns.add(new SelectOption('1',lstSettings[0].AGN_AMI_Confirmation_Text__c));
                optns.add(new SelectOption('2',lstSettings[0].AGN_AMI_Confirmation_Text_2__c));
            }
        }        
    }
    // The method will fetch the Allegan logo from AMI_SC_Allergan_Logo__mdt metadata based on Country
    public String getImageName() {
        String retLogo;
        List<AGN_AMI_SC_URL_Redirect_Setting__mdt> lstAllerganLogo = new List<AGN_AMI_SC_URL_Redirect_Setting__mdt>();
        lstAllerganLogo=[select Label,AGN_AMI_Country_Code__c,AGN_AMI_Logo_Link__c from AGN_AMI_SC_URL_Redirect_Setting__mdt 
                         where AGN_AMI_Country_Code__c =:userCountrycode                        
                         limit 1];
        if(lstAllerganLogo.size() > 0)
        {
            for(AGN_AMI_SC_URL_Redirect_Setting__mdt logo:lstAllerganLogo) {
                retLogo=logo.AGN_AMI_Logo_Link__c; 
            }
        }
        else{
            retLogo=[select Label,AGN_AMI_Country_Code__c,AGN_AMI_Logo_Link__c from AGN_AMI_SC_URL_Redirect_Setting__mdt 
                     where AGN_AMI_Country_Code__c =:AGN_AMI_SC_Static_Labels.YZ].AGN_AMI_Logo_Link__c;
        }
        
        return retLogo;
        
    }
    //This Method will reload the Site landing page for the particular country which is selected and add a country parameter to the URL
    public PageReference countryRedirect()
    {
        
        AGN_AMI_SC_URL_Redirect_Setting__mdt aur = [Select label,AGN_AMI_Default_Language_AGN__c,AGN_AMI_Redirect_URL__c,AGN_AMI_Country_Code__c,AGN_AMI_Confirmation_Required__c 
                                                    from AGN_AMI_SC_URL_Redirect_Setting__mdt 
                                                    where label = :country Limit 1];        
        PageReference pr = new PageReference(Label.AGN_AMI_SC_Site_Country_Selector + '?country=' + aur.AGN_AMI_Country_code__c);
        
        return pr;
    }
    //This Method will fetch the redirect URL from  AGN_AMI_SC_URL_Redirect_Setting__mdt metadata
    public void countryChange()
    {
        
        
        AGN_AMI_SC_URL_Redirect_Setting__mdt AUR = [Select label,AGN_AMI_Default_Language_AGN__c,AGN_AMI_Redirect_URL__c,AGN_AMI_Country_Code__c,AGN_AMI_Confirmation_Required__c,AGN_AMI_Confirmation_Text_2__c,AGN_AMI_Confirmation_Text__c
                                                    from AGN_AMI_SC_URL_Redirect_Setting__mdt 
                                                    where label = :country Limit 1];
        
        confirmationRequried = AUR.AGN_AMI_Confirmation_Required__c;
        if(country=='Canada')
        {
            privacyLink = System.Label.AGN_AMI_SC_Privacy_Page_CA;
        }
        else
        {
            privacyLink = System.Label.AGN_AMI_SC_Privacy_Page + '?' +AUR.AGN_AMI_Redirect_URL__c.substringAfterLast('?');
        }
        
        tncLink = System.Label.AGN_AMI_SC_TnC_Page + '?' + AUR.AGN_AMI_Redirect_URL__c.substringAfterLast('?');
       
        APZ = [select ZINC_AGN__c,Date_of_Preparation_AGN__c 
               from AGN_AMI_SC_Page_Zinc_Mapping__mdt 
               where Page_Name_AGN__c =: PAGENAME
               and Country_AGN__c =: AUR.AGN_AMI_Redirect_URL__c.substringAfter('=').substringBefore('&')
               Limit 1];
        if(APZ.size()>0)
            zincNumber = APZ[0].ZINC_AGN__c +' '+cstmLabel+ ' ' + APZ[0].Date_of_Preparation_AGN__c;
        else
            zincNumber = ' ';        
        if(AUR.AGN_AMI_Confirmation_Text__c != null && AUR.AGN_AMI_Confirmation_Text_2__c != null)
        {
            optns.clear();
            optns.add(new SelectOption('1',AUR.AGN_AMI_Confirmation_Text__c));
            optns.add(new SelectOption('2',AUR.AGN_AMI_Confirmation_Text_2__c));
            
        }
        confirmationText = AUR.AGN_AMI_Confirmation_Text__c; 
        
        
    }
    //This method will fetch all the Country names from AGN_AMI_SC_URL_Redirect_Setting__mdt that is displayed in Site landing Page
    public List<SelectOption> getcountryList(){
        List<SelectOption> optns = new List<Selectoption>();
        for(AGN_AMI_SC_URL_Redirect_Setting__mdt country : lstSettings ) 
            uniqueCountryList.put(country.Label, country.Label);          
        for(string countryName : uniqueCountryList.keySet())
            optns.add(new selectOption(countryName, countryName));                     
        return optns;
    }
    //This Method will redirect to the Landing page  or country specific secondary URL.
    public pagereference moveToCommunity()
    {
       
        if(lstSettings!=null && lstSettings.size()>0){
            for(AGN_AMI_SC_URL_Redirect_Setting__mdt temp:lstSettings){
                if(temp.Label==country){
                    
                    if(confirmationRequried)
                    {
                        if(SelectOptn == '1')
                            retURL=temp.AGN_AMI_Redirect_URL__c;
                        else if(SelectOptn == '2')
                            retURL=temp.AGN_AMI_Secondary_URL__c;
                        else
                            return null;
                    }
                    else
                        retURL=temp.AGN_AMI_Redirect_URL__c;
                    
                }
                
            }
        }
        
        pagereference pr =new pagereference(retURL);
        return pr;
    }
    //This is the use the maxmind api to fetch user specific details
    @TestVisible
    private void getDefCountryAMISCUser(){
        country='';
        
        String UserIP= '';
        UserIP = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        if (UserIP == '' || UserIP == null) {
            UserIP=ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP'); 
        }
        if (UserIP == '' || UserIP == null) {
            UserIP=ApexPages.currentPage().getHeaders().get('X-Forwarded-For'); 
        }
        
        system.debug(UserIP);
        try
        {
            if(UserIP!=null){
                HttpRequest req = new HttpRequest();
                /*Named Credential Max Mind Used*/
                req.setEndpoint('callout:AGN AMI Max Mind');                               
                req.setMethod('GET');
                req.setHeader('content-type','application/json');            
                Http http = new Http();
                HTTPResponse res = http.send(req);            
                String retBody=  res.getBody();                 
                Integer reStStatus = res.getStatusCode();
                system.debug('donno--'+retBody);
                AGN_AMI_JsonApex detail1;
                if(retBody!=''){             
                    detail1= (AGN_AMI_JsonApex)JSON.deserialize(retBody, AGN_AMI_JsonApex.class);
                    if(detail1.country.Names.en!=null)
                        country = detail1.country.Names.en;
                }
                system.debug('snStcode--'+detail1.country.Names.en);
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
    }
    
    public class User_IP_Detail
    {
        public String country_name;
        public String country;
        public String city;
    }
    
    
}