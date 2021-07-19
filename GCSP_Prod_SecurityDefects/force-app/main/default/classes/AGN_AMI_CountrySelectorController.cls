public class AGN_AMI_CountrySelectorController {
    public string country{get;set;}
    public boolean confirmationRequried {get;set;}
    public boolean confirmation {get; set;}
    public String SelectOptn {get; set;}
    public String confirmationText {get; set;}
    Map<string,string> uniqueCountryList;
    public String privacyLink {get; set;}
    public String tncLink {get; set;}
    public String toURL;
    public String zincNumber {get; set;}
    String PAGENAME = 'AGN_AMI_SiteLanding_Page';
    public List<SelectOption> optns {get;set;}
    List<AMI_URL_Redirect_Settings_AGN__c> lstSettings;
    User user;
    public String userLanguage {get;set;}
    string retURL;
    List<AMI_Page_Zinc_Mapping_AGN__mdt> APZ;
    public String cstmLabel ;
    public AMI_Footer_Visibility_Settings_AGN__c lstFooterVis {get;set;}
    public Boolean is_MENA;
	public String user_country_MENA;
    public AGN_AMI_CountrySelectorController()
    {
        cstmLabel = System.Label.AGN_AMI_Date_Of_Preparation;
        lstSettings=[select Name,Redirect_URL__c,Country_Code__c,Default_Language_AGN__c,Confirmation_Required__c,Confirmation_Text__c,Confirmation_Text_2__c,Secondary_URL__c from AMI_URL_Redirect_Settings_AGN__c order by Name];
        uniqueCountryList=new Map<string,string>();
        optns = new List<SelectOption>();
        user = [Select Country_code__c,LanguageLocaleKey from user where id =: Userinfo.getUserid() limit 1];
        //System.debug(Apexpages.currentPage().getUrl().substringAfterLast('/'));
        toURL = ApexPages.currentPage().getParameters().get('toURL');
        system.debug(toURL);
        //userLanguage = user.LanguageLocaleKey;
		/*AMI MENA changes- Start*/
        is_MENA=false;
        List<AGN_AMI_MENA_Mapping__mdt> menaSettings = new List<AGN_AMI_MENA_Mapping__mdt>([Select AGN_AMI_Child_Country_Code__c,AGN_AMI_Parent_Country_Code__c from AGN_AMI_MENA_Mapping__mdt Where MasterLabel =:ApexPages.currentPage().getParameters().get('country') ]) ;
        if(menaSettings.size() > 0){
            for(AGN_AMI_MENA_Mapping__mdt m:menaSettings){
				user_country_MENA=m.AGN_AMI_Parent_Country_Code__c;
				is_MENA=true;
            }
        }
       	/*AMI MENA changes- End*/ 
        if(ApexPages.currentPage().getParameters().get('country') != null)
        {
            AMI_URL_Redirect_Settings_AGN__c aur = [Select Name 
                                                    from AMI_URL_Redirect_Settings_AGN__c 
                                                    where Country_Code__c = :ApexPages.currentPage().getParameters().get('country') Limit 1];
            country = aur.Name;
            /*AMI MENA changes- Start*/ 
            if(!is_MENA){         
                lstFooterVis = AMI_Footer_Visibility_Settings_AGN__c.getValues(ApexPages.currentPage().getParameters().get('country') );
            }else{       
                lstFooterVis = AMI_Footer_Visibility_Settings_AGN__c.getValues(user_country_MENA );
            }
            /*AMI MENA changes- End*/
        }
        else
        {
            getDefCountryAMIUser(); 
        }  
        for(AMI_URL_Redirect_Settings_AGN__c AUR : lstSettings)
        {
            System.debug(AUR.Name + '--' + country + '--' + (AUR.Name == country)); 
            if(AUR.Name == country)
            {
                optns.clear();
                userLanguage = AMI_URL_Redirect_Settings_AGN__c.getValues(country).Default_Language_AGN__c;
                if(AUR.Confirmation_Text__c != null && AUR.Confirmation_Text_2__c != null)
                {
                    optns.add(new SelectOption('1',AUR.Confirmation_Text__c));
                    optns.add(new SelectOption('2',AUR.Confirmation_Text_2__c));
                }
                confirmationRequried = AUR.Confirmation_Required__c;
                confirmationText = AUR.Confirmation_Text__c;
                if(country=='Canada')
                {
                    privacyLink = System.Label.AGN_AMI_Privacy_Page_CA;
                }
                else
                {
                	privacyLink = System.Label.AGN_AMI_Privacy_Page + '?' + AMI_URL_Redirect_Settings_AGN__c.getValues(country).Redirect_URL__c.substringAfterLast('?');
                }
                //privacyLink = System.Label.AGN_AMI_Privacy_Page + '?' + AMI_URL_Redirect_Settings_AGN__c.getValues(country).Redirect_URL__c.substringAfterLast('?');
                tncLink = System.Label.AGN_AMI_TnC_Page + '?' + AMI_URL_Redirect_Settings_AGN__c.getValues(country).Redirect_URL__c.substringAfterLast('?');
                APZ = [select ZINC_AGN__c,Date_of_Preparation_AGN__c 
                       from AMI_Page_Zinc_Mapping_AGN__mdt 
                       where Page_Name_AGN__c =: PAGENAME
                       and Country_AGN__c =: AMI_URL_Redirect_Settings_AGN__c.getValues(country).Redirect_URL__c.substringAfter('=').substringBefore('&')
                       Limit 1];
                if(APZ.size()>0)
                    zincNumber = APZ[0].ZINC_AGN__c +' '+cstmLabel + ' ' + APZ[0].Date_of_Preparation_AGN__c;
                else
                    zincNumber = ' ';
            }
        }
        if(userLanguage == null)
        {
            userLanguage = lstSettings[0].Default_Language_AGN__c;
            confirmationRequried = lstSettings[0].Confirmation_Required__c;
            if(country=='Canada')
                {
                    privacyLink = System.Label.AGN_AMI_Privacy_Page_CA;
                }
                else
                {
                	privacyLink = System.Label.AGN_AMI_Privacy_Page + '?' +lstSettings[0].Redirect_URL__c.substringAfterLast('?');
                }
            //privacyLink = System.Label.AGN_AMI_Privacy_Page + '?' +lstSettings[0].Redirect_URL__c.substringAfterLast('?');
            tncLink = System.Label.AGN_AMI_TnC_Page + '?' + lstSettings[0].Redirect_URL__c.substringAfterLast('?');
            APZ = [select ZINC_AGN__c,Date_of_Preparation_AGN__c 
                   from AMI_Page_Zinc_Mapping_AGN__mdt 
                   where Page_Name_AGN__c =: PAGENAME
                   and Country_AGN__c =: lstSettings[0].Redirect_URL__c.substringAfter('=').substringBefore('&')
                   Limit 1];
            if(APZ.size()>0)
                zincNumber = APZ[0].ZINC_AGN__c +' '+cstmLabel+ ' ' + APZ[0].Date_of_Preparation_AGN__c;
            else
                zincNumber = ' ';
            confirmationText = lstSettings[0].Confirmation_Text__c;
            if(lstSettings[0].Confirmation_Text__c != null && lstSettings[0].Confirmation_Text_2__c != null)
            {
                optns.clear();
                optns.add(new SelectOption('1',lstSettings[0].Confirmation_Text__c));
                optns.add(new SelectOption('2',lstSettings[0].Confirmation_Text_2__c));
            }
        }
        
    }
    
    public PageReference countryRedirect()
    {
        PageReference pr;
        if(toURL != null)
            pr = new PageReference(Label.AGN_AMI_Site_Country_Selector 
                                                 + '?country=' + AMI_URL_Redirect_Settings_AGN__c.getValues(country).Country_code__c
                                                 + '&toURL=' + EncodingUtil.urlEncode(toURL, 'UTF-8'));
        else
            pr = new PageReference(Label.AGN_AMI_Site_Country_Selector 
                                                 + '?country=' + AMI_URL_Redirect_Settings_AGN__c.getValues(country).Country_code__c);
        
        return pr;
    }
    public void countryChange()
    {
        AMI_URL_Redirect_Settings_AGN__c AUR = AMI_URL_Redirect_Settings_AGN__c.getValues(country);
        confirmationRequried = AMI_URL_Redirect_Settings_AGN__c.getValues(country).Confirmation_Required__c;
        if(country=='Canada')
                {
                    privacyLink = System.Label.AGN_AMI_Privacy_Page_CA;
                }
                else
                {
                	privacyLink = System.Label.AGN_AMI_Privacy_Page + '?' +AUR.Redirect_URL__c.substringAfterLast('?');
                }
        //privacyLink = System.Label.AGN_AMI_Privacy_Page + '?' +AUR.Redirect_URL__c.substringAfterLast('?');
        tncLink = System.Label.AGN_AMI_TnC_Page + '?' + AUR.Redirect_URL__c.substringAfterLast('?');
        APZ = [select ZINC_AGN__c,Date_of_Preparation_AGN__c 
               from AMI_Page_Zinc_Mapping_AGN__mdt 
               where Page_Name_AGN__c =: PAGENAME
               and Country_AGN__c =: AUR.Redirect_URL__c.substringAfter('=').substringBefore('&')
               Limit 1];
        if(APZ.size()>0)
            zincNumber = APZ[0].ZINC_AGN__c +' '+cstmLabel+ ' ' + APZ[0].Date_of_Preparation_AGN__c;
        else
            zincNumber = ' ';        
        if(AUR.Confirmation_Text__c != null && AUR.Confirmation_Text_2__c != null)
        {
            optns.clear();
            optns.add(new SelectOption('1',AUR.Confirmation_Text__c));
            optns.add(new SelectOption('2',AUR.Confirmation_Text_2__c));
            
        }
        confirmationText = AMI_URL_Redirect_Settings_AGN__c.getValues(country).Confirmation_Text__c; 
        //optns.clear();
        //optns.add(new SelectOption('1',lstSettings[0].Confirmation_Text__c));
        //optns.add(new SelectOption('2',lstSettings[0].Confirmation_Text_2__c));
    }
    public List<SelectOption> getcountryList(){
        List<SelectOption> optns = new List<Selectoption>();
        for(AMI_URL_Redirect_Settings_AGN__c country : lstSettings ) 
            uniqueCountryList.put(country.Name, country.Name);          
        for(string countryName : uniqueCountryList.keySet())
            optns.add(new selectOption(countryName, countryName));                     
        return optns;
    }
    public pagereference moveToCommunity()
    {
        
        if(lstSettings!=null && lstSettings.size()>0){
            for(AMI_URL_Redirect_Settings_AGN__c temp:lstSettings){
                if(temp.Name==country){
                    system.debug('agif--'+temp.Redirect_URL__c);
                    if(confirmationRequried)
                    {
                        if(SelectOptn == '1')
                            retURL=temp.Redirect_URL__c;
                        else if(SelectOptn == '2')
                            retURL=temp.Secondary_URL__c;
                        else
                            return null;
                    }
                    else
                        retURL=temp.Redirect_URL__c;
                    
                }
                
            }
        }
        if(toURL != null)
        	retURL = retURL + '&toURL=' + EncodingUtil.urlEncode(toURL, 'UTF-8');
        pagereference pr =new pagereference(retURL);    
        return pr;
    }
    private void getDefCountryAMIUser(){
        country='';
        
        string username='135512';
        string password='4cJuz62SjCx1';
        String retURL='';
        String UserIP=ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        try
        {
            if(UserIP!=null){
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://geoip.maxmind.com/geoip/v2.1/country/'+UserIP);
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                req.setHeader('Authorization', authorizationHeader);            
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