/*──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Cognizant
* @Name           AGN_Error_Logger
* @version        1.0
* @created        2020-09-28
* @modified       2020-09-28
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes        
*/

public class AGN_Error_Logger {
     public static void  createExceptionsLog( Exception pException, String pClassName, String pMethodName,String customMsg ) {
        Error_Log_AGN__c  newExceptionLog = new Error_Log_AGN__c();
        if(Schema.sObjectType.Error_Log_AGN__c.fields.Class_AGN__c.isCreateable()){
        newExceptionLog.Class_AGN__c = pClassName;
        }
        if(Schema.sObjectType.Error_Log_AGN__c.fields.Method_AGN__c.isCreateable()){
        newExceptionLog.Method_AGN__c = pMethodName;
        }
        if(Schema.sObjectType.Error_Log_AGN__c.fields.Custom_Error_Message_AGN__c.isCreateable()){
        newExceptionLog.Custom_Error_Message_AGN__c=customMsg;
        }
        if(Schema.sObjectType.Error_Log_AGN__c.fields.Status_AGN__c.isCreateable()){
        newExceptionLog.Status_AGN__c= 'Open';
        }
        if(Schema.sObjectType.Error_Log_AGN__c.fields.Message_AGN__c.isCreateable()){
        newExceptionLog.Message_AGN__c =pException!= Null? pException.getMessage():Null;
        }
        if(Schema.sObjectType.Error_Log_AGN__c.fields.Type_AGN__c.isCreateable()){
        newExceptionLog.Type_AGN__c = pException!= Null? pException.getTypeName():Null;   
        }
        if(Schema.sObjectType.Error_Log_AGN__c.isCreateable()){
        Database.insert(newExceptionLog,false);
        }
    }
    
}