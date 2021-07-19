public without sharing class AccountHelper {


    public void createHCs(list<Account> triggerNew){
    
        /** 
         *  Need a unique reference number – Health Care Institution ID (HCI ID) 
         *  for compliance purposes. 
         *  We have various pieces of information across systems e.g. SAP, 
         *  expenses, payments and an HCP ID object was created so that if we 
         *  merge records we will get one record. 
         *  This now needs to be done for HCI – i.e. for Institutions.
         *  The HCI_ID__C Object is Master (Account) Detail relation
         */
        
        // TODO 
        // 1 - add expression to bypass trigger if we are in Bulk load
        
        List<HCI_ID__c> hcis = new List<HCI_ID__c>();
        List<HCP_ID__c> hcps = new List<HCP_ID__c>();
        Map<ID,RecordType> rt_Map = New Map<ID,RecordType>([Select ID, Name From RecordType Where SobjectType = 'Account']);
        
        // Create new HC's ID for all new Accounts
        for (Account acc :triggerNew) {
        
            //if (!acc.Customer_Managed_AGN__c){
                if(rt_map.get(acc.recordTypeID).name == 'Person Account'||rt_map.get(acc.recordTypeID).name == 'Professional_vod'){
                    hcps.add(new HCP_ID__c(Person__c = acc.Id, Original_Person_ID__c = acc.Id));
                }
                else {
                    hcis.add(new HCI_ID__c(Institution__c = acc.Id, Original_Institution_ID__c = acc.Id));
                }
            //}
        }
        if (!hcis.isEmpty()){
            insert hcis;
        }
        if (!hcps.isEmpty()){
            system.debug(hcps);
            insert hcps;
        }
        
    }
}