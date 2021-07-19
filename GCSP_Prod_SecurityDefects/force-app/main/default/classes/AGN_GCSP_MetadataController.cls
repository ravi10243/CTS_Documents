/**
 * @description       : Get the behaviour of the field and sobject like CRED permissions and field type.
 * @author            : GCSP Core Plus Dev Team
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
 * Modifications Log  :
 * Ver   Date         Author       					Modification
 * 1.0   01-04-2021   GCSP Core Plus Dev Team   	Initial Version
**/
public without sharing class AGN_GCSP_MetadataController {
    
     @AuraEnabled(cacheable=true)
    public static SObjectMetadata getSObjectMetadata(String sobjectName) {
        try {
            return new SObjectMetadata(sobjectName);
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static FieldMetadata getFieldMetadata(String sobjectName, String fieldName, String controllingFieldValue) {
       system.debug('sobjectName : '+sobjectName+' fieldName: '+fieldName + ' controllingFieldValue: ' + controllingFieldValue);
       // try {
            controllingFieldValue = String.isEmpty(controllingFieldValue) ? '' : controllingFieldValue;
            return new FieldMetadata(sobjectName, fieldName, controllingFieldValue, null);            
      /*  } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }*/
    }
    //added for PT
    @AuraEnabled(cacheable=true)
    public static List<FieldMetadata> getAllFieldsMetadata(String fieldListJson) {
        system.debug('fieldListJson : =='+fieldListJson);
        List<fieldObjectWrapper> fieldList = (List<fieldObjectWrapper>) System.JSON.deserialize(fieldListJson, List<fieldObjectWrapper>.class);
        system.debug('fieldList : =='+fieldList);

        Map<String,List<fieldObjectWrapper>> objFieldMap = new Map<String, List<fieldObjectWrapper>>();
        List<FieldMetadata> filedMetadataList = new List<FieldMetadata>();
        for(fieldObjectWrapper fieldInfo : fieldList){
            system.debug('sobjectName : == '+fieldInfo.sobjectName+' fieldName: '+fieldInfo.fieldName + ' controllingFieldValue: ' + fieldInfo.controllingFieldValue);
            if(objFieldMap.containsKey(fieldInfo.sobjectName)){
                objFieldMap.get(fieldInfo.sobjectName).add(fieldInfo);
            }
            else{
                objFieldMap.put(fieldInfo.sobjectName, new list<fieldObjectWrapper>{fieldInfo});
            }
        }
        for (string sObjName : objFieldMap.keyset()){
            SObjectMetadata sobjectDescribe = new SObjectMetadata(sObjName);
            for( fieldObjectWrapper field : objFieldMap.get(sObjName)){               
                string ValueOfControllingField = String.isEmpty(field.controllingFieldValue) ? '' : field.controllingFieldValue;
                filedMetadataList.add(new FieldMetadata(field.sobjectName, field.fieldName, ValueOfControllingField, sobjectDescribe));
            }   
        }

        return filedMetadataList;                
    }
    //added for PT
    private class fieldObjectWrapper{
        @AuraEnabled public String sobjectName {get; set;}
        @AuraEnabled public String fieldName {get; set;}
        @AuraEnabled public String controllingFieldValue {get; set;}
    }

    public class SObjectMetadata {
        @AuraEnabled public String name           {get;private set;}
        @AuraEnabled public Boolean isAccessible  {get;private set;}
        @AuraEnabled public Boolean isCreateable  {get;private set;}
        @AuraEnabled public Boolean isDeletable   {get;private set;}
        @AuraEnabled public Boolean isMergeable   {get;private set;}
        @AuraEnabled public Boolean isQueryable   {get;private set;}
        @AuraEnabled public Boolean isSearchable  {get;private set;}
        @AuraEnabled public Boolean isUndeletable {get;private set;}
        @AuraEnabled public Boolean isUpdateable  {get;private set;}
        @AuraEnabled public String label          {get;private set;}
        @AuraEnabled public String labelPlural    {get;private set;}
        @AuraEnabled public String nameField      {get;private set;}
        
        public Schema.DescribeSObjectResult sobjectDescribe {get;private set;}
        
        public SObjectMetadata(String sobjectName) {
            this.name            = sobjectName;
            this.sobjectDescribe = Schema.describeSObjects(new String[]{sobjectName}).get(0);
            //this.sobjectDescribe = Schema.getGlobalDescribe().get(sobjectName).getDescribe();
            
            this.isAccessible  = this.sobjectDescribe.isAccessible();
            this.isCreateable  = this.sobjectDescribe.isCreateable();
            this.isDeletable   = this.sobjectDescribe.isDeletable();
            this.isMergeable   = this.sobjectDescribe.isMergeable();
            this.isQueryable   = this.sobjectDescribe.isQueryable();
            this.isSearchable  = this.sobjectDescribe.isSearchable();
            this.isUndeletable = this.sobjectDescribe.isUndeletable();
            this.isUpdateable  = this.sobjectDescribe.isUpdateable();
            this.label         = this.sobjectDescribe.getLabel();
            this.labelPlural   = this.sobjectDescribe.getLabelPlural();
            
            this.setNameField();
        }
        
        private void setNameField() {
            for(Schema.SObjectField field : this.sobjectDescribe.fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                
                if(fieldDescribe.isNameField()) {
                    this.nameField = fieldDescribe.getName();
                    break;
                }
            }
        }
    }
    
    public class FieldMetadata {
        @AuraEnabled public String name                                 {get;private set;}
        @AuraEnabled public String sobjectName                          {get;private set;}
        @AuraEnabled public SObjectMetadata sobjectMetadata             {get;private set;}
        @AuraEnabled public Object defaultValue                         {get;private set;}
        @AuraEnabled public String displayType                          {get;private set;}
        @AuraEnabled public String inlineHelpText                       {get;private set;}
        @AuraEnabled public Boolean isAccessible                        {get;private set;}
        @AuraEnabled public Boolean isCreateable                        {get;private set;}
        @AuraEnabled public Boolean isDefaultedOnCreate                 {get;private set;}
        @AuraEnabled public Boolean isFilterable                        {get;private set;}
        @AuraEnabled public Boolean isNameField                         {get;private set;}
        @AuraEnabled public Boolean isSortable                          {get;private set;}
        @AuraEnabled public Boolean isUpdateable                        {get;private set;}
        @AuraEnabled public String label                                {get;private set;}
        @AuraEnabled public Integer maxLength                           {get;private set;}
        @AuraEnabled public Boolean required                            {get;private set;}
        @AuraEnabled public List<PicklistEntryMetadata> picklistOptions {get;private set;}
        
        public Schema.DescribeFieldResult fieldDescribe {get;private set;}
        
        public FieldMetadata(String sobjectName, String fieldName, String controllingFieldValue, SObjectMetadata sobjectDetails) {
            this.sobjectName     = sobjectName;
            this.name            = fieldName;
            this.sobjectMetadata = new SObjectMetadata(sobjectName);
            this.picklistOptions = new List<PicklistEntryMetadata>();
            
            //String obj = sobjectName;
            //SObjectType sObjType = ((SObject)(Type.forName('Schema.'+obj).newInstance())).getSObjectType();
            //System.debug(Schema.SObjectType.sObjType.fields.fieldName.getType());
            //this.fieldDescribe =  Schema.describeSObjects(new String[]{sobjectName}).get(0).fields.getMap().get(fieldName).getDescribe();
			//this.fieldDescribe = Schema.getGlobalDescribe().get(sobjectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
            
            //added for PT - sobjectDetails null chek has been added to maintain the exiting field metada constructor
            if(sobjectDetails == null){
                this.fieldDescribe =  Schema.describeSObjects(new String[]{sobjectName}).get(0).fields.getMap().get(fieldName).getDescribe();
            }
            else {
                this.fieldDescribe = sobjectDetails.sobjectDescribe.fields.getMap().get(fieldName).getDescribe();
            }
            
            this.defaultValue        = this.fieldDescribe.getDefaultValue();
            this.displayType         = this.fieldDescribe.getType().name();
            this.inlineHelpText      = this.fieldDescribe.getInlineHelpText();
            this.isDefaultedOnCreate = this.fieldDescribe.isDefaultedOnCreate();
            this.isFilterable        = this.fieldDescribe.isFilterable();
            this.isNameField         = this.fieldDescribe.isNameField();
            this.isSortable          = this.fieldDescribe.isSortable();
            this.label               = this.fieldDescribe.getLabel();
            this.maxLength           = this.fieldDescribe.getLength();
            this.required            = this.fieldDescribe.isNillable() == false; // If a field is NOT nillable, then it's required
            this.isAccessible        = this.fieldDescribe.isAccessible();
            this.isCreateable        = this.fieldDescribe.isCreateable();
            this.isUpdateable        = this.fieldDescribe.isUpdateable();
            if(this.fieldDescribe.getType().name()=='PICKLIST')
            {
                this.setPicklistOptions(controllingFieldValue);
            }            
        }
        
        private void setPicklistOptions(String controllingFieldValue) {
            Schema.DisplayType fieldDisplayType = this.fieldDescribe.getType();
            if(fieldDisplayType != Schema.DisplayType.Picklist && fieldDisplayType != Schema.DisplayType.MultiPicklist) {
                return;
            }
            
            Schema.sObjectField controlToken = this.fieldDescribe.getController();
            this.picklistOptions.add(new PicklistEntryMetadata()); // Empty picklist value

            if ( controlToken == null ) {
                for(Schema.PicklistEntry picklistEntry : this.fieldDescribe.getPickListValues()) {
                    this.picklistOptions.add(new PicklistEntryMetadata(picklistEntry));
                }
            }
            else {
                integer controllingIndex = -1;
                Schema.DescribeFieldResult control = controlToken.getDescribe();
                List<Schema.PicklistEntry> controlEntries =
                    (   control.getType() == Schema.DisplayType.Boolean
                     ?   null
                     :   control.getPicklistValues()
                    );
                for ( Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++ )
                {
                    if(controlEntries == null) {
                        controllingIndex = 1;
                        break;
                    }
                    if(controlEntries[index].isActive() 
                        && controlEntries[index].getLabel() == controllingFieldValue) {
                        controllingIndex = index;
                        break;
                    }
                }
                String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
                Map<String,List<Schema.PicklistEntry>> dependentPicklistValues = new Map<String,List<Schema.PicklistEntry>>();
                if(controllingIndex != -1) {
                    for ( Schema.PicklistEntry entry : this.fieldDescribe.getPicklistValues() ) {
                        if ( entry.isActive() ) {
                            if(JSON.serialize( entry ).contains('validFor')) {
                                List<String> base64chars =
                                    String.valueOf
                                    (((Map<String,Object>) 
                                        JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')
                                    ).split( '' );
                                Integer bitIndex = controllingIndex / 6;
                                Integer bitShift = 5 - Math.mod( controllingIndex, 6 );
                                if(base64chars.size() <= bitIndex) {
                                    continue;
                                }
                                if ((base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0) {
                                    continue;
                                }
                                this.picklistOptions.add(new PicklistEntryMetadata(entry));
                            }
                        }
                    }
                }
                else {
                    for ( Schema.PicklistEntry entry : this.fieldDescribe.getPicklistValues() ) { 
                        this.picklistOptions.add(new PicklistEntryMetadata(entry));
                    }
                }
                system.debug(this.picklistOptions);
            }            
        }
    }
    @Testvisible
    private class PicklistEntryMetadata {
        @AuraEnabled public String label           {get;private set;}
        @AuraEnabled public String value           {get;private set;}
        @AuraEnabled public Boolean isDefaultValue {get;private set;}
        
        private Schema.PicklistEntry picklistEntry;
        
        public PicklistEntryMetadata() {
            this.label          = '';
            this.value          = '';
            this.isDefaultValue = false;
        }
        
        public PicklistEntryMetadata(Schema.PicklistEntry picklistEntry) {
            this.picklistEntry  = picklistEntry;
            
            this.label          = picklistEntry.getLabel();
            this.value          = picklistEntry.getValue();
            this.isDefaultValue = picklistEntry.isDefaultValue();
        }
    }
    
    public static String getLabelString(String labelName ){
        Component.Apex.OutputText output = new Component.Apex.OutputText();
        output.expressions.value = '{!$Label.' + labelname + '}';
        return String.valueOf(output.value);
    } 

}