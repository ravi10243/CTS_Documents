/*
* This sets the 
Id and HCP on Opportunity from opportunityContactRoles.
*/
public with sharing class AGN_OppContactRolesHelper {
    public Map<String, String> oppRecordTypeIdMap;  
    
    public AGN_OppContactRolesHelper(){
        oppRecordTypeIdMap = new Map<String, String>();
        Map<Id, RecordType> oppRecordTypes = new Map<Id, RecordType>();
        
        oppRecordTypes = AGN_RecordTypes.getOppRecordTypes('Opportunity');
          if(oppRecordTypes != null && oppRecordTypes.size() > 0){
              for(RecordType rt : oppRecordTypes.values()){
                  oppRecordTypeIdMap.put(rt.Developername, rt.Id);
              }
          }
    }
    
    public void setContactAndHCPLookup(list<Opportunity> opps) {
        list<Id> oppIds = new list<Id>{};
        for (Opportunity opp : opps) {
            if (opp.RecordTypeId == oppRecordTypeIdMap.get('AM_without_MSA_AGN') || opp.RecordTypeId == oppRecordTypeIdMap.get('AM_with_MSA_AGN')|| opp.RecordTypeId == oppRecordTypeIdMap.get('PSS_AGN')||opp.RecordTypeId == oppRecordTypeIdMap.get('AM_With_Approval_AGN'))
                oppIds.add(opp.Id);
        }
        
        Map<Id,Id> HCPMap = new Map<Id,Id>{};
        Map<Id,Id> signerMap = new Map<Id,Id>{};
        Map<Id,Id> primaryMap = new Map<Id,Id>{};
        
        for (OpportunityContactRole ocr : [SELECT OpportunityId,ContactId,Role,IsPrimary FROM OpportunityContactRole WHERE OpportunityId IN :oppIds]) {
            if (ocr.Role == 'Signer') signerMap.put(ocr.OpportunityId,ocr.ContactId);
            if (ocr.IsPrimary) primaryMap.put(ocr.OpportunityId,ocr.ContactId);
            if (ocr.Role == 'Medical Director') HCPMap.put(ocr.OpportunityId,ocr.ContactId);
        }
      
      for (Opportunity opp : opps) {
            if (primaryMap.containsKey(opp.Id)) opp.Contact_AGN__c = primaryMap.get(opp.Id);
            if (signerMap.containsKey(opp.Id)) opp.Contact_AGN__c = signerMap.get(opp.Id);
           //     if (HCPMap.containsKey(opp.Id)) opp.HCP__c = HCPMap.get(opp.Id);  do we want this?
        }
    }
}