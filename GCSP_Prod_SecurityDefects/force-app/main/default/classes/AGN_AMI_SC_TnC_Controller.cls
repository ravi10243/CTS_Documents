// This class is created as the Controller class of the Visualforce Page - AGN_AMI_SC_TnC_Page
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public class AGN_AMI_SC_TnC_Controller {
    public List<AMI_Terms_and_Conditions_AGN__c> lsttermnc{get;set;}
    public user currentuser{get;set;}
    public String CommunityProfile {get; set;}
    public String userLanguage{get;set;}
    String userCountryName;
    Id userId;
    User user;
    public AGN_AMI_SC_TnC_Controller()
    {
        currentuser = new User();
        currentuser = [Select contact.AccountId,LanguageLocaleKey,Country_Code__c,Profile.Id, UserType from User where Id=:userinfo.getuserId()];
        userId = currentuser.Contact.AccountId;         
         
        CommunityProfile = [Select Id from Profile where Name =: AGN_AMI_SC_Static_Labels.AMI_SC_Customer_Community].Id;
        
        if(currentuser.UserType != 'Guest')
        {            
            AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();
            userLanguage = userDetails.userLanguage;
            userCountryName =  userDetails.userCountryName;
            user =  userDetails.user;
            
        }
        else
        {
            UserCountryName = ApexPages.currentPage().getParameters().get('country');
            userLanguage = AMI_Language_AGN__c.getValues(ApexPages.currentPage().getParameters().get('lang')).Lang_Code__c;
        }
        
        lsttermnc = new List<AMI_Terms_and_Conditions_AGN__c>();
        lsttermnc = [Select Country_Code_agn__c, Terms_and_Conditions_AGN__c from AMI_Terms_and_Conditions_AGN__c 
                     where Country_Code_agn__c = :userCountryName and AGN_AMI_Business_Unit__c =: AGN_AMI_SC_Static_Labels.specialityCare LIMIT 1];
                     
        System.debug('The terms and conditions are----->' +lsttermnc);
    }

}