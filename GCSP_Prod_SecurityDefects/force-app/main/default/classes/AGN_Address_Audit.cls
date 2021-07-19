//******************* 26th October,2016:Cognizant: R009: Requirement:1042: To track Address History*******************

global class AGN_Address_Audit implements database.batchable<sObject>{
    // global final String Query;
    private final Datetime startTime;
    global Datetime Rtime;
    global AGN_Address_Audit(){
        startTime = datetime.now();
        Rtime=startTime;
    }
    
    
    global Database.queryLocator start(Database.BatchableContext BC){
        // Load sync settings
        AGN_Settings__c mhc = AGN_Settings__c.getOrgDefaults();
        
// If sync date is null then run on all records otherwise use a filter
        if (mhc.StartTime_Address_Audit_AGN__c == null) {
            return Database.getQueryLocator(
                [SELECT CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue,ParentId FROM Address_vod__History
                ]
            );
        }
        else
        {
            if(Schema.sObjectType.AGN_Settings__c.fields.StartTime_Address_Audit_AGN__c.isAccessible())
            {
                return Database.getQueryLocator(
                    [SELECT CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue,ParentId FROM Address_vod__History where (CreatedDate>=:mhc.StartTime_Address_Audit_AGN__c AND CreatedDate<:Rtime)]
                );
            }
            else
                return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<Address_vod__History> scope){
        
        List<Product_Metrics_Audit_AGN__c> afa = new List<Product_Metrics_Audit_AGN__c>();
        
        
        
        
        for ( Address_vod__History ah : scope)
        {
            
            Product_Metrics_Audit_AGN__c  ap = new Product_Metrics_Audit_AGN__c();
            list<Address_vod__c> pm= new List<Address_vod__c>([Select id,Account_vod__c,Country_Code__c from Address_vod__c where id=:ah.ParentId]);
            for (Address_vod__c a : pm )
            {
                //AG CC(48-49)
                if (Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Account_AGN__c.isCreateable()){
                    ap.Account_AGN__c=a.Account_vod__c;
                    }
                if (Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Country_Code_AGN__c.isCreateable()){
                    ap.Country_Code_AGN__c=a.Country_Code__c;
                    }

            }
            //AG CC(53-58)
            if (Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Field_AGN__c.isCreateable()){
                ap.Field_AGN__c=ah.Field;
                }
            if (Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.ParentId_AGN__c.isCreateable()){
                ap.ParentId_AGN__c=ah.ParentId;
                }
            if (Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.External_ID_AGN__c.isCreateable()){
                ap.External_ID_AGN__c=ah.id;
                }
            if (Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Ownerid.isCreateable()){
                ap.Ownerid=ah.CreatedByid;
                }
            if (Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.New_Value_AGN__c.isCreateable()){
                ap.New_Value_AGN__c=string.valueOf(ah.NewValue); 
                }
            if (Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Old_Value_AGN__c.isCreateable()){
                ap.Old_Value_AGN__c=string.valueOf(ah.OldValue); 
                }
            afa.add(ap);
        }
        //AG CC
        if(Product_Metrics_Audit_AGN__c.sObjectType.getDescribe().isCreateable()){
            insert afa; 
            }
        
        
    }
    
    global void finish(Database.BatchableContext BC){
    
    string emailadd=system.Label.Email_Address_AGN;
    AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email From AsyncApexJob Where Id=:BC.getJobId()];
    // sending email 
    
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     list<String> sendto = new list<String>();
     sendto.add(a.Createdby.Email);
     sendto.add(emailadd);
     mail.setToAddresses(sendto);
     mail.setSubject('Address Audit Status: '+a.status);
     mail.setPlainTextBody('The Batch Apex job processed '+a.TotalJobItems +
            ' batches with '+a.NumberOfErrors + ' failures. ');

        Messaging.sendEmail(New Messaging.SingleEmailMessage[] {mail});
        
        
                // Update the last sync time
        AGN_Settings__c settings = AGN_Settings__c.getOrgDefaults();
        //AG CC
        if (Schema.sObjectType.AGN_Settings__c.fields.StartTime_Address_Audit_AGN__c.isUpdateable()){
            settings.StartTime_Address_Audit_AGN__c= RTime;
            }
        //AG CC
        if(AGN_Settings__c.sObjectType.getDescribe().isUpdateable()){
            update settings;
            }
    }
}