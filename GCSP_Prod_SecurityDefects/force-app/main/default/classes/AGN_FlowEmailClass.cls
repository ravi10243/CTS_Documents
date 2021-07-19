public class AGN_FlowEmailClass {
    @InvocableMethod(label='Send email' description='Sends an email')
    public static void callSendEmail(List<AGN_FlowEmailWrapper> sobjDetails){ 
        sendEmail(sobjDetails);
    }
    private static void sendEmail(List<AGN_FlowEmailWrapper> sobjDetails){
        if(sobjDetails != null && sobjDetails.size() > 0){
            System.debug('sobjDetails************ '+sobjDetails);
            System.debug('Invocable class:::::: ');
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
            Map<String, AGN_ICL_Email_Settings__c> emailTemplateCSMap = new Map<String, AGN_ICL_Email_Settings__c>();
            String eTemplateName = '';
            
            for(AGN_ICL_Email_Settings__c emailSetting : AGN_ICL_Email_Settings__c.getAll().Values()){
                    emailTemplateCSMap.put(emailSetting.Country_Code_AGN__c+'-'+emailSetting.Language_Code_AGN__c, emailSetting);
            }
            
            if(sobjDetails != null && sobjDetails.size() > 0 && sobjDetails[0].MCountrycode != null && sobjDetails[0].MLangcode != null
              && sobjDetails[0].OptType != null){   
                  if(sobjDetails[0].OptType == 'Opt_In_vod'){
                      System.debug('opt in*******************');
                      eTemplateName = emailTemplateCSMap.get(sobjDetails[0].MCountrycode+'-'+sobjDetails[0].MLangcode).Opt_in_EmailTemplateName_AGN__c;
                  }else{
                       System.debug('opt out*******************');
                      eTemplateName = emailTemplateCSMap.get(sobjDetails[0].MCountrycode+'-'+sobjDetails[0].MLangcode).Opt_out_EmailTemplateName_AGN__c;
                  }               
            }
            
            if(eTemplateName != null && eTemplateName != ''){
                for(EmailTemplate emailTemp : [SELECT Id,Name,Body,HTMLValue,developername,Subject FROM EmailTemplate WHERE developername = :eTemplateName]){
                	emailTemplateMap.put(emailTemp.developername, emailTemp);
            	}  
            }
                      
        //    System.debug('user************* '+UserInfo.getUserId());
        //    System.debug('profile************* '+UserInfo.getProfileId());
            
            OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where DisplayName ='Allergan International Clinic Locator'];
            
            if ( owea.size() > 0 ) {
                System.debug('OWD ID'+owea.get(0).Id);
                //mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            else{
                System.debug('OWD ID enter else');
                //mail.setSenderDisplayName('Allergan Clinic Locator Portal'); 
            }  
            
            List<String> sendTo = new List<String>();
            sendTo.add(sobjDetails[0].emailId);
            
            System.debug('emailtemplateName*** '+eTemplateName);
            System.debug('accName*** '+sobjDetails[0].accName);
            System.debug('channelLabel*** '+sobjDetails[0].channelLabel);
            System.debug('temp*** '+emailTemplateMap.get(eTemplateName));
            System.debug('opttype*** '+sobjDetails[0].OptType);
            
            if((eTemplateName != null && eTemplateName != '')
               && (sobjDetails[0].accName != null && sobjDetails[0].accName != '')
               && (sobjDetails[0].channelLabel != null && sobjDetails[0].channelLabel != '')
               && (!emailTemplateMap.isEmpty() && emailTemplateMap.get(eTemplateName) != null)){
				   System.debug('*******Enter send email from flow************');	                	
                   mail = AGN_EmailUtilityClass.constructConsentEmail(emailTemplateMap.get(eTemplateName).Subject, 
                                                                       sendTo, owea, emailTemplateMap.get(eTemplateName).Id, 
                                                                       emailTemplateMap.get(eTemplateName).HTMLValue, 
                                                                       sobjDetails[0].accName, sobjDetails[0].channelLabel);
            		mails.add(mail);
                   
                   ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();
                   Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplateMap.get(eTemplateName).Id, null, sobjDetails[0].sobjId);
                   emailLog.Subject_AGN__c =email.Subject;
                   emailLog.From_AGN__c = owea.get(0).Address;          
                   emailLog.Body_AGN__c = email.getHtmlBody();
                   emailLog.Sent_On_AGN__c = datetime.now();
                   emailLog.To_AGN__c = AGN_ICL_SendEmailNotification.getStringValue(sendTo);                            
            	   Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                   emailLog.Success_Error_Message_AGN__c = results[0].isSuccess() ? 'success' : JSON.serialize(results[0].errors); 
                   //------CheckMarx Phase2--Added on 18/11/2020----------
                   List<ICL_Email_Status_Log_AGN__c> emailLogList =  new  List<ICL_Email_Status_Log_AGN__c> ();
                   emailLogList.add(emailLog);
                   String objlog = 'ICL_Email_Status_Log_AGN__c';
                   SObjectType objlogType = ((SObject)(Type.forName('Schema.'+objlog).newInstance())).getSObjectType();
                   AGN_FLSCheck.check(emailLogList,objlogType,'INSERT');
                   //------CheckMarx Phase2--Ends here----------
                   insert emailLog;  
            }            
        }
    }
}