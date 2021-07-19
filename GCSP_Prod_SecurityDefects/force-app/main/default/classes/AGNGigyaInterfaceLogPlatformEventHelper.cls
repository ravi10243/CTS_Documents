/*****************************************************************************************************************************************************************
Apex  Class- AGNGigyaInterfaceLogPlatformEventHelper
Description- This is a generic trigger helper class which is being used by GDPR several processes forinterface logging.
Developer Name- Mansi Mittal
Development Date- 3 May 2018
********************************************************************************************************************************************************************/

public class AGNGigyaInterfaceLogPlatformEventHelper {
    public static void logErrorObj(List<AGNInterfaceLoggingEvent__e> errorPlatformObj) {
        // Convert the list of gigya exceptions into a list of Error_Table_AGN__c records
        List<Error_Table_AGN__c> errorDetailList = new List<Error_Table_AGN__c>();
        Set<Integer> errCodeSet= new Set<Integer>();
        for(AGNInterfaceLoggingEvent__e pdException : errorPlatformObj) {
            if(pdException.AGN_Error_Code__c!=null){
                Error_Table_AGN__c errorDetail = new Error_Table_AGN__c();
                //Cognizant- CC - Line Number - 18,22,26
                if(Schema.sObjectType.Error_Table_AGN__c.fields.Error_Code_AGN__c.isAccessible() && Schema.sObjectType.Error_Table_AGN__c.fields.Error_Code_AGN__c.isCreateable() &&
                   Schema.sObjectType.Error_Table_AGN__c.fields.Error_Code_AGN__c.isUpdateable()){
                    errorDetail.Error_Code_AGN__c = (Integer) pdException.AGN_Error_Code__c;
                }
                if(Schema.sObjectType.Error_Table_AGN__c.fields.Error_Code_AGN__c.isAccessible() && Schema.sObjectType.Error_Table_AGN__c.fields.Error_Code_AGN__c.isCreateable() &&
                  Schema.sObjectType.Error_Table_AGN__c.fields.Error_Code_AGN__c.isUpdateable()){
                    errorDetail.Error_Code_AGN__c = (Integer) pdException.AGN_Error_Code__c;
                }
                if(Schema.sObjectType.Error_Table_AGN__c.fields.Error_Details_AGN__c.isAccessible() && Schema.sObjectType.Error_Table_AGN__c.fields.Error_Details_AGN__c.isCreateable()&&
                   Schema.sObjectType.Error_Table_AGN__c.fields.Error_Details_AGN__c.isUpdateable()){
                    errorDetail.Error_Details_AGN__c = pdException.AGN_Error_Message__c;
                }
                
                
                /* Error_Table_AGN__c errorDetail = new Error_Table_AGN__c(
Error_Code_AGN__c= (Integer) pdException.AGN_Error_Code__c,
Error_Details_AGN__c=pdException.AGN_Error_Message__c
);*/
                
                errorDetailList.add(errorDetail);
                errCodeSet.add((Integer) pdException.AGN_Error_Code__c);
            }
        }
        System.debug('errorDetailList'+errorDetailList);
        try{
            if(!errorDetailList.isEmpty()){
                upsert errorDetailList;
                logErrorObj(errorPlatformObj,errorDetailList);
            }
            else{
                Id jobId= errorPlatformObj[0].AGN_Run_Details__c;
                Integer totalCount=(Integer) errorPlatformObj[0].AGN_Total_Count__c;
                System.debug('Enter interface details as there are no exceptions');
                AsyncApexJob apexJob = [SELECT Id, ApexClassId, ApexClass.Name, Status, NumberOfErrors, CreatedDate, CompletedDate, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :jobId];
                Interface_Run_Details_AGN__c iRunDetails = new Interface_Run_Details_AGN__c();
                //Cognizant- CC - Line Number - 53,56,59,62,65,68,71,74,77
                if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.End_Date_AGN__c.isAccessible() && Schema.sObjectType.Interface_Run_Details_AGN__c.fields.End_Date_AGN__c.isCreateable()) {
                    iRunDetails.End_Date_AGN__c = apexJob.CompletedDate;
                }
                if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Error_Record_Count_AGN__c.isCreateable()) {
                    iRunDetails.Error_Record_Count_AGN__c   = apexJob.NumberOfErrors;
                }
                if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Name.isCreateable()) {
                    iRunDetails.Name = apexJob.ApexClass.Name;
                }
                if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Run_Status__c.isCreateable()) {
                    iRunDetails.Run_Status__c = apexJob.Status;
                }
                if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Run_Name_AGN__c.isCreateable()) {
                    iRunDetails.Run_Name_AGN__c=apexJob.ApexClass.Name;
                }
                if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Run_Date_AGN__c.isCreateable()) {
                    iRunDetails.Run_Date_AGN__c	= apexJob.CreatedDate;
                }
                if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Start_Date_AGN__c.isCreateable()) {
                    iRunDetails.Start_Date_AGN__c  = apexJob.CreatedDate;
                }  
                if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Success_Record_Count_AGN__c.isAccessible() && Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Success_Record_Count_AGN__c.isCreateable()) {
               		iRunDetails.Success_Record_Count_AGN__c = totalCount>0?totalCount:0;
                }
                if(schema.SObjectType.Interface_Run_Details_AGN__c.isCreateable()){
                    insert iRunDetails; 
                }
                               
            }
        }
        catch(Exception ex){
            
        }
        
    }
    
    public static void logErrorObj(List<AGNInterfaceLoggingEvent__e> errorPlatformObj, List<Error_Table_AGN__c> errorDetailList ) {
        // Convert the list of gigya exceptions into a list of Success_Error_History_AGN__c records
      
        Map<Integer, Id> errorMap= new Map<Integer, Id>();
        for(Error_Table_AGN__c er: errorDetailList){
            errorMap.put((Integer) er.Error_Code_AGN__c, er.Id);
        }
        
        List<Success_Error_History_AGN__c> successErrorlist = new List<Success_Error_History_AGN__c>();
        for(AGNInterfaceLoggingEvent__e pdException : errorPlatformObj) {
            Success_Error_History_AGN__c successError = new Success_Error_History_AGN__c();
            //Cognizant- CC - Line Number -110,113,116,119
            if (Schema.sObjectType.Success_Error_History_AGN__c.fields.Allergan_Error_Table__c.isAccessible() && Schema.sObjectType.Success_Error_History_AGN__c.fields.Allergan_Error_Table__c.isCreateable()) {
                successError.Allergan_Error_Table__c        = 'Error';
            }
            if (Schema.sObjectType.Success_Error_History_AGN__c.fields.Record_Details_AGN__c.isCreateable()) {
                successError.Record_Details_AGN__c  = pdException.AGN_Error_Record_Details__c;
            }
            if (Schema.sObjectType.Success_Error_History_AGN__c.fields.Success_Code_from_Gigya_AGN__c.isCreateable()) {
                successError.Success_Code_from_Gigya_AGN__c = pdException.AGN_Error_Code__c;
            }
            if (Schema.sObjectType.Success_Error_History_AGN__c.fields.Error_Id_AGN__c.isAccessible() && Schema.sObjectType.Success_Error_History_AGN__c.fields.Error_Id_AGN__c.isCreateable()) {
                successError.Error_Id_AGN__c = errorMap.containsKey((Integer) pdException.AGN_Error_Code__c)?errorMap.get((Integer) pdException.AGN_Error_Code__c):null;
                        
            }
            successErrorlist.add(successError);
        }
        logErrorObj(errorPlatformObj,successErrorlist);
    }
    
    public static void logErrorObj(List<AGNInterfaceLoggingEvent__e> errorPlatformObj, List<Success_Error_History_AGN__c> successErrorlist) {
        
        Id jobId= errorPlatformObj[0].AGN_Run_Details__c;
        Integer totalCount=(Integer) errorPlatformObj[0].AGN_Total_Count__c;
        AsyncApexJob apexJob = [SELECT Id, ApexClassId, ApexClass.Name, Status, NumberOfErrors, CreatedDate, CompletedDate, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :jobId order by createdDate desc Limit 1];
        Integer countErrors    = successErrorlist.isEmpty() ? apexJob.NumberOfErrors : successErrorlist.size();
        Integer countSuccesses = totalCount - countErrors;
        
        Interface_Run_Details_AGN__c iRunDetails = new Interface_Run_Details_AGN__c();
        //Cognizant- CC - Line Number -138,141,144,147,150,153,156,159,163
        if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.End_Date_AGN__c.isAccessible() && Schema.sObjectType.Interface_Run_Details_AGN__c.fields.End_Date_AGN__c.isCreateable()) {
            iRunDetails.End_Date_AGN__c = apexJob.CompletedDate;
        }
        if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Error_Record_Count_AGN__c.isCreateable()) {
            iRunDetails.Error_Record_Count_AGN__c   = apexJob.NumberOfErrors;
        }
        if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Name.isCreateable()) {
            iRunDetails.Name = apexJob.ApexClass.Name;
        }
        if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Run_Status__c.isCreateable()) {
            iRunDetails.Run_Status__c = apexJob.Status;
        }
        if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Run_Name_AGN__c.isCreateable()) {
            iRunDetails.Run_Name_AGN__c=apexJob.ApexClass.Name;
        }
        if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Run_Date_AGN__c.isCreateable()) {
            iRunDetails.Run_Date_AGN__c	= apexJob.CreatedDate;
        }
        if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Start_Date_AGN__c.isCreateable()) {
            iRunDetails.Start_Date_AGN__c  = apexJob.CreatedDate;
        }  
        if (Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Success_Record_Count_AGN__c.isAccessible() && Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Success_Record_Count_AGN__c.isCreateable()) {
          	iRunDetails.Success_Record_Count_AGN__c = totalCount>0?totalCount:0;
        }
             
        if(Schema.SObjectType.Interface_Run_Details_AGN__c.isCreateable()){
            insert iRunDetails; 
        }
               
        
        // Relate the individual errors to the parent interface run details
        for(Success_Error_History_AGN__c error : successErrorlist) {
            error.Allergan_Interface_Run_Details_AGN__c = iRunDetails.Id;
        }
        insert successErrorlist;
        
    }
    
    /*public static void updateSuccessCount(Integer totalCount, Database.BatchableContext batchableContext){
System.debug('batchableContext'+batchableContext.getJobId());
AsyncApexJob apexJob = [SELECT Id, ApexClassId, ApexClass.Name, Status, NumberOfErrors, CreatedDate, CompletedDate, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :batchableContext.getJobId() order by createdDate desc Limit 1];
Interface_Run_Details_AGN__c intrfc=[Select Success_Record_Count_AGN__c,Error_Record_Count_AGN__c  From Interface_Run_Details_AGN__c where Run_Name_AGN__c=:apexJob.ApexClass.Name order by createdDate desc Limit 1];
intrfc.Success_Record_Count_AGN__c=(totalCount-	intrfc.Error_Record_Count_AGN__c)>0?(totalCount-intrfc.Error_Record_Count_AGN__c):0;
update intrfc;
}*/
}