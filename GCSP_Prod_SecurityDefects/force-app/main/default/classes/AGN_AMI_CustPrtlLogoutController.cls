public  without sharing class AGN_AMI_CustPrtlLogoutController {
    
    public string userLang{get;set;}
    public string userCountry {get; set;}
    public String userLanguage {get;set;}
    User user;
    public AGN_AMI_CustPrtlLogoutController () 
    {
       // userLang=UserInfo.getLanguage();
        /*user = [Select  contact.AccountId,Country_code__c,LanguageLocaleKey from user where id =: Userinfo.getUserid() limit 1];
        userId= user.Contact.AccountId;
       
        userCountry = [Select Country_vod__r.name from account where id =: userId limit 1].Country_vod__r.name;
        userLanguage = user.LanguageLocaleKey; */
        
         AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
          userLang = userDetails.userLanguage;
          userCountry =  userDetails.userCountryName;
          user =  userDetails.user;
    }
}