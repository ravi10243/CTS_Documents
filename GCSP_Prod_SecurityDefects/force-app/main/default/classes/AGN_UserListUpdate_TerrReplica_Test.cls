/**
* --------------
* Allerga-Targeting and Segmenta
* 09 June 2019
* Cognizant Dev team
* Segmentation & Targeting project
* --------------
* Test Class used for AGN_UserListUpdate_TerrReplica
*/
@isTest
public class AGN_UserListUpdate_TerrReplica_Test
{
    public static testmethod void AGN_testRepNameUpdate()
    {
        // Create test data
        String CRON_EXP = '0 0 0 12 6 ? 2019';
        Test.startTest();
        String jobId = System.schedule('AGN_UserListUpdate_TerrReplica_Test', CRON_EXP, new AGN_UserListUpdate_TerrReplica());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}