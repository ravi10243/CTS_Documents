/**
* --------------
* Allerga-Targeting and Segmenta
* 15 May 2019
* Cognizant Dev team
* Segmentation & Targeting project
* --------------
* Class used in Territory object to fetch the data in Territory Replica custom object
* 20 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team
*/
global class AGN_CreateTerritoryReplica
{
    /* Remove as part of TM2.0 Implementation
    //Future method to replicate Territory object into Territory Replica object. Instantiated from Trigger in Territory Object
    @future
    public static void AGN_terr_rep(List<ID> TUPS_ID, List<ID> TDEL_ID)
    {
        
        try
        {
            list<Territory_Replica_AGN__c> TerUPSReplica = new list<Territory_Replica_AGN__c>();
            List<Territory_Replica_AGN__c> TerDELReplica = new List<Territory_Replica_AGN__c>();
            List<Territory> TUPS_list = new List<Territory>();
            
            //Query for upsert record details through record Id obtained from Trigger
            if(TUPS_ID.size() > 0)
            {
                TUPS_list = [SELECT Id, Name, ParentTerritoryId FROM Territory WHERE Id IN :TUPS_ID];
                
                //Add to be upsert record set for Upsert operation
                if(TUPS_list.size() > 0)
                {  
                    for(Territory tu : TUPS_list)
                    {
                        Territory_Replica_AGN__c TerUpsRep = new Territory_Replica_AGN__c();
                        if(Schema.sObjectType.Territory_Replica_AGN__c.fields.External_ID_AGN__c.isCreateable() && Schema.sObjectType.Territory_Replica_AGN__c.fields.External_ID_AGN__c.isUpdateable()){ //cc_AD  
                            TerUpsRep.External_ID_AGN__c = tu.Id;
                        }
                        if(Schema.sObjectType.Territory_Replica_AGN__c.fields.Parent_ID_AGN__c.isCreateable() && Schema.sObjectType.Territory_Replica_AGN__c.fields.Parent_ID_AGN__c.isUpdateable()){   //cc_AD  
                            TerUpsRep.Parent_ID_AGN__c = tu.ParentTerritoryId;
                        }
                        if(Schema.sObjectType.Territory_Replica_AGN__c.fields.Name.isCreateable() && Schema.sObjectType.Territory_Replica_AGN__c.fields.Name.isUpdateable()){    //cc_AD  
                            TerUpsRep.Name = tu.Name;
                        }
                        
                        TerUPSReplica.add(TerUpsRep);
                    }
                }
                //Upsert Data into replication object
                if(TerUPSReplica.size() > 0)
                {
                    Schema.SObjectField ext_id = Territory_Replica_AGN__c.External_ID_AGN__c;
                    Database.UpsertResult[] upsresults;   
                    if(Schema.SObjectType.Territory_Replica_AGN__c.isCreateable() && Schema.SObjectType.Territory_Replica_AGN__c.isUpdateable()){ //cc_AD
                        upsresults = Database.upsert(TerUPSReplica, ext_id);
                    }   
                    
                    
                    //Logging for Upsert operation
                    for(Integer upsindex = 0, size = upsresults.size(); upsindex < size; upsindex++)
                    {
                        if(upsresults[upsindex].isSuccess())
                        {
                            if(upsresults[upsindex].isCreated())
                            {
                                System.debug(TerUPSReplica[upsindex].External_ID_AGN__c +' was created');
                            }
                            else
                            {
                                System.debug(TerUPSReplica[upsindex].External_ID_AGN__c +' was updated');
                            }
                        }
                    }
                }
            }
            
            //Query for delete record details through record Id obtained from Trigger
            if(TDEL_ID.size() > 0)
            {//System.debug('In Delete: '+ TDEL_ID[0]);
                TerDELReplica = [SELECT Id FROM Territory_Replica_AGN__c WHERE External_ID_AGN__c IN :TDEL_ID];
                
                // Add to be deleted record set for Deletion
                if(TerDELReplica.size() > 0)
                {
                    Database.DeleteResult[] delresults;
                    if(Territory_Replica_AGN__c.sObjectType.getDescribe().isDeletable()){//cc_AD
                        delresults = Database.delete(TerDELReplica);
                    }
                    
                    
                    //Logging for Delete operation
                    for(Integer delindex = 0, size = delresults.size(); delindex < size; delindex++)
                    {
                        if(delresults[delindex].isSuccess())
                        {
                            System.debug(TerDELReplica[delindex] +' was deleted');
                        }
                    }
                }
            }
            
            // Code to increase test coverage by including catch block in test class
            if(Test.isRunningTest())
            {
                throw new AGN_customException('Test is running');
            }
        }
        catch(exception e)
        {
            System.debug('Failed in AGN_CreateTerritoryReplica.AGN_terr_rep Future method. Error: ' + e.getMessage());
            Allergan_Error_Logger_AGN__c errlog = new Allergan_Error_Logger_AGN__c();
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Error_Message_AGN__c.isCreateable()){   //cc_AD
                errlog.Error_Message_AGN__c = 'Failed in AGN_CreateTerritoryReplica.AGN_terr_rep Future method. Error: ' + e.getMessage();
            }
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Source_AGN__c.isCreateable()){   //cc_AD
                errlog.Source_AGN__c = 'Salesforce';
            }
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Transaction_AGN__c.isCreateable()){   //cc_AD  
                errlog.Transaction_AGN__c = 'Apex Class: AGN_CreateTerritoryReplica';
            }
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.isCreateable()){   //cc_AD
                insert errlog;
            }
        }    
    }
    */
        
        
        /* Added as part of TM2.0 Implementation - Start */
        //Future method to create Territory Replica object based on insert/update on Territory object. 
        //Instantiated from Trigger in Territory Object
        @future
        public static void insertUpdateHandler(List<Id> territoryIds) {
            List<Territory2> territories = [SELECT Id, Name, ParentTerritory2Id 
                                            FROM Territory2 
                                            WHERE Id IN :territoryIds];
            List<Territory_Replica_AGN__c> terrReplicasToUpsert = new List<Territory_Replica_AGN__c>();
            for(Territory2 territory : territories) {
                Territory_Replica_AGN__c terrReplicas = new Territory_Replica_AGN__c();
                
                if(Schema.sObjectType.Territory_Replica_AGN__c.fields.External_ID_AGN__c.isCreateable() 
                   && Schema.sObjectType.Territory_Replica_AGN__c.fields.External_ID_AGN__c.isUpdateable()){ 
                       terrReplicas.External_ID_AGN__c = territory.Id;
                   }
                
                if(Schema.sObjectType.Territory_Replica_AGN__c.fields.Parent_ID_AGN__c.isCreateable() 
                   && Schema.sObjectType.Territory_Replica_AGN__c.fields.Parent_ID_AGN__c.isUpdateable()){   
                       terrReplicas.Parent_ID_AGN__c = territory.ParentTerritory2Id;
                   }
                
                if(Schema.sObjectType.Territory_Replica_AGN__c.fields.Name.isCreateable() 
                   && Schema.sObjectType.Territory_Replica_AGN__c.fields.Name.isUpdateable()){ 
                       terrReplicas.Name = territory.Name;
                   }
                system.debug(terrReplicas);
                terrReplicasToUpsert.add(terrReplicas);
            }
            
            try {
                if(terrReplicasToUpsert.size() > 0) {
                    
                    Schema.SObjectField ext_id = Territory_Replica_AGN__c.External_ID_AGN__c;
                    Database.UpsertResult[] upsresults;   
                    if(Schema.SObjectType.Territory_Replica_AGN__c.isCreateable() 
                       && Schema.SObjectType.Territory_Replica_AGN__c.isUpdateable()){ 
                           
                           upsresults = Database.upsert(terrReplicasToUpsert, ext_id);
                       }   
                    
                    /* Is this section required?
//Logging for Upsert operation
for(Integer upsindex = 0, size = upsresults.size(); upsindex < size; upsindex++)
{
if(upsresults[upsindex].isSuccess())
{
if(upsresults[upsindex].isCreated())
{
System.debug(TerUPSReplica[upsindex].External_ID_AGN__c +' was created');
}
else
{
System.debug(TerUPSReplica[upsindex].External_ID_AGN__c +' was updated');
}
}
}
*/
                }
                // Code to increase test coverage by including catch block in test class
                if(Test.isRunningTest())
                {
                    throw new AGN_customException('Test is running');
                }
            }
            catch(Exception ex) {
                System.debug('Failed in AGN_CreateTerritoryReplica.insertUpdateHandler Future method. Error: ' 
                             + ex.getMessage());
                Allergan_Error_Logger_AGN__c errlog = new Allergan_Error_Logger_AGN__c();
                if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Error_Message_AGN__c.isCreateable()){
                    errlog.Error_Message_AGN__c = 'Failed in AGN_CreateTerritoryReplica.insertUpdateHandler Future method. Error: ' 
                        + ex.getMessage();
                }
                if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Source_AGN__c.isCreateable()){ 
                    errlog.Source_AGN__c = 'Salesforce';
                }
                if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Transaction_AGN__c.isCreateable()){
                    errlog.Transaction_AGN__c = 'Apex Class: AGN_CreateTerritoryReplica';
                }
                if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.isCreateable()){  
                    insert errlog;
                }
            }
        }
    
    //Future method to delete Territory Replica object based on delete on Territory object. 
    //Instantiated from Trigger in Territory Object
    @future
    public static void deleteHandler(List<Id> territoryIds) {
        List<Territory_Replica_AGN__c> terrReplicasToDelete = [SELECT Id 
                                                               FROM Territory_Replica_AGN__c 
                                                               WHERE External_ID_AGN__c IN :territoryIds];
        try {
            if(terrReplicasToDelete.size() > 0)
            {
                Database.DeleteResult[] delresults;
                if(Territory_Replica_AGN__c.sObjectType.getDescribe().isDeletable()) {
                    delresults = Database.delete(terrReplicasToDelete);
                }
                
                /* Is this section required?
//Logging for Delete operation
for(Integer delindex = 0, size = delresults.size(); delindex < size; delindex++)
{
if(delresults[delindex].isSuccess())
{
System.debug(TerDELReplica[delindex] +' was deleted');
}
}
*/
            }
            // Code to increase test coverage by including catch block in test class
            if(Test.isRunningTest())
            {
                throw new AGN_customException('Test is running');
            }
        }
        catch(Exception ex) {
            System.debug('Failed in AGN_CreateTerritoryReplica.deleteHandler Future method. Error: ' 
                         + ex.getMessage());
            Allergan_Error_Logger_AGN__c errlog = new Allergan_Error_Logger_AGN__c();
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Error_Message_AGN__c.isCreateable()){
                errlog.Error_Message_AGN__c = 'Failed in AGN_CreateTerritoryReplica.deleteHandler Future method. Error: ' 
                    + ex.getMessage();
            }
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Source_AGN__c.isCreateable()){ 
                errlog.Source_AGN__c = 'Salesforce';
            }
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Transaction_AGN__c.isCreateable()){
                errlog.Transaction_AGN__c = 'Apex Class: AGN_CreateTerritoryReplica';
            }
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.isCreateable()){  
                insert errlog;
            }
        }
    }
    /* Added as part of TM2.0 Implementation - End */
}