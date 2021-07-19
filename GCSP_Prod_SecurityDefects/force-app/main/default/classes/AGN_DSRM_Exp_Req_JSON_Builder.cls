/*******************************************************************************************************
 * @File Name          : AGN_DSRM_Exp_Req_JSON_Builder.cls
 * @Description        : Request builder
 * @Author             : Avijit Gorai & Debkumar Sarkar
 * @Group              : 
 * @Last Modified By   : 
 * @Last Modified On   : 
 * 
 * @Modification Log   : 
 * Ver       Date            	Author                 Modification
 * 1.0    4/3/2020   			AG & DS    				Initial Version
 * 1.1	  30/3/2020				AG						Customer's info generated through mapping	
 *******************************************************************************************************/
public class AGN_DSRM_Exp_Req_JSON_Builder {
    
    public class CaseMappingData{
        public String fieldName {get;private set;}
        public String value {get;private set;}
        public String groupName {get;private set;}
        
        public CaseMappingData(String fieldNameVal, String valueVal, String groupNameVal){
            fieldName = fieldNameVal;
            value = valueVal;
            groupName = groupNameVal;
        }
    }
    
    public class Options{
        public Options(){
        }
    }    
    
    public class Control{
        private String value;
        private String option;
        
        public Control(String option, String value){
            this.value = value;
            this.option = option;
        }
    }

    public static String generateJSONContentInitialRequest(CCPA_Experian_Setting_AGN__mdt experianSetting, 
                                                           Map<String, List<CaseMappingData>> mappingGroupByData)
    {
        
        String clientReferenceId = generateRandomString(20);
		String messageTime = getFormattedDateTime(); //YYYY-MM-DDTHH:MM:SSZ format
        
        JSONGenerator gen = JSON.createGenerator(true);
        //start
        gen.writeStartObject();
        //header
        gen.writeFieldName('header');
        gen.writeStartObject();
        gen.writeStringField('tenantId', experianSetting.Tenant_ID_AGN__c);
        gen.writeStringField('requestType', experianSetting.Request_Type_AGN__c);
        gen.writeStringField('clientReferenceId', clientReferenceId);
        gen.writeStringField('expRequestId', '');
        gen.writeStringField('messageTime', messageTime);
        gen.writeFieldName('options');
        gen.writeStartObject();

        gen.writeEndObject();
        gen.writeEndObject();
        
        //payload
        gen.writeFieldName('payload');
        gen.writeStartObject();
        //control
        gen.writeFieldName('control');
        List<AGN_DSRM_Exp_Req_JSON_Builder.Control> ctrl = getControlSetting(experianSetting);
        gen.writeObject(ctrl);
        //contacts
        gen.writeFieldName('contacts');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('id', getGroupNameId('contacts'));
                
        for (String groupName : mappingGroupByData.keySet())
        {
            List<CaseMappingData> caseMappingDataList = mappingGroupByData.get(groupName);
            if(groupName == 'names'){
                gen.writeFieldName('person');
                gen.writeStartObject();
            }   
            gen.writeFieldName(groupName);
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('id', getGroupNameId(groupName));
            gen.writeStringField('type', 'CURRENT');
            
            for(CaseMappingData caseMappingData : caseMappingDataList){
                if(!String.isEmpty(caseMappingData.value)) {
                    String caseData = String.valueOf(caseMappingData.value);
                    caseData = caseData.normalizeSpace();
                    gen.writeStringField(caseMappingData.fieldName, caseData);
                }
            }
            
            gen.writeEndObject();
            gen.writeEndArray();
            
            if(groupName == 'names'){ 
                gen.writeEndObject();
            }
        }
        
        gen.writeEndObject();
        gen.writeEndArray(); 
        
        //application
        gen.writeFieldName('application');
        gen.writeStartObject();
        gen.writeStringField('otpMsgType', 'TEXT');
        gen.writeFieldName('productDetails');
        gen.writeStartObject();
        gen.writeStringField('productType', 'WRITTEN_INSTRUCTIONS');
        gen.writeEndObject();
        
        gen.writeFieldName('applicants');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('contactId', getGroupNameId('contacts'));
        gen.writeStringField('applicantType', 'APPLICANT');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        
        gen.writeEndObject();
        
        gen.writeEndObject();       
        
        String jsonString = gen.getAsString();
        
        jsonString = jsonString.replace('\r\n', '');
        jsonString = jsonString.replace('\n', '');
        jsonString = jsonString.replace('\r', '');
        
        System.debug('The Generated JSON :' +jsonString);
        return jsonString;
    }
	
