public class AGN_AMI_Content_Trigger_Handler {
    /*to trigger AMI_Sessions_AGN__c so that the changes in content will be reflected in AMI_Path_Session_AGN__c */
    public static void manageSessionPathUpdate(List<AMI_Content_AGN__c>triggerNew){
        Set <Id> setContentId = New Set <Id>();
        for(AMI_Content_AGN__c content :triggerNew){
            setContentId.add(content.id);
        }
        List <AMI_Sessions_AGN__c> sessionToUpdate = [SELECT Id FROM AMI_Sessions_AGN__c WHERE AMI_Content_AGN__c in :setContentId ];
        update sessionToUpdate;
        
    }

}