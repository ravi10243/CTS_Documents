public class CPDCurriculumStatusHelper{
    
    public static void updateCurriculumDetails(List<CPD_Curricula_AGN_AMI__c> newCurriculmStatusList){
        set<id> CPDGrantedIds = new set<id>();
        for(CPD_Curricula_AGN_AMI__c cs : newCurriculmStatusList ){
            CPDGrantedIds.add(cs.AMI_CPD_Granted_AGN_AMI__c);
        }
        
        List<AMI_CPD_Granted_AGN__c> CPDGrantedList = [select id,AGN_AMI_Congratulation_Timestamp__c,Curriculum_Status_Completion_Percentage__c,Last_Curriculum_Completion_Date__c,
        (select id,AGN_AMI_Curricula_Name__c,AGN_AMI_Curriculum_Completion_Percent__c,AGN_AMI_Curriculum_Completion_Date__c from CPD_Curricula_AGN_AMI__r) 
        from AMI_CPD_Granted_AGN__c where id in : CPDGrantedIds];
        
        for(AMI_CPD_Granted_AGN__c cg : CPDGrantedList){
            cg.Curriculum_Status_Completion_Percentage__c = null;
            cg.Last_Curriculum_Completion_Date__c = null;
            
            for(CPD_Curricula_AGN_AMI__c cs : cg.CPD_Curricula_AGN_AMI__r){
                cg.Curriculum_Status_Completion_Percentage__c = String.isBlank(cg.Curriculum_Status_Completion_Percentage__c) ? 
                    cs.AGN_AMI_Curricula_Name__c + '(' + cs.AGN_AMI_Curriculum_Completion_Percent__c  + '%)' : 
                    cg.Curriculum_Status_Completion_Percentage__c + ',' + cs.AGN_AMI_Curricula_Name__c + '(' + cs.AGN_AMI_Curriculum_Completion_Percent__c  + '%)';
                
                
                    cg.AGN_AMI_Congratulation_Timestamp__c = cg.AGN_AMI_Congratulation_Timestamp__c == null ? 
                    cs.AGN_AMI_Curriculum_Completion_Date__c == null ? null : cs.AGN_AMI_Curriculum_Completion_Date__c :
                    (cs.AGN_AMI_Curriculum_Completion_Date__c == null || cs.AGN_AMI_Curriculum_Completion_Date__c < cg.AGN_AMI_Congratulation_Timestamp__c ? cg.AGN_AMI_Congratulation_Timestamp__c : cs.AGN_AMI_Curriculum_Completion_Date__c);
                
                    cg.Last_Curriculum_Completion_Date__c = cg.Last_Curriculum_Completion_Date__c == null ? 
                    Date.valueOf(cs.AGN_AMI_Curriculum_Completion_Date__c == null ? null : cs.AGN_AMI_Curriculum_Completion_Date__c) :
                    (cs.AGN_AMI_Curriculum_Completion_Date__c == null || Date.valueOf(cs.AGN_AMI_Curriculum_Completion_Date__c) < cg.Last_Curriculum_Completion_Date__c ? cg.Last_Curriculum_Completion_Date__c : Date.valueOf(cs.AGN_AMI_Curriculum_Completion_Date__c));
            }
        }
        if(CPDGrantedList != null && !CPDGrantedList.isEmpty()){
            update CPDGrantedList;
        }
    }

}