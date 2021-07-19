global class AGN_ICL_LocatorListingApproverUpdate implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,First_Level_Clinic_Approver_AGN__c,Second_Level_Clinic_Approver_AGN__c,Country_Code_AGN__c,Registered_For_Clinic_Locator_AGN__c,Country_Code_AGN__r.First_Level_Clinic_Approver_AGN__c,Country_Code_AGN__r.Second_Level_Clinic_Approver_AGN__c,Registered_from_OAM_AGN__c   FROM Locator_Listing_AGN__c Where First_Level_Clinic_Approver_AGN__c ='' and Registered_For_Clinic_Locator_AGN__c = true ]);   
    }
    
    global void execute(Database.BatchableContext bc, List<Locator_Listing_AGN__c> scope){
        List<Locator_Listing_AGN__c> locupdate = new List<Locator_Listing_AGN__c>();
        for(Locator_Listing_AGN__c loc : scope)
        {
            loc.First_Level_Clinic_Approver_AGN__c = loc.Country_Code_AGN__r.First_Level_Clinic_Approver_AGN__c;
            if(loc.Country_Code_AGN__r.Second_Level_Clinic_Approver_AGN__c != null)
            {
                loc.Second_Level_Clinic_Approver_AGN__c = loc.Country_Code_AGN__r.Second_Level_Clinic_Approver_AGN__c;
            }
            
            locupdate.add(loc);
        }
         //------CheckMarx Phase2--Added on 24/09/2020----------           
            String objLoc = 'Locator_Listing_AGN__c';
                                SObjectType locObjType = ((SObject)(Type.forName('Schema.'+objLoc).newInstance())).getSObjectType();
                                AGN_FLSCheck.check(locupdate,locObjType,'UPDATE');
            //------CheckMarx Phase2--Ends here----------
        update locupdate;
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }  
}