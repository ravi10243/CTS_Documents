public without sharing class AGN_AMI_SC_Contact_Us_Controller {
    public List<AMI_Contact_AGN__c> listAMIContact{get;set;}
    public List<AMI_Contact_AGN__c> listAMISupport{get;set;}
    public user currentuser{get;set;}
    public String userCountry{get; set;}
    public String CommunityProfile {get; set;}
    public String userLanguage {get; set;}
    public Integer contactListSize {get;set;}
    public Integer supportListsize{get;set;}
    
    Public AGN_AMI_SC_Contact_Us_Controller()
    {
        
        String ipUserID='';   
        String loggedInUserID=Userinfo.getUserid();
        ipUserID =loggedInUserID;
        
        currentuser = new User();
        currentuser = [Select contact.AccountId,LanguageLocaleKey,Country_Code__c,Profile.Id, UserType from User where Id=:userinfo.getuserId() limit 1];
        CommunityProfile = [Select Id from Profile where Name = :AGN_AMI_SC_Static_Labels.AMI_SC_Customer_Community].Id;
        if(currentuser.UserType != AGN_AMI_SC_Static_Labels.Guest)
        {            
            AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();
            userLanguage = userDetails.userLanguage;
            userCountry =  userDetails.userCountryName;
        }
        else
        {
            userCountry = ApexPages.currentPage().getParameters().get('country');
            userLanguage = AMI_Language_AGN__c.getValues(ApexPages.currentPage().getParameters().get('lang')).Lang_Code__c;
        }
        
        listAMIContact=[SELECT Id,Country_AGN__c,
                        Country_AGN__r.name,   Country_AGN__r.AGN_Country_Name__c,
                        Email_AGN__c,First_Name_AGN__c,Last_Name_AGN__c,
                        Name,Phone_AGN__c,Photo_URL_AGN__c,CurrencyIsoCode,Is_Support_AGN__c,
                        Postal_Address_AGN__c,Contact_Location_AGN__c,Fax_AGN__c
                        FROM AMI_Contact_AGN__c where Country_AGN__r.name=:userCountry and Active_AGN__c=true and 
                        AGN_AMI_Business_Unit__c=:AGN_AMI_SC_Static_Labels.specialityCare and Is_Support_AGN__c=false ORDER BY Name ASC];	
        contactListSize = listAMIContact.size();
        listAMISupport=[SELECT Id,Country_AGN__c,
                        Country_AGN__r.name,   Country_AGN__r.AGN_Country_Name__c,
                        Email_AGN__c,First_Name_AGN__c,Last_Name_AGN__c,
                        Name,Phone_AGN__c,Photo_URL_AGN__c,CurrencyIsoCode,Is_Support_AGN__c
                        FROM AMI_Contact_AGN__c where Country_AGN__r.name=:userCountry and 
                        AGN_AMI_Business_Unit__c=:AGN_AMI_SC_Static_Labels.specialityCare and Active_AGN__c=true and Is_Support_AGN__c=true];
        supportListsize = listAMISupport.size();
    }
    
    
}