/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant
* @Name           AGN_TSF_Insert
* @version        1.0
* @created        2020-09-28
* @modified       2020-11-13 (SG)
* @modified       2020-11-23 (AB)
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes 
  PMO 3661: TSF Deletion Job Logic Change.
  23 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team
*/


public class AGN_TSF_Insert implements Database.Batchable<SObject> {
 /* Start Method 
*  Scope is AccountShare
	23 Nov 2020 - Scope updated to ObjectTerritory2Association - TM2.0 Implementation
*/
    public Database.QueryLocator start(Database.BatchableContext context){
        Set<String> countryCodeSet = new Set<String>();
        Set<String> territoryIDSet = new Set<String>();
        Set<String> groupIDSet = new Set<String>();      
        //23 Nov 2020 - Value updated as per new model - TM2.0 Implementation
        //String rowcauseValue='TerritoryManual';
        String rowcauseValue='Territory2Manual';
        
        //Retrieving Country code from AGN_Offline_Account_Load__mdt metadata.
        for(AGN_Offline_Account_Load__mdt acTL:[SELECT AGN_Country_Code__c FROM AGN_Offline_Account_Load__mdt]){            
            countryCodeSet.add(String.escapeSingleQuotes(acTL.AGN_Country_Code__c));
        }
        
        //Retrieving Territory ID by filtering with the country code.
        for(Territory2 tr:[SELECT Id,Country_Code_AGN__c FROM Territory2 WHERE Country_Code_AGN__c IN :countryCodeSet]){
            territoryIDSet.add(tr.Id);
        }
        
        // Removed as part of TM2.0 Implementation
        //Retrieving Group ID by filtering with the Territory ID
        /*for(Group grp:[SELECT Id,RelatedId FROM Group WHERE RelatedId IN :territoryIDSet]){
            groupIDSet.add(grp.Id);
        }*/
        
        // Retrieving ObjectTerritory2Association data by filtering with Lastmodified date, Rowcause and UserGroupId.
        string acctShrQuery = 'select ObjectId,LastModifiedDate,Territory2Id, Territory2.Name,AssociationCause,IsDeleted from ObjectTerritory2Association where ' + System.Label.AGN_TSF_Insert_Batch_Job_Date + ' and  Territory2Id IN : territoryIDSet and AssociationCause =:rowcauseValue and IsDeleted = FALSE';
        return Database.getQueryLocator(String.escapeSingleQuotes(acctShrQuery));
    }
    
    public void execute(Database.BatchableContext context, List<ObjectTerritory2Association> scope){
        String ExternalID;
        List<TSF_vod__c> tsfListFinal = new List<TSF_vod__c>();
        Map<String,Id> terrAccMap = new Map<String,Id>();
        Map<String,ID> tsfMap = new Map<String,ID>();       
        Set<String> terrIds = new Set<String>();
        Map<id,String> grpTerritoryMap = new Map<id,String>();
        
        try
        //Storing group ID in a Set from ObjectTerritory2Association Object 
        {
            for(ObjectTerritory2Association accShare:scope){          
                terrIds.add(accShare.Territory2Id);
            }
            // Removed as part of TM2.0 Implementation
            //Storing Territory name in a Map where Key = GroupId
            /*for(Group grp :[Select Id,RelatedId,Related.Name from group where Id in:grpIds]){
				grpTerritoryMap.put(grp.Id,grp.Related.Name);
			}*/
            
            //Storing value in this Map where Key = TSF External ID and Value = Account ID
            for(ObjectTerritory2Association accShare:scope){
                // Condition Removed as part of TM2.0 Implementation
                //if(grpTerritoryMap.containsKey(accShare.Territory2Id)){
                ExternalID = accShare.ObjectId +'__'+ accShare.Territory2.Name;
                terrAccMap.put(ExternalID, accShare.ObjectId); // parentset
                //}
            }
            //Storing value in this Map where Key = TSF External ID and Value = TSF ID    
            for(TSF_vod__c tsfList :[Select Account_vod__c,Id,Target_Manager_SMB__c,Name,Territory_vod__c,External_Id_vod__c,IsDeleted from TSF_vod__c where IsDeleted = False and External_Id_vod__c in :terrAccMap.keySet()]){
                tsfMap.put(tsfList.External_Id_vod__c,tsfList.id); //subset
            }
        
      		//Checking TSF record present for an Account. If record is not present then will create TSF record.
        	for(String str :terrAccMap.keySet()){
                if(!tsfMap.containsKey(str)){
                TSF_vod__c ts = new TSF_vod__c();
                if(Schema.sObjectType.TSF_vod__c.fields.Account_vod__c.isCreateable()){
                  ts.Account_vod__c=terrAccMap.get(str);
                }
                if(Schema.sObjectType.TSF_vod__c.fields.Target_Manager_SMB__c.isCreateable()){
                  ts.Target_Manager_SMB__c=True;
                }
                if(Schema.sObjectType.TSF_vod__c.fields.Territory_vod__c.isCreateable()){
                  ts.Territory_vod__c=str.substringAfter('__');
                }
                if(Schema.sObjectType.TSF_vod__c.fields.Name.isCreateable()){
                  ts.Name=str.substringAfter('__');
                }
                  tsfListFinal.add(ts);
              }
        }
        Set<String> exterIdSet = new Set<String>();    
        if(tsfListFinal.size()>0){
          if(Schema.sObjectType.TSF_vod__c.isCreateable()){
            //insert tsfListFinal;
            Database.SaveResult[] srList =Database.insert(tsfListFinal, false);
            String errMsg='TSF Insert Failure for the below ExternalId \n';
              for(Integer i=0; i<srList.size();i++){
                  if(!srList.get(i).isSuccess()){
                     exterIdSet.add(tsfListFinal[i].Account_vod__c +'__'+tsfListFinal[i].Territory_vod__c);
                  }
              }
              if(exterIdSet.size()>0){
               errMsg=errMsg +JSON.serialize(exterIdSet);
              // IF insert operation fail , then corresponding details will store as a record of  AGN_Error_Logger object.
              AGN_Error_Logger.createExceptionsLog(null,'AGN_TSF_Insert','execute',errMsg);
              }
          } 
        }
        }Catch(Exception ex){
             AGN_Error_Logger.createExceptionsLog(ex,'AGN_TSF_Insert','execute','TSF Insert Failure from Batch');
        }
    
    }
    
     public void finish(Database.BatchableContext context) 
    {
        //PMO 3661: Reduce batch size from 200 to 50.
        Database.executeBatch(new AGN_TSF_Delete(),50);
    }
    
}