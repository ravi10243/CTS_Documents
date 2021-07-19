/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author            Cognizant
* @createdBy        Preeti Achary
* @modifiedBy       Preeti Achary
* @maintainedBy   
* @version          1.1
* @created          Sept30th,2019
* @modified         Oct30th,2019
* @testClass    
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1           
* Oct30th,2019   Added before Update method, makes IsApproved = false and
          the Asset_Status_AGN__c to 'Updated Asset' on on each dataRecordUpdate and update
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class AGN_GDPR_DataRecordTriggerHandler {
    
    // These variables store Trigger.oldMap and Trigger.newMap
    Map<Id, Data_Record_AGN__c> oldDataRecMap;
    Map<Id, Data_Record_AGN__c> newDataRecMap;
    //Created this 'newTriggerList' for the BeforeInsert as Id is not available in the beforeInsert and newMap and oldMap going to be null in beforeInsert.
    List<Data_Record_AGN__c> newTriggerList; 
    //Get the profile Name from the genercally defined getCurrentUserProfileName.
    public String contextUserProfileName = AGN_GDPR_Utility.getCurrentUserProfileName();
    
    public AGN_GDPR_DataRecordTriggerHandler(Map<Id, Data_Record_AGN__c> newTriggerMap,Map<Id, Data_Record_AGN__c> oldTriggerMap, List<Data_Record_AGN__c> newTriggerList){
        oldDataRecMap = oldTriggerMap;
        newDataRecMap = newTriggerMap;
        this.newTriggerList = newTriggerList;
    }
    //onBeforeInsert
    public void onBeforeInsert(){
        for(Data_Record_AGN__c dataRec : newTriggerList){
            //Update the ExternalId to the dynamic external Id on Insert.
            dataRec.External_Id_AGN__c = AGN_GDPR_Utility.getDataRecordExternalId(dataRec);
        }//loop_ends.
    }
    //BeforeUpdate Method.
    //OnEveryDataRecordUpdate - make the isApproved as false, as it will need an approval again.
    public void onBeforeUpdate(){
        //Add profileNameSetToBypass in the process of the approval. Set can accomodate many other profiles for whichever we want to bypass the below logic , profile Name can be added in this set.
        //Set's contains Method is case sensitive so both the operands in upperCase to correctly compare.
        Set<String> profileNameSetToBypass = new Set<String>{('AGN_DSRM_Users').toUpperCase() ,('AGN Business Admin').toUpperCase(), ('System Administrator').toUpperCase()};
        //>>>>>> Need to change profile 'AGN_DSRM_Users' hardcoding to the constant Utility <<<<<<<<<<<
        for(Data_Record_AGN__c dataRec : newDataRecMap.values()){
            //Update the ExternalId to the dynamic external Id on every Update,as it will require an approval again.
            dataRec.External_Id_AGN__c = AGN_GDPR_Utility.getDataRecordExternalId(dataRec);
            if(String.isNotBlank(contextUserProfileName) && !profileNameSetToBypass.contains(contextUserProfileName.toUpperCase())){
                dataRec.Is_Approved_AGN__c = false;
            }
        }//loop_ends.
    }
    //onAfterUpdate Method.
    public void onAfterUpdate(){
        performDataRecordOperations();
    }
    public void performDataRecordOperations() {
        Set<Id> assetRgIdSet = new Set<Id>();
    
        //Fill assetRgIdSet only when the dataSubjectType is present.
        for(Data_Record_AGN__c dataRec : newDataRecMap.values()){
            if(String.isNotBlank(dataRec.Data_Subject_Type_AGN__c)){
                assetRgIdSet.add(dataRec.Asset_Register_AGN__c);
            }
        }//loop_ends.
    
        Map<Id,Asset_Register_AGN__c> mapAssetIdToAssetRg = new Map<Id,Asset_Register_AGN__c>();
        Map<Id,String> mapAstIdToSetSubject;
        Set<String> dataSubTypeSet = new Set<String>();
        Map<Id,Map<String,Integer>> mapAstIdToSubCount = new Map<Id,Map<String,Integer>>();
        Map<String,Integer> mapAstDataSubToCount = new Map<String,Integer>();
        Map<Id,Map<String,Integer>> mapAstIdToSubjectCountMap = new Map<Id,Map<String,Integer>>();
        Map<String,Integer> mapDataRecSubToCount; 
        String dataSubjectStr = '' ;
        String dataSubjectConcat ='';
        Integer countSubject;
        mapAstIdToSetSubject = new Map<Id,String>();
        //Fetch AssetRegister DataSubjectType and concated of it's child. 
        for(Asset_Register_AGN__c assetReg :[select id,Data_Subject_GDPR_AGN__c,Asset_Status_AGN__c,(select id,                                     Data_Subject_Type_AGN__c,Asset_Register_AGN__c,Active_AGN__c,Is_Approved_AGN__c                                     from Data_Records__r where Data_Subject_Type_AGN__c!=null)
                                            from Asset_Register_AGN__c where Id in :assetRgIdSet]){
            mapAssetIdToAssetRg.put(assetReg.Id,assetReg);
            dataSubjectStr = assetReg.Data_Subject_GDPR_AGN__c;
            System.debug('dataSubjectStr## '+dataSubjectStr);
            if(String.isNotBlank(dataSubjectStr)){
                for(String tempStr : dataSubjectStr.split(';')){
                    if(!mapAstDataSubToCount.isEmpty() && mapAstDataSubToCount.containsKey(tempStr)){
                        countSubject = mapAstDataSubToCount.get(tempStr)+1;
                        mapAstDataSubToCount.put(tempStr,countSubject);
                    }
                    else if(mapAstDataSubToCount.isEmpty() || !mapAstDataSubToCount.containsKey(tempStr)){
                        mapAstDataSubToCount.put(tempStr,1);
                    }   
                } 
            }
            System.debug('mapAstDataSubToCount##Ast '+mapAstDataSubToCount);
            mapAstIdToSubCount.put(assetReg.Id, mapAstDataSubToCount);
            System.debug('mapAstIdToSubCount## '+mapAstIdToSubCount);
            Integer count = 0;
            dataSubjectConcat = '';
            mapDataRecSubToCount = new Map<String,Integer>();
            for(Data_Record_AGN__c dataRec : assetReg.Data_Records__r){
                dataSubjectStr = dataRec.Data_Subject_Type_AGN__c;
                dataSubjectConcat += dataSubjectStr;
                System.debug('DataRecord###-11 '+dataRec.Id + '  '+dataRec.Asset_Register_AGN__c);
                if(!mapAstIdToSetSubject.containsKey(assetReg.Id)){
                    mapAstIdToSetSubject.put(assetReg.Id, dataSubjectConcat);
                    System.debug('mapAstIdToSetSubject###-2 '+mapAstIdToSetSubject);
                }
                else if(mapAstIdToSetSubject.containsKey(assetReg.Id)){
                    String tempSubjStr = mapAstIdToSetSubject.get(assetReg.Id);
                     if(String.isNotBlank(dataSubjectStr) && !tempSubjStr.contains(dataSubjectStr) && dataRec.Active_AGN__c && dataRec.Is_Approved_AGN__c){
                        System.debug('mapAstIdToSetSubject###-3 '+mapAstIdToSetSubject);
                        count++;
                        mapAstIdToSetSubject.put(assetReg.Id, mapAstIdToSetSubject.get(assetReg.Id) + dataSubjectStr + ' ; ' );
                    }
                }
                System.debug('mapAstIdToSetSubject##count '+'  count   '  + count + '   '+ mapAstIdToSetSubject);
                if(!mapAstIdToSubjectCountMap.containsKey(assetReg.Id)){
                    mapAstIdToSubjectCountMap.put(assetReg.Id , new Map<String,Integer>());
                }
                else if(mapAstIdToSubjectCountMap.containsKey(assetReg.Id)){
                    if(!mapDataRecSubToCount.isEmpty() && mapDataRecSubToCount.containsKey(dataSubjectStr)){
                        countSubject = mapDataRecSubToCount.get(dataSubjectStr)+1;
                        mapDataRecSubToCount.put(dataSubjectStr,countSubject);
                    }
                    else if(mapDataRecSubToCount.isEmpty() || !mapDataRecSubToCount.containsKey(dataSubjectStr)){
                        mapDataRecSubToCount.put(dataSubjectStr,1);
                    }
                    mapAstIdToSubjectCountMap.put(assetReg.Id,mapDataRecSubToCount);
                }
            }//inner_loop_ends.
        }//loop_ends.
        System.debug('mapAstIdToSubjectCountMap##final1 '+ mapAstIdToSubjectCountMap);
        System.debug('mapAstIdToSetSubject##final1 '+ mapAstIdToSetSubject);
        
        String dataSubOnAsset; 
        Asset_Register_AGN__c assetReg;
        Map<Id,Asset_Register_AGN__c> mapAstIdToAstToUpdate = new Map<Id,Asset_Register_AGN__c>();
        Map<String,Integer> mapDataRecSubjectToCount = new Map<String,Integer>();
        String dataSubRollUpStr;
        Id assetRegId;
        
        for(Data_Record_AGN__c dataRec : newDataRecMap.values()){
            assetRegId = dataRec.Asset_Register_AGN__c;
            //added mapAstIdToAstToUpdate to support bulk operations, if more than one dataRecord exists with one asset, then instead fetching the old queried data it will consider contextual data records as well.
            if(!mapAstIdToAstToUpdate.isEmpty() && mapAstIdToAstToUpdate.containsKey(dataRec.Asset_Register_AGN__c)){
                assetReg = mapAstIdToAstToUpdate.get(dataRec.Asset_Register_AGN__c);
            }
            else if(!mapAssetIdToAssetRg.isEmpty() && mapAssetIdToAssetRg.containsKey(dataRec.Asset_Register_AGN__c)){
                assetReg = mapAssetIdToAssetRg.get(dataRec.Asset_Register_AGN__c);
                mapAstIdToAstToUpdate.put(dataRec.Asset_Register_AGN__c , assetReg);
            }
            String oldSubType = '';
            
            if(assetReg!=null && mapAstIdToSetSubject.containsKey(assetRegId)){
                
                dataSubRollUpStr = mapAstIdToSetSubject.get(assetRegId);
                System.debug('assetRegId## '+assetReg.Id);
                System.debug('dataSubRollUpStr###@@ '+dataSubRollUpStr);
                
                //If any of the data record is deactivated/unApproved, then find out the current dataSubjectType and remove that from the Asset Register(If no other data Record exists with the same DataSubjectType.  
                if(String.isNotBlank(dataRec.Data_Subject_Type_AGN__c) && ((oldDataRecMap.get(dataRec.Id).Active_AGN__c != dataRec.Active_AGN__c && !dataRec.Active_AGN__c) || (oldDataRecMap.get(dataRec.Id).Is_Approved_AGN__c != dataRec.Is_Approved_AGN__c && !dataRec.Is_Approved_AGN__c) || (oldDataRecMap.get(dataRec.Id).Data_Subject_Type_AGN__c != dataRec.Data_Subject_Type_AGN__c))&& !mapAstIdToSubCount.isEmpty() && mapAstIdToSubCount.containsKey(assetRegId) ){
                    oldSubType = oldDataRecMap.get(dataRec.Id).Data_Subject_Type_AGN__c;
                    //If No other data Record exists with the same DataSubjectType exists then Asset's DataSubjectType will no longer have that dataSubjectType.  
                    System.debug('dataSubRollUpStr### '+ dataSubRollUpStr);
                    assetReg.Data_Subject_GDPR_AGN__c = dataSubRollUpStr ; 
                    mapAstIdToAstToUpdate.put(assetReg.Id,assetReg);
                    System.debug('mapAstIdToAstToUpdate### '+ mapAstIdToAstToUpdate);
                    
                    //Do not do anything if more than one data record found with one subject Type.
                }
                //Update the dataSubjectType on the Asset Register - only when the DataRecord is set to approved.
                //Update the dataSubjectType on the Asset Register - When the DataRecord's subject type is updated.
                if(String.isNotBlank(dataRec.Data_Subject_Type_AGN__c) && (oldDataRecMap.get(dataRec.Id).Is_Approved_AGN__c != dataRec.Is_Approved_AGN__c && dataRec.Is_Approved_AGN__c && dataRec.Active_AGN__c) || 
                (oldDataRecMap.get(dataRec.Id).Data_Subject_Type_AGN__c != dataRec.Data_Subject_Type_AGN__c)){
                    mapDataRecSubjectToCount = mapAstIdToSubjectCountMap.get(dataRec.Asset_Register_AGN__c);
                    System.debug('AssetId##34 ' + dataRec.Asset_Register_AGN__c + '   mapDataRecSubjectToCount##@@@ '+mapDataRecSubjectToCount);
                    assetReg.Data_Subject_GDPR_AGN__c = dataSubRollUpStr ; 
                    mapAstIdToAstToUpdate.put(assetReg.Id,assetReg);
                    System.debug('insideApprovalSection ###### '+assetReg.Id);
                    /*if(mapDataRecSubjectToCount.containsKey(oldDataRecMap.get(dataRec.Id).Data_Subject_Type_AGN__c)){
                        if(mapDataRecSubjectToCount.get(oldDataRecMap.get(dataRec.Id).Data_Subject_Type_AGN__c) <= 1){
                            assetReg.Data_Subject_GDPR_AGN__c = dataSubRollUpStr ; 
                            
                            System.debug('mapAstIdToAstToUpdate###toUpdate1 '+mapAstIdToAstToUpdate);
                        }
                        //Do not do anything if more than one data record found with one subject Type.
                    }*/
                    dataSubOnAsset = assetReg.Data_Subject_GDPR_AGN__c;
                    System.debug('AssetId##56loop; ' + dataRec.Asset_Register_AGN__c +'dataSubOnAsset##inFor '+dataSubOnAsset);
                    if(String.isBlank(dataSubOnAsset) || (String.isNotBlank(dataSubOnAsset) && !dataSubOnAsset.containsIgnoreCase(dataRec.Data_Subject_Type_AGN__c))){
                        assetReg.Data_Subject_GDPR_AGN__c =  dataSubRollUpStr ; 
                        //Change to accomodate the bulk scenario, having multiple data records(details) with one Asset Register (master)
                        mapAstIdToAstToUpdate.put(assetReg.Id,assetReg);
                        System.debug('dataSubOnAsset### '+assetReg.Data_Subject_GDPR_AGN__c);
                    }
                }
                //Update the Asset_Status_AGN__c to Updated Asset, on every Data Record Update. 
                if(Trigger.isUpdate){  
                    System.debug('contextUserProfileName### '+ 'Inside### '+ contextUserProfileName);
                    //>>>>>> Need to change profile hardcoding to the constant Utility <<<<<<<<<<<
                    //Add profileNameSetToBypass in the process of the approval. Set can accomodate many other profiles for whichever we want to bypass the below logic , profile Name can be added in this set.
                    //Set's contains Method is case sensitive so both the operands in upperCase to correctly compare.
                    Set<String> profileNameSetToBypass = new Set<String>{('AGN_DSRM_Users').toUpperCase() , ('System Administrator').toUpperCase()};
                    if(String.isNotBlank(contextUserProfileName) && !profileNameSetToBypass.contains(contextUserProfileName.toUpperCase())){    
                        System.debug('assetReg### '+ assetReg);
                        assetReg.Asset_Status_AGN__c = 'Updated Asset';
                    }
                    mapAstIdToAstToUpdate.put(assetReg.Id,assetReg);
                }
            }
        }//loop_ends.
        System.debug('mapAstIdToAstToUpdate##final1ToUpdate '+mapAstIdToAstToUpdate);
        if(!mapAstIdToAstToUpdate.isEmpty()){
            update mapAstIdToAstToUpdate.values();
        }
    }  
}