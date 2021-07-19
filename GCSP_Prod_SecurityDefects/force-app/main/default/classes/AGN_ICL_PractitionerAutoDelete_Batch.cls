public class AGN_ICL_PractitionerAutoDelete_Batch implements Database.Batchable<sObject>,Database.Stateful{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        Date currentDate = Date.today();
        Date filterDate = currentDate.addDays(-30); 
        DateTime projectDate = DateTime.newInstance(2020, 11, 30, 00, 00, 00);//Added as per BA advice . to get those records which created after go-live
        DateTime etDatetime = DateTime.newInstance(filterDate.year(), filterDate.month(), filterDate.day(), 23, 59, 59);
        DateTime StDateTime = DateTime.newInstance(filterDate.year(), filterDate.month(), filterDate.day(), 00, 00, 00); 
        
        return Database.getQueryLocator([SELECT Id,Status_AGN__c,Consent_Check_AGN__c,createdDate,Practitioner_AGN__c
                                         FROM Practitioner_Listing_AGN__c 
                                         WHERE (Status_AGN__c = 'Active' OR Status_AGN__c = 'Pending Approval') 
                                         AND Practitioner_AGN__c != NULL  
                                         AND createdDate >=:StDateTime
                                         AND createdDate <=:etDatetime
                                         AND createdDate >:projectDate
                                         AND Consent_Check_AGN__c = False]);   
    }    
    
    public void execute(Database.BatchableContext bc, List<Practitioner_Listing_AGN__c> scope){
        
        
        List<Practitioner_Listing_AGN__c> pl = new List<Practitioner_Listing_AGN__c>();      
        Map<id,Practitioner_Listing_AGN__c> accPracMap = new Map<id,Practitioner_Listing_AGN__c> ();
        Map<id,List<Multichannel_Consent_vod__c>> accMCMap = new Map<id,List<Multichannel_Consent_vod__c>> ();
        List<Practitioner_Listing_AGN__c> pracTODeactivate = new List<Practitioner_Listing_AGN__c> ();
        
        if(scope!=null && !scope.isEmpty()){
            
            for (Practitioner_Listing_AGN__c pc: scope){               
                accPracMap.put(pc.Practitioner_AGN__c,pc);
            }
            
            for(Multichannel_Consent_vod__c mc : [SELECT Id,Account_vod__c
                                                  FROM Multichannel_Consent_vod__c 
                                                  WHERE Account_vod__c IN:accPracMap.keySet()])
            {
                if(accMCMap.containsKey(mc.Account_vod__c)){
                    accMCMap.get(mc.Account_vod__c).add(mc);
                }
                else{
                    accMCMap.put(mc.Account_vod__c,new List<Multichannel_Consent_vod__c> ());
                    accMCMap.get(mc.Account_vod__c).add(mc);
                }
            }
            
            for(Id accId: accPracMap.keySet()){                
                if(!accMCMap.containsKey(accId)){                    
                    pracTODeactivate.add(accPracMap.get(accId));
                }
            }
            
            if(!pracTODeactivate.isEmpty())
            {
                for (Practitioner_Listing_AGN__c pd: pracTODeactivate){
                    pd.Status_AGN__c = 'Inactive';
                    pd.Is_Auto_Deleted_AGN__c = True; 
                    pd.Auto_Deleted_DateTime_AGN__c = Datetime.now();
                }
                //------CheckMarx Phase2--Added on 18/11/2020----------           
                String obj = 'Practitioner_Listing_AGN__c';
                SObjectType objType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
                AGN_FLSCheck.check(pracTODeactivate,objType,'UPDATE');
                //------CheckMarx Phase2--Ends here----------
                update pracTODeactivate;
            }
        }
    }    
    public void finish(Database.BatchableContext bc)
    {
        
    } 
}