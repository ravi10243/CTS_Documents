//public class AGN_ICL_TestRegFormInputFieldController {
public without sharing class AGN_ICL_TestRegFormInputFieldController {  /* added without sharing for Spring'21 Release Updates */

   @AuraEnabled
    public static List<PicklistWrapper> getPicklistValues1(String SObjectAPIName,String FieldAPIName)
    {
        
        List<PicklistWrapper> piclistval = new List<PicklistWrapper>();
        Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(SObjectAPIName).getDescribe().fields.getMap().get(FieldAPIName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       
        for( Schema.PicklistEntry f : ple){
            
            piclistval.add(new PicklistWrapper(f));
        }   
       
        return piclistval;
    }
    
    @AuraEnabled
    public static List<AGN_ICL_UtlityClass.PicklistWrapper> getPicklistValues(String SObjectAPIName,String FieldAPIName)
    { 
        User u = [SELECT id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c  
                  FROM User 
                  WHERE id =:UserInfo.getUserId() 
                  LIMIT 1];
       
        return AGN_ICL_UtlityClass.getPicklistValues(SObjectAPIName, FieldAPIName, u.Country_Code__c);
    }
    @AuraEnabled
    public static List<AGN_ICL_UtlityClass.PicklistWrapper> getPicklistValuesLogged(String SObjectAPIName,String FieldAPIName)
    { 
        User u = [SELECT id,name,ContactId,Locator_Listing_Id_AGN__c,Country_Code__c  
                  FROM User 
                  WHERE id =:UserInfo.getUserId() 
                  LIMIT 1];
        
        return AGN_ICL_UtlityClass.getPicklistValues(SObjectAPIName, FieldAPIName, u.Country_Code__c);
    }
    @AuraEnabled
    public static List<AGN_ICL_UtlityClass.PicklistWrapper> getPicklistValuesFromLoc(String SObjectAPIName,String FieldAPIName,id LocId)
    { 
        Locator_Listing_AGN__c locObj = [SELECT id, Country_Code_AGN__r.Alpha_2_Code_vod__c 
                  FROM Locator_Listing_AGN__c 
                  WHERE id =:LocId
                  LIMIT 1];
       
        return AGN_ICL_UtlityClass.getPicklistValues(SObjectAPIName, FieldAPIName, locObj.Country_Code_AGN__r.Alpha_2_Code_vod__c );
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