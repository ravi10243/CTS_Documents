//public class AGN_ICL_SendEmailCtrl {
public without sharing class AGN_ICL_SendEmailCtrl {  /* added without sharing for Spring'21 Release Updates */
    @AuraEnabled
    //get from getuserinfo.contactid and corrresponding person account id 
    public static Boolean sendEmailToContactMethod(String emailtocontact,String loclstId)
    {
        Boolean success = false;
        //User usr = [select id,name,accountid,Locator_Listing_Id_AGN__c from User where id=:UserInfo.getUserId() limit 1];
        
        //String loc_id = usr.Locator_Listing_Id_AGN__c;
        List<Practitioner_Listing_AGN__c> ListCon = new List<Practitioner_Listing_AGN__c> ([Select id,Email_AGN__c, Clinic_AGN__c, Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c, Locator_Listing_AGN__r.User_Language_AGN__c
                                                                                            from Practitioner_Listing_AGN__c 
                                                                                            where Locator_Listing_AGN__c =:loclstId]);
        
        Practitioner_Listing_AGN__c sendpract;
        if(ListCon.size() > 0)
        {
            for(Practitioner_Listing_AGN__c pract : ListCon)
            {
                if(pract.Email_AGN__c == emailtocontact)
                { 
                    sendpract = pract;
                    success = true;  
                    break;
                }
            }
            if(success == true && sendpract !=null)
            {
                Boolean sent = AGN_ICL_SendEmailCtrl.sendEmailtoPractitioner(sendpract);
                return sent;
            }
            else
            {
                return false;
            }
            //return true;   
        }
        else
        {
            return false;
        }
        //return false;
    }

    public static Boolean sendEmailtoPractitioner(Practitioner_Listing_AGN__c practitioner) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<AGN_ICL_Email_Settings__c> emailSettingList = AGN_ICL_Email_Settings__c.getAll().values();
       
        
        String emailtemplateName = '';
        for(AGN_ICL_Email_Settings__c emailSetting : emailSettingList){
            if(emailSetting.Country_Code_AGN__c == practitioner.Locator_Listing_AGN__r.Country_Code_AGN__r.Alpha_2_Code_vod__c
               && emailSetting.Language_Code_AGN__c == practitioner.Locator_Listing_AGN__r.User_Language_AGN__c){
                   emailtemplateName = emailSetting.Opt_out_Ins_Email_template_Name__c;
                 
                   break;
               }
            else{
                 
                //return false;
            }	
        }
        
        EmailTemplate et;
            
        if(emailtemplateName != '' && emailtemplateName != null)
        	et=[Select id,Subject,developername from EmailTemplate where developername=:emailtemplateName]; 
        else 
            return false;
        
     //   EmailTemplate et=[Select id from EmailTemplate where Name=: 'AGN_ICL_SendlPractitioner_Instructions']; 
        
        AGN_ICL_Portal_Settings__c portalSetting = AGN_ICL_Portal_Settings__c.getInstance();
        String fromEmailAddress = (String)portalSetting.From_Email_Address_AGN__c;
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: fromEmailAddress];
        if ( owea.size() > 0 ) {
           
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        else{
            mail.setSenderDisplayName('Allergan Clinic Locator Portal'); 
        }
        
        List<String> sendTo = new List<String>();
        sendTo.add(practitioner.Email_AGN__c);
        mail.setToAddresses(sendTo);
        //mail.setReplyTo('sambit.rout@cognizant.com');
        //mail.setSenderDisplayName('Allergan ICL');
        mail.setWhatId(practitioner.id);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setSaveAsActivity(false);
        mail.setTemplateId(et.id); 
        mail.setCharset('UTF-8');
        mails.add(mail);
        
        ICL_Email_Status_Log_AGN__c emailLog = new ICL_Email_Status_Log_AGN__c();	
        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(et.id, null, practitioner.id);	
        emailLog.Subject_AGN__c =email.Subject;	
        emailLog.From_AGN__c = fromEmailAddress;	
        emailLog.Body_AGN__c = email.getHtmlBody();	
        emailLog.Sent_On_AGN__c = datetime.now();	
        emailLog.To_AGN__c = practitioner.Email_AGN__c;
        
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        emailLog.Success_Error_Message_AGN__c = results[0].isSuccess() ? 'success' : JSON.serialize(results[0].errors); 
        insert emailLog;
        
        if (results[0].success) {
            return true;
        } else {
            return false;
        }
    } 
      @AuraEnabled
    //get Country name for GTM by Locatorlisting id 
    public static string getCountrydeatisbyLocId(String loclstId)
    { 
        Locator_Listing_AGN__c llc =[select id,Country_AGN__c from Locator_Listing_AGN__c where id =:loclstId ];

        return llc.Country_AGN__c;
    }
}