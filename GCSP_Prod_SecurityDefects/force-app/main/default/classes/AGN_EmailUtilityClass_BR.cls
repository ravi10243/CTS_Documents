public class AGN_EmailUtilityClass_BR {
    public static Messaging.SingleEmailMessage constructEmail(String subject, List<String> toAddresses,List<OrgWideEmailAddress> owea,Id templateId , String body, string Name,List<Messaging.EmailFileAttachment> email_attachments){      
        //Construct email message based upon received parameters.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject); 
        mail.setToAddresses(toAddresses);
        //mail.setTargetObjectId(dcrId);
        if (owea.size()>0) {
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
         }
        mail.setTemplateId(templateId);
        //setHtmlBody -- sets the HTML body instead a plain text body.
        system.debug('body===='+body);
        body= body.replace('{!Account.FirstName}{!Account.LastName}', Name);
        mail.setHtmlBody(body); 
     if(email_attachments !=null)
     {
        mail.setFileAttachments(email_attachments);
        }
        return mail;
    }
    
    /*Construct Email for Consent Email Notification*/
    public static Messaging.SingleEmailMessage constructConsentEmail(String subject, List<String> toAddresses,List<OrgWideEmailAddress> owea,Id templateId , String body, string accName,String channelLabel){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(toAddresses);
        if (owea.size()>0) {
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
         }
        mail.setTemplateId(templateId);
        if(!String.isBlank(channelLabel)){
        subject = subject.replace('{!Multichannel_Consent_vod__c.AGN_Consent_Label_Email_Template__c}',channelLabel);
        body=body.replace('{!Multichannel_Consent_vod__c.AGN_Consent_Label_Email_Template__c}',channelLabel);
        }
        /*else{
        subject = subject.replace('{!Consent_Type_vod__c.Channel_Label_vod__c}','AGN Product and Service Direct Marketing Consent - Email');
        body=body.replace('{!Consent_Type_vod__c.Channel_Label_vod__c}','AGN Product and Service Direct Marketing Consent - Email');
        }*/
        body=body.replace('{!Multichannel_Consent_vod__c.Doctors_Name_AGN__c}',accName);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        return mail;
    }

}