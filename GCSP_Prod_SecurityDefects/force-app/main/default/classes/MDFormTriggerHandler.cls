public class MDFormTriggerHandler {
	
    public static void createMDFormStepAfterInsert(List<MDForm__c> newForms, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when AFTER_INSERT {
                System.debug('Testing FORM AFTER INSERT');
                System.debug(newForms);
                List<MDFormStep__c> mdFormSteps = new List<MDFormStep__c>();
                for(MDForm__c form : newForms) {
                    //Step 1
                    mdFormSteps.add(new MDFormStep__c(
                        MDForm__c = form.Id,
                        DeveloperName__c = 'Step 1',
                        type__c = 'Data Capture',
                        StepOrder__c = 1,
                        isActive__c = true,
                        LocalisedShortName__c = 'Short 1',
                        LocalisedLongName__c = 'Long 1'
                    ));
                    //Success
                    if(form.RecordTypeName__c != 'CaseForm'){
                        mdFormSteps.add(new MDFormStep__c(
                            MDForm__c = form.Id,
                            DeveloperName__c = 'Success',
                            type__c = 'Success',
                            StepOrder__c = 99,
                            isActive__c = true
                        ));
                    }
                }
                insert mdFormSteps;
            }
        }
    }
    
    public static void populateBrandingJSONOnForm(List<MDForm__c> forms) {
    	
        Map<String,JSONData__mdt> mapJSONData = new Map<String,JSONData__mdt>();
        for(JSONData__mdt JSONData : [SELECT DeveloperName, JSONBody__c FROM JSONData__mdt]){
            mapJSONData.put(JSONData.DeveloperName,JSONData);
        }
        Id unAuthFormRecordTypeId = Schema.SObjectType.MDForm__c.getRecordTypeInfosByDeveloperName().get('Unauthenticated').getRecordTypeId();
        
        for(MDForm__c form : forms){
            system.debug('form recordtype id: ' + unAuthFormRecordTypeId + ' :: ' + form.RecordTypeId);
            //if(form.RecordTypeId == unAuthFormRecordTypeId){
                form.BrandingJSON__c = mapJSONData.get('UnauthenticatedForm_Branding').JSONBody__c;
            //}
        }
    }
    public static void populatePropertiesJSONOnForm(List<MDForm__c> forms) {
    	
        Map<String,JSONData__mdt> mapJSONData = new Map<String,JSONData__mdt>();
        for(JSONData__mdt JSONData : [SELECT DeveloperName, JSONBody__c FROM JSONData__mdt]){
            mapJSONData.put(JSONData.DeveloperName,JSONData);
        }
        Id unAuthFormRecordTypeId = Schema.SObjectType.MDForm__c.getRecordTypeInfosByDeveloperName().get('Unauthenticated').getRecordTypeId();
        for(MDForm__c form : forms){
            system.debug('JSON form recordtype id: ' + unAuthFormRecordTypeId + ' :: ' + form.RecordTypeId);
            //if(form.RecordTypeId == unAuthFormRecordTypeId){
                form.PropertiesJSON__c = mapJSONData.get('UnauthenticatedForm_Properties').JSONBody__c;
            //}
        }
    }
    
}