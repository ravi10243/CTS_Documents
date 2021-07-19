public class CaseTriggerHandler {
    
    public static void afterInsert(List<Case> newList){
        String metadataDeveloperName;
        for(Case  cs : newList){
            metadataDeveloperName = cs.MetadataDeveloperName__c;
            break;
        }
        List<MDAppFormMap__c> listMDAppForms = [Select Id,MDForm__c,MDForm__r.Name,Sort_Order__c FROM MDAppFormMap__c  WHERE MDApplication__r.MetadataDeveloperName__c =: metadataDeveloperName];       
        
        List<LEXForm__c> lexFormInsert = new List<LEXForm__c>();
        for(Case  cs : newList){
            for(MDAppFormMap__c mdAppForm : listMDAppForms){
            	LEXForm__c lexForm = new LEXForm__c(Case__c = cs.Id,Portal_Label__c = mdAppForm.MDForm__r.Name,Md_Form__c = mdAppForm.MDForm__c, Sort_Order__c = mdAppForm.Sort_Order__c);
            	lexFormInsert.add(lexForm);
            }
        }
        
        Database.insert(lexformInsert,false);
        
        Map<Id,MDForm__c> mapMDForm = new Map<Id,MDForm__c>([Select Id,Name,(Select Id,Name,StepOrder__c, StepContextChangerClassAPIName__c, OnLoadViewState__c FROM MD_FormSteps__r) from MDForm__c]);
        list<LEXFormStep__c> lexFormStepsInsert = new list<LEXFormStep__c>();
        for(LEXForm__c lexForm : lexFormInsert){
            for(MDFormStep__c mdStep : mapMDForm.get(lexForm.Md_Form__c).MD_FormSteps__r){
            	LEXFormStep__c lexformStep = new LEXFormStep__c(LEXForm__c = lexForm.Id,Sort_Order__c = mdStep.StepOrder__c,StepContextChangerClassAPIName__c = mdStep.StepContextChangerClassAPIName__c,
                                                                CurrentViewState__c =  mdStep.OnLoadViewState__c, MDFormStep__c = mdStep.Id);
            	lexFormStepsInsert.add(lexFormStep);
            }
        }
        Database.insert(lexFormStepsInsert,false);
        
    }
}