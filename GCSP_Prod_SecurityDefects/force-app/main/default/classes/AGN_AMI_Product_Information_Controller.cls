public class AGN_AMI_Product_Information_Controller 
{
    User user;
    String userCountryName;
    public user currentuser{get;set;}
    public String userLanguage {get; set;}
    public List<AMI_Production_Information_AGN__mdt> productInformationList {get; set;}
    
    
    public AGN_AMI_Product_Information_Controller()
    {
        currentuser = [Select contact.AccountId,LanguageLocaleKey,Country_Code__c,Profile.Id, UserType from User where Id=:userinfo.getuserId() limit 1];
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        
        productInformationList = [Select Link_Label_AGN__c, Document_Link_AGN__c, Sequence_AGN__c 
                                  from AMI_Production_Information_AGN__mdt 
                                  where Country_Code_AGN__c =: userCountryName 
                                  order by Sequence_AGN__c asc]; 
        
    }

}