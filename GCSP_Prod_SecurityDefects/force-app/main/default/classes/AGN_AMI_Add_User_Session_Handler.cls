public class AGN_AMI_Add_User_Session_Handler {
    
    
    public static void onAfterUpdate(List<AMI_Sessions_AGN__c> newAMISessionList , Map<id,AMI_Sessions_AGN__c> newAMISessionMap,
                                        List<AMI_Sessions_AGN__c> oldAMISessionList , Map<id,AMI_Sessions_AGN__c> oldAMISessionMap){
      AGN_AMI_Add_User_Session_Helper.activateAMISession(newAMISessionList ,oldAMISessionMap);  
                                            
    }
    
    
    
    public static void manageSessionUpdate(map<id,AMI_Sessions_AGN__c>triggerNewMap,List<AMI_Sessions_AGN__c>triggerOld){
        
        List <AMI_Sessions_AGN__c> listSessionOld = New List <AMI_Sessions_AGN__c>();
        Map<id,AMI_Sessions_AGN__c> sessionNewMap = new Map<id,AMI_Sessions_AGN__c>();
        Set <Id> setModuleId = New Set <Id>();
        List<AMI_Path_Session_AGN__c> sessionPathToUpdate = new List<AMI_Path_Session_AGN__c>();
        
        for (AMI_Sessions_AGN__c session : triggerOld) {
            listSessionOld.add(session);
            setModuleId.add(session.Parent_Module_AGN__c);
            sessionNewMap.put(session.id,triggerNewMap.get(session.ID));
            
        }
        
        List<AMI_Learning_Path_agn__c> listLearningPath  = [select Id,Module__r.Module_AGN__c from AMI_Learning_Path_agn__c where Module__r.Module_AGN__c in :setModuleId]; 
        Set<Id>listLearningPathId = new Set<Id>();
        for(AMI_Learning_Path_agn__c learningPath:listLearningPath){
            listLearningPathId.add(learningPath.Id);
        }
        List<AMI_Path_Session_AGN__c> listSessionPath =   [SELECT AMI_Learning_Path_AGN__c,Id,Name_AGN__c,Session_Code_AGN__c FROM AMI_Path_Session_AGN__c WHERE AMI_Learning_Path_AGN__c in :listLearningPathId];
        
        for (AMI_Sessions_AGN__c session:listSessionOld){
            for(AMI_Path_Session_AGN__c sessionPath :listSessionPath){
                //if session name/session code in trigger old is not same as the session path name 
                if(session.Name_AGN__c == sessionPath.Name_AGN__c || session.Session_Code_AGN__c ==sessionPath.Session_Code_AGN__c) {
                    sessionPath.Name_AGN__c =sessionNewMap.get(session.id).Name_AGN__c;
                    sessionPath.Session_Code_AGN__c = sessionNewMap.get(session.id).Session_Code_AGN__c;
                    sessionPath.Duration_AGN__c =sessionNewMap.get(session.id).Duration_AGN__c;
                    sessionPath.ZINC_number_agn__c =sessionNewMap.get(session.id).ZINC_number_agn__c;
                    sessionPath.Training_URL_AGN__c = sessionNewMap.get(session.id).Training_URL_AGN__c;
                    sessionPath.Active_AGN__c = sessionNewMap.get(session.id).IsActive_AGN__c;
                    sessionPath.AMI_Session_Number_AGN__c = sessionNewMap.get(session.id).Name;
                    sessionPathToUpdate.add(sessionPath);
                }
            } 
        }
        update sessionPathToUpdate;
    }
   
//deleting AMI Session
    public static void manageSessionDelete(List<AMI_Sessions_AGN__c> triggerOld){
        
        Set <String> setModuleId = New Set <String>();
        Set <String> setName = New Set <String>();
        Set <String> setModuleName = New Set <String>();
        
        for (AMI_Sessions_AGN__c session : triggerOld) {
            setModuleName.add(session.Parent_Module_AGN__c+'_'+session.Name_AGN__c);
            setModuleId.add(String.valueOf(session.Parent_Module_AGN__c).substring(0, 15));
            //setModuleId.add(session.Parent_Module_AGN__c);
            setName.add(session.Name_AGN__c);
        }
        
         system.debug('setModuleName>>>>>'+setModuleName);
          system.debug('setModuleId>>>>>'+setModuleId);
           system.debug('setName>>>>>'+setName);
        
        Map<String,List<AMI_Path_Session_AGN__c>> setModuleNameAMIPathSessionMap = new Map<String,List<AMI_Path_Session_AGN__c>>();
        for(AMI_Path_Session_AGN__c AMIPathSession :  [select id,Name_AGN__c,Parent_Module_AGN__c from AMI_Path_Session_AGN__c 
            where Name_AGN__c in : setName AND Parent_Module_AGN__c in : setModuleId]){
            
            if(!setModuleNameAMIPathSessionMap.containsKey(AMIPathSession.Parent_Module_AGN__c+'_'+AMIPathSession.Name_AGN__c)){
                setModuleNameAMIPathSessionMap.put(AMIPathSession.Parent_Module_AGN__c+'_'+AMIPathSession.Name_AGN__c , new List<AMI_Path_Session_AGN__c>{AMIPathSession});
            }
            else{
                List<AMI_Path_Session_AGN__c> AMIPaLst = setModuleNameAMIPathSessionMap.get(AMIPathSession.Parent_Module_AGN__c+'_'+AMIPathSession.Name_AGN__c);
                AMIPaLst.add(AMIPathSession);
                setModuleNameAMIPathSessionMap.put(AMIPathSession.Parent_Module_AGN__c+'_'+AMIPathSession.Name_AGN__c , new List<AMI_Path_Session_AGN__c>{AMIPathSession});
            }
        }
         system.debug('setModuleNameAMIPathSessionMap>>>>>'+setModuleNameAMIPathSessionMap);
          
        
        List<AMI_Path_Session_AGN__c> deleteAMIPathSessionList = new List<AMI_Path_Session_AGN__c>();
        for (AMI_Sessions_AGN__c session : triggerOld) {
            system.debug('session'+session);
            if(setModuleNameAMIPathSessionMap.containsKey(String.valueOf(session.Parent_Module_AGN__c).substring(0, 15)+'_'+session.Name_AGN__c)){
               
                deleteAMIPathSessionList.addAll(setModuleNameAMIPathSessionMap.get(String.valueOf(session.Parent_Module_AGN__c).substring(0, 15)+'_'+session.Name_AGN__c));
                   
            }
        }
        if(!deleteAMIPathSessionList.isEmpty()){
            delete deleteAMIPathSessionList;
        }
    }
}