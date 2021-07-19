public class LEXApplicationTriggerHandler {
    public static void afterInsert(List<LEXApplication__c> newList){
        set<Id> mdApplicationIds = new set<Id>();
        for(LEXApplication__c  lexApp : newList){
            mdapplicationIds.add(lexApp.MD_Application__c);
        }
        
        list<MDAppFormMap__c> mdAppFormsList = [Select Id,MDForm__c,MDForm__r.Name FROM MDAppFormMap__c 
                                               WHERE MDApplication__c IN : mdapplicationIds];
        
        list<LEXForm__c> lexFormInsert = new list<LEXForm__c>();
        set<Id> mdFormIds = new set<Id>();
        // iterate on lex app and 
        for(LEXApplication__c  lexApp : newList){
            for(MDAppFormMap__c mdAppForm : mdAppFormsList){
                mdFormIds.add(mdAppForm.MDForm__c);
            	LEXForm__c lexForm = new LEXForm__c(LEXApplication__c = lexApp.Id,Portal_Label__c = mdAppForm.MDForm__r.Name,Md_Form__c = mdAppForm.MDForm__c);
            	lexFormInsert.add(lexForm);
            }
        }
        
        insert lexformInsert;
        
        map<Id,MDForm__c> mdFormMap = new map<Id,MDForm__c>([Select Id,Name,(Select Id,Name,StepOrder__c,OnLoadViewState__c FROM MD_FormSteps__r) from MDForm__c]);
        list<LEXFormStep__c> lexFormStepsInsert = new list<LEXFormStep__c>();
        for(LEXForm__c lexForm : lexFormInsert){
            for(MDFormStep__c mdStep : mdFormMap.get(lexForm.Md_Form__c).MD_FormSteps__r){
            	LEXFormStep__c lexformStep = new LEXFormStep__c(LEXForm__c = lexForm.Id,Sort_Order__c = mdStep.StepOrder__c, 
                                                                CurrentViewState__c = mdStep.OnLoadViewState__c);
            	lexFormStepsInsert.add(lexFormStep);
            }
        }
        insert lexFormStepsInsert;
    }
}