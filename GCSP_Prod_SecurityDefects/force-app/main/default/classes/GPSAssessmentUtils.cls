public class GPSAssessmentUtils {

    public static void setAssessmentProductUniqueId(GPS_Assessment_Product_AGN__c assessmentProduct) {
        assessmentProduct.Unique_Id_AGN__c = '' + assessmentProduct.GPS_Assessment_AGN__c + assessmentProduct.Product_AGN__c;
    }

    public static void setAccountAssessmentUniqueId(Account_GPS_Assessment__c accountAssessment) {
        accountAssessment.Unique_ID_AGN__c = '' + accountAssessment.Account_AGN__c
            + accountAssessment.GPS_Assessment_AGN__c
            + accountAssessment.OwnerId;
    }

    public static void setAccountCustomerAssessmentUniqueId(Account_Customer_GPS_Assessment_AGN__c accountCustomerAssessment) {
        accountCustomerAssessment.Unique_ID_AGN__c = '' + accountCustomerAssessment.Customer_AGN__c
            + accountCustomerAssessment.Account_GPS_Assessment_AGN__c
            + accountCustomerAssessment.OwnerId;
    }

}