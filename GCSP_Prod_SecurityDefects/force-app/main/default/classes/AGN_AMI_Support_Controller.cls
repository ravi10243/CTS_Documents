public class AGN_AMI_Support_Controller 
{
    public List<AMI_Contact_AGN__c> lstContact{get;set;}
    public user currentuser{get;set;}
    public String CommunityProfile {get; set;}
    public String userLanguage {get;set;}
    public String UserCountryName;
    Id userId;
    User user;
    public AGN_AMI_Support_Controller()
    {
        currentuser = new User();
                            System.debug('user Id is----->' +userinfo.getuserId());
        currentuser = [Select contact.AccountId,LanguageLocaleKey,Country_Code__c,Profile.Id, UserType from User where Id=:userinfo.getuserId() limit 1];
        userId = currentuser.Contact.AccountId; 
        userLanguage = currentuser.LanguageLocaleKey;
        CommunityProfile = [Select Id from Profile where Name = 'AMI Customer Community'].Id;
        
        if(currentuser.UserType != 'Guest')
        {            //UserCountry = currentuser.Country_Code__c;
           /* userCountryName = [Select Country_vod__r.name from account where id =: userId limit 1].Country_vod__r.name;
            userLanguage = currentuser.LanguageLocaleKey;*/
            
            AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            userLanguage = userDetails.userLanguage;
            userCountryName =  userDetails.userCountryName;
            user =  userDetails.user;
        }
        else
        {
            /*AMI MENA changes- Start */
            //userCountryName = ApexPages.currentPage().getParameters().get('country');
            AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            userCountryName =  userDetails.userCountryName;
        	/*AMI MENA changes- End */
            userLanguage = AMI_Language_AGN__c.getValues(ApexPages.currentPage().getParameters().get('lang')).Lang_Code__c;
        }
        
                            System.debug('CurrentUser---->' +currentuser);
        lstContact = New List<AMI_Contact_AGN__c>();
        lstContact = [Select Country_AGN__r.name ,Country_AGN__r.AGN_Country_Name__c,Email_AGN__c,Phone_AGN__c,First_Name_AGN__c,Last_Name_AGN__c
                      from AMI_Contact_AGN__c where  Country_AGN__r.name = : userCountryName and Active_AGN__c=true and Is_Support_AGN__c=true];       
                            System.debug('The country code is----->' + lstContact);
                            System.debug('List Size is--->' +lstContact.size());
    }
}