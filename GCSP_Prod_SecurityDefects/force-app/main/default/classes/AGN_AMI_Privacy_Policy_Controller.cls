public class AGN_AMI_Privacy_Policy_Controller 
{
    public List<AMI_Privacy_Policy_AGN__c> lstpp{get;set;}
    public user currentuser{get;set;}
    public String CommunityProfile {get; set;}
    public String userLanguage {get;set;}
    public String UserCountryName;
    User user;
    
    public AGN_AMI_Privacy_Policy_Controller()
    {
        currentuser = new User();
        System.debug('user Id is----->' +userinfo.getuserId());
        currentuser = [Select contact.AccountId,LanguageLocaleKey,Country_Code__c,Profile.Id, UserType from User where Id=:userinfo.getuserId()];
        CommunityProfile = [Select Id from Profile where Name = 'AMI Customer Community'].Id;
        
        
        if(currentuser.UserType != 'Guest')
        {            //UserCountry = currentuser.Country_Code__c;
            /* UserCountryName = [Select Country_vod__r.name from account where id =: userId limit 1].Country_vod__r.name;
userLanguage = currentuser.LanguageLocaleKey;*/
            
            AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            userLanguage = userDetails.userLanguage;
            userCountryName =  userDetails.userCountryName;
            user =  userDetails.user;
        }
        else
        {
            /*AMI MENA changes- Start */
            //UserCountryName = ApexPages.currentPage().getParameters().get('country');
            AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            UserCountryName =  userDetails.userCountryName;
            /*AMI MENA changes- Start */
            userLanguage = AMI_Language_AGN__c.getValues(ApexPages.currentPage().getParameters().get('lang')).Lang_Code__c;
        }  
        System.debug('UserCountry---->' +userCountryName );
        lstpp = new List<AMI_Privacy_Policy_AGN__c>();
        /*AMI Specialty Care - Added condition for AGN_AMI_Business_Unit__c */
        lstpp = [Select Country_Code_AGN__c, Privacy_Policy_AGN__c from AMI_Privacy_Policy_AGN__c 
                 where Country_Code_AGN__c = :UserCountryName and AGN_AMI_Business_Unit__c =: AGN_AMI_SC_Static_Labels.medicalAesthetics LIMIT 1];
        System.debug('The terms and conditions are----->' +lstpp);
    }
}