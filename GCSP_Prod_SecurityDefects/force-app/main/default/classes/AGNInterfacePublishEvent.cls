/*****************************************************************************************************************************************************************
Apex  Class- AGNInterfacePublishEvent
Description- This is a generic class to publish data to platform event 'AGNInterfaceLoggingEvent__e'. This platform event is
			 used for interface logging for several GDPR processes
Developer Name- Mansi Mittal
Development Date- 3 May 2018
********************************************************************************************************************************************************************/

public class AGNInterfacePublishEvent {
public static void logBatchApex(Database.BatchableContext batchableContext, List<AGNGigyaValidationException> exceptions, Integer Count) {
        
        AsyncApexJob apexJob = [SELECT Id, ApexClassId, ApexClass.Name, Status, NumberOfErrors, CreatedDate, CompletedDate, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :batchableContext.getJobId()];
        
        // Convert the list of gigya exceptions into a platform event 'AGNCustomExceptionEvent__e'
       List<AGNInterfaceLoggingEvent__e> exList = new List<AGNInterfaceLoggingEvent__e>();
        for(AGNGigyaValidationException ex : exceptions) {
            AGNInterfaceLoggingEvent__e errorDetail = new AGNInterfaceLoggingEvent__e(
                AGN_Error_Code__c=ex.errorCode,
                AGN_Error_Message__c=ex.errorMessage,
                AGN_Error_Record_Details__c=ex.errorDetail,
                AGN_Total_Count__c=count,
                AGN_Run_Details__c=apexJob.Id);
            
            exList.add(errorDetail);
        }
        publishEvent(exList,apexJob, count);
    }
 
public static void logBatchApex(Database.BatchableContext batchableContext, List<AGN_customException> exceptions, Integer Count) {
        
        AsyncApexJob apexJob = [SELECT Id, ApexClassId, ApexClass.Name, Status, NumberOfErrors, CreatedDate, CompletedDate, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :batchableContext.getJobId()];
        
        // Convert the list of gigya exceptions into a platform event 'AGNCustomExceptionEvent__e'
       List<AGNInterfaceLoggingEvent__e> exList = new List<AGNInterfaceLoggingEvent__e>();
        for(AGN_customException ex : exceptions) {
            AGNInterfaceLoggingEvent__e errorDetail = new AGNInterfaceLoggingEvent__e(
                AGN_Error_Code__c=ex.errorCode,
                AGN_Error_Message__c=ex.errorMessage,
                AGN_Error_Record_Details__c=ex.errorDetail,
                AGN_Total_Count__c=count,
                AGN_Run_Details__c=apexJob.Id);
            
            exList.add(errorDetail);
        }
        publishEvent(exList,apexJob, count);
    }    
    
    public static void logBatchApex(Database.BatchableContext batchableContext, Integer count){
        List<AGNInterfaceLoggingEvent__e> exList = new List<AGNInterfaceLoggingEvent__e>();
        AsyncApexJob apexJob = [SELECT Id, ApexClassId, ApexClass.Name, Status, NumberOfErrors, CreatedDate, CompletedDate, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :batchableContext.getJobId()];
        publishEvent(exList,apexJob, count);
    }
    
    public static void publishEvent(List<AGNInterfaceLoggingEvent__e> exList, AsyncApexJob apexJob, Integer count){
        if(exList.isEmpty()){
          AGNInterfaceLoggingEvent__e errorDetail = new AGNInterfaceLoggingEvent__e(
                AGN_Run_Details__c=apexJob.Id,
          		AGN_Total_Count__c=count);
            System.debug('results.size()'+errorDetail);
        	
            exlist.add(errorDetail);  
        }
        List<Database.SaveResult> results = EventBus.publish(exList);
        
        //To check if the exceptions have been successfully published into the platform events
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage());
                }
            }
        }
    }
}