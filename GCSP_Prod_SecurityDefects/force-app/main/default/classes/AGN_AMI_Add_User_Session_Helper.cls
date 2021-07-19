public class AGN_AMI_Add_User_Session_Helper{
    
    public static void activateAMISession(List<AMI_Sessions_AGN__c> newAMISessionList , Map<id,AMI_Sessions_AGN__c> oldAMISessionMap) {
        set<id> AMILearningIds = new set<id>();
        for(AMI_Sessions_AGN__c AMISession : newAMISessionList){
            if(oldAMISessionMap.get(AMISession.id).IsActive_AGN__c != AMISession.IsActive_AGN__c && AMISession.IsActive_AGN__c){
                AMILearningIds.add(AMISession.Parent_Module_AGN__c);
            }
        }
    
        Map<id,id> AMILearningIdAMILearningPathIdMap = new Map<id,id>();
        for(AMI_Learning_Path_AGN__c AMILearningPath : [select id,Module__c,Module__r.Module_AGN__c from AMI_Learning_Path_AGN__c 
                                                                where Module__r.Module_AGN__c in : AMILearningIds]){
                                                                
            AMILearningIdAMILearningPathIdMap.put(AMILearningPath.Module__r.Module_AGN__c,AMILearningPath.id);                                                      
        }
        
        set<id> identifiedAMILearningPathIds = new set<Id>();
        for(AMI_Sessions_AGN__c AMISession : newAMISessionList){
            if(oldAMISessionMap.get(AMISession.id).IsActive_AGN__c != AMISession.IsActive_AGN__c && AMISession.IsActive_AGN__c){
                if(AMILearningIdAMILearningPathIdMap.containsKey(AMISession.Parent_Module_AGN__c)){
                    identifiedAMILearningPathIds.add(AMILearningIdAMILearningPathIdMap.get(AMISession.Parent_Module_AGN__c));
                }
            }                                               
        }
    
        Map<String,id> AMPPathSessionMap = new Map<String,id>(); 
        for(AMI_Path_Session_AGN__c AMIPathSession : [select id,Parent_Module_AGN__c,AMI_Learning_Path_AGN__c,Name_AGN__c from AMI_Path_Session_AGN__c where AMI_Learning_Path_AGN__c in : identifiedAMILearningPathIds]){
            AMPPathSessionMap.put(AMIPathSession.Parent_Module_AGN__c+'_'+AMIPathSession.AMI_Learning_Path_AGN__c+'_'+AMIPathSession.Name_AGN__c,AMIPathSession.Id);
        }
    
        
        List<AMI_Path_Session_AGN__c> createLearningPathList = new List<AMI_Path_Session_AGN__c>();
                for(AMI_Sessions_AGN__c AMISession : newAMISessionList){
        system.debug('AMPPathSessionMap'+AMPPathSessionMap);
            if(oldAMISessionMap.get(AMISession.id).IsActive_AGN__c != AMISession.IsActive_AGN__c && AMISession.IsActive_AGN__c){
                if(AMILearningIdAMILearningPathIdMap.containsKey(AMISession.Parent_Module_AGN__c)){
                system.debug('AMPPathSessionMap2'+AMISession.Parent_Module_AGN__c+'_'+AMILearningIdAMILearningPathIdMap.get(AMISession.Parent_Module_AGN__c)+'_'+AMISession.Name_AGN__c); 
                    if(!AMPPathSessionMap.containsKey(String.valueOf(AMISession.Parent_Module_AGN__c).substring(0, 15)+'_'+AMILearningIdAMILearningPathIdMap.get(AMISession.Parent_Module_AGN__c)+'_'+AMISession.Name_AGN__c )){
                        AMI_Path_Session_AGN__c lps = new AMI_Path_Session_AGN__c();
                        
                        lps.Active_AGN__c = AMISession.IsActive_AGN__c;
                        lps.AMI_Learning_Path_AGN__c = AMILearningIdAMILearningPathIdMap.get(AMISession.Parent_Module_AGN__c);
                        lps.Duration_AGN__c = AMISession.Duration_agn__c;
                        lps.File_name_AGN__c = AMISession.File_name_AGN__c;
                        lps.Name_AGN__c = AMISession.Name_AGN__C;
                        lps.Session_Code_AGN__c = AMISession.Session_Code_AGN__c;
                        lps.AMI_Session_Number_AGN__c = AMISession.Name;      // Pending design review
                        lps.Training_URL_AGN__c = AMISession.Training_URL_AGN__c;
                        lps.ZINC_number_AGN__c = AMISession.ZINC_number_agn__c;
                        
                        createLearningPathList.add(lps);
                    }
                }
            }
        }
        if(!createLearningPathList.isEmpty()){
            insert createLearningPathList;
        }
    }                                                       
    
}