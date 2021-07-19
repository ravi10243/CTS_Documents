public class F3_ChildObjectController {
    @AuraEnabled
    public static List<String> GetComponentConfigJSON(Id mdComponentId, String languageKey)
    {
        String configJSON;
        String localisedConfigJSON;

        List<MDComponent__c> listComponent = [SELECT Id, ConfigJSON__c
                                              FROM MDComponent__c
                                              WHERE Id = :mdComponentId];
        if(!listComponent.isEmpty())
        {
            configJSON = listComponent[0].ConfigJSON__c;
        }
        if(languageKey != 'enGB') {
            
            List<MDLocalisedComponent__c> localisedlistComponent = [SELECT Id, Language__c, ConfigJSON__c
                                                  FROM MDLocalisedComponent__c
                                                  WHERE MDComponent__c = :mdComponentId and Language__c = :languageKey];
            if(!localisedlistComponent.isEmpty())
            {
                localisedConfigJSON = localisedlistComponent[0].ConfigJSON__c;
            }
        }

        
        return new String[] {configJSON, localisedConfigJSON};
    }
    
    @AuraEnabled 
    public static ID GetChildRecordId(string objectAPIName, Id parentRecordId, string parentRelationField)
    {
        string query = 'SELECT Id FROM ' + objectAPIName + ' WHERE ' + parentRelationField + ' = : parentRecordId' ;
        
        List<SObject> listSObject = Database.query(query);
        
        if(listSObject == null || listSObject.size() == 0)
            return null;
        
        return listSObject[0].Id;
    }
    
    @AuraEnabled 
    public static list<sObject> GetChildRecordsMany(string mdComponentId, string objectAPIName, Id parentRecordId, string parentRelationField)
    {
        
        String configJSON;
        List<MDComponent__c> listComponent = [SELECT Id, ConfigJSON__c
                                              FROM MDComponent__c
                                              WHERE Id = :mdComponentId];
        if(!listComponent.isEmpty())
        {
            configJSON = listComponent[0].ConfigJSON__c;
        }
        //String jsonResponse = [select ConfigJSON__c from MDComponent__c where id = 'a044J000001U08hQAC'].ConfigJSON__c;
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(configJSON );
        
        List<Object> lstCustomers = (List<Object>)results.get('ListFieldConfig');

        list<string> lstFieldNames = new list<string>();
        for (Object customer : lstCustomers) {
            // now get attributes for this customer.
            Map<String, Object> customerAttributes = (Map<String, Object>)customer;
            // now loop through our customer attributes.
            for (String attributeName : customerAttributes.keyset()) {
                // handle response
                
                if(attributeName == 'FieldAPIName'){
                    lstFieldNames.add((string)customerAttributes.get(attributeName));
                }
             }
         }
        
        String separator = ', ';
        string soqlFields = String.join(lstFieldNames, separator);
        system.debug('lstFieldNames--'+ lstFieldNames);
        // create dynamic SOQL from JSON 
        string query = 'SELECT Id,' + soqlFields +' FROM ' + objectAPIName + ' WHERE ' + parentRelationField + ' = : parentRecordId' ;
        
        List<SObject> listSObject = Database.query(query);
        
        if(listSObject == null || listSObject.size() == 0)
            return null;
        
        return listSObject;
    }
}