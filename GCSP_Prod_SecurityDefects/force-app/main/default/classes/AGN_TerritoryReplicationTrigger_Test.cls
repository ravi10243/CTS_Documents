/**
* --------------
* Allerga-Targeting and Segmenta
* 15 May 2019
* Cognizant Dev team
* Segmentation & Targeting project
* --------------
* Test Class used for AGN_CreateTerritoryReplica
* 20 Nov 2020 - Class is update to reflect changes for TM 1.0 to TM 2.0 Migration - Cognizant Dev Team
*/
@isTest
private class AGN_TerritoryReplicationTrigger_Test
{
    @isTest static void AGN_testTerritoryInsert()
    {
        Territory2Model t2m = [SELECT Id FROM Territory2Model LIMIT 1];
        Territory2Type t2t = [SELECT Id FROM Territory2Type LIMIT 1];
        Integer numTerrs = 10;
        // Updated Object from Territory to Territory2 - TM2.0 Implementation
        //Territory Insert test
        List<Territory2> terrs = new List<Territory2>();
        
        
        For(Integer i=0; i<numTerrs; i++)
        {
            // Updated Object from Territory to Territory2 and added Territory2ModelId, Territory2TypeId fields - TM2.0 Implementation
            Territory2 ti = new Territory2(Name='TestTerritory_RD_' + i,
                                           DeveloperName='TestTerritory_RD_' + i,
                                           Territory2ModelId = t2m.Id, 
                                           Territory2TypeId = t2t.Id);
            terrs.add(ti);
        }
        
        //Start test
        Test.startTest();
        Database.SaveResult[] saveresult = Database.insert(terrs);
        Test.stopTest();
        
        //Check records
        For (Database.SaveResult sr : saveresult)
        {
            If (sr.isSuccess())
            {
                System.debug('Successfully inserted territory. Territory ID: ' + sr.getId());
            }
            Else
            {
                for(Database.Error err : sr.getErrors())
                {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Territory fields that affected this error: ' + err.getFields());
                }
            }
        }
        List<Territory_Replica_AGN__c> TR_CHK = [SELECT Id, Name FROM Territory_Replica_AGN__c WHERE Name LIKE 'TestTerritory_RD_%'];
        If(TR_CHK.size() == numTerrs)
        {
            System.debug('Insert counts match!');
        }
    }
    
    /******************************************************************************************************/
    /******************************************************************************************************/
    
    @isTest static void AGN_testTerritoryUpdate()
    {
        Territory2Model t2m = [SELECT Id FROM Territory2Model LIMIT 1];
        Territory2Type t2t = [SELECT Id FROM Territory2Type LIMIT 1];
        
        Integer numTerrsu = 10;
        
        // Updated Object from Territory to Territory2 - TM2.0 Implementation
        //Territory Update test
        List<Territory2> terrs_ins = new List<Territory2>();
        
        
        For(Integer i=0; i<numTerrsu; i++)
        {
            // Updated Object from Territory to Territory2 and added Territory2ModelId, Territory2TypeId fields - TM2.0 Implementation
            Territory2 ti = new Territory2(Name='TestTerritory_RD_' + i, 
                                           DeveloperName='TestTerritory_RD_' + i,
                                           Territory2ModelId = t2m.Id, 
                                           Territory2TypeId = t2t.Id);
            terrs_ins.add(ti);
        }
        Database.insert(terrs_ins);
        
        // Updated Object from Territory to Territory2 - TM2.0 Implementation
        List<Territory2> terrs_upd = new List<Territory2>();
        List<Territory2> TR_UPD = [SELECT Id, Name FROM Territory2 WHERE Name LIKE 'TestTerritory_RD_%'];
        For(Territory2 tu : TR_UPD)
        {
            tu.Name = 'TestUpdateTerritory_RD_%';
            terrs_upd.add(tu);
        }
        
        //Start test
        Test.startTest();
        Database.SaveResult[] saveupdresult = Database.update(terrs_upd);
        Test.stopTest();
        
        //Check records
        For (Database.SaveResult su : saveupdresult)
        {
            If (su.isSuccess())
            {
                System.debug('Successfully updated territory. Territory ID: ' + su.getId());
            }
            Else
            {
                for(Database.Error erru : su.getErrors())
                {
                    System.debug('The following error has occurred.');
                    System.debug(erru.getStatusCode() + ': ' + erru.getMessage());
                    System.debug('Territory fields that affected this error: ' + erru.getFields());
                }
            }
        }
        List<Territory_Replica_AGN__c> TRU_CHK = [SELECT Id, Name FROM Territory_Replica_AGN__c WHERE Name LIKE 'TestUpdateTerritory_RD_%'];
        If(TRU_CHK.size() == numTerrsu)
        {
            System.debug('Update counts match!');
        }
    }
    
    /******************************************************************************************************/
    /******************************************************************************************************/
    
    @isTest static void AGN_testTerritoryDelete()
    {
        Territory2Model t2m = [SELECT Id FROM Territory2Model LIMIT 1];
        Territory2Type t2t = [SELECT Id FROM Territory2Type LIMIT 1];
        Integer numTerrs = 10;
        // Updated Object from Territory to Territory2 - TM2.0 Implementation
        //Territory Insert test
        List<Territory2> terrs_id = new List<Territory2>();
        
        For(Integer i=0; i<numTerrs; i++)
        {
            // Updated Object from Territory to Territory2 and added Territory2ModelId, Territory2TypeId fields - TM2.0 Implementation
            Territory2 ti = new Territory2(Name='TestTerritory_RD_' + i,
                                           DeveloperName='TestTerritory_RD_' + i,
                                           Territory2ModelId = t2m.Id, 
                                           Territory2TypeId = t2t.Id);
            terrs_id.add(ti);
        }
        Database.insert(terrs_id);
        
        // Updated Object from Territory to Territory2 - TM2.0 Implementation
        //Territory Delete test
        List<Territory2> TR_DEL = [SELECT Id FROM Territory2 WHERE Name LIKE 'TestTerritory_RD_%'];
        
        //Start test
        Test.startTest();
        Database.DeleteResult[] savedelresult = Database.delete(TR_DEL);
        Test.stopTest();
        
        //Start test for expection testing
        //Test.startTest();
        //Database.DeleteResult[] savedelresult1 = Database.delete(TR_DEL);
        //Test.stopTest();
        
        //Check records
        For (Database.DeleteResult sd : savedelresult)
        {
            If (sd.isSuccess())
            {
                System.debug('Successfully deleted territory. Territory ID: ' + sd.getId());
            }
            Else
            {
                for(Database.Error errd : sd.getErrors())
                {
                    System.debug('The following error has occurred.');
                    System.debug(errd.getStatusCode() + ': ' + errd.getMessage());
                    System.debug('Territory fields that affected this error: ' + errd.getFields());
                }
            }
        }
        List<Territory_Replica_AGN__c> TRD_CHK = [SELECT Id, Name FROM Territory_Replica_AGN__c WHERE Name LIKE 'TestTerritory_RD_%'];
        If(TRD_CHK.size() == 0)
        {
            System.debug('All replicated territories deleted!');
        }
    }
}