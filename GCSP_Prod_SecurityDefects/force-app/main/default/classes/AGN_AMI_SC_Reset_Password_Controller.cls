// This class is created as the Controller class of the Visualforce Page - AGN_AMI_SC_Reset_Password_Page
// Author - Cognizant
// Created Date - 11/12/2019
// Last Modified By - Cognizant
public class AGN_AMI_SC_Reset_Password_Controller {
    User user;
    public String userLanguage {get;set;}
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    
    public boolean isOldPasswordCorrect{get;set;}
    
    public AGN_AMI_SC_Reset_Password_Controller()
    {
      user = [Select LanguageLocaleKey from user where Id =: Userinfo.getUserid() limit 1];
      userLanguage = user.LanguageLocaleKey;
    }   
    //This method changes the password for the User
     public PageReference internalChangePassword() {
        System.PageReference pg= Site.changePassword(newPassword, verifyNewPassword,oldPassword);
         
         If (pg==null)
          { 
              system.debug('The Password did not get Changed succesfully');
              isOldPasswordCorrect=False;
              return NUll;
          }
         else
         {
             isOldPasswordCorrect=True;
             return pg;
         }
         
    }

}