public Without Sharing class AGN_ICLInputFieldController {
    
    
    @AuraEnabled (cacheable=true)
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
    
    @AuraEnabled (cacheable=true)
    public static List<AGN_ICL_UtlityClass.PicklistWrapper> getPicklistValues(String SObjectAPIName,String FieldAPIName,String countryCode)
    {
        return AGN_ICL_UtlityClass.getPicklistValues(SObjectAPIName, FieldAPIName, countryCode);
    }
    
    @AuraEnabled (cacheable=true)
    public static List<AGN_ICL_UtlityClass.PicklistWrapper> getPicklistValuesLogged(String SObjectAPIName,String FieldAPIName)
    { 
        User u = [SELECT id,Country_Code__c  
                  FROM User 
                  WHERE id =:UserInfo.getUserId() 
                  LIMIT 1];
        return AGN_ICL_UtlityClass.getPicklistValues(SObjectAPIName, FieldAPIName, u.Country_Code__c);
    }
    @AuraEnabled (cacheable=true)
    public static String getcountry(String country)
    {
        
        
        List<AGN_ICL_Country_Settings__c > countryval=[select Name,Country_AGN__c from AGN_ICL_Country_Settings__c where Country_AGN__c = :country ];
        return countryval[0].Name;
        
    }
    @AuraEnabled
    public static String getloggedInUserCountry()
    {   
        User u = [Select id,name,Country_code__c from User where Id=:UserInfo.getUserId() limit 1];
        List<AGN_ICL_Country_Settings__c > countryval=[select Name,Country_AGN__c from AGN_ICL_Country_Settings__c where Country_AGN__c = :u.Country_Code__c ];
        return countryval[0].Name;
        
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
        public PicklistWrapper(String label, String value, Boolean isDefaultValue) {
            this.label          = label;
            this.value          = value;
            this.isDefaultValue = isDefaultValue;
        }
    }
}