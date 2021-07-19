public class AGN_AMI_Certification_CurrListController {
    public List<checkboxWrapper> currDisplayList {get; set;}
    public Boolean editMode {get; set;}
    public List<AMI_Lrn_Rel_Dtl_AGN__c> learningList;
    public String certId;
    public Set<Id> existingLearnings;
    public AMI_Certification_AGN__c cert;
    
    public AGN_AMI_Certification_CurrListController(ApexPages.StandardController controller) {
        editMode = false;
        certId = (String)controller.getRecord().get('id');
        cert = [SELECT Id, Country_code_AGN_AMI__c, 
                                         (SELECT Id, Curriculam_AGN_AMI__c, Learning_AGN_AMI__c, Learning_AGN_AMI__r.Curriculum_AGN__c 
                                          FROM AMI_Certification_Paths__r ORDER BY Learning_AGN_AMI__r.Curriculum_Sequence_AGN__c NULLS LAST) 
                                         FROM AMI_Certification_AGN__c 
                                         WHERE Id = :certId];
        learningList = [SELECT Id, Curriculum_AGN__c, 
                        Curriculum_AGN__r.Curriculum_AGN__c
                        FROM AMI_Lrn_Rel_Dtl_AGN__c 
                        WHERE Country_Code_AGN__c =: cert.Country_code_AGN_AMI__c
                        AND Active_AGN__c=true 
                        ORDER BY Curriculum_AGN__r.Curriculum_Header_Sequence_AGN__c ASC NULLS LAST];
        
        Map<Id,CheckboxWrapper> curriculumMap = new Map<Id,CheckboxWrapper>();
        for(AMI_Lrn_Rel_Dtl_AGN__c learning : learningList) {
            if(curriculumMap.keySet().contains(learning.Curriculum_AGN__c)){
                CheckboxWrapper temp = curriculumMap.get(learning.Curriculum_AGN__c);
                temp.inLRD = temp.inLRD + 1;
                curriculumMap.put(learning.Curriculum_AGN__c,temp);
            }
            else {
                CheckboxWrapper temp = new CheckboxWrapper(learning.Curriculum_AGN__c, learning.Curriculum_AGN__r.Curriculum_AGN__c, 1, 0);
                curriculumMap.put(learning.Curriculum_AGN__c,temp);
            }
        }
        existingLearnings = new Set<Id>();
        for(AMI_CPD_Module_AGN__c cm : cert.AMI_Certification_Paths__r) {
            existingLearnings.add(cm.Learning_AGN_AMI__c);
            if(curriculumMap.keySet().contains(cm.Learning_AGN_AMI__r.Curriculum_AGN__c)){
                CheckboxWrapper temp = curriculumMap.get(cm.Learning_AGN_AMI__r.Curriculum_AGN__c);
                temp.inCPD = temp.inCPD + 1;
                if(temp.inLRD == temp.inCPD){
                   temp.checked = true; 
                }
                curriculumMap.put(cm.Learning_AGN_AMI__r.Curriculum_AGN__c,temp);
            }
        }
        currDisplayList = curriculumMap.values();
    }
    
    public void enabledEdit() {
        editMode = true;
    }
    
    public void save() {
        editMode = false;
        Set<Id> currIds = new Set<Id>();
        for(checkboxWrapper cW : currDisplayList) {
            if(cW.checked) {
                currIds.add(cw.currId);
            }
        }
        
        cert.Total_Curricula_AGN_AMI__c = currIds.size();
        
        List<AMI_CPD_Module_AGN__c> insertList = new List<AMI_CPD_Module_AGN__c>();
        for(AMI_Lrn_Rel_Dtl_AGN__c lrd : learningList) {
            if(currIds.contains(lrd.Curriculum_AGN__c) && !(existingLearnings.contains(lrd.Id))) {
                insertList.add(new AMI_CPD_Module_AGN__c(Certification_AGN_AMI__c = certId, Learning_AGN_AMI__c = lrd.Id));
            }
        }
        
        List<AMI_CPD_Module_AGN__c> deleteList = new List<AMI_CPD_Module_AGN__c>();
        for(AMI_CPD_Module_AGN__c cm : cert.AMI_Certification_Paths__r) {
            if(! currIds.contains(cm.Learning_AGN_AMI__r.Curriculum_AGN__c)){
                deleteList.add(cm);
            }
        }
        
        try{
            update cert;
            insert insertList;
            delete deleteList;
        }
        catch(Exception ex) {
            
        }
    }
    
    public class CheckboxWrapper {
        public String currId {get; set;}
        public String currLabel {get; set;}
        public Integer inLRD {get; set;}
        public Integer inCPD {get; set;}
        public Boolean checked {get; set;}
        public checkboxWrapper(String currId, String currLabel, Integer inLRD, Integer inCPD) {
            this.currId = currId;
            this.currLabel = currLabel;
            this.inLRD = inLRD;
            this.inCPD = inCPD;
        }
        
    }
}