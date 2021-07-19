/**
 * @File Name          : AGN_DSRM_Experian_Services.cls
 * @Description        : 
 * @Author             : AG & DS
 * @Group              : 
 * @Last Modified By   : Avijit Gorai
 * @Last Modified On   : 11/3/2020, 3:18:05 am
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/3/2020   AG & DS     Initial Version
**/
public without sharing class AGN_DSRM_Experian_Services {
    
    /**
    * @description 
    * @author AG & DS | 11/3/2020 
    * @param caseRecordId 
    * @param dsEmailRecordId 
    * @param countryCode 
    * @return AGN_DSRM_Experian_Response 
    **/
    public static AGN_DSRM_Experian_Response submitInitialRequest(String caseRecordId, String dsEmailRecordId, String countryCode)
    {
        String requestName = 'Initial Request';
        System.debug('Case Id:: '+caseRecordId);
        AGN_DSRM_Experian_Response objResponse;
        
        CCPA_Experian_Setting_AGN__mdt experianSetting = getExperianSetting();
        Map<String, List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData>> mappingGroupByData = getCaseMappingData(caseRecordId, countryCode);
        String requestBody = AGN_DSRM_Exp_Req_JSON_Builder.generateJSONContentInitialRequest(experianSetting, mappingGroupByData);
        
        try{
            objResponse = doCallOutWithLogging(requestName, caseRecordId, dsEmailRecordId, requestBody, experianSetting);
        }
        catch(System.Exception ex){
            throw ex;
        }
        
        return objResponse;
    }
    
    /**
    * @description 
    * @author AG & DS | 12/3/2020 
    * @param caseRecordId 
    * @param dsEmailRecordId 
    * @param valueOTP 
    * @param experianSessionId 
    * @return AGN_DSRM_Experian_Response 
    **/
    public static AGN_DSRM_Experian_Response validateOTP(String caseRecordId, String dsEmailRecordId, 
                                                         String valueOTP, String experianSessionId)
    {
        String requestName = 'OTP Validate Request';
        System.debug('Case Id:: '+caseRecordId);
        System.debug('Entered OTP Value:: '+valueOTP);
        AGN_DSRM_Experian_Response objResponse;
        
        CCPA_Experian_Setting_AGN__mdt experianSetting = getExperianSetting();                
        String requestBody = AGN_DSRM_Exp_Req_JSON_Builder.generateJSONContentOTPRequest(valueOTP, experianSessionId, experianSetting);
		
        try{
            objResponse = doCallOutWithLogging(requestName, caseRecordId, dsEmailRecordId, requestBody, experianSetting);
        }
        catch(System.Exception ex){
            throw ex;
        }
        
        return objResponse;
    }

    /**
    * @description 
    * @author AG & DS | 14/3/2020 
    * @param caseRecordId 
    * @param dsEmailRecordId 
    * @param answerIdList 
    * @param experianSessionId 
    * @return AGN_DSRM_Experian_Response 
    **/
    public static AGN_DSRM_Experian_Response submitQuestions(String caseRecordId, String dsEmailRecordId, 
                                                             List<String> answerIdList, String experianSessionId)
    {
        String requestName = 'Q&A Submit Request';
        System.debug('Case Id:: '+caseRecordId);
        System.debug('Q&A Answers:: '+ System.JSON.serialize(answerIdList));
        AGN_DSRM_Experian_Response objResponse;
        
        CCPA_Experian_Setting_AGN__mdt experianSetting = getExperianSetting();                
        String requestBody = AGN_DSRM_Exp_Req_JSON_Builder.generateJSONContentFinalRequest(experianSessionId, answerIdList, experianSetting);
		
        try{
            objResponse = doCallOutWithLogging(requestName, caseRecordId, dsEmailRecordId, requestBody, experianSetting);
        }
        catch(System.Exception ex){
            throw ex;
        }
        
        return objResponse;
    }
    
    /**
    * @description 
    * @author AG & DS | 14/3/2020 
    * @param requestName 
    * @param caseRecordId 
    * @param dsEmailRecordId 
    * @param requestBody 
    * @param experianSetting 
    * @return AGN_DSRM_Experian_Response 
    **/
    public static AGN_DSRM_Experian_Response doCallOutWithLogging(String requestName, String caseRecordId, String dsEmailRecordId, 
                                                                  String requestBody, CCPA_Experian_Setting_AGN__mdt experianSetting)
    {
        AGN_DSRM_Experian_Response objResponse;
        HttpResponse resp;
        CCPA_Logger_AGN__e log;
        List<CCPA_Logger_AGN__e> logList = new List<CCPA_Logger_AGN__e>();
        Integer experianTimeout = Integer.valueOf(experianSetting.Service_Time_Out_AGN__c);
        
        String hmacSignature = generateHmacSHA256Signature(requestBody, experianSetting.Hmac_Key_AGN__c);
        
        log = new CCPA_Logger_AGN__e(
            Source_AGN__c = 'Salesforce',
            Transaction_AGN__c = requestName + ' - Request',
            Error_Message_AGN__c = requestBody,
            DS_Email_Verification_AGN__c = dsEmailRecordId,
            Case_AGN__c = caseRecordId
        );
        logList.add(log);

        Map<String,String> headers = new Map<String, String>();
        headers.put('Accept', 'application/json');
        headers.put('Content-Type', 'application/json');
        headers.put('hmac-signature', hmacSignature);
        
        AGN_CalloutUtils callout = new AGN_CalloutUtils();
        
        callout
            .endPoint(experianSetting.End_Point_Url_AGN__c)        	      
            .method('POST')            
            .addHeader(headers)
            .body(requestBody)    
            .timeout(experianTimeout)
            .setClientCertificateName(experianSetting.Certificate_Name_AGN__c);
        
        try{
            //sending request to Experian
            resp = callout.send();
            
            //if (resp.getStatusCode() >= 200 && resp.getStatusCode() < 300)
            if (resp.getStatusCode() == 200) {
                // Everthing fine
                
                objResponse = new AGN_DSRM_Experian_Response(System.JSON.createParser(resp.getBody()));
                
                log = new CCPA_Logger_AGN__e(
                    Source_AGN__c = 'Experian',
                    Transaction_AGN__c = requestName + ' - Response',
                    Error_Message_AGN__c = resp.getBody(),
                    DS_Email_Verification_AGN__c = dsEmailRecordId,
                    Case_AGN__c = caseRecordId
                );
                logList.add(log);
            }
            else{
                throw new AGN_CalloutUtils.AGN_CalloutUtilsException('HTTP callout failed:'
                                                                     + '\nendPoint=' + experianSetting.End_Point_Url_AGN__c
                                                                     + '\nstatusCode=' + resp.getStatusCode()
                                                                     + '\nstatus=' + resp.getStatus()
                                                                     + '\nresponse body=' + resp.getBody()
                                                                    );
            }
        }
        catch(AGN_CalloutUtils.AGN_CalloutUtilsException ex){
            log = new CCPA_Logger_AGN__e(
                Source_AGN__c = 'Experian',
                Transaction_AGN__c = requestName + ' - Response',
                Error_Message_AGN__c = 'ERROR = ' + ex.getMessage() + '\nStackTrace = '+ ex.getStackTraceString(),
                DS_Email_Verification_AGN__c = dsEmailRecordId,
                Case_AGN__c = caseRecordId
            );
            logList.add(log);
            
            throw ex;
        }
        catch(System.CalloutException ex){
            log = new CCPA_Logger_AGN__e(
                Source_AGN__c = 'Experian',
                Transaction_AGN__c = requestName + ' - Response',
                Error_Message_AGN__c = 'ERROR = ' + ex.getMessage() + '\nStackTrace = '+ ex.getStackTraceString(),
                DS_Email_Verification_AGN__c = dsEmailRecordId,
                Case_AGN__c = caseRecordId
            );
            logList.add(log);
            
            throw ex;
        }
        catch(System.Exception ex){
            log = new CCPA_Logger_AGN__e(
                Source_AGN__c = 'Salesforce',
                Transaction_AGN__c = '',
                Error_Message_AGN__c = 'ERROR = ' + ex.getMessage() + '\nStackTrace = '+ ex.getStackTraceString(),
                DS_Email_Verification_AGN__c = dsEmailRecordId,
                Case_AGN__c = caseRecordId
            );
            logList.add(log);
            
            throw ex; 
        }
        finally{
            //Call method to publish events (exception/log will be saved to Allergan_Error_Logger_AGN__c)
            if(!logList.isEmpty()){
                EventBus.publish(logList);
            }
        }
        
        return objResponse;
    }
    
    /**
    * @description 
    * @author AG & DS | 30/3/2020 
    * @param caseId 
    * @param countryCode 
    * @return Map<String, List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData>> 
    **/
    public static Map<String, List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData>> getCaseMappingData(String caseId, String countryCode){
        
        List<SF_to_Experian_Mapping_AGN__mdt> mappingRecords = [Select Country_Code_AGN__c, Experian_Field_AGN__c, SF_Field_AGN__c, 
                                                                Group_Name_AGN__c from SF_to_Experian_Mapping_AGN__mdt 
                                                                where Country_Code_AGN__c =: countryCode];
        
        
        List<String> caseFieldList = new List<String>();
        for(SF_to_Experian_Mapping_AGN__mdt mappingRecord : mappingRecords){
            caseFieldList.add(mappingRecord.SF_Field_AGN__c);
        }
        String caseQueryString = 'Select ' + String.join(caseFieldList, ', ') + ' From Case where Id = \'' + caseId + '\'';
        Map<String, String> lst = new Map<String, String>();
        List<Case> caseRecords = Database.query(caseQueryString);
        Map<String, Object> mapCase = (Map<String, Object>)JSON.deserializeUntyped(System.JSON.serialize(caseRecords[0]));
        //mapCase.remove('attributes');
        
        List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData> caseMappingDataList = new List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData>();
        
        for(SF_to_Experian_Mapping_AGN__mdt mappingRecord : mappingRecords){
            String caseFieldValue;
            switch on mappingRecord.SF_Field_AGN__c {
                when 'Country_AGN_GDPR__c' {
                    caseFieldValue = countryCode;
                }
                when 'Address_Type_AGN__c' {
                    caseFieldValue = String.valueOf(mapCase.get(mappingRecord.SF_Field_AGN__c)).toUpperCase(); //RESIDENTIAL/COMMERCIAL
                }
                when 'States_CCPA_AGN__c' {
                    String stateCode = getStateCode(String.valueOf(mapCase.get(mappingRecord.SF_Field_AGN__c)).toUpperCase());
                    caseFieldValue = stateCode;
                }
                when else {
                    caseFieldValue = String.valueOf(mapCase.get(mappingRecord.SF_Field_AGN__c));
                }
            }
            caseMappingDataList.add(new AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData(mappingRecord.Experian_Field_AGN__c, 
                                                                                      caseFieldValue, 
                                                                                      mappingRecord.Group_Name_AGN__c));
        }
        
        caseMappingDataList.add(new AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData('addressType', 'CURRENT', 'addresses'));
        
        Map<String, List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData>> mappingGroupBy = groupByField(caseMappingDataList);
        
        return mappingGroupBy;
    }
    
    /**
    * @description 
    * @author AG & DS | 30/3/2020 
    * @param message 
    * @param secretKey 
    * @return String 
    **/
    @TestVisible
    private static String generateHmacSHA256Signature(String message, String secretKey) {
       
        String algorithmName = 'HmacSHA256';
        
        Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(message), Blob.valueOf(secretKey));
        //Blob hmacData = Crypto.generateMac(algorithmName, Blob.valueOf(message), EncodingUtil.base64Decode(secretKey));
        return EncodingUtil.base64Encode(hmacData);
    }
    
    /**
    * @description 
    * @author AG & DS | 30/3/2020 
    * @return CCPA_Experian_Setting_AGN__mdt 
    **/
	@TestVisible
    private static CCPA_Experian_Setting_AGN__mdt getExperianSetting(){
        Boolean isSandbox = isSandbox();
        String settingName = isSandbox ? 'SANDBOX' : 'PROD';
        
        List<CCPA_Experian_Setting_AGN__mdt> experianSetting = [Select Certificate_Name_AGN__c, End_Point_Url_AGN__c, Hmac_Key_AGN__c, 
                                                                PID_Password_AGN__c, PID_Username_AGN__c, PIDXML_Version_AGN__c, 
                                                                Product_Option_AGN__c, Request_Type_AGN__c, Service_Time_Out_AGN__c, 
                                                                Subscriber_Operator_Initial_AGN__c, Subscriber_Preamble_AGN__c, 
                                                                Subscriber_Sub_Code_AGN__c, Tenant_ID_AGN__c 
                                                                from CCPA_Experian_Setting_AGN__mdt where DeveloperName =:settingName];
        
        return experianSetting[0];
    }
    
	/**
	* @description 
	* @author AG & DS | 30/3/2020 
	* @param records 
	* @return Map<String, List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData>> 
	**/
    @TestVisible
	private static Map<String, List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData>> groupByField(List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData> records) {   
        Map<String, List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData>> grouped = new Map<String, List <AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData>>();
        if (records != null && records.size() > 0) {
            for (AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData record: records) {
                String key = record.groupName;
                if (!grouped.containsKey(key))
                    grouped.put(key, new List<AGN_DSRM_Exp_Req_JSON_Builder.CaseMappingData>());
                grouped.get(key).add(record);
            }
        }        
        return grouped;
    }
    
    /**
    * @description 
    * @author AG & DS | 30/3/2020 
    * @param stateName 
    * @return String 
    **/
    @TestVisible
    private static String getStateCode(String stateName){
        
        List<US_State_Code_Mapping_AGN__mdt> usStateCodeMapping = [Select State_Code_AGN__c from US_State_Code_Mapping_AGN__mdt 
                                                                   where Label =: stateName];
        if(usStateCodeMapping.isEmpty()){
            usStateCodeMapping = [Select State_Code_AGN__c from US_State_Code_Mapping_AGN__mdt 
                                  where DeveloperName =: stateName];
        }
        return !usStateCodeMapping.isEmpty() ? usStateCodeMapping[0].State_Code_AGN__c : '';
    }

    /**
    * @description 
    * @author AG & DS | 30/3/2020 
    * @param logEvents 
    * @return void 
    **/
    public static void recordLogs(List<CCPA_Logger_AGN__e> logEvents) {
        List<Allergan_Error_Logger_AGN__c> logRecordings = new List<Allergan_Error_Logger_AGN__c>();
        Allergan_Error_Logger_AGN__c logRecording;
        
        for(CCPA_Logger_AGN__e logEvent : logEvents) {
            logRecording = new Allergan_Error_Logger_AGN__c();
            logRecording.Source_AGN__c = logEvent.Source_AGN__c;
            logRecording.Transaction_AGN__c = logEvent.Transaction_AGN__c;
            logRecording.Error_Message_AGN__c = logEvent.Error_Message_AGN__c;
            
            if(!String.isEmpty(logEvent.DS_Email_Verification_AGN__c)){
                logRecording.DS_Email_Verification_AGN__c = logEvent.DS_Email_Verification_AGN__c;
            }
            if(!String.isEmpty(logEvent.Case_AGN__c)){
                logRecording.Case_AGN__c = logEvent.Case_AGN__c;
            }
            logRecordings.add(logRecording);
        }
        insert logRecordings;
    }
    
    public static Boolean isSandbox(){
        return [SELECT Id, isSandbox FROM Organization LIMIT 1].isSandbox;
    }
}