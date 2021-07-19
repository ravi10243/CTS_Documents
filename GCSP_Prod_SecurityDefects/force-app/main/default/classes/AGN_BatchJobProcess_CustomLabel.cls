/**
* The Job will getting triggered once WorkflowEmail job finished its activity 
* which overrides the config data with org specific data. In this case custom label data 
* specific for sandbox org overides the custom label data of production org.
*
* @author  Amit Das
* @version 1.0
* @since   2020-07-28 
*/

global class AGN_BatchJobProcess_CustomLabel implements Database.Batchable<sObject>,Database.AllowsCallouts{
    
    
    Boolean isNextBatchExecute = true;
    public AGN_BatchJobProcess_CustomLabel(Boolean value){
       this.isNextBatchExecute = value;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        
        String query = 'Select Custom_Label_Name__c,Description__c,Language__c,isProtected__c,URLValue__c,Value__c,IsActive__c from AGN_Post_Activity_CustomLabel__mdt';
        System.debug('Raw Query ' +query);
        List<AGN_Post_Activity_CustomLabel__mdt> custLabels = [Select Custom_Label_Name__c,Description__c,Language__c,isProtected__c,URLValue__c,Value__c,IsActive__c from AGN_Post_Activity_CustomLabel__mdt];
        System.debug('meta data size ' +custLabels);
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<AGN_Post_Activity_CustomLabel__mdt> custLabelMetaInfos) {
        //System.debug('Queue list size '+queueList);  
        // process each batch of records default size is 200
        //List<Post_Refresh_Metadata__mdt> updatedCustLabelList = new List<Post_Refresh_Metadata__mdt>();
        //Custom_Label_Name__c,Description__c,URLValue__c,IsActive__c 
        System.debug('Custom label info --' + custLabelMetaInfos);
        for(AGN_Post_Activity_CustomLabel__mdt labelInfo : custLabelMetaInfos){
           AGN_Post_Refresh_Custom_LabelUtil.updateCustomLabel(labelInfo);  
        }
        try {
            // Update the Account Record
            //update updatedCustLabelList;
         
        } catch(Exception e) {
            System.debug(e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        System.debug('Custom label job finished ');
        // start next batch process
        AGN_Post_Copy_Util.insertJobRecord(BC.getJobId()); 
        if(this.isNextBatchExecute){
            AGN_CustomSettingBatchProcess custSettingBatch = new AGN_CustomSettingBatchProcess();
            custSettingBatch.processCustomSettingBatchJobs();
        }
        else{
            AGN_Post_Copy_Util.sendJobStatusReportEmail();
        }
        
    }
}