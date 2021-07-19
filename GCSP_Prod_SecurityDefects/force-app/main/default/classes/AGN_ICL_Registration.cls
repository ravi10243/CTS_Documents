/* Modified by :ICL Project Team
   Decription : Added line 45 to 49 ,107, and line 163 to 172 as a  part of ICL wave 3 development for cluster country logic.
                Added Two Column Layout for Canada
   Release :ICL Wave-3
*/
public class AGN_ICL_Registration
{
    
    public StringCarrier defaultLanguage {get; set;} 
    public String lang { get; set;}
    public String countrycode { get;set;}
    public String countryname { get;set;}
    public String url { get; set;}
    public List<SelectOption> langlist {get;set;}
    public String selectedlang {get;set;}
    public String headerlang{get;set;}
    public String ICLcookie {get;set;}
    public String ICLOK{get;set;}
    public Boolean is_TwoColumn{get;set;}
    public String Forgotpasslink {get;set;}
    public String username {get;set;}
    public String password {get;set;}
    
    //public String SiteURL {get;set;} 
    //public String SitePrefix {get;set;} 
    public String OKTABASEURL{get;set;}
    public string OKTAOAUTH2ISSUER{get;set;}
    public string OKTAREDIRECTURL{get;set;}
    public String ICLcookieDiv1 {get;set;}
    public String PrivacyLinkURL{get;set;}
    //Vault Code Changes LATAM
    public String VaultCode{get;set;}
    public Boolean isHCPEnabled{get;set;}
    public Boolean is_CLUSTER ;
    public String user_country_CLUSTER ;
    
    public boolean isPortalUnderMaintenance {get;set;}
    public Boolean isValidCountry {get;set;} 
    public Boolean isValidUsername {get;set;} 
    
    public AGN_ICL_Registration(){
        isPortalUnderMaintenance = AGN_ICL_Settings__c.getValues(ApexPages.currentPage().getParameters().get('country')).AGN_ICL_Maintenance_Alert__c;          
        isHCPEnabled = false;
        isValidCountry = false;
        isValidUsername = false;
        lang = ApexPages.currentPage().getParameters().get('lang');
        countrycode=ApexPages.currentPage().getParameters().get('country');
        countryname =AGN_ICL_UtlityClass.getCountry(countrycode);
        headerlang=ApexPages.currentPage().getParameters().get('ref');
        Forgotpasslink = '/AGN_ICLOktaForgotPwd?country='+countrycode+'&lang='+lang;
        
          //Added as a  part of ICL wave 3 development for cluster country logic.
        user_country_CLUSTER = String.escapeSingleQuotes(AGN_ICL_UtlityClass.isCluster(countrycode));
        PrivacyLinkURL = AGN_ICL_PageFooterController.getPrivacyLinkURL(countrycode);
        //added below line for displaying Vault Code at the footer section of the page for Latam Countries
        VaultCode = AGN_ICL_PageFooterController.getFooter(countrycode);////Vault Code Changes LATAM
        isHCPEnabled = AGN_ICL_UtlityClass.getHCPEnableStatus(user_country_CLUSTER);
         //Ends
        if(headerlang==NULL)
        {
            language();
        } 
        else
        {
            changedlanguage();
            
        }  
        this.OKTABASEURL = (String)AGN_ICL_Portal_Settings__c.getInstance().Okta_Base_URL_AGN__c;
        this.OKTAOAUTH2ISSUER = (String)AGN_ICL_Portal_Settings__c.getInstance().Okta_OAuth2_Issuer_AGN__c;
        this.OKTAREDIRECTURL = (String)AGN_ICL_Portal_Settings__c.getInstance().Okta_Redirect_URL_AGN__c;

        
        //this.SiteURL = (String)AGN_ICL_Portal_Settings__c.getInstance().SiteURL_AGN__c;
        //this.SitePrefix = (String)AGN_ICL_Portal_Settings__c.getInstance().SitePrefix_AGN__c;
        
        //PrivacyLinkURL = AGN_ICL_PageFooterController.getPrivacyLinkURL(countrycode);
        //isHCPEnabled = AGN_ICL_UtlityClass.getHCPEnableStatus(countrycode);
        
    } 
    
