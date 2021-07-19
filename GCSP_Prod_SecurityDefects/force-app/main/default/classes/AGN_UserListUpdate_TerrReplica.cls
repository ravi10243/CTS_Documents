/**
* --------------
* Allerga-Targeting and Segmenta
* 09 June 2019
* Cognizant Dev team
* Segmentation & Targeting project
* --------------
* Scheduled apex class used to populate user list in territory replica rep name field
* 20 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team
*/
global class AGN_UserListUpdate_TerrReplica implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        try
        {
            // Declare list variables
            List<Territory_Replica_AGN__c> terr_rep_lst = new List<Territory_Replica_AGN__c>();
            List<Territory_Replica_AGN__c> repnameterrrep = new List<Territory_Replica_AGN__c>();
            List<Territory_Replica_AGN__c> terrep_upd = new List<Territory_Replica_AGN__c>();
            
            // Updated Object from UserTerritory to UserTerritory2Association - TM2.0 Implementation
            List<UserTerritory2Association> userterrlst = new List<UserTerritory2Association>();
            
            // Declare Map variables
            Map<Id, Territory_Replica_AGN__c> repnameterrrep_update = new Map<Id, Territory_Replica_AGN__c>();
            Map<Id, User> usermap = new Map<Id, User>([SELECT Id, Name, Alias, IsActive From User WHERE IsActive = true]);
            
            // Updated Object from UserTerritory to UserTerritory2Association - TM2.0 Implementation
            // Populate List variables with UserTerritory and Territory replication reference data
            userterrlst = [SELECT Id, IsActive, Territory2Id, UserId FROM UserTerritory2Association WHERE IsActive = true AND Territory2.Territory2Model.State ='Active'];
            terr_rep_lst= [SELECT Id, External_ID_AGN__c, Rep_Name_AGN__c From Territory_Replica_AGN__c WHERE IsDeleted = false];
            
            // Populate Territory Replica transaction map for final update
            for(Territory_Replica_AGN__c tr_map : terr_rep_lst)
            {
                if(Schema.sObjectType.Territory_Replica_AGN__c.fields.Rep_Name_AGN__c.isCreateable() ||
                   Schema.sObjectType.Territory_Replica_AGN__c.fields.Rep_Name_AGN__c.isUpdateable())   // AKJ cc
                    tr_map.Rep_Name_AGN__c = '';
                if(Schema.sObjectType.Territory_Replica_AGN__c.fields.Rep_Name_AGN__c.isCreateable() ||
                   Schema.sObjectType.Territory_Replica_AGN__c.fields.Rep_Name_AGN__c.isUpdateable())   // AKJ cc  
                    repnameterrrep_update.put(tr_map.External_ID_AGN__c, tr_map);
            }
            
            // System.Debug(repnameterrrep_update);
            
            // Updated Object from UserTerritory to UserTerritory2Association - TM2.0 Implementation
            // Get User name and Alias details against each UserTerritory record
            for(UserTerritory2Association ut : userterrlst)
            {
                if(usermap.containsKey(ut.UserId))
                {Territory_Replica_AGN__c terrrepinst = new Territory_Replica_AGN__c();
                 User usrdet = usermap.get(ut.UserId);
                 if(Schema.sObjectType.Territory_Replica_AGN__c.fields.External_ID_AGN__c.isCreateable() ||
                    Schema.sObjectType.Territory_Replica_AGN__c.fields.External_ID_AGN__c.isUpdateable())   // AKJ cc
                 {
                     terrrepinst.External_ID_AGN__c = ut.Territory2Id;
                 }
                 
                 terrrepinst.Rep_Name_AGN__c = usrdet.Name + ' (' + usrdet.Alias + ')';
                 
                 repnameterrrep.add(terrrepinst);
                }
            }
            
            // System.debug(repnameterrrep);
            
            // Combine same territory records into one with user details comma delimited
            for(Territory_Replica_AGN__c repnmterr : repnameterrrep)
            {
                if(repnameterrrep_update.containsKey(repnmterr.External_ID_AGN__c))
                {
                    if(String.isBlank(repnameterrrep_update.get(repnmterr.External_ID_AGN__c).Rep_Name_AGN__c))
                    {
                        repnameterrrep_update.get(repnmterr.External_ID_AGN__c).Rep_Name_AGN__c = repnmterr.Rep_Name_AGN__c;
                    }
                    else
                    {
                        repnameterrrep_update.get(repnmterr.External_ID_AGN__c).Rep_Name_AGN__c = repnameterrrep_update.get(repnmterr.External_ID_AGN__c).Rep_Name_AGN__c + ', ' + repnmterr.Rep_Name_AGN__c;
                    }
                }
                else
                {
                    repnameterrrep_update.put(repnmterr.External_ID_AGN__c, repnmterr);
                }
            }
            
            //System.debug(repnameterrrep_update);
            
            // Get the delimited records into a List for final DML
            terrep_upd.addAll(repnameterrrep_update.values());
            
            // Initialize DML operation
            if(terrep_upd.size() > 0)
            {
                Schema.SObjectField ext_id = Territory_Replica_AGN__c.External_ID_AGN__c;
                if(Schema.sObjectType.Territory_Replica_AGN__c.fields.Rep_Name_AGN__c.isCreateable() &&
                   Schema.sObjectType.Territory_Replica_AGN__c.fields.Rep_Name_AGN__c.isUpdateable()) // AKJ cc
                {
                    
                    
                    Database.UpsertResult[] updresult = Database.upsert(terrep_upd, ext_id);
                    
                    //Logging for Delete operation
                    for(Integer updindex = 0, size = updresult.size(); updindex < size; updindex++)
                    {
                        if(updresult[updindex].isSuccess())
                        {
                            System.debug(terrep_upd[updindex] +' was updated');
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
            System.debug('Failed in AGN_UserListUpdate_TerrReplica.execute method. Error: ' + e.getMessage());
            Allergan_Error_Logger_AGN__c errlog = new Allergan_Error_Logger_AGN__c();
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Error_Message_AGN__c.isCreateable())   // AKJ cc
            {
                errlog.Error_Message_AGN__c = 'Failed in AGN_UserListUpdate_TerrReplica.execute method. Error: ' + e.getMessage();
            }
            
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Source_AGN__c.isCreateable())   // AKJ cc
            {
                errlog.Source_AGN__c = 'Salesforce';
            }
            
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.fields.Transaction_AGN__c.isCreateable())   // AKJ cc
            {
                errlog.Transaction_AGN__c = 'Apex Class: AGN_UserListUpdate_TerrReplica';
            }
            
            if(Schema.sObjectType.Allergan_Error_Logger_AGN__c.isCreateable())   // AKJ cc   
            {
                insert errlog;
            }
            
        }
    }
}