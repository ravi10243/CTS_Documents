public class AGN_AMI_Reset_Password_Controller {

    User user;
    public String userLanguage {get;set;}
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    
    public boolean isOldPasswordCorrect{get;set;}
    public boolean success{get;set;}
    
    public AGN_AMI_Reset_Password_Controller()
    {
      user = [Select LanguageLocaleKey from user where Id =: Userinfo.getUserid() limit 1];
      userLanguage = user.LanguageLocaleKey;
    }   
    
     public PageReference internalChangePassword() {
        System.PageReference pg= Site.changePassword(newPassword, verifyNewPassword,oldPassword);
         If (pg==null)
          { 
              isOldPasswordCorrect=False;
              success=false;
              return null;
          }
         else
         {
             isOldPasswordCorrect=True;
              success=true;
   //PMO 3423 returning null to display success message 
             return null;
          
         }
         
    }

}