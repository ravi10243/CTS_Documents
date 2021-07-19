/**
 * @description       : Create the test class for the AGN_GCSP_MetadataController.
 * @author            : Ravi Sirigiri
 * @group             : 
 * @last modified on  : 03-25-2021
 * @last modified by  : Avik Shaw
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   01-04-2021   Ravi Sirigiri   Initial Version
**/
@isTest
private class AGN_GCSP_MetadataControllerTest{

	@isTest static void metaDataTestMethod() {
		AGN_GCSP_MetadataController.SObjectMetadata objMetaData = new AGN_GCSP_MetadataController.SObjectMetadata('Account');
		objMetaData = AGN_GCSP_MetadataController.getSObjectMetadata('Account');		
		system.assertEquals(objMetaData.name, 'Account', 'expected value and actual value should be same');
        try{
            AGN_GCSP_MetadataController.getSObjectMetadata(null);
        }catch(Exception e){}
        AGN_GCSP_MetadataController.getFieldMetadata('Account','Name','Id');
        try{
            AGN_GCSP_MetadataController.getFieldMetadata(null,'Name','Id');
        }catch(Exception e){}
        try{
            AGN_GCSP_MetadataController.getFieldMetadata('Account','Type','Id');
        }catch(Exception e){}
        try{
            AGN_GCSP_MetadataController.getFieldMetadata('Allergan_Customer_Address_AGN__c','State_AGN__c','Country_AGN__c');
        }catch(Exception e){}
        AGN_GCSP_MetadataController.PicklistEntryMetadata pWrap = new AGN_GCSP_MetadataController.PicklistEntryMetadata();
        String labelValue = AGN_GCSP_MetadataController.getLabelString('AGN_OAM_Last_Name');
        system.assert(String.isNotEmpty(labelValue));
        
	}

	
}