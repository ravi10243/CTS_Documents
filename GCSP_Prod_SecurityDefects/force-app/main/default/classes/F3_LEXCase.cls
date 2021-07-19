/**
 * @Author : Gunwant patidar
 * Description : this class fetch case related LEX forms and steps and display.
 */
public class F3_LEXCase {
	
    @AuraEnabled
    public static list<LEXForm__c> doGetLEXForms(Id caseId){
        return [SELECT Id,Name,Case__c,MD_Form__c,Portal_Label__c,Status__c,Sort_Order__c,(SELECT Id,Name,LEXForm__c,Sort_Order__c,Status__c
               FROM LEX_FormSteps__r order by Sort_Order__c asc)
               FROM LEXForm__c WHERE Case__c =: caseId
               order by Sort_Order__c asc];
    }
    
    @AuraEnabled
    public static list<LEXFormStep__c> doGetLEXFormSteps(Id lexFormId){
        return [SELECT Id,Name,LEXForm__c,Sort_Order__c,Status__c
               FROM LEXFormStep__c WHERE LEXForm__c =: lexFormId
               order by Sort_Order__c asc];
    }
    
}