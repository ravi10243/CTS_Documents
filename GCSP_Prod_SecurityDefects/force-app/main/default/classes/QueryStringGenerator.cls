public with sharing class QueryStringGenerator {

    private Schema.SObjectType sobjectType;
    private Schema.DescribeSObjectResult describeResult;
    private Map<String, Schema.SObjectField> allFieldsMap;
    private List<Schema.SObjectField> fieldsToCheck;
    private List<String> additionalFields;

    public QueryStringGenerator(Schema.SObjectType sobjectType) {
        this.sobjectType = sobjectType;

        this.describeResult   = this.sobjectType.getDescribe();
        this.allFieldsMap     = this.describeResult.fields.getMap();
        this.fieldsToCheck    = this.allFieldsMap.values();
        this.additionalFields = new List<String>();
    }

    public void includeFields(List<String> additionalFields) {
        this.additionalFields.addAll(additionalFields);
    }

    public List<String> getReadableFields() {
        List<String> readableFields = new List<String>();
        for(Schema.SObjectField field : this.fieldsToCheck) {
            if(!field.getDescribe().isAccessible()) continue;

            readableFields.add(field.getDescribe().getName());

            // If the field is a lookup, then we need to get the name field from the parent object
            if(field.getDescribe().getType().name() == 'Reference') {
                String parentNameField = this.getParentObjectNameField(field);
                if(parentNameField != null) readableFields.add(parentNameField);
            }
        }

        readableFields.addAll(this.additionalFields);
        return readableFields;
    }

    public String getReadableFieldsQuery() {
        return this.createQuery(this.getReadableFields());
    }

    private String getParentObjectNameField(Schema.SObjectField field) {
        String relationshipName = field.getDescribe().getRelationshipName();
        Schema.SObjectType parentSObjectType = field.getDescribe().getReferenceTo()[0];
        String nameField;
        for(Schema.SObjectField parentField : parentSObjectType.getDescribe().fields.getMap().values()) {
            if(parentField.getDescribe().isNameField()) {
                nameField = parentField.getDescribe().getName();
                break;
            }
        }
        if(relationshipName == null) return null;
        if(nameField == null) return null;
        return relationshipName + '.' + nameField;
    }

    private String createQuery(List<String> fieldNamesList) {
        return 'SELECT ' + String.join(fieldNamesList, ', ')
            + ' FROM ' + this.sobjectType + ' ';
    }

}