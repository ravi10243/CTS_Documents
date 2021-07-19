/**
* @description       : Site landing page controller
* @author            : Dev Team
* @group             : 
* @last modified on  : 
* @last modified by  : 
* Modifications Log 
* Ver   Date         Author        Modification
* 1.0   01-12-2018   Dev Team   	Initial Version
**/
public class AGN_OAM_SiteLandingPageController {
    public String userLanguage {get;set;}
    public String selectedCountry {get;set;} 
    public List<SelectOption> options {get;set;}
    Map<string,string> uniqueCountryList;
    List<Site_Landing_Configuration_AGN__mdt> lstSiteData;
    public user userRecord {get;set;}
    String retURL;
    
	public AGN_GCSP_Common_Setting_AGN__mdt commonOktaConfig {get;set;}  
    
    public AGN_OAM_SiteLandingPageController(){
        commonOktaConfig = AGN_GCSP_Utilities.getGCSPCommonSetting();
         if(ApexPages.currentPage().getParameters().get('language') != null){
            userLanguage = ApexPages.currentPage().getParameters().get('language');
        }else {         
            userLanguage = UserInfo.getLocale();
        }     
        system.debug('==========userLanguage========'+userLanguage);
        options = new list<SelectOption>();
        uniqueCountryList = new Map<string,string>();
        lstSiteData = [SELECT ID, MasterLabel, Community_Portal_URL_AGN__c, DeveloperName FROM Site_Landing_Configuration_AGN__mdt WHERE isActive_AGN__c = true order by MasterLabel];
        
    }
    
    public List<SelectOption> getcountryList(){       
        List<SelectOption> optns = new List<Selectoption>();
        for(Site_Landing_Configuration_AGN__mdt country : lstSiteData ) 
            uniqueCountryList.put(country.MasterLabel, country.Community_Portal_URL_AGN__c);          
        for(string countryName : uniqueCountryList.keySet())
            optns.add(new selectOption(countryName, countryName));                     
        return optns;
    }
    
    public pagereference moveToCommunity(){
        System.debug('COUNTRY: '+ selectedCountry);
        String langCode = AGN_GCSP_Country_Lang_Settings__c.getValues(selectedCountry)?.Lang_Code_AGN__c;
        String countryCode = AGN_GCSP_Country_Lang_Settings__c.getValues(selectedCountry)?.Country_Code_AGN__c;
        system.debug('agif--'+lstSiteData);       	
        if(lstSiteData!=null && lstSiteData.size()>0){
            for(Site_Landing_Configuration_AGN__mdt siteData:lstSiteData){
                if(siteData.MasterLabel==selectedCountry){
                    system.debug('agif--'+siteData.Community_Portal_URL_AGN__c);
                    retURL = siteData.Community_Portal_URL_AGN__c;
                }
            }           
        }
        if(String.isNotEmpty(retURL)){
            string landingPage = !String.isEmpty(commonOktaConfig.Redirection_Page__c) ? commonOktaConfig.Redirection_Page__c : '';
                if(!String.isEmpty(langCode) && !String.isEmpty(countryCode)){
                     retURL = retURL+landingPage+'?country='+countryCode+'&language='+langCode;   
                }
                    
            return new PageReference(retURL);
        }
       	
        /* PageReference pageRef = new PageReference(retURL);
       pageRef.setRedirect(true);        
        if(String.isNotBlank(countryCode)){
            pageRef.getParameters().put('country',countryCode); 
        }
        if(String.isNotBlank(langCode)){
            pageRef.getParameters().put('language',langCode); 
        }       
        System.debug('-->pageRef: ' + pageRef);*/
        
        return null;  
    }
    
}