/**
 *
 * @Class Name: AGN_SPARK_TrainingCtrl
 * @Created Date: 
 * @Description: Controller class for Training page component
 * @Author: 
 * @History     :  
 */
public Without Sharing class AGN_SPARK_TrainingCtrl {  //added without sharing keyword for Spring '21 release

    /*
     * Method to get Pdf & Images URL used in the traing component
     */
    @AuraEnabled
    public static Map<String,String> getUrls(){ 
        Map<String,String> urlMap = new Map<String,String>();	 	
        urlMap = AGN_SPARK_Utility.getImageURL('TrainingPage');
        urlMap.put('businessTraining', AGN_SPARK_Utility.SPARK_SETTINGS.BusinessTrainingVisitSiteUrl__c);
        urlMap.put('webinarsAndEventsPDF', AGN_SPARK_Utility.SPARK_SETTINGS.WebinarsAndEventsPDFUrl__c);
        return urlMap;  
    } 
}