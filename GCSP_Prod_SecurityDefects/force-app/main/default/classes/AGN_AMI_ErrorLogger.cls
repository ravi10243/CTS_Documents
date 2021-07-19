public class AGN_AMI_ErrorLogger 
{
      public static Error_Log_AGN__c generateExceptionsLog( Exception pException, String pErrorCode,String pStatus) {
                    
        Error_Log_AGN__c  newExceptionLog = new Error_Log_AGN__c ();
        newExceptionLog.User_AGN__c = Userinfo.getUserId();
        newExceptionLog.Status_AGN__c = pStatus;                                
        newExceptionLog.Error_Code_AGN__c = pErrorCode;
        newExceptionLog.Cause_AGN__c = String.valueOf( pException.getCause()); //Returns the cause of the exception as an exception object.
        newExceptionLog.Type_AGN__c = pException.getTypeName(); //Returns the type of exception, such as ListException, MathException, and so on.
        newExceptionLog.Message_AGN__c = pException.getMessage(); //Returns the error message that displays for the user.    
     
        return newExceptionLog;
    }
    

    public static Error_Log_AGN__c  createExceptionsLog( Exception pException, String pClassName ) {
        Error_Log_AGN__c  newExceptionLog = generateExceptionsLog(pException, null,'Open');
        newExceptionLog.Class_AGN__c = pClassName;
        newExceptionLog.StackTraceString_AGN__c = pException.getStackTraceString();
        newExceptionLog.Line_Number_AGN__c = pException.getLineNumber();
        try {
            System.debug('New Ex: '+newExceptionLog);
            Database.insert(newExceptionLog,false);
        }catch (Exception e) {
            System.debug(getExceptionDetails(e));
            
        }
        return newExceptionLog;
    }

    public static Error_Log_AGN__c  createExceptionsLog( Exception pException, String pClassName, String pErrorCode ) {
        Error_Log_AGN__c  newExceptionLog = generateExceptionsLog(pException, pErrorCode,'Open');
        newExceptionLog.Class_AGN__c = pClassName;
        newExceptionLog.StackTraceString_AGN__c = pException.getStackTraceString();
        newExceptionLog.Line_Number_AGN__c = pException.getLineNumber();
        try {
                Database.insert(newExceptionLog,false);
            }catch (Exception e) {
               
            }
        return newExceptionLog;
    
    }
    public static Error_Log_AGN__c  createExceptionsLog( Exception pException, String pClassName, String pMethodName,String pErrorCode ) {
        Error_Log_AGN__c  newExceptionLog = generateExceptionsLog(pException, pErrorCode,'Open');
        newExceptionLog.Class_AGN__c = pClassName;
        newExceptionLog.Method_AGN__c = pMethodName;
        newExceptionLog.StackTraceString_AGN__c = pException.getStackTraceString();
        newExceptionLog.Line_Number_AGN__c = pException.getLineNumber();
        try{
            Database.insert(newExceptionLog,false);
        }catch (Exception e) {
            System.debug(getExceptionDetails(e));
        }
        return newExceptionLog;
    }
    
    
    public static Error_Log_AGN__c  createExceptionsLog( Exception pException, String pClassName, String pErrorCode,String pMethodName, String customErrorMessage ) {

        Error_Log_AGN__c  newExceptionLog = generateExceptionsLog(pException, pErrorCode,'Open');
        newExceptionLog.Class_AGN__c = pClassName;
        newExceptionLog.Method_AGN__c = pMethodName;
        newExceptionLog.Custom_Error_Message_AGN__c = customErrorMessage;
        newExceptionLog.StackTraceString_AGN__c = pException.getStackTraceString();
        newExceptionLog.Line_Number_AGN__c = pException.getLineNumber();
        try {
           Database.insert(newExceptionLog,false);
    
        }catch (Exception e) {
            System.debug(getExceptionDetails(e));
        }
        return newExceptionLog;
    }
    
    public static Error_Log_AGN__c  createExceptionsLog(Error_Log_AGN__c  errorLog, String pClassName, String pMethodName, 
    String pErrorCode,String pCause,String pType,String pMessage,String customErrorMessage ) {
        if (errorLog == null) {
            errorLog = new Error_Log_AGN__c  ();
        }
        errorLog.User_AGN__c = Userinfo.getUserId();
        errorLog.Status_AGN__c = 'Open';                              
        errorLog.Error_Code_AGN__c = pErrorCode;
        errorLog.Cause_AGN__c = pCause; //Returns the cause of the exception as an exception object.
        errorLog.Type_AGN__c = pType; //Returns the type of exception, such as ListException, MathException, and so on.
        errorLog.Message_AGN__c = pMessage; //Returns the error message that displays for the user.    
        errorLog.Class_AGN__c = pClassName;
        errorLog.Custom_Error_Message_AGN__c = customErrorMessage;
        errorLog.Method_AGN__c= pMethodName;
        
        return errorLog;
    }
    
    public static List<Error_Log_AGN__c  > createExceptionsLog(List<Error_Log_AGN__c > errorLogs) {
        try 
        {
            for (Error_Log_AGN__c   errorLog : errorLogs) 
            {
                mapFields(errorLog);
            }
            //Database.insert(errorLogs,false);
        } 
        catch (Exception e) 
        {
            System.debug(getExceptionDetails(e));
        }
        
        return errorLogs;
    }

     public static Error_Log_AGN__c  mapFields(Error_Log_AGN__c  errorLog) {
         return createExceptionsLog(errorLog, errorLog.Class_AGN__c, 
                                    errorLog.Method_AGN__c, errorLog.Error_Code_AGN__c,errorLog.Cause_AGN__c,errorLog.Type_AGN__c,errorLog.Message_AGN__c,errorLog.Custom_Error_Message_AGN__c);
     }
    
    public static String getExceptionDetails(Exception e) {
        String details = '';

       	/* if (e instanceof UnsuccessfulHttpResponseException) {
            UnsuccessfulHttpResponseException httpe = (UnsuccessfulHttpResponseException) e;
	        details += '\n\nHttp Details:' + httpe.toString() ;
        }*/

      	//  details += '\n\nException:\n' + getStackTrace(e);
        details += '\n\nException:\n' + e.getMessage()+'=>'+e.getStackTraceString();
        return details.trim();
    }

}