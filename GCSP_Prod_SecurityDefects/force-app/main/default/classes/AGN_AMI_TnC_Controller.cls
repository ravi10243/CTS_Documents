public class AGN_AMI_TnC_Controller 
{
    public List<AMI_Terms_and_Conditions_AGN__c> lsttermnc{get;set;}
    public user currentuser{get;set;}
    public String CommunityProfile {get; set;}
    public String userLanguage{get;set;}
    public String userCountryName;
    Id userId;
    User user;
    public AGN_AMI_TnC_Controller()
    {
        currentuser = new User();
        System.debug('user Id is----->' +userinfo.getuserId());
        currentuser = [Select contact.AccountId,LanguageLocaleKey,Country_Code__c,Profile.Id, UserType from User where Id=:userinfo.getuserId()];
        userId = currentuser.Contact.AccountId;         
        
        CommunityProfile = [Select Id from Profile where Name = 'AMI Customer Community'].Id;
        
        if(currentuser.UserType != 'Guest')
        {            //UserCountry = currentuser.Country_Code__c;
            /* UserCountryName = [Select Country_vod__r.name from account where id =: userId limit 1].Country_vod__r.name;
System.debug(UserCountryName);
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
            /*AMI MENA changes- End */
            userLanguage = AMI_Language_AGN__c.getValues(ApexPages.currentPage().getParameters().get('lang')).Lang_Code__c;
        }
        lsttermnc = new List<AMI_Terms_and_Conditions_AGN__c>();
        /*Specialty Care changes to add check based on Business Unit */
            lsttermnc = [Select Country_Code_agn__c, Terms_and_Conditions_AGN__c from AMI_Terms_and_Conditions_AGN__c 
                         where Country_Code_agn__c = :userCountryName and AGN_AMI_Business_Unit__c=: AGN_AMI_SC_Static_Labels.medicalAesthetics LIMIT 1];
        System.debug('The terms and conditions are----->' +lsttermnc);
    }
}