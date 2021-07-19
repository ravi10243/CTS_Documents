global class AGN_AccountExtID implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        try{
            return Database.getQueryLocator([SELECT Id,Ext_Status_AGN__c,Ext_Error_Msg_AGN__c, Winner_Id_AGN__c,Merge_Country_AGN__c,Ext_Field_Header_AGN__c,
                                             Ext_Field_Val_AGN__c FROM Merge_Parent_AGN__c WHERE 
                                             Ext_Status_AGN__c = 'INPROGRESS' AND Merge_Status_AGN__c = 'COMPLETED']);
        }
        catch(Exception e)
        {
            System.debug('ErrorInStart = '+e.getMessage()+' at line number = '+e.getLineNumber());
            return null;
        }
    }
    
    global void execute(Database.BatchableContext context, List<Merge_Parent_AGN__c> mergeParentScope){
        List<Account> accountListToUpdate = new List<Account>();
        List<String>fieldApiList = new List<String>();
        List<String>fieldvalueList = new List<String>();
        Map<Id,Merge_Parent_AGN__c> mergeParentMap = new Map<Id,Merge_Parent_AGN__c>();
        Map<Id, Merge_Parent_AGN__c> winnerMergeMap = new Map<Id, Merge_Parent_AGN__c>();
        Account acc;
        List<Account> accList = new List<Account>();
        
        for(Merge_Parent_AGN__c mergeRec: mergeParentScope){
            //winnerID= mergeRec.Winner_Id_AGN__c;
            winnerMergeMap.put(mergeRec.Winner_Id_AGN__c,mergeRec);
        }
        Merge_Parent_AGN__c mergeParentObj;
        for(Id keyId: winnerMergeMap.keySet()){
            mergeParentObj = winnerMergeMap.get(keyId);
            if(String.isBlank(mergeParentObj.Ext_Field_Header_AGN__c) && String.isBlank(mergeParentObj.Ext_Field_Val_AGN__c)){
                
                Merge_Parent_AGN__c wrongRecords = winnerMergeMap.get(keyId);
                wrongRecords.Ext_Status_AGN__c = 'COMPLETED';
                mergeParentMap.put(wrongRecords.id,wrongRecords);
                system.debug('Both Empty:fieldApiList.size() + fieldvalueList.size()'+fieldApiList.size()+'  '+fieldvalueList.size());
                system.debug('mergeParentMap--->'+mergeParentMap);
                system.debug('wrongRecords + wrongRecords.id'+wrongRecords+' '+wrongRecords.id);
            }
            else if (String.isBlank(mergeParentObj.Ext_Field_Header_AGN__c)){
                
                Merge_Parent_AGN__c noValueRecords = winnerMergeMap.get(keyId);
                noValueRecords.Ext_Status_AGN__c = 'FAILED';
                noValueRecords.Ext_Error_Msg_AGN__c = 'No value in Ext_Field_Header_AGN__c field';
                mergeParentMap.put(noValueRecords.id,noValueRecords);
                system.debug('Ext_Field_Header_AGN__c Empty: fieldApiList.size() + fieldvalueList.size()'+fieldApiList.size()+'  '+fieldvalueList.size());
                system.debug('mergeParentMap--->'+mergeParentMap);
                system.debug('noValueRecords + noValueRecords.id'+noValueRecords+' '+noValueRecords.id);
                
            }
            
            else if(String.isBlank(mergeParentObj.Ext_Field_Val_AGN__c))
            {
                Merge_Parent_AGN__c noValueRecords = winnerMergeMap.get(keyId);
                noValueRecords.Ext_Status_AGN__c = 'FAILED';
                noValueRecords.Ext_Error_Msg_AGN__c = 'No value in Ext_Field_Val_AGN__c field';
                mergeParentMap.put(noValueRecords.id,noValueRecords);
                system.debug('Ext_Field_Val_AGN__c empty: fieldApiList.size() + fieldvalueList.size()'+fieldApiList.size()+'  '+fieldvalueList.size());
                system.debug('mergeParentMap--->'+mergeParentMap);
                system.debug('noValueRecords + noValueRecords.id'+noValueRecords+' '+noValueRecords.id);  
            }
            else if(String.isNotBlank(mergeParentObj.Ext_Field_Header_AGN__c) && String.isNotBlank(mergeParentObj.Ext_Field_Val_AGN__c)){
                if(String.isNotBlank(mergeParentObj.Ext_Field_Header_AGN__c)){
                    
                    fieldApiList = mergeParentObj.Ext_Field_Header_AGN__c.split(',');//Returns List of Field API Name.
                }
                if(String.isNotBlank(mergeParentObj.Ext_Field_Val_AGN__c)){
                    
                    fieldvalueList = mergeParentObj.Ext_Field_Val_AGN__c.replaceAll('\"','').split('~#');//Returns List of value each corresponds to Field API.
                }       
                
                if(!fieldApiList.isEmpty() && !fieldvalueList.isEmpty() && fieldApiList.size() == fieldvalueList.size()){
                    acc = new Account(id=keyId);
                    for(integer i=0;i<fieldApiList.size();i++)
                    {
                        
                        System.debug('acc_BeforeUpdate '+acc);
                        System.debug('first** '+fieldApiList.get(i)+' #fieldvalueList : '+fieldvalueList.get(i));
                        if(AGN_typeConversionUtil.doesFieldExist('Account',fieldApiList.get(i))){
                            AGN_typeConversionUtil.typeCastAndPopulate(acc, 'Account',fieldApiList.get(i),fieldvalueList.get(i));
                        }
                       
                    }//loopendsfieldApiList.size()
                    system.debug('keyID in main completed'+keyId);
                    system.debug('Account in main completed'+acc);
                    accList.add(acc);
                    
                }         
            }
            
        }//loopendswinnerMergeMap.keySet()
        
        
        
        if(!accList.isEmpty()){
            Database.SaveResult[] srList = Database.update(accList,false);
            for(integer a=0; a<srList.size();a++){
                if(srList[a].getId()!=null){
                    Merge_Parent_AGN__c completedRecords = winnerMergeMap.get(accList[a].id);
                    if (Schema.sObjectType.Merge_Parent_AGN__c.fields.Ext_Status_AGN__c.isUpdateable ()){ // sw cc
                    	completedRecords.Ext_Status_AGN__c = 'COMPLETED';
                    }
                    mergeParentMap.put(completedRecords.id,completedRecords);
                }
                else {
                    List<Database.Error> errorList = srList[a].getErrors();
                    Merge_Parent_AGN__c failedRecords = winnerMergeMap.get(accList[a].id);
                    
                     if (Schema.sObjectType.Merge_Parent_AGN__c.fields.Ext_Status_AGN__c.isUpdateable ()){ // sw cc
                    	failedRecords.Ext_Status_AGN__c = 'FAILED';
                    }
                    if (Schema.sObjectType.Merge_Parent_AGN__c.fields.Ext_Error_Msg_AGN__c.isUpdateable ()){ //sw cc
                    	failedRecords.Ext_Error_Msg_AGN__c = '';
                    }
                    for(Database.Error error : errorList){
                        if (Schema.sObjectType.Merge_Parent_AGN__c.fields.Ext_Error_Msg_AGN__c.isUpdateable ()){ //sw cc
                        	failedRecords.Ext_Error_Msg_AGN__c += error.getMessage();
                        }
                        mergeParentMap.put(failedRecords.id,failedRecords);
                    }
                }
                
            }
        }
        
        if(!mergeParentMap.isEmpty()){
            if(Merge_Parent_AGN__c.sObjectType.getDescribe().isUpdateable()){ //sw cc
            	database.update(mergeParentMap.values(),false);    
            }
            
        }
    }
    
    global void finish(Database.BatchableContext context) {
    }
}