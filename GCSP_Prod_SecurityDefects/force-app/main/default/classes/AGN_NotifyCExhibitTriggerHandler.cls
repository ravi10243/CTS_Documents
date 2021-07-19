public class AGN_NotifyCExhibitTriggerHandler {
  public static Boolean hasExecuted = false;
  private Boolean m_isExecuting = false;
  private Integer batchSize = 0;

  public AGN_NotifyCExhibitTriggerHandler(Boolean isExecuting, Integer size){
    m_isExecuting = isExecuting;
    batchSize = size;
  }

  public void OnAfterInsert(AGN_GDPR_Notify_Contract_Exhibit__c[] newRecords){
    // GIGYA integration - send data to Gigya
    if (AGNGigyaRESTHelper.environmentEnabled()) {
      Set<Id> ids = new Set<Id>();
      for (AGN_GDPR_Notify_Contract_Exhibit__c record : newRecords) {
        ids.add(record.Id);
      }
      Database.executeBatch(new AGN_CExhibitGigyaNotificationBatch(ids), 15);
    }

  }
  public void OnAfterUpdate(AGN_GDPR_Notify_Contract_Exhibit__c[] oldRecords,
  AGN_GDPR_Notify_Contract_Exhibit__c[] updatedRecords,
  Map<ID, AGN_GDPR_Notify_Contract_Exhibit__c> recordMap) {

    // GIGYA integration - send data to Gigya
    if (AGNGigyaRESTHelper.environmentEnabled()) {
      Database.executeBatch(new AGN_CExhibitGigyaNotificationBatch(recordMap.keySet()), 15);
    }
  }
}