    public void language()
    {
        
                //------CheckMarx Phase2--Added on 17/09/2020----------On where condition---
          List<AGN_ICL_Country_Settings__c> ic= [SELECT Redirect_URL_AGN__c,Multi_Language_AGN__c,Default_Language_AGN__c, Enable_Two_Column_Layout_AGN__c FROM AGN_ICL_Country_Settings__c where Country_AGN__c=:ApexPages.currentPage().getParameters().get('country')];
                //------CheckMarx Phase2--Ends here----------

        langlist= new List<SelectOption>();
        list<String> l=new list<String>();
        List<String> listvalues=new List<String>();         
        for(AGN_ICL_Country_Settings__c aic:ic)
        {
            url=aic.Redirect_URL_AGN__c ;
            selectedlang=aic.Default_Language_AGN__c;
            listvalues.add(aic.Multi_Language_AGN__c);
            //Added below line for Two column layout for Canada as a part of ICLWave Project
            is_TwoColumn =aic.Enable_Two_Column_Layout_AGN__c;
        }
        
        for(Integer i=0;i<listvalues.size();i++)
        {
            
            l.addAll(listvalues.get(i).split(','));
        }
        
        for(Integer j=0;j<l.size();j++)
        {
            
            langlist.add(new SelectOption(l.get(j),l.get(j)));
            
        }      
        // AGN_ICL_Language_Settings__c ail=[select Language_Code_AGN__c from AGN_ICL_Language_Settings__c where Name=:lang ] ;
            //------CheckMarx Phase2--Added on 17/09/2020----------On where condition---
            //Country_vod__c cv=[select Id from Country_vod__c where Name=:ApexPages.currentPage().getParameters().get('country')];
            //------CheckMarx Phase2--Ends here----
            
            Country_vod__c cv;
        //Added as a  part of ICL wave 3 development for cluster country logic.
        cv=[select Id from Country_vod__c where Name=:user_country_CLUSTER];
        List<Allergan_Consent_Cookie_Info__c > ail=[select Name from Allergan_Consent_Cookie_Info__c where Language__c=:lang and country_code_AGN__c=:cv.Id ] ;
        if(ail.size()>0)
        {
            Allergan_Consent_Cookie_Info__c cookie=[select OkLabel__c,Cookie_Content__c from Allergan_Consent_Cookie_Info__c where Application_Flag_AGN__c='ICL' and Language__c=:lang and country_code_AGN__c=:cv.Id   ];
            ICLcookie =cookie.Cookie_Content__c;
            ICLcookieDiv1 =cookie.Cookie_Content__c.substring(0, cookie.Cookie_Content__c.length()/3);
            ICLOK=cookie.OkLabel__c;         
        }
        if(ail.isEmpty())
        {
            Allergan_Consent_Cookie_Info__c cookie=[select OkLabel__c,Cookie_Content__c from Allergan_Consent_Cookie_Info__c where  Language__c='en_US' limit 1];
            ICLcookie = cookie.Cookie_Content__c;
            ICLcookieDiv1 =cookie.Cookie_Content__c.substring(0, cookie.Cookie_Content__c.length()/3);
            ICLOK=cookie.OkLabel__c;  
        }        
        
    }
    public void changedlanguage()
    {
        
          //------CheckMarx Phase2--Added on 17/09/2020----------On where condition---
          List<AGN_ICL_Country_Settings__c> ic= [SELECT Redirect_URL_AGN__c,Multi_Language_AGN__c,Default_Language_AGN__c FROM AGN_ICL_Country_Settings__c where Country_AGN__c=:ApexPages.currentPage().getParameters().get('country')];
          //------CheckMarx Phase2--Ends here---
        langlist= new List<SelectOption>();
        list<String> l=new list<String>();
        List<String> listvalues=new List<String>();         
        for(AGN_ICL_Country_Settings__c aic:ic)
        {
            url=aic.Redirect_URL_AGN__c ;
            selectedlang=headerlang;
            listvalues.add(aic.Multi_Language_AGN__c);
            
        }
       
        
        for(Integer i=0;i<listvalues.size();i++)
        {
            
            l.addAll(listvalues.get(i).split(','));
           
        }
        
        for(Integer j=0;j<l.size();j++)
        {
            
            langlist.add(new SelectOption(l.get(j),l.get(j)));
            
        }  
        
        
        //AGN_ICL_Language_Settings__c ail=[select Language_Code_AGN__c from AGN_ICL_Language_Settings__c where Name=:lang  ] ;
            //------CheckMarx Phase2--Added on 17/09/2020----------On where condition---
            //Country_vod__c cv=[select Id from Country_vod__c where Name=:ApexPages.currentPage().getParameters().get('country')];
            //------CheckMarx Phase2--Ends here----------
            //Added as a  part of ICL wave 3 development for cluster country logic.
            Country_vod__c cv;
            if(user_country_CLUSTER != null || user_country_CLUSTER != ''){
            is_CLUSTER = true;
        }
        if(!is_CLUSTER){
             cv=[select Id from Country_vod__c where Name=:ApexPages.currentPage().getParameters().get('country')];
        }else{
           
             cv=[select Id from Country_vod__c where Name=:user_country_CLUSTER];
        }
        //End
        List<Allergan_Consent_Cookie_Info__c > ail=[select Name from Allergan_Consent_Cookie_Info__c where Language__c=:lang and country_code_AGN__c=:cv.Id] ;
        if(ail.size()>0)
        {
            Allergan_Consent_Cookie_Info__c cookie=[select OkLabel__c,Cookie_Content__c from Allergan_Consent_Cookie_Info__c where Application_Flag_AGN__c='ICL' and Language__c=:lang and country_code_AGN__c=:cv.Id ];
            ICLcookie =cookie.Cookie_Content__c ;
            ICLcookieDiv1 =cookie.Cookie_Content__c.substring(0, cookie.Cookie_Content__c.length()/3);
            ICLOK=cookie.OkLabel__c;         
        }
        if(ail.isEmpty())
        {
            Allergan_Consent_Cookie_Info__c cookie=[select OkLabel__c,Cookie_Content__c from Allergan_Consent_Cookie_Info__c where Language__c='en_US' limit 1];
            ICLcookie =cookie.Cookie_Content__c ;
            ICLcookieDiv1 =cookie.Cookie_Content__c.substring(0, cookie.Cookie_Content__c.length()/3);
            ICLOK=cookie.OkLabel__c;  
        }
        
    }
    
    
    public Pagereference change() {
        
        String Langcode;
        String LangName;
        
        List<AGN_ICL_Language_Settings__c> icl=[select Name,Language_Code_AGN__c from AGN_ICL_Language_Settings__c where Name=:selectedlang];
        for(AGN_ICL_Language_Settings__c icls:icl)
        {
            //url=icls.Redirect_URL_AGN__c;  
            Langcode=icls.Language_Code_AGN__c; 
            LangName= icls.Name;      
        }
        List<AGN_ICL_Country_Settings__c> ic= [SELECT Redirect_URL_AGN__c,Multi_Language_AGN__c FROM AGN_ICL_Country_Settings__c where Country_AGN__c=:countrycode];   
        for(AGN_ICL_Country_Settings__c aic:ic)
        {
            if(aic.Multi_Language_AGN__c.contains(selectedlang))
                url=aic.Redirect_URL_AGN__c ;
            
        }
        Pagereference pg=new Pagereference(url+'/AGN_ICL_Registration?country='+countrycode+'&lang='+Langcode+'&ref='+LangName);
        pg.setredirect(true);
        return pg;
    }
    
