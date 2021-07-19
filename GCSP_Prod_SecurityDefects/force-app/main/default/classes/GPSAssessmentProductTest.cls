@isTest
private class GPSAssessmentProductTest {

    @testSetup
    static void testSetup() {
        GPSCreateTestData.createAssessment();
        GPSCreateTestData.createProducts();
    }

    @isTest
    static void setAssessmentProductUniqueId() {
        GPS_Assessment__c assessment = [SELECT Id FROM GPS_Assessment__c LIMIT 1];
        List<Product_vod__c> products = [SELECT Id FROM Product_vod__c LIMIT 5];

        List<GPS_Assessment_Product_AGN__c> assessmentProducts = GPSCreateTestData.createAssessmentProducts(products, assessment, false);
        for(GPS_Assessment_Product_AGN__c assessmentProduct : assessmentProducts) {
            assessmentProduct.Unique_Id_AGN__c = null;
        }
        insert assessmentProducts;

        Test.startTest();

        assessmentProducts = [SELECT Id, GPS_Assessment_AGN__c, Product_AGN__c, Unique_Id_AGN__c FROM GPS_Assessment_Product_AGN__c WHERE Id IN :assessmentProducts];
        for(GPS_Assessment_Product_AGN__c assessmentProduct : assessmentProducts) {
            String expectedUniqueId = '' + assessmentProduct.GPS_Assessment_AGN__c + assessmentProduct.Product_AGN__c;
            System.assertNotEquals(null, assessmentProduct.Unique_Id_AGN__c);
            System.assertEquals(expectedUniqueId, assessmentProduct.Unique_Id_AGN__c);
        }

        Test.stopTest();
    }

    @isTest
    static void setProductListOnAssessment() {
        GPS_Assessment__c assessment = [SELECT Id, Product_List_AGN__c FROM GPS_Assessment__c LIMIT 1];
        System.assertEquals(null, assessment.Product_List_AGN__c);
        List<Product_vod__c> products = [SELECT Id, Name FROM Product_vod__c ORDER BY Name LIMIT 5];

        List<String> productNames = new List<String>();
        for(Product_vod__c product : products) productNames.add(product.Name);
        String expectedProductList = String.join(productNames, '\n');

        Test.startTest();

        // Insert the assessment products and verify that the assessment's product list field has been updated
        List<GPS_Assessment_Product_AGN__c> assessmentProducts = GPSCreateTestData.createAssessmentProducts(products, assessment);
        assessment = [SELECT Id, Product_List_AGN__c FROM GPS_Assessment__c WHERE Id = :assessment.Id];
        System.assertEquals(expectedProductList, assessment.Product_List_AGN__c);

        // Delete an assessment product and verify that the assessment's product list field has been updated
        productNames.remove(0);
        delete assessmentProducts[0];
        expectedProductList = String.join(productNames, '\n');
        assessment = [SELECT Id, Product_List_AGN__c FROM GPS_Assessment__c WHERE Id = :assessment.Id];
        System.assertEquals(expectedProductList, assessment.Product_List_AGN__c);

        Test.stopTest();
    }

}