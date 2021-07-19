public class AGN_AMI_External_Password_Controller 
{
    public String userLanguage {get;set;}
    public String email {get; set;}
    public boolean resetSuccess {get; set;}
    public boolean changeSuccess {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    public String getCountry {get;set;}
    public boolean HideText {get;set;}
    public boolean success{get;set;}
    static string link='?resetSuccess=true';
    static string reset_true='true';
    static string reset_success='resetSuccess';
    static string country_Br='BR';
    //CR#3597 23.09.2020 - G.B - Prevent reset password for Demo User.  
    public boolean isDemoUser {get; private set;}
    
    public AGN_AMI_External_Password_Controller()
    {
        //userLanguage = [Select LanguageLocaleKey from user where Id =: Userinfo.getUserid() limit 1].LanguageLocaleKey;
        //System.debug(Apexpages.currentPage().getUrl().substring(Apexpages.currentPage().getUrl().lastIndexOf('/')+1).startsWith('AGN_AMI_Forget_Password'));
        if(Apexpages.currentPage().getUrl().substring(Apexpages.currentPage().getUrl().lastIndexOf('/')+1).startsWith('AGN_AMI_Forget_Password'))
            //line modified to fix password reset exception missing lang parameter.  
           userLanguage =  AMI_Language_AGN__c.getValues(ApexPages.currentPage().getParameters().get('lang')).Lang_Code__c != null
                            ? AMI_Language_AGN__c.getValues(ApexPages.currentPage().getParameters().get('lang')).Lang_Code__c:System.Label.AMI_Default_Password_Reset_Language_Local_Key;
                          
        else
            userLanguage = [Select LanguageLocaleKey from user where Id =: Userinfo.getUserid() limit 1].LanguageLocaleKey;
    
        /*fetching country code*/
        getCountry =apexpages.currentpage().getparameters().get('country'); 
        
        /*checking if country code is of BRAZIL*/
        if (getCountry==country_Br){
            HideText=True;
            }
        //PMO3423 
        changeSuccess = false;
        if(ApexPages.currentPage().getParameters().get('resetSuccess')!=null) {
            if(ApexPages.currentPage().getParameters().get('resetSuccess') == 'true') {
                changeSuccess = true;
            }
        }
        
        
    
    }
    
    public void forgotPassword()
    {
        // DQ - HCP Harmonization changes start
        List<User> userList = [Select username, Contact.Account.AGN_AMI_Enabled__c,     
                               contact.Is_AMI_Contact_AGN__c, contact.account.IsPersonAccount,Is_AMI_Demo_User_AGN__c,Is_AMI_Country_Demo_User_AGN__c from User     
                               where Email =: email.trim() and isActive = true];
        
        /*List<User> userList = [Select username, Contact.Account.AGN_AMI_Enabled__c, 
                               contact.Is_AMI_Contact_AGN__c, contact.account.IsPersonAccount from User 
                               where Email =: email and isActive = true];*/
        User user;
        for(User tempUser : userList)
        {
            // DQ - HCP Harmonization backward compatibility start
            if(tempUser.Contact.Account.IsPersonAccount && tempUser.Contact.Account.AGN_AMI_Enabled__c)
            {
                user = tempUser;
            }
            // DQ - HCP Harmonization backward compatibility end
            else if(!tempUser.Contact.Account.IsPersonAccount && tempUser.Contact.Is_AMI_Contact_AGN__c)
            {
                user = tempUser;
            }
        }
        // DQ - HCP Harmonization changes end
       
       /* if(user != null)
        {
            resetsuccess = Site.forgotPassword(user.username);
            System.debug(user.username + resetsuccess);
        }
        else
            resetSuccess = false;
    }*/
    //CR#3597 23.09.2020 - G.B - Prevent reset password for Demo User.  
        if(user != null && !user.Is_AMI_Country_Demo_User_AGN__c && !user.Is_AMI_Demo_User_AGN__c)   
        {   
            resetsuccess = Site.forgotPassword(user.username);  
            //CR#3597 23.09.2020 - G.B - Prevent reset password for Demo User.  
            isDemoUser = false; 
            System.debug(user.username + resetsuccess); 
        }   
        else{   
            resetSuccess = false;   
            //CR#3597 23.09.2020 - G.B - Prevent reset password for Demo User.  
            isDemoUser = (user !=null && (user.Is_AMI_Country_Demo_User_AGN__c || user.Is_AMI_Demo_User_AGN__c))? true:false; 
        }   
    }
    public PageReference changePassword()
        {   
            String a = System.label.AGN_AMI_External_Reset_Password_Page;      
            PageReference pr = Site.changePassword(newPassword, verifyNewPassword);
        
        PageReference prNew;
        //PMO 3423 redirecting to the same page 
        if(pr!=null) {
            prNew = new PageReference(a+link); 
        }
        else {
            prNew = pr;
        }
        return prNew; 
    }       
}