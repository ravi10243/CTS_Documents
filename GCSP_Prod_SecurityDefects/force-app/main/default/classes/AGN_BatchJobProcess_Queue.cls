/**
* The Job will getting triggered from PostRefresh activity class 
* responsible for masking all production email inorder to protect PII data.
*
* @author  Amit Das
* @version 1.0
* @since   2020-07-27 
*/
global class AGN_BatchJobProcess_Queue implements Database.Batchable<sObject>{
    
    Boolean isNextBatchExecute = true;
    public AGN_BatchJobProcess_Queue(Boolean value){
       this.isNextBatchExecute = value;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        String whereClause = 'Queue'; 
        //String query = 'select Id, Email from Group where Type = \'' + String.escapeSingleQuotes(whereClause) + '\' AND Email <> null';
        String query = 'select Id, Email from Group where Type = \'' + String.escapeSingleQuotes(whereClause) + '\' AND (Email <> null and (not Email like \''+'%invalid'+'\'))';
        System.debug('Raw Query ' +query);
        return Database.getQueryLocator(query);
    }
    global integer totalSizeRecords=0;
    global void execute(Database.BatchableContext BC, List<Group> queueList) {
        System.debug('Queue list size '+queueList);  
         totalSizeRecords += queueList.size();
        // process each batch of records default size is 200
        List<Group> updatedQueueList = new List<Group>();
        for(Group queue : queueList){
            System.debug('Email value '+queue.Email +' eligible for update ' +isEligible(queue)); 
             //code to mask email ids in the queue
             if(AGN_PostCopyValidateUtil.isEligible(queue.Email)){
                String value = queue.Email +'.invalid';  
                //AG CC
                if(Schema.sObjectType.Group.fields.Email.isUpdateable()){  
                    queue.Email = value; 
                } 
                updatedQueueList.add(queue);  
                //System.debug('Email value '+value);  
             }
             //code to unmask email ids in the queue
             /*if(queue.Email != null && queue.Email != '' && queue.Email.endsWith('.invalid')){
                String value = queue.Email.substring(0,queue.Email.indexOf('.invalid'));
                queue.Email = value;
                updatedQueueList.add(queue);  
                System.debug('Email value '+value); 
            } */   
            
        }
        try {
            //update records in the queue;
            //AG CC
            if(Group.sObjectType.getDescribe().isUpdateable()){
            database.SaveResult[] myResult = database.update(updatedQueueList,false);
            
                for(database.SaveResult result : myResult){
                if(result.isSuccess()){
                    System.debug('Records are updated Successfully');
                    this.successIds().add(result.Id);
                    }
                else{
                      Database.Error errors =  result.getErrors().get(0);
                      System.debug('Error Occurs While Processing The Record'+errors.getMessage());
                      this.failedIds().add(result.Id);
                    }
            }
            
            }  
        } catch(Exception e) {
            System.debug(e);
        }
        
    } 
    private List<String> successIds , failedIds;
    private List<String> successIds(){
        if(successIds == null)
            successIds = new List<String>();
        return this.successIds;
    }
    
    private List<String> failedIds(){
        if(failedIds == null)
            failedIds = new List<String>();
        return this.failedIds;
    }
    
   private boolean isEligible(Group queue){
        //AG CC
        if (Schema.sObjectType.Group.fields.Email.isAccessible()){
            return (queue.Email != null && queue.Email != '' && ! queue.Email.endsWith('.invalid'));
            }
        return false;
    }
    
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
        // start next batch process
        AGN_Post_Copy_Util.insertJobRecord(BC.getJobId()); 
        if(this.isNextBatchExecute){
           AGN_BatchJobProcess_WorkflowEmailAlert wFlowAlertJob = new AGN_BatchJobProcess_WorkflowEmailAlert(true);
           Database.executeBatch(wFlowAlertJob,20);
       }
        else{
            AGN_Post_Copy_Util.sendJobStatusReportEmail();
        }
        
     }
}