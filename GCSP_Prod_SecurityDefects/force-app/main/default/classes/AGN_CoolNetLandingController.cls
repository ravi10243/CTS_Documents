public without sharing class AGN_CoolNetLandingController
{
    public Map<String,String> MapVar {get;set;}
    public String Country {get;set;}
    public string error{get;set;}
    public boolean isVisible {get;set;}
    public Map<String,CoolNet_AGN_Redirection_Link__c> mapCountryToUrlSeting;
    
    public AGN_CoolNetLandingController() {
        MapVar = new Map<String,String>();
        isVisible = false;
        mapCountryToUrlSeting = new Map<String,CoolNet_AGN_Redirection_Link__c>();
        System.debug('coolNetLoggedInUser## '+UserInfo.getUserId());
        
 
    }
    
    //NaviagteToOrg - Redirecting to the login page.
    public pagereference NaviagteToOrg(){
        System.debug('COUNTRY: '+ Country);
        String navigateurl;
        String regionStr; 
        if(!MapVar.isEmpty() && MapVar.containsKey(Country)){
            navigateurl = MapVar.get(Country); 
        }
        if(!mapCountryToUrlSeting.isEmpty() && mapCountryToUrlSeting.containsKey(Country)){
            navigateurl = navigateurl + '/' + mapCountryToUrlSeting.get(Country).Redirection_Page_AGN__c; 
            regionStr = mapCountryToUrlSeting.get(Country).Country_AGN__c;
        }
        if(Country!='Select'){
            System.debug('NAVIGATE : ' + navigateurl);
            PageReference pageRef = new PageReference(navigateurl);
            pageRef.setRedirect(true);
            if(String.isNotBlank(regionStr)){
               pageRef.getParameters().put('countryCode',regionStr); 
            }
            return pageRef;
        }
        else {
            return null;
        }
    }
    
    //getCoolnetCountryList - constructs URL
    public List<SelectOption> getCoolnetCountryList(){  
        //GetURL from CoolNet_AGN_Redirection_Link__c custom Setting
        List<CoolNet_AGN_Redirection_Link__c> countryUrlList = CoolNet_AGN_Redirection_Link__c.getall().values();
        countryUrlList.sort();
        System.debug('Country Debug : '+countryUrlList);
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Select','Select country'));
        //Loop on CoolNet_AGN_Redirection_Link__c - and construct URL.
        for(CoolNet_AGN_Redirection_Link__c iterate : countryUrlList){
            MapVar.put(iterate.Name,iterate.Redirection_Url_AGN__c);
            mapCountryToUrlSeting.put(iterate.Name,iterate);
            options.add(new SelectOption(iterate.Name,iterate.Name));
        }
        System.debug('MAP VALUE '+MapVar);
        return options;
    }
    public void find()
    {
        if(Country!='Select')
        {
            isVisible = true;
            //system.debug('Arijit2 : ' + isVisible);
        }
        else 
        {
            isVisible = false;
            //system.debug('Arijit3 : ' + isVisible);
        }
    }
}