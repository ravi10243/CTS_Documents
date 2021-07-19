public class AGN_ICL_FooterController {
    public String Slanguage{get; set;}
    public String value{get;set;}
    public String ICLflag{get;set;}
    public String ICLcountry{get;set;}
    public String PrivacyLinkURL{get;set;}
    public AGN_ICL_FooterController() {
        
        ICLflag=ApexPages.currentPage().getParameters().get('ICLflag');
        ICLcountry=ApexPages.currentPage().getParameters().get('country');
        PrivacyLinkURL = AGN_ICL_PageFooterController.getPrivacyLinkURL(ICLcountry);
        
        
    }
    public List<Allergan_Consent_Footer_Info__c> footerList{
        get{
            
            footerList = new List<Allergan_Consent_Footer_Info__c>();
            
            if(iclflag=='true')
            {
                if(Slanguage != null)
                {
                    Country_vod__c cv=[select Id from Country_vod__c where Name=:ICLcountry];
                    footerList = [Select Id, Name, Language__c, Footer_RichText_c__c,country_code_AGN__c from Allergan_Consent_Footer_Info__c where Language__c= :Slanguage and country_code_AGN__c =:cv.Id and Application_Flag_AGN__c='ICL' and name=:'ICL Terms of Use'];
                    if(footerList.isEmpty())
                    {
                        footerList = [Select Id, Name, Language__c, Footer_RichText_c__c from Allergan_Consent_Footer_Info__c where Language__c= :'en_US' and name=:'Terms of Use'];
                    }
                }
                else 
                {
                    footerList = [Select Id, Name, Language__c, Footer_RichText_c__c from Allergan_Consent_Footer_Info__c where Language__c= :'en_US' and name=:'Terms of Use'];
                }
            }
            return footerList;
            
        }                                                            
        set;
    }
}