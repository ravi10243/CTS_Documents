//public class AGN_ICL_AllInputFieldForOAM {
public without sharing class AGN_ICL_AllInputFieldForOAM {  /* added without sharing for Spring'21 Release Updates */
    
   @AuraEnabled
    public static List<PicklistWrapper> getPicklistValues(String SObjectAPIName,String FieldAPIName)
    {
       List<PicklistWrapper> piclistval = new List<PicklistWrapper>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(SObjectAPIName).getDescribe().fields.getMap().get(FieldAPIName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple){
            piclistval.add(new PicklistWrapper(f));
        }   
        
        return piclistval;
    }
    
     @Testvisible
     private class PicklistWrapper {
        @AuraEnabled public String label           {get;private set;}
        @AuraEnabled public String value           {get;private set;}
        @AuraEnabled public Boolean isDefaultValue {get;private set;}
        
        public PicklistWrapper() {
            this.label          = '';
            this.value          = '';
            this.isDefaultValue = false;
        }
        
        public PicklistWrapper(Schema.PicklistEntry picklistEntry) {
            this.label          = picklistEntry.getLabel();
            this.value          = picklistEntry.getValue();
            this.isDefaultValue = picklistEntry.isDefaultValue();
        }
    }
}