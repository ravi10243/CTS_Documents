public class AGN_OnlineConsent_CookieController {
    public StringCarrier Slanguage{get; set;}
    public String Language{get;set;}
    public String okLabel {get; set;}
    
    public void AGN_OnlineConsent_CookieController(){
        Language = Slanguage.value;
    }
     public String getCookieMesg
    {
        get{
            String cm = '';
            try{           
                List<Allergan_Consent_Cookie_Info__c> cookieList = new List<Allergan_Consent_Cookie_Info__c>();
                if(Slanguage != null && Slanguage.value != '')
                    cookieList = [Select Id, Name, Cookie_Content__c, Language__c, OkLabel__c from Allergan_Consent_Cookie_Info__c where Language__c = :Slanguage.value and Application_Flag_AGN__c=NULL];
                
                if(cookieList != null && cookieList.size() > 0)
                {
                    cm = cookieList[0].Cookie_Content__c;
                    okLabel = cookieList[0].OkLabel__c;
                }
                return cm;
            }
            catch(Exception e){
                System.debug('error: '+e);
                return null;
            }            
        }
        set;
    }
    
    public PageReference NextPage()
    {       
        if(Slanguage != null && Slanguage.value != null)
        {
            return new PageReference('/apex/AGN_OnlineConsent_UniqueCode');
        }    
        return null;
    }
}