/*****************************************************************************************************************************************************************
Apex  Class- AGN_prepareMessageListutility
Description- A utility class for batch 'AGN_ContractExhibitNotificationBatch'.
             This class prepare email list for sending email notifications to contract exhibit records
Developer Name- Mansi Mittal
Development Date- 3 May 2018
********************************************************************************************************************************************************************/


public with sharing class AGN_prepareMessageListutility {
    
    public static List<Messaging.SingleEmailMessage> prepareMessageList(Map<Id,Set<String>> tempIdToEmailMap,Map<Id,EmailTemplate> tempToHTMLMap, Map<Id,List<attachment>> tempIdToAttachMap, Id fromAdrs,Map<String, String> emailToNameMap ,Map<Id,String> tempIdToLangMap){
        
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        List<String> emailSuccessList;
        for(Id temp:tempIdToEmailMap.keySet() ){
            System.debug('preparing email');
            for(String email: tempIdToEmailMap.get(temp)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(temp);
            emailSuccessList= new List<String>(tempIdToEmailMap.get(temp));
            mail.setOrgWideEmailAddressId(fromAdrs);
            List<String> emailSet= new List<String>();
            emailSet.add(email);
            mail.setToAddresses(emailSet);
            mail.setSubject(tempToHTMLMap.get(temp).Subject);
            String body= tempToHTMLMap.get(temp).HTMLValue;
            String emailLang=email+tempIdToLangMap.get(temp);
                System.debug('tempIdToLangMap.get(temp)'+tempIdToLangMap.get(temp));
                System.debug('emailToNameMap'+emailToNameMap);
                System.debug('emailToNameMap.get'+emailToNameMap.get(emailLang));
                System.debug('emailLang'+emailLang);
            body= body.replace('{!Data_Change_Request_vod__c.Doctor_Name_AGN__c}', emailToNameMap.get(emailLang));
            //body= body.replace('{!Data_Change_Request_vod__c.Doctor_Name_AGN__c}', '');
            mail.setHtmlBody(body);
            List<Messaging.EmailFileAttachment> email_attachments = new List<Messaging.EmailFileAttachment>();
            if(tempIdToAttachMap.containsKey(temp)) {
                    for(attachment att: tempIdToAttachMap.get(temp)){
                        Messaging.EmailFileAttachment email_att = new Messaging.EmailFileAttachment();
                        email_att.setBody(att.Body);
                        email_att.setContentType(att.ContentType);
                        email_att.setFileName(att.Name);
                        email_att.setinline(false);
                        email_attachments.add(email_att);
                    }
            }
            System.debug('email_attachments'+email_attachments);
            mail.setFileAttachments(email_attachments);
            messageList.add(mail);
            System.debug('@@'+messageList);
        } 
      }
     return messageList;
    }

}