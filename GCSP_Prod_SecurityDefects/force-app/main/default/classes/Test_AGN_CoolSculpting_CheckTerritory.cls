@isTest
public class Test_AGN_CoolSculpting_CheckTerritory {
    static testMethod void AGN_CoolSculpting_CheckTerritoryTest() {
    
      Account acc = new Account();
        acc.Name = 'Test acc'; 
        insert acc;
        
      GAS_Alignment_History_vts__c GAHV = new GAS_Alignment_History_vts__c();
      GAHV.Account__c = acc.id;
      GAHV.CurrencyIsoCode = 'USD';
      GAHV.New_Territory__c = 'Test;Test';
      insert GAHV;
      List<GAS_Alignment_History_vts__c> gasHistoryList=new List<GAS_Alignment_History_vts__c>();
      gasHistoryList.add(GAHV);
      
     // AGN_CoolSculpting_CheckTerritory  ACCT = new AGN_CoolSculpting_CheckTerritory();
      AGN_CoolSculpting_CheckTerritory.checkTerritory(gasHistoryList);
    }
 }