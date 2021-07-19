// #R003: Canada Requirement to Close Contract Exhibit after the end of the year

global class BCInvoice implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
    return Database.getQueryLocator([select id from Contract_Exhibit__c where New_End_date__c=1 and End_Date__c =NULL and Exhibit_Status__c IN ('Draft','Pending Customer Signature','Live','Completed')]);
    }
    global void execute(Database.BatchableContext BC, List<Contract_Exhibit__c> scope)
    {
        for(Contract_Exhibit__c cex : scope)
        {
            if(Schema.sObjectType.Contract_Exhibit__c.fields.Exhibit_Status__c.isUpdateable()) // AKJ cc
            {
                cex.Exhibit_Status__c='Closed';
            }
        	
            if(Schema.sObjectType.Contract_Exhibit__c.isUpdateable())  // AKJ cc
            {
                update cex;
            }
            
        }
       
    }
    global void finish(Database.BatchableContext BC) {
    }
}