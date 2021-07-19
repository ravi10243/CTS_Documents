public class AGN_OnlineConsent_FooterController {
    public StringCarrier Slanguage{get; set;}
    public String value{get;set;}
    public List<Allergan_Consent_Footer_Info__c> footerList{
        get{
            system.debug('lang** '+Slanguage);
            if(Slanguage != null) 
                value  = Slanguage.value;
            else
                value = 'en_US';
            
            footerList = new List<Allergan_Consent_Footer_Info__c>();
            footerList = [Select Id, Name, Language__c, Footer_RichText_c__c from Allergan_Consent_Footer_Info__c where Language__c= :value and Application_Flag_AGN__c=NULL order by Display_Order__c asc];
            return footerList;
        }                                                            
        set;
    }
}