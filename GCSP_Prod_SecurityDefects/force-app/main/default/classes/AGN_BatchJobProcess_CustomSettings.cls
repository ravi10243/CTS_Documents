/**
* The Job will getting triggered once Custom Label job finished its activity 
* which overrides the config data with org specific data. In this case data 
* maintained under different custom settings will be restored specific for sandbox org.
*
* @author  Santanu Roy
* @version 1.0
* @since   2020-08-07 
*/

global class AGN_BatchJobProcess_CustomSettings implements Database.Batchable<sObject>{
    
    private String soqlQuery;
    private void setQuery(String value){
        this.soqlQuery = value;
    }
    private String query(){
        return this.soqlQuery;
    }
    private boolean isLastQuery;
    private void setLastQuery(boolean value){
        this.isLastQuery = value;
    }
    private boolean isLastQuery(){
        return this.isLastQuery;
    }
    
    public AGN_BatchJobProcess_CustomSettings(String query , boolean isLast) {
        this.setQuery(query);
        this.setLastQuery(isLast);
    }
    Boolean isNextBatchExecute = true;
    public AGN_BatchJobProcess_CustomSettings(Boolean value){
       this.isNextBatchExecute = value;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query());
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> listRecords) {
        
            //System.debug('Objects '+listRecords);
            System.debug('Query '+query());
            String sql = query();
            if(sql == null || sql == '')
                return;
            List<String> columns = sql.substring(sql.indexOf('Select')+7, sql.indexOf('FROM')-1).split(',');
            String table = sql.substring(sql.indexOf('from')+5).split(' ')[0];
            System.debug('Column names '+ columns);
            System.debug('Table name '+table);
      
        
        
        
       if (columns.size() > 0 ) {
           
            for (sObject obj : listRecords ) {
                for (String columnName : columns ) {
                    String strField = columnName.trim();
                    //code to mask email ids in the queue
                    if (obj.get(strField) != null && AGN_PostCopyValidateUtil.validateEmail(String.valueOf(obj.get(strField))) && ! String.valueOf(obj.get(strField)).contains('.invalid')){ 
                        obj.put(strField, obj.get(strField) +'.invalid'); 
                        System.debug('Modified field ' + obj.get(strField));
                    }
                    //code to unmask email ids in the queue
                    /*if (obj.get(strField) != null &&  String.valueOf(obj.get(strField)).endsWith('.invalid')) {
                          String email =  String.valueOf(obj.get(strField));   
                          String value = email.substring(0,email.indexOf('.invalid'));
                          obj.put(strField, value);                            
                     }*/
                }
                try{
                     update listRecords;
                     System.debug('Successfully added ' + listRecords);
                }
                Catch(DmlException exp){
                    System.debug('DML operation has failed');
                } 
               
            }
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        //if isLast then start next batch
        AGN_Post_Copy_Util.insertJobRecord(BC.getJobId()); 
        if(this.isNextBatchExecute){
            if(isLastQuery()){
                AGN_BatchJobProcess_CustomMetadata custMetadataJob = new AGN_BatchJobProcess_CustomMetadata();
                Database.executeBatch(custMetadataJob,1);
           }
        }
        else{
            AGN_Post_Copy_Util.sendJobStatusReportEmail();
        }
    }
    
}