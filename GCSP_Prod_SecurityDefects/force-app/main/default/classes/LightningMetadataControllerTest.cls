@isTest
private class LightningMetadataControllerTest {

    @isTest
    static void getSObjectMetadataTest() {
        String sobjectName = 'Account';
        DescribeSObjectResult sobjectDescribe = Schema.Account.SObjectType.getDescribe();

        Test.startTest();
        LightningMetadataController.SObjectMetadata sobjectMetadata = LightningMetadataController.getSObjectMetadata(sobjectName);
        Test.stopTest();

        System.assertEquals(sobjectName, sobjectMetadata.name);
        System.assertEquals(sobjectDescribe.getLabel(), sobjectMetadata.label);
        System.assertEquals(sobjectDescribe.getLabelPlural(), sobjectMetadata.labelPlural);
    }

    @isTest
    static void getSObjectMetadataTestForInvalidSObjectName() {
        String sobjectName = 'FakeName';

        Test.startTest();
        try {
            LightningMetadataController.SObjectMetadata sobjectMetadata = LightningMetadataController.getSObjectMetadata(sobjectName);
            System.assert(false, 'Exception expected here');
        } catch(Exception ex) {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
        Test.stopTest();
    }

    @isTest
    static void getFieldMetadataTest() {
        String sobjectName = 'Account';
        String fieldName = 'Type';
        DescribeSObjectResult sobjectDescribe = Schema.Account.SObjectType.getDescribe();
        DescribeFieldResult fieldDescribe = Schema.Account.SObjectType.fields.Type.getDescribe();

        Test.startTest();
        LightningMetadataController.FieldMetadata fieldMetadata = LightningMetadataController.getFieldMetadata(sobjectName, fieldName);
        Test.stopTest();

        System.assertEquals(sobjectName, fieldMetadata.sobjectName);
        System.assertEquals(fieldName, fieldMetadata.name);
        System.assertEquals(fieldDescribe.getLabel(), fieldMetadata.label);
    }

    @isTest
    static void getFieldMetadataTestForInvalidFieldName() {
        String sobjectName = 'Account';
        String fieldName = 'FakeField';

        Test.startTest();
        try {
            LightningMetadataController.FieldMetadata fieldMetadata = LightningMetadataController.getFieldMetadata(sobjectName, fieldName);
            System.assert(false, 'Exception expected here');
        } catch(Exception ex) {
            System.assertEquals('System.AuraHandledException', ex.getTypeName());
        }
        Test.stopTest();
    }

}