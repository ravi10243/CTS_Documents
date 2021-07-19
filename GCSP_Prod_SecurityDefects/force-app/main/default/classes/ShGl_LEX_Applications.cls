public class ShGl_LEX_Applications {
	
    @auraenabled
    public static list<MDApplication__c> getMDApplications(){
        return [SELECT Id,Name, HelpKey__c,IsActive__c,PortalDescription__c,PortalLabel__c,ShGl_CheckList__c
               FROM MDApplication__c
               LIMIT 50000];
    }
    
    @auraenabled
    public static Id doInsertApplication(Id mdId,string appName,string onlineHelpKey, string onlineChecklistKey){
        //insert LEX application and return the id of LEX APplication
        LEXApplication__c app = new LEXApplication__c(MD_Application__c = mdId,Status__c = 'Draft',Name = appName);
        
        insert app;
        return app.Id;
    }
}