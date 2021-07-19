@isTest
public class AGN_AttachmentTriggerHandler_Test {
    
    @isTest
    public static void testInsertAttachment(){
        
        User AdminUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        Test.startTest();
        
        System.runAs(AdminUser){ 
            Case cs = new case(PR_ID_Trackwise_AGN__c = 'INT-000012',OTI_Batch_Status_CoolS_AGN__c='');
            Insert cs;
            Blob b = Blob.valueOf('Test Data');
            Attachment att = new Attachment(parentId =cs.Id,Name='Test',Body=b);
            Insert att;
            List<Attachment> attList = new List<Attachment>();
            attList.add(att);
            
            AGN_AttachmentTriggerHandler excute = new AGN_AttachmentTriggerHandler();
            excute.insertUpdateAttachment(attList);
            Case cas = [Select PR_ID_Trackwise_AGN__c,OTI_Batch_Status_CoolS_AGN__c from Case where Id =:cs.id]; 
            System.assertEquals(cas.OTI_Batch_Status_CoolS_AGN__c,'Scheduled');
        }
        Test.stopTest();
        
    }
}