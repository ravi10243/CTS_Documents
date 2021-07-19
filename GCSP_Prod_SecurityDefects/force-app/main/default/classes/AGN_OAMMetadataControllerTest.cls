@isTest
public class AGN_OAMMetadataControllerTest {

    
    @isTest public static void metadataTestmethod(){

        AGN_OAMMetadataController.getSObjectMetadata('Account');
        AGN_OAMMetadataController.getFieldMetadata('Account','Name');
        AGN_OAMMetadataController.PicklistEntryMetadata pWrap = new AGN_OAMMetadataController.PicklistEntryMetadata();
        
    }
}