@isTest
public class AGN_Filing_System_Owner_share_test {

    public static testmethod void AGN_Filing_System_Owner_share_test()
    {
        Test.Starttest();
        
         List<Asset_Register_AGN__c> assetList = new List<Asset_Register_AGN__c>();
          Asset_Register_AGN__c a= new Asset_Register_AGN__c ();
            a.Name='Test CCPA';
            a.Business_Owner_GDPR_AGN__c=UserInfo.getUserId();
            a.Top_Level_Business_Unit_GDPR_AGN__c = 'Commercial';
            a.AGN_Assign_Primary_Owner_in_queue__c = false;
         assetList.add(a);
        
        if(assetList.size()>0){
            insert assetList;
        }
        
        a.Top_Level_Business_Unit_GDPR_AGN__c = 'Legal and Compliance';
        a.AGN_Assign_Primary_Owner_in_queue__c = true;
        Update a;
        
       System.assertEquals('Test CCPA', a.Name);
        Test.StopTest();      
    }
    }