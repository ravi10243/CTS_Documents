public class AGN_AMI_Expert_Page_Controller 
{
	public List<AMI_Faculty_AGN__c> expertList{get; set;}
    User user;
    public String userLanguage{get;set;}
    String userCountryName;
    public AGN_AMI_Expert_Page_Controller()
    {
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        expertList = [Select Name_AGN__c, Hospital_AGN__c,email_AGN__c,Image_URL_AGN__c,Title_AGN__c ,AMI_Faculty_Description_AGN__c
                      from AMI_Faculty_AGN__c 
                      where Active_AGN__c=true and AMI_Is_Country_Expert_AGN__c=true and Country_LKP_AGN__r.Name =: userCountryName];
    }
}