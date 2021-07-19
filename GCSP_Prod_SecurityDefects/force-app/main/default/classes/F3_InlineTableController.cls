public class F3_InlineTableController {
	
    @AuraEnabled
    public static List<Processed_Customer_Account__c> getProcessedCustomerData(Id recordID){
        return [select Id, Name, Account_Type__c, Account_Details__c, Arrears_Amount__c, Full_Min_Due_CMP__c, Due_Date__c
                from Processed_Customer_Account__c where Case__r.Id =: recordID];
    }
    
}