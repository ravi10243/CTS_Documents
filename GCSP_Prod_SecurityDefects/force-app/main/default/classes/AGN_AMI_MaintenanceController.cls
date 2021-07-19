public class AGN_AMI_MaintenanceController {
public AMI_Web_Visibility_Settings_AGN__c AWV {get; set;}
    public String userCountry{get;set;}
    public String externalCountry {get; set;}
    public String externalLanguage {get; set;}
    public AGN_AMI_MaintenanceController(){
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userCountry =  userDetails.userCountryName;
        externalCountry = ApexPages.currentPage().getParameters().get('country');
        externalLanguage = ApexPages.currentPage().getParameters().get('lang');
    AWV = (externalCountry!=null)?AMI_Web_Visibility_Settings_AGN__c.getValues(externalCountry):AMI_Web_Visibility_Settings_AGN__c.getValues(userCountry);
}
}