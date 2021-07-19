global without sharing class EmailSendController_GDPR_AGN 
{
      @AuraEnabled 
    public static Business_Owner_Task_GDPR_AGN__c getValues(Id tskId)
    {
        Business_Owner_Task_GDPR_AGN__c botsk = new Business_Owner_Task_GDPR_AGN__c();
        botsk = [SELECT Name,Asset_GDPR_AGN__c,Assigned_To_GDPR_AGN__c, Task_Subject_GDPR_AGN__c,
                 Business_Owner_Comment_AGN_GDPR_Case__c,Case_Type_GDPR_AGN__c,CurrencyIsoCode,
                 Full_Address_GDPR_AGN__c,OwnerId,Provide_additional_Information_GDPR_AGN__c,
                 Related_to_GDPR_AGN__c,Role_with_Allergan_GDPR_AGN__c,
                 Status_GDPR_AGN__c,Third_Party_Email_GDPR_AGN__c, System_ID_AGN__c, Due_Date_AGN__c, Request_Type_GDPR_AGN__c, Data_Subject_Name_GDPR_AGN__c,Days_to_Close_GDPR_AGN__c,
                 Titile_AGN_GDPR__c,Requester_First_Name_GDPR_AGN__c, Requester_Last_Name_GDPR_AGN__c, Affiliation_GDPR_AGN__c, Address_Line_1_Street_Address_GDPR_AGN__c,
                 Address_Line_1_Town_City_GDPR_AGN__c, Address_Line_1_State_GDPR_AGN__c, Address_Line_1_Country_GDPR_AGN__c,Zip_AGN_GDPR__c,
                 Address_Line_1_E_Mail_Address_GDPR_AGN__c,Data_Subject_Phone_GDPR_AGN__c,Rejection_Reason_AGN__c, Justification_for_Others_Role_GDPR_AGN__c
                 from Business_Owner_Task_GDPR_AGN__c where ID = :tskId];
        System.debug('BOTSK '+botsk);
        
        return botsk;  
    }
    
    @AuraEnabled 
    public static void sendMailMethod(String mMail ,String mSubject ,String mbody,Id tskId) 
    {     
        
        Business_Owner_Task_GDPR_AGN__c bot = new Business_Owner_Task_GDPR_AGN__c();
        bot = [SELECT Name,Third_Party_Email_GDPR_AGN__c,Case_Type_GDPR_AGN__c,Related_to_GDPR_AGN__c from Business_Owner_Task_GDPR_AGN__c where ID = :tskId];
       
        System.debug('Third '+bot.Third_Party_Email_GDPR_AGN__c);

        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        
        List<String> sendTo = new List<String>();
         String replyTo = Label.AGN_GDPR_From_Email;
        
        sendTo.add(mMail);
        
        mail.setToAddresses(sendTo);
        mail.setReplyTo(replyTo);
        mail.setSenderDisplayName('Allergan'); 
        
        mail.setSubject(mSubject);
        
        String messageBody = mbody +'<div> <apex:image url="{!URLFOR($Resource.AGN_CCPA_Footer_Image)}"/> </div>'; 
        //mail.setHtmlBody(mbody);
        String mbody_ccpa;
        
        if(bot.Case_Type_GDPR_AGN__c == 'CCPA'){
           	//mbody_ccpa = mbody + Label.AGN_CCPA_Email_Footer;
        	mbody_ccpa = mbody;
            mail.setHtmlBody(mbody_ccpa);
        }
        else{
            mail.setHtmlBody(mbody);
        }
        
        
        EmailMessage newemailMessage = new EmailMessage();
        newemailMessage.fromAddress=replyTo;
        insert newemailMessage;  
        
        mails.add(mail);
        
        Messaging.sendEmail(mails);
        
       
        
        External_Email_Communication_GDPR_AGN__c em = new External_Email_Communication_GDPR_AGN__c();
        em.Business_Owner_Task_GDPR_AGN__c=tskId;
        //em.Email_GDPR_AGN__c=bot.Third_Party_Email_GDPR_AGN__c;
        //em.Associated_Case_GDPR_AGN__c =bot.Related_to_GDPR_AGN__c;
        em.Email_Sent_To__c=mMail;
        em.Email_From_GDPR_AGN__c='System Owner';
        if(bot.Case_Type_GDPR_AGN__c == 'CCPA')
        {
           	em.Email_Body_GDPR_AGN__c=mbody_ccpa;
        }
        else
        {
            em.Email_Body_GDPR_AGN__c=mbody;
        }
        em.Email_Subject_GDPR_AGN__c = mSubject;
        try
        {
            insert em;    
        }
        catch(DmlException e)
        {   
            System.debug('An unexpected error has occurred: ' + e.getMessage());
           
        }
    }
}