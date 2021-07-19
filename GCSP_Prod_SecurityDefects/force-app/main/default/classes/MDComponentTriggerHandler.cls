public class MDComponentTriggerHandler {
	
    public static void populateBrandingJSONOnComponent(List<MDComponent__c> components) {
    	
        Map<String,JSONData__mdt> mapJSONData = new Map<String,JSONData__mdt>();
        for(JSONData__mdt JSONData : [SELECT DeveloperName, JSONBody__c FROM JSONData__mdt]){
            mapJSONData.put(JSONData.DeveloperName,JSONData);
        }
        for(MDComponent__c component : components){
            if(component.ComponentType__c =='ImportantInfo'){
                component.BrandingJSON__c = mapJSONData.get('ImportantInfo_Branding').JSONBody__c;
            }
            else if(component.ComponentType__c =='InlineHelp'){
                component.BrandingJSON__c = mapJSONData.get('InlineHelp_Branding').JSONBody__c;
            }
            else if(component.ComponentType__c =='PlainText'){
                component.BrandingJSON__c = mapJSONData.get('PlainText_Branding').JSONBody__c;
            }
            else if(component.ComponentType__c =='SectionHeader'){
                component.BrandingJSON__c = mapJSONData.get('SectionHeader_Branding').JSONBody__c;
            }
            else if(component.ComponentType__c =='TranslatedPicklist'){
                component.BrandingJSON__c = mapJSONData.get('TranslatedPicklist_Branding').JSONBody__c;
            }
        }
    }
}