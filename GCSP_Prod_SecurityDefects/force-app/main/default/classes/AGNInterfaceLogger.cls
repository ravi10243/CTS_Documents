public with sharing class AGNInterfaceLogger {

  public static void logBatchApex(Database.BatchableContext batchableContext) {
    List<Success_Error_History_AGN__c> errorList = new List<Success_Error_History_AGN__c>();
    logBatchApex(batchableContext, errorList);
  }

  public static void logBatchApex(Database.BatchableContext batchableContext, List<AGNGigyaValidationException> gigyaExceptions) {
    // Convert the list of gigya exceptions into a list of Error_Table_AGN__c records
    List<Error_Table_AGN__c> errorDetailList = new List<Error_Table_AGN__c>();
    for(AGNGigyaValidationException gigyaException : gigyaExceptions) {
        Error_Table_AGN__c errorDetail = new Error_Table_AGN__c();
       if(Schema.sObjectType.Error_Table_AGN__c.fields.Error_Code_AGN__c.isCreateable() &&
          Schema.sObjectType.Error_Table_AGN__c.fields.Error_Code_AGN__c.isUpdateable()) {//If clause added by Cognizant team for FLS issues//
      
      errorDetail.Error_Code_AGN__c=gigyaException.errorCode;
          }
        if(Schema.sObjectType.Error_Table_AGN__c.fields.Error_Details_AGN__c.isCreateable() &&
           Schema.sObjectType.Error_Table_AGN__c.fields.Error_Details_AGN__c.isUpdateable()){//If clause added by Cognizant team for FLS issues//
          errorDetail.Error_Details_AGN__c=gigyaException.errorMessage;
              }
      errorDetailList.add(errorDetail);
    
  }
    System.debug(errorDetailList);
    upsert errorDetailList;
    logBatchApex(batchableContext,gigyaExceptions, errorDetailList);
  }

  public static void logBatchApex(Database.BatchableContext batchableContext, List<AGNGigyaValidationException> gigyaExceptions, List<Error_Table_AGN__c> errorMsg) {
    // Convert the list of gigya exceptions into a list of Success_Error_History_AGN__c records

    Map<Integer, Id> errorMap= new Map<Integer, Id>();
    for(Error_Table_AGN__c er: errorMsg){
      errorMap.put((Integer) er.Error_Code_AGN__c, er.Id);
    }

    List<Success_Error_History_AGN__c> errors = new List<Success_Error_History_AGN__c>();
    for(AGNGigyaValidationException gigyaException : gigyaExceptions) {
        Success_Error_History_AGN__c error = new Success_Error_History_AGN__c();
        if(Schema.sObjectType.Success_Error_History_AGN__c.fields.Allergan_Error_Table__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
          error.Allergan_Error_Table__c = 'Error';
              }
         if(Schema.sObjectType.Success_Error_History_AGN__c.fields.Error_Id_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
           error.Error_Id_AGN__c= errorMap.containsKey(gigyaException.errorCode)?errorMap.get(gigyaException.errorCode):null;
              }
        if(Schema.sObjectType.Success_Error_History_AGN__c.fields.Record_Details_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
          error.Record_Details_AGN__c  = gigyaException.errorDetail;
              }
      if(Schema.sObjectType.Success_Error_History_AGN__c.fields.Success_Code_from_Gigya_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
         error.Success_Code_from_Gigya_AGN__c = gigyaException.errorCode;
              }
      errors.add(error);
    }
    logBatchApex(batchableContext, errors);
    }
  
  public static void logBatchApex(Database.BatchableContext batchableContext, List<Success_Error_History_AGN__c> errors) {
    // Query the apex job details so we can log it
    AsyncApexJob apexJob = [SELECT Id, ApexClassId, ApexClass.Name, Status, NumberOfErrors, CreatedDate, CompletedDate, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :batchableContext.getJobId()];
	Boolean isCreateAccess = true;
    // Calculate the number of errors & successes
    Integer countErrors    = errors.isEmpty() ? apexJob.NumberOfErrors : errors.size();
    Integer countSuccesses = apexJob.TotalJobItems - countErrors;
	/*String[] jobFields = new String [] {'CompletedDate','NumberOfErrors','Status','CreatedDate','TotalJobItems','ApexClass.Name'};
    Map<String,Schema.SObjectField> mapSchema = Schema.SObjectType.AsyncApexJob.fields.getMap();
    for(String fieldToCheck : jobFields) {
    	if(mapSchema.get(fieldToCheck) != null && (!mapSchema.get(fieldToCheck).getDescribe().isCreateable())) {
        	isCreateAccess = false;
            break;
        }
    }*/
    Interface_Run_Details_AGN__c iRunDetails = new Interface_Run_Details_AGN__c();
      if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.End_Date_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
    iRunDetails.End_Date_AGN__c = apexJob.CompletedDate;
        }
     if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Error_Record_Count_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
    iRunDetails.Error_Record_Count_AGN__c = countErrors;
        } 
    if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Name .isCreateable()){//If clause added by Cognizant team for FLS issues//
    iRunDetails.Name = apexJob.ApexClass.Name;
        }
    if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Run_Status__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
    iRunDetails.Run_Status__c = errors.isEmpty() ? apexJob.Status : 'Failed';
        }
     if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Start_Date_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
    iRunDetails.Start_Date_AGN__c = apexJob.CreatedDate;
        } 
    if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Success_Record_Count_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
    iRunDetails.Success_Record_Count_AGN__c = countSuccesses;
        }
    
      insert iRunDetails;
      
   

    // Relate the individual errors to the parent interface run details
    for(Success_Error_History_AGN__c error : errors) {
        if(Schema.sObjectType.Success_Error_History_AGN__c.fields.Allergan_Interface_Run_Details_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
      error.Allergan_Interface_Run_Details_AGN__c = iRunDetails.Id;
        }
     }
       insert errors;
  }

  public static void log(String className, List<Success_Error_History_AGN__c> successes, List<Success_Error_History_AGN__c> errors) {
    Datetime now = Datetime.now();

    if (successes == null) {
      successes = new List<Success_Error_History_AGN__c>();
    }
    if (errors == null) {
      errors = new List<Success_Error_History_AGN__c>();
    }
     Interface_Run_Details_AGN__c iRunDetails = new Interface_Run_Details_AGN__c();
      
      if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.End_Date_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
         iRunDetails.End_Date_AGN__c = now; 
      }
      if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Error_Record_Count_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
         iRunDetails.Error_Record_Count_AGN__c = errors.size();
      }
      if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Name.isCreateable()){//If clause added by Cognizant team for FLS issues//
       iRunDetails.Name = className;   
      }
      if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Run_Status__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
       iRunDetails.Run_Status__c = 'Failed';  
      }
      if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Start_Date_AGN__c .isCreateable()){//If clause added by Cognizant team for FLS issues//
          iRunDetails.Start_Date_AGN__c = now;
      }
        if(Schema.sObjectType.Interface_Run_Details_AGN__c.fields.Success_Record_Count_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
          iRunDetails.Success_Record_Count_AGN__c = successes.size();  
        }

   insert iRunDetails;
        
  
    // Relate the individual errors to the parent interface run details
    for(Success_Error_History_AGN__c error : errors) {
        if(Schema.sObjectType.Success_Error_History_AGN__c.fields.Allergan_Interface_Run_Details_AGN__c.isCreateable()){//If clause added by Cognizant team for FLS issues//
      error.Allergan_Interface_Run_Details_AGN__c = iRunDetails.Id;
         }
    }
    insert errors;
  }
  }