/*
*------------------------------------------------------------------------------------------------------------------------+
* @author         Cognizant
* @createdBy      Rajeev Roushan
* @modifiedBy     Rajeev Roushan
* @maintainedBy   
* @version        2.0
* @created       15 April 2019
* @modified      24 March 2020
* @testClass      
* ----------------------------------------------------------------------------------------------------------------------
* @description
* v2.0          
*      
* Apex  class added for Email Service used to capture DS response to the PO Users.
*-------------------------------------------------------------------------------------------------------------------------+
*/
global class AGN_GDPR_ReceiveEmailResponse implements Messaging.InboundEmailHandler 
{
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
                                                           Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        External_Email_Communication_GDPR_AGN__c objExEmailcom = new External_Email_Communication_GDPR_AGN__c();
        objExEmailcom.Email_GDPR_AGN__c = email.fromAddress;
        objExEmailcom.Email_Subject_GDPR_AGN__c = email.subject;
        objExEmailcom.Email_Body_GDPR_AGN__c = email.htmlBody;
        objExEmailcom.Email_From_GDPR_AGN__c = 'Third Party';
        
        //Get information from Case or Business Owner Task
        string strEmailSubject = email.subject;
        string strAfterSeperator = strEmailSubject.substringAfter('[');
        system.debug('==>1 : ' + strAfterSeperator);
        string strBeforeSeperator = strAfterSeperator.substringBefore(']');
        system.debug('==>2 : ' + strBeforeSeperator);
        
        if(strBeforeSeperator.contains('Case')) //response for Business Owner Task
        {
            system.debug('==>3 : ');
            List<Business_Owner_Task_GDPR_AGN__c> lstBSTask = new List<Business_Owner_Task_GDPR_AGN__c>();
            lstBSTask = [Select Id, Name,OwnerId, Assigned_To_GDPR_AGN__c, Assigned_To_GDPR_AGN__r.Email,Related_to_GDPR_AGN__c from Business_Owner_Task_GDPR_AGN__c where Name =: strBeforeSeperator];
            system.debug('==>4 : ' + lstBSTask);
            system.debug('==>4.1 :' + lstBSTask[0].Assigned_To_GDPR_AGN__r.Email);
            if(lstBSTask.size() > 0)
            {
                objExEmailcom.Business_Owner_Task_GDPR_AGN__c = lstBSTask[0].Id;
                objExEmailcom.Parent_Owner_Email_GDPR_AGN__c = lstBSTask[0].Assigned_To_GDPR_AGN__r.Email;
                objExEmailcom.OwnerId = lstBSTask[0].OwnerId;
              //  objExEmailcom.Associated_Case_GDPR_AGN__c =lstBSTask[0].Related_to_GDPR_AGN__c;
            }
        }
        else
        {
            List<Case> lstCase = new List<Case>();
            lstCase = [Select Id, CaseNumber, OwnerId from case where CaseNumber =: strBeforeSeperator];
            system.debug('==>5 : ' + lstCase);
            if(lstCase.size() > 0)
            {
                objExEmailcom.Associated_Case_GDPR_AGN__c = lstCase[0].Id;
                objExEmailcom.OwnerId = lstCase[0].OwnerId;
            }
        }
        insert objExEmailcom;
        system.debug('==>1: ' + objExEmailcom.Id);
        
        //Read the Email Attachment Save attachments, if any
        List<Attachment> attachmentList = new List<Attachment>();
        if(email.textAttachments!=null) 
        {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                Attachment attachment = new Attachment();
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = objExEmailcom.Id;
                attachmentList.add(attachment);
            }
        }
        
        //Save any Binary Attachment
        if(email.binaryAttachments!=null){
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Attachment attachment = new Attachment();
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = objExEmailcom.Id;
                attachmentList.add(attachment);
            }
        }
        
        if(!attachmentList.isEmpty()){
            insert attachmentList;
        }
        //End
        return result;
    }
}