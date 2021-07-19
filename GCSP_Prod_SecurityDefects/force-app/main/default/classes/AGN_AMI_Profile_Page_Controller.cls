public without sharing class AGN_AMI_Profile_Page_Controller {
    
    User user;
    Account accountRecord;
    Contact contactRecord;
    Public Contact UsrProfile{get;set;}
    Public string birthDate{get;set;}
    public string userLanguage {get;set;}
    public Allergan_Customer_Address_AGN__c UsrAddress {get;set;}
    Public string mobile {get;set;}   
    public string email {get;set;}
    public string language {get;set;}
    
    public AGN_AMI_Profile_Page_controller()
    {
        AGN_AMI_Utility_class.AGN_AMI_UserDetails userDetails =  new AGN_AMI_Utility_class.AGN_AMI_UserDetails();
        userLanguage = userDetails.userLanguage;
        user =  userDetails.user;
        accountRecord = userDetails.accountRecord;
        contactRecord = userDetails.contactRecord;
        List<Contact> lstUsrProfile= [select Id,Name,Title,Firstname,LastName, Professional_Title_AGN__c, SAP_ID_AGN__c, Website_Link_AGN__c,  
                                      Salutation,Middle_Name_AGN__c,Graduation_Year_AGN__c, toLabel(Language_AGN__c),Street_Name_AGN__c,
                                      AMI_Specialty_AGN__r.Name_AGN__c,Physician_Registration_Reference_AGN__c, National_Id_AGN__c,
                                      Birthdate,MobilePhone,Phone, Country_AGN__r.Name, Suite_AGN__c, AMI_HCP_Desgination_AGN__c, 
                                      Email,AMI_Instagram_AGN__c,Account.name, MailingPostalCode, State_License_Number_AGN__c,
                                      MailingStreet, House_Number_AGN__c, MailingCity, MailingState,Invited_By_AMI_AGN__c
                                      from Contact where Id = :contactRecord.Id limit 1];
        if(lstUsrProfile!=null){
            if(lstUsrProfile.size()>0){
                UsrProfile=lstUsrProfile[0];
                birthDate=(UsrProfile.Birthdate!=null)?
                    DateTime.newInstance(UsrProfile.Birthdate.year(), UsrProfile.Birthdate.month(), UsrProfile.Birthdate.day()).format('dd MMM, yyyy'):'';            }   
        }
    }
    
    // 3161 - added to update Instagram handle
    public void saveInstagramHandle(){
        try{
            update UsrProfile;
        }
        catch(DmlException ex){
            AGN_AMI_ErrorLogger.createExceptionsLog(ex, 'AGN_AMI_Profile_Page_Controller', 'saveInstagramHandle');
        }
    }
}