public class AGN_OAMPortalCaseRejectsendAnEmail
{
    @InvocableMethod(label='Send an email from apex class' description='sends an email to customer if case is rejected')
    public static void sendEmailWithAttachment(list<Id> caseIdList)
    {
        String caseId = String.escapeSingleQuotes(caseIdList[0]);
        
        
        Allergan_Customer_Registration_AGN__c acr = [SELECT Id,First_Name_AGN__c,Last_Name_AGN__c,Case_AGN__c,Case_AGN__r.ContactId,Case_AGN__r.CaseNumber,
                                                     Rejected_Case_AGN__c,Email_AGN__c, SAP_Country_Code_AGN__c, RecordType.DeveloperName 
                                                     FROM Allergan_Customer_Registration_AGN__c WHERE Case_AGN__c =: caseId LIMIT 1];
        
        if(acr.Rejected_Case_AGN__c && (acr.SAP_Country_Code_AGN__c == 'AU' || acr.SAP_Country_Code_AGN__c == 'NZ')){
            List<AGN_EmailMessageWrapper> listEmailMessageWrapper = new List<AGN_EmailMessageWrapper>();
            Map<String, String> mapSubjectParams = new Map<String, String>();				
            Map<String, String> mapBodyParams = new Map<String, String> {
                    '{!Recipient.FirstName}' => acr.First_Name_AGN__c,
                    '{!Recipient.LastName}' => acr.Last_Name_AGN__c,
                    '{!CaseNumber}' => acr.Case_AGN__r.CaseNumber
                    };
            listEmailMessageWrapper.add(new AGN_EmailMessageWrapper('noreply@salesforce.com', acr.Email_AGN__c, null, null, null, mapSubjectParams, null, mapBodyParams));
            
            String senderEmailAddress = AGN_OAMConstant.SENDEREMAILADDRESS;
            if(listEmailMessageWrapper.size() > 0){
                //second parameter of sendEmail() is email template name (e.g: Self Registration: Welcome Email-DE)
                //System.debug('####Language Code #### '+ AGN_OAMConstant.USER_LANGUAGE.toUpperCase());
                String countryCode = acr.SAP_Country_Code_AGN__c;//Country_Code_AGN__c           
                String welcomeEmailTemplateName = 'Offline_Customer_Registration_AR_Rejection_'+countryCode;
                //System.debug('####email template name #### '+ welcomeEmailTemplateName);
                sendEmail(listEmailMessageWrapper, welcomeEmailTemplateName, senderEmailAddress);
            }
        }
    }
    
    public static void sendEmail(List<AGN_EmailMessageWrapper> listEmailMessageWrapper, String emailTemplateName, String fromEmailAddress) {
        Messaging.reserveSingleEmailCapacity(2);
        List<Messaging.SendEmailResult> listEmailResult = null;
        List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE developerName = :emailTemplateName];  
       
        for (AGN_EmailMessageWrapper emailMessageWrapper : listEmailMessageWrapper) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: fromEmailAddress];
            if ( owea.size() > 0 ) {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            else{
                mail.setSenderDisplayName('Allergan Customer Portal'); 
            } 
           
            if(emailMessageWrapper.ToAddress != null && emailMessageWrapper.ToAddress.length() > 0)
                mail.setToAddresses(new String[] { emailMessageWrapper.ToAddress });
            else
                mail.setTargetObjectId(emailMessageWrapper.ToAddressId);
            if(emailMessageWrapper.BccAddress != null && emailMessageWrapper.BccAddress.length() > 0)
                mail.setBccAddresses(new String[] {emailMessageWrapper.BccAddress });
            String subject = null;
            if(emailMessageWrapper.Subject != null && emailMessageWrapper.Subject.length() > 0) {
                mail.setSubject(emailMessageWrapper.Subject);
                subject = emailMessageWrapper.Subject;
            }
            else{
                subject = emailTemplate.Subject;
            }
            for(String key: emailMessageWrapper.ParameterSubjectMap.keySet()){
                subject = subject.replace(key, (emailMessageWrapper.ParameterSubjectMap.get(key) == null ? '' : emailMessageWrapper.ParameterSubjectMap.get(key)));
            }
            
            mail.setSubject(subject);
            String htmlBody = emailTemplate.HtmlValue;
            String plainBody = emailTemplate.Body;
            for (String key : emailMessageWrapper.ParameterBodyMap.keySet()) {
                htmlBody = htmlBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
                plainBody = plainBody.replace(key, (emailMessageWrapper.ParameterBodyMap.get(key) == null) ? '' : emailMessageWrapper.ParameterBodyMap.get(key));
            }
            
            mail.setHtmlBody(htmlBody);
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(plainBody);
            listSingleEmailMessages.add(mail);
        }
        if(!Test.isRunningTest()){
            listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
        } 
    }
    
}