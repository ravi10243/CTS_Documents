/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant
* @Name           AGN_updateMergeChildobj
* @modifiedBy     Preeti Achary
* @maintainedBy   Preeti Achary
* @version        1.0
* @created        2019-05-03
* @modified       2019-05-08
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
*/
global class AGN_updateMergeChildobj implements Database.Batchable<sObject>{
    
    /* Start Method 
*  Scope is Merge_Child_AGN__c
*/
    global Database.QueryLocator start(Database.BatchableContext BC){
        try{
            //Parent_Merge_Record_AGN__c
            String query;
            query ='SELECT Id,Child_Id_AGN__c,Child_Status_AGN__c,Child_Error_Details_AGN__c,Child_Header_AGN__c,Child_Value_AGN__c'; 
            query += ' FROM Merge_Child_AGN__c where ';
            query += ' Child_Status_AGN__c=\'INPROGRESS\'';
            System.debug('query: '+query);
            return Database.getQueryLocator(query);
        }catch(Exception ex){
            System.debug('ErrorInStart = '+ex.getMessage()+' at line number = '+ex.getLineNumber());
            return null;
        }
    }
    /* Execute Logic
*  Scope is Merge_Child_AGN
*/
    global void execute(Database.BatchableContext BC, Merge_Child_AGN__c[] mergeChildObjScope){
        // Logic to be Executed batch wise
        Map<Id, Merge_Child_AGN__c> mapChildIdToChildMerge = new Map<Id,Merge_Child_AGN__c>();
        map<Id, Merge_Child_AGN__c> mapMatrixIdToChildMerge = new map<Id, Merge_Child_AGN__c>();
        map<Id, Merge_Child_AGN__c> mapTsfIdToChildMerge = new map<Id, Merge_Child_AGN__c>();
        map<Id, Merge_Child_AGN__c> mapChildAccToChildMerge = new map<Id, Merge_Child_AGN__c>();
        String fieldApiHeaderStr;
        Id childObjId;
        
        for(Merge_Child_AGN__c mergeChild: mergeChildObjScope) {
            if(mergeChild.Child_Id_AGN__c!=null){
                fieldApiHeaderStr = mergeChild.Child_Header_AGN__c;
                childObjId = mergeChild.Child_Id_AGN__c; 
                mapChildIdToChildMerge.put(childObjId,mergeChild);
                String objName = String.valueOf(childObjId.getsobjecttype());
                if(objName.equalsIgnoreCase('Product_Metrics_vod__c')){
                    mapMatrixIdToChildMerge.put(childObjId,mergeChild);
                }
                else if(objName.equalsIgnoreCase('TSF_vod__c')){
                    mapTsfIdToChildMerge.put(childObjId,mergeChild);
                }
                else if(objName.equalsIgnoreCase('Child_Account_vod__c')){
                    mapChildAccToChildMerge.put(childObjId,mergeChild);
                }
            }
        }//loop_Ends.
        List<String>fieldApiList = new List<String>();
        List<String>fieldvalueList = new List<String>();
        List<Product_Metrics_vod__c> prodMetrixListToUpdate = new List<Product_Metrics_vod__c>();
        List<TSF_vod__c> TsfListToUpdate = new List<TSF_vod__c>();
        List<Child_Account_vod__c> ChildAccListToUpdate = new List<Child_Account_vod__c>();
        Product_Metrics_vod__c prodMat;
        TSF_vod__c tsf;
        Child_Account_vod__c childAcc;
        //get values from Child_Header_AGN__c and Child_Value_AGN__c and update the Product_Metrics_vod__c 
        //and TSF_vod__C object with  those values
        Merge_Child_AGN__c mergeChildObj;
        for(Id keyId: mapChildIdToChildMerge.keySet()){
            
            mergeChildObj = mapChildIdToChildMerge.get(keyId);
            if(String.isNotBlank(mergeChildObj.Child_Header_AGN__c)){
                fieldApiList = mergeChildObj.Child_Header_AGN__c.split(',');//Returns List of Field API Name.
            }
            if(String.isNotBlank(mergeChildObj.Child_Value_AGN__c)){
                fieldvalueList = mergeChildObj.Child_Value_AGN__c.replaceAll('\"','').split(',');//Returns List of value each corresponds to Field API.
            }
            if(!fieldApiList.isEmpty() && !fieldvalueList.isEmpty() && fieldApiList.size() == fieldvalueList.size()){
                if(mapMatrixIdToChildMerge.containsKey(keyId)){
                    prodMat = new Product_Metrics_vod__c(Id = keyId);
                    for(integer i= 0; i<fieldApiList.size(); i++){
                        // Type casting 
                        System.debug('prodMat_BeforeUpdate '+prodMat);
                        System.debug('first** '+fieldApiList.get(i)+' #fieldvalueList : '+fieldvalueList.get(i));
                        if(AGN_typeConversionUtil.doesFieldExist('Product_Metrics_vod__c',fieldApiList.get(i))){
                            AGN_typeConversionUtil.typeCastAndPopulateProd(prodMat, 'Product_Metrics_vod__c',fieldApiList.get(i),
                                                                           fieldvalueList.get(i));
                        }
                    }//loop_ends
                    prodMetrixListToUpdate.add(prodMat);
                    System.debug('prodMat_AfterUpdate '+prodMat);
                }
                if(mapTsfIdToChildMerge.containsKey(keyId)){
                    tsf = new TSF_vod__c(Id = keyId);
                    for(integer i= 0; i<fieldApiList.size(); i++){
                        //Type casting 
                        System.debug('tsf_BeforeUpdate '+tsf);
                        System.debug('first** '+fieldApiList.get(i)+' #fieldvalueList : '+fieldvalueList.get(i));
                        if(AGN_typeConversionUtil.doesFieldExist('TSF_vod__c',fieldApiList.get(i))){
                            AGN_typeConversionUtil.typeCastAndPopulateTsf(tsf, 'TSF_vod__c',fieldApiList.get(i),
                                                                          fieldvalueList.get(i));
                        }
                    }//loop_ends
                    TsfListToUpdate.add(tsf); 
                    System.debug('tsf_AfterUpdate '+tsf);
                }
                if(mapChildAccToChildMerge.containsKey(keyId)){
                    childAcc = new Child_Account_vod__c(Id = keyId);
                    for(integer i= 0; i<fieldApiList.size(); i++){
                        //Type casting 
                        System.debug('childAccount_BeforeUpdate '+childAcc);
                        System.debug('first** '+fieldApiList.get(i)+' #fieldvalueList : '+fieldvalueList.get(i));
                        if(AGN_typeConversionUtil.doesFieldExist('Child_Account_vod__c',fieldApiList.get(i))){
                            AGN_typeConversionUtil.typeCastAndPopulatechildAcc(childAcc, 'Child_Account_vod__c',fieldApiList.get(i),
                                                                               fieldvalueList.get(i));
                        }
                        
                    }//loop_ends
                    ChildAccListToUpdate.add(childAcc); 
                    System.debug('childAcc_AfterUpdate '+childAcc);
                    system.debug('ChildAccListToUpdate'+ChildAccListToUpdate);
                }
            }
        }//loop_Ends
        //update the Product_Metrics_vod__c object list in the salesforce
        Map<Id,Merge_Child_AGN__c> mergeChildTochildMap = new Map<Id,Merge_Child_AGN__c>();
        Merge_Child_AGN__c tempMergeChild = new Merge_Child_AGN__c();
        //Product Matrix Update
        if(!prodMetrixListToUpdate.isEmpty()){
            Database.SaveResult[] srList = Database.update(prodMetrixListToUpdate,false);
            for(integer a=0; a<srList.size();a++){
                if(srList[a].getId()!=null){
                    tempMergeChild = mapMatrixIdToChildMerge.get(prodMetrixListToUpdate[a].id);
                    tempMergeChild.Child_Status_AGN__c = 'COMPLETED';
                    System.debug('tempMergeChildStatus!! '+ tempMergeChild.id);
                    mergeChildTochildMap.put(tempMergeChild.Id,tempMergeChild);
                }
                else{
                    List<Database.Error> errorList = srList[a].getErrors();
                    Merge_Child_AGN__c mcRec = mapChildIdToChildMerge.get(prodMetrixListToUpdate[a].id);
                    mcRec.Child_Status_AGN__c ='FAILED';
                    mcRec.Child_Error_Details_AGN__c='';
                    for(Database.Error error : errorList){
                        SYSTEM.debug('ERRORMESSAGE'+error.getMessage());
                        mcRec.Child_Error_Details_AGN__c += error.getMessage();
                    }//loop_ends
                    mergeChildTochildMap.put(mcRec.Id,mcRec);
                    System.debug('failedRecordId: '+mcRec.id);
                }
            }//loop_ends
        }
        //update the TSF_vod__c object list in the salesforce
        for(Id i :mapChildIdToChildMerge.keySet()){
            System.debug('mapChildIdToChildMerge$$ '+ i +' #mapChildIdToChildMergeValue# '+ mapChildIdToChildMerge.get(i));
        }//loop_ends
        if(!TsfListToUpdate.isEmpty()){
            Database.SaveResult[] srList = Database.update(TsfListToUpdate,false);
            System.debug('SRTSFLIST'+ srList.size() + 'srList# '+srList);
            for(integer a=0; a<srList.size();a++){
                if(srList[a].getId()!=null){
                    tempMergeChild = mapChildIdToChildMerge.get(TsfListToUpdate[a].id);
                    tempMergeChild.Child_Status_AGN__c = 'COMPLETED';
                    mergeChildTochildMap.put(tempMergeChild.Id,tempMergeChild);
                }
                else{
                    List<Database.Error> errorList = srList[a].getErrors();
                    Merge_Child_AGN__c mcRec = mapChildIdToChildMerge.get(TsfListToUpdate[a].id);
                    mcRec.Child_Status_AGN__c = 'FAILED';
                    mcRec.Child_Error_Details_AGN__c = '';
                    for(Database.Error error : errorList){
                        System.debug('ERRORMESSAGE## '+error.getMessage());
                        mcRec.Child_Error_Details_AGN__c += error.getMessage();
                    }//loop_ends
                    mergeChildTochildMap.put(mcRec.Id,mcRec);
                    System.debug('failed RecordId: '+ mcRec.id);
                }
            }//loop_ends
        }
        if(!ChildAccListToUpdate.isEmpty()){
            Database.SaveResult[] srList = Database.update(ChildAccListToUpdate,false);
            System.debug('SRTSFLIST'+ srList.size() + 'srList# '+srList);
            for(integer a=0; a<srList.size();a++){
                if(srList[a].getId()!=null){
                    tempMergeChild = mapChildIdToChildMerge.get(ChildAccListToUpdate[a].id);
                    tempMergeChild.Child_Status_AGN__c = 'COMPLETED';
                    mergeChildTochildMap.put(tempMergeChild.Id,tempMergeChild);
                }
                else{
                    List<Database.Error> errorList = srList[a].getErrors();
                    Merge_Child_AGN__c mcRec = mapChildIdToChildMerge.get(ChildAccListToUpdate[a].id);
                    mcRec.Child_Status_AGN__c = 'FAILED';
                    mcRec.Child_Error_Details_AGN__c = '';
                    for(Database.Error error : errorList){
                        System.debug('ERRORMESSAGE## '+error.getMessage());
                        mcRec.Child_Error_Details_AGN__c += error.getMessage();
                    }//loop_ends
                    mergeChildTochildMap.put(mcRec.Id,mcRec);
                    System.debug('failed RecordId: '+ mcRec.id);
                }
            }//loop_ends
        }
        system.debug('mergeChildTochildMap===== '+mergeChildTochildMap);
        if(!mergeChildTochildMap.isEmpty()){
            database.update(mergeChildTochildMap.values(),false);
        }
    }     
    global void finish(Database.BatchableContext BC){
        // call batch class to merge duplicate accounts
        Database.executeBatch(new AGN_batchMergeAccounts(),1);
    }
}