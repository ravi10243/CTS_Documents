public class MDLocalisedPicklistVal 
{
	@AuraEnabled
    public String TranslatedLabel
    {get;set;}
    
    @AuraEnabled
    public String OptionLabel
    {get;set;}
    
    @AuraEnabled
    public String OptionValue
    {get;set;}
    
    @AuraEnabled
    public Boolean Include
    {get;set;}
}