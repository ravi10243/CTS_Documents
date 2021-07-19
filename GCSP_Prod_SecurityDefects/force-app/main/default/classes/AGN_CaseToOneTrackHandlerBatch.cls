global class AGN_CaseToOneTrackHandlerBatch implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    global String query;
      
    global AGN_CaseToOneTrackHandlerBatch(String q) {
        query = q;
    }   
   
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext bc, List<SObject> objList){
        List<Case> casesToProcess = new List<Case>();
        
        for(sObject s: objList){
            Case caseObj = (Case)s;
            system.debug('####OTI Case Id####'+caseObj.id);
            AGN_CallToOneTrack.submitCaseToOneTrack(caseObj.Id, true); 
           
        }
    }
    
    global void finish(Database.BatchableContext bc){  
    //exception need to handle and notify the system admin   
    }   
}