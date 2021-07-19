public class AGN_FLSCheck {
    
    private String operation;    
    public static List<String> exclusionList = new List<String>
    {
            'LastModifiedDate',
            'Id',
            'CreatedById',
            'IsDeleted',
            'CreatedDate',
            'LastModifiedById',
            'SystemModstamp',
            'IsLocked',
            'MayEdit',
            'LastViewedDate',
            'LastReferencedDate',
            'FederationIdentifier'
     };
        
    public static void check(SObject obj, SObjectType myType, String operationType) {
        List<SObject> objList = new List<SObject>();
        objList.add(obj);
        check(objList, myType, operationType);
    }
    
    public static void checkObjectAccess(SObjectType myType, String operationType){
        switch on operationType {
            when 'INSERT' {
                if (myType.getDescribe().isCreateable()) {
                	throw new AGN_CommonException('Insufficient permission to Insert on object ' + myType);
                }
            }
            when 'UPDATE' {
                if (myType.getDescribe().isUpdateable()) {
                	throw new AGN_CommonException('Insufficient permission to Update on object ' + myType);
                }
            }
            when 'UPSERT' {
                if (myType.getDescribe().isCreateable() && myType.getDescribe().isUpdateable()) {
                	throw new AGN_CommonException('Insufficient permission to Insert/Update on object ' + myType);
                }
            }
            when 'DELETE' {
                if (myType.getDescribe().isAccessible() && myType.getDescribe().isDeletable()) {
                	throw new AGN_CommonException('Insufficient permission to Delete on object ' + myType);
                }
            }
        }
    }
                             
    public static void check(List<SObject> objList, SObjectType myType, String operationType) {
        
        //checkObjectAccess(myType, operationType);
            
       /* List<String> affectedFields = new List<String>();
        for (SObject so : objList) {
            Map<String, Schema.SObjectField> fieldMap = myType.getDescribe().fields.getMap();
            for (String fieldName : so.getPopulatedFieldsAsMap().keySet()) {
                
                if (exclusionList.contains(fieldName)){
                    continue;
                }
                
                Schema.SObjectField myField = fieldMap.get(fieldName); 
                if (myField == null){                    
                    continue;                          
                }  
                else if( myField.getDescribe().isCalculated() 
                        || myField.getDescribe().isAutoNumber() 
                        || myField.getDescribe().getType() == Schema.DisplayType.REFERENCE)
                {
                    continue;    
                }
                switch on operationType {
                    when 'INSERT' {
                        if (!myField.getDescribe().isCreateable()) {
                            affectedFields.add(''+myField);
                        }
                    }
                    when 'UPDATE' {
                        if (!myField.getDescribe().isUpdateable()) {
                            affectedFields.add(''+myField);
                        }
                    }
                    when 'UPSERT' {
                        if (!myField.getDescribe().isCreateable() && !myField.getDescribe().isUpdateable()){
                            affectedFields.add(''+myField);
                        }
                    }
                }
            }
            
            if(!affectedFields.isEmpty()){
                switch on operationType {
                    when 'INSERT' {
                        system.debug('SO>>>'+affectedFields);
                        throw new AGN_CommonException('Insufficient permission to create this object/fields: ' + myType + ' / ' + affectedFields);
                    }
                    when 'UPDATE' {
                        system.debug('SO>>>'+affectedFields);
                        throw new AGN_CommonException('Insufficient permission to update this object/fields: ' + myType + ' / ' + affectedFields);
                    }
                    when 'UPSERT' {
                        system.debug('SO>>>'+affectedFields);
                        throw new AGN_CommonException('Insufficient permission to create or update this object/fields: ' + myType + ' / ' + affectedFields);
                    }
                }
            }
        }*/
    }
}