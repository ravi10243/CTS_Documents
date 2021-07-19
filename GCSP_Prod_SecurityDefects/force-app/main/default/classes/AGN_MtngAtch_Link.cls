public class AGN_MtngAtch_Link {
    public void updateAttachmentLink(){
        System.debug('## Inside updateAttachmentLink() method of AGN_MtngAtch_Link Class');
        List<Meeting_Attachment_Link_AGN__c> mtng_atchmnt_list = new List<Meeting_Attachment_Link_AGN__c>();
        List<Meeting_Attachment_Link_AGN__c> result_mtng_atchmnt_list = new List<Meeting_Attachment_Link_AGN__c>();
        List<Attachment> attachmentList = new List<Attachment>();
        AGN_Meeting_Setting__c mtngSetting = AGN_Meeting_Setting__c.getInstance();
        Set<Id> idSet = new Set<Id>();
        System.debug('## Initial mtng_atchmnt_list.size() -> '+mtng_atchmnt_list.size());
        System.debug('## Initial result_mtng_atchmnt_list.size() -> '+result_mtng_atchmnt_list.size());
        System.debug('## Initial attachmentList.size() -> '+attachmentList.size());
        System.debug('## Initial idSet.size() -> '+idSet.size());
        
        Date lastday = date.today() - (Integer) mtngSetting.Days_for_Attachment_Link_AGN__c;
        System.debug('## lastday -> '+lastday);
        Date today = date.today()+1;
        System.debug('## Today -> '+today);
        String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('## BaseURL -> '+baseURL);
        attachmentList = [SELECT Id,Name,ParentId FROM Attachment where ParentId in 
                          (SELECT Id FROM Medical_Event_vod__c 
                           where Country_AGN__r.Name =: mtngSetting.Country_for_Reports_AGN__c)
                          AND LastModifiedDate >=: lastday AND LastModifiedDate <: today 
                          AND Name LIKE : '%'+ mtngSetting.Event_Report_Attachment_Criteria_AGN__c +'%'
                          order by LastModifiedDate];
        System.debug('## attachmentList -> '+attachmentList);
        System.debug('## attachmentList.size() -> '+attachmentList.size());
        for(Attachment atchmnt : attachmentList){
            idSet.add(atchmnt.ParentId);
        }
        System.debug('## ID Set element -> '+ idSet);
        System.debug('## idSet.size() -> '+ idSet.size());
        mtng_atchmnt_list = [select Id,Meeting_AGN__c,Attachment_Link_AGN__c from Meeting_Attachment_Link_AGN__c 
                             where Meeting_AGN__c in: idSet]; 
        System.debug('## mtng_atchmnt_list -> '+ mtng_atchmnt_list); 
        System.debug('## mtng_atchmnt_list.size() -> '+ mtng_atchmnt_list.size());
        for(Meeting_Attachment_Link_AGN__c mtng_atchmnt : mtng_atchmnt_list){
            Meeting_Attachment_Link_AGN__c meetingAttachment = new Meeting_Attachment_Link_AGN__c();
            for(Attachment atchmnt : attachmentList){
                
               // AG CC
                if(mtng_atchmnt.Meeting_AGN__c == atchmnt.ParentId){
                    
                        meetingAttachment.Id = mtng_atchmnt.Id;
                    
                    if(Schema.sObjectType.Meeting_Attachment_Link_AGN__c.fields.Meeting_AGN__c.isUpdateable())
                    {
                        meetingAttachment.Meeting_AGN__c = mtng_atchmnt.Meeting_AGN__c;
                    }
                    if(Schema.sObjectType.Meeting_Attachment_Link_AGN__c.fields.Attachment_Link_AGN__c.isUpdateable())
                    {
                        meetingAttachment.Attachment_Link_AGN__c = baseURL +'/'+atchmnt.id;
                    }
                }
            }
            System.debug('## meetingAttachment -> '+meetingAttachment);
            result_mtng_atchmnt_list.add(meetingAttachment);
        }
        System.debug('## result_mtng_atchmnt_list -> '+result_mtng_atchmnt_list);
        System.debug('## result_mtng_atchmnt_list.size() -> '+result_mtng_atchmnt_list.size());
        if(result_mtng_atchmnt_list.size() > 0){
            //AG CC
            if(Schema.sObjectType.Meeting_Attachment_Link_AGN__c.isUpdateable())
            {
              update result_mtng_atchmnt_list;
            }
            System.debug('## Updated successfully');
            result_mtng_atchmnt_list.clear();
            System.debug('## After clear result_mtng_atchmnt_list.size() -> '+result_mtng_atchmnt_list.size());
            
            String email_Id = [SELECT Country,Country_Code__c,Email,Id,Name,Profile_Name_vod__c,Username FROM User 
                               WHERE IsActive = true AND Username LIKE 'bau.service%' LIMIT 1].Email;
            System.debug('## email_Id -> '+email_Id);
            List<String> emailList = new List<String>();
            emailList.add(email_Id);
            //emailList.add('akash.parihar@cognizant.com');
            System.debug('## emailList -> '+emailList);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(emailList);
            email.setSubject(Label.AGN_mtngAtchmnt_subject);
            email.setPlainTextBody(Label.AGN_mtngAtchmnt_body);
            system.debug('## emailMessages check '+email);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
            system.debug('## Messaging.sendEmail(emailMessages) ran successfully ');
        }
        
    }
}