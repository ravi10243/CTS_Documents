global class AGN_batchSparkConsentEmail implements Database.Batchable<sObject>,Database.Stateful
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'select recordtype.name, CreatedBy.Name  from Multichannel_Consent_vod__c where createddate >= TODAY ';
        system.debug('query is' +query);
        return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext BC, List<Multichannel_Consent_vod__c> scope)
    {
        list<Multichannel_Consent_vod__c> MC_final = new list<Multichannel_Consent_vod__c>();
        for ( Multichannel_Consent_vod__c mc : scope)
            {
              if(mc.recordtype.name != Label.AGN_ICL_Consent_Recordtype && mc.CreatedBy.Name == Label.AGN_SPARK_Guest_User_Name )
                {
                    MC_final.add(mc);
                }

            }
        AGN_ConsentEmailNotifcationHelper helper = new AGN_ConsentEmailNotifcationHelper();
        helper.sendEmail(MC_final); 
    }
    
    global void finish(Database.BatchableContext BC)
    {
    } 

}