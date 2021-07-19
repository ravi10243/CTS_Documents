/*Class Name: AGN_typeConversionUtil 
Purpose: to utilize same set of code in multiple classes
*/
public class AGN_typeConversionUtil {
    
    public static String getFieldType(String objName, String fieldName){
        
        Schema.DisplayType fieldType = Schema.getGlobalDescribe() 
            .get(objName)
            .getDescribe()
            .fields
            .getMap()
            .get(fieldName)
            .getDescribe()
            .getType();
        String fieldTypeStr = String.valueOf(fieldType);
        return fieldTypeStr;
    }
    
    public static boolean doesFieldExist(String objApiName, string fieldApiName){
        /* used Type.forName for better performance than globalDescribe method like this, 
* SObject objSObjectType = Schema.getGlobalDescribe().get(objApiName).newSObject(); */
        SObjectType sObjType = ((SObject)(Type.forName('Schema.'+objApiName).newInstance())).getSObjectType();
        String fieldApiLowerCase = fieldApiName.toLowerCase(); 
        //getDescribe().fields returns all API names in lowercase, so for comparision converted upperCase to lowerCase.
        return sObjType.getDescribe().fields.getMap().containsKey(fieldApiLowerCase);
    }
    
    public static Boolean convertToBool(String fieldValue){
        if(fieldValue == '1' || fieldValue == 'true'){
            return true;
        }
        else if(fieldValue == '0' || fieldValue == 'false'){
            return false;
        }
        return false;
    }
    
