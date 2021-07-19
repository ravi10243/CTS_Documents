/**
 * @File Name          : AGN_DSRM_ExperianController.cls
 * @Description        : 
 * @Author             : Avijit Gorai
 * @Group              : 
 * @Last Modified By   : Avijit Gorai
 * @Last Modified On   : 18/3/2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    18/3/2020   		Avijit Gorai     		Initial Version
**/

public class AGN_DSRM_ExperianController {
    
    //May return three separate "responses". 1. Kba Response, or 2. OTP Response or 3. Response without Kba and OTP
    //1. Kba Response - If questions are generated, the method will return 
    //an initial response that includes Questions-and-Answer (Kba) to present to the consumer
    //or 2. OTP Response - Multi-Factor Authentication provides an additional method to authenticate customers 
    //using a one-time passcode sent to the customer's mobile via SMS.
    //or 3. Response without Kba and OTP - if consumer's Identity is not been authenticated/identified by Experian
    
    @AuraEnabled
    public static AGN_DSRM_Experian_Response getInitialResponse(String caseRecordId, String caseNumber, String countryCode){

        AGN_DSRM_Experian_Response response;
        DS_Email_Verification_GDPR_AGN__c dsEmailObj = getDSEmailObject(caseRecordId);
        try{
            response = AGN_DSRM_Experian_Services.submitInitialRequest(caseRecordId, dsEmailObj.Id, countryCode);
            if(response != null && response.responseHeader != null && response.responseHeader.responseType != null && response.responseHeader.responseType == 'ERROR'){
                throw new AGN_CalloutUtils.AGN_CalloutUtilsException(response.responseHeader.responseMessage);
            }
            AGN_DSRM_Experian_Response.DecisionElements decisionElement = response.clientResponsePayload.decisionElements[0];
            
            if(decisionElement.otherData != null 
               && decisionElement.otherData.json != null 
               && decisionElement.otherData.json.fraudSolutions != null 
               && decisionElement.otherData.json.fraudSolutions.response != null 
               && decisionElement.otherData.json.fraudSolutions.response.products != null 
               && decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer != null){
                   
                   //OTP Sent
                   if(decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer.multiFactorAuth != null){
                       AGN_DSRM_Experian_Response.MFStatus mFStatus = decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer.multiFactorAuth.status;
                       //Status code 100 or 400
                       //code 100 - Message Sent
                       //code 400 - Message delivery error
                       if(mFStatus.code == '100'){
                           Boolean isSandbox = AGN_DSRM_Experian_Services.isSandbox();
                           String logMessage = 'Experian - OTP Generated.';
                           if(isSandbox){
                               logMessage += ' OTP = ' + decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer.multiFactorAuth.oneTimePwd;
                           }
                           CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                               Source_AGN__c = 'System',
                               Transaction_AGN__c = 'Initial Request - OTP Sent',
                               Error_Message_AGN__c = logMessage,
                               DS_Email_Verification_AGN__c = dsEmailObj.Id,
                               Case_AGN__c = caseRecordId
                           );
                           EventBus.publish(log);
                       }
                       else{
                           //stamp overallResponse - decision
                           updateOverallDecision(dsEmailObj, response.responseHeader.overallResponse.decision);
                           
                           CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                               Source_AGN__c = 'System',
                               Transaction_AGN__c = 'Initial Request - OTP Message delivery error',
                               Error_Message_AGN__c = 'Experian - '+ mFStatus.value +' with Status Code = ' + mFStatus.code,
                               DS_Email_Verification_AGN__c = dsEmailObj.Id,
                               Case_AGN__c = caseRecordId
                           );
                           EventBus.publish(log);
                       }
                   }
                   //Questions-and-answer functionality returned
                   else if(decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer.kba != null){
                       AGN_DSRM_Experian_Response.Kba kba = decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer.kba;
                       CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                           Source_AGN__c = 'System',
                           Transaction_AGN__c = 'Initial Request - Q&A Returned',
                           Error_Message_AGN__c = 'Experian - ' + kba.general.numberOfQuestions +' Q&A Generated',
                           DS_Email_Verification_AGN__c = dsEmailObj.Id,
                           Case_AGN__c = caseRecordId
                       );
                       EventBus.publish(log);
                   }
                   //consumer's Identity is not been authenticated/identified by Experian
                   else{
                       //stamp overallResponse - decision
                       updateOverallDecision(dsEmailObj, response.responseHeader.overallResponse.decision);
                       
                       CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                           Source_AGN__c = 'System',
                           Transaction_AGN__c = 'Initial Request - ' + System.Label.AGN_CCPA_Experian_Response_Status,
                           Error_Message_AGN__c = 'Experian - Neither OTP sent nor Q&A generated. Experian Decision - ' + response.responseHeader.overallResponse.decision,
                           DS_Email_Verification_AGN__c = dsEmailObj.Id,
                           Case_AGN__c = caseRecordId
                       );
                       EventBus.publish(log);
                   }
               }
            else if(decisionElement.otherData == null){
                //stamp overallResponse - decision
                updateOverallDecision(dsEmailObj, response.responseHeader.overallResponse.decision);
                
                CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                    Source_AGN__c = 'System',
                    Transaction_AGN__c = 'Initial Request - ' + System.Label.AGN_CCPA_Experian_Response_Status,
                    Error_Message_AGN__c = 'decisionElement.otherData is null. Experian Decision - ' + response.responseHeader.overallResponse.decision,
                    DS_Email_Verification_AGN__c = dsEmailObj.Id,
                    Case_AGN__c = caseRecordId
                );
                EventBus.publish(log);
            }
        }
        catch(System.Exception ex){
            CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                Source_AGN__c = '',
                Transaction_AGN__c = 'Default',
                Error_Message_AGN__c = 'ERROR = ' + ex.getMessage() + '\nStackTrace = '+ ex.getStackTraceString(),
                DS_Email_Verification_AGN__c = dsEmailObj.Id,
                Case_AGN__c = caseRecordId
            );
            EventBus.publish(log);
            throw new AuraHandledException(String.format(System.Label.AGN_CCPA_Error_Processing_Request, new List<String>{caseNumber}));
        }
        
        return response;
    }
    
    //If a OTP successfully sent to the customer's mobile by getInitialResponse method
    //submit the consumer-supplied OTP to get final decision on consumer's identity
    @AuraEnabled
    public static AGN_DSRM_Experian_Response validateOTP(String caseRecordId, String caseNumber, String valueOTP, String experianSessionId){
        
        System.debug('valueOTP -> ' + valueOTP);
        AGN_DSRM_Experian_Response response;
        DS_Email_Verification_GDPR_AGN__c dsEmailObj = getDSEmailObject(caseRecordId);
        try{
            response = AGN_DSRM_Experian_Services.validateOTP(caseRecordId, dsEmailObj.Id, valueOTP, experianSessionId);
            if(response != null && response.responseHeader != null && response.responseHeader.responseType != null && response.responseHeader.responseType == 'ERROR'){
                throw new AGN_CalloutUtils.AGN_CalloutUtilsException(response.responseHeader.responseMessage);
            }
            AGN_DSRM_Experian_Response.DecisionElements decisionElement = response.clientResponsePayload.decisionElements[0];
            AGN_DSRM_Experian_Response.MfaValidationResponse mfaValidationResponse;
            
            if(decisionElement.otherData != null 
               && decisionElement.otherData.json != null 
               && decisionElement.otherData.json.fraudSolutions != null 
               && decisionElement.otherData.json.fraudSolutions.response != null 
               && decisionElement.otherData.json.fraudSolutions.response.products != null 
               && decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer != null) 
            {
                if(decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer.multiFactorAuth != null){
                    //multiFactorAuth
                    mfaValidationResponse = decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer.multiFactorAuth.mfaValidationResponse;
                    AGN_DSRM_Experian_Response.ValidateOTP validateOTP = mfaValidationResponse.validateOTP;
                    /*
                    One-Time Password match result:
                    "M" Match
                    "N" No Match
                    "E" Expired
                    */
                                        
                    /*if(validateOTP.otpMatchResult == 'M'){
                    	//overallResponse - "decision": ACCEPT
                    }
                    else{
                    	//overallResponse - "decision": REFER
                    }*/
                    updateOverallDecision(dsEmailObj, response.responseHeader.overallResponse.decision);
                    
                    CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                        Source_AGN__c = 'System',
                        Transaction_AGN__c = 'OTP Validate Request - ' + System.Label.AGN_CCPA_Experian_Response_Status,
                        Error_Message_AGN__c = 'OTP validation status = ' + validateOTP.otpMatchResult + ' (M = Match, N = No Match, E = Expired). Experian Decision - ' + response.responseHeader.overallResponse.decision,
                        DS_Email_Verification_AGN__c = dsEmailObj.Id,
                        Case_AGN__c = caseRecordId
                    );
                    EventBus.publish(log);
                }
                else if(decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer.error != null){
                    AGN_DSRM_Experian_Response.Error otpError = decisionElement.otherData.json.fraudSolutions.response.products.preciseIDServer.error;
                    //stamp overallResponse - decision
                    updateOverallDecision(dsEmailObj, response.responseHeader.overallResponse.decision);
                    
                    CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                        Source_AGN__c = 'System',
                        Transaction_AGN__c = 'OTP Validate Request - ' + System.Label.AGN_CCPA_Experian_Response_Status,
                        Error_Message_AGN__c = 'OTP validation status = ' + otpError.errorDescription + ', Transaction Id = ' + otpError.transactionID +', Error Code = '+ otpError.errorCode + ' . Experian Decision - ' + response.responseHeader.overallResponse.decision,
                        DS_Email_Verification_AGN__c = dsEmailObj.Id,
                        Case_AGN__c = caseRecordId
                    );
                    EventBus.publish(log);
                }
            }
            else if(decisionElement.otherData == null){
                //stamp overallResponse - decision
                updateOverallDecision(dsEmailObj, response.responseHeader.overallResponse.decision);
                
                CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                    Source_AGN__c = 'System',
                    Transaction_AGN__c = 'OTP Validate Request - ' + System.Label.AGN_CCPA_Experian_Response_Status,
                    Error_Message_AGN__c = 'decisionElement.otherData is null. Experian Decision - ' + response.responseHeader.overallResponse.decision,
                    DS_Email_Verification_AGN__c = dsEmailObj.Id,
                    Case_AGN__c = caseRecordId
                );
                EventBus.publish(log);
            }
        }
        catch(System.Exception ex){
            CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                Source_AGN__c = '',
                Transaction_AGN__c = 'Default',
                Error_Message_AGN__c = 'ERROR = ' + ex.getMessage() + '\nStackTrace = '+ ex.getStackTraceString(),
                DS_Email_Verification_AGN__c = dsEmailObj.Id,
                Case_AGN__c = caseRecordId
            );
            EventBus.publish(log);
            throw new AuraHandledException(String.format(System.Label.AGN_CCPA_Error_Processing_Request, new List<String>{caseNumber}));
        }
        return response;
    }
    
    //If Questions-and-answer functionality returned by getInitialResponse method
    //submit the consumer-supplied answers to get final decision on consumer's identity
    @AuraEnabled
    public static AGN_DSRM_Experian_Response submitQuestions(String caseRecordId, String caseNumber, String answerIds, String experianSessionId){
        System.debug('Inside submitQuestions');
        System.debug('answerIds::: '+answerIds);
        
        AGN_DSRM_Experian_Response response;
        DS_Email_Verification_GDPR_AGN__c dsEmailObj = getDSEmailObject(caseRecordId);
        List<String> answerIdList = (List<String>) JSON.deserialize(answerIds, List<String>.class);
        try{
            response = AGN_DSRM_Experian_Services.submitQuestions(caseRecordId, dsEmailObj.Id, answerIdList, experianSessionId);
            if(response != null && response.responseHeader != null && response.responseHeader.responseType != null && response.responseHeader.responseType == 'ERROR'){
                throw new AGN_CalloutUtils.AGN_CalloutUtilsException(response.responseHeader.responseMessage);
            }
            //stamp overallResponse - decision
            updateOverallDecision(dsEmailObj, response.responseHeader.overallResponse.decision);
            CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                Source_AGN__c = 'System',
                Transaction_AGN__c = 'Q&A Submit Request - ' + System.Label.AGN_CCPA_Experian_Response_Status,
                Error_Message_AGN__c = 'Experian Decision - ' + response.responseHeader.overallResponse.decision,
                DS_Email_Verification_AGN__c = dsEmailObj.Id,
                Case_AGN__c = caseRecordId
            );
            EventBus.publish(log);
        }
        catch(System.Exception ex){
            CCPA_Logger_AGN__e log = new CCPA_Logger_AGN__e(
                Source_AGN__c = '',
                Transaction_AGN__c = 'Default',
                Error_Message_AGN__c = 'ERROR = ' + ex.getMessage() + '\nStackTrace = '+ ex.getStackTraceString(),
                DS_Email_Verification_AGN__c = dsEmailObj.Id,
                Case_AGN__c = caseRecordId
            );
            EventBus.publish(log);
            throw new AuraHandledException(String.format(System.Label.AGN_CCPA_Error_Processing_Request, new List<String>{caseNumber}));
        }
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static DS_Email_Verification_GDPR_AGN__c getDSEmailObject(String caseRecordId){
        List<DS_Email_Verification_GDPR_AGN__c> dsEmailList = [Select Id, Experian_Overall_Decision_AGN__c from DS_Email_Verification_GDPR_AGN__c where Case_AGN__c =: caseRecordId];
        return dsEmailList[0];
    }
    
    private static void updateOverallDecision(DS_Email_Verification_GDPR_AGN__c dsEmailObj, String experianOverallDecision){
        dsEmailObj.Experian_Overall_Decision_AGN__c = experianOverallDecision;
        update dsEmailObj;
    }
}