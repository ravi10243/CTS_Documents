/**************************************************************************************************************************
@ Class:          AGN_ContentDistributionTrigger_Test 
@ Version:        1.0
@ Author:         Ayush Basak (ayush.basak@cognizant.com)
@ Purpose:        This the test class for AGN_ContentDistributionTrigger and associated helper class
@ PMO:            CR-3334: Infocus tab introduction
---------------------------------------------------------------------------------------------------------------------------
@ Change history: 20.07.2020 / Ayush Basak / Created the class.
***************************************************************************************************************************/
@isTest
public class AGN_ContentDistributionTrigger_Test {
	@isTest
    static void testContentDeliveryTrigger(){
        
       	// Creating User
       	User adminUser = AGN_AMI_TestData_Factory.createUser('AGN AMI Admin Profile', 'U1');
        
        
        
        System.runAs(adminUser) {
            Test.startTest();
            
            // Creating Test Data
        	AMI_InFocus_AGN__c sampleInfocus = AGN_AMI_TestData_Factory.createInFocus();
        	AMI_Project_AGN__c sampleProject = AGN_AMI_TestData_Factory.createAMIProjectAGN();
            
           	// Testing for Infocus Updated
            ContentDistribution cd1 = AGN_AMI_TestData_Factory.createContentDelivery(sampleInfocus.Id);
            
            ContentDistribution cd1_fetch = [SELECT DistributionPublicUrl 
                                             FROM ContentDistribution 
                                             WHERE Id = :cd1.Id 
                                             LIMIT 1];
            
            AMI_InFocus_AGN__c infocus_fetch = [SELECT Video_URL_AGN__c 
                                                FROM AMI_InFocus_AGN__c 
                                                WHERE id = :sampleInfocus.Id 
                                                Limit 1];
           	System.assertEquals(cd1_fetch.DistributionPublicUrl, infocus_fetch.Video_URL_AGN__c);
            
            // Testing for Clinical Gallery Updated
            ContentDistribution cd2 = AGN_AMI_TestData_Factory.createContentDelivery(sampleProject.Id);
            
            ContentDistribution cd2_fetch = [SELECT DistributionPublicUrl 
                                             FROM ContentDistribution 
                                             WHERE Id = :cd2.Id 
                                             LIMIT 1];
            
            AMI_Project_AGN__c cg_fetch = [SELECT Content_Link_AGN_AMI__c 
                                           FROM AMI_Project_AGN__c 
                                           WHERE id = :sampleProject.Id 
                                           Limit 1];
           	System.assertEquals(cd2_fetch.DistributionPublicUrl, cg_fetch.Content_Link_AGN_AMI__c);
            
            // Testing for unrelated ContentDistribution
            ContentDistribution cd3 = AGN_AMI_TestData_Factory.createContentDelivery(sampleProject.Id);
            List<ContentDistribution> cd3_fetch = [SELECT DistributionPublicUrl 
                                                   FROM ContentDistribution 
                                                   WHERE Id = :cd3.Id];
            System.assertEquals(1, cd3_fetch.size());
            
            Test.stopTest();
        }
    }
}