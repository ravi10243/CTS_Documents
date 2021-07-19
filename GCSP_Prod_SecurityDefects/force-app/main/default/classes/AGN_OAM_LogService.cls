public with sharing class AGN_OAM_LogService {
    
    public static void recordErrors(List<OAM_Log_AGN__e> logEvents) {
        List<OAM_Log_Recording_AGN__c> logRecordings = new List<OAM_Log_Recording_AGN__c>();
        for(OAM_Log_AGN__e logEvent : logEvents) {
            OAM_Log_Recording_AGN__c logRecording = new OAM_Log_Recording_AGN__c();
            logRecording.Data_AGN__c = logEvent.Data_AGN__c;
            logRecording.MethodName_AGN__c = logEvent.MethodName_AGN__c;
            logRecording.Reason_AGN__c = logEvent.Reason_AGN__c;
            logRecording.Callouts_AGN__c = logEvent.Callouts_AGN__c;
            logRecording.ExceptionType_AGN__c = logEvent.ExceptionType_AGN__c;
            logRecording.ExceptionStackTrace_AGN__c = logEvent.ExceptionStackTrace_AGN__c;
            logRecording.ExceptionMessage_AGN__c = logEvent.ExceptionMessage_AGN__c;
            logRecording.RunningUser_AGN__c = logEvent.RunningUserId_AGN__c;
            logRecording.Reference_Email_AGN__c = logEvent.Reference_Email_AGN__c;
            logRecording.ErrorId_AGN__c = logEvent.ErrorId_AGN__c;
            if(!String.isEmpty(logEvent.Allergan_Customer_Registration_AGN__c)){
                logRecording.Allergan_Customer_Registration_AGN__c = logEvent.Allergan_Customer_Registration_AGN__c;
            }
            logRecordings.add(logRecording);
        }
        //------CheckMarx--Added on 25/07/2020----------         
        String objLogRec = 'OAM_Log_Recording_AGN__c';
        SObjectType objLogRecType = ((SObject)(Type.forName('Schema.'+objLogRec).newInstance())).getSObjectType();
        AGN_FLSCheck.check(logRecordings,objLogRecType,'INSERT');
        insert logRecordings;
        //----------------------------------------------
        
    }
    
    public static String getRandom(Integer len){
        final String chars = '0123456789';
        String randStr = '';
        
        while(randStr.length() < len){
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        String guid = randStr.SubString(0,10)+ '-' + randStr.SubString(10,15) + '-' + randStr.SubString(15,20) + '-' + randStr.SubString(20,25) + '-' + randStr.substring(25);
        return guid;
    }
    
    public static String createErrorId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,10)+ '-' + h.SubString(10,15) + '-' + h.SubString(15,20) + '-' + h.SubString(20,25) + '-' + h.substring(25);
        return guid;
    }
}