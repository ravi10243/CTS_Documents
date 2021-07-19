@isTest
private class QueryStringGeneratorTest {

    private static String getParentObjectNameField(Schema.SObjectField field) {
        String relationshipName = field.getDescribe().getRelationshipName();
        Schema.SObjectType parentSObjectType = field.getDescribe().getReferenceTo()[0];
        String nameField;
        for(Schema.SObjectField parentField : parentSObjectType.getDescribe().fields.getMap().values()) {
            if(parentField.getDescribe().isNameField()) {
                nameField = parentField.getDescribe().getName();
                break;
            }
        }
        return relationshipName + '.' + nameField;
    }

    @isTest
    static void getReadableFields() {
        Schema.SObjectType accountSObjectType = Schema.Account.SObjectType;
        Set<String> expectedFieldNames = new Set<String>();
        Map<String, Schema.SObjectField> fieldMap = accountSObjectType.getDescribe().fields.getMap();

        for(Schema.SObjectField field : fieldMap.values()) {
            if(!field.getDescribe().isAccessible()) continue;

            expectedFieldNames.add(field.getDescribe().getName());

            if(field.getDescribe().getType().name() == 'Reference') {
                String parentNameField = getParentObjectNameField(field);
                expectedFieldNames.add(parentNameField);
            }
        }

        Test.startTest();
        QueryStringGenerator gen = new QueryStringGenerator(accountSObjectType);
        for(String fieldName : gen.getReadableFields()) {
            System.assert(expectedFieldNames.contains(fieldName));

            if(fieldName.contains('.')) continue; // Skip checking FLS for parent fields

            Schema.SObjectField field = fieldMap.get(fieldName);
            System.assert(field.getDescribe().isAccessible());
        }
        Test.stopTest();
    }

    @isTest
    static void getReadableFieldsWithAdditionalFields() {
        Schema.SObjectType accountSObjectType = Schema.Account.SObjectType;
        List<String> additionalFields = new List<String>{'Owner.Profile.Description', 'Owner.UserRole.DeveloperName'};
        QueryStringGenerator gen = new QueryStringGenerator(accountSObjectType);

        Test.startTest();
        // Make sure that the additional fields aren't automatically added (false positive)
        for(String fieldName : additionalFields) {
            Set<String> returnedFields = new Set<String>(gen.getReadableFields());
            System.assert(returnedFields.contains(fieldName) == false, returnedFields);
        }
        // Add the fields and recheck to make sure that they are now in the returned list
        gen.includeFields(additionalFields);
        for(String fieldName : additionalFields) {
            Set<String> returnedFields = new Set<String>(gen.getReadableFields());
            System.assert(returnedFields.contains(fieldName) == true, returnedFields);
        }
        Test.stopTest();
    }

    @isTest
    static void getReadableFieldsQuery() {
        Schema.SObjectType accountSObjectType = Schema.Account.SObjectType;

        Test.startTest();
        QueryStringGenerator gen = new QueryStringGenerator(accountSObjectType);
        // Execute the query to make sure that the return query string is valid
        Database.query(gen.getReadableFieldsQuery());
        Test.stopTest();
    }

}