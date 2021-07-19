// This class is created as the Controller class of the Visualforce Page - AGN_AMI_SC_CustomerPortalLogout
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public  without sharing class AGN_AMI_SC_CustPrtlLogoutController {
    public string userLang{get;set;}
    public string userCountry {get; set;}
    public String userLanguage {get;set;}
    User user;
    public AGN_AMI_SC_CustPrtlLogoutController () 
    {             
        AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();
        userLang = userDetails.userLanguage;
        userCountry =  userDetails.userCountryName;
        user =  userDetails.user;
    }
    
}