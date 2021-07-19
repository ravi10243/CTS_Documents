public class AGN_AMI_Our_Team_Controller 
{
    public List<AMI_Faculty_AGN__c> facultyList {get; set;} 
    User user;
    public String userLanguage {get;set;}
    String userCountryName;
    public AGN_AMI_Our_Team_Controller()
    {
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        
        facultyList = [select Name_AGN__c,Image_URL_AGN__c,Country_AGN__c,email_AGN__c,Title_AGN__c,AMI_Faculty_Description_AGN__c,Hospital_AGN__c
                       from AMI_Faculty_AGN__c 
                       where Active_AGN__c=true and AMI_AMI_Team_AGN__c=true and
                       Country_LKP_AGN__r.Name =: userCountryName];
        
    }
}