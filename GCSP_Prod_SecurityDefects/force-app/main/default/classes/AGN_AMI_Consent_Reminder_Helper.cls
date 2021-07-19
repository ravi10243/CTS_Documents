public class AGN_AMI_Consent_Reminder_Helper 
{
    @InvocableMethod
    //To trigger reminder email to if user has not verified consent submitted
    public static void triggerReminder(List<Id> idList)
    {
        List<Messaging.SingleEmailMessage > emailList = new List<Messaging.SingleEmailMessage>();
        List<Allergan_Customer_Registration_AGN__c> acrList = [Select id, Country_Code_AGN__c, AMI_Consent_Verified_AGN__c 
                                                               from Allergan_Customer_Registration_AGN__c 
                                                               where id in: idList];
        Map<String, AMI_User_Settings_AGN__c> settingsMap = AMI_User_Settings_AGN__c.getAll();
        Id templateId = [Select id from EmailTemplate where DeveloperName = 'AGN_AMI_Communities_Consent_Verification' Limit 1].Id;
        Id senderId = [Select id from OrgWideEmailAddress where DisplayName = 'AMI Sender' Limit 1].Id;
        for(Allergan_Customer_Registration_AGN__c acr : acrList)
        {
            AMI_User_Settings_AGN__c aus = settingsMap.get(acr.Country_code_AGN__c);
            if(aus.Consent_Required_AGN__c && !acr.AMI_Consent_Verified_AGN__c)
            {
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(templateId,UserInfo.getUserId(),acr.Id);
                List<String> emailAddress = new List<String>();
                emailAddress.add(acr.Email_AGN__c);
                email.setToAddresses(emailAddress);
                email.setOrgWideEmailAddressId(senderId);
                email.setSaveAsActivity(false);
                emailList.add(email);
            }
        }
        Messaging.sendEmail(emailList);
    }
}