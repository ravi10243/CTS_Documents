/****************************************************************************************************************
@ Constructor:    AGN_Reltio_Entity_Wrapper_Class 
@ Version:        1
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        To deserialize responses from Reltio Entity API
-----------------------------------------------------------------------------------------------------------------
@ Change history: 28.12.2020 / Ayush Basak / Created the class.
****************************************************************************************************************/
public with sharing class AGN_Reltio_Entity_Wrapper_Class {
    
    // Static String Constants 
    private final static String ATTRIBUTE = 'attributes';
    private final static String VEEVA = 'Veeva';
    //Added for displaying SAP ID//
    private static final String SAP = 'SAP';
    //Added for displaying SAP ID//
    private final static String VALUE_STRING = 'value';
    private final static String IDENTIFIERS = 'Identifiers';
    private final static String TYPE = 'Type';
    private final static String NAME_STRING = 'Name';
    private final static String ID = 'ID';
    private final static String SPLIT_REGEX = '\\.';

    // Fields to store data in simplified form

    // Account Id for the matching record
    @AuraEnabled
    public String accountId;
    // Name of the veeva account, to be displayed on the top of the card
    @AuraEnabled
    public String name;
    //Added for displaying SAP ID//
    @AuraEnabled
    public String sapId;
    //Added for displaying SAP ID//
    // Map of all other fields to be displayed on the card
    @AuraEnabled
    public Map<String,String> data;

    /************************************************************************************************************
    @ method:           deserialize 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          Custom deserialization method, to traverse and retrieve data for only those field marked 
                        for display in Reltio Select Field metadata 
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 08.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    public static List<AGN_Reltio_Entity_Wrapper_Class> deserialize(String jsonString, 
                                                                    String countryCode, 
                                                                    String Type) {
        
        List<Reltio_Select_Field_AGN__mdt> fieldParsing;
        fieldParsing = [SELECT Display_Label_AGN__c, Is_Visible_AGN__c, Parsing_Schema_AGN__c
                        FROM Reltio_Select_Field_AGN__mdt 
                        WHERE Country_Code_AGN__c =: countryCode 
                        AND Supported_Objects_AGN__c LIKE :('%'+type+'%')
                        WITH SECURITY_ENFORCED 
                        ORDER BY Display_Order_AGN__c];
        

        // If no fields are configured for the country, fetch default list of fields
        if (fieldParsing.isEmpty()) {
            
            fieldParsing = [SELECT Display_Label_AGN__c, Is_Visible_AGN__c, Parsing_Schema_AGN__c 
                            FROM Reltio_Select_Field_AGN__mdt 
                            WHERE Supported_Objects_AGN__c LIKE :('%'+type+'%')
                            WITH SECURITY_ENFORCED
                            ORDER BY Display_Order_AGN__c];
        }   
        //system.debug('type------->'+type);                                                             
		//system.debug('fieldParsing1------->' +fieldParsing);
        List<AGN_Reltio_Entity_Wrapper_Class> duplicates = new List<AGN_Reltio_Entity_Wrapper_Class>();
        
        // Deserializing into untyped object list
        List<Object> entities = (List<Object>)JSON.deserializeUntyped(jsonString);

        // For each object in the list, fetch the fields mention in the metadata
        for(Object entity : entities) {

            AGN_Reltio_Entity_Wrapper_Class duplicate = new AGN_Reltio_Entity_Wrapper_Class();
            // Getting the Name for the Account
            duplicate.name = AGN_Reltio_Entity_Wrapper_Class.getName(entity);
            // Getting the Id for the Account
            duplicate.accountId = AGN_Reltio_Entity_Wrapper_Class.getId(entity);
            // Getting other field data for the Account
            //Added for displaying SAP ID//
             duplicate.sapId = AGN_Reltio_Entity_Wrapper_Class.getsapId(entity);
            //Added for displaying SAP ID//
            duplicate.data = new Map<String, String>();
            //system.debug('fieldParsing' +fieldParsing);
            for(Reltio_Select_Field_AGN__mdt field : fieldParsing) {
                //system.debug('field------>'+field);
                if(field.Is_Visible_AGN__c) {
                    //Added for displaying SAP ID//
                    if(field.Display_Label_AGN__c.containsIgnoreCase(SAP)){
                      system.debug('field.Display_Label_AGN__c' +field.Display_Label_AGN__c);
                      duplicate.data.put(field.Display_Label_AGN__c, 
                                       duplicate.sapId);  
                    }
                    //Added for displaying SAP ID//
                    else{
                        duplicate.data.put(field.Display_Label_AGN__c, 
                                       AGN_Reltio_Entity_Wrapper_Class.getValue(entity, 
                                                                                field.Parsing_Schema_AGN__c));
                    }
                    
                }
            }
            duplicates.add(duplicate);
        }
         //system.debug('duplicatelist------->' +duplicates);                                                               
        return duplicates;
    }

    /************************************************************************************************************
    @ method:           getValue 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This method accepts an object and a dot separated path for a field, and returns the value 
                        from the object for the particular field
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 08.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    private static String getValue(Object entity, String fieldTree) {
       //system.debug('fieldTree'+fieldTree);
        String value = '';
        
        // Getting list nodes to traverse
        
        List<String> fieldTreeList = fieldTree.split(SPLIT_REGEX);
        
        //system.debug('fieldTreeList'+fieldTreeList);
        Object tempObject = entity;
        //system.debug('tempObject----->'+tempObject);
        // Traversing through the node list
        for(String field : fieldTreeList) {
            //Checking if the node contains list
            if(tempObject instanceOf List<Object>) {
               
                // If node is list, picking up the zero'th element, converting to map of string and object
                // and then fetching the next node. 
                List<Object> tempObjToList = (List<Object>)tempObject;
                //system.debug('tempObjToList-------->'+JSONtempObjToList);
                Map<String, Object> tempListToMap = (Map<String, Object>)(tempObjToList[0]); 
                if(tempObject != null) {
                    tempObject = tempListToMap.get(field);
                }
            }
            else {
                // If node is object, fetching the next node directly
                if(tempObject != null) {
                    tempObject = ((Map<String,Object>)tempObject).get(field);
                }
                
            }
        }
        // Converting last node to string and returning
        value = String.valueOf(tempObject);
        //system.debug('value-------->' +value);
        return value;
    }

    /************************************************************************************************************
    @ method:           getName 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This method accepts an object and traverse through particular nodes to get the Name of 
                        the account 
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 08.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    private static String getName(Object entity) {
        // Entity -> Attributes -> Name[] -> value
        Object attributes = ((Map<String,Object>)entity).get(ATTRIBUTE);
        //system.debug('attributes------------>'+String.valueOf(attributes));
        List<Object> names = (List<Object>)(((Map<String,Object>)attributes).get(NAME_STRING));
        //system.debug('names------------>'+names);
        Object value = ((Map<String,Object>)names[0]).get(VALUE_STRING);
        //system.debug('value------------>'+String.valueOf(value));
        return String.valueOf(value);
    }

    /************************************************************************************************************
    @ method:           getId 
    @ Version:          1.0
    @ Author:           Ayush Basak  (ayush.basak@cognizant.com)
    @ Purpose:          This method accepts an object and traverse through particular nodes to get the Id of 
                        the account. Reltio returns multiple types of Ids, type of each identifier is checked 
                        whether is for Veeva or any other system.
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 08.01.2021 / Ayush Basak / Created the method
    ************************************************************************************************************/
    private static String getId(Object entity) {
        // Entity -> Attributes -> Indentifiers[Where Type[].Value contains '%Veeva%'] -> ID[] -> value
        Object attributes = ((Map<String,Object>)entity).get(ATTRIBUTE);
        List<Object> identifiers = (List<Object>)(((Map<String,Object>)attributes).get(IDENTIFIERS));
        Object value;
        for(Object identifier : identifiers) {
            Object idValue = ((Map<String,Object>)identifier).get(VALUE_STRING);
            List<Object> types = (List<Object>)(((Map<String,Object>)idValue).get(TYPE));
            Object type = ((Map<String,Object>)(types[0])).get(VALUE_STRING);
            if(String.valueOf(type).containsIgnoreCase(VEEVA)) {
                List<Object> ids = (List<Object>)(((Map<String,Object>)idValue).get(ID));
                value = ((Map<String,Object>)(ids[0])).get(VALUE_STRING);
                break;
            }
        }
        return String.valueOf(value);
    }
    
    /************************************************************************************************************
    @ method:           getsapId 
    @ Version:          1.0
    @ Author:           Aritra Majumder (aritra.majumder@cognizant.com)
    @ Purpose:          This method accepts an object and traverse through particular nodes to get the SAP Id of 
                        the account. Reltio returns multiple types of Ids, type of each identifier is checked 
                        whether is for Veeva or any other system.
    -------------------------------------------------------------------------------------------------------------
    @ Change history: 17.16.2021 / Aritra Majumder / Created the method
    ************************************************************************************************************/
    private static String getsapId(Object entity) {
        // Entity -> Attributes -> Indentifiers[Where Type[].Value contains '%Veeva%'] -> ID[] -> value
        Object attributes = ((Map<String,Object>)entity).get(ATTRIBUTE);
        List<Object> identifiers = (List<Object>)(((Map<String,Object>)attributes).get(IDENTIFIERS));
        Object value;
        for(Object identifier : identifiers) {
            Object idValue = ((Map<String,Object>)identifier).get(VALUE_STRING);
            List<Object> types = (List<Object>)(((Map<String,Object>)idValue).get(TYPE));
            Object type = ((Map<String,Object>)(types[0])).get(VALUE_STRING);
            if(String.valueOf(type).containsIgnoreCase(SAP)) {
                List<Object> ids = (List<Object>)(((Map<String,Object>)idValue).get(ID));
                value = ((Map<String,Object>)(ids[0])).get(VALUE_STRING);
                break;
            }
        }
        return String.valueOf(value);
    }
}