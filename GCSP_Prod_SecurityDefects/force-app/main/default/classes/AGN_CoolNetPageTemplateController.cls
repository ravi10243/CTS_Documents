public class AGN_CoolNetPageTemplateController {
    public String SelSearch { get; set; }
    public string userId{get;set;}
    public string user_country{get;set;}
    public List<Disclaimer_Content_AGN__c> disclaimer{get;set;}
    public string Trasifex_LanguageCode{get;set;}
    public AGN_CoolNetPageTemplateController()
    {
        userId=userinfo.getSessionId();
        Trasifex_LanguageCode='';
        disclaimer =new List<Disclaimer_Content_AGN__c>();
        //User objUser=[select Country_Code_AGN__c from user where id=:UserInfo.getUserId() Limit 1]; // Blocked by Arijit
        
        //Commented by Avijit, reason : MEA Rollout
        /*User objUser=[select Country_Code__c from user where id=:UserInfo.getUserId() Limit 1];
        if(objUser!=null && objUser.Country_Code__c !=null){
            user_country= objUser.Country_Code__c;   
        }
        */
        user_country = AGN_CoolNetUtils.getUserCountryCode(); //Added by Avijit, reason : MEA Rollout
        /*disclaimer = [Select  Country_AGN__r.Country_Name__c,Disclaimer_AGN__c From Disclaimer_Content_AGN__c Where Country_AGN__r.Country_Name__c =:user_country LIMIT 1];*/ //Blocked by Arijit
        //Added by Arijit
        disclaimer = [Select Country_AGN__r.Country_Name_vod__c,Disclaimer_AGN__c From Disclaimer_Content_AGN__c Where Country_AGN__r.Alpha_2_Code_vod__c =:user_country LIMIT 1];
        
        if(user_country!=null && user_country!=''){
            
            List<AGN_Coolnet_Portal_Countries__mdt> lstCountry=[Select Transifex_Language_Code_AGN__c From AGN_Coolnet_Portal_Countries__mdt Where Country_code__c=:user_country LIMIT 1];
            if(lstCountry!=null && lstCountry.size()>0){
                Trasifex_LanguageCode=lstCountry[0].Transifex_Language_Code_AGN__c ;
            }
        }
    }
    
    public pagereference GoToSearchResults()
    {
        Pagereference prModDet=new PageReference('/Apex/AGN_CoolNet_Search');
        prModDet.setRedirect(true);
        prModDet.getParameters().put('SelSearch',SelSearch);         
        
        return prModDet;
        
    }
}