	//For 2nd OTP Request
    public static String generateJSONContentOTPRequest(String oneTimePasscode, String experianSessionId, 
                                                       CCPA_Experian_Setting_AGN__mdt experianSetting)
    {
        
        String clientReferenceId = generateRandomString(20);
		String messageTime = getFormattedDateTime(); //YYYY-MM-DDTHH:MM:SSZ format
        
        JSONGenerator gen = JSON.createGenerator(true);
        //start
        gen.writeStartObject();
        //header
        gen.writeFieldName('header');
        gen.writeStartObject();
        gen.writeStringField('tenantId', experianSetting.Tenant_ID_AGN__c);
        gen.writeStringField('requestType', experianSetting.Request_Type_AGN__c);
        gen.writeStringField('clientReferenceId', clientReferenceId);
        gen.writeStringField('expRequestId', '');
        gen.writeStringField('messageTime', messageTime);
        gen.writeFieldName('options');
        gen.writeStartObject();

        gen.writeEndObject();
        gen.writeEndObject(); 
        
        //payload
        gen.writeFieldName('payload');
        gen.writeStartObject();
        //control
        gen.writeFieldName('control');
        List<AGN_DSRM_Exp_Req_JSON_Builder.Control> ctrl = getControlSetting(experianSetting);
        ctrl.add(new AGN_DSRM_Exp_Req_JSON_Builder.Control('SESSIONID', experianSessionId));
		ctrl.add(new AGN_DSRM_Exp_Req_JSON_Builder.Control('VALIDATE_OTP', 'Y'));
        gen.writeObject(ctrl);
        //application
        gen.writeFieldName('application');
        gen.writeStartObject();
        gen.writeStringField('oneTimePasscode', oneTimePasscode.normalizeSpace());
        gen.writeEndObject();
        
        gen.writeEndObject();
       
        gen.writeEndObject();
        
        String jsonString = gen.getAsString();
        
       	jsonString = jsonString.replace('\r\n', '');
        jsonString = jsonString.replace('\n', '');
        jsonString = jsonString.replace('\r', '');
        
        System.debug('The Generated JSON :' +jsonString);
		
		return jsonString;
        
    }
    
	//For Final request
	
    public static String generateJSONContentFinalRequest(String sessionId, List<String> answerIds, 
                                                         CCPA_Experian_Setting_AGN__mdt experianSetting)
    {
        
        String clientReferenceId = generateRandomString(20);
		String messageTime = getFormattedDateTime(); //YYYY-MM-DDTHH:MM:SSZ format
        
        JSONGenerator gen = JSON.createGenerator(true);
        //start
        gen.writeStartObject();
        //header
        gen.writeFieldName('header');
        gen.writeStartObject();
        gen.writeStringField('tenantId', experianSetting.Tenant_ID_AGN__c);
        gen.writeStringField('requestType', experianSetting.Request_Type_AGN__c);
        gen.writeStringField('clientReferenceId', clientReferenceId);
        gen.writeStringField('expRequestId', '');
        gen.writeStringField('messageTime', messageTime);
        gen.writeFieldName('options');
        gen.writeStartObject();

        gen.writeEndObject();
        gen.writeEndObject(); 
        
        //payload
        gen.writeFieldName('payload');
        gen.writeStartObject();
        //control
        gen.writeFieldName('control');
        List<AGN_DSRM_Exp_Req_JSON_Builder.Control> ctrl = getControlSetting(experianSetting);
        gen.writeObject(ctrl);
        //kba
        gen.writeFieldName('kba');
        gen.writeStartObject();
        gen.writeStringField('riskStrategyNumber', '');
        gen.writeStringField('languageCode', 'en');
        gen.writeStringField('championChallengerRandomNumber', '');
        //gen.writeStringField('outWalletQuestionsRequest', String.valueOf(answerIds.size()));
        //gen.writeStringField('outWalletQuestionsRequest', '');
        gen.writeStringField('sessionId', sessionId);
        gen.writeFieldName('answers');
        gen.writeStartObject();
        Integer ansCounter = 0;
        for(String questionAnswer : answerIds){
            gen.writeStringField('outWalletAnswer' + String.valueOf(++ansCounter), questionAnswer);
        }
        gen.writeEndObject(); 
        
        gen.writeEndObject();
        gen.writeEndObject();
        
        gen.writeEndObject();       
        
        String jsonString = gen.getAsString();
        
        jsonString = jsonString.replace('\r\n', '');
        jsonString = jsonString.replace('\n', '');
        jsonString = jsonString.replace('\r', '');
        
        System.debug('The Generated JSON :' +jsonString);
        return jsonString;
    }
	
