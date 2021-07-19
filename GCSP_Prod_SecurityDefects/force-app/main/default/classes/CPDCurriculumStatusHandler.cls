public class CPDCurriculumStatusHandler{
    
    public static void onAfterInsert(List<CPD_Curricula_AGN_AMI__c> newCurriculmStatusList, Map<id,CPD_Curricula_AGN_AMI__c> newCurriculmStatusMap){
        CPDCurriculumStatusHelper.updateCurriculumDetails(newCurriculmStatusList);
    }
    
    
    public static void onAfterUpdate(List<CPD_Curricula_AGN_AMI__c> newCurriculmStatusList, Map<id,CPD_Curricula_AGN_AMI__c> newCurriculmStatusMap,
        List<CPD_Curricula_AGN_AMI__c> oldCurriculmStatusList, Map<id,CPD_Curricula_AGN_AMI__c> oldCurriculmStatusMap){
            
        CPDCurriculumStatusHelper.updateCurriculumDetails(newCurriculmStatusList);    
    }
    
}