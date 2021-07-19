// This class is created as the Controller class of the Visualforce Page - AGN_AMI_SC_Forget_Password
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public class AGN_AMI_SC_External_Password_Controller {
    public String userLanguage {get;set;}
    public String email {get; set;}
    public boolean resetSuccess {get; set;}
    public boolean changeSuccess {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    public AGN_AMI_SC_External_Password_Controller()
    {
        
        if(Apexpages.currentPage().getUrl().substring(Apexpages.currentPage().getUrl().lastIndexOf('/')+1).startsWith('AGN_AMI_SC_Forget_Password'))
            userLanguage = AMI_Language_AGN__c.getValues(ApexPages.currentPage().getParameters().get('lang')).Lang_Code__c;
        else
            userLanguage = [Select LanguageLocaleKey from user where Id =: Userinfo.getUserid() limit 1].LanguageLocaleKey;
    }
    //This Method Resets the user's password and sends an email to the user with the user’s new password.Returns a value indicating whether the password reset was successful
    public void forgotPassword()
    {
        
        List<User> userList = [Select username, Contact.Account.AGN_AMI_SC_Enabled__c, 
                               contact.Is_AMI_SC_Contact_AGN__c, contact.account.IsPersonAccount from User 
                               where Email =: email and isActive = true];
        User user;
        for(User tempUser : userList)
        {
            
            if(tempUser.Contact.Account.IsPersonAccount && tempUser.Contact.Account.AGN_AMI_SC_Enabled__c)
            {
                user = tempUser;
            }
            
            else if(!tempUser.Contact.Account.IsPersonAccount && tempUser.Contact.Is_AMI_SC_Contact_AGN__c)
            {
                user = tempUser;
            }
        }
        if(user != null)
        {
            resetsuccess = Site.forgotPassword(user.username);
        }
        else
            resetSuccess = false;
    }
    //This Method Changes the password of the current user.
    public PageReference changePassword()
    {
        PageReference pr = Site.changePassword(newPassword, verifyNewPassword);
        changeSuccess = (pr != null) ? true : false;
        return pr;
    }   
    
}