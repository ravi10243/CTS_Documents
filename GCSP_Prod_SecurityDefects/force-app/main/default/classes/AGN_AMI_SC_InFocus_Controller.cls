public without sharing class AGN_AMI_SC_InFocus_Controller {
    public User user {get; set;} 
    public String userLanguage {get;set;}
    Id userId;
    String userCountryName{get;set;}
    public List<AMI_InFocus_AGN__c> listInFocus {get; set;}
    public AMI_InFocus_AGN__c selectedInFocus {get; set;}
    public String clickedVideo {get; set;}
    public AGN_AMI_SC_InFocus_Controller()
    {
        AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails userDetails =  new AGN_AMI_SC_Utility_class.AGN_AMI_SC_UserDetails();
        userLanguage = userDetails.userLanguage;
        userCountryName =  userDetails.userCountryName;
        user =  userDetails.user;
        listInFocus = [Select Id, Name_AGN__c, Description_AGN__c, AMI_Image_URL_AGN__c, Video_URL_AGN__c 
                       from AMI_InFocus_AGN__c
                       where Country_AGN__r.Name =: userCountryName and Active_AGN__c = true
                       and AGN_AMI_Business_Unit__c=: AGN_AMI_SC_Static_Labels.specialityCare
                       order by Sequence_AGN__c ASC NULLS LAST];
        if( !listInFocus.isEmpty() )
        {
            selectedInFocus = listInFocus[0];
        }
    }
    public PageReference changeVideo()
    {
        for(AMI_InFocus_AGN__c inFocus : listInFocus)
        {
            if(inFocus.Id == clickedVideo)
            {
                selectedInFocus = inFocus;
            }
        }
        return null;
    }
    
}