    public static Decimal convertToDecimal(String decStr){
        Decimal tempDecimal = Decimal.valueOf(decStr);
        return tempDecimal;
    }
    public static Date convertToDate (String dateStr){
        Date tempDate = Date.valueOf(dateStr);
        return tempDate;
    }
    public static Datetime convertToDateTime (String datetimeStr){
        //Datetime tempDateTime = DateTime.parse(datetimeStr);
        Datetime tempDateTime = DateTime.ValueofGmt(datetimeStr.replace('T', ' '));
        return tempDateTime;
    }
    public static Id convertToId(String toId){
        Id tempId = toId;
        return tempId;
    }
    public static void setIsMergedToFalse(Account acc){
         String isMerged ='IsMerged_AGN__c';
         acc.put(isMerged, false);
       
    }
    public static void typeCastAndPopulate(Account accMaster, String objName, String fieldName, String fieldValue){
        System.debug('accMasterInUtil #######'+ accMaster.Id);
        String isMerged ='IsMerged_AGN__c';
        String fieldType = AGN_typeConversionUtil.getFieldType(objName, fieldName);
        System.debug('accMasterInUtil_fieldType$$ '+fieldType +'   -   ' +  fieldValue);
        if(fieldType.equalsIgnoreCase('Boolean')){
            System.debug('accMasterInUtil_Bool_Before$$ ');
            accMaster.put(fieldName, convertToBool(fieldValue));
            System.debug('accMasterInUtil_Bool_After$$ ');
        }
        if(fieldType.equalsIgnoreCase('Id')){
            System.debug('accMasterInUtil_Id_Before$$ ');
            accMaster.put(fieldName, convertToId(fieldValue));
            System.debug('accMasterInUtil_Id_After$$ ');
        }
        if((fieldType.equalsIgnoreCase('PICKLIST') || fieldType.equalsIgnoreCase('EMAIL') || fieldType.equalsIgnoreCase('REFERENCE') || 
            fieldType.equalsIgnoreCase('STRING') || fieldType.equalsIgnoreCase('PHONE')) 
            || fieldType.equalsIgnoreCase('TEXTAREA') || fieldType.equalsIgnoreCase('URL') || fieldType.equalsIgnoreCase('MULTIPICKLIST')){
                System.debug('accMasterInUtil_STRING_Before$$ ');
                accMaster.put(fieldName, fieldValue);
                System.debug('accMasterInUtil_STRING_After$$ ');
            }
        if(fieldValue.isNumeric() &&  (fieldType.equalsIgnoreCase('DOUBLE') || fieldType.equalsIgnoreCase('CURRENCY'))){
            System.debug('accMasterInUtil_DOUBLE_Before$$ ');
            accMaster.put(fieldName, convertToDecimal(fieldValue));
            System.debug('accMasterInUtil_DOUBLE_After$$ ');
        }
        if(fieldType.equalsIgnoreCase('Date')){
            accMaster.put(fieldName, convertToDate(fieldValue));
        }
        if(fieldType.equalsIgnoreCase('DateTime')){
            accMaster.put(fieldName, convertToDateTime(fieldValue));
        }
        if(fieldType.equalsIgnoreCase('PERCENT')){
            accMaster.put(fieldName, convertToDecimal(fieldValue));
        }
        if(fieldType.equalsIgnoreCase('INTEGER')){
            accMaster.put(fieldName, integer.ValueOf(fieldValue));
        }
        accMaster.put(isMerged, true);
        
    }
    public static void typeCastAndPopulateProd(Product_Metrics_vod__c prodMat, String objName, String fieldName, String fieldValue){
        System.debug('prodMatInUtil #######'+ prodMat.Id);
        String fieldType = AGN_typeConversionUtil.getFieldType(objName, fieldName);
        System.debug('prodMatInUtil_fieldType$$ '+fieldType +'   -   ' +  fieldValue);
        if(fieldType.equalsIgnoreCase('Boolean')){
            System.debug('prodMatInUtil_Bool_Before$$ ');
            prodMat.put(fieldName, convertToBool(fieldValue));
            System.debug('prodMatInUtil_Bool_After$$ ');
        }
        if((fieldType.equalsIgnoreCase('PICKLIST') || fieldType.equalsIgnoreCase('EMAIL') || fieldType.equalsIgnoreCase('REFERENCE') ||
            fieldType.equalsIgnoreCase('STRING') || fieldType.equalsIgnoreCase('CURRENCY') || fieldType.equalsIgnoreCase('PHONE'))){
                System.debug('prodMatInUtil_STRING_Before$$ ');
                prodMat.put(fieldName, fieldValue);
                System.debug('prodMatInUtil_STRING_After$$ ');
            }
        if(fieldValue.isNumeric() &&  fieldType.equalsIgnoreCase('DOUBLE')){
            System.debug('prodMatInUtil_DOUBLE_Before$$ ');
            prodMat.put(fieldName, convertToDecimal(fieldValue));
            System.debug('prodMatInUtil_DOUBLE_After$$ ');
        }
        if(fieldType.equalsIgnoreCase('Date')){
            prodMat.put(fieldName, convertToDate(fieldValue));
        }
        if(fieldType.equalsIgnoreCase('DateTime')){
            prodMat.put(fieldName, convertToDateTime(fieldValue));
        }
        
    }
    public static void typeCastAndPopulateTsf(TSF_vod__c tsf, String objName, String fieldName, String fieldValue){
        System.debug('tsfInUtil #######'+ tsf.Id);
        String fieldType = AGN_typeConversionUtil.getFieldType(objName, fieldName);
        System.debug('tsfInUtil_fieldType$$ '+fieldType +'   -   ' +  fieldValue);
        if(fieldType.equalsIgnoreCase('Boolean')){
            System.debug('tsfInUtil_Bool_Before$$ ');
            tsf.put(fieldName, convertToBool(fieldValue));
            System.debug('tsfInUtil_Bool_After$$ ');
        }
        if((fieldType.equalsIgnoreCase('PICKLIST') || fieldType.equalsIgnoreCase('EMAIL') || fieldType.equalsIgnoreCase('REFERENCE') ||
            fieldType.equalsIgnoreCase('STRING') || fieldType.equalsIgnoreCase('CURRENCY') || fieldType.equalsIgnoreCase('PHONE'))){
                System.debug('tsfInUtil_STRING_Before$$ ');
                tsf.put(fieldName, fieldValue);
                System.debug('tsfInUtil_STRING_After$$ ');
            }
        if(fieldValue.isNumeric() &&  fieldType.equalsIgnoreCase('DOUBLE')){
            System.debug('tsfInUtil_DOUBLE_Before$$ ');
            tsf.put(fieldName, convertToDecimal(fieldValue));
            System.debug('tsfInUtil_DOUBLE_After$$ ');
        }
        if(fieldType.equalsIgnoreCase('Date')){
            tsf.put(fieldName, convertToDate(fieldValue));
        }
        if(fieldType.equalsIgnoreCase('DateTime')){
            tsf.put(fieldName, convertToDateTime(fieldValue));
        }
        
    }
    public static void typeCastAndPopulatechildAcc(Child_Account_vod__c childAcc, String objName, String fieldName, String fieldValue){
        System.debug('childAccInUtil #######'+ childAcc.Id);
        String fieldType = AGN_typeConversionUtil.getFieldType(objName, fieldName);
        System.debug('childAccInUtil_fieldType$$ '+fieldType +'   -   ' +  fieldValue);
        if(fieldType.equalsIgnoreCase('Boolean')){
            System.debug('childAccInUtil_Bool_Before$$ ');
            childAcc.put(fieldName, convertToBool(fieldValue));
            System.debug('childAccInUtil_Bool_After$$ ');
        }
        if((fieldType.equalsIgnoreCase('PICKLIST') || fieldType.equalsIgnoreCase('EMAIL') || fieldType.equalsIgnoreCase('REFERENCE') ||
            fieldType.equalsIgnoreCase('STRING') || fieldType.equalsIgnoreCase('CURRENCY') || fieldType.equalsIgnoreCase('PHONE'))){
                System.debug('childAccInUtil_STRING_Before$$ ');
                childAcc.put(fieldName, fieldValue);
                System.debug('childAccInUtil_STRING_After$$ ');
            }
        if(fieldValue.isNumeric() &&  fieldType.equalsIgnoreCase('DOUBLE')){
            System.debug('childAccInUtil_DOUBLE_Before$$ ');
            childAcc.put(fieldName, convertToDecimal(fieldValue));
            System.debug('childAccInUtil_DOUBLE_After$$ ');
        }
        if(fieldType.equalsIgnoreCase('Date')){
            childAcc.put(fieldName, convertToDate(fieldValue));
        }
        if(fieldType.equalsIgnoreCase('DateTime')){
            childAcc.put(fieldName, convertToDateTime(fieldValue));
        }
        
    }
}