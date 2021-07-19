/*****************************************************************************************************
* @Author: Cognizant Team 
* @Class Name: AGN_AttachmentTriggerHandler
* @Description: Handler class for Attachment Trigger 
                
*******************************************************************************************************/

public class AGN_AttachmentTriggerHandler
{
    //if any new attachment is added to a case record, then this method will work
    public void insertUpdateAttachment(List<Attachment> attachmentList)
    {
        List<Case> caseList = new List<Case>();
        List<Case> caseUpdateList = new List<Case>();
        Set<Id> caseIdSet = new Set<id>();
        if(!attachmentList.isEmpty())
        {
            for(Attachment a: attachmentList)
            {
                //adding the parentId of the new attachment to the caseIdSet1 Set.
                caseIdSet.add(a.parentId);
            }
        }
        
        //fetching the case record ID & attachment Id to which the new attachment is related
        if(!caseIdSet.isEmpty()){
        caseList = [SELECT id,PR_ID_Trackwise_AGN__c,OTI_Batch_Status_CoolS_AGN__c, (SELECT id FROM Attachments) FROM Case WHERE id in: caseIdSet];
        }
        
        for(Case c : caseList)
        {
            //checking if this case has any IntakeID or not,if it has an IntakeID, then only it will set the OTI_Batch_Status_CoolS_AGN__c as Scheduled
            if(c.PR_ID_Trackwise_AGN__c != null)
            {
                //setting the OTI_Batch_Status_CoolS_AGN__c field of that case record as Scheduled
               if(Schema.sObjectType.Case.fields.OTI_Batch_Status_CoolS_AGN__c.isUpdateable()){
                c.OTI_Batch_Status_CoolS_AGN__c = 'Scheduled';
               }
                caseUpdateList.add(c);
            }
        }
        
        if(!caseUpdateList.isEmpty()){
         update caseUpdateList;
        }
    }
}