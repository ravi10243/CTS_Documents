public class AGN_ICL_CommonEmailHandler {
    
    @InvocableMethod(label='NotifyRejection')
    public static void sendMailLocatorListing(List<AGN_ICL_LocatorEmailWrapper> locWrapList){
        
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String fromEmailAddress = (String)portalSetting.From_Email_Address_AGN__c;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
        Map<String,List<Locator_Listing_AGN__c> > countryLocMap = new  Map<String,List<Locator_Listing_AGN__c> >();
        String emailTempalte = locWrapList[0].templateName;
        list<ICL_Email_Status_Log_AGN__c> logList = new list<ICL_Email_Status_Log_AGN__c>();
        
        for(AGN_ICL_LocatorEmailWrapper wrpObj: locWrapList){
            
            if(countryLocMap.containsKey(wrpObj.CountryCode)){
                countryLocMap.get(wrpObj.CountryCode).add(wrpObj.locObj);
            }
            else{
                countryLocMap.put(wrpObj.CountryCode,new List<Locator_Listing_AGN__c>());
                countryLocMap.get(wrpObj.CountryCode).add(wrpObj.locObj);
            }
            
        }
        try{
            OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address =: fromEmailAddress LIMIT 1];
            EmailTemplate emailTempateObj = [SELECT Id, Body, Description, Name, Subject, Markup, HtmlValue, DeveloperName  
                                             FROM EmailTemplate 
                                             WHERE DeveloperName =:emailTempalte LIMIT 1];
            for(String str:countryLocMap.keySet()){
                
                if(countryLocMap.get(str).Size()>0){
                    
                    for(Locator_Listing_AGN__c ltrObj: countryLocMap.get(str)){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setOrgWideEmailAddressId(owea.Id); 
                        List<String> sendTo = new List<String>();
                        //sendTo.add(ltrObj.Email_AGN__c);
                        sendTo.add(ltrObj.Clinic_Admin_Email_AGN__c);
                        mail.setToAddresses(sendTo);                        
                        mail.setTargetObjectId(UserInfo.getUserId());
                        mail.setWhatId(ltrObj.Id);        
                        mail.setTreatTargetObjectAsRecipient(false);        
                        mail.setSaveAsActivity(false);  
                        mail.setCharset('UTF-8');
                        mail.setTemplateId(emailTempateObj.id);          
                        mails.add(mail);
                        ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();
                        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTempateObj.id, null, ltrObj.id);
                        emailLog.Subject_AGN__c =email.Subject;
                        emailLog.From_AGN__c = fromEmailAddress;          
                        emailLog.Body_AGN__c = email.getHtmlBody();
                        emailLog.Sent_On_AGN__c = datetime.now();
                        emailLog.To_AGN__c = AGN_ICL_SendEmailNotification.getStringValue(sendTo);
                        logList.add(emailLog); 
                    }
                }
            }
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            if(results.size() > 0){  
                
                integer i=0;
                for(Messaging.SendEmailResult result : results){            
                    logList[i].Success_Error_Message_AGN__c = result.isSuccess() ? 'success' : JSON.serialize(result.errors);    
                    i++;
                }   
                if(logList.size()>0){      
                    insert logList;  
                }                    
            }
        }
        catch(exception ex){

        }
    }
}