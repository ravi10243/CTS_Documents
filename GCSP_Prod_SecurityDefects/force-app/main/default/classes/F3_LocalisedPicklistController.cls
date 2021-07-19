public class F3_LocalisedPicklistController 
{
    @AuraEnabled
    public static List<MDLocalisedPicklistVal> GetPicklistVal(Id elementId, string langCode)
    {
        List<MDLocalisedPicklistVal> listToBeLocalised;
        
        List<MDLocalisedPicklistVal> listToReturn;
        
        List<MDLocalisedComponent__c> listLocalisedPageElement = [SELECT ConfigJSON__c 
                                                                     FROM MDLocalisedComponent__c
                                                                    WHERE MDComponent__c = :elementId AND Language__c = :langCode];
        
        if(!listLocalisedPageElement.isEmpty())
        {
            String configJSON = listLocalisedPageElement[0].ConfigJSON__c;
            
            listToBeLocalised = (List<MDLocalisedPicklistVal>)System.JSON.deserialize(configJSON, List<MDLocalisedPicklistVal>.class);
            
            if(!listToBeLocalised.isEmpty())
            {
                listToReturn = new List<MDLocalisedPicklistVal>();
                
                for(MDLocalisedPicklistVal picklistVal : listToBeLocalised)
                {
                    if(picklistVal.Include == true)
                    {
                        listToReturn.add(picklistVal);
                    }
                }
            }
        }
        
        return listToReturn;
    }
    
    @AuraEnabled
    public static List<PicklistValOption> GetPicklistOptions(Id elementId, string langCode)
    {
        List<MDLocalisedPicklistVal> listToBeLocalised = new List<MDLocalisedPicklistVal>();
        
        List<PicklistValOption> listToReturn;
        
        List<MDLocalisedComponent__c> listLocalisedPageElement = [SELECT ConfigJSON__c 
                                                                     FROM MDLocalisedComponent__c
                                                                    WHERE MDComponent__c = :elementId AND Language__c = :langCode];
        if(!listLocalisedPageElement.isEmpty())
        {
            String configJSON = listLocalisedPageElement[0].ConfigJSON__c;
            if(configJSON != null){
            	listToBeLocalised = (List<MDLocalisedPicklistVal>)System.JSON.deserialize(configJSON, List<MDLocalisedPicklistVal>.class);
            }
            if(!listToBeLocalised.isEmpty())
            {
                listToReturn = new List<PicklistValOption>();
                
                for(MDLocalisedPicklistVal picklistVal : listToBeLocalised)
                {
                    if(picklistVal.Include == true)
                    {
                        PicklistValOption optVal = new PicklistValOption();
                        optVal.label = picklistVal.TranslatedLabel;
                        optVal.value = picklistVal.OptionValue;
                        
                        listToReturn.add(optVal);
                    }
                }
            }
        }
        
        return listToReturn;
    }
    
    public class PicklistValOption
    {
        @AuraEnabled
    	public String label
    	{get;set;}
        
        @AuraEnabled
    	public String value
    	{get;set;}            
    }
}