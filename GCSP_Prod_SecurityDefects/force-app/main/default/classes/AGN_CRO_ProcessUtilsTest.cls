@IsTest
public class AGN_CRO_ProcessUtilsTest 
{

	public static testMethod void Test_fetchFieldMappings()
    {
        AGN_CRO_ProcessUtils.fetchFieldMappings();
        
        // Hopefully these two very important fields are never changed!
        system.assertEquals('FirstName', AGN_CRO_ProcessUtils.CroToAccountFieldMap.get('First_Name_AGN__c'));
        system.assertEquals('Address_line_2_vod__c', AGN_CRO_ProcessUtils.CraToAddressFieldMap.get('Address_Line_2_AGN__c'));
    }

}