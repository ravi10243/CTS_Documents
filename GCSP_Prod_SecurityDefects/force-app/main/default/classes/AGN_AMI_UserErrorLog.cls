public class AGN_AMI_UserErrorLog implements Queueable {
    public exception exe;
    public string errorCode;
    public string className;
    public string status;
    
    public AGN_AMI_UserErrorLog(exception exe, string errorCode , string className, string status){
        this.exe =exe;
        this.errorCode = errorCode;
        this.className = className;
        this.status = status;
    }
    public void execute(QueueableContext context) {
        Error_Log_AGN__c  newExceptionLog = new Error_Log_AGN__c ();
        newExceptionLog.User_AGN__c = Userinfo.getUserId();
        newExceptionLog.Status_AGN__c = status;
        newExceptionLog.Error_Code_AGN__c = errorCode;
        newExceptionLog.Cause_AGN__c = String.valueOf( exe.getCause());
        newExceptionLog.Type_AGN__c = exe.getTypeName();
        newExceptionLog.Message_AGN__c = exe.getMessage();
        newExceptionLog.Class_AGN__c = className ;
        Database.insert(newExceptionLog,false);
    }
}