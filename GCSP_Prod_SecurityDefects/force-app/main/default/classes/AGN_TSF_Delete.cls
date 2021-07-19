/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant
* @Name           AGN_TSF_Delete
* @version        1.0
* @created        2020-09-28
* @modified       2020-11-13 (SG)   
* 		  2020-11-23 (AB)
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes   
   PMO 3661: TSF Deletion Job Logic Change.
   23 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team
*/

public class AGN_TSF_Delete implements Database.Batchable<SObject> {
  /* Start Method 
*  Scope is TSF_vod__c
*/   
    public Database.QueryLocator start(Database.BatchableContext context){
        Set<String> countryCodeSet = new Set<String>(); 
        Set<String> territoryNameSet = new Set<String>();
        
        //Retrieving Country code from AGN_Offline_Account_Load__mdt metadata.
		for(AGN_Offline_Account_Load__mdt acTL:[SELECT AGN_Country_Code__c FROM AGN_Offline_Account_Load__mdt]){            
            countryCodeSet.add(String.escapeSingleQuotes(acTL.AGN_Country_Code__c));
        }
        
        //Retrieving Territory Name by filtering with the country code.
        for(Territory2 tr:[SELECT Id,Country_Code_AGN__c,Name FROM Territory2 WHERE Country_Code_AGN__c IN :countryCodeSet]){
            territoryNameSet.add(String.escapeSingleQuotes(tr.Name));
        }
        
        //Retrieving TSF record by filtering with the Territory Name and LastmodifiedDate
         // string tsfQuery = 'SELECT Account_vod__c,External_Id_vod__c,Id,Name,Territory_vod__c,LastModifiedDate,IsDeleted FROM TSF_vod__c  where ' + System.Label.AGN_TSF_Insert_Batch_Job_Date + ' and  Territory_vod__c IN : territoryNameSet and IsDeleted = FALSE';
 		//PMO 3661: Remove Last modified data from where clause. 
         string tsfQuery = 'SELECT Account_vod__c,External_Id_vod__c,Id,Name,Territory_vod__c,LastModifiedDate,My_Target_vod__c,IsDeleted FROM TSF_vod__c  where Territory_vod__c IN : territoryNameSet and IsDeleted = FALSE and My_Target_vod__c = False';

        return Database.getQueryLocator(String.escapeSingleQuotes(tsfQuery));
    }
    
    public void execute(Database.BatchableContext context, List<TSF_vod__c> scope){
        
        String ExternalID;
        Set<String> grpIds = new Set<String>();
        Map<String,Id> terrAccMap = new Map<String,Id>();
        Map<id,String> grpTerritoryMap = new Map<id,String>();
		Set<String> tsfAccountIdSet = new Set<String>(); 
        Set<String> ExterNalIdSet = new Set<String>(); 
        Set<String> externalIdforDeleteTsf = new Set<String>();
        
        try
        {
         //Storing Account Id in Set and TSF External Id in an another set from TSF object.
        for(TSF_vod__c tsfDeleteList : scope){			
			tsfAccountIdSet.add(tsfDeleteList.Account_vod__c);
            externalIdforDeleteTsf.add(tsfDeleteList.External_Id_vod__c); // super set
		  }    
       	
        // Removed as part of TM2.0 Implementation
        // Storing  Group Id in a set from AccountShare Object
        /* for(ObjectTerritory2Association accShare:[select ObjectId,Id,AssociationCause,Territory2Id,IsDeleted from ObjectTerritory2Association     
                                                  where IsDeleted = False and ObjectId in  :tsfAccountIdSet and AssociationCause = 'Territory2AssociationManual']){          
			grpIds.add(accShare.Territory2Id);
        }
         
        //Storing Territory Name in a Map from Group object  where Key = Group ID
        for(Group grp :[Select Id,RelatedId,Related.Name from group where Id in:grpIds]){
            grpTerritoryMap.put(grp.Id,grp.Related.Name);
        }   
        */
        //Storing Account Id in a Map from ObjectTerritory2Association Object where Key = TSF External key.
            for(ObjectTerritory2Association accShare:[select ObjectId,Id,AssociationCause,Territory2Id,Territory2.Name,IsDeleted from ObjectTerritory2Association                                       
                                                      where ObjectId in  :tsfAccountIdSet 
                                                      and IsDeleted = False
                                                      and AssociationCause = 'Territory2Manual']){
            	// Condition removed as part of TM2.0 Implementation
            	// if(grpTerritoryMap.containsKey(accShare.UserOrGroupId)){
            	ExternalID = accShare.ObjectId +'__'+ accShare.Territory2.Name;
            	terrAccMap.put(ExternalID, accShare.ObjectId); // parentset
          	//}
        }
          
	  //Checking ExterIds of TSF for which Record not present in AccountShare Object. 
        for(String s:externalIdforDeleteTsf){
            if(!terrAccMap.containsKey(s)){
               ExterNalIdSet.add(s); 
            }
        }
        
      //Final Delete list of TSF
       List<TSF_vod__c> tsfDeleteFinalSet =[SELECT Id,Account_vod__c,External_Id_vod__c,IsDeleted FROM TSF_vod__c where IsDeleted = False and External_Id_vod__c IN  :ExterNalIdSet];
            
              Set<String> exterIdSet = new Set<String>();    
        if(tsfDeleteFinalSet.size()>0){
          if(TSF_vod__c.sObjectType.getDescribe().isDeletable()){
            Database.DeleteResult[] srList =Database.Delete(tsfDeleteFinalSet, false);
            String errMsg='TSF Delete Failure for the below ExternalId \n';
              for(Integer i=0; i<srList.size();i++){
                  if(!srList.get(i).isSuccess()){
                     exterIdSet.add(tsfDeleteFinalSet[i].External_Id_vod__c);
                  }
              }
              if(exterIdSet.size()>0){
               errMsg=errMsg +JSON.serialize(exterIdSet);
              // IF delete opeartion fail , then corresponding details will store as a record of  AGN_Error_Logger object.
              AGN_Error_Logger.createExceptionsLog(null,'AGN_TSF_Delete','execute',errMsg);
              }
          } 
        }
        }Catch(Exception ex){
            AGN_Error_Logger.createExceptionsLog(ex,'AGN_TSF_Delete','execute','TSF Delete Failure from Batch');
        }
		
    }
    
     public void finish(Database.BatchableContext context) 
    {
        
    }
    

}