/*
*------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev
* @modifiedBy     Rajeev
* @maintainedBy   
* @version        1.0
* @created        
* @modified      08-FEB-2020
* @testClass      
* ----------------------------------------------------------------------------------------------------------------------
* @description
* v1.0          
* 08-FEB-2020   		
* USED BY PROCESS BUILDER AGN Deletion Approval Mail for Deletion Approval Verification by DS.
*-------------------------------------------------------------------------------------------------------------------------+
*/
public class DS_DeletionApproval_AGN {
    @InvocableMethod
    public static void DeletionApproval(List<ID> caseIdList)
    {
        System.debug('ID   --> '+caseIdList[0]);
        ID caseId = caseIdList[0];
        
        List<Case> caseList = new List<Case>();
        caseList=[Select Id,CaseNumber,Data_Subject_Email_GDPR_AGN__c,Titile_AGN_GDPR__c,Last_Name_GDPR_AGN__c,Deletion_Status_AGN__c from Case where Id =:caseId];
        
        caseList[0].Deletion_Status_AGN__c ='Awaiting Reply';
        Update caseList;
        External_Email_Communication_GDPR_AGN__c ex = new External_Email_Communication_GDPR_AGN__c();
        ex.Associated_Case_GDPR_AGN__c=caseId;
        ex.Email_From_GDPR_AGN__c='System Owner';
        
        ex.Email_Sent_To__c=caseList[0].Data_Subject_Email_GDPR_AGN__c;
        ex.Email_Subject_GDPR_AGN__c='['+caseList[0].CaseNumber+'] '+System.Label.AGN_DeletionApprovalSubject;
        ex.Email_Body_GDPR_AGN__c='Dear '+caseList[0].Titile_AGN_GDPR__c+' '+caseList[0].Last_Name_GDPR_AGN__c +'\n'+ System.Label.AGN_DeletionApprovalBody +'\n';
        
        
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        
        List<String> sendTo = new List<String>();
        String replyTo = System.Label.AGN_GDPR_From_Email;
        
        
        sendTo.add(caseList[0].Data_Subject_Email_GDPR_AGN__c);
        
        mail.setToAddresses(sendTo);
        mail.setReplyTo(replyTo);
        
        String mSubject = '['+caseList[0].CaseNumber+']'+System.Label.AGN_DeletionApprovalSubject;
        mail.setSubject(mSubject);
        
        String mbody_ccpa = 'Dear '+caseList[0].Last_Name_GDPR_AGN__c +','+'\n'+'&nbsp;'+System.Label.AGN_DeletionApprovalBody +'\n';
        
        OrgWideEmailAddress[] oweaccpa = [select Id from OrgWideEmailAddress where DisplayName = :AGN_GDPR_ConstantUtility.CCPA_ACCESSREQ ];
        if ( oweaccpa.size() > 0 ) 
        {
            mail.setOrgWideEmailAddressId(oweaccpa.get(0).Id);
        }
        mail.setHtmlBody(mbody_ccpa);
        
        EmailMessage newemailMessage = new EmailMessage();
        newemailMessage.fromAddress=replyTo;
        insert newemailMessage;  
        
        mails.add(mail);
        
        Messaging.sendEmail(mails);
        
        try
        {
            Insert ex;
        }
        catch(DmlException e) 
        {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}