    private static List<AGN_DSRM_Exp_Req_JSON_Builder.Control> getControlSetting(CCPA_Experian_Setting_AGN__mdt experianSetting){
		
		List<AGN_DSRM_Exp_Req_JSON_Builder.Control> ctrl = new List<AGN_DSRM_Exp_Req_JSON_Builder.Control>();
        
		AGN_DSRM_Exp_Req_JSON_Builder.Control control;
		
        control = new AGN_DSRM_Exp_Req_JSON_Builder.Control('PIDXML_VERSION', experianSetting.PIDXML_Version_AGN__c);
		ctrl.add(control);
		control = new AGN_DSRM_Exp_Req_JSON_Builder.Control('SUBSCRIBER_PREAMBLE', experianSetting.Subscriber_Preamble_AGN__c);
		ctrl.add(control);
		control = new AGN_DSRM_Exp_Req_JSON_Builder.Control('SUBSCRIBER_SUB_CODE', experianSetting.Subscriber_Sub_Code_AGN__c);
		ctrl.add(control);
        control = new AGN_DSRM_Exp_Req_JSON_Builder.Control('SUBSCRIBER_OPERATOR_INITIAL', experianSetting.Subscriber_Operator_Initial_AGN__c);
		ctrl.add(control);
		control = new AGN_DSRM_Exp_Req_JSON_Builder.Control('PID_USERNAME', experianSetting.PID_Username_AGN__c);
		ctrl.add(control);
		control = new AGN_DSRM_Exp_Req_JSON_Builder.Control('PID_PASSWORD', EncodingUtil.base64Encode(Blob.valueOf(experianSetting.PID_Password_AGN__c))); //Need to send base64 encoded password
		ctrl.add(control);
		control = new AGN_DSRM_Exp_Req_JSON_Builder.Control('VERBOSE','Y');
		ctrl.add(control);
		control = new AGN_DSRM_Exp_Req_JSON_Builder.Control('PRODUCT_OPTION', experianSetting.Product_Option_AGN__c);
		ctrl.add(control);
		control = new AGN_DSRM_Exp_Req_JSON_Builder.Control('DETAIL_REQUEST','D');
		ctrl.add(control);
        
		return ctrl;
	}
    
    @TestVisible
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    @TestVisible
    private static String getFormattedDateTime() {
        String messageTime = Datetime.now().format('YYYY-MM-dd HH:mm:ss');
        messageTime += 'Z';
        return messageTime.replace(' ', 'T'); //output -> 2020-03-04T22:10:10Z
    }
    
    @TestVisible
	private static String getGroupNameId(String groupName){
        
        Map<String, String> groupNameIdMap = new Map<String, String>();
        
        groupNameIdMap.put('addresses', 'MAIN_CONTACT_ADDRESS_0');
        groupNameIdMap.put('names', 'MAIN_PERSON_NAME_0');
        groupNameIdMap.put('telephones', 'MAIN_PHONE_0');
        groupNameIdMap.put('contacts', 'APPLICANT_CONTACT_ID_0');

        return groupNameIdMap.get(groupName);
    }
}