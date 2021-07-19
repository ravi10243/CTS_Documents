/* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant   
* @modifiedBy      
* @createdBy      
* @version        1.0
* @created        Nov14'2019
* @modified       
* @testClass             
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            
* YYYY-MM-DD      
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class AGN_GDPR_ContentVersionHandler {
    
    // These variables store Trigger.oldMap and Trigger.newMap
    public Map<Id, ContentVersion> oldVersionMap;
    public  Map<Id, ContentVersion> newVersionMap;
    public  List<ContentVersion> conVerList;
    public AGN_GDPR_ContentVersionHandler(Map<Id, ContentVersion> oldContentVersionMap, Map<Id, ContentVersion> newContentVersionMap, List<ContentVersion> conVerList) {
        oldVersionMap = oldContentVersionMap;
        newVersionMap = newContentVersionMap;
        this.conVerList = conVerList;
    }
    
/************************************************************************************************************************************
@ author:          Cognizant  
@ method:          onBeforeInsert 
@ returns:         Id
@ params:          void
@return :          void
@ @description:    [All Markets]Method to perform Operations on BeforeInsert
@ @changeHistory:  Preeti Achary- Created the method/Nov14,2019
************************************************************************************************************************************/
    public void onBeforeInsert(){
    }
/************************************************************************************************************************************
@ author:          Cognizant  
@ method:          onAfterInsert 
@ returns:         Id
@ params:          void
@return :          void
@ @description:    [All Markets]Method to perform Operations on AfterInsert
@ @changeHistory:  Preeti Achary-  Created the method/Nov14,2019.
                :  Preeti Achary - Otpimized*- Moved the existing code of AfterInsert from the trigger to the Handler
                :  Preeti Achary - Otpimized* - Taken the ContentDocLinkList SOQL outside the for loop.
                :  Preeti Achary - Added Custom logic to block certain users to upload files on Asset Register ( Filling System). 
************************************************************************************************************************************/
    public void onAfterInsert(){
        ID linkedObjectId;
        Set<Id> contentDocIdSet = new Set<Id>();
        Map<Id,Id> conDocLinkIdToEntityIdMap = new Map<Id,Id>();
        Set<Id> businessOwnerGdprIdSet = new Set<Id>();
        Set<Id> astRegIdSet = new Set<Id>();
        
        String profileName = AGN_GDPR_Utility.getCurrentUserProfileName(); 
        Set<Id> docIds = new Set<Id>();
        Set<String> profileNameToAllowSet = new Set<String>{AGN_GDPR_ConstantUtility.AGN_GDPR_Case_DPO ,
            AGN_GDPR_ConstantUtility.SYSTEM_ADMIN_PROFILE};
        
        //Find the documentId and add to conVerIdSet
        for(ContentVersion conVer: conVerList){
            contentDocIdSet.add(conVer.ContentDocumentId);
        }
        //There's a Salesforce Implementation restriction: "filtering on non-id fields is only permitted when filtering by ContentDocumentLink.LinkedEntityId using the equals operator" on the ContentDocumentLink.
        //Therefore, there's a need to add loop in a loop.
        for(ContentDocument conDoc : [SELECT Id, LatestPublishedVersionId, (select Id,ContentDocumentId,LinkedEntityId from ContentDocumentLinks)FROM ContentDocument where Id in :contentDocIdSet]){
            for(ContentDocumentLink cdl : conDoc.ContentDocumentLinks){
                conDocLinkIdToEntityIdMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
            }
        }
        
        //Fetch Business Owner where CaseType is Not GDPR.
        //Optimized by Preeti Achary - Taken BusinessOwnerTask Loop outside the Content Version loop and bulkified.
        for(Business_Owner_Task_GDPR_AGN__c busiOwnTask: [SELECT Id,Case_Type_GDPR_AGN__c from Business_Owner_Task_GDPR_AGN__c where Id in :conDocLinkIdToEntityIdMap.values() and Case_Type_GDPR_AGN__c = 'CCPA']){
            businessOwnerGdprIdSet.add(busiOwnTask.Id);
        }
        //Fetch asset Register(Filling System) to fetch content 
        for(Asset_Register_AGN__c astReg:[SELECT Id, name FROM Asset_Register_AGN__c WHERE Id in:conDocLinkIdToEntityIdMap.values()]){
            astRegIdSet.add(astReg.Id);
        }
        //For Non-GDPR caseType BusinessOwnerTask - only pdf document is allowed to be uploaded.
        //Optimized by Preeti Achary - Taken BusinessOwnerTask Loop outside this Content Version loop and bulkified.
        for(ContentVersion conVer: conVerList){
            if(!conDocLinkIdToEntityIdMap.isEmpty() && conDocLinkIdToEntityIdMap.containsKey(conVer.ContentDocumentId) && conVer.PathOnClient != null){
                linkedObjectId = conDocLinkIdToEntityIdMap.get(conVer.ContentDocumentId);
                //For Non-GDPR caseType BusinessOwnerTask - only pdf document is allowed to be uploaded.
                if(!businessOwnerGdprIdSet.isEmpty() && businessOwnerGdprIdSet.contains(linkedObjectId)){
                    if(!conVer.PathOnClient.endsWith('.pdf')){
                    system.debug('conVer.PathOnClient******'+conVer.PathOnClient);
                        conVer.PathOnClient.addError('Not a PDF file.Please select a PDF file');
                    }
                }
                //This is a Salesforce - Limitation(As of Nov 23rd,2019) - Displaying custom error message on file upload is not available.
                //Standard error message is shown 'Can't Upload "FileName" ' .
                if(!astRegIdSet.isEmpty() && astRegIdSet.contains(linkedObjectId) && String.isNotBlank(profileName) && !profileNameToAllowSet.contains(profileName) && conVer.ContentDocumentId != null){
                    conVer.PathOnClient.addError('You do not have enough rights to upload new file');
                }
            }
        }
    }
}