public class AGN_AMI_Email_Reset_Password_Controller {
    User user;
    public String userLanguage {get;set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}
    public string returnMessage{get;set;}
    public boolean resetSuccess{get;set;}
    public boolean IsLinkExpired{get;set;}
    public boolean IsPasswordAlreadyReset{get;set;}
    public string country{get;set;}
    
    public AGN_AMI_Email_Reset_Password_Controller(){
        ID userId=null;
        IsLinkExpired=false;
        IsPasswordAlreadyReset=false;
        resetSuccess=false;
        if(ApexPages.currentPage().getParameters().get('country') != null)
        {
            AMI_URL_Redirect_Settings_AGN__c aur = [Select Name 
                                                    from AMI_URL_Redirect_Settings_AGN__c 
                                                    where Country_Code__c = :ApexPages.currentPage().getParameters().get('country') Limit 1];
            country = aur.Name;
        }
        if(ApexPages.currentPage().getParameters().get('UserId')!=null){
        	 userId=ApexPages.currentPage().getParameters().get('UserId');
        }
        if(ApexPages.currentPage().getParameters().get('lang')!=null){
        	 userLanguage=ApexPages.currentPage().getParameters().get('lang');
        }
        user = [Select Id,Is_AMI_Country_Demo_User_AGN__c,UserName,AMI_Password_Reminder_Send_Date__c,LastPasswordChangeDate from user where Id =: userId limit 1];        
        datetime dt = user.AMI_Password_Reminder_Send_Date__c;
        datetime days = System.Now() - integer.valueof(system.label.AGN_AMI_Password_Reminder_Link_Active_Days);
        datetime PasswordResetDate=user.LastPasswordChangeDate;
        if(dt < days){
            IsLinkExpired=true;
        }
        if(dt < PasswordResetDate && IsLinkExpired==false){
            IsPasswordAlreadyReset=true;
        }
    }
    
    public PageReference countryRedirect()
    {
        PageReference pr;
        pr = new PageReference(AMI_URL_Redirect_Settings_AGN__c.getValues(country).Redirect_URL__c);
        return pr;
    }
    
    public PageReference changePassword(){
        try
        {
         	System.Setpassword(user.Id,newPassword);
            resetSuccess=true;
            returnMessage=system.label.AGN_AMI_Reset_Password_Success_Msg;
        }
        catch(Exception ex)
        {
            returnMessage=ex.getMessage();
            
            if(returnMessage.containsIgnoreCase(system.label.AGN_AMI_Reset_Password_Error_Msg_1_Value))
                returnMessage=system.label.AGN_AMI_Reset_Password_Error_Msg_1;
            else if(returnMessage.containsIgnoreCase(system.label.AGN_AMI_Reset_Password_Error_Msg2_Value))
                returnMessage=system.label.AGN_AMI_Reset_Password_Error_Msg2;
            else if(returnMessage.containsIgnoreCase(system.label.AGN_AMI_Reset_Password_Error_Msg3_Value))
                returnMessage=system.label.AGN_AMI_Reset_Password_Error_Msg3;
            
            resetSuccess=false;
        }        
        return null;
    }
}