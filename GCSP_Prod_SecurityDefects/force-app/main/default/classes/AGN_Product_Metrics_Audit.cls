//******************* 31st March,2016:Cognizant: Release006: Requirement:470:*******************

global class AGN_Product_Metrics_Audit implements database.batchable<sObject>{
    // global final String Query;
    private final Datetime startTime;
    global Datetime Rtime;
    global AGN_Product_Metrics_Audit(){
        startTime = datetime.now();
        Rtime=startTime;
    }
    
    
    global Database.queryLocator start(Database.BatchableContext BC){
        // Load sync settings
        AGN_Settings__c mhc = AGN_Settings__c.getOrgDefaults();
        
// If sync date is null then run on all records otherwise use a filter
        if (mhc.StartTime_AGN__c == null) {
            return Database.getQueryLocator(
                [SELECT CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue,ParentId FROM Product_Metrics_vod__History
                ]
            );
        }
        else
        {
            if (Schema.sObjectType.AGN_Settings__c.fields.StartTime_AGN__c.isAccessible())  // AKJ cc
            	{
                	return Database.getQueryLocator(
                	[SELECT CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue,ParentId FROM Product_Metrics_vod__History where (CreatedDate>=:mhc.StartTime_AGN__c AND CreatedDate<:Rtime)]
                 	);
            	}
            	return null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<Product_Metrics_vod__History> scope){
        
        List<Product_Metrics_Audit_AGN__c> pmfa = new List<Product_Metrics_Audit_AGN__c>();
        
        
        
        
        for ( Product_Metrics_vod__History pmh : scope)
        {
            
            Product_Metrics_Audit_AGN__c  pma = new Product_Metrics_Audit_AGN__c();
            list<Product_Metrics_vod__c> pm= new List<Product_Metrics_vod__c>([Select id,Account_vod__c,Account_vod__r.Country_Code__c,Products_vod__c from Product_Metrics_vod__c where id=:pmh.ParentId]);
            for (Product_Metrics_vod__c a : pm )
    		{
             if(Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Account_AGN__c.isCreateable())        // AKJ cc
             {
                 pma.Account_AGN__c=a.Account_vod__c;
             }
				
             if(Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Country_Code_AGN__c.isCreateable())   // AKJ cc
             {
                 pma.Country_Code_AGN__c=a.Account_vod__r.Country_Code__c;
             }
				
             if(Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Product_AGN__c.isCreateable())    // AKJ cc
             {
                 pma.Product_AGN__c=a.Products_vod__c;
             }
				
    		}
             if(Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Field_AGN__c.isCreateable())      // AKJ cc
             {
                 pma.Field_AGN__c=pmh.Field;
             }
            	
             if(Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.ParentId_AGN__c.isCreateable())   // AKJ cc
             {
                 pma.ParentId_AGN__c=pmh.ParentId;
             }
           		
             if(Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Ownerid.isCreateable())           // AKJ cc
             {
                 pma.Ownerid=pmh.CreatedByid;
             }
            	
             if(Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.External_ID_AGN__c.isCreateable())  // AKJ cc
             {
                 pma.External_ID_AGN__c=pmh.id;
             }
            	
             if(Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.New_Value_AGN__c.isCreateable())    // AKJ cc
             {
                 pma.New_Value_AGN__c=string.valueOf(pmh.NewValue);
             }
            	 
             if(Schema.sObjectType.Product_Metrics_Audit_AGN__c.fields.Old_Value_AGN__c.isCreateable())    // AKJ cc
             {
                 pma.Old_Value_AGN__c=string.valueOf(pmh.OldValue);
             }
           	     
            pmfa.add(pma);
        }
        if(Schema.sObjectType.Product_Metrics_Audit_AGN__c.isCreateable())    // AKJ cc
        {
            insert pmfa;
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
     mail.setSubject('Product Metrics Audit Status: '+a.status);
     mail.setPlainTextBody('The Batch Apex job processed '+a.TotalJobItems +
            ' batches with '+a.NumberOfErrors + ' failures. ');

        Messaging.sendEmail(New Messaging.SingleEmailMessage[] {mail});
        
        
                // Update the last sync time
        AGN_Settings__c settings = AGN_Settings__c.getOrgDefaults();
        if(Schema.sObjectType.AGN_Settings__c.fields.StartTime_AGN__c.isUpdateable())     // AKJ cc
        {
            settings.StartTime_AGN__c= RTime;
        }
        	
        if(Schema.sObjectType.AGN_Settings__c.isUpdateable())     // AKJ cc
        {
            update settings;
        }
        	
    }
}