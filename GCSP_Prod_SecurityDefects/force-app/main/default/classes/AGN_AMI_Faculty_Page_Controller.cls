public class AGN_AMI_Faculty_Page_Controller {
    public List<AMI_Faculty_AGN__c> facultyList {get; set;}
    User user;
    public String userLanguage {get;set;}
    Id userId;
    String userCountryName{get;set;}
    
    public List<AMI_Faculty_AGN__c> internationalExpertList {get; set;}
    public List<AMI_Faculty_AGN__c> amiTeamList {get; set;}
    
    public AGN_AMI_Faculty_Page_Controller()
    {
       /*  user = [Select contact.AccountId,LanguageLocaleKey from user where id =: Userinfo.getUserid() limit 1];
         UserID = user.contact.AccountId;
         userLanguage = user.LanguageLocaleKey;
         userCountryName = [Select Country_vod__r.name from account where id =: userId limit 1].Country_vod__r.name; */
         
         AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            userLanguage = userDetails.userLanguage;
            userCountryName =  userDetails.userCountryName;
            user =  userDetails.user;
         facultyList = [select Name_AGN__c,Image_URL_AGN__c,Country_AGN__c,Country_Code_AGN__c,email_AGN__c,Title_AGN__c,AMI_Faculty_Description_AGN__c ,Hospital_AGN__c
                       from AMI_Faculty_AGN__c 
                       where Active_AGN__c=true 
                       and AMI_Is_Country_Expert_AGN__c=true
                       and AMI_Is_International_Expert_AGN__c<>true
                       and Country_Code_AGN__c =: userCountryName order by Name_AGN__c];
        
        internationalExpertList = [SELECT AMI_Is_International_Expert_AGN__c,Name_AGN__c,Image_URL_AGN__c,Country_AGN__c,Country_Code_AGN__c,email_AGN__c,Title_AGN__c,AMI_Faculty_Description_AGN__c ,Hospital_AGN__c
                       from AMI_Faculty_AGN__c  where Active_AGN__c=true 
                       and AMI_Is_International_Expert_AGN__c=true
                       and Country_Code_AGN__c =: userCountryName order by Name_AGN__c];
        
        amiTeamList= [select Name_AGN__c,Image_URL_AGN__c,Country_AGN__c,email_AGN__c,Title_AGN__c,AMI_Faculty_Description_AGN__c,Hospital_AGN__c
                       from AMI_Faculty_AGN__c 
                       where Active_AGN__c=true and AMI_AMI_Team_AGN__c=true and
                       Country_LKP_AGN__r.Name =: userCountryName order by Name_AGN__c];
        
    }
}