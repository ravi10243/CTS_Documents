public class MDChildObjectSingleConfig 
{
	@AuraEnabled
    public static string ChildObjectAPIName {get;set;}
    
    @AuraEnabled
    public static string RelationshipFieldAPIName {get;set;}
    
    @AuraEnabled
    public List<MDChilObjectFieldConfig> ListFieldConfig {get;set;}
}