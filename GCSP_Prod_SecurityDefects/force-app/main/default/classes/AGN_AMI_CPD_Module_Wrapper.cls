/**************************************************************************************************************************
@ Class:          AGN_AMI_CPD_Module_Wrapper
@ Version:        1.0
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        Controller class for maintaining changes to vault code changes in metadata.
@ PMO:            CPD Tracking Enhancement
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 13.11.2020 / Ayush Basak / Created the class.
***************************************************************************************************************************/
public class AGN_AMI_CPD_Module_Wrapper implements Comparable{
    
    private static string STATUS_COMPLETED = 'Completed';
    
    public string name {get; set;}
    public string id {get; set;}
    public string lrdId {get; set;}
    public integer sequence {get; set;}
    public string duration {get; set;}
    public boolean isCompleted {get; set;}
    public string contentType {get; set;}
    public integer completedSessions {get; set;}
    public integer pendingSessions {get; set;}
    public String progressString {get; set;}
    public boolean flagforSecModuleRec{get; set;}
    public boolean flagforSecCPDModuleRec{get; set;}
    
    public AGN_AMI_CPD_Module_Wrapper(AMI_CPD_Module_AGN__c cpdModule, AMI_Learning_Path_AGN__c learningPath, List<AMI_Sessions_AGN__c> sessions, Integer sequence) {
        this.name = cpdModule.Module_AGN_AMI__c;
        this.id = cpdModule.Learning_AGN_AMI__r.Module_AGN__c;
        this.sequence = sequence;
        this.lrdId = cpdModule.Learning_AGN_AMI__c;
         if(cpdModule.Learning_AGN_AMI__r.Module_AGN__r.Module_Duration_AGN__c<1){
            this.duration = String.valueOf(cpdModule.Learning_AGN_AMI__r.Module_AGN__r.Module_Duration_AGN__c*60).substringBefore('.');
            flagforSecCPDModuleRec =true;
        }else{
           this.duration = cpdModule.Learning_AGN_AMI__r.Module_AGN__r.Module_Duration_AGN__c.intValue().format();  
        }
        
        this.contentType = cpdModule.Learning_AGN_AMI__r.Module_AGN__r.Module_Content_Type_AGN__c;
		Map<String, String> statusMap = new Map<String, String>();
        this.progressString = '';
        if(learningPath != null) {
            this.completedSessions = 0;
            this.pendingSessions = 0;
            for(AMI_Path_Session_AGN__c pathSession : learningPath.AMI_Learning_Path_Sessions__r) {
                    statusMap.put(pathSession.Session_Code_AGN__c, pathSession.Session_Status_AGN__c);
                if(pathSession.Session_Status_AGN__c == STATUS_COMPLETED) {
                    this.completedSessions++;
                }
                else {
                    this.pendingSessions++;
                }
            }
            if(this.pendingSessions == 0 && this.completedSessions != 0) {
                this.isCompleted = true;
            }
            else {
                this.isCompleted = false;
            }
        }
        else{
            this.isCompleted = false;
            this.pendingSessions = sessions.size();
        }
        for(AMI_Sessions_AGN__c session : sessions) { 
            if(statusMap.keySet().contains(session.Session_Code_AGN__c)) {
                if(statusMap.get(session.Session_Code_AGN__c) == STATUS_COMPLETED) {
                    progressString = progressString + 'Completed;';
                }
                else {
                    progressString = progressString + 'Incomplete;';
                }
            }
            else {
                progressString = progressString + 'Incomplete;';
            }
        }
        progressString = progressString.substring(0, progressString.length()-1);
    }
    
    public AGN_AMI_CPD_Module_Wrapper(AMI_Lrn_Rel_Dtl_AGN__c cpdModule, AMI_Learning_Path_AGN__c learningPath, List<AMI_Sessions_AGN__c> sessions, Integer sequence) {
        this.name = cpdModule.Module_FMA_AGN__c;
        this.id = cpdModule.Module_AGN__c;
        this.sequence = sequence;
        this.lrdId = cpdModule.Id;
        if(cpdModule.Module_AGN__r.Module_Duration_AGN__c<1){
            this.duration = String.valueOf(cpdModule.Module_AGN__r.Module_Duration_AGN__c*60).substringBefore('.');
            flagforSecModuleRec =true;
        }else{
           this.duration = cpdModule.Module_AGN__r.Module_Duration_AGN__c.intValue().format(); 
        }
        
        this.contentType = cpdModule.Module_AGN__r.Module_Content_Type_AGN__c;
		Map<String, String> statusMap = new Map<String, String>();
        this.progressString = '';
        if(learningPath != null) {
            this.completedSessions = 0;
            this.pendingSessions = 0;
            for(AMI_Path_Session_AGN__c pathSession : learningPath.AMI_Learning_Path_Sessions__r) {
                    statusMap.put(pathSession.Session_Code_AGN__c, pathSession.Session_Status_AGN__c);
                if(pathSession.Session_Status_AGN__c == STATUS_COMPLETED) {
                    this.completedSessions++;
                }
                else {
                    this.pendingSessions++;
                }
            }
            if(this.pendingSessions == 0 && this.completedSessions != 0) {
                this.isCompleted = true;
            }
            else {
                this.isCompleted = false;
            }
        }
        else{
            this.isCompleted = false;
            this.pendingSessions = sessions.size();
        }
        for(AMI_Sessions_AGN__c session : sessions) { 
            if(statusMap.keySet().contains(session.Session_Code_AGN__c)) {
                if(statusMap.get(session.Session_Code_AGN__c) == STATUS_COMPLETED) {
                    progressString = progressString + 'Completed;';
                }
                else {
                    progressString = progressString + 'Incomplete;';
                }
            }
            else {
                progressString = progressString + 'Incomplete;';
            }
        }
        progressString = progressString.substring(0, progressString.length()-1);
    }
    
    public Integer compareTo(Object objToCompare) {
    	return Integer.valueOf(sequence - ((AGN_AMI_CPD_Module_Wrapper)objToCompare).sequence);
    }
}