public class CMS_Applications {
    @auraenabled
    public static list<LEXApplication__c> getAllApplications(){
        return [SELECT Id,Name, ApplicationNumber__c,Application_NumberF__c,Status__c, createdDate FROM LEXApplication__c Order By createdDate DESC];
    }
    
    @auraenabled
    public static LEXApplication__c getApplicationById(Id appId){
        return [SELECT Id,Name, ApplicationNumber__c,Status__c, CreatedDate FROM LEXApplication__c where Id = : appId];
    }
    
    @auraenabled
    public static List<LEXForm__c> getApplicationForms(Id appId){
        return [SELECT Id,Name,Portal_Label__c, Status__c FROM LEXForm__c where LEXApplication__c = : appId];
    }
    
    @auraenabled
    public static String getMDForm(Id lexFormId){
        return [SELECT MD_Form__r.URLKey__c FROM LEXForm__c where Id = : lexFormId limit 1].MD_Form__r.URLKey__c;
        
    }
    
    @auraenabled
    public static void updateFormStatus(Id lexFormId){
        LEXForm__c form =  [SELECT id, Status__c FROM LEXForm__c where Id = : lexFormId limit 1];
        form.Status__c = 'In Progress';        
        update form;

    }
    
    
}