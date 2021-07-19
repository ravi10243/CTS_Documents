@isTest
public class Test_AGN_OpportunityRollUpOnMeeting {
    static testMethod void AGNOpportunityRollUpOnMeetingTest() {
   
          
    List<Opportunity> oppList = New List<Opportunity>();
        
        Meeting_Type_AGN__c MTA = new Meeting_Type_AGN__c();
        	MTA.name = 'TestMTA';
            MTA.Active_AGN__c = true;
            MTA.Master_Type_AGN__c = 'HQ';
            insert MTA;
        
        Medical_Event_vod__c MEV = new Medical_Event_vod__c();
        	MEV.Name = 'TestMedical';
        	MEV.Start_Time_vod__c = system.Today();
        	MEV.End_Time_vod__c = system.Today();
        	MEV.Geographic_Region_AGN__c = 'EU';
        	MEV.Meeting_Type_Picklist_AGN__c = 'HQ';
            MEV.Meeting_Type_AGN__c = MTA.id;
       	insert MEV;
      
        
        
    Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp1';
        opp.CurrencyIsoCode = 'USD';
        opp.CloseDate = System.today();
        opp.ForecastCategoryName = 'Pipeline';
        opp.StageName = 'Closed Won'; 
        opp.Meeting_AGN__c = MEV.id;
        insert Opp;
    oppList.add(opp);
        
       MEV.Name = 'TestMedical1';
        update MEV;
        Delete MEV;
        
        AGN_OpportunityRollUpOnMeeting AORM = new AGN_OpportunityRollUpOnMeeting();
        AORM.OppRollMeetings(oppList );
    }
}