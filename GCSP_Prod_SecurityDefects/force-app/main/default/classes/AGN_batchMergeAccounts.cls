/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant
* @Name           AGN_batchMergeAccounts
* @modifiedBy     Preeti Achary
* @maintainedBy   Preeti Achary
* @version        1.0
* @created        2019-04-25
* @modified       2019-05-06
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
*/
global class AGN_batchMergeAccounts implements Database.Batchable<sObject>,Database.Stateful{
    /* Start Method 
*  Scope is Merge_Parent_AGN__c
*/
    private List<AGNGigyaAccountChannelChangedVariables> vars= new List<AGNGigyaAccountChannelChangedVariables>();
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query =  'SELECT Id,Merge_Status_AGN__c,Merge_Error_Details_AGN__c,Loser_Id_AGN__c, Winner_Id_AGN__c,Merge_Country_AGN__c,Field_Header_AGN__c, Field_Value_AGN__c '; 
        query += 'FROM Merge_Parent_AGN__c where ';
        query += 'Merge_Status_AGN__c=\'INPROGRESS\'';
        System.debug('query: '+query);
        return Database.getQueryLocator(query);
    }
    /* Execute Logic
*  Scope is Merge_Parent_AGN__c
*/
    public void execute(Database.BatchableContext context, Merge_Parent_AGN__c[] mergeParentScope){
        //Logic to be Executed batch wise
        List<Account> winnerAccountList = new List<Account>();
        Map<String,  List<Merge_Parent_AGN__c>> mapWinIdLooserMerge = new Map<String, List<Merge_Parent_AGN__c>>();
        Map<String,  List<Id>> mapWinIdLooserId = new Map<String, List<Id>>();
        Map<String, Merge_Parent_AGN__c> mapLooserIdToMrId = new Map<String, Merge_Parent_AGN__c>();
        String winnerId; 
        String looserId; 
        string fieldApistr;
        String fieldHeaderQuery;
        Set<Id> accIdSet = new Set<Id>();
        Set<Merge_Parent_AGN__c> noRecordSet = new Set<Merge_Parent_AGN__c>();
        Map<Id, Merge_Parent_AGN__c> winnerMergeMap = new Map<Id, Merge_Parent_AGN__c>();
        List<Address_vod__c > listChildAdd  = new List<Address_vod__c >();//Merge 20119 Update
        AGNGigyaAccountChannelChangedVariables tempVar = new AGNGigyaAccountChannelChangedVariables(vars);
        for(Merge_Parent_AGN__c mergeRec: mergeParentScope) {
            winnerId = mergeRec.Winner_Id_AGN__c;
            looserId = mergeRec.Loser_Id_AGN__c;
            winnerMergeMap.put(winnerId,mergeRec);
            if(!String.isBlank(mergeRec.Field_Header_AGN__c)){
                System.debug('mergeRec.Field_Header_AGN__c+:'+mergeRec.Field_Header_AGN__c);
            String[] fieldString= mergeRec.Field_Header_AGN__c.split(',');
                System.debug('fieldString+:'+ fieldString);
            for(String s: fieldString){
                if(String.isBlank(fieldHeaderQuery)){
                    fieldHeaderQuery = s;
                }
                else{
                    if(!fieldHeaderQuery.contains(s)){
                    fieldHeaderQuery= fieldHeaderQuery+','+s;
                }
              }
            }
             System.debug('fieldHeaderQuery created is:'+ fieldHeaderQuery);
           }          
            if(!mapWinIdLooserMerge.containsKey(winnerId)){
                mapWinIdLooserMerge.put(winnerId , new List<Merge_Parent_AGN__c>{});
            }
            mapWinIdLooserMerge.get(winnerId).add(mergeRec);
            accIdSet.add(winnerId);
            mapLooserIdToMrId.put(looserId,mergeRec);
            Id accLooserId = looserId;
            if(!mapWinIdLooserId.containsKey(winnerId)){
                mapWinIdLooserId.put(winnerId , new List<String>{});
            }
            mapWinIdLooserId.get(winnerId).add(accLooserId);
            accIdSet.add(looserId);
        }//loop_ends. 
        
        fieldApistr =fieldHeaderQuery;
        string querystr = 'SELECT Id,IsMerged_AGN__c ';
        
        if(String.isNotBlank(fieldApistr)){
            querystr += ',';
            querystr += fieldApistr ;
        }
        querystr +=' from Account where Id in :accIdSet';
        System.debug('querystr******: '+querystr);
        //Database.query(querystr)
        Map<Id,Account> mapAccIdToAcc = new Map<Id,Account>((List<Account>)Database.query(querystr));
        //Some Account records not found.
        Set<Id> setAccIdNotFound = new Set<Id>();
        if(accIdSet.size() != mapAccIdToAcc.keySet().size()){
            for(Id objId: accIdSet){
                if(!mapAccIdToAcc.keySet().contains(objId)){
                    setAccIdNotFound.add(objId);
                    
                }
            }
        }
        System.debug('setAccIdNotFound:::::::::::::::::::'+setAccIdNotFound.size());
        if(!setAccIdNotFound.isEmpty()){
            for(Id absentAccount : setAccIdNotFound){
                System.debug('setAccIdNotFound+++:'+absentAccount);
                if(winnerMergeMap.containsKey(absentAccount)){
                    System.debug('WinnerabsentAccount+++:'+winnerMergeMap.get(absentAccount).id);
                    Merge_Parent_AGN__c mrRec = new Merge_Parent_AGN__c(id=winnerMergeMap.get(absentAccount).id);
                    System.debug('the Merge record with unknown winner:'+mrRec);
                    if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Status_AGN__c.isUpdateable()){// swar cc 
                        mrRec.Merge_Status_AGN__c ='FAILED';
                    }
                    if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Error_Details_AGN__c.isUpdateable()){// swar cc 
                        mrRec.Merge_Error_Details_AGN__c= 'Record Not Found';
                    }
                    noRecordSet.add(mrRec);
                }else if(mapLooserIdToMrId.containsKey(absentAccount)){
                    System.debug('LoserabsentAccount+++:'+mapLooserIdToMrId.get(absentAccount).id);
                    if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Id.isUpdateable()){}
                    Merge_Parent_AGN__c mrRec = new Merge_Parent_AGN__c(id=mapLooserIdToMrId.get(absentAccount).id);
                    System.debug('the Merge_ record with unknown loser:'+mrRec);
                    if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Status_AGN__c.isUpdateable()){// swar cc 
                        mrRec.Merge_Status_AGN__c ='FAILED';
                    }
                    if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Error_Details_AGN__c.isUpdateable()){// swar cc 
                        mrRec.Merge_Error_Details_AGN__c= 'Record Not Found';
                    }
                    noRecordSet.add(mrRec);
                }
            }
        }
        System.debug('Merge Records size()'+noRecordSet.size());
        List<Merge_Parent_AGN__c> noRecordList = new List<Merge_Parent_AGN__c>();
        if(noRecordSet.size()!=0)
            for(Merge_Parent_AGN__c rec : noRecordSet){
                Merge_Parent_AGN__c mrRec = rec;
                noRecordList.add(rec);
                
            }
        System.debug('noRecordList.size()'+noRecordList.size());
        try{
            if(Merge_Parent_AGN__c.sObjectType.getDescribe().isUpdateable()){// swar cc 
                Database.update(noRecordList,false);  
            }
        }catch(Exception e){
            System.debug(e.getMessage()+e.getLineNumber());
        }
        
        if(!mapWinIdLooserMerge.isEmpty() && !mapAccIdToAcc.isEmpty()){
            Account accMaster;
            Account oldAcc;
            String looserAccId;
            List<String>fieldApiList = new List<String>();
            List<String>fieldvalueList = new List<String>();
            Map<Id,Merge_Parent_AGN__c> mapMergeResultToUpdate = new Map<Id,Merge_Parent_AGN__c>();
            
            for(String winId : mapWinIdLooserMerge.keySet()){
                if(mapAccIdToAcc.containsKey(winId) && mapWinIdLooserMerge.containsKey(winId) 
                   && mapWinIdLooserId.containsKey(winId)){
                       accMaster = mapAccIdToAcc.get(winId);
                       system.debug('accMaster ismerged before Merge**'+accMaster.IsMerged_AGN__c);
                       oldAcc = accMaster.clone();
                       System.debug('accMaster** '+accMaster.Id);
                       for(Merge_Parent_AGN__c mergeRec : mapWinIdLooserMerge.get(winId)){
                           looserAccId = mergeRec.Loser_Id_AGN__c;
                           if(String.isNotBlank(mergeRec.Field_Header_AGN__c))
                           {
                               fieldApiList = mergeRec.Field_Header_AGN__c.split(',');//listAPI
                           }
                           system.debug('fieldApiList'+fieldApiList);
                           if(String.isNotBlank(mergeRec.Field_Value_AGN__c)){
                               fieldvalueList = mergeRec.Field_Value_AGN__c.replaceAll('\"','').split('~#');
                           }
                           System.debug('first1** '+fieldApiList+' #fieldvalueList : '+fieldvalueList);
                           if(!fieldApiList.isEmpty() && !fieldvalueList.isEmpty() && fieldApiList.size() == fieldvalueList.size()){
                               for(Integer i=0; i<fieldApiList.size() ; i++){
                                   if(AGN_typeConversionUtil.doesFieldExist('Account',fieldApiList.get(i))){
                                       AGN_typeConversionUtil.typeCastAndPopulate(accMaster, 'Account',fieldApiList.get(i),
                                                                                  fieldvalueList.get(i));
                                   }
                                   
                               }//loop_ends   
                           }
                       }//loop_ends.
                       //This will only work when size of loser records are lesser than or equal to 2. 
                       //( As Merge accepts only 2 at a time.)
                       if(mapWinIdLooserId.get(winId).size()<=2 ){
                           try{
                           Account tempWinnerAccount = new Account();
                           Database.MergeResult[] results;
                           if(Account.sObjectType.getDescribe().isDeletable()){ 
                               results = Database.merge(accMaster , mapWinIdLooserId.get(winId), false); //@@NEED SW
                           }
                           system.debug('accMaster after merge***'+accMaster);
                           tempVar.accountId =accMaster.Id;
                           System.debug('fieldApiListValues:::::+++'+fieldApiList);
                           if(fieldApiList.contains('PERSONEMAIL')){
                               system.debug('fieldApiList personEmail'+fieldApiList);
                               if(accMaster.personEmail != oldAcc.personEmail)
                               {
                                   tempVar.isEmailBased = true;
                                   tempVar.newChannel = accMaster.personEmail;
                                   tempVar.oldChannel = oldAcc.personEmail;
                                   system.debug('tempVar'+tempVar);
                               }
                           }
                           if(fieldApiList.contains('EMAIL_INTERNAL_AGN__C')){
                               system.debug('fieldApiList emailInternal'+fieldApiList);
                               if(accMaster.Email_Internal_AGN__c != oldAcc.Email_Internal_AGN__c)
                               {
                                   tempVar.isEmailBased = true;
                                   tempVar.newChannel = accMaster.Email_Internal_AGN__c ;
                                   tempVar.oldChannel = oldAcc.Email_Internal_AGN__c;
                                   system.debug('tempVar****'+tempVar);
                               }
                           }
                           if(fieldApiList.contains('PersonMobilePhone')){
                               system.debug('fieldApiList Phone'+fieldApiList);
                               if(accMaster.PersonMobilePhone != oldAcc.PersonMobilePhone)
                               {
                                   tempVar.isEmailBased = false;
                                   tempVar.newChannel = accMaster.PersonMobilePhone;
                                   tempVar.oldChannel = oldAcc.PersonMobilePhone;
                                   system.debug('tempVar***********'+tempVar);
                               }
                           }
                           vars.add(tempVar);
                           for(Database.MergeResult res : results){
                               if (res.isSuccess()) {
                               //for(Child_Account_vod__c chldAcc : [select Id,Copy_Address_vod__c from Child_Account_vod__c where Child_Account_vod__c = :res.getId()]){
                               for(Address_vod__c chldAdd : [SELECT Id,Name,Account_vod__r.IsPersonAccount FROM Address_vod__c WHERE Account_vod__c= :res.getId() and Account_vod__r.IsPersonAccount=false]){   
                                   if(Schema.sObjectType.Address_vod__c.fields.Name.isUpdateable()){ 
                                       chldAdd.Name=chldAdd.Name;
                                   }
                                  listChildAdd.add(chldAdd);
                                }
                                   tempWinnerAccount.id = res.getId();
                                  if(tempWinnerAccount.IsMerged_AGN__c == true)
                                       {
                                       winnerAccountList.add(tempWinnerAccount);
                                       }
                                   System.debug('Master record ID: ' + res.getId());
                                   System.debug('Reparented record ID: ' + res.getUpdatedRelatedIds());
                                   // Get the IDs of the merged records and display them
                                   List<Id> mergedIds = res.getMergedRecordIds();
                                   System.debug('IDs of merged records: ' + mergedIds);
                                   for(Id mrId: mergedIds){        
                                       if(!mapLooserIdToMrId.isEmpty() && mapLooserIdToMrId.containsKey(mrId)){
                                           System.debug('inside try after merge. change status to complete');
                                           Merge_Parent_AGN__c mrRec = mapLooserIdToMrId.get(mrId);
                                           if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Status_AGN__c.isUpdateable()){     // swar cc  
                                            mrRec.Merge_Status_AGN__c ='COMPLETED';
                                           }
                                           mapMergeResultToUpdate.put(mrRec.Id,mrRec);
                                       }
                                   }//loop_ends                                    
                               }
                               else{
                                   for(Database.Error err : res.getErrors()){ 
                                       // print error message in merge error field
                                       System.debug('The email failed to send due to this exception:   \n'+err.getMessage());
                                       System.debug('Fields that affected this error: ' + err.getFields());
                                       system.debug('loser ids****'+mapWinIdLooserId.get(winId));
                                       for(Id mrId : mapWinIdLooserId.get(winId)){
                                           if(!mapLooserIdToMrId.isEmpty()){
                                               System.debug('inside else after merge record failed ');
                                               Merge_Parent_AGN__c mrRec = mapLooserIdToMrId.get(mrId);
                                               if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Status_AGN__c.isUpdateable()){     // swar cc  
                                                mrRec.Merge_Status_AGN__c ='FAILED';
                                               }
                                               if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Error_Details_AGN__c.isUpdateable()){     // swar cc  
                                                mrRec.Merge_Error_Details_AGN__c= err.getMessage();
                                               }
                                               mapMergeResultToUpdate.put(mrRec.Id,mrRec);
                                           }
                                       }//loop_ends
                                   }//loop_ends
                               }
                           }//loop_ends
                           }
                           catch(DMLException e) {
                            system.debug('The following exception has occured:'+e.getMessage());
                           }
                       }
                       //This will work only when loser size is more than 2.
                       else if(mapWinIdLooserId.get(winId).size() > 2){
                           //Create a temporary data Structure to store only 2 at a time.
                           List<Id> tempLooserRecIdList = new List<Id>(); // size(0)
                           tempLooserRecIdList.addAll(mapWinIdLooserId.get(winId));
                           List<Id> tempMergeList = new List<Id>();
                           //5 looser
                           set<id> idset = new set<id>();
                           
                           for(integer i=0;i<tempLooserRecIdList.size();i++){
                               system.debug('i*****'+i);
                               //{1 dup, {1}} , {2 dup, {2}} 
                               //{3,dup, {1}, {4, {2}}}
                               system.debug('accId====='+tempLooserRecIdList[i]);
                               system.debug('tempLooserRecIdList====='+tempLooserRecIdList);
                               if(tempMergeList.size()< =2){
                                   system.debug('accId in first if====='+tempLooserRecIdList[i]);
                                   system.debug('tempLooserRecIdList in first if====='+tempLooserRecIdList);
                                   tempMergeList.add(tempLooserRecIdList[i]); //1dup,2 dup
                                   system.debug('tempMergeList======'+tempMergeList);
                               }
                               //Can merge upto 2 records at a time with one masterAccount.
                               if(tempMergeList.size() == 2 ){
                                   system.debug('i*****'+i);
                                   system.debug('accId in second if====='+tempLooserRecIdList[i]);
                                   system.debug('tempLooserRecIdList in second if====='+tempLooserRecIdList);
                                   try{
                                       Account tempWinnerAccount = new Account();
                                       Database.MergeResult[] results;
                                       if(Account.sObjectType.getDescribe().isDeletable()){ 
                                           results = Database.merge(accMaster , tempMergeList, false); //@@NEED SW
                                       }
                                       tempVar.accountId =accMaster.Id;
                                       if(fieldApiList.contains('PERSONEMAIL')){
                                           system.debug('fieldApiList personEmail'+fieldApiList);
                                           if(accMaster.personEmail != oldAcc.personEmail)
                                           {
                                               tempVar.isEmailBased = true;
                                               tempVar.newChannel = accMaster.personEmail;
                                               tempVar.oldChannel = oldAcc.personEmail;
                                           }
                                       }
                                       if(fieldApiList.contains('EMAIL_INTERNAL_AGN__C')){
                                           system.debug('fieldApiList emailInternal'+fieldApiList);
                                           if(accMaster.Email_Internal_AGN__c != oldAcc.Email_Internal_AGN__c)
                                           {
                                               tempVar.isEmailBased = true;
                                               tempVar.newChannel = accMaster.Email_Internal_AGN__c ;
                                               tempVar.oldChannel = oldAcc.Email_Internal_AGN__c;
                                           }
                                       }
                                       if(fieldApiList.contains('PersonMobilePhone')){
                                           system.debug('fieldApiList Phone'+fieldApiList);
                                           if(accMaster.PersonMobilePhone != oldAcc.PersonMobilePhone)
                                           {
                                               tempVar.isEmailBased = false;
                                               tempVar.newChannel = accMaster.PersonMobilePhone;
                                               tempVar.oldChannel = oldAcc.PersonMobilePhone;
                                           }
                                       }
                                       vars.add(tempVar);
                                       for(Database.MergeResult res : results){
                                           if (res.isSuccess()) {
                                             for(Address_vod__c chldAdd : [SELECT Id,Name,Account_vod__r.IsPersonAccount FROM Address_vod__c WHERE Account_vod__c= :res.getId() and Account_vod__r.IsPersonAccount=false]){   
                                               if(Schema.sObjectType.Address_vod__c.fields.Name.isUpdateable()){  
                                                   chldAdd.Name=chldAdd.Name; //@@NEED SW
                                               }
                                               listChildAdd.add(chldAdd);
                                              }
                                               tempWinnerAccount.id = res.getId();
                                               if(tempWinnerAccount.IsMerged_AGN__c == true)
                                                   {
                                               winnerAccountList.add(tempWinnerAccount);
                                                   }
                                               System.debug('Master record ID: ' + res.getId());
                                               System.debug('Reparented record ID: ' + res.getUpdatedRelatedIds());
                                               // Get the IDs of the merged records and display them
                                               List<Id> mergedIds = res.getMergedRecordIds();
                                               System.debug('IDs of merged records: ' + mergedIds);
                                               for(Id mrId: mergedIds){        
                                                   if(!mapLooserIdToMrId.isEmpty() && mapLooserIdToMrId.containsKey(mrId)){
                                                       System.debug('inside try after merge. change status to complete');
                                                       Merge_Parent_AGN__c mrRec = mapLooserIdToMrId.get(mrId);
                                                       if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Status_AGN__c.isUpdateable()){     // swar cc  
                                                        mrRec.Merge_Status_AGN__c ='COMPLETED';
                                                       }
                                                       mapMergeResultToUpdate.put(mrRec.Id,mrRec);
                                                   }
                                               }//loop_ends             
                                           }
                                           else{
                                               for(Database.Error err : res.getErrors()){
                                                   // print error message in merge error field
                                                   System.debug(err.getMessage());
                                                   for(Id mrId : tempMergeList){
                                                       if(!mapLooserIdToMrId.isEmpty()){
                                                           System.debug('inside else after merge record failed ');
                                                           Merge_Parent_AGN__c mrRec = mapLooserIdToMrId.get(mrId);
                                                           if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Status_AGN__c.isUpdateable()){     // swar cc  
                                                            mrRec.Merge_Status_AGN__c ='FAILED';
                                                           }
                                                           if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Error_Details_AGN__c.isUpdateable()){     // swar cc  
                                                            mrRec.Merge_Error_Details_AGN__c= err.getMessage();
                                                           }
                                                           mapMergeResultToUpdate.put(mrRec.Id,mrRec);
                                                       }
                                                   }//loop_ends
                                               }//loop_ends.
                                           }
                                       }//loop_ends.
                                   }
                                   Catch(DMLException e) {
                                       system.debug('The following exception has occured:'+e.getMessage());
                                   }
                                   for(id ids: tempMergeList){
                                       If(tempLooserRecIdList.contains(ids)){
                                           idset.add(ids);
                                           tempLooserRecIdList.remove(tempLooserRecIdList.indexOf(ids));
                                           system.debug('i*****'+i);
                                           i--;   
                                       }
                                   }//loop_ends
                                   tempMergeList.clear();
                                   System.debug('tempLooserRecIdList===== '+tempLooserRecIdList.size() + 'tempLooserRecIdList==== '+tempLooserRecIdList);
                                   
                               }
                           }//loop_ends
                           if(tempLooserRecIdList.size()==1){
                               System.debug('accMaster: '+accMaster);
                               system.debug('tempLooserRecIdList in third if====='+tempLooserRecIdList);
                               try{
                                   Account tempWinnerAccount = new Account();
                                   Database.MergeResult res;
                                   if(Account.sObjectType.getDescribe().isDeletable()){ 
                                       res = Database.merge(accMaster , tempLooserRecIdList.get(0),false); //@@NEED SW
                                   }
                                   tempVar.accountId =accMaster.Id;
                                   if(fieldApiList.contains('PERSONEMAIL')){
                                       system.debug('fieldApiList personEmail'+fieldApiList);
                                       if(accMaster.personEmail != oldAcc.personEmail)
                                       {
                                           tempVar.isEmailBased = true;
                                           tempVar.newChannel = accMaster.personEmail;
                                           tempVar.oldChannel = oldAcc.personEmail;
                                       }
                                   } 
                                   if(fieldApiList.contains('EMAIL_INTERNAL_AGN__C')){
                                       system.debug('fieldApiList emailInternal'+fieldApiList);
                                       if(accMaster.Email_Internal_AGN__c != oldAcc.Email_Internal_AGN__c   )
                                       {
                                           tempVar.isEmailBased = true;
                                           tempVar.newChannel = accMaster.Email_Internal_AGN__c ;
                                           tempVar.oldChannel = oldAcc.Email_Internal_AGN__c;
                                       }
                                   }
                                   if(fieldApiList.contains('PersonMobilePhone')){
                                       system.debug('fieldApiList Phone'+fieldApiList);
                                       if(accMaster.PersonMobilePhone != oldAcc.PersonMobilePhone)
                                       {
                                           tempVar.isEmailBased = false;
                                           tempVar.newChannel = accMaster.PersonMobilePhone;
                                           tempVar.oldChannel = oldAcc.PersonMobilePhone;
                                       }
                                   }
                                   vars.add(tempVar);
                                   if (res.isSuccess()) {                                      
                                     for(Address_vod__c chldAdd : [SELECT Id,Name,Account_vod__r.IsPersonAccount FROM Address_vod__c WHERE Account_vod__c= :res.getId() and Account_vod__r.IsPersonAccount=false]){   
                                         chldAdd.Name=chldAdd.Name;
                                         listChildAdd.add(chldAdd);
                                       }
                                       tempWinnerAccount.id = res.getId();
                                       if(tempWinnerAccount.IsMerged_AGN__c == true)
                                       {
                                       winnerAccountList.add(tempWinnerAccount);
                                       }
                                       System.debug('Master record ID: ' + res.getId());
                                       System.debug('Reparented record ID: ' + res.getUpdatedRelatedIds());
                                       
                                       // Get the IDs of the merged records and display them
                                       List<Id> mergedIds = res.getMergedRecordIds();
                                       System.debug('IDs of merged records: ' + mergedIds);
                                       for(Id mrId: mergedIds){  
                                           if(!mapLooserIdToMrId.isEmpty() && mapLooserIdToMrId.containsKey(mrId)){
                                               System.debug('inside try after merge. change status to complete');
                                               Merge_Parent_AGN__c mrRec = mapLooserIdToMrId.get(mrId);
                                               if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Status_AGN__c.isUpdateable()){     // swar cc  
                                                mrRec.Merge_Status_AGN__c ='COMPLETED';
                                               }
                                               mapMergeResultToUpdate.put(mrRec.Id,mrRec);
                                           }
                                       }//loop_ends 
                                   }
                                   else{
                                       List<Database.Error> errList = res.getErrors();
                                       Database.Error err = errList.get(0);
                                       // print error message in merge error field
                                       System.debug('error::  '+err.getMessage());
                                       Id mrId = tempLooserRecIdList.get(0);
                                       if(!mapLooserIdToMrId.isEmpty()){
                                           System.debug('inside else after merge record failed ');
                                           Merge_Parent_AGN__c mrRec = mapLooserIdToMrId.get(mrId);
                                           if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Status_AGN__c.isUpdateable()){     // swar cc  
                                            mrRec.Merge_Status_AGN__c ='FAILED';
                                           }
                                           if(Schema.sObjectType.Merge_Parent_AGN__c.fields.Merge_Error_Details_AGN__c.isUpdateable()){     // swar cc  
                                            mrRec.Merge_Error_Details_AGN__c = err.getMessage();
                                           }
                                           mapMergeResultToUpdate.put(mrRec.Id,mrRec);
                                       }           
                                   }
                               }
                               Catch(DMLException e) {
                                   system.debug('The following exception has occured:'+e.getMessage());
                               }
                           }
                       }
                   }
            }//loop_ends
            
            if(!mapMergeResultToUpdate.isEmpty()){
                System.debug('mapMergeResultToUpdate Size::'+ mapMergeResultToUpdate.values());
                if(Merge_Parent_AGN__c.sObjectType.getDescribe().isUpdateable()){     // swar cc  
                    update mapMergeResultToUpdate.values();
                }
            }
            if(!winnerAccountList.isEmpty()){
                System.debug('winnerAccountListSize::::::'+winnerAccountList.size());
                for(Account tempAccount: winnerAccountList){
                    AGN_typeConversionUtil.setIsMergedToFalse(tempAccount);
                }
                if(Account.sObjectType.getDescribe().isUpdateable()){     // swar cc  
                    update winnerAccountList;
                }
            }
            if(!listChildAdd.isEmpty()){
                System.debug('listChildAdd Size::'+ listChildAdd.size());
                if(Address_vod__c.sObjectType.getDescribe().isUpdateable()){     // swar cc  
                    update listChildAdd;
                }
            }
        }
    }
    public void finish(Database.BatchableContext context) {
        
        //execute batch to update External IDs of merged Accounts
        database.executeBatch(new AGN_AccountExtID(),1);
        //execute the batch class to push data to gigya, based on @vars@ list
        database.executeBatch(new  AGNGigyaAccountChannelChangedBatch(vars));
        
    }
}