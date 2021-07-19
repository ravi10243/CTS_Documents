/**
* The Job will getting triggered once Custom Setting job finished its activity 
* which overrides the config data with org specific data. In this case data 
* maintained under different custom settings and custom metadata will be restored specific for sandbox org.
*
* @author  Amit Das
* @version 1.0
* @since   2020-08-03 
*/

global class AGN_BatchJobProcess_CustomMetadata implements Database.Batchable<sObject>,Database.AllowsCallouts{
    List<AGN_Post_Activity_CustomMetadata__mdt> metaDataList;
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        this.metaDataList().clear();
        String query = 'SELECT Label,DeveloperName__c,ReferenceId__c, Type__c, Type_Field__c, Type_Field_Value__c,Type_Name__c FROM AGN_Post_Activity_CustomMetadata__mdt order by Type__c ,Type_Name__c';
        return Database.getQueryLocator(query);
        
    }  
        private String currentObject;
        SObject objectRef;
        global void execute(Database.BatchableContext BC, List<AGN_Post_Activity_CustomMetadata__mdt> metaList) {
            List<SObject> listUpObbjects = new List<SObject>();
            for(AGN_Post_Activity_CustomMetadata__mdt custObject : metaList){
                if('Custom Setting'.equalsIgnoreCase(custObject.Type__c)){
                    boolean isNewObject = false;
                    if(! custObject.Type_Name__c.equalsIgnoreCase(currentObject)){
                        isNewobject = true;
                        currentObject = custObject.Type_Name__c;
                    }
                    Schema.SObjectType targetType = Schema.getGlobalDescribe().get(custObject.Type_Name__c);
                    if(isNewObject){
                        objectRef = (SObject)(Type.forName('Schema.'+custObject.Type_Name__c).newInstance());
                        objectRef.put('Id', custObject.ReferenceId__c);
                    }
                    objectRef.put(custObject.Type_Field__c, custObject.Type_Field_Value__c);
                    if(isNewObject){
                        listUpObbjects.add(objectRef); 
                    }
                }
                else if('Custom Metadata Type'.equalsIgnoreCase(custObject.Type__c)){
                    AGN_CustomMetadataInfo metaInfo = new AGN_CustomMetadataInfo();
                    Map<String , Object> fieldMap = new Map<String , Object>();
                    fieldMap.put(custObject.Type_Field__c ,custObject.Type_Field_Value__c);
                    metaInfo.setFieldValueMap(fieldMap); 
                    metaInfo.setDeveloperName(custObject.DeveloperName__c);
                    metaInfo.setLabel(custObject.Label);
                    metaInfo.setObjectName(custObject.Type_Name__c);
                    this.metaDataList().add(metaInfo);
                }
                
                
            }
            
            for(AGN_CustomMetadataInfo info : this.metaDataList()){
                System.debug('Meta data size '+ this.metaDataList().size());
                AGN_CustomMetadataUtils.updateCustomMetadata(info.ObjectName() , info.DeveloperName(),info.Label() ,info.mapFieldValue());             
            }
           try{
                update listUpObbjects;
                System.debug('Updated successfully -----' + listUpObbjects.size());
            }
            Catch(DmlException excep){
                System.debug('Update failed -----'+excep);
            }
         }
        private List<AGN_CustomMetadataInfo> infoList;
        public List<AGN_CustomMetadataInfo> metaDataList(){
          if(infoList == null)
            infoList = new List<AGN_CustomMetadataInfo>();
          return this.infoList;
         }
        
        global void finish(Database.BatchableContext BC) {
             System.debug('Batch finish '); 
             AGN_Post_Copy_Util.insertJobRecord(BC.getJobId()); 
             AGN_Post_Copy_Util.sendJobStatusReportEmail();
        
        }
    }