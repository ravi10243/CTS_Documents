public without sharing class AGN_CommunityPortal_FooterController {
    public String pageLang{get; set;}
    public List<Allergan_Consent_Footer_Info__c> footerList{
        get{
            system.debug('lang** '+pageLang);
            if(pageLang == null) 
                pageLang = 'en_US';
            
            //footerList = new List<Allergan_Consent_Footer_Info__c>();
            footerList = AGN_OAMPortalCustomerRegUtils.getFooterConsents(pageLang);
            //[Select Id, Name, Language__c, Footer_RichText_c__c from Allergan_Consent_Footer_Info__c where Language__c= :pageLang order by Display_Order__c asc];
            return footerList;
        }                                                            
        set;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Allergan_Consent_Footer_Info__c> fetchFooterConsents(String pageLang){
        List<Allergan_Consent_Footer_Info__c> footerList = AGN_OAMPortalCustomerRegUtils.getFooterConsents(pageLang);
        return footerList;
    }
    
    @AuraEnabled
    public static String userLocale(){
        return UserInfo.getLocale();
    }
}