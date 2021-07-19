public without sharing class AGN_AMI_Contact_Us_Controller{
    
    public List<AMI_Contact_AGN__c> listAMIContact{get;set;}
    public List<AMI_Contact_AGN__c> listAMISupport{get;set;}
    //String userId{get; set;}
    //List<user> userName{get; set;}
    public user currentuser{get;set;}
    public String userCountry{get; set;}
    public String CommunityProfile {get; set;}
    public String userLanguage {get; set;}
    public Integer contactListSize {get;set;}
    public Integer supportListsize{get;set;}
    public string LoginHelpVideo{get; set;} //	CR 3932
    Public AGN_AMI_Contact_Us_Controller()
    {
        String ipUserID='';   
        String loggedInUserID=Userinfo.getUserid();
        ipUserID =loggedInUserID;
        
        currentuser = new User();
        System.debug('user Id is----->' +userinfo.getuserId());
        currentuser = [Select contact.AccountId,LanguageLocaleKey,Country_Code__c,Profile.Id, UserType from User where Id=:userinfo.getuserId() limit 1];
        System.debug('currentuser----->' +currentuser);
        CommunityProfile = [Select Id from Profile where Name = 'AMI Customer Community'].Id;
        if(currentuser.UserType != 'Guest')
        {            
            AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            userLanguage = userDetails.userLanguage;
            userCountry =  userDetails.userCountryName;
            LoginHelpVideo = AMI_Web_Visibility_Settings_AGN__c.getValues(userCountry).AGN_AMI_Login_Help_Video_Link__c;
            }
        else
        {
            /*AMI MENA changes- Start */
            AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
            userCountry =  userDetails.userCountryName;
            LoginHelpVideo = AMI_Web_Visibility_Settings_AGN__c.getValues(userCountry).AGN_AMI_Login_Help_Video_Link__c;
            //userCountry = ApexPages.currentPage().getParameters().get('country');
            /*AMI MENA changes- End */
            userLanguage = AMI_Language_AGN__c.getValues(ApexPages.currentPage().getParameters().get('lang')).Lang_Code__c;
        }
        System.debug('userCountry----->' +userCountry);
        
        // Changes for Australia: 0719 -start
		listAMIContact=[SELECT Id,Country_AGN__c,
                        Country_AGN__r.name,   Country_AGN__r.AGN_Country_Name__c,
                        Email_AGN__c,First_Name_AGN__c,Last_Name_AGN__c,
                        Name,Phone_AGN__c,Photo_URL_AGN__c,CurrencyIsoCode,Is_Support_AGN__c,
                        Postal_Address_AGN__c,Contact_Location_AGN__c,Fax_AGN__c
                        FROM AMI_Contact_AGN__c where Country_AGN__r.name=:userCountry and Active_AGN__c=true and 
                        AGN_AMI_Business_Unit__c=:AGN_AMI_SC_Static_Labels.medicalAesthetics and Is_Support_AGN__c=false ORDER BY Name ASC];	
		// Changes for Australia: 0719 -end
        contactListSize = listAMIContact.size();
        
        listAMISupport=[SELECT Id,Country_AGN__c,
                        Country_AGN__r.name,   Country_AGN__r.AGN_Country_Name__c,
                        Email_AGN__c,First_Name_AGN__c,Last_Name_AGN__c,
                        Name,Phone_AGN__c,Photo_URL_AGN__c,CurrencyIsoCode,Is_Support_AGN__c
                        FROM AMI_Contact_AGN__c where Country_AGN__r.name=:userCountry and Active_AGN__c=true and 
                        AGN_AMI_Business_Unit__c=:AGN_AMI_SC_Static_Labels.medicalAesthetics and Is_Support_AGN__c=true];
        supportListsize = listAMISupport.size();
        system.debug('supportListsize-->'+supportListsize);
    }
    
}