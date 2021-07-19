public class AGN_AMI_Consent_Confirmation_Controller 
{
    public String userLanguage{get;set;}
    public String regId {get; set;}
    public AGN_AMI_Consent_Confirmation_Controller()
    {
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = ApexPages.currentPage().GetParameters().Get('lang');
        regId = ApexPages.currentPage().GetParameters().Get('id');
        System.debug(regId);
    } 
    public void updateReg()
    {
        system.debug('Here');
        Allergan_Customer_Registration_AGN__c acr = new Allergan_Customer_Registration_AGN__c();
        acr.id = regId;
        acr.AMI_Consent_Verified_AGN__c = true;
        update acr;
    }
}