    public PageReference Submit() 
    {
        List<AGN_ICL_Country_Settings__c> ic= [SELECT Redirect_URL_AGN__c,Multi_Language_AGN__c,Default_Language_AGN__c FROM AGN_ICL_Country_Settings__c where Country_AGN__c=:countrycode];
        for(AGN_ICL_Country_Settings__c aic:ic)
        {
            url=aic.Redirect_URL_AGN__c ;
            
        }
        Pagereference pg=new Pagereference(url+'/s/agn-icl-clinicregistration/?language='+lang+'&country='+countrycode);
        pg.setredirect(true);
        return pg;
        
    }      
    
    public PageReference OKTALogin()
    {
        PageReference retpage = null;
        String oktaUser = this.username;
        AGN_ICL_OKTA_Util okta = new AGN_ICL_OKTA_Util();
        String okatMessage = okta.getOktaUserCountry(oktaUser);
        Map < String, Object > m = (Map < String, Object > ) JSON.deserializeUntyped(okatMessage);
        System.debug('m '+ m);
        if((String) m.get('messagetype') == 'SUCCESS')
        {            
            String OktaCountrycode = (String) m.get('countrycode');
            if(countrycode != OktaCountrycode)
            {
                    isValidUsername = false;
                    isValidCountry = true;
                    //apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.AGN_ICL_Registration_Country_mismatch));  
                //}
               
                //retpage = new PageReference('/AGN_ICL_Registration?country='+countrycode+'&lang='+lang);
                //apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.AGN_ICL_Registration_Country_mismatch));
            }
        
            else
            {
                String oktaToken = '';
                AGN_ICL_OKTA_Util.Session oktaSession = new AGN_ICL_OKTA_Util.Session();
                
                Boolean loginSuccessful  = false;
                String oktaError;
                String bodyString = '{ "username" : "'+ oktaUser +'", "password" : "'+ this.password +'" }';
                HttpResponse response = okta.CheckOktaLogin(bodyString);
                if(response != null){
                    if (response.getStatusCode() == 200) { //success
                        String stringResponse = response.getBody();
                        oktaSession = String.isBlank(stringResponse) ? null : AGN_ICL_OKTA_Util.parseToSession(stringResponse);
                        if(nullOrEmpty(oktaSession.cookieToken)){
                            loginSuccessful = false;
                        }
                        else{
                            oktaToken = oktaSession.cookieToken;
                            loginSuccessful = true;
                        }  
                    } else {
                        
                        loginSuccessful = false;
                        retpage = null;   
                    }
                    if(loginSuccessful){
                        
                        String redirectURL = this.OKTAREDIRECTURL;
                        //String retUrl = EncodingUtil.urlEncode('https://allergandev.okta.com/home/salesforce_portal/0oa1ejfqjexdoPawW1d8/1339','UTF-8');
                        String retUrl = EncodingUtil.urlEncode(redirectURL,'UTF-8');
                        retpage = new PageReference(this.OKTABASEURL +'/login/sessionCookieRedirect?token='+ oktaToken +'&redirectUrl=' + retUrl);
                    }
                    else{
                        isValidCountry = false;
                        isValidUsername = true;
                        //apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.AGN_ICL_Authentication_Error));
                        retpage = null;
                    }
                }
                else{
                    isValidCountry = false;
                    isValidUsername = true;
                    //apexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.AGN_ICL_Authentication_Error));
                    retpage = null;
                }
            }
        }else{
            isValidCountry = false;
            isValidUsername = true;
        }
         return retpage;
    }
    
    public static Boolean nullOrEmpty(Object o) {
        return (null == o) ||
            ((o instanceof String) && (0 == ((String)o).trim().length())) ||
            ((o instanceof List<object>) && (0 == ((List<object>)o).size()));
    }
    
}