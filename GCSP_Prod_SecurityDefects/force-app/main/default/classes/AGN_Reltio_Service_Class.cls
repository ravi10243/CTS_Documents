/****************************************************************************************************************
@ Class:          AGN_Reltio_Service_Class 
@ Version:        1
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        Authenticate and access Reltio API to get matching HCO information based on filter condtions 
-----------------------------------------------------------------------------------------------------------------
@ Change history: 28.12.2020 / Ayush Basak / Created the class.
****************************************************************************************************************/
public with sharing class AGN_Reltio_Service_Class {

    // Static String Constants
    final static String GET = 'GET'; 
    final static String POST = 'POST';
    final static String AUTHORIZATION = 'Authorization';
    final static String BASIC = 'Basic';
    final static String BEARER = 'Bearer';
    final static String CONTENT_TYPE = 'Content-Type';
    final static String URLENCODED = 'application/x-www-form-urlencoded';
    final static String JSON_TYPE = 'application/json';
    final static String USERNAME = 'username';
    final static String PASSWORD = 'password';
    final static String GRANT_TYPE = 'grant_type=password';
    final static String ACCESS_TOKEN = 'access_token';
    final static String OPTIONS = 'options=ovOnly';
    final static String MAX = 'max';
    final static String MAX_VALUE = System.Label.AGN_Dupe_Checker_MaxValue;
    final static String SELECTFIELD = 'select';
    final static String FILTER = 'filter';
    final static String UTF_ENCODING = 'UTF-8';
    final static String FILTER_CONDITION = 'Filter_Logic';

    /************************************************************************************************************
    @ method:           authenticateReltio 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          Uses information stored in Reltio_API_AGN__c custom settings to authenticate and get 
                        access token from Reltio API
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 28.12.2020 / Ayush Basak / Created the method
    ************************************************************************************************************/
    private static String authenticateReltio(){

        // Getting API informations from custom setting
        Reltio_API_AGN__c reltio = Reltio_API_AGN__c.getInstance();

        // Building request
        HTTPRequest req = new HTTPRequest();
        String endpoint = reltio.Authentication_URL_AGN__c 
                            + '?' + USERNAME + '=' + reltio.Username_AGN__c 
                            + '&' + PASSWORD + '=' + reltio.Password_AGN__c 
                            + '&' + GRANT_TYPE;
        req.setEndpoint(endpoint);
        req.setMethod(POST);
        req.setHeader(AUTHORIZATION, BASIC + ' ' + reltio.Authentication_Token_AGN__c);
        req.setHeader(CONTENT_TYPE, URLENCODED);
        
        // Making the callout
        Http http = new Http();
        HTTPResponse res = http.send(req); 
        
        // Reading the response to get access token
        String resBody=  res.getBody(); 
        Map<String,Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(resBody);
        String accessToken = String.valueOf(resMap.get(ACCESS_TOKEN));
        return accessToken;
    }

    /************************************************************************************************************
    @ method:           getHCOs 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          Use Entity endpoint for Reltio API to get HCO information
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 28.12.2020 / Ayush Basak / Created the method
    ************************************************************************************************************/
    public static List<AGN_Reltio_Entity_Wrapper_Class> getHCOs(sObject acaRecord, String type){
        
        type = type.substring(0,type.length()-3);
        System.debug(type);

        // Generating access token
         String accessToken = AGN_Reltio_Service_Class.authenticateReltio();

        // Getting filter string for the service call
        String filters = AGN_Reltio_Service_Class.getFilterList(acaRecord, type);

        // Getting fields list to be fetched 
        String fields = AGN_Reltio_Service_Class.getFieldList((String)acaRecord.get('Country_Code_AGN__c'));

        // Getting API informations from custom setting
        Reltio_API_AGN__c reltio = Reltio_API_AGN__c.getInstance();

        // Building request
        HTTPRequest req = new HTTPRequest();
        String endpoint = reltio.Tenant_URL_AGN__c + reltio.Enpoint_AGN__c 
                            + '?' + OPTIONS 
                            + '&' + MAX + '=' + MAX_VALUE
                            + '&' + FILTER + '=' + filters
                            + '&' + SELECTFIELD + '=' + fields;
        req.setEndpoint(endpoint);
        req.setMethod(GET);
        req.setHeader(AUTHORIZATION, BEARER + ' ' + accessToken);
        req.setHeader(CONTENT_TYPE, URLENCODED);
        req.setTimeout(120000);
        System.debug(req);

        // Making the callout
        Http http = new Http();
        HTTPResponse res = http.send(req);       
        
        // Reading the response and deserializing using custom method
        String resBody =  res.getBody(); 

        List<AGN_Reltio_Entity_Wrapper_Class> reltioEntitiesSimplified 
                    = AGN_Reltio_Entity_Wrapper_Class.deserialize(
                        resBody, (String)acaRecord.get('Country_Code_AGN__c'), type
                        ); 
        
        return reltioEntitiesSimplified;
    }

    /************************************************************************************************************
    @ method:           getFieldList 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          Uses Reltio_Select_Field_AGN__mdt data to create the common separated list of fields 
                        to be returned by Reltio
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 28.12.2020 / Ayush Basak / Created the method
    ************************************************************************************************************/
    private static String getFieldList(String countryCode){ 

        String selectFields = '';

        // Fetching Field List from metadata based on country code
        List<Reltio_Select_Field_AGN__mdt> fetchFields;
        fetchFields = [SELECT Reltio_Field_AGN__c 
                        FROM Reltio_Select_Field_AGN__mdt 
                        WHERE Country_Code_AGN__c =: countryCode
                        WITH SECURITY_ENFORCED ];

        // If no fields are configured for the country, fetch default list of fields
        if (fetchFields.isEmpty()) {
            fetchFields = [SELECT Reltio_Field_AGN__c 
                            FROM Reltio_Select_Field_AGN__mdt 
                            WITH SECURITY_ENFORCED];
        }
                                                            
        // Building comma separated list of fields
        for (Reltio_Select_Field_AGN__mdt field : fetchFields) {
            selectFields = selectFields + ',' + field.Reltio_Field_AGN__c;
        }
        selectFields = selectFields.substring(1,selectFields.length());

        return selectFields;
    }
    

    /************************************************************************************************************
    @ method:           getFilterList 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          Uses data to create the filter string for Reltio Entity API
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 28.12.2020 / Ayush Basak / Created the method
    ************************************************************************************************************/
    private static String getFilterList(sObject record, String type){ 
        string filters = '';
        System.debug(type);
        // Fetching full filter condtion based on country code
        List<Reltio_Filter_String_AGN__mdt> filterStrings;
        filterStrings = [SELECT Full_Condition_String_AGN__c 
                            FROM Reltio_Filter_String_AGN__mdt 
                            WHERE Country_Code_AGN__c = 
                                :(String)record.get('Country_Code_AGN__c')
                            AND DeveloperName LIKE :('%'+type+'%')
                            WITH SECURITY_ENFORCED 
                            LIMIT 1];

        // If no records returned based on country, fetching default values
        if (filterStrings.isEmpty()) {
            List<Reltio_Filter_String_AGN__mdt> filterList = [SELECT Full_Condition_String_AGN__c, Country_Code_AGN__c 
                                                              FROM Reltio_Filter_String_AGN__mdt 
                                                              WHERE DeveloperName = :type
                                                              WITH SECURITY_ENFORCED];
            for(Reltio_Filter_String_AGN__mdt rfs : filterList) {
                if(rfs.Country_Code_AGN__c == NULL) {
                    filterStrings = new List<Reltio_Filter_String_AGN__mdt>();
                    filterStrings.add(rfs);
                }
            }
            
        }                                                    
        if(!filterStrings.isEmpty()) {
            filters = filterStrings[0].Full_Condition_String_AGN__c;
        }
        System.debug(filters);
        // Fetching list of individual conditions and their field mappings
        List<Reltio_Filter_Condition_AGN__mdt> conditions = [SELECT DeveloperName, Condition_AGN__c, 
                                                                sObject_AGN__c, Field_Name_AGN__c 
                                                                FROM Reltio_Filter_Condition_AGN__mdt 
                                                                WITH SECURITY_ENFORCED];
        
        // Storing condition in map for easy assessiblity from at later point, with DeveloperName as Key
        Map<String,Reltio_Filter_Condition_AGN__mdt> conditionMap 
                = new Map<String,Reltio_Filter_Condition_AGN__mdt>();
        for (Reltio_Filter_Condition_AGN__mdt condition : conditions) {
            conditionMap.put(condition.DeveloperName, condition);
        }
        

        // Iterate as long as there is merge placeholder available in the filter string
        while (true) {

            // Check is all the placeholders in the filter string has been removed and break
            if(! filters.contains('{{')) {
                break;
            }

            // Getting the placeholder key
            String key = filters.substring(filters.indexOf('{{')+2,filters.indexOf('}}'));
            
            // Getting the condition from the metadata map based on the placeholder key
            Reltio_Filter_Condition_AGN__mdt condition = conditionMap.get(key);
            String filterCondition = condition.Condition_AGN__c;

            // Checking if the condition has a placeholder text
            if(filterCondition.contains('{{')) {
                // Replacing the placeholder in the condition with value from the field 
                if(record.get(condition.Field_Name_AGN__c) != null) {
                    String replaceValue = String.valueOf(record.get(condition.Field_Name_AGN__c));
                    filterCondition = filterCondition.replace('{{key}}',replaceValue);
                }
                else {
                    filterCondition = '';
                }
            }

            // Replacing the placeholders from filter string with the calculated condition
            filters = filters.replace('{{'+key+'}}', filterCondition);
            // To handle if any of the attributes are null
            filters = filters.replace('and  and', 'and');
            filters = filters.replace('or  or', 'or');
            filters = filters.replace('or  and', 'and');
            filters = filters.replace('and  or', 'and');
            filters = filters.replace('( or', '(');
            filters = filters.replace('( and', '(');
            filters = filters.replace('or )', ')');
            filters = filters.replace('and )', ')');
            filters = filters.replace('  ', ' ');
        }

        // URL Encoding the filter string to allow special characters to be passed in the filter
        filters = EncodingUtil.urlEncode(filters, UTF_ENCODING);

        return filters;
    }
}