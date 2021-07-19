public class AGN_GCSP_EmailSendController {
    
      @AuraEnabled 
    public static Case getCaseDetails(Id caseId)
    {
        Case caseObj = new Case();
        caseObj= [SELECT CaseNumber,Subject,Country_Code_AGN__c FROM Case where ID = :caseId];
        return caseObj;  
    }
    
      @AuraEnabled 
    public static List<String> getFromAddress()
    {
        List<String> fromAddressList = new List<String> ();
        String userName = UserInfo.getUserName();
		User activeUser = [Select Email From User where Username = : userName limit 1];
        fromAddressList.add(activeUser.Email);
        System.debug('User Email:' +fromAddressList);
        List<OrgWideEmailAddress> oweaList = [select Id,Address from OrgWideEmailAddress];
        for(OrgWideEmailAddress owea : oweaList) 
         {
            fromAddressList.add(owea.Address);
		 }
         System.debug('org wide Email:' +fromAddressList);
        return fromAddressList;  
    }
    
    
    @AuraEnabled 
    public static String sendMailMethod(String mMail ,String mSubject ,String mbody,String mailCCAddress, String mailBCCAddress,Id atachID,Id caseID,String fromEmail) 
    {     
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        List<String> sendTo = new List<String>();
        List<String> ccAddress = new List<String>(); 
        List<String> bccAddress = new List<String>(); 
        sendTo = mMail.split(';');
        for(Integer mailCount=0;mailCount<sendTo.size();mailCount++)
        {
            if(String.isBlank(sendTo[mailCount]))
            {
                sendTo.remove(mailCount);
            }
        }
        
        mail.setToAddresses(sendTo);
        mail.setBccSender(false);
        
        if(String.isNotBlank(mailCCAddress))
        {
            ccAddress = mailCCAddress.split(';');
            
            for(Integer mailCount=0;mailCount<ccAddress.size();mailCount++)
            {
                if(String.isBlank(ccAddress[mailCount]))
                {
                    ccAddress.remove(mailCount);
                }
            }
            
            mail.setCcAddresses(ccAddress);
        }
        if(String.isNotBlank(mailBCCAddress))
        {  
            bccAddress = mailBCCAddress.split(';');
            
            for(Integer mailCount=0;mailCount<bccAddress.size();mailCount++)
            {
                if(String.isBlank(bccAddress[mailCount]))
                {
                    bccAddress.remove(mailCount);
                }
            }
            
            mail.setBccAddresses(bccAddress);
        }  
        mail.setSubject(mSubject);
        mail.setHtmlBody(mbody);
       OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :fromEmail];
       if (owea.size() > 0) 
       {
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
	   }
        else{
            	 mail.setSenderDisplayName(UserInfo.getFirstName()+' '+UserInfo.getLastName()); 
        }
       
        if(atachID != NULL)
        {
            List<Messaging.EmailFileAttachment> fileAttachmentsList = new List<Messaging.EmailFileAttachment>();
            ContentDocumentLink contentDocLink = [SELECT id,ContentDocument.Title,ContentDocument.FileType,
                                                  ContentDocument.FileExtension,
                                                  ContentDocument.LatestPublishedVersionId,ContentDocument.LatestPublishedVersion.VersionData  
                                                  FROM ContentDocumentLink WHERE ContentDocumentId = :atachID AND LinkedEntityID = :caseID];
            
            Messaging.Emailfileattachment emailFileAttachment = new Messaging.Emailfileattachment();
            emailFileAttachment.setFileName(contentDocLink.ContentDocument.Title+'.'+contentDocLink.ContentDocument.FileExtension);
            emailFileAttachment.setBody(contentDocLink.ContentDocument.LatestPublishedVersion.VersionData);
            fileAttachmentsList.add(emailFileAttachment);
            mail.setFileAttachments(fileAttachmentsList);
        }
                
      	EmailMessage newemailMessage = new EmailMessage();
        
        newemailMessage.fromAddress=fromEmail;
        newemailMessage.ParentId = caseID;
        newemailMessage.ToAddress = mMail;
        newemailMessage.CcAddress = mailCCAddress;
        newemailMessage.BccAddress= mailBCCAddress;
        newemailMessage.HtmlBody = mbody;
        newemailMessage.Subject = mSubject;
            
        if(Schema.sobjectType.EmailMessage.iscreateable())
        {
            insert newemailMessage; 
        }
        
        if(atachID != NULL){
            ID emailMessageID = newemailMessage.Id;
            ContentDocumentLink documentLink = new ContentDocumentLink();
            documentLink.LinkedEntityId = emailMessageID;
            documentLink.ContentDocumentId = atachID;
        	if(Schema.sobjectType.ContentDocumentLink.iscreateable())
        	{
           		 insert documentLink; 
        	}
        }
		
        mails.add(mail);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(mails); 
        System.debug('Email status'+r);
		if(r[0].IsSuccess() == false){
		  Messaging.SendEmailError [] e = r[0].getErrors();
 		  return 'There was a problem processing the email. Please contact your system administrator. ' + e[0].getMessage(); 
        }else{
            return 'Success';
        }
    }
   

}