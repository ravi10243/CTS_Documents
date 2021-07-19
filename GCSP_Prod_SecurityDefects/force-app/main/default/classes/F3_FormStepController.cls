public class F3_FormStepController {

    @AuraEnabled 
    public static string GetPreviousStepId(string mdPageFormStepId)
    {
        string previousStep = '';
        
        // Get the current step
        List<MDFormStep__c> listCurrentStep = [SELECT Id,StepOrder__c, MDForm__c
                                                  FROM MDFormStep__c
                                                  WHERE Id = :mdPageFormStepId];
        
        if(!listCurrentStep.isEmpty())
        {
            MDFormStep__c currentStep = listCurrentStep[0];
            
            List<MDFormStep__c> listPrevious = [SELECT Id,StepOrder__c, MDForm__c
                                                  FROM MDFormStep__c
                                                  WHERE MDForm__c = :currentStep.MDForm__c
                                              			AND StepOrder__c < :currentStep.StepOrder__c
                                                     	AND IsActive__c = true
                                              	  ORDER BY StepOrder__c DESC NULLS LAST];
            
            if(!listPrevious.isEmpty())
            {
                previousStep = listPrevious[0].Id;
            }
            else
            {
                previousStep = 'START';
            }
        }
        
        return previousStep;
    }
    
    @AuraEnabled 
    public static string GetNextStepId(string mdPageFormStepId)
    {
        string nextStep = '';
        
        // Get the current step
        List<MDFormStep__c> listCurrentStep = [SELECT Id,StepOrder__c, MDForm__c
                                                  FROM MDFormStep__c
                                                  WHERE Id = :mdPageFormStepId];
        
        if(!listCurrentStep.isEmpty())
        {
            MDFormStep__c currentStep = listCurrentStep[0];
            
            List<MDFormStep__c> listNext = [SELECT Id,StepOrder__c, MDForm__c
                                                  FROM MDFormStep__c
                                                  WHERE MDForm__c = :currentStep.MDForm__c
                                              			AND StepOrder__c > :currentStep.StepOrder__c
                                                 		AND IsActive__c = true
                                              	  ORDER BY StepOrder__c asc];
            
            if(!listNext.isEmpty())
            {
                nextStep = listNext[0].Id;
            }
            else
            {
                nextStep = 'END';
            }
        }
        
        return nextStep;
    }
    
    @AuraEnabled
    public static List<MD_Message__mdt> getMessage(String key, String language) {
        return [SELECT title__c, message__c from MD_Message__mdt where language__c = :language and key__c = :key limit 1];
    }
    
    @AuraEnabled
    public static Id getPrimaryObjRecTypeId(string objectAPI,string recordTypeDevName){
        Id recTypeId ;
        list<RecordType> recordTypeList = [SELECT Id FROM RecordType 
                                           WHERE SObjectType=: objectAPI 
                                           AND DeveloperName =: recordTypeDevName];
        if(!recordTypeList.isEmpty()){
            recTypeId = recordTypeList[0].Id;
        }
        return recTypeId;
        
    }
    @AuraEnabled
    public static Case getCaseDetails(Id caseId)
    {
        Case cs = new Case();
        cs =[Select Id,First_Name_GDPR_AGN__c,Last_Name_GDPR_AGN__c from Case where Id =:caseId];
        
        return cs;
    